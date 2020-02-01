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
    local background = self.view
    local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
    elseif phase == "did" then
        --dichiaro un vettore di oggetti per contenere il background
        local plastic = {}
        local speed = 5
        local imgwidth = 1280
        local imgheight = 720
        --do al primo oggetto la foto di sfondo e lo posiziono nelle coordinate 0,0
        plastic[1] = display.newImageRect("immagini/livello-1/plastic-beach.png", imgwidth, imgheight)
        plastic[1].anchorX=0
		plastic[1].anchorY=0
		plastic[1].x = 0
        plastic[1].y = 0
        --secondo oggetto contenente la stessa immagine che partirà quando finisce l'altra
        plastic[2] = display.newImageRect("immagini/livello-1/plastic-beach.png", imgwidth, imgheight)
        plastic[2].anchorX=0
		plastic[2].anchorY=0
		plastic[2].x = display.contentWidth
        plastic[2].y = 0

        local function scroller(self, event)
            if self.x < -(display.contentWidth-speed*2) then
                self.x = display.contentWidth
            else 
                self.x = self.x - speed
            end
        end
        plastic[1].enterFrame = scroller 
        Runtime:addEventListener( "enterFrame", plastic[1] )
        plastic[2].enterFrame = scroller 
        Runtime:addEventListener( "enterFrame", plastic[2] )
        background:insert(plastic[1])
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