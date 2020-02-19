--[[ ---------------------------------------------------------------------------------
Questo codice serve per riprodurre la storia. Quando si sceglie il livello, prima del gameplay partirà la storia 
legata a ogni livello. La storia va segue una trama con un prologo (livello 1), uno svolgimento (livelli 2,3,4) e 
un epilogo (sconfitto il boss del livello 4). 

Per evitare di fare un file per ogni livello, abbiamo pensato di fare un unico file per tutti. Ciò ci è stato possibile
grazie a

        local leveltarget = event.params.level
        local numImgs = tostring(event.params.imagetoshow)

che prende le immagini della storia da mostrare contenute nella cartella "storia" di ciascun livello 
]]-- ---------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
local n -- numero di immagini che sono contenute nella cartella 

-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
    group_background = display.newGroup() --group_background conterrà la foto di sfondo che scrollerà
    group_buttons = display.newGroup() --group_elements conterrà tutti gli altri elementi dello schermo: sprite del personaggio, nemici e bottoni per uscire dal gioco
    
    sceneGroup:insert( group_background ) --inserisco il gruppo group_background dentro la scena
    sceneGroup:insert( group_buttons ) 
end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
    
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
 
    elseif ( phase == "did" ) then
        n=1 --parto dalla prima immagine nominata 1 
        local leveltarget = event.params.level
        local numImgs = tostring(event.params.imagetoshow)
        
        --funzione per cambiare immagine
        function continua( event )
            if event.phase == "ended" then
                n = n + 1
                imagesToShow(n)
            end
        end
        Runtime:addEventListener( "touch", continua )
        
        function imagesToShow( n )
            local imgpath
            if tonumber(n) <= tonumber(numImgs) then
                -- se n è minore  uguale al numero di immagini contenute nella cartella del livello scelto
                -- continuo a sovrapporle una sopra l'altra
				imgpath = "immagini/livello-"..leveltarget.."/storia/"..n..".png"
                local immagine = display.newImageRect(group_background,imgpath,1280,720)
                immagine.anchorX = 0
                immagine.anchorY = 0 
            else 
                -- dopo l'ultima immagine disponibile, cliccando su "continua" il gioco di consentirà di iniziare il gameplay
				local leveltargetpath = "levels.level" .. leveltarget;
                composer.gotoScene( leveltargetpath, "fade", 500 )
            end
        end
        imagesToShow( n )
    end
end
 
 
-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
        Runtime:removeEventListener( "touch", continua )
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
        composer.removeScene("levels.storylevel")
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
