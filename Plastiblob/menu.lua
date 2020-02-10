-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "widget" library
local widget = require "widget"

local musicTrack1
--------------------------------------------

-- forward declarations and other locals
-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease()
	
	-- go to level1.lua scene
	composer.gotoScene( "menu-levels", "fade", 500 )
	
	return true	-- indicates successful touch
end

function scene:create( event )
	local sceneGroup = self.view

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	-- display a background image
	local background = display.newImageRect( "immagini/menu/sfondomenu.png", display.actualContentWidth, display.actualContentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x = 0 + display.screenOriginX 
	background.y = 0 + display.screenOriginY
	
	-- create/position logo/title image on upper-half of the screen
	
	local titleLogo = display.newImageRect( "immagini/menu/logo.png", display.contentWidth, display.contentHeight)
	titleLogo.anchorX = 0
	titleLogo.anchorY = 0
	titleLogo.x= contentCenterX
	titleLogo.y= -100
	
	
	-- create a widget button (which will loads level1.lua on release)
	-- Example assumes 'imageSheet' is already created from graphics.newImageSheet()
 
	-- consecutive frames
	local playButtonOptions =
	{
		width = 500,
		height = 200,
		numFrames = 10
	}
	local playbtnsheet = graphics.newImageSheet( "immagini/menu/playbottle200.png", playButtonOptions )
	local sequenceDataPlay =
	{
		name="play",
		start=1,
		count=10,
		time=800,
		loopCount = 0,   -- Optional ; default is 0 (loop indefinitely)
		loopDirection = "bounce"    -- Optional ; values include "forward" or "bounce"
	}
	
	local playBtn = display.newSprite( playbtnsheet, sequenceDataPlay )
	playBtn.x = display.contentCenterX
	playBtn.y = display.contentHeight - 195
	playBtn:addEventListener("touch", onPlayBtnRelease)
	playBtn:play()

	--bottone per cancellare i dati dal database
	local deletedata = display.newImageRect( "immagini/menu/x.png", 80, 80 )
	deletedata.anchorX =  0
	deletedata.anchorY =  0
	deletedata.x = display.actualContentWidth - 100
	deletedata.y = display.actualContentHeight - 100

	-- aggiungiamo la musica di background del menù

	musicTrack1 = audio.loadStream("MUSIC/THEME.mp3")

	--funzione per cancellare i dati dal database
	function deletedata:touch( event )
		if event.phase == "began" then
			--cancello i  dati dal database
			-- Require the SQLite library
			local sqlite3 = require( "sqlite3" )	
			-- Create a file path for the database file "data.db"
			local path = system.pathForFile( "data.db", system.DocumentsDirectory )
			-- Open the database for access
			local db = sqlite3.open( path )
			--controllo se la tabella 'levels' esiste già, sennò la devo creare
			local deletedb = [[DROP TABLE levels;]]
			local s = db:exec( deletedb )
			print(s)
			return true
		end
	end
	deletedata:addEventListener( "touch", goback )
	sceneGroup:insert( background )
	sceneGroup:insert( titleLogo)
	sceneGroup:insert( playBtn )
	sceneGroup:insert(deletedata)
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
		
		-- Start the music!
        audio.play( musicTrack1, { channel=1, loops=-1 } )
	end	
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
		-- Called when the scene is now off screen
		-- Stop the music!
		--audio.fade( )
		audio.stop(1)
	end	
end

function scene:destroy( event )
	local sceneGroup = self.view
	
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	
	audio.dispose( musicTrack1 )

	if playBtn then
		playBtn:removeSelf()	-- widgets must be manually removed
		playBtn = nil
	end
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene