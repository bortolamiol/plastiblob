local composer = require( "composer" )
 
local scene = composer.newScene()
local n


-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

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
        -- Code here runs when the scene is entirely on screen
        n=1
        local leveltarget = event.params.level
        local numImgs = tostring(event.params.imagetoshow)
        local continua = display.newImageRect( group_buttons, "immagini/livello-1/storia/continua.png", 100, 70 )
        continua.anchorX = 0
        continua.anchorY = 0
        continua.y = 40
        continua.x = 20
    
         
        
        --funzione per cambiare immagine
        function continua:touch( event )
            if event.phase == "ended" then
                n = n + 1
                imagesToShow(n)
            end
        end
        continua:addEventListener( "touch", continua )
        
        function imagesToShow( n )
            local imgpath
			if tonumber(n) <= tonumber(numImgs) then
				imgpath = "immagini/livello-"..leveltarget.."/storia/"..n..".png"
                local immagine = display.newImageRect(group_background,imgpath,1280,720)
                immagine.anchorX = 0
                immagine.anchorY = 0 
            else 
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
