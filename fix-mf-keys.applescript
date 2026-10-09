-- APPLES FILE: fix-mf-keys.applescript
--
-- Purpose   : Change the format of <M-f..> key sequences to M-<f..>.
-- Created   : Friday, October  9 2026.
-- Author    : Pierre Rouleau <prouleau001@gmail.com>
-- Time-stamp: <2026-10-09 16:09:26 EDT, updated by Pierre Rouleau>
-- ---------------------------------------------------------------------------
-- Module Description
-- ------------------
--
--  This is a script meant to be used inside macOS Number.
--  It replaces the key-sequences descriptions that relate to Meta and function keys.
--  It also produces a log of the modified tabs.
--
-- Should be compiled as a script: a .scpt file, with the following command:
--
--   osacompile -o <PATH_TO>/fix-m-function.scpt <PATH_TO>/fix-m-function.applescript
--
-- ---------------------------------------------------------------------------
-- Dependencies
-- ------------
--
--

-- ---------------------------------------------------------------------------
-- Code
-- ----
--

-- Define the log file path on your Desktop
set desktopPath to (path to desktop as text)
set logFilePath to POSIX path of (desktopPath & "Numbers_Changed_Tabs_Log.txt")

-- Define the strings to find and their replacements
set findList to {"<M-f8>", "<M-f11>", "<M-f12>"}
set replaceList to {"M-<f8>", "M-<f11>", "M-<f12>"}

set changedTabs to {}

tell application "Numbers"
	activate
	if not (exists document 1) then
		display dialog "Please open a Numbers document first." buttons {"OK"} default button 1
		return
	end if

        tell document 1
	    repeat with aSheet in sheets
		set sheetChanged to false
		set sheetName to name of aSheet

		repeat with aTable in tables of aSheet
		    tell aTable
			-- Loop through rows and columns structurally rather than blindly pulling all cells
			repeat with r from 1 to count of rows
			    repeat with c from 1 to count of columns
				set aCell to cell c of row r
				set cellName to name of aCell

				-- Numbers Quirk Fix: If the actual cell name doesn't match the row/column coordinate,
				-- it's a hidden constituent of a merged block. Skip it to prevent changing
                                -- the same text more than once
				if cellName is (name of column c & r) then
				    set cellValue to value of aCell

				    if class of cellValue is text then
					repeat with i from 1 to count of findList
					    set toFind to item i of findList
					    set toReplace to item i of replaceList

					    if cellValue contains toFind then
						-- Perform the string replacement
						set newValue to my replaceText(cellValue, toFind, toReplace)
						set value of aCell to newValue
						set sheetChanged to true
					    end if
					end repeat
				    end if
				end if

			    end repeat
			end repeat
		    end tell
		end repeat

		-- Record the tab name if any changes occurred
		if sheetChanged is true then
		    if sheetName is not in changedTabs then
			copy sheetName to end of changedTabs
		    end if
		end if
	    end repeat
	end tell
end tell

-- Write the results to the log file
if (count of changedTabs) > 0 then
	set logContent to "The following tabs were modified on " & (current date) as text & return & return
	repeat with aTab in changedTabs
		set logContent to logContent & "- " & aTab & return
	end repeat
	my writeToFile(logFilePath, logContent)
	display dialog "Replacement complete! Log saved to Desktop." buttons {"OK"} default button 1
else
	my writeToFile(logFilePath, "No matching strings were found. No tabs changed.")
	display dialog "No matching strings were found." buttons {"OK"} default button 1
end if

-- Helper text replacement function
on replaceText(theText, toFind, toReplace)
	set AppleScript's text item delimiters to toFind
	set theItems to text items of theText
	set AppleScript's text item delimiters to toReplace
	set cleanText to theItems as string
	set AppleScript's text item delimiters to ""
	return cleanText
end replaceText

-- Helper file writing function
on writeToFile(filePath, fileText)
	try
		set fileReference to open for access POSIX file filePath with write permission
		set eof of fileReference to 0 -- Clear existing file contents
		write fileText to fileReference as «class utf8»
		close access fileReference
	on error
		try
			close access fileReference
		end try
	end try
end writeToFile


-- ---------------------------------------------------------------------------
