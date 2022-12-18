local Container = require("Container")
local drawSystem = require("basaltDraw")
local rpairs = require("utils").rpairs

local max,min,sub,rep = math.max,math.min,string.sub,string.rep

return function(name, basalt)
    local base = basalt.getObject("Container")(name, basalt)
    local objectType = "BaseFrame"

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

        updateDraw = function(self)
            redrawRequired = true
            return self
        end,

        setSize = function(self, w, h, rel)
            base.setSize(self, w, h, rel)
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
            if (y >= 1) and (y <= self:getHeight()) then
                local w = self:getWidth()
                t = sub(t, max(1 - x + 1, 1), max(w - x + 1,1))
                f = sub(f, max(1 - x + 1, 1), max(w - x + 1,1))
                b = sub(b, max(1 - x + 1, 1), max(w - x + 1,1))
                basaltDraw.blit(max(x + (obx - 1), obx), oby + y - 1, t, f, b)
            end
        end,

        setCursor = function(self, _blink, _xCursor, _yCursor, color)
            local obx, oby = self:getAbsolutePosition(self:getPosition(self:getX(), self:getY(), true))
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
            height = (y < 1 and (height + y > h and h or height + y - 1) or (height + y > h and h - y + 1 or height))
            width = (x < 1 and (width + x > w and w or width + x - 1) or (width + x > w and w - x + 1 or width))
            basaltDraw[v](max(x + (obx - 1), obx), max(y + (oby - 1), oby), width, height, symbol)
        end
    end

    for k,v in pairs({"setBG", "setFG", "setText"})do
        object[v] = function(self, x, y, str)
            local obx, oby = self:getPosition()
            local w, h  = self:getSize()
            if (y >= 1) and (y <= h) then
                basaltDraw[v](max(x + (obx - 1), obx), oby + y - 1, sub(str, max(1 - x + 1, 1), max(w - x + 1,1)))
            end
        end
    end


    object.__index = object
    return setmetatable(object, base)
end