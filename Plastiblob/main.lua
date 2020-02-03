-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )

-- include the Corona "composer" module
local composer = require "composer"

-- load menu screen
-- ciao
--NON CANCELLARE LA PROSSIMA RIGA
--composer.gotoScene( "menu" )
composer.gotoScene( "levels.level2" )