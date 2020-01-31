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
	local backgroundImage = self.view
	local menu = self.view

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
				print( "ID del giocatore:", row.ID, " - Livello: ", row.level ),
			}
			livellicompletati = levels[1].level
			
		end
	else
	--Se dbexists ritorna 1 allora il Database non esiste, vuol dire perciò che dovrà essere creato
		local tableSetup = [[CREATE TABLE IF NOT EXISTS levels ( ID INTEGER PRIMARY KEY autoincrement,  level );]]
		db:exec( tableSetup )
		--inserisco la riga di default nel database, se l'ho appena creato andrò al livello 1
		local insertQuery = [[INSERT INTO levels VALUES ( null, "1" );]]
		db:exec( insertQuery )
	end
	
	--inserisco le immagini dei livelli dentro un vettore/tabella
	--per iniziare useremo 8 livelli, creerò quindi un for da 1 a 8 e ogni livello avrà un identificativo dentro i 
	local levels={}
	for i=1, 8 do
		local impath
		--controllo se ho già passato il livello nell'identificativo su cui è posizionata 1
		if (tonumber(livellicompletati) >= i) then
			--assegno al percorso dell'immagine l'immagine corrispondente al livello in modalità SBLOCCATA
			impath = "immagini/menu/livelli/"..i..".png"
		else
			--assegno al percorso dell'immagine l'immagine corrispondente al livello in modalità BLOCCATA
			impath = "immagini/menu/livelli/locked"..i..".png"
		end
		print("percorso: ", impath)
		levels[i] = display.newImageRect( menu, impath, 200, 200 )
		levels[i].anchorX = 0
		levels[i].anchorY = 0
		levels[i].x = checkImagePositionX(i)
		levels[i].y = checkImagePositionY(i)
	end

	local background = display.newImageRect( "immagini/menu/sfondo-menu-livelli.png", display.actualContentWidth, display.actualContentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x = 0 + display.screenOriginX 
	background.y = 0 + display.screenOriginY
	
	backgroundImage:insert( background )
	for i=1, 8 do
		--inserisco dentro la scena del gruppo le foto dei miei livelli
		menu:insert(levels[i])
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

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
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
	local sceneGroup = self.view
	
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