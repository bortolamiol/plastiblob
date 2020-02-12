-----------------------------------------------------------------------------------------
--
-- menu dei livelli, in questa pagina potrò scegliere il livello a cui giocare, ovviamente
-- scegliendo solo tra quelli già sbloccati
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()


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
		print("entrato")
		local backgroundImage = self.view
		local menu = self.view
		
		local musicTrack1 = audio.loadStream("MUSIC/THEME.mp3") --carico musica "tema"
		audio.setVolume(0.2)
		
		--controllo se c'è già dell'audio che suona
		if (composer.isAudioPlayingMenu==1) then
			print("channel 1 sta già suonando, non fare nulla")
		elseif (composer.isAudioPlaying==0) then
			audio.play( musicTrack1, { channel=2, loops=-1 } )
			composer.isAudioPlaying=1
			print("faccio partire audio da levels nel channel 2!")
		end
		
		--creo una variabile che contenga i livelli a cui sono arrivato, se non ho passato nessun livello partirà da 1
		local livellicompletati 
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
				levels[#levels+1] =
				{
					FirstName = row.FirstName,
					level = row.level,
					scoreLevel1 = row.scoreLevel1,
					scoreLevel2 = row.scoreLevel2,
					scoreLevel3 = row.scoreLevel3,
					scoreLevel4 = row.scoreLevel4,
					scoreLevel5 = row.scoreLevel5,
					scoreLevel6 = row.scoreLevel6,
					scoreLevel7 = row.scoreLevel7,
					scoreLevel8 = row.scoreLevel8,
					print("Livello: " ..row.level .. "  || 1: " ..row.scoreLevel1 .. " || 2: " ..row.scoreLevel2 .. " || 3: " ..row.scoreLevel3 .. " || 4: " ..row.scoreLevel4 .. " || 5: " ..row.scoreLevel5 .. " || 6: " ..row.scoreLevel6 .. " || 7: " ..row.scoreLevel7 .. " || 8: " ..row.scoreLevel8) 
				}
				livellicompletati = levels[1].level		
			end
		else
		--Se dbexists ritorna 1 allora la tabella non esiste, vuol dire perciò che dovrà essere creata
			local tableSetup = [[CREATE TABLE levels ( ID INTEGER PRIMARY KEY autoincrement, level, scoreLevel1, scoreLevel2, scoreLevel3, scoreLevel4, scoreLevel5, scoreLevel6, scoreLevel7, scoreLevel8);]]
			db:exec( tableSetup )
			--inserisco la riga di default nel database, se l'ho appena creato andrò al livello 1
			local insertQuery = [[INSERT INTO levels VALUES ( null, "1", 0, 0, 0, 0, 0, 0, 0, 0);]]
			db:exec( insertQuery )
			--dato che la tabella non esisteva vuol dire che è la prima volta che l'utente gioca, perciò lo faccio iniziare dal livello 1
			livellicompletati = 1
		end
		
		--inserisco le immagini dei livelli dentro un vettore/tabella
		--per iniziare useremo 8 livelli, creerò quindi un for da 1 a 8 e ogni livello avrà un identificativo dentro i 
		local levels={}
		for i=1, 8 do
			local impath
			--controllo se ho già passato il livello nell'identificativo su cui è posizionata 1
			if tonumber(livellicompletati) >= tonumber(i) then
				--assegno al percorso dell'immagine l'immagine corrispondente al livello in modalità SBLOCCATA
				impath = "immagini/menu/livelli/"..i..".png"
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
			levels[i].y = checkImagePositionY(i)
		end

		--questa funzione serve per capire quando ho cliccato su un'immagine per andare sul livello cliccato
		function levels:touch( event )
			if event.phase == "began" then
				--grazie al nome dell'oggetto riesco a capire su quale immagine ho cliccato
				local nlevel = tostring(event.target.name)
				--controllo se ho accesso al livello in quanto devo aver superato quello prima
				if(tonumber(livellicompletati) >= tonumber(nlevel)) then
					local leveltargetpath = "levels.level" .. nlevel;
					composer.gotoScene( leveltargetpath, "fade", 500 )
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

		for i=1, 8 do
			--inserisco dentro la scena del gruppo le foto dei miei livelli e assegno un listener per ognuno degli oggetti
			levels[i]:addEventListener( "touch", levels )
			menu:insert(levels[i])
		end
	end
end
function checkImagePositionX(i)
	local x
	--questa funzione serve per ritornare il valore di x in cui posizionare una determinata immagine, la funzione si svolgerà per ogni elemento del vettore/tabella
	if(i == 1 or i==5) then
		x = 100
	end
	if(i == 2 or i==6) then
		x = 400
	end
	if(i == 3 or i==7) then
		x = 700
	end
	if(i == 4 or i==8) then
		x = 1000
	end
	return x
end
function checkImagePositionY(i)
	local y
	--questa funzione serve per ritornare il valore di x in cui posizionare una determinata immagine, la funzione si svolgerà per ogni elemento del vettore/tabella
	if(i == 1 or i == 2 or i == 3 or i == 4) then
		y= 200
	end
	if(i == 5 or i == 6 or i == 7 or i == 8) then
		y= 500
	end
	return y
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