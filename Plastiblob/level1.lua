-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

function scene:create( event )

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then

		--We display the plastic beach backgrounds that need to scroll. We put the X and Y anchor to 0 so that the image is out of
		--frame when it reaches the negative of its actual width and the function sets it back at the center.
		local plastic = display.newImageRect("/immagini/livello-1/plastic-beach.png",display.actualContentWidth, display.actualContentHeight)
		plastic.anchorX=0
		plastic.anchorY=0
		plastic.x = display.contentCenterX-640
		plastic.y = display.contentCenterY-360
		
		local plastic_next = display.newImageRect("/immagini/livello-1/plastic-beach.png",display.actualContentWidth,display.actualContentHeight)
		plastic_next.anchorX=0
		plastic_next.anchorY=0
		plastic_next.x = display.contentCenterX+640
		plastic_next.y = display.contentCenterY-360

		local speed = 4
		
		--PRIMA NUVOLA
		
		local cloudOptions =
		{
			width = 300,
			height = 200,
			numFrames = 6
		}
		local cloudSheet = graphics.newImageSheet( "/immagini/livello-1/nuvola1.png", cloudOptions )
		local sequenceDataCloud =
		{
			name="play",
			start=1,
			count=6,
			time=2800,
			loopCount = 0,   -- Optional ; default is 0 (loop indefinitely)
			loopDirection = "bounce"    -- Optional ; values include "forward" or "bounce"
		}
		
		--SECONDA NUVOLA
		
		local cloudOptions2 =
		{
			width = 200,
			height = 100,
			numFrames = 6
		}
		local cloudSheet2 = graphics.newImageSheet( "/immagini/livello-1/nuvola2.png", cloudOptions2)
		local sequenceDataCloud2 =
		{
			name="play",
			start=1,
			count=6,
			time=3000,
			loopCount = 0,   -- Optional ; default is 0 (loop indefinitely)
			loopDirection = "bounce"    -- Optional ; values include "forward" or "bounce"
		}
		--DISPLAY PRIMA NUVOLA E PLAY ANIMAZIONE
		local cloud = display.newSprite( cloudSheet, sequenceDataCloud )
		cloud.x = display.contentCenterX+800
		cloud.y = display.contentHeight-500;
		cloud:play()

		--DISPLAY SECONDA NUVOLA E PLAY ANIMAZIONE
		local cloud_next = display.newSprite(cloudSheet2,sequenceDataCloud2)
		cloud_next.x= display.contentCenterX;
		cloud_next.y=display.contentCenterY-200;
		cloud_next:play()

		--We define the scroll function for the background
		local function scroll(self,event)
		if 	self.x<-(display.contentWidth-speed*2) then
			self.x = display.contentWidth
		else
			self.x =self.x - speed
		end	
	end

	--We define the scroll function for the clouds at a different speed
	local function scroll_clouds(self,event)
		if self.x<-(display.contentWidth/4-speed*2) then
				self.x = display.contentWidth+(math.random(50,200));
				self.y = display.contentHeight-(math.random(500,620));
				--print(self.X);
				print(self.y);
			else
				self.x =self.x - speed/2
				
		end	
	end

	plastic.enterFrame = scroll
	Runtime:addEventListener("enterFrame",plastic)
	plastic.enterFrame = scroll
	Runtime:addEventListener("enterFrame",plastic_next)
	plastic_next.enterFrame = scroll
	cloud.enterFrame = scroll_clouds
	Runtime:addEventListener("enterFrame",cloud)
	cloud_next.enterFrame = scroll_clouds
	Runtime:addEventListener("enterFrame",cloud_next)
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

	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	local sceneGroup = self.view
	
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene

--[[we add the first cloud 
local opt = { width = 300, height = 200, numFrames = 6}
local cloudSheet = graphics.newImageSheet("Immagini/livello-1/nuvola1.png", opt)
local seqs ={{
	          name = "nuvola1",
			  start = 1,
              count = 6,
              time = 300,
			  loopCount = 0,
			  loopDirection ="bounce"
	    	 }
			} 
local nuvola1=display.newSprite(cloudSheet,seqs)
plane.x = display.contentCenterX - 90
plane.y = display.contentCenterY - 90
]]--