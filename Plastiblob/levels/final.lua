local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local gameLoop --timer per le animazioni del gioco
local life
local totalLifeRect
local timerBullet --timer per richiamare l'attacco del nemico
local table_bullets = {}
local table_enemy_bullets = {}
local enemyLife = 400

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
  local bg = display.newImageRect("immagini/final/background.png", _w, _h)
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
    local options = {
      effect = "fade",
      time = 1000,
      params = { level="final"} --opzioni che mi serviranno per tornare dal game over
    }

    local secondsPlayed = 0 -- conteggio dei secondi in cui sono all'interno del gioco, più secondi passo più è difficile
    enemySpeed = 12 --velocità iniziale di scorrimento dei proiettili del nemico
    local enemySpeed_min = 12 --velocità iniziale di scorrimento dei proiettili del nemico
    local enemySpeed_max = 18 --velocità massima di scorrimento dei proiettili del nemico
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
    local enemyWalkingSheetData = { width=600, height=600, numFrames=4, sheetContentWidth=2400, sheetContentHeight=600 }
    local enemyWalkingSheet = graphics.newImageSheet( "immagini/final/monster.png", enemyWalkingSheetData )
    local enemyData = {
      { name="walking", sheet=enemyWalkingSheet, start=1, count=4, time=700, loopCount=0 }
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
    --questi due rettangoli sono uno sopra l'altro, uno bianco e uno rosso: uno indica la vita totale che ha il nemico (rosso) e il bianco indica la vita che ha dopo che lo si colpisce
    totalLifeRect = display.newRect( (display.actualContentWidth - 80), 50, 400, 30 ) --rettangolo rosso che indica quanta vita a perso il boss
    totalLifeRect:setFillColor(255, 0, 0  )
    totalLifeRect.anchorX = (display.actualContentWidth - 150)
    group_elements:insert(totalLifeRect)

    life = display.newRect( (display.actualContentWidth - 80), 50, enemyLife , 30 ) --diminuendo il terzo fattore diminuisce la vita
    life:setFillColor( 255 )
    life.anchorX = (display.actualContentWidth - 150)
    group_elements:insert(life)

    --PROIETTILE NEMICO
    local enemyBulletSheetData = { width=160, height=160, numFrames=6, sheetContentWidth=960, sheetContentHeight=160 }
    local enemyBulletSheet = graphics.newImageSheet( "immagini/final/proiettile.png", enemyBulletSheetData )
    local enemyBulletData = {
      { name="plastic-bottle", sheet=enemyBulletSheet, start=1, count=6, time=400, loopCount=0 }
    }

    --IL NOSTRO PROIETTILE
    local bulletSheetData = { width=100, height=100, numFrames=3, sheetContentWidth=300, sheetContentHeight=100 }
    local bulletSheet = graphics.newImageSheet( "immagini/final/ecoproiettile.png", bulletSheetData )
    local bulletData = {
        { name="ecoproiettile", sheet=bulletSheet, start=1, count=3, time=400, loopCount=0 }
      }



    --------------------------------------------------------------------------
    --------------------------------------------------------------------------
    ----------------------          FUNZIONI         -------------------------
    --------------------------------------------------------------------------
    --------------------------------------------------------------------------
    local function loop( event )
      --faccio muovere i miei due sprite dell gioco
      sprite:play()
      enemy:play()
    end
    --------------------------------------------------------------------------
    --funzione che capisce se c'è collisione con un elemento
    function sprite.collision( self, event ) --se tocco terra imposto che posso saltare ancora
      if( event.phase == "began" ) then
        if(event.other.name == "ground") then --tocco terra
            sprite.isJumping = false --non sto più saltando
            sprite:setSequence("walking")	
        end
      end
    end
    sprite:addEventListener("collision")
    --------------------------------------------------------------------------

    function gameOver() --quando entro qui devo mandare alla scena del gameover e resettare la scena
      stop = 1 -- grazie a questo le animazioni personagggi non scrolleranno più
      audio.pause(crunchSound)
      audio.setMaxVolume(0.03)
      local audiogameover = audio.loadSound("MUSIC/PERDENTE.mp3")
      audio.play(audiogameover)
      composer.gotoScene( "levels.gameover", options )
    end
    --------------------------------------------------------------------------

    function win() --quando entro qui devo mandare alla scena del gameover e resettare la scena
      stop = 1 -- grazie a questo le animazioni personagggi non scrolleranno più
      composer.gotoScene( "levels.victory", options )
    end
    --------------------------------------------------------------------------
    -- Global collision handling
    function onEnemyBulletCollision( event ) --funzione che controlla se il proiettile nemico tocca il nostro sprite
      if(event.other.name == "sprite") then
        --ci ha presi
        gameOver()
      end
    end

    --------------------------------------------------------------------------
    local function enemyBulletScroll(self, event) --funzione che fa scrollare il proiettile nemico
      --fa scorrere il sacchetto nello schermo
      if stop == 0 then
        self.x = self.x - enemySpeed --fa andare  avanti il proiettile in x senza spostarsi in y
        if self.x > display.actualContentWidth - 30 then --se c'è un sacchetto di plastica che ha superato il limite di -200, lo togliamo!
          self:removeEventListener( "collision", onBulletCollision ) --rimuovo l'ascoltatore per la collisione di quel sprite
          Runtime:removeEventListener("enterFrame",self) --rimuovo l'ascoltatore che lo fa scrollare
          group_elements:remove(self)
          display.remove(self) --rimuove QUEL sacchetto di plastica dal display display
          local res = table.remove(table_enemy_bullets, table.indexOf( table_enemy_bullets, self )) --lo rimuove anche dalla tabella dei proeittili
        end
      end
    end
    ---------------------------------------------------
    local function createEnemyBullet()
      --crea un oggetto di un nuovo sprite del sacchetto e lo aggiunge alla tabella table_plasticbag[]
      --da implementare meglio, mi faccio passare che tipo di nemico devo inserire
      local enemybullet = display.newSprite( enemyBulletSheet, enemyBulletData )
      enemybullet.name = "bullet"
      enemybullet:play()
      group_elements:insert(enemybullet)
      enemybullet.x = enemy.x - 190
      enemybullet.y = math.random( 400, 600)
      local outlineBullet = graphics.newOutline(6, enemyBulletSheet, 2)
      physics.addBody(enemybullet, { outline=outlineBullet, density=1, bounce=0, friction=1})
      enemybullet.isBullet = true
      enemybullet.isSensor = true
      enemybullet.bodyType = "kinematic"
      return enemybullet
    end
    ------------------------------------------------
    local function enemyBulletsLoop()
      if(stop == 0) then --se il gioco non è finito allora continuo a creare
        Enemybullet = createEnemyBullet() --creo un'istanza di un oggetto sprite plastic bag
        table.insert(table_enemy_bullets, Enemybullet)
        Enemybullet:addEventListener( "collision", onEnemyBulletCollision )
        Enemybullet.enterFrame = enemyBulletScroll --lo faccio scrollare, grazie alla funzione plasticbagScroll
        Runtime:addEventListener("enterFrame", Enemybullet) --assegno all'evento enterframe lo scroll
      end
    end
    -------------------------------------------------
    -- FUNZIONI PER IL PROIETTILE 'LATTINA DI PLASTICA'
    local function bulletScroll(self, event)
      --fa scorrere il sacchetto nello schermo
      if stop == 0 then
        self.x = self.x + 10 --fa andare  avanti il proiettile in x senza spostarsi in y
        if self.x > display.actualContentWidth + 30 then --se c'è un sacchetto di plastica che ha superato il limite di -200, lo togliamo!
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
      if(tostring(event.other.name) == "enemy") then
        enemyLife = enemyLife - 4
        life.width = enemyLife
        group_elements:remove(event.target)
        event.target:removeEventListener( "collision", onBulletCollision ) --rimuovo l'ascoltatore per la collisione di quel sprite
        Runtime:removeEventListener("enterFrame",event.target) --rimuovo l'ascoltatore che lo fa scrollare
        display.remove(event.target) --rimuove QUELLA bottiglia di plastica dal display
        local res = table.remove(table_bullets, table.indexOf( table_bullets, event.target )) --lo rimuove anche dalla tabella dei proeittili
        if(enemyLife <= 0) then
          win()
        end
      end
    end
    ---------------------------------------------------
    local function createBullet()
      --crea un oggetto di un nuovo sprite del sacchetto e lo aggiunge alla tabella table_plasticbag[]
      --da implementare meglio, mi faccio passare che tipo di nemico devo inserire
      local bullet = display.newSprite( bulletSheet, bulletData )
      bullet.name = "bullet"
      bullet:play()
      group_elements:insert(bullet)
      bullet.x = sprite.x + 80
      bullet.y = sprite.y
      local outlineBullet = graphics.newOutline(6, bulletSheet, 2)
      physics.addBody(bullet, { outline=outlineBullet, density=1, bounce=0, friction=1})
      bullet.isBullet = true
      bullet.isSensor = true
      bullet.bodyType = "kinematic"
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

    --------------------------------------------------------------------------
    function touchListener(event) --ascoltatore del touch su schermo
      if ( event.phase == "began" ) then --è finito il processo di touch dello sschermo
        if ((event.x >= 0 ) and (event.x <= display.actualContentWidth/2) and (not sprite.isJumping) )then
          sprite:setLinearVelocity(0,- 1650)
          sprite.isJumping = true -- se ho toccato imposto la variabile isJumping del mio personaggio a true
          sprite:setSequence("jumping") --lo sprite si muove con animazione jumping
          sprite:play()
        elseif (event.x > display.actualContentWidth / 2) and (event.x <= display.contentWidth) then
          --ho cliccato sulla parte destra dello shcermo, devo sparare
          bulletsLoop()
        end
      end
    end
    Runtime:addEventListener( "touch", touchListener )


    --------------------------------------------------------------------------
    --funzione che serve per aumentare la velocità del gioco
    local function increaseGameSpeed(event)
      if(secondsPlayed <= 16) then
        secondsPlayed = secondsPlayed + 1 --ogni secondo che passa aumento questa variabile che tiene conto di quanto tempo è passato
        local x_enemySpeed = ((enemySpeed_max * secondsPlayed)/40)
        enemySpeed = enemySpeed_min + x_enemySpeed --la velocità è data dalla velocità minima (2) + il risultato della proporzione
        timerBullet._delay = timerBullet._delay - secondsPlayed * 3
      end
    end

    gameLoop = timer.performWithDelay( 500, loop, 0 ) --richiamo le animazioni di gioco ogni 500 millisecondi
    timeplayed = timer.performWithDelay( 1000, increaseGameSpeed, 0 ) --funzione che serve per aumentare la velocità di gioco ogni secondo
    timerBullet = timer.performWithDelay( 1500, enemyBulletsLoop, 0 ) --richiamo lo sparo del nemico
  end
end


-- hide()
function scene:hide( event )

  local sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then
    -- Code here runs when the scene is on screen (but is about to go off screen)
    physics.pause()
    timer.cancel(gameLoop)
    timer.cancel(timeplayed)
    timer.cancel(timerBullet)

    --ELIMINO I LISTENERS
    sprite:removeEventListener("collision")
    Runtime:removeEventListener( "touch", touchListener )

    for i=1, #table_bullets do 
      Runtime:removeEventListener("enterFrame",  table_bullets[i])
      table_bullets[i]:removeEventListener( "collision", onBulletCollision )
      table_bullets[i]:removeSelf() -- Optional Display Object Removal
      table_bullets[i] = nil        -- Nil Out Table Instance
    end

    for i=1, #table_enemy_bullets do 
      Runtime:removeEventListener("enterFrame",  table_enemy_bullets[i])
      table_enemy_bullets[i]:removeEventListener( "collision", onEnemyBulletCollision )
      table_enemy_bullets[i]:removeSelf() -- Optional Display Object Removal
      table_enemy_bullets[i] = nil        -- Nil Out Table Instance
    end

  elseif ( phase == "did" ) then
    -- Code here runs immediately after the scene goes entirely off screen
    composer.removeScene("levels.final")
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