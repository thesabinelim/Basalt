return {
    VisualObject = function(base)
        local shadow = false        

        local object = {
            setShadow = function(self, color)
                shadow = color
                self:updateDraw()
                return self
            end,

            draw = function(self)
                base.draw(self)
                self:addDraw("shadow", function()
                    if(shadow~=false)then
                        local w,h = self:getSize()
                        if(shadow)then      
                            local obj = self:getParent() or self                  
                            obj:addBackgroundBox(1, h, w, 1, shadow)
                            obj:addBackgroundBox(w, 1, 1, h, shadow)
                            obj:addForegroundBox(1, h, w, 1, shadow)
                            obj:addForegroundBox(w, 1, 1, h, shadow)
                        end
                    end
                end)
            end,
        }

        return object
    end
}