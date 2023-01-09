local tHex = require("tHex")

return function(name, basalt)
    local base = basalt.getObject("ChangeableObject")(name, basalt)
    local objectType = "Slider"

    base:setSize(12, 1)
    base:setValue(1)
    base:setBackground(false, "\140", colors.black)

    local barType = "horizontal"
    local symbol = " "
    local symbolFG = colors.black
    local symbolBG = colors.gray
    local maxValue = 12
    local index = 1
    local symbolSize = 1

    local function mouseEvent(self, button, x, y)
    local obx, oby = self:getPosition()
    local w,h = self:getSize()
        local size = barType == "vertical" and h or w
        for i = 0, size do
            if ((barType == "vertical" and oby + i == y) or (barType == "horizontal" and obx + i == x)) and (obx <= x) and (obx + w > x) and (oby <= y) and (oby + h > y) then
                index = math.min(i + 1, size - (#symbol + symbolSize - 2))
                self:setValue(maxValue / size * index)
                self:updateDraw()
            end
        end
    end

    local object = {
        getType = function(self)
            return objectType
        end,

        load = function(self)
            local parent = self:getParent()
            parent:addEvent("mouse_click", self)
            parent:addEvent("mouse_drag", self)
            parent:addEvent("mouse_scroll", self)
        end,

        setSymbol = function(self, _symbol)
            symbol = _symbol:sub(1, 1)
            self:updateDraw()
            return self
        end,

        setIndex = function(self, _index)
            index = _index
            if (index < 1) then
                index = 1
            end
            local w,h = self:getSize()
            index = math.min(index, (barType == "vertical" and h or w) - (symbolSize - 1))
            self:setValue(maxValue / (barType == "vertical" and h or w) * index)
            self:updateDraw()
            return self
        end,

        getIndex = function(self)
            return index
        end,

        setMaxValue = function(self, val)
            maxValue = val
            return self
        end,

        setSymbolColor = function(self, col)
            symbolColor = col
            self:updateDraw()
            return self
        end,

        setBarType = function(self, _typ)
            barType = _typ:lower()
            self:updateDraw()
            return self
        end,

        mouseHandler = function(self, button, x, y)
            if (base.mouseHandler(self, button, x, y)) then
                mouseEvent(self, button, x, y)
                return true
            end
            return false
        end,

        dragHandler = function(self, button, x, y)
            if (base.dragHandler(self, button, x, y)) then
                mouseEvent(self, button, x, y)
                return true
            end
            return false
        end,

        scrollHandler = function(self, dir, x, y)
            if(base.scrollHandler(self, dir, x, y))then
                local w,h = self:getSize()
                index = index + dir
                if (index < 1) then
                    index = 1
                end
                index = math.min(index, (barType == "vertical" and h or w) - (symbolSize - 1))
                self:setValue(maxValue / (barType == "vertical" and h or w) * index)
                self:updateDraw()
                return true
            end
            return false
        end,

        draw = function(self)
            base.draw(self)
            self:addDraw("slider", function()
                local parent = self:getParent()
                local obx, oby = self:getPosition()
                local w,h = self:getSize()
                local bgCol,fgCol = self:getBackground(), self:getForeground()
                if (barType == "horizontal") then
                    parent:setText(obx + index - 1, oby, symbol:rep(symbolSize))
                    if(symbolBG~=false)then parent:setBG(obx + index - 1, oby, tHex[symbolBG]:rep(#symbol*symbolSize)) end
                    if(symbolFG~=false)then parent:setFG(obx + index - 1, oby, tHex[symbolFG]:rep(#symbol*symbolSize)) end
                end

                if (barType == "vertical") then
                    for n = 0, h - 1 do
                        if (index == n + 1) then
                            for curIndexOffset = 0, math.min(symbolSize - 1, h) do
                                parent:writeText(obx, oby + n + curIndexOffset, symbol, symbolColor, symbolColor)
                            end
                        else
                            if (n + 1 < index) or (n + 1 > index - 1 + symbolSize) then
                                parent:writeText(obx, oby + n, bgSymbol, bgCol, fgCol)
                            end
                        end
                    end
                end
            end)
        end,
    }

    object.__index = object
    return setmetatable(object, base)
end