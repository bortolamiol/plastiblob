-----------------------------------------------------------------------------------------
--
-- PRIMO LIVELLO DEL GIOCO: SALTARE I NEMICI E RACCOGLIERE LA PLASTICA DAL CIELO
--
-----------------------------------------------------------------------------------------

-- dichiaro delle variabili che andrò a usare in varie scene del livello
local composer = require( "composer" ) --richiedo la libreria composer
local scene = composer.newScene() --nuova scena composer
local tutorial = 1 --ho completato il tutorial? se è 0 devo ancora farlo!
local bg --variabile che durante lo show conterrà le due immagini di sfondo che andranno una dopo l'altra
local punteggio --variabile che conterrà il mio punteggio del livello
local sprite --sprite del personaggio
local enemies = {} --sprite dei nemici
local table_plasticbag = {}
local button_home --bottone per uscire dal livello e tornare alla button_home dei livelli
local stop =  0 --variabile che servirà per capire se stoppare il gioco
local callingEnemies
local callingPlasticbag
local timeplayed  --varaiabile che misura da quanti secondi sono all'interno del gioco e farà cambiare la velocità
local timeToPlay = 100 --variabile che conterrà quanto l'utente dovrà sopravvivere all'interno del gioco
function scene:create( event )

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
    -- e.g. add display objects to 'sceneGroup', add touch listeners, etc.
    local sceneGroup = self.view
    --creo due nuovi gruppi che inserirò all'interno del gruppo 'padre' sceneGroup
    group_tutorial = display.newGroup() --group_background conterrà la foto di sfondo che scrollerà
    group_background = display.newGroup() --group_background conterrà la foto di sfondo che scrollerà
    group_elements = display.newGroup() --group_elements conterrà tutti gli altri elementi dello schermo: sprite del personaggio, nemici e bottoni per uscire dal gioco
    sceneGroup:insert( group_tutorial ) --inserisco il gruppo group_background dentro la scena
    sceneGroup:insert( group_background ) --inserisco il gruppo group_background dentro la scena
    sceneGroup:insert( group_elements ) --inserisco il gruppo group_elements dentro la scena
end

function scene:show( event )
	local phase = event.phase
	
    if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
		--richiedo la libreria necessaria per inserire la fisica all'interno del livello
		local physics = require("physics")
		physics.start()
		-- Overlays collision outlines on normal display objects
        physics.setGravity( 0,20 )
        physics.setDrawMode( "hybrid" )
		-- The default Corona renderer, with no collision outlines
		--physics.setDrawMode( "normal" )
		-- Shows collision engine outlines only
		--physics.setDrawMode( "debug" )  
		
    elseif phase == "did" then
        if(tutorial == 0) then 
            --[[ DA FARE
            

            --visualizzare il tutorial del gioco, all'interno del gruppo 'group_tutorial'


            ]]--
        elseif(tutorial == 1) then
            --ELIMINARE IL GRUPPO DEL TUTORIAL 
            -- INIZIALIZZO LE VARIABILI CHE VERRANNO USATE NEL GIOCO
               local secondsPlayed = 0
            -- VARIABILI PER LO SFONDO DI BACKGROUND {
                local _w = display.actualContentWidth  -- Width of screen
                local _h = display.actualContentHeight  -- Height of screen
                local _x = 0  -- Horizontal centre of screen
                local _y = 0  -- Vertical centre of screen
                
                bg={} -- 'vettore' che conterrà i due sfondi del gioco
                    bg[1] = display.newImageRect("immagini/livello-1/plastic-beach.png", _w, _h)
                    bg[1].anchorY = 0
                    bg[1].anchorX = 0
                    bg[1].x = 0
                    bg[1].y = _y
                    group_background:insert(bg[1])
                    bg[2] = display.newImageRect("immagini/livello-1/plastic-beach.png", _w, _h)
                    bg[2].anchorY = 0
                    bg[2].anchorX = 0
                    bg[2].x = _w
                    bg[2].y = _y
                    group_background:insert(bg[2])

                ------------------------------------------------------------
                -- VARIABILI MOLTO IMPORTANTI PER IL GIOCO: VELOCITA' DI GIOCO
                local enemySpeed_max = 14 -- massima velocità di spostamento del nemico
                local enemySpeed_min = 2 -- minima velocità di spostamento del nemico
                local enemySpeed = enemySpeed_min --velocità di spostamento del nemico

                local frame_speed = 20 --questa sarà la velocità dello scorrimento del nostro sfondo, in base a questa velocità alzeremo anche quella del gioco
                
                local time_speed_min = 30 -- ogni quanti millisecondi verranno chiamate le funzioni di loop (esempio di sfondo group_background)
                local time_speed_max = 6 --massimo di velocità che time_speed può raggiungere
                
                local spriteFrameSpeed = 800 --velocità del movimento delle gambe dello sprite [250 - 800]
                local spriteFrameSpeed_max = 200 --velocità del movimento delle gambe dello sprite [250 - 800]
                ------------------------------------------------------------
            --}
            --VARIABILI PER GLI ELEMENTI DELLO SCHERMO{
            local groundHeight = 100
            local ground = display.newRect( 0, 0,99999, groundHeight )
            ground.name = "ground"
            group_elements:insert(ground)
            ground.x = display.contentCenterX
            ground.y = display.contentHeight- groundHeight/2
            physics.addBody(ground, "static",{bounce=0, friction=1 } )
            --}
            --VARIABILI PER GLI SPRITE { 

            --PERSONAGGIO DEL GIOCO
            local spriteWalkingSheetData = 
            { 
                width=200, 
                height=200, 
                numFrames=8, 
                sheetContentWidth=1600, 
                sheetContentHeight=200
            }

            local spriteWalkingSheet = graphics.newImageSheet( "immagini/livello-1/spritewalking.png", spriteWalkingSheetData )
            -- primo sprite per il personaggio che salta
            local spriteJumpingSheetData = 
            { 
                width=200, 
                height=200, 
                numFrames=7, 
                sheetContentWidth=1400, 
                sheetContentHeight=200 
            }

            local spriteJumpingSheet = graphics.newImageSheet( "immagini/livello-1/spritejump.png", spriteJumpingSheetData )
            -- In your sequences, add the parameter 'sheet=', referencing which image sheet the sequence should use
            local spriteData = {
                { name="walking", sheet=spriteWalkingSheet, start=1, count=8, time=spriteFrameSpeed, loopCount=0 },
                { name="jumping", sheet=spriteJumpingSheet, start=1, count=7, time=500, loopCount=0 }
            }
            --metto assieme tutti i dettagli dello sprite, elencati in precedenza
            sprite = display.newSprite( spriteWalkingSheet, spriteData )
            sprite.name = "sprite"
            group_elements:insert(sprite)   
            local posY_sprite =  ground.y 
            sprite.x = (display.contentWidth/2)-300 ; sprite.y = posY_sprite-100
            local frameIndex = 1
            local outlinePersonaggio = graphics.newOutline(2, spriteWalkingSheet, frameIndex)   --outline personaggio
            physics.addBody(sprite, { outline=outlinePersonaggio, density=10, bounce=0, friction=1})    --sprite diventa corpo con fisica
            sprite.gravityScale = 3.8
            sprite.isFixedRotation = true --rotazione bloccata
            sprite.isJumping = false
            
            -- PRIMO NEMICO
            local enemyWalkingSheetData = { width=200, height=200, numFrames=6, sheetContentWidth=1200, sheetContentHeight=200 }
            local enemyWalkingSheet = graphics.newImageSheet( "immagini/livello-1/zombiewalking.png", enemyWalkingSheetData )
            local enemyData = {
                { name="walking", sheet=enemyWalkingSheet, start=1, count=6, time=500, loopCount=0 }
            }
            local enemyTimeSpawnMin = 5000
            local enemyTimeSpawnMax  = 9000

            -- SACCHETTO IN PLASTICA
            local plasticbagSheetData = { width=130, height=130, numFrames=4, sheetContentWidth=520, sheetContentHeight=130 }
            local plasticbagSheet = graphics.newImageSheet( "immagini/livello-1/paper.png", plasticbagSheetData )
            local plasticbagData = {
                { name="plastic", sheet=plasticbagSheet, start=1, count=4, time=500, loopCount=0 }
            }
            local plasticbagTimeSpawn = 5000

            --}
            

            
            --FUNZIONI {
            
            local function moveBackground(self)
                --questa funzione muove il group_background di sfondo
                if 	self.x<-(display.contentWidth-frame_speed*2) then
                    self.x = display.contentWidth
                else
                    self.x =self.x - frame_speed
                end	
            end
            
            ------------------------------------------------
            -- FUNZIONI PER I NEMICI {
            local function enemyScroll(self, event)
                --fa scorrere il nemico nello schermo
                if stop == 0 then
                    self.x = self.x - (enemySpeed*2)
                end
            end
            ------------------------------------------------
            local function createEnemies()
                --crea un oggetto di un nuovo sprite nemico e lo aggiunge alla tabella enemies[]
                --da implementare meglio, mi faccio passare che tipo di nemico devo inserire
                local enemy = display.newSprite( enemyWalkingSheet, enemyData )
                enemy.name = "enemy"
                enemy:play()
                group_elements:insert(enemy) 
                enemy.x = display.actualContentWidth + 200
                enemy.y = ground.y-150
                frameIndexNemico = 1;
                local outlineNemico = graphics.newOutline(5, enemyWalkingSheet, frameIndexNemico)
                physics.addBody(enemy, { outline=outlineNemico, density=5, bounce=0, friction=1})
                enemy.bodyType = "static"
                enemy.isFixedRotation = true
                enemy.gravityScale = 5
                table.insert(enemies, enemy)
                return enemy
            end
            ------------------------------------------------
            local function enemiesLoop()
                enemy = createEnemies()
                enemy.enterFrame = enemyScroll
                Runtime:addEventListener("enterFrame",enemy)
                for i,thisEnemy in ipairs(enemies) do
                    if thisEnemy.x < -200 then
                        Runtime:removeEventListener("enterFrame",thisEnemy)
                        display.remove(thisEnemy)
                        table.remove(enemies,i)
                    end
                end
            end
            --}
            ------------------------------------------------
            -- FUNZIONI PER IL SACCHETTO DI PLASTICA CHE VOLA{
                local function plasticbagScroll(self, event)
                    --fa scorrere il nemico nello schermo
                    if stop == 0 then
                        self.x = self.x - (enemySpeed*2)
                        local spostamentoaria = math.random(-5, 5)
                        self.y = self.y + spostamentoaria
                    end
                end
                ------------------------------------------------
                local function createPlasticbag()
                    --crea un oggetto di un nuovo sprite nemico e lo aggiunge alla tabella table_plasticbag[]
                    --da implementare meglio, mi faccio passare che tipo di nemico devo inserire
                    local plasticbag = display.newSprite( plasticbagSheet, plasticbagData )
                    plasticbag.name = "plasticbag"
                    plasticbag:play()
                    group_elements:insert(plasticbag) 
                    plasticbag.x = display.actualContentWidth
                    plasticbag.y = 200
                    local frameIndePlasticbag = 1;
                    local outlinePlasticbag = graphics.newOutline(20, plasticbagSheet, frameIndePlasticbag)
                    physics.addBody(plasticbag, { outline=outlinePlasticbag, density=1, bounce=0, friction=1})
                    plasticbag.isBullet = true
                    plasticbag.isSensor = true
                    plasticbag.bodyType = "static"
                    table.insert(table_plasticbag, plasticbag)
                    return plasticbag
                end
                ------------------------------------------------
                local function plasticbagLoop()
                    plasticbag = createPlasticbag() --creo un'istanza di un oggetto sprite plastic bag
                    plasticbag.enterFrame = plasticbagScroll --lo faccio scrollare, grazie alla funzione plasticbagScroll
                    Runtime:addEventListener("enterFrame", plasticbag) --assegno all'evento enterframe lo scroll
                    for i,thisPlasticbag in ipairs(table_plasticbag) do  --ipairs ritorna: an iteration Function, a Table, and 0. (?? trovata online)
                        if thisPlasticbag.x < -200 then --se c'è un sacchetto di plastica che ha superato il limite di -200, lo togliamo!
                            Runtime:removeEventListener("enterFrame",thisPlasticbag) --rimuovo l'ascoltatore che lo fa scrollare
                            display.remove(thisPlasticbag) --rimuove QUEL sacchetto di plastica dal display display
                            table.remove(table_plasticbag,i) --lo rimuove anche dalla tabella dei sacchetti di plastica
                        end
                    end
                end
                --}
                ------------------------------------------------
            --}
            
            --funzione che capisce se c'è collisione con un elemento
            function sprite.collision( self, event )
                if( event.phase == "began" ) then		
                    --tutte le informazioni dell'elemento che ho toccato le troviamo dentro event.other
                    if(event.other.name ==  "plasticbag") then --mi sono scontrato con il sacchetto
                        --[[

                            INSERIRE QUI IL DARE PUNTEGGIO PER AVER RACCOLTO LA PLASTICA

                        ]]--
                        Runtime:removeEventListener("enterFrame", event.other) --rimuovo il listener dello scroll, così non si muove più
                        local indexToRemove = table.indexOf(table_plasticbag, event.other ) --trovo l'indice che ha all'interno della tabella dei sacchetti di plastica
                        table.remove(table_plasticbag, indexToRemove) --lo rimuovo dalla tabella, utilizzando l'indice 'indexToRemove' 
                        display:remove(event.other) --lo rimuovo dal display
                        group_elements:remove(event.other) --lo rimuovo dal gruppo (????? serve??? NON LO SO, VEDIAMO SE DARA' PROBLEMI)
                    end
                    if(event.other.name ==  "enemy") then 
                        --mi sono scontrato col nemico
                       --print("Collisione con il nemico")
                       --[[

                            INSERIRE QUI GAME OVER

                       ]]--
                    end
                    if(self.isJumping) then 
                        self.isJumping = false
                        self:setSequence("walking")
                        self:play()
                       --print("Landed @ ", system.getTimer())
                        --print("------------------------\n")
                    end
                end
            end
            sprite:addEventListener("collision")
            
            ------------------------------------------------
            --quando avviene touch personaggio salta e avvia animazione salto
            function sprite.touch( self,event)
                if( event.phase == "began" and not self.isJumping ) then
                    self:setLinearVelocity(0,-1200)
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
            --[[

                    DA FARE!

            ]]--
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
            local function increaseGameSpeed(event)
                secondsPlayed = secondsPlayed + 1 --ogni secondo che passa aumento questa variabile che tiene conto di quanto tempo è passato
                if(gameLoop._delay >= time_speed_max) then --minimo di millisecondi a cui può spingersi la funzione loop
                    --time speed con cui viene richiamata la funzione loop
                    local x_time_speed = ((time_speed_max * secondsPlayed) / timeToPlay) --ottiene un numero da 1 a 6
                    gameLoop._delay = time_speed_min - ((time_speed_min * x_time_speed)/time_speed_max ) --il time delay è frutto di un'altra proporzione da 6 a 30

                    --cambio della velocità del nostro nemico [da 2 a 12] --> secondi passati : secondi totali = x : 12 (ritornerà un numero da 1 a 12)
                    local x_enemySpeed = ((enemySpeed_max * secondsPlayed)/timeToPlay)
                    enemySpeed = enemySpeed_min + x_enemySpeed --la velocità è data dalla velocità minima (2) + il risultato della proporzione
                    end
            end
            -- }
            --bottone per uscire dal livello e tornare al menu del livelli
            button_home = display.newImageRect( "immagini/menu/x.png", 80, 80 )
            button_home.anchorX =  0
            button_home.anchorY =  0
            button_home.x = display.actualContentWidth - 100
            button_home.y = 80
            group_elements:insert(button_home)

            function button_home:touch( event )
                if event.phase == "ended" then
                    stop = 1
                    timer.performWithDelay( 500, function() composer.gotoScene( "menu-levels", "fade", 500 ) end)  --ritorno al menu dei livelli
                end
            end
            button_home:addEventListener( "touch", touch )

            --PARTE FINALE: richiamo le funzioni e aggiungo gli elementi allo schermo e ai gruppi
            timeplayed = timer.performWithDelay( 1000, increaseGameSpeed, 0 )
            gameLoop = timer.performWithDelay( time_speed_min, loop, 0 )
            callingEnemies = timer.performWithDelay( math.random(enemyTimeSpawnMin, enemyTimeSpawnMax), enemiesLoop, 0 )
            callingPlasticbag = timer.performWithDelay( plasticbagTimeSpawn, plasticbagLoop, 0)
        end
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
        --QUI BISOGNA SALVARE I DATI DEL GIOCATORE COME IL PUNTEGGIO

        --CANCELLO I LOOP
		timer.cancel( gameLoop )
        timer.cancel( callingEnemies )
        timer.cancel( callingPlasticbag )
        timer.cancel( timeplayed )
        physics.pause()

       
        --ELIMINO I LISTENERS
        Runtime:removeEventListener("enterFrame",enemy)
        Runtime:removeEventListener("enterFrame",plasticbag)
        Runtime:removeEventListener( "touch", sprite )
        button_home:removeEventListener( "touch", touch ) 
        
        --SVUOTO LE TABELLE
        for i=1, #enemies do
            enemies[i]:removeSelf() -- Optional Display Object Removal
            enemies[i] = nil        -- Nil Out Table Instance
        end
        for i=1, #table_plasticbag do
            table_plasticbag[i]:removeSelf() -- Optional Display Object Removal
            table_plasticbag[i] = nil        -- Nil Out Table Instance
        end

	elseif phase == "did" then
		-- Called when the scene is now off screen
		--cancella tutto il contenuto all'interno di una scena senza salvare i contenuti
        
        composer.removeScene( "levels.level1" )
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