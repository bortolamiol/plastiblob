local composer = require( "composer" )
 
local scene = composer.newScene()
 
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
 
end
 
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
 
    elseif ( phase == "did" ) then
        local leveltarget = event.params.level 
        --CREO UNO SPRITE 1280 X 720 CHE CONTERRA' L'IMMAGINE DEL TUTORIAL
        
        --l'immagine del tutorial cambia in base a che livello sono, se sono al primo livello mostrerà un'immagine, al due un'altra e così via..
        local tutorialSheetData = { width=1280, height=720, numFrames=3, sheetContentWidth=3840, sheetContentHeight=720 }
        --grazie al parametro passato dalla scena precedente riesco a capire che immagine mostrare dei tutorial
        -- le immagini sono rinominate in base al livello a cui fanno riferimento: tutorial1.png, tutorial2.png e tutorial3.png
        local impath = "immagini/tutorial/tutorial"..leveltarget ..".png"
        local tutorialSheet = graphics.newImageSheet( impath, tutorialSheetData )
        local tutorialData = {{ name="tutorial", sheet=tutorialSheet, start=1, count=3, time=4000, loopCount=0 }}
        local tutorialSprite = display.newSprite (tutorialSheet, tutorialData)
        tutorialSprite.x = display.actualContentWidth/2
        tutorialSprite.y = display.actualContentHeight/2
        tutorialSprite:play();
        sceneGroup:insert(tutorialSprite)
        
        function goToLevel()
            local levelTo = "levels.level"..leveltarget --punto al livello in base al paramettro passato dalla scena precedente
             composer.gotoScene(levelTo, "fade", 500)
        end
        Runtime:addEventListener("touch", goToLevel)
             
    end
end
 
 
-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
        Runtime:removeEventListener("touch", goToLevel)
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
        composer.removeScene("tutorial")
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
