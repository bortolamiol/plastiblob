-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "widget" library
local widget = require "widget"

--------------------------------------------

-- forward declarations and other locals
local playBtn

-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease()
	
	-- go to level1.lua scene
	composer.gotoScene( "level-1", "fade", 1000 )
	
	return true	-- indicates successful touch
end

function scene:create( event )
	local sceneGroup = self.view
	
	--CREAZIONE DI UN DATABASE PER CONTENERE I LIVELLI
	-- Require the SQLite library
	local sqlite3 = require( "sqlite3" )	

	-- Create a file path for the database file "data.db"
	local path = system.pathForFile( "data.db", system.DocumentsDirectory )

	-- Open the database for access
	local db = sqlite3.open( path )

	local tableSetup = [[CREATE TABLE IF NOT EXISTS levels ( ID INTEGER PRIMARY KEY, INTEGER level );]]
	db:exec( tableSetup )

	local insertQuery = [[INSERT INTO levels VALUES ( NULL, "1" );]]
	db:exec( insertQuery )

	local people = {}
 
	-- Loop through database table rows via a SELECT query
	for row in db:nrows( "SELECT * FROM levels" ) do
	
		print( "Row:", row.level )
	
		-- Create sub-table at next available index of "people" table
		people[#people+1] =
		{
			FirstName = row.FirstName,
			print( "Row:", row.ID, " ", row.level )
		}
	end
	local insertQuery = [[DROP TABLE levels;]]
	db:exec( insertQuery )
		-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	-- display a background image
	local background = display.newImageRect( "immagini/menu/sfondo-menu-livelli.png", display.actualContentWidth, display.actualContentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x = 0 + display.screenOriginX 
	background.y = 0 + display.screenOriginY
	
	
	-- all display objects must be inserted into group
	sceneGroup:insert( background )
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
	end	
end

function scene:destroy( event )
	local sceneGroup = self.view
	
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------


return scene