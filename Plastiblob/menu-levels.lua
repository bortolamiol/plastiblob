-----------------------------------------------------------------------------------------
--
-- menu dei livelli, in questa pagina potrò scegliere il livello a cui giocare, ovviamente
-- scegliendo solo tra quelli già sbloccati
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

local backgroundImage
local menu
local stars
-- include Corona's "widget" library
local widget = require "widget"

function scene:create( event )

end

function scene:show( event )
  local sceneGroup = self.view
  local phase = event.phase

  if phase == "will" then
    -- Called when the scene is still off screen and is about to move on screen

  elseif phase == "did" then

    backgroundImage = display.newGroup() --group_elements conterrà tutti gli altri elementi dello schermo: sprite del personaggio, nemici e bottoni per uscire dal gioco
    menu = display.newGroup() --group_elements conterrà tutti gli altri elementi dello schermo: sprite del personaggio, nemici e bottoni per uscire dal gioco
    scene_stars = display.newGroup() --group_elements conterrà tutti gli altri elementi dello schermo: sprite del personaggio, nemici e bottoni per uscire dal gioco

    sceneGroup:insert( backgroundImage ) -- il primmo gruppo che si visualizzerà sarà quello dell'immagine di bg
    sceneGroup:insert( menu ) --questo conterrà le foto dei livelli
    sceneGroup:insert( scene_stars ) --questo le stelle che sarannno posizionate sopra le foto dei livelli


    local musicTrack1 = audio.loadStream("MUSIC/THEME.mp3") --carico musica "tema"
    --audio.setVolume(0.2)

    --controllo se c'è già dell'audio che suona
    if (composer.isAudioPlayingMenu==1) then
      print("channel 1 sta già suonando, non fare nulla")
    elseif (composer.isAudioPlaying==0) then
      audio.play( musicTrack1, { channel=2, loops=-1 } )
      composer.isAudioPlaying=1
      print("faccio partire audio da levels nel channel 2!")
    end

    --creo una variabile che contenga i livelli a cui sono arrivato, se non ho passato nessun livello partirà da 1
    local livellicompletati --variabile che andrà ad essere valorizzata in base al numero di livelli che l'utente ha completato
    local scores = {}
    --CREAZIONE DI UN DATABASE PER CONTENERE I LIVELLI
    -- Require the SQLite library
    local sqlite3 = require( "sqlite3" )

    -- Create a file path for the database file "data.db"
    local path = system.pathForFile( "data.db", system.DocumentsDirectory )

    -- Open the database for access
    local db = sqlite3.open( path )
    --controllo se la tabella 'levels' esiste già, sennò la devo creare
    local checkifdbexists = [[SELECT * from levels]]
    local dbexists = db:exec( checkifdbexists )
    print("il DATABASE esiste: "..dbexists .. "  (se è 0 già esiste, se 1 allora non esiste)")
    if(dbexists == 0) then
      --Se dbexists ritorna 0 allora il Database già esiste nella memoria, mi serve prendere i dati
      local levels = {}
      -- prendo i dati dal database con una select
      for row in db:nrows( "SELECT * FROM levels" ) do
        --print( "Row:", row.level )
        --Crea una tabella dove inserire i dati che troviamo dentro la tabella dei livelli
        levels[#levels+1] = {
          FirstName = row.FirstName, --questa variabile contiene l'ID del giocatore, ovviamente noi avendo il db in locale non avremmo altri utenti, ma nel caso si volesse portare il gioco ad un "online" questa chiave primaria servirebbe che identificare ogni singolo utente che gioca
          level = row.level, --numero del livello a cui l'utente è arrivato
          scoreLevel1 = row.scoreLevel1 , --punteggio acquisito nel livello 1
          scoreLevel2 = row.scoreLevel2, --punteggio acquisito nel livello 2
          scoreLevel3 = row.scoreLevel3, --punteggio acquisito nel livello 3
          scoreLevel4 = row.scoreLevel4, --punteggio acquisito nel livello 4
          print("Livello: " ..row.level .. "  || 1: " ..row.scoreLevel1 .. " || 2: " ..row.scoreLevel2 .. " || 3: " ..row.scoreLevel3 .. " || 4: " ..row.scoreLevel4 )
        }
        livellicompletati = levels[1].level --livelli completati viene valorizzato con qeusta variabile
        --la tabella scores viene valorizzata, ogni posizione conterrà il punteggio ottenuto nel livello
        scores[1] = levels[1].scoreLevel1
        scores[2] = levels[1].scoreLevel2
        scores[3] = levels[1].scoreLevel3
        scores[4] = levels[1].scoreLevel4
      end
    else
      --Se dbexists ritorna 1 allora la tabella non esiste, vuol dire perciò che dovrà essere creata
      local tableSetup = [[CREATE TABLE levels ( ID INTEGER PRIMARY KEY autoincrement, level, scoreLevel1, scoreLevel2, scoreLevel3, scoreLevel4);]]
      db:exec( tableSetup )
      --inserisco la riga di default nel database, se l'ho appena creato andrò al livello 1
      local insertQuery = [[INSERT INTO levels VALUES ( null, "1", 0, 0, 0, 0);]]
      db:exec( insertQuery )
      --dato che la tabella non esisteva vuol dire che è la prima volta che l'utente gioca, perciò lo faccio iniziare dal livello 1
      livellicompletati = 1
      --dato che ho appena creato la tabella, non ho completato nessun livello --> non ho ottenuto punteggi
      scores[1] = 0
      scores[2] = 0
      scores[3] = 0
      scores[4] = 0
    end

    local function checkStars(score) --funzione che ritorna quante stelle ho raggiunto sul livello
      --in base al numero di oggetti di plastica raccolti, ritorno delle stelle di merito all'utente
      local stars
      if(tonumber(score) <= 3) then --se ho preso meno di 4 plastiche...
        --ritorno una stella
        stars = 1
      elseif(tonumber(score) >= 4 and tonumber(score) <= 7) then
        --ritorno due stelle
        stars = 2
      elseif(tonumber(score) >= 8) then
        --ritorno tre stelle
        stars = 3
      end
      return stars
    end
    --inserisco le immagini dei livelli dentro un vettore/tabella
    --per iniziare useremo 4 livelli, creerò quindi un for da 1 a 4 8 e ogni livello avrà un identificativo dentro 'i'
    local levels={}
    for i=1, 4 do
      local impath --percorso dell'immagine che andremo a valorizzare in seguito
      --controllo se ho già passato il livello nell'identificativo su cui è posizionata 1
      if tonumber(livellicompletati) >= tonumber(i) then
        --assegno al percorso dell'immagine l'immagine corrispondente al livello in modalità SBLOCCATA
        impath = "immagini/menu/livelli/"..i..".png" --grazie al ciclo for, riuscirò a valorizzare impath in maniera sempre differente, prima con 1.png, 2.png, 3 ecc
        if(tonumber(livellicompletati) > i) then
          local numberOfStars = checkStars(scores[i]) --quante stelle ha fatto l'utente
          local starsPath = "immagini/menu/livelli/star"..numberOfStars..".png" --in base al numero tornato cerco l'immagine giusta (1 o 2 o 3)
          local starImage = display.newImageRect( scene_stars, starsPath, 200, 200 )
          starImage.anchorX = 0
          starImage.anchorY = 0
          starImage.x = checkImagePositionX(i)
          starImage.y = 250
        end
      else
        --assegno al percorso dell'immagine l'immagine corrispondente al livello in modalità BLOCCATA
        impath = "immagini/menu/livelli/locked"..i..".png"
      end
      --IMPORTANTE: ogni oggetto ha un proprio nome dato dalla sua posizione nel contatore i, per esempio l'immagine del livello 1 avrà nome "1"
      levels[i] = display.newImageRect( menu, impath, 200, 200 )
      levels[i].name = tostring(i)
      levels[i].anchorX = 0
      levels[i].anchorY = 0
      levels[i].x = checkImagePositionX(i)
      levels[i].y = 310 --dispongo le immagini a metà dello shcermo
    end

    --questa funzione serve per capire quando ho cliccato su un'immagine per andare sulla storia del livello cliccato
    function levels:touch( event )
      if event.phase == "began" then
        --grazie al nome dell'oggetto riesco a capire su quale immagine ho cliccato
        local nlevel = tostring(event.target.name)
        local imagetoshowParam --parametro da passare
        --controllo se ho accesso al livello in quanto devo aver superato quello prima

        --per far vedere all'utente la storia, abbiamo creato UN SOLO file lua, che in base al numero di immagini da mostrare fa un ciclo e le mostra
        --ovviamente dobbiamo dire quante immagini mostrare, per esempio il livello 1 ha bisogno di 5 immagini, il livello 2 di 3 immagini e così via
        --questo parametro poi lo passeremo grazie alla tabella 'options' che conterrà il nostro parametro 'imagetoshowParam'
        if(tonumber(nlevel) == 1) then
          imagetoshowParam = 5
        elseif(tonumber(nlevel) == 2) then
          imagetoshowParam = 3
        elseif(tonumber(nlevel) == 3) then
          imagetoshowParam = 2
        elseif(tonumber(nlevel) == 4) then
          imagetoshowParam = 1
        end
        local options = {
          effect = "fade", --animazione
          time = 500, --tempo che durerà l'animazione
          params = { level= nlevel, imagetoshow = imagetoshowParam } --parametri che gli passo: il numero del livello a cui andare dopo la storia e il numero di immagini da mostrare
        }
        if(tonumber(livellicompletati) >= tonumber(nlevel)) then --se ho il permesso di cliccare sull'immagine..vado al livello
          local leveltargetpath = "levels.storylevel" --path della storia
          composer.gotoScene( leveltargetpath, options) --vado alla storia, passandogli la tabella options
          audio.stop();
          audio.dispose( musicTrack1 )
        end
        return true
      end
    end

    --immagine di sfondo
    local background = display.newImageRect( "immagini/menu/sfondo-menu-livelli.png", display.actualContentWidth, display.actualContentHeight )
    background.anchorX = 0
    background.anchorY = 0
    background.x = 0 + display.screenOriginX
    background.y = 0 + display.screenOriginY
    backgroundImage:insert( background )

    --bottone per tornare indietro alla schermata precedente
    local goback = display.newImageRect( "immagini/menu/goback.png", 100, 70 )
    goback.anchorX = 0
    goback.anchorY = 0
    goback.y = 40
    goback.x = 20

    --funzione per tornare indietro nel menu
    function goback:touch( event )
      if event.phase == "began" then
        --grazie al nome dell'oggetto riesco a capire su quale immagine ho cliccato
        composer.gotoScene( "menu", "fade", 500 )
        return true
      end
    end
    goback:addEventListener( "touch", goback )
    menu:insert(goback)

    for i=1, 4 do
      --inserisco dentro la scena del gruppo le foto dei miei livelli e assegno un listener per ognuno degli oggetti
      levels[i]:addEventListener( "touch", levels )
      menu:insert(levels[i])
    end
  end
end
function checkImagePositionX(i)
  local x
  --questa funzione serve per ritornare il valore di x in cui posizionare una determinata immagine, la funzione si svolgerà per ogni elemento del vettore/tabella
  if(i == 1) then
    x = 100
  end
  if(i == 2) then
    x = 400
  end
  if(i == 3) then
    x = 700
  end
  if(i == 4) then
    x = 1000
  end
  return x
end
function scene:hide( event )
  local sceneGroup = self.view
  local phase = event.phase

  if event.phase == "will" then
    -- Called when the scene is on screen and is about to move off screen
    --
    -- INSERT code here to pause the scene
    -- e.g. stop timers, stop animation, unload sounds, etc.)
    audio.dispose( musicTrack1 )
  elseif phase == "did" then
    -- Called when the scene is now off screen
    --composer.removeScene( "menu-levels" )
  end
end

function scene:destroy( event )
  local sceneGroup = self.view
  audio.dispose( musicTrack1 )
  -- Called prior to the removal of scene's "view" (sceneGroup)
  --
  -- INSERT code here to cleanup the scene
  -- e.g. remove display objects, remove touch listeners, save state, etc.
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------


return scene