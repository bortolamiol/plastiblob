local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local gameLoop --variabile che conterrà il timer per il loop del gioco: mette in loop le animazioni del personaggio e nemico
local lifeRect --rettangolo Rosso che avrà larghezza 400 e ha il compito di segnare la vita totale del nemico
local totalLifeRect --rettangolo che segnerà la vita del nemico
local timerBullet --timer per richiamare l'attacco del nemico
local table_bullets = {} --tabella per contenere al suo interno i vari proiettili sparati dal nostro personaggio
local table_enemy_bullets = {} --tabella per contenere al suo interno i vari proiettili sparati dal nemico
local enemyLife = 400 --variabile che conterrà la vita del nemico (numero che andrà da 400 a 0)
local enemySpeed --velocità di scorrimento dei proiettili dei nemici
local table_loop
local musicFinal

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

  local sceneGroup = self.view
  musicFinal = audio.loadStream("MUSIC/finalBoss.mp3") --carico la musica finalBoss
  -- Code here runs when the scene is first created but has not yet appeared on screen
  group_background = display.newGroup() --group_background conterrà la foto di sfondo
  group_elements = display.newGroup() --group_elements conterrà tutti gli altri elementi dello schermo: sprite del personaggio, nemici e bottoni per uscire dal gioco
  sceneGroup:insert( group_background ) --inserisco il gruppo group_background dentro la scena
  sceneGroup:insert( group_elements ) --inserisco il gruppo group_elements dentro la scena
  local _y = 0  -- Vertical centre of screen
  local bg = display.newImageRect("immagini/livello-5/background.png", display.actualContentWidth, display.actualContentHeight ) --inserisco la foto di sfondo
  bg.anchorY = 0
  bg.anchorX = 0
  bg.x = 0
  bg.y = 0
  group_background:insert(bg)

  --richiedo la libreria necessaria per inserire la fisica all'interno del livello
  local physics = require("physics")
  physics.start()
  -- Overlays collision outlines on normal display objects
  physics.setGravity( 0,41 )
  --physics.setDrawMode( "hybrid" )
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
    audio.play( musicFinal, { channel=3, loops=-1 } ) --parte la musica del boss finale
    
    -- Questa tabella OPTIONS la passerò alla schermata di GameOver quando morirò, la schermata di GameOver prenderà in pasto questi parametri e grazie alla variabile 'level' saprà a che livello tornare (ovvero il livello che ha chiamato tale schermata di GameOver)
    local options = { 
      effect = "fade",
      time = 1000,
      params = { level="final"} --opzioni che mi serviranno per tornare dal game over
    }

    local secondsPlayed = 0 -- variabile che conterrà il conteggio dei secondi in cui sono all'interno del gioco, più secondi saranno e più veloci andranno i proiettili sparati dal nemico
    local enemySpeed_min = 12 --velocità iniziale di scorrimento dei proiettili del nemico
    enemySpeed = enemySpeed_min --velocità di scorrimento dei proiettili del nemico, questa variabile andrà ad essere aumentata nel corso del gioco
    local enemySpeed_max = 18 --velocità massima di scorrimento dei proiettili del nemico
    local stop = 0 --variabile che farà andare o meno avanti le funzioni di loop, se è finito il gioco setterò questa variabile a 1 
    local groundHeight = 100 --altezza del suolo
    local ground = display.newRect( 0, 0, 99999, groundHeight ) --disegno il suolo
    ground:setFillColor(0,0,0,0) --lo rendo trasparente
    ground.name = "ground" --do il nome al suolo, in modo da riuscire a capire in fase di collisione che sto toccando la terra
    group_elements:insert(ground) --aggiungo il suolo al gruppo degli elementi sopra il background
    ground.x = display.contentCenterX
    ground.y = display.contentHeight- groundHeight/2
    physics.addBody(ground, "static",{bounce=0, friction=1 } )

    -- SPRITE DEL PERSONAGGIO DEL GIOCO
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
    sprite.y = ground.y - 100 --posiziono il personaggio un po' più in alto del terreno
    local outlineSpriteWalking = graphics.newOutline(2, spriteWalkingSheet, 1)   --outline personaggio
    physics.addBody(sprite, { outline=outlineSpriteWalking, density=4, bounce=0, friction=1}) --sprite diventa corpo con fisica
    sprite.gravityScale = 3
    sprite.isFixedRotation = true --rotazione bloccata
    sprite.isJumping = false

    -- SPRITE DEL NOSTRO NEMICO CHE CAMMINA; IN QUESTO LIVELLO SI TRATTA DI UN SERPENTE
    local enemyWalkingSheetData = { width=600, height=600, numFrames=4, sheetContentWidth=2400, sheetContentHeight=600 }
    local enemyWalkingSheet = graphics.newImageSheet( "immagini/livello-5/monster.png", enemyWalkingSheetData )
    local enemyData = {
      { name="walking", sheet=enemyWalkingSheet, start=1, count=4, time=700, loopCount=0 }
    }
    local enemy = display.newSprite( enemyWalkingSheet, enemyData )
    enemy.name = "enemy" --il nostro nemico si chiama enemy
    enemy:play() --faccio partire l'animazione del nemico
    group_elements:insert(enemy) --aggiungo il nemico al gruppo degli elementi sopra il background
    enemy.x = display.actualContentWidth  - 200
    enemy.y = ground.y-150
    local outlineNemico = graphics.newOutline(5, enemyWalkingSheet, 4) --creo l'outline del nemico..
    physics.addBody(enemy, { outline=outlineNemico, density=5, bounce=0, friction=1}) --e gliela assegno
    enemy.bodyType = "dynamic"
    enemy.isFixedRotation = true
    enemy.gravityScale = 5

    --VITA DEL NEMICO
    --questi due rettangoli sono uno sopra l'altro, uno bianco e uno rosso: uno indica la vita totale che ha il nemico (rosso) e il bianco indica la vita che ha dopo che lo si colpisce
    totalLifeRect = display.newRect( (display.actualContentWidth - 80), 50, 400, 30 ) --rettangolo rosso che indica quanta vita a perso il boss
    totalLifeRect:setFillColor(255, 0, 0  ) --lo coloro di ROSSO
    totalLifeRect.anchorX = (display.actualContentWidth - 150)
    group_elements:insert(totalLifeRect) --inserisco questo rettangolo nel gruppo che prevale su tutti, verrà mostrato sopra di tutti

    lifeRect = display.newRect( (display.actualContentWidth - 80), 50, enemyLife , 30 ) --diminuendo il terzo fattore diminuisce la vita e farà vedere visivamente all'utente che il mostro ha tanta/poca vita
    lifeRect:setFillColor( 255 ) --lo coloro di BIANCO
    lifeRect.anchorX = (display.actualContentWidth - 150)
    group_elements:insert(lifeRect) --inserisco questo rettangolo nel gruppo che prevale su tutti, verrà mostrato sopra di tutti

    --PROIETTILE NEMICO
    local enemyBulletSheetData = { width=160, height=160, numFrames=6, sheetContentWidth=960, sheetContentHeight=160 }
    local enemyBulletSheet = graphics.newImageSheet( "immagini/livello-5/proiettile.png", enemyBulletSheetData )
    local enemyBulletData = {
      { name="plastic-bottle", sheet=enemyBulletSheet, start=1, count=6, time=400, loopCount=0 }
    }

    --IL NOSTRO PROIETTILE
    local bulletSheetData = { width=100, height=100, numFrames=3, sheetContentWidth=300, sheetContentHeight=100 }
    local bulletSheet = graphics.newImageSheet( "immagini/livello-5/ecoproiettile.png", bulletSheetData )
    local bulletData = {
        { name="ecoproiettile", sheet=bulletSheet, start=1, count=3, time=400, loopCount=0 }
      }



    --------------------------------------------------------------------------
    --------------------------------------------------------------------------
    ----------------------          FUNZIONI         -------------------------
    --------------------------------------------------------------------------
    --------------------------------------------------------------------------
    local function loop( event )
      --faccio muovere i miei due sprite del gioco
      sprite:play()
      enemy:play()
    end
    --------------------------------------------------------------------------
    --funzione che capisce se c'è collisione con un elemento
    function sprite.collision( self, event ) --se tocco terra imposto che posso saltare ancora
      if( event.phase == "began" ) then
        if(event.other.name == "ground") then --tocco terra
            sprite.isJumping = false --non sto più saltando
            sprite:setSequence("walking")	--lo sprite non sta più saltando ma camminerà, do quindi allo sprite l'animazione della camminata
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
      composer.gotoScene( "levels.gameover", options ) --vado alla scena del gameover passandogli la tabella Options per sapere dove tornare se si clicca 'retry'
    end
    --------------------------------------------------------------------------

    function win() --quando entro qui devo mandare alla scena del gameover e resettare la scena
      stop = 1 -- grazie a questo le animazioni personagggi non scrolleranno più
      local options = { 
        effect = "crossFade",
        time = 1000,
        params = {level= 6, imagetoshow = 4} --opzioni che mi serviranno per tornare dal game over
      }
      composer.gotoScene( "levels.storylevel", options ) --vado alla schermata di vittoria
    end
    --------------------------------------------------------------------------

    -- FUNZIONI PER IL PROIETTILE DEL NEMICO
    function onEnemyBulletCollision( event ) --funzione che controlla se il proiettile nemico tocca il nostro sprite
      if(event.other.name == "sprite") then
        --ci ha presi
        Runtime:removeEventListener( "touch", touchListener )
        gameOver() --richiamo la funzione di GameOver dove si resetteranno le scene e si andrà alla schermata di gameOver
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
    local function createEnemyBullet() --CREA UN NUOVO PROIETTILE NEMICO
      --crea un oggetto di un nuovo sprite del sacchetto e lo aggiunge alla tabella table_plasticbag[]
      --da implementare meglio, mi faccio passare che tipo di nemico devo inserire
      local enemybullet = display.newSprite( enemyBulletSheet, enemyBulletData ) --creo uno sprite del proiettile nemico
      enemybullet.name = "enemyBullet"
      enemybullet:play() --faccio partire l'animazione
      group_elements:insert(enemybullet) --aggiungo l'elemento a gruppo sopra il bg
      enemybullet.x = enemy.x - 190 --lo posiziono a partire dalla posizione x del nemico
      enemybullet.y = math.random( 400, 600) --la posizione y sarà random tra due fattori --> 400 e 600
      local outlineBullet = graphics.newOutline(6, enemyBulletSheet, 2)  --creo l'outline
      physics.addBody(enemybullet, { outline=outlineBullet, density=1, bounce=0, friction=1})
      enemybullet.isBullet = true 
      enemybullet.isSensor = true
      enemybullet.bodyType = "kinematic"
      return enemybullet --ritorno l'oggetto appena creato al chiamante
    end
    ------------------------------------------------
    local function enemyBulletsLoop() --RICHIAMA TUTTE LE FUNZIONI PER CREARE, SCROLLARE IL PROIETTILE NEMICO,  QUESTA FUNZIONE VIENE CHIAMTA IN LOOP DA UN TIMER CHE ANDREMO A DICHIARARE SOTTO
      if(stop == 0) then --se il gioco non è finito allora continuo a creare
        Enemybullet = createEnemyBullet() --creo un'istanza di un oggetto sprite plastic bag
        table.insert(table_enemy_bullets, Enemybullet) --inserisco tale oggetto all'interno della tabella che conterrà tutti i proiettili (tabella di oggetti)
        Enemybullet:addEventListener( "collision", onEnemyBulletCollision ) --richiamo il listeners per le collisioni
        Enemybullet.enterFrame = enemyBulletScroll --lo faccio scrollare, grazie alla funzione plasticbagScroll
        Runtime:addEventListener("enterFrame", Enemybullet) --assegno all'evento enterframe lo scroll
      end
    end
    -------------------------------------------------
    -- FUNZIONI PER IL PROIETTILE DEL NOSTRO PERSONAGGIO
    local function bulletScroll(self, event)
      --fa scorrere il sacchetto nello schermo
      if stop == 0 then --SE IL GIOCO NON E'  FINITO ALLORA..
        self.x = self.x + 10 --fa andare  avanti il proiettile in x senza spostarsi in y
        if self.x > display.actualContentWidth + 30 then --se c'è un proiettile che ha superato il limite di -200, lo togliamo!
          self:removeEventListener( "collision", onBulletCollision ) --rimuovo l'ascoltatore per la collisione di quel sprite
          Runtime:removeEventListener("enterFrame",self) --rimuovo l'ascoltatore che lo fa scrollare
          group_elements:remove(self) --rimuove dal gruppo l'elemento all'interno di questa funzione
          display.remove(self) --rimuove QUEL sacchetto di plastica dal display display
          local res = table.remove(table_bullets, table.indexOf( table_bullets, self )) --lo rimuove anche dalla tabella dei proeittili
        end
      end
    end
    ------------------------------------------------
    -- Global collision handling
    function onBulletCollision( event )
      if(tostring(event.other.name) == "enemy") then --un nostro proiettile ha colpito il nemico
        enemyLife = enemyLife - 4 --faccio perdere al nemico 4 punti vita
        lifeRect.width = enemyLife --aggiorno il rettangolo BIANCO della vita del nemico
        group_elements:remove(event.target) --rimuovo l'elemento proiettile che ha appena colpito il nemico
        event.target:removeEventListener( "collision", onBulletCollision ) --rimuovo l'ascoltatore per la collisione di quel sprite
        Runtime:removeEventListener("enterFrame",event.target) --rimuovo l'ascoltatore che lo fa scrollare
        display.remove(event.target) --rimuove QUELLA bottiglia di plastica dal display
        local res = table.remove(table_bullets, table.indexOf( table_bullets, event.target )) --lo rimuove anche dalla tabella dei proeittili
        if(enemyLife <= 0) then --se la vita del nemico è uguale o minore a ZERO allore...
          win() --ho vinto! richiamo la funzione win che andrà a chiamare la scena in cui dico all'utente che ha completato il gioco
        end
      end
    end
    ---------------------------------------------------
    local function createBullet() --creo un proiettile sparato dal nemcio
      local bullet = display.newSprite( bulletSheet, bulletData ) --richiamo lo sprite
      bullet.name = "bullet" --do il nome 'bullet' all'oggetto in modo da riconscerlo in fase di collisione
      bullet:play() --faccio partire l'animazione
      group_elements:insert(bullet) --inserisco l'elemento al gruppo sopra il bg
      bullet.x = sprite.x + 80 --x
      bullet.y = sprite.y -- y
      local outlineBullet = graphics.newOutline(6, bulletSheet, 2) --outline dello sprite
      physics.addBody(bullet, { outline=outlineBullet, density=1, bounce=0, friction=1})
      bullet.isBullet = true
      bullet.isSensor = true
      bullet.bodyType = "kinematic"
      return bullet
    end
    ------------------------------------------------
    local function bulletsLoop() -- funzione che verrà richiamata quando clicco sullo schermo per sparare
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
          sprite:setLinearVelocity(0,- 1650) --faccio saltare il nostro personaggio applicandoli una forza lineare di -1650
          sprite.isJumping = true -- se ho toccato imposto la variabile isJumping del mio personaggio a true
          sprite:setSequence("jumping") --lo sprite si muove con animazione jumping
          sprite:play()
        elseif (event.x > display.actualContentWidth / 2) and (event.x <= display.contentWidth) then
          --ho cliccato sulla parte destra dello shcermo, devo sparare
          bulletsLoop() --richiamo un proiettile
        end
      end
    end
    Runtime:addEventListener( "touch", touchListener )


    --------------------------------------------------------------------------
    --funzione che serve per aumentare la velocità del gioco
    local function increaseGameSpeed(event)
      if(secondsPlayed <= 16) then --fino ai 16 gioco aumento determinate variabili per rendere il gioco più complicato
        secondsPlayed = secondsPlayed + 1 --ogni secondo che passa aumento questa variabile che tiene conto di quanto tempo è passato
        local x_enemySpeed = ((enemySpeed_max * secondsPlayed)/40) --aggiungo un incremento alla velocità di gioco facendo una proporzione sul tempo di gioco passato
        enemySpeed = enemySpeed_min + x_enemySpeed --la velocità è data dalla velocità minima (2) + il risultato della proporzione
        table_loop[3]._delay =  table_loop[3]._delay - secondsPlayed * 3 --aggiorno la velcoità di chiamata del timer dei proiettili del nemico, faccio sparare più velocemetne
      end
    end
    print("arriv")
    table_loop = {}
    table_loop[1] = timer.performWithDelay( 500, loop, 0 ) --richiamo le animazioni di gioco ogni 500 millisecondi
    table_loop[2] = timer.performWithDelay( 1000, increaseGameSpeed, 0 ) --funzione che serve per aumentare la velocità di gioco ogni secondo
    table_loop[3] = timer.performWithDelay( 1500, enemyBulletsLoop, 0 ) --richiamo lo sparo del nemico
  end
end


-- hide()
function scene:hide( event )

  local sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then
     -- Code here runs immediately after the scene goes entirely off screen
    -- Code here runs when the scene is on screen (but is about to go off screen)
  
  physics.pause()
  --timer.cancel(gameLoop)
  --timer.cancel(timeplayed)
 -- timer.cancel(timerBullet)

  --ELIMINO I LISTENERS
  sprite:removeEventListener("collision")

  -- RIMUOVO TUTTI GLI ELEMENTI DALLE TABELLE, CHE POSSOONO COMPRENDERE OGGETTI, EVENTI, LISTENERS E TIMER
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
  for i=1, #table_loop do
    timer.cancel( table_loop[i] )
    table_loop[i] = nil        -- Nil Out Table Instance
  end  

  elseif ( phase == "did" ) then
    composer.removeScene( "levels.final") -- ELIMINO TUTTO CIO' CHE C'E' ALL'INTERNO DELLA SCENA
end
end


-- destroy()
function scene:destroy( event )
  audio.stop(musicFinal)
  audio.dispose( musicFinal)
  local sceneGroup = self.view
  
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