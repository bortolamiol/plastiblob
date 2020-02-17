local composer = require( "composer" )
 
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
 local gameLoop --timer per le animazioni del gioco
 local life
 local totalLife
 local timerBullet --timer per richiamare l'attacco del nemico
 local table_bullets = {}
 
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
        local stop = 0
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
        
         --PROIETTILE
         local bulletSheetData = { width=160, height=160, numFrames=4, sheetContentWidth=640, sheetContentHeight=160 }
         local bulletSheet = graphics.newImageSheet( "immagini/livello-1/plastic-bottle.png", bulletSheetData )
         local bulletData = {
           { name="plastic-bottle", sheet=plasticbagSheet, start=1, count=4, time=400, loopCount=0 }
        }
        --ESPLOSIONE QUANDO SI COLPISCE IL NEMICO CON IL PROIETTILE
        local explosionSheetData = { width=200, height=200, numFrames=12, sheetContentWidth=2400, sheetContentHeight=200 }
        local explosionSheet = graphics.newImageSheet( "immagini/livello-1/explosion1.png", explosionSheetData )
        local explosionData = {
            { name="explosion", sheet=explosionSheet, start=1, count=12, time=800, loopCount=1}
        }
        local function loop( event )
            --qui dentro metteremo tutte le cose che necessitano di un loop all'interno del gioco
            --richiamo le due funzioni per muovere lo sfondo
            sprite:play()
            enemy:play()
        end
          ------------------------------------------------
        
      -- FUNZIONI PER IL PROIETTILE 'LATTINA DI PLASTICA'
      local function bulletScroll(self, event)
        print("ooo")
        --fa scorrere il sacchetto nello schermo
        if stop == 0 then
          self.x = self.x -  10 --fa andare  avanti il proiettile in x senza spostarsi in y
          print(self.x)
          if self.x > display.actualContentWidth - 30 then --se c'è un sacchetto di plastica che ha superato il limite di -200, lo togliamo!
            self:removeEventListener( "collision", onBulletCollision ) --rimuovo l'ascoltatore per la collisione di quel sprite
            Runtime:removeEventListener("enterFrame",self) --rimuovo l'ascoltatore che lo fa scrollare 
            group_elements:remove(self)
            display.remove(self) --rimuove QUEL sacchetto di plastica dal display display
            local res = table.remove(table_bullets, table.indexOf( table_bullets, self )) --lo rimuove anche dalla tabella dei proeittili
          end
        end
      end
      ------------------------------------------------
      -- Global collision handling
      function onBulletCollision( event )
        print(event.other.name)
        --[[if(tostring(event.other.name) == "enemy") then --se il proiettile si è scontrato contro un nemico allora..
          enemyKilled = event.other --salvo dentro enemyKilled l'indirizzo che mi porta al nemico ucciso
          --Riproduco l'animazione dell'esplosione nelle stesse coordinate in cui si trova il nemico nel momento della collisione
          local explosion = display.newSprite( explosionSheet, explosionData ) --salvo dentro explosion l'animazione dell'esplosione
          explosion.name = "explosion"
          group_elements:insert(explosion)
          explosion.x = enemyKilled.x
          explosion.y = enemyKilled.y
          explosion:play()

          --rimuovo il nemico dallo schermo
          Runtime:removeEventListener("enterFrame", enemyKilled) --non faccio più muovere il nemico
          display.remove(enemyKilled) --rimuovo dal display il nemico
          local position = table.indexOf(enemies, enemyKilled) --carico dentro la variabile position la posizione del nemico colpito dentro la tabella dei nemici 
          table.remove(enemies,position) --rimuovo dalla tabella enemies il nemico colpito

          --rimuovo la bottiglia appena lanciata
          group_elements:remove(event.target)
          event.target:removeEventListener( "collision", onBulletCollision ) --rimuovo l'ascoltatore per la collisione di quel sprite
          Runtime:removeEventListener("enterFrame",event.target) --rimuovo l'ascoltatore che lo fa scrollare 
          display.remove(event.target) --rimuove QUELLA bottiglia di plastica dal display 
          local res = table.remove(table_bullets, table.indexOf( table_bullets, event.target )) --lo rimuove anche dalla tabella dei proeittili
          end
          ]]--
      end
      ---------------------------------------------------
      local function createBullet()
        --crea un oggetto di un nuovo sprite del sacchetto e lo aggiunge alla tabella table_plasticbag[]
        --da implementare meglio, mi faccio passare che tipo di nemico devo inserire
        local bullet = display.newSprite( bulletSheet, bulletData )
        bullet.name = "bullet"
        bullet:play()
        group_elements:insert(bullet)
        bullet.x = enemy.x - 190
        bullet.y = sprite.y
        local outlineBullet = graphics.newOutline(6, bulletSheet, 2)
        physics.addBody(bullet, { outline=outlineBullet, density=1, bounce=0, friction=1})
        bullet.isBullet = true
        bullet.isSensor = true
        bullet.bodyType = "static"
        return bullet
      end
      ------------------------------------------------
      local function bulletsLoop()
        bullet = createBullet() --creo un'istanza di un oggetto sprite plastic bag         
        table.insert(table_bullets, bullet)
        bullet:addEventListener( "collision", onBulletCollision )
        bullet.enterFrame = bulletScroll --lo faccio scrollare, grazie alla funzione plasticbagScroll
        Runtime:addEventListener("enterFrame", bullet) --assegno all'evento enterframe lo scroll
      end
        gameLoop = timer.performWithDelay( 500, loop, 0 )
        timerBullet = timer.performWithDelay( 2000, bulletsLoop, 0 )
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