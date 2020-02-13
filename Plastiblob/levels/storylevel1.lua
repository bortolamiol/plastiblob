local composer = require( "composer" )
 
local scene = composer.newScene()

local imagesToShow = 5
local n = 1


-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
 
end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
    
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        local continua = display.newImageRect( "immagini/livello-1/storia1/continua.png", 100, 70 )
        continua.anchorX = 0
        continua.anchorY = 0
        continua.y = 40
        continua.x = 20
    
        --funzione per cambiare immagine
        function continua:touch( event )
            if event.phase == "ended" then
                --grazie al nome dell'oggetto riesco a capire su quale immagine ho cliccato
                print("uoooooo")
            end
        end
        continua:addEventListener( "touch", continua )

        local imagesToShow = {}

        for n=1 , 5 do
            local imgpath
			if n <= 5 then
				imgpath = "immagini/livello-1/storia1"..n..".png"
                n = n + 1
            else
                local leveltargetpath = "levels.level" .. nlevel;
					composer.gotoScene( leveltargetpath, "fade", 500 )
            end
        end   

    end
end
 
 
-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
        
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
 
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
