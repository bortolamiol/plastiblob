local composer = require( "composer" )

local scene = composer.newScene()

-- create()
function scene:create( event )

  local sceneGroup = self.view
  -- Code here runs when the scene is first created but has not yet appeared on screenlocal sceneGroup = self.view
  group_background = display.newGroup() --group_background conterrà la foto di sfondo che scrollerà
  group_buttons = display.newGroup() --group_elements conterrà tutti gli altri elementi dello schermo: sprite del personaggio, nemici e bottoni per uscire dal gioco

  sceneGroup:insert( group_background ) --inserisco il gruppo group_background dentro la scena
  sceneGroup:insert( group_buttons ) --inserisco il gruppo grooup_buttons sopra la scena e sotto i personaggi
end

-- show()
function scene:show( event )
  local phase = event.phase

  if ( phase == "will" ) then
    -- Code here runs when the scene is still off screen (but is about to come on screen)
  elseif ( phase == "did" ) then
    -- Code here runs when the scene is entirely on screen
    local retryAttempt = 0 --variabile che serviràà per poter farc cliccare solo una volta l'utente sul bottone retry
    local levelTarget = "levels."..event.params.level --Event.params contiene i parametri che si passano alla scena dal chiamante, in questo caso noi prendiamo la variabile level che conterrà il livello in cui dovremmo tornare in fase di 'retry'
    local button_home  --variabile per il bottone di home
    local button_retry --variabile per il bottone di retry
    local background = display.newImageRect(group_background,"immagini/menu/sfondo-menu.png",1280,720) --foto di sfondo
    background.anchorX = 0
    background.anchorY = 0


    --bottone per uscire dal livello e tornare al menu del livelli
    button_home = display.newImageRect(group_buttons, "immagini/menu/home.png", 200, 200 )
    button_home.anchorX =  0
    button_home.anchorY =  0
    button_home.x =  display.contentWidth/2 - 220
    button_home.y = display.contentHeight/2 + 100
    group_buttons:insert(button_home)

    function button_home:touch( event )
      if event.phase == "began" then
        timer.performWithDelay( 500, function() composer.gotoScene( "menu-levels", "fade", 500 ) end)  --ritorno al menu dei livelli
      end
    end
    button_home:addEventListener( "touch", touch )

    --bottone per ricominciare il livello
    button_retry = display.newImageRect( group_buttons,"immagini/menu/restart.png", 200, 200 )
    button_retry.anchorX =  0
    button_retry.anchorY =  0
    button_retry.x = display.actualContentWidth/2 + 30
    button_retry.y = display.actualContentHeight/2 + 100
    group_buttons:insert(button_retry)

    function button_retry:touch( event )
      if retryAttempt == 0 then
        retryAttempt = 1
        if event.phase == "began" then
          timer.performWithDelay( 500, function() composer.gotoScene( levelTarget, "fade", 200 ) end)  --ricomicio il livello puntando al percorso 'levelTarget' valorizzato sopra
        end
      end
    end
    button_retry:addEventListener( "touch", touch )
  end
end


-- hide()
function scene:hide( event )
  local phase = event.phase

  if ( phase == "will" ) then
    -- Code here runs when the scene is on screen (but is about to go off screen)

  elseif ( phase == "did" ) then
    -- Code here runs immediately after the scene goes entirely off screen
    composer.removeScene( "levels.gameover" ) --rimuovo completamente la scena
  end
end


-- destroy()
function scene:destroy( event )
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