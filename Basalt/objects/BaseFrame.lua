local Container = require("Container")
local drawSystem = require("basaltDraw")
local rpairs = require("utils").rpairs

local max,min,sub,rep = math.max,math.min,string.sub,string.rep

return function(name, basalt)
    local base = basalt.getObject("Container")(name, basalt)
    local objectType = "BaseFrame"

    local xOffset, yOffset = 0, 0

    local colorTheme = {}

    local redrawRequired = true
    
    local termObject = basalt.getTerm()
    local basaltDraw = drawSystem(termObject)

    local xCursor, yCursor, cursorBlink, cursorColor = 1, 1, false, colors.white

    local object = {   
        init = function(self)
            if(base.init(self))then
                self:setBackground(basalt.getTheme("BaseFrameBG"))
                self:setForeground(basalt.getTheme("BaseFrameText"))
            end
        end,

        getType = function()
            return objectType
        end,
        isType = function(self, t)
            return objectType==t or base.isType~=nil and base.isType(t) or false
        end,

        getBase = function(self)
            return base
        end,

        getOffset = function(self)
            return xOffset, yOffset
        end,

        setOffset = function(self, xOff, yOff)
            xOffset = xOff or xOffset
            yOffset = yOff or yOffset
            return self
        end,

        updateDraw = function(self)
            redrawRequired = true
            return self
        end,

        setSize = function(self, ...)
            base.setSize(self, ...)
            basaltDraw = drawSystem(termObject)
            return self
        end,

        getSize = function()
            return termObject.getSize()
        end,

        getWidth = function(self)
            return ({termObject.getSize()})[1]
        end,

        getHeight = function(self)
            return ({termObject.getSize()})[2]
        end,

        show = function(self)
            base.show(self)
            basalt.setActiveFrame(self)
            for k,v in pairs(colors)do
                if(type(v)=="number")then
                    termObject.setPaletteColor(v, colors.packRGB(term.nativePaletteColor((v))))
                end
            end
            for k,v in pairs(colorTheme)do
                if(type(v)=="number")then
                    termObject.setPaletteColor(type(k)=="number" and k or colors[k], v)
                else
                    local r,g,b = table.unpack(v)
                    termObject.setPaletteColor(type(k)=="number" and k or colors[k], r,g,b)
                end
            end
            basalt.setMainFrame(self)
            return self
        end,

        redraw = function(self)
            base.redraw(self)
            redrawRequired = false
            return self
        end,

        draw = function(self)
            base.draw(self)
            self:addDraw("baseframe-objects", function()
                local objects,objZIndex = self:getObjects()
                for _, index in rpairs(objZIndex) do
                    if (objects[index] ~= nil) then
                        for _, value in pairs(objects[index]) do
                            if (value.redraw ~= nil) then
                                value:redraw()
                            end
                        end
                    end
                end
            end)
        end,

        updateTerm = function(self)
            basaltDraw.update()
        end,

        eventHandler = function(self, event, ...)
            base.eventHandler(self, event, ...)
            if(event=="term_resize")then
                self:setSize(termObject.getSize())
            end
        end,

        blit = function (self, x, y, t, f, b)
            local obx, oby = self:getPosition()
            x = x + xOffset
            y = y + yOffset
            local w, h = self:getWidth(), self:getHeight()
            local xPos = x + obx - 1
            local yPos = oby + y - 1
            if y >= 1 and y <= h then
                local xMin = x < 1 and 1 - x + 1 or 1
                local xMax = x > w and w - x + 1 or w
                t = sub(t, xMin, xMax)
                f = sub(f, xMin, xMax)
                b = sub(b, xMin, xMax)
                basaltDraw.blit(xPos, yPos, t, f, b)
            end
        end,

        setCursor = function(self, _blink, _xCursor, _yCursor, color)
            local obx, oby = self:getAbsolutePosition()
            cursorBlink = _blink or false
            if (_xCursor ~= nil) then
                xCursor = obx + _xCursor - 1
            end
            if (_yCursor ~= nil) then
                yCursor = oby + _yCursor - 1
            end
            cursorColor = color or cursorColor
            if (cursorBlink) then
                termObject.setTextColor(cursorColor)
                termObject.setCursorPos(xCursor, yCursor)
                termObject.setCursorBlink(cursorBlink)
            else
                termObject.setCursorBlink(false)
            end
            return self
        end,
    }

    for k,v in pairs({"drawBackgroundBox", "drawForegroundBox", "drawTextBox"})do
        object[v] = function(self, x, y, width, height, symbol)
            local obx, oby = self:getPosition()
            local w, h  = self:getSize()
            x = x + xOffset
            y = y + yOffset
            height = max(0, min(h - y + 1, height))
            width = max(0, min(w - x + 1, width))
            if height > 0 and width > 0 then
                basaltDraw[v](max(x + (obx - 1), obx), max(y + (oby - 1), oby), width, height, symbol)
            end
        end
    end

    for k,v in pairs({"setBG", "setFG", "setText"}) do
        object[v] = function(self, x, y, str)
            local obx, oby = self:getPosition()
            local w, h = self:getSize()
            x = x + xOffset
            y = y + yOffset
            local xPos = x + obx - 1
            local yPos = oby + y - 1
            if (y >= 1) and (y <= h) then
                local xMin = x < 1 and 1 - x + 1 or 1
                local xMax = x > w and w - x + 1 or w
                basaltDraw[v](xPos, yPos, sub(str, xMin, xMax))
            end
        end
    end


    object.__index = object
    return setmetatable(object, base)
end