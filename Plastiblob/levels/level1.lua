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
    local groundHeight = 100
    local ground = display.newRect( 0, 0,99999, groundHeight )
    sceneGroup:insert(ground)
    ground.x = display.contentCenterX
    ground.y = display.contentHeight- groundHeight/2
    composer.setVariable( "posY_ground", ground.y )
    physics.addBody(ground, "static",{bounce=0, friction=1 } )

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
            
            local bg={} -- 'vettore' che conterrà i due sfondi del gioco
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

            local enemies = {} --vettore che conterrà i nemici che inserirò dentro il gioco

            ------------------------------------------------------------
            -- VARIABILI MOLTO IMPORTANTI PER IL GIOCO: VELOCITA' DI GIOCO
            local frame_speed = 10 --questa sarà la velocità dello scorrimento del nostro sfondo, in base a questa velocità alzeremo anche quella del gioco
            local time_speed = 30 -- ogni quanti millisecondi verranno chiamate le funzioni di loop (esempio di sfondo background)
            ------------------------------------------------------------
        --}

        --VARIABILI PER GLI SPRITE { 

        --PERSONAGGIO DEL GIOCO
        local spriteWalkingSheetData = { width=200, height=200, numFrames=8, sheetContentWidth=1600, sheetContentHeight=200 }
        local spriteWalkingSheet = graphics.newImageSheet( "immagini/livello-1/spritewalking.png", spriteWalkingSheetData )
        -- primo sprite per il personaggio che salta
        local spriteJumpingSheet = { width=200, height=200, numFrames=7, sheetContentWidth=1400, sheetContentHeight=200 }
        local spriteJumpingSheet = graphics.newImageSheet( "immagini/livello-1/spritejump.png", spriteJumpingSheet )
        -- In your sequences, add the parameter 'sheet=', referencing which image sheet the sequence should use
        local spriteData = {
            { name="walking", sheet=spriteWalkingSheet, start=1, count=8, time=500, loopCount=0 },
            { name="jumping", sheet=spriteJumpingSheet, start=1, count=7, time=500, loopCount=0 }
        }
        --metto assieme tutti i dettagli dello sprite, elencati in precedenza
        local sprite = display.newSprite( spriteWalkingSheet, spriteData )
        local posY_sprite = composer.getVariable( "posY_ground" )
        sprite.x = display.contentWidth/2-300 ; sprite.y = posY_sprite-100
        local outlinePersonaggio = graphics.newOutline(20, spriteWalkingSheet)
        physics.addBody(sprite, { outline=outlinePersonaggio, density=10, bounce=0, friction=1})

        sprite.isJumping = false
        --^_^----^_^----^_^----^_^----^_^----^_^----^_^----^_^----^_^----^_^----^_^----^_^----^_^----^_^----^_^----^_^----^_^----^_^--
        
        -- PRIMO NEMICO
        local enemyWalkingSheetData = { width=200, height=200, numFrames=6, sheetContentWidth=1200, sheetContentHeight=200 }
        local enemyWalkingSheet = graphics.newImageSheet( "immagini/livello-1/zombiewalking.png", enemyWalkingSheetData )
        local enemyData = {
            { name="walking", sheet=enemyWalkingSheet, start=1, count=6, time=500, loopCount=0 }
        }
        --enemy.x = display.contentWidth + 200 ; sprite.y = posY_sprite
        local enemyTimeSpawn = math.random(1000,15000);

        --}
        

           
        --FUNZIONI {
        
        local function moveBackground(self)
            --questa funzione muove il background di sfondo
            if 	self.x<-(display.contentWidth-frame_speed*2) then
                self.x = display.contentWidth
            else
                self.x =self.x - frame_speed
            end	
        end
        ------------------------------------------------
        local function createEnemies()
            --crea un oggetto di un nuovo sprite nemico e lo aggiunge alla tabella enemies[]
            --da implementare meglio, mi faccio passare che tipo di nemico devo inserire
            local enemy = display.newSprite( enemyWalkingSheet, enemyData )
            enemy.x = display.actualContentWidth + 200
            enemy.y = composer.getVariable( "posY_ground" )
            print(enemy.y)
            local outlineNemico = graphics.newOutline(20, enemyWalkingSheet)
            physics.addBody(enemy, { outline=outlineNemico, density=1, bounce=0.3, friction=0.1 })
            table.insert(enemies, enemy)
            return enemy
        end
        ------------------------------------------------
        local function enemyScroll(self, event)
            --fa scorrere il nemico nello schermo
            self.x = self.x - frame_speed*0.45
        end
        ------------------------------------------------
        local function loop( event )
            --qui dentro metteremo tutte le cose che necessitano di un loop all'interno del gioco
            --richiamo le due funzioni per muovere lo sfondo
            moveBackground(bg[1])
            moveBackground(bg[2])
            sprite:play()
        end
        ------------------------------------------------
        local function enemiesLoop()
            local enemy = createEnemies()
            enemy.enterFrame = enemyScroll
            Runtime:addEventListener("enterFrame",enemy)
            for i,thisEnemy in ipairs(enemies) do
                if thisEnemy.x < -200 then
                    Runtime:removeEventListener("enterFrame",thisEnemy)
                    display.remove(thisEnemy)
                    print("cancellato")
                    table.remove(enemies,i)
                end
            end
        end
        ------------------------------------------------
       
        --funzione che capisce se c'è collisione
        function sprite.collision( self, event )
            if( event.phase == "began" and self.isJumping ) then		
                self.isJumping = false
                self:setSequence("walking")
                self:play()
                print("Landed @ ", system.getTimer())
                print("------------------------\n")
            end
        end
        sprite:addEventListener("collision")
        
        ------------------------------------------------
       
        function sprite.touch( self,event)
            if( event.phase == "began" and not self.isJumping ) then
                self:setLinearVelocity(60,-400)
                self.isJumping = true
                self:setSequence("jumping")
                self:play()
                print("Jumped @ ", system.getTimer())
            end
        end
        Runtime:addEventListener( "touch", sprite )

        ------------------------------------------------
        local function touchListener()
        --funzione che capirà quale evento scatenare al click sullo schermo
           -- if
        end
    
        -- }
        local deletedata = display.newImageRect( "immagini/menu/x.png", 80, 80 )
        deletedata.anchorX =  0
        deletedata.anchorY =  0
        deletedata.x = display.actualContentWidth - 100
        deletedata.y = display.actualContentHeight - 100

        local gameLoop = timer.performWithDelay( time_speed, loop, 0 )
        local callingEnemies = timer.performWithDelay( enemyTimeSpawn, enemiesLoop, 0 )
        --PARTE FINALE: richiamo le funzioni e aggiungo gli elementi allo schermo e ai gruppi
        sceneGroup:insert(deletedata)
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