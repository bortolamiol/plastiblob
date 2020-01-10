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

	--We define the scroll function
local function scroll(self,event)
    if self.x<-(display.contentWidth-speed*2) then
		self.x = display.contentWidth
		print(x)
	else
		self.x =self.x - speed
		
	end	
end	

plastic.enterFrame = scroll
Runtime:addEventListener("enterFrame",plastic)
plastic.enterFrame = scroll
Runtime:addEventListener("enterFrame",plastic_next)
plastic_next.enterFrame = scroll

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