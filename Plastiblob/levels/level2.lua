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
    --richiedo la libreria necessaria per inserire la fisica all'interno del livello
    local physics = require("physics")
    physics.start()
    -- Overlays collision outlines on normal display objects
    --physics.setDrawMode( "hybrid" )
    -- The default Corona renderer, with no collision outlines
    physics.setDrawMode( "normal" )
    -- Shows collision engine outlines only
    --physics.setDrawMode( "debug" )  
    local sceneGroup = self.view
    local ground = display.newRect( 0, 0, display.contentWidth, 80 )
    ground.x = display.contentCenterX
    ground.y = display.contentHeight - 40
    physics.addBody(ground, "static",{ friction=0.5, bounce=0 } )

    end

function scene:show( event )
    local background = self.view
    local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
    elseif phase == "did" then
        -- Set up a few local variables for convenience
        local _w = display.contentWidth  -- Width of screen
        local _h = display.contentHeight  -- Height of screen
        local _x = 0  -- Horizontal centre of screen
        local _y = 0  -- Vertical centre of screen

        bg={}
            bg[1] = display.newImageRect("immagini/livello-1/plastic-beach.png", _w, _h)
            bg[1].anchorY = 0
            bg[1].anchorX = 0
            bg[1].x = 0
            bg[1].y = _y
            bg[2] = display.newImageRect("immagini/livello-1/plastic-beach.png", _w, _h)
            bg[2].anchorY = 0
            bg[2].anchorX = 0
            bg[2].x = _w
            bg[2].y = _y
                

        local speed = 5 -- I increased this to speed up testing
            
        function move()
            bg[1].x = bg[1].x-speed
            bg[2].x = bg[2].x-speed
            if(bg[1].x < -(bg[1].contentWidth - speed*2))then
                bg[1].x = _w
            elseif(bg[2].x < -(bg[2].contentWidth - speed*2))then
                bg[2].x = _w
            end
        end

        -- Example assumes 'imageSheet' already created using graphics.newImageSheet()
        
        -- 1st image sheet
        local sheetData1 = { width=200, height=200, numFrames=8, sheetContentWidth=1600, sheetContentHeight=200 }
        local sheet1 = graphics.newImageSheet( "immagini/livello-1/spritewalk2.png", sheetData1 )
        
        -- 2nd image sheet
        local sheetData2 = { width=200, height=200, numFrames=7, sheetContentWidth=1400, sheetContentHeight=200 }
        local sheet2 = graphics.newImageSheet( "immagini/livello-1/spritejump.png", sheetData2 )
        
        -- In your sequences, add the parameter 'sheet=', referencing which image sheet the sequence should use
        local sequenceData = {
                        { name="seq1", sheet=sheet1, start=1, count=6, time=500, loopCount=0 },
                        { name="seq2", sheet=sheet2, start=1, count=1, time=500, loopCount=0 }
                        }
        
        local myAnimation = display.newSprite( sheet1, sequenceData )
        myAnimation.x = display.contentWidth/2 ; myAnimation.y = display.contentHeight/2
        myAnimation:play()
        
        -- After a short time, swap the sequence to 'seq2' which uses the second image sheet
        local function running()
                myAnimation:setSequence( "seq1" )
                myAnimation:play()
        end
        local function jump()
            myAnimation:setSequence( "seq2" )
            myAnimation:play()
        end
        
        physics.addBody(myAnimation)
        timer.performWithDelay( 2000, running ) 
        Runtime:addEventListener( "enterFrame", move )
        Runtime:addEventListener( "touch", jump )
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