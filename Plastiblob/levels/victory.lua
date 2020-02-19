-----------------------------------------------------------------------------------------
--
-- TERZO LIVELLO DEL GIOCO: SALTARE I NEMICI E RACCOGLIERE LA PLASTICA DAL CIELO CON PIATTAFORME
--
-----------------------------------------------------------------------------------------

-- dichiaro delle variabili che andrò a usare in varie scene del livello
local localLevel = 3 --VARIABILE CHE CONTIENE IL NUMERO DI LIVELLO A CUI APPARTIENE IL FILE LUA: IN QUESTO CASO SIAMO AL LIVELLO 1
local composer = require( "composer" ) --richiedo la libreria composer
local scene = composer.newScene() --nuova scena composer
local tutorial = 1 --ho completato il tutorial? se è 0 devo ancora farlo!
local bg --variabile che durante lo show conterrà le due immagini di sfondo che andranno una dopo l'altra
local punteggio --variabile che conterrà il mio punteggio del livello
local sprite --sprite del personaggio
local enemies = {} --sprite dei nemici
local table_plasticbag = {} --tabella che conterrà al suo interno i sacchetti di plastica che sono sullo schermo
local table_bullets = {} --tabella che conterrà al suo interno i proiettili che sono sullo schermo
local table_spine = {} --tabella che conterrà al suo interno le pozze d'acqua che sono sullo schermo
local table_platform = {} --tabella che conterrà al suo interno le piattaforme che saranno sullo schermo
local button_home --bottone per uscire dal livello e tornare alla button_home dei livelli
local stop =  0 --variabile che servirà per capire se stoppare il gioco
local stopCreatingEnemies =  0 --variabile che servirà per capire se stoppare il gioco
local callingEnemies
local castle
local platform --variabile che conterrà al suo interno l'immagine della piattaforma che sarà visualizzata nel gioco
local callingPlasticbag
local callingSpine
local timeplayed  --varaiabile che misura da quanti secondi sono all'interno del gioco e farà cambiare la velocità
local timeToPlay = 70 --variabile che conterrà quanto l'utente dovrà sopravvivere all'interno del gioco
local scoreCount    --variabile conteggio punteggio iniziale
local gameFinished
local newTimerOut
local nextScene = "menu-levels"
local crunchSound = audio.loadSound("MUSIC/crunch.mp3")
local musicLevel3
local explosionSound3 = audio.loadSound("MUSIC/explosion.mp3") --carico suono esplosione
function scene:create( event )

  -- Called when the scene's view does not exist.
  --
  -- INSERT code here to initialize the scene
  -- e.g. add display objects to 'sceneGroup', add touch listeners, etc.
  local sceneGroup = self.view
  musicLevel3 = audio.loadStream("MUSIC/level2.mp3") --carico la traccia audio level3
  --creo due nuovi gruppi che inserirò all'interno del gruppo 'padre' sceneGroup
  group_background = display.newGroup() --group_background conterrà la foto di sfondo che scrollerà
  group_castle = display.newGroup() --group_elements conterrà tutti gli altri elementi dello schermo: sprite del personaggio, nemici e bottoni per uscire dal gioco
  group_elements = display.newGroup() --group_elements conterrà tutti gli altri elementi dello schermo: sprite del personaggio, nemici e bottoni per uscire dal gioco
  sceneGroup:insert( group_background ) --inserisco il gruppo group_background dentro la scena
  sceneGroup:insert( group_castle ) --inserisco il gruppo castle sopra la scena e sotto i personaggi
  sceneGroup:insert( group_elements ) --inserisco il gruppo group_elements dentro la scena
end

function scene:show( event )
  local phase = event.phase

  if phase == "will" then
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    -------------------   RICHIEDO LA FISICA ALLA LIBRERIA  --------------------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    local physics = require("physics")
    physics.start()
    -- Overlays collision outlines on normal display objects
    physics.setGravity( 0,41 )

  elseif phase == "did" then
    audio.play( musicLevel3, { channel=3, loops=-1 } ) --parte la musica del livello 3


    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    -------------------   VARIE VARIABILI DI FUNZIONAMENTO  --------------------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    local secondsPlayed = 0 --quanti secondi sono passati dall'inizio del gioco
    local castleAppared = 0 --variabile fuffa che mi servirà per controllare se il castello è già apparso sullo schermo una volta
    scoreCount = 0 --variabile conteggio punteggio iniziale
    gameFinished = 0 --variabile che mi servirà per fare un controllo aggiuntivo e fermare le animazioni e la creazione dei personaggi fino a quando non si cancellano i timer e animazioni

    -- VARIABILI PER LO SFONDO DI BACKGROUND
    local _w = display.actualContentWidth  -- Width of screen
    local _h = display.actualContentHeight  -- Height of screen
    local _x = 0  -- Horizontal centre of screen
    local _y = 0  -- Vertical centre of screen

    bg={} -- 'vettore' che conterrà i due sfondi del gioco
    bg[1] = display.newImageRect("immagini/livello-3/background.png", _w, _h)
    bg[1].anchorY = 0
    bg[1].anchorX = 0
    bg[1].x = 0
    bg[1].y = _y
    group_background:insert(bg[1])
    bg[2] = display.newImageRect("immagini/livello-3/background.png", _w, _h)
    bg[2].anchorY = 0
    bg[2].anchorX = 0
    bg[2].x = _w
    bg[2].y = _y
    group_background:insert(bg[2])

    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    -------------------   VARIABILI PER VELOCITA' DI GIOCO  --------------------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    local enemySpeed_max = 8-- massima velocità di spostamento del nemico
    local enemySpeed_min = 4 -- minima velocità di spostamento del nemico
    local enemySpeed = enemySpeed_min --velocità iniziale di spostamento del nemico, parte dal valore minimo

    local frame_speed = 10 --questa sarà la velocità dello scorrimento del nostro sfondo, si sposta di 20 pixel in 20

    local time_speed_min = 20 -- ogni quanti millisecondi verranno chiamate le funzioni di loop (esempio di sfondo group_background)
    local time_speed_max = 10 -- massimo di velocità che time_speed può raggiungere

    local plasticToCatch = 7 --numero di oggetti di plastica che l'utente dovrà raccogliere

    ----------------PROIETTILE
    local bulletSheetData = { width=200, height=84, numFrames=3, sheetContentWidth=600, sheetContentHeight=84 }
    local bulletSheet = graphics.newImageSheet( "immagini/finale/ecoproiettile.png", bulletSheetData )
    local bulletData = {
        { name="berna", sheet=bulletSheet, start=1, count=3, time=1400, loopCount=0 }
        { name="borto", sheet=bulletSheet, start=1, count=3, time=1400, loopCount=0 }
        { name="gabri", sheet=bulletSheet, start=1, count=3, time=1400, loopCount=0 }
        { name="simo", sheet=bulletSheet, start=1, count=3, time=1400, loopCount=0 }
        { name="corso", sheet=bulletSheet, start=1, count=3, time=1400, loopCount=0 }
    }



    local function moveBackground(self) --funzione dello scroll del gioco
      --questa funzione muove il group_background di sfondo
      if 	self.x<-(display.contentWidth-frame_speed*2) then
        self.x = display.contentWidth
      else
        self.x =self.x - frame_speed --si muove di 20 in 20
      end
    end

    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    ---------------- FUNZIONI PER IL PRIMO NEMICO DEL GIOCO --------------------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------

    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    ------------- FUNZIONI PER IL PROIETTILE E LATTINA DI PLASTICA --------------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------

    local function bulletScroll(self, event)
        --fa scorrere il sacchetto nello schermo
        if stop == 0 then
          self.x = self.x  - 5 --fa andare  avanti il proiettile in x senza spostarsi in y
          if self.x > display.actualContentWidth + 30 then --se c'è un sacchetto di plastica che ha superato il limite di -200, lo togliamo!
            Runtime:removeEventListener("enterFrame",self) --rimuovo l'ascoltatore che lo fa scrollare
            group_elements:remove(self)
            display.remove(self) --rimuove QUEL sacchetto di plastica dal display display
            local res = table.remove(table_bullets, table.indexOf( table_bullets, self )) --lo rimuove anche dalla tabella dei proeittili
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
        local outlineBullet = graphics.newOutline(1, bulletSheet, 2)
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

    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    --------------------- FUNZIONI PER IL LOOP DEL GIOCO  ----------------------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------

    local function loop( event )
      --qui dentro metteremo tutte le cose che necessitano di un loop all'interno del gioco
      --richiamo le due funzioni per muovere lo sfondo
      moveBackground(bg[1])
      moveBackground(bg[2])
    end


    ------------------------------------------------
    function goToTheNewScene()
      composer.gotoScene( "menu-levels", "fade", 500 ) --vado alla nuova scena
    end
    -----------------------------------------------

    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    --------------- FUNZIONI PER L'INCREMENDO DELLA VELOCITA' ------------------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    local function increaseGameSpeed(event)
      secondsPlayed = secondsPlayed + 1 --ogni secondo che passa aumento questa variabile che tiene conto di quanto tempo è passato
      print("seconds played: " ..secondsPlayed)
        if(secondsPlayed >= 50 ) then --se è ora di far finire il gioco, vado al passo successivo
          goToTheNewScene()
        end
      end


    
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    ---------------------------------- TIMER  ----------------------------------
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    timeplayed = timer.performWithDelay( 1000, increaseGameSpeed, 0 )
    gameLoop = timer.performWithDelay( time_speed_min, loop, 0 )

    
  end
end


function scene:hide( event )
  local sceneGroup = self.view

  local phase = event.phase

  if event.phase == "will" then
    resetScene()

  elseif phase == "did" then
    --cancella tutto il contenuto all'interno di una scena senza salvare i contenuti
    audio.stop( 3 ) --la musica del livello 1 si ferma
    composer.removeScene( "levels.victory")
  end

end

function scene:destroy( event )

  -- Called prior to the removal of scene's "view" (sceneGroup)
  --
  -- INSERT code here to cleanup the scene
  -- e.g. remove display objects, remove touch listeners, save state, etc.
  audio.dispose( musicLevel3) --elimino la musica del livello
  local sceneGroup = self.view
end


function resetScene()
    composer.isAudioPlaying=0
    audio.dispose(crunchSound)
    timer.cancel( gameLoop )
    timer.cancel( timeplayed )
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene