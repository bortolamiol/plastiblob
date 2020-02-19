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
    print(event.params.level)
end
 
-- show()
function scene:show( event )
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        local levelTarget = "levels."..event.params.level
        local button_home 
        local button_retry
        local background = display.newImageRect(group_background,"immagini/livello-5/vittoria.png",1280,720)
        background.anchorX = 0
        background.anchorY = 0  
       --bottone per uscire dal livello e tornare al menu del livelli

        button_home = display.newImageRect(group_buttons, "immagini/menu/home.png", 200, 200 )
        button_home.anchorX =  0
        button_home.anchorY =  0
        button_home.x =  display.contentWidth/2 
        button_home.y = display.contentHeight/2 + 100
        group_buttons:insert(button_home)

        function button_home:touch( event )
            if event.phase == "began" then
                timer.performWithDelay( 500, function() composer.gotoScene( "menu-levels", "fade", 500 ) end)  --ritorno al menu dei livelli
            end
        end
        button_home:addEventListener( "touch", touch )
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