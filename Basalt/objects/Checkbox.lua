local utils = require("utils")
local tHex = require("tHex")

return function(name, basalt)
    -- Checkbox
    local base = basalt.getObject("ChangeableObject")(name, basalt)
    local objectType = "Checkbox"

    base:setZIndex(5)
    base:setValue(false)
    base:setSize(1, 1)

    local symbol,inactiveSymbol = "\42"," "

    local object = {
        init = function(self)
            local parent = self:getParent()
            parent:addEvent("mouse_click", self)
            parent:addEvent("mouse_up", self)
            return base.init(self)
        end,

        getType = function(self)
            return objectType
        end,
        isType = function(self, t)
            return objectType==t or base.isType~=nil and base.isType(t) or false
        end,

        setSymbol = function(self, sym, inactive)
            symbol = sym or symbol
            inactiveSymbol = inactive or inactiveSymbol
            self:updateDraw()
            return self
        end,

        mouseHandler = function(self, button, x, y)
            if (base.mouseHandler(self, button, x, y)) then
                if(button == 1)then
                    if (self:getValue() ~= true) and (self:getValue() ~= false) then
                        self:setValue(false)
                    else
                        self:setValue(not self:getValue())
                    end
                self:updateDraw()
                return true
                end
            end
            return false
        end,

        draw = function(self)
            base.draw(self)
            self:addDraw("checkbox", function()
                local obx, oby = self:getPosition()
                local w,h = self:getSize()
                local verticalAlign = utils.getTextVerticalAlign(h, "center")
                local bg,fg = self:getBackground(), self:getForeground()
                if (self:getValue()) then
                    self:addBlit(1, verticalAlign, utils.getTextHorizontalAlign(symbol, w, "center"), tHex[bg], tHex[fg])
                else
                    self:addBlit(1, verticalAlign, utils.getTextHorizontalAlign(inactiveSymbol, w, "center"), tHex[bg], tHex[fg])
                end
            end)
        end,
    }

    object.__index = object
    return setmetatable(object, base)
end