local composer = require( "composer" )
 
local scene = composer.newScene()
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------
-- Scene event functions

--print( event.params.level ) QUEST
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screenlocal sceneGroup = self.view
    group_background = display.newGroup() --group_background conterrà la foto di sfondo 
    group_buttons = display.newGroup() --group_elements conterrà i due bottoni di sfondo
    
    sceneGroup:insert( group_background ) --inserisco il gruppo group_background dentro la scena
    sceneGroup:insert( group_buttons ) --inserisco il gruppo dei bottoni sopra quello del background
    
end
 
 
-- show()
function scene:show( event )
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        --[[

            INSERISCI QUI IL CODICE LASTON
            1) fai vedere la foto di sfondo
            2) crea un bottone per tornare alla home
            3) crea un bottone per re-iniziare il livello
            4) guarda su internet o su elearning come inserire i listener per capire se si ha cliccato sui bottoni
            5) crea due funzioni di click sui due bottoni
            6) scrivi sul gruppo se hai problemi
        ]]--
    end
end
 
 
-- hide()
function scene:hide( event )
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
 
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