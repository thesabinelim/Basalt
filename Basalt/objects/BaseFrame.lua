local Container = require("Container")
local drawSystem = require("basaltDraw")
local rpairs = require("utils").rpairs

local max,min,sub,rep = math.max,math.min,string.sub,string.rep

return function(name, basalt)
    local base = Container(name, basalt)
    local objectType = "BaseFrame"

    local termObject = basalt.getTerm()
    local basaltDraw = drawSystem(termObject)

    local colorTheme = {}

    local redrawRequired = true

    local object = {    
        getType = function()
            return objectType
        end,
        isType = function(self, t)
            return objectType==t or base.isType~=nil and base.isType(t) or false
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

        drawBackgroundBox = function(self, x, y, width, height, bgCol)
            local obx, oby = self:getPosition()
            local parent = self:getParent()
            local w, h  = self:getSize()
            
            height = (y < 1 and (height + y > h and h or height + y - 1) or (height + y > h and h - y + 1 or height))
            width = (x < 1 and (width + x > w and w or width + x - 1) or (width + x > w and w - x + 1 or width))
            if (parent ~= nil) then
                parent:drawBackgroundBox(max(x + (obx - 1), obx), max(y + (oby - 1), oby), width, height, bgCol)
            else
                basaltDraw.drawBackgroundBox(max(x + (obx - 1), obx), max(y + (oby - 1), oby), width, height, bgCol)
            end
        end,

        drawForegroundBox = function(self, x, y, width, height, fgCol)
            local obx, oby = self:getPosition()
            local parent = self:getParent()
            local w, h  = self:getSize()

            height = (y < 1 and (height + y > h and h or height + y - 1) or (height + y > h and h - y + 1 or height))
            width = (x < 1 and (width + x > w and w or width + x - 1) or (width + x > w and w - x + 1 or width))
            if (parent ~= nil) then
                parent:drawForegroundBox(max(x + (obx - 1), obx), max(y + (oby - 1), oby), width, height, fgCol)
            else
                basaltDraw.drawForegroundBox(max(x + (obx - 1), obx), max(y + (oby - 1), oby), width, height, fgCol)
            end
        end;

        drawTextBox = function(self, x, y, width, height, symbol)
            local obx, oby = self:getPosition()
            local parent = self:getParent()
            local w, h  = self:getSize()

            height = (y < 1 and (height + y > h and h or height + y - 1) or (height + y > h and h - y + 1 or height))
            width = (x < 1 and (width + x > w and w or width + x - 1) or (width + x > w and w - x + 1 or width))
            if (parent ~= nil) then
                parent:drawTextBox(max(x + (obx - 1), obx), max(y + (oby - 1), oby), width, height, sub(symbol,1,1))
            else
                basaltDraw.drawTextBox(max(x + (obx - 1), obx), max(y + (oby - 1), oby), width, height, sub(symbol,1,1))
            end
        end,

        blit = function (self, x, y, t, f, b)
            local obx, oby = self:getPosition()
            local parent = self:getParent()
            if (y >= 1) and (y <= self:getHeight()) then
                local w = self:getWidth()
                if (parent ~= nil) then
                    t = sub(t, max(1 - x + 1, 1), w - x + 1)
                    f = sub(f, max(1 - x + 1, 1), w - x + 1)
                    b = sub(b, max(1 - x + 1, 1), w - x + 1)
                    parent:blit(max(x + (obx - 1), obx), oby + y - 1, t, f, b)
                else
                    t = sub(t, max(1 - x + 1, 1), max(w - x + 1,1))
                    f = sub(f, max(1 - x + 1, 1), max(w - x + 1,1))
                    b = sub(b, max(1 - x + 1, 1), max(w - x + 1,1))
                    basaltDraw.blit(max(x + (obx - 1), obx), oby + y - 1, t, f, b)
                end
            end
        end,

        setText = function(self, x, y, text)
            local obx, oby = self:getPosition()
            local parent = self:getParent()
            if (y >= 1) and (y <= self:getHeight()) then
                if (parent ~= nil) then
                    parent:setText(max(x + (obx - 1), obx), oby + y - 1, sub(text, max(1 - x + 1, 1), max(self:getWidth() - x + 1,1)))
                else
                    basaltDraw.setText(max(x + (obx - 1), obx), oby + y - 1, sub(text, max(1 - x + 1, 1), max(self:getWidth() - x + 1,1)))
                end
            end
        end,

        setBG = function(self, x, y, bgCol)
            local obx, oby = self:getPosition()
            local parent = self:getParent()
            if (y >= 1) and (y <= self:getHeight()) then
                if (parent ~= nil) then
                    parent:setBG(max(x + (obx - 1), obx), oby + y - 1, sub(bgCol, max(1 - x + 1, 1), max(self:getWidth() - x + 1,1)))
                else
                    basaltDraw.setBG(max(x + (obx - 1), obx), oby + y - 1, sub(bgCol, max(1 - x + 1, 1), max(self:getWidth() - x + 1,1)))
                end
            end
        end,

        setFG = function(self, x, y, fgCol)
            local obx, oby = self:getPosition()
            local parent = self:getParent()
            if (y >= 1) and (y <= self:getHeight()) then
                if (parent ~= nil) then
                    parent:setFG(max(x + (obx - 1), obx), oby + y - 1, sub(fgCol, max(1 - x + 1, 1), max(self:getWidth() - x + 1,1)))
                else
                    basaltDraw.setFG(max(x + (obx - 1), obx), oby + y - 1, sub(fgCol, max(1 - x + 1, 1), max(self:getWidth() - x + 1,1)))
                end
            end
        end,

        writeText = function(self, x, y, text, bgCol, fgCol)
            local obx, oby = self:getPosition()
            local parent = self:getParent()
            if (y >= 1) and (y <= self:getHeight()) then
                if (parent ~= nil) then
                    parent:writeText(max(x + (obx - 1), obx), oby + y - 1, sub(text, max(1 - x + 1, 1), self:getWidth() - x + 1), bgCol, fgCol)
                else
                    basaltDraw.writeText(max(x + (obx - 1), obx), oby + y - 1, sub(text, max(1 - x + 1, 1), max(self:getWidth() - x + 1,1)), bgCol, fgCol)
                end
            end
        end,

        redraw = function(self)
            base.redraw(self)
            redrawRequired = false
            return self
        end,

        draw = function(self)
            self:addDraw("baseframe", function()
                local w,h = termObject.getSize()
                local bgColor,bgSymbol,bgSymbolColor = self:getBackground()
                if(bgColor~=false)then
                    basaltDraw.drawBackgroundBox(1, 1, w, h, bgColor)
                end
                if(bgSymbol~=false)then
                    self:drawTextBox(1, 1, w, h, bgSymbol)
                    if(bgSymbol~=" ")then
                        basaltDraw.drawForegroundBox(1, 1, w, h, bgSymbolColor)
                    end
                end
            end)
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

        init = function(self)
            if(base.init(self))then
                self:setBackground(basalt.getTheme("BaseFrameBG"))
                self:setForeground(basalt.getTheme("BaseFrameText"))
            end
        end,
    }

    object.__index = object
    return setmetatable(object, base)
end