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
    local leveltarget = event.params.level --il livello a cui andrò dopo me lo passa la scena 'menu-levels' ed è dentro la variabile level dei parametri
    local numImgs = tostring(event.params.imagetoshow) --numero di immagini che andrò a  mostrare all'utente, uso questo parametro perchè oogni sttoria ha un numero differente di immagini da mostrare

    --funzione per cambiare immagine
    function continua( event ) -- questa funzione viene richiamata ogni volta che l'utente clicca sullo schermo per continuare la storia
      if event.phase == "ended" then
        n = n + 1 --aumento questa variabile che mi servrà per mostrare le immagini in ordine, la prima volta che si entra n = 1 quindi si mostrerà immgine '1.png'
        imagesToShow(n) --richiamo la funzione per mostrare le immagini, passandogli il numero dell'immagine da mostrare
      end
    end
    Runtime:addEventListener( "touch", continua ) --ascoltatore che rileva quando si clicca sullo schermo

    function imagesToShow( n ) --prendo in pasto la variabile n
      local imgpath --dichiaro una variabile che andrò a valorizzare con il percorso dell'immagine
      if tonumber(n) <= tonumber(numImgs) then --se non sono ancora arrivato all'ultima immagine da mostrare, vado avanti
        -- se n è minore  uguale al numero di immagini contenute nella cartella del livello scelto
        -- continuo a sovrapporle una sopra l'altra
        if(leveltarget == 6) then
          imgpath = "immagini/finale/"..n..".png" --creo il percorso dell'immagine
        else
          imgpath = "immagini/livello-"..leveltarget.."/storia/"..n..".png" --creo il percorso dell'immagine
        end

        local immagine = display.newImageRect(group_background,imgpath,1280,720)
        immagine.anchorX = 0
        immagine.anchorY = 0
      else
        -- dopo l'ultima immagine disponibile, cliccando su "continua" il gioco di consentirà di iniziare il gameplay
        local options = { --parametri che passerò alla prossima schermara
          effect = "fade", --animazione
          time = 500, --tempo che durerà l'animazione
          params = { level = leveltarget } --parametri che gli passo: il numero del livello a cui andare dopo la storia e il numero di immagini da mostrare
        }
        local leveltargetpath --dichiaro una variabile per il percoso a cui puntare
        if(tonumber(leveltarget) == 1 or tonumber(leveltarget) ==2 or tonumber(leveltarget) == 3 ) then --se devo andare al livello 1, 2 o 3 devo mostrare anche un piccolo tutorial, al livello 4 ci vado direttamente senza tutorial
          leveltargetpath = "tutorial" --vado alla pagina di tutorial
        elseif(tonumber(leveltarget) == 4)  then
          leveltargetpath = "levels.level4" --vado al livello 4
        elseif(tonumber(leveltarget) == 5)  then
          leveltargetpath = "levels.final" --vado al livello finale
        elseif(tonumber(leveltarget) == 6) then
          leveltargetpath = "levels.victory" --vado ai credits
        end
        composer.gotoScene( leveltargetpath, options)
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
