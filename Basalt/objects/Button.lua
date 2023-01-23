local utils = require("utils")
local tHex = require("tHex")

return function(name, basalt)
    -- Button
    local base = basalt.getObject("VisualObject")(name, basalt)
    local objectType = "Button"
    local textHorizontalAlign = "center"
    local textVerticalAlign = "center"

    local text = "Button"

    base:setSize(12, 3)
    base:setZIndex(5)

    local object = {
        getType = function(self)
            return objectType
        end,
        isType = function(self, t)
            return objectType==t or base.isType~=nil and base.isType(t) or false
        end,

        getBase = function(self)
            return base
        end,  
        
        setHorizontalAlign = function(self, pos)
            textHorizontalAlign = pos
            self:updateDraw()
            return self
        end,

        setVerticalAlign = function(self, pos)
            textVerticalAlign = pos
            self:updateDraw()
            return self
        end,

        setText = function(self, newText)
            text = newText
            self:updateDraw()
            return self
        end,

        draw = function(self)
            base.draw(self)
            self:addDraw("button", function()
                local w,h = self:getSize()
                local verticalAlign = utils.getTextVerticalAlign(h, textVerticalAlign)
                self:addText(1, verticalAlign, utils.getTextHorizontalAlign(text, w, textHorizontalAlign))
                self:addFG(1, verticalAlign, utils.getTextHorizontalAlign(tHex[self:getForeground() or colors.black]:rep(text:len()), w, textHorizontalAlign))

            end)
        end,
    }
    object.__index = object
    return setmetatable(object, base)
end