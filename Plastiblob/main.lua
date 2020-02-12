-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )

-- include the Corona "composer" module
local composer = require "composer"

-- Reserve channel 1 for background music. Channel 1 tells the Corona audio library to reserve channel 1. 
-- While reserved, no audio file will play on the channel unless we explicitly command it to.
audio.reserveChannels( 1 )
audio.reserveChannels( 2 )
-- Reduce the overall volume of the channel
audio.setVolume( 0.5, { channel=1 } )
audio.setVolume( 0.5, { channel=2 } )

-- load menu screen
--NON CANCELLARE LA PROSSIMA RIGA
composer.gotoScene( "menu" )
--composer.gotoScene( "levels.level3" )
