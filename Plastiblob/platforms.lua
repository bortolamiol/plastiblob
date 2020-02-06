local platformSpeed = 2 --velocità di spostamento della piattaforma
local platformSpeed_max = 8 --massima velocità di spostamento della piattaforma

 --PIATTAFORMA PASSTHROUGH
 local platform = display.newImageRect("immagini/livello-1/platform.png" ,400, 60)
 platform.x, platform.y = display.contentCenterX, display.contentCenterY+80
 platform.collType = "passthru"
 physics.addBody( platform, "static", { bounce=0.0, friction=0.3 } )
 group_elements:insert(platform)


------------------------------------------------
            --FUNZIONI PER LA PIATTAFORMA {
            local function platformScroll(self, event)
                --fa scorrere il nemico nello schermo
                if stop == 0 then
                    self.x = self.x - (platformSpeed*2)
                end
            end
            

