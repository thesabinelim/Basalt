return function(name, basalt)
    local base = basalt.getObject("ChangeableObject")(name, basalt)
    local objectType = "Switch"

    base:setSize(4, 1)
    base:setValue(false)
    base:setZIndex(5)

    local bgSymbol = colors.black
    local inactiveBG = colors.red
    local activeBG = colors.green

    local object = {
        getType = function(self)
            return objectType
        end,

        setSymbol = function(self, col)
            bgSymbol = col
            return self
        end,

        setActiveBackground = function(self, col)
            activeBG = col
            return self
        end,

        setInactiveBackground = function(self, col)
            inactiveBG = col
            return self
        end,


        load = function(self)
            local parent = self:getParent()
            parent:addEvent("mouse_click", self)
        end,

        mouseHandler = function(self, ...)
            if (base.mouseHandler(self, ...)) then
                self:setValue(not self:getValue())
                self:updateDraw()
                return true
            end
        end,

        draw = function(self)
            base.draw(self)
            self:addDraw("switch", function()
                local parent = self:getParent()
                local obx, oby = self:getPosition()
                local bgCol,fgCol = self:getBackground(), self:getForeground()
                local w,h = self:getSize()
                if(self:getValue())then
                    parent:drawBackgroundBox(obx, oby, w, h, activeBG)
                    parent:drawBackgroundBox(obx+w-1, oby, 1, h, bgSymbol)
                else
                    parent:drawBackgroundBox(obx, oby, w, h, inactiveBG)
                    parent:drawBackgroundBox(obx, oby, 1, h, bgSymbol)
                end
            end)
        end,
    }

    object.__index = object
    return setmetatable(object, base)
end