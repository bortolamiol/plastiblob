local composer = require( "composer" )
 
local scene = composer.newScene()
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screenlocal sceneGroup = self.view
    group_background = display.newGroup() --group_background conterrà la foto di sfondo che scrollerà
    group_buttons = display.newGroup() --group_elements conterrà tutti gli altri elementi dello schermo: sprite del personaggio, nemici e bottoni per uscire dal gioco
    
    sceneGroup:insert( group_background ) --inserisco il gruppo group_background dentro la scena
    sceneGroup:insert( group_buttons ) --inserisco il gruppo castle sopra la scena e sotto i personaggi
end
-- audio 
 local audiogameover = audio.loadSound("MUSIC/PERDENTE.mp3")
 audio.play(audiogameover)
 
-- show()
function scene:show( event )
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
       local button_home 
       local button_retry
       local background = display.newImageRect(group_background,"immagini/menu/sfondo-menu.png",1280,720)
           background.anchorX = 0
           background.anchorY = 0  
       --bottone per uscire dal livello e tornare al menu del livelli

             button_home = display.newImageRect(group_buttons, "immagini/menu/home.png", 100, 100 )
             button_home.anchorX =  0
             button_home.anchorY =  0
             button_home.x =  50
             button_home.y = 50
             group_buttons:insert(button_home)

             function button_home:touch( event )
                if event.phase == "began" then
                    timer.performWithDelay( 500, function() composer.gotoScene( "menu-levels", "fade", 500 ) end)  --ritorno al menu dei livelli
                end
            end
            button_home:addEventListener( "touch", touch )
             
 
         
             --bottone per uscire dal livello e ricominciare
             button_retry = display.newImageRect( group_buttons,"immagini/menu/restart.png", 100, 100 )
             button_retry.anchorX =  0
             button_retry.anchorY =  0
             button_retry.x = display.actualContentWidth - 120
             button_retry.y = 50
             group_buttons:insert(button_retry)

             function button_retry:touch( event )
                if event.phase == "began" then
                    timer.performWithDelay( 500, function() composer.gotoScene( "levels.level1", "fade", 200 ) end)  --ricomicio
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
        composer.removeScene( "levels.gameover" )
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