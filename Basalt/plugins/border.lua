return {
    VisualObject = function(base)
        local border = false
        local inline = false      

        local object = {
            setBorder = function(self, color)
                border = color
                self:updateDraw()
                return self
            end,

            draw = function(self)
                base.draw(self)
                self:addDraw("border", function()
                    if(border~=false)then
                        local obj = self:getParent() or self
                        local x, y = self:getPosition()
                        local w,h = self:getSize()
                        if(border)then                        
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