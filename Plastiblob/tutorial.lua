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
        local tutorialSheetData = { width=1280, height=720, numFrames=3, sheetContentWidth=3840, sheetContentHeight=720 }
        local tutorialSheet = graphics.newImageSheet( "Tutorial/jumptutorial.png", tutorialSheetData )
        local tutorialData = {{ name="tutorial", sheet=tutorialSheet, start=1, count=3, time=5000, loopCount=0 }}
        local tutorialSprite = display.newSprite (tutorialSheet, tutorialData)
        tutorialSprite.x = display.actualContentWidth/2
        tutorialSprite.y = display.actualContentHeight/2
        tutorialSprite:play();
        
        local goToLevelBtn = display.newImageRect("immagini/livello-1/storia/continua.png", 100, 70)
        goToLevelBtn.x = display.actualContentWidth/2
        goToLevelBtn.y = display.actualContentWidth/2
        local options =
        {
            effect = "fade",
            time = 400
        }
        function goToLevel (touch)
             composer.goToScene("levels.level1",options)
        end
        goToLevelBtn:addEventListener("touch", goToLevel)
             
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
