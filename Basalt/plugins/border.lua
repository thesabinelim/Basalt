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
                        local x, y = self:getPosition()
                        local w,h = self:getSize()
                        local parent = self:getParent()
                        if(border)then                        
                            parent:drawBackgroundBox(x+1, y+h, w, 1, shadow)
                            parent:drawBackgroundBox(x+w, y+1, 1, h, shadow)
                            parent:drawForegroundBox(x+1, y+h, w, 1, shadow)
                            parent:drawForegroundBox(x+w, y+1, 1, h, shadow)
                        end
                    end
                end)
            end,
        }

        return object
    end
}