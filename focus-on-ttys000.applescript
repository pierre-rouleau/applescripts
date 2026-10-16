-- APPLES FILE: focus-on-ttys000.applescript
--
-- Purpose   : Change focus to the very first Terminal window opened.
-- Created   : Friday, October 16 2026.
-- Author    : Pierre Rouleau <prouleau001@gmail.com>
-- Time-stamp: <2026-10-16 16:13:27 EDT, updated by Pierre Rouleau>
-- ---------------------------------------------------------------------------

-- Module Description
-- ------------------
--
-- Activate the Terminal window/tab for ttys000.  That is normally the very
-- first Terminal window that was created (if it was not closed).
--
-- By using the first Emacs session created in thei Terminal window, then this
-- quickly moves focus to the Emacs session that holds the Agenda when that is
-- used.
--
-- The script works in 2 step: first change the macOS desktop that has a
-- Teminal application windo inside it and then move to the appropriate window
-- and tab, putting focus on it.

-- ---------------------------------------------------------------------------
-- Dependencies
-- ------------
--
-- Terminal application.
-- Compile this into a signed .app file to run.
--  - Use the AppleScript Editor and export a signed .app file
--  - You can also use PEL bin/build-applescript shell script.
--    - See: https://github.com/pierre-rouleau/pel/blob/master/bin/build-applescript

-- ---------------------------------------------------------------------------
-- Code
-- ----
--
--

-- Part 1: Move to a desktop that has a Terminal window
-- ====================================================

tell application "Terminal"
	-- A simple activation tells macOS to jump to an active Terminal Space
	activate
end tell

-- Give the macOS window manager a brief moment to complete the Desktop transition animation
delay 0.4


-- Part 2: Set focus to the Terminal window/tab that is the ttys001
-- ================================================================

global foundMatch
global targetWindowID

tell application "Terminal"
	set targetTTY to "/dev/ttys000"
	set foundMatch to false
	set targetWindowID to 0

	repeat with currentWindow in windows
		if foundMatch is true then exit repeat

		repeat with currentTab in tabs of currentWindow
			if tty of currentTab is targetTTY then
				activate
				set index of currentWindow to 1
				set selected of currentTab to true

				-- Capture the exact system ID of this specific window object
				set targetWindowID to id of currentWindow
				set foundMatch to true
				exit repeat
			end if
		end repeat
	end repeat
end tell

-- Lock onto the exact window ID we discovered
if foundMatch is true and targetWindowID is not 0 then
	try
		tell application "System Events"
			tell process "Terminal"
				set frontmost to true
				-- Raise the specific window matching our ID, not a generic index
				perform action "AXRaise" of (first window whose id is targetWindowID)
			end tell
		end tell
	on error
		-- Quietly catch any UI stutter
	end try
end if

-- ---------------------------------------------------------------------------
