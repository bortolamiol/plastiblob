local composer = require( "composer" )
 
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
 local gameLoop
 local life
 local totalLife
 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
    group_background = display.newGroup() --group_background conterrà la foto di sfondo che scrollerà
    group_elements = display.newGroup() --group_elements conterrà tutti gli altri elementi dello schermo: sprite del personaggio, nemici e bottoni per uscire dal gioco
    sceneGroup:insert( group_background ) --inserisco il gruppo group_background dentro la scena
    sceneGroup:insert( group_elements ) --inserisco il gruppo group_elements dentro la scena
    local _w = display.actualContentWidth  -- Width of screen
    local _h = display.actualContentHeight  -- Height of screen
    local _x = 0  -- Horizontal centre of screen
    local _y = 0  -- Vertical centre of screen
    local bg = display.newImageRect("immagini/livello-3/background.png", _w, _h)
    bg.anchorY = 0
    bg.anchorX = 0
    bg.x = 0
    bg.y = _y
    group_background:insert(bg)

    --richiedo la libreria necessaria per inserire la fisica all'interno del livello
    local physics = require("physics")
    physics.start()
    -- Overlays collision outlines on normal display objects
    physics.setGravity( 0,41 )
    physics.setDrawMode( "hybrid" )
    -- The default Corona renderer, with no collision outlines
    --physics.setDrawMode( "normal" )
    -- Shows collision engine outlines only
    --physics.setDrawMode( "debug" )

end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        --VARIABILI PER GLI ELEMENTI DELLO SCHERMO{
        local groundHeight = 100
        local ground = display.newRect( 0, 0,99999, groundHeight )
        ground:setFillColor(0,0,0,0)
        ground.name = "ground"
        group_elements:insert(ground)
        ground.x = display.contentCenterX
        ground.y = display.contentHeight- groundHeight/2
        physics.addBody(ground, "static",{bounce=0, friction=1 } )

        --PERSONAGGIO DEL GIOCO
        local spriteWalkingSheetData =
        {
            width=160,
            height=160,
            numFrames=8,
            sheetContentWidth=1280,
            sheetContentHeight=160
        }

        local spriteWalkingSheet = graphics.newImageSheet( "immagini/livello-1/spritewalking.png", spriteWalkingSheetData )
        -- primo sprite per il personaggio che salta
        local spriteJumpingSheetData =
        {
            width=160,
            height=160,
            numFrames=8,
            sheetContentWidth=1280,
            sheetContentHeight=160
        }

        local spriteJumpingSheet = graphics.newImageSheet( "immagini/livello-1/spritejump.png", spriteJumpingSheetData )
        -- In your sequences, add the parameter 'sheet=', referencing which image sheet the sequence should use
        local spriteData = {
            { name="walking", sheet=spriteWalkingSheet, start=1, count=8, time=800, loopCount=0 },
            { name="jumping", sheet=spriteJumpingSheet, start=1, count=8, time=800, loopCount=0 }
        }
        --metto assieme tutti i dettagli dello sprite, elencati in precedenza
        sprite = display.newSprite( spriteWalkingSheet, spriteData )
        sprite.name = "sprite"
        group_elements:insert(sprite)
        sprite.x = (display.contentWidth/2)-390	
        sprite.y = ground.y - 100
        local frameIndex = 1
        local outlineSpriteWalking = graphics.newOutline(2, spriteWalkingSheet, frameIndex)   --outline personaggio
        local outlineSpriteJumping = graphics.newOutline(2, spriteJumpingSheet, 4)   --outline personaggio
        physics.addBody(sprite, { outline=outlineSpriteWalking, density=4, bounce=0, friction=1}) --sprite diventa corpo con fisica
        sprite.gravityScale = 3
        sprite.isFixedRotation = true --rotazione bloccata
        sprite.isJumping = false

        --Mostro nemico
        local enemyWalkingSheetData = { width=600, height=600, numFrames=9, sheetContentWidth=5400, sheetContentHeight=3600 }
        local enemyWalkingSheet = graphics.newImageSheet( "immagini/final/monster.png", enemyWalkingSheetData )
        local enemyData = {
            { name="walking", sheet=enemyWalkingSheet, start=1, count=9, time=800, loopCount=0 }
        }
        local enemy = display.newSprite( enemyWalkingSheet, enemyData )
        enemy.name = "enemy"
        enemy:play()
        group_elements:insert(enemy)
        enemy.x = display.actualContentWidth  - 200
        enemy.y = ground.y-150
        local outlineNemico = graphics.newOutline(5, enemyWalkingSheet, 4)
        physics.addBody(enemy, { outline=outlineNemico, density=5, bounce=0, friction=1})
        enemy.bodyType = "dynamic"
        enemy.isFixedRotation = true
        enemy.gravityScale = 5

        --vita del nemico

        totalLife = display.newRect( (display.actualContentWidth - 80), 50, 400, 30 ) --rettangolo rosso che indica quanta vita a perso il boss
        totalLife:setFillColor(255, 0, 0  )
        totalLife.anchorX = (display.actualContentWidth - 150)
        group_elements:insert(totalLife)

        life = display.newRect( (display.actualContentWidth - 80), 50, 50 , 30 ) --diminuendo il terzo fattore diminuisce la vita
        life:setFillColor( 255 )
        life.anchorX = (display.actualContentWidth - 150)
        group_elements:insert(life)
        
        local function loop( event )
            --qui dentro metteremo tutte le cose che necessitano di un loop all'interno del gioco
            --richiamo le due funzioni per muovere lo sfondo
            sprite:play()
            enemy:play()
        end
          ------------------------------------------------

        gameLoop = timer.performWithDelay( 500, loop, 0 )
    end
end
 
 
-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
 
    end
end
 
 
-- destroy()
function scene:destroy( event )
 
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
 
end
 
 
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
 
return scene