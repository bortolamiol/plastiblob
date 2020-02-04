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
    physics.setDrawMode( "hybrid" )
    -- The default Corona renderer, with no collision outlines
    --physics.setDrawMode( "normal" )
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
        -- INIZIALIZZO LE VARIABILI CHE VERRANNO USATE NEL GIOCO

        -- VARIABILI PER LO SFONDO DI BACKGROUND {
            local _w = display.actualContentWidth  -- Width of screen
            local _h = display.actualContentHeight  -- Height of screen
            local _x = 0  -- Horizontal centre of screen
            local _y = 0  -- Vertical centre of screen
            local speed = 20 --questa sarà la velocità dello scorrimento del nostro sfondo, in base a questa velocità alzeremo anche quella del gioco

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
        --}

        --VARIABILI PER LO SPRITE DEL PERSONAGGIO { 
        -- primo sprite per il personaggio che corre
        local sheetData1 = { width=200, height=200, numFrames=8, sheetContentWidth=1600, sheetContentHeight=200 }
        local sheet1 = graphics.newImageSheet( "immagini/livello-1/spritewalk2.png", sheetData1 )
        
        -- primo sprite per il personaggio che salto
        local sheetData2 = { width=200, height=200, numFrames=7, sheetContentWidth=1400, sheetContentHeight=200 }
        local sheet2 = graphics.newImageSheet( "immagini/livello-1/spritejump.png", sheetData2 )
        
        -- In your sequences, add the parameter 'sheet=', referencing which image sheet the sequence should use
        local sequenceData = {
            { name="walking", sheet=sheet1, start=1, count=6, time=500, loopCount=0 },
            { name="seq2", sheet=sheet2, start=1, count=1, time=500, loopCount=0 }
        }
        --}
        
        
        local myAnimation = display.newSprite( sheet1, sequenceData )
        myAnimation.x = display.contentWidth/2 ; myAnimation.y = display.contentHeight/2
        myAnimation:play()
           
         --FUNZIONI {
        
        --questa funzione muove il background di sfondo
        function move(self)
            if 	self.x<-(display.contentWidth-speed*2) then
                self.x = display.contentWidth
            else
                self.x =self.x - speed
            end	
        end

        --questa funzione sceglie la sequenza per far correre il nostro personaggio
        local function running()
            myAnimation:setSequence( "walking" )
            myAnimation:play()
        end
        -- 
        local function loop( event )
            --qui dentro metteremo tutte le cose che necessitano di un loop all'interno del gioco
            --richiamo le due funzioni per muovere lo sfondo
            move(bg[1])
            move(bg[2])
        end
        -- }
        local gameLoop = timer.performWithDelay( 30, loop, 0 )
        --PARTE FINALE: richiamo le funzioni e aggiungo gli elementi allo schermo e ai gruppi
        physics.addBody(myAnimation)
        timer.performWithDelay( 2000, running ) 
        --local timer1 = timer.performWithDelay(200,move(bg[1]),0)
        --local timer2 = timer.performWithDelay(200,move(bg[2]),0)
        --Runtime:addEventListener( "enterFrame", move )
        --bg[1].touch = move
        --touch:addEventListener("enterFrame",bg[1])
        --bg[2].enterFrame = move
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