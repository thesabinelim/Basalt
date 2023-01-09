local drawSystem = require("basaltDraw")
local rpairs = require("utils").rpairs

local max,min,sub,rep = math.max,math.min,string.sub,string.rep

return function(name, basalt)
    local base = basalt.getObject("Container")(name, basalt)
    local objectType = "Frame"
    local parent

    local xOffset, yOffset = 0, 0

    base:setSize(30, 10)

    local function getPosition()
        local x, y = base:getPosition()
        return x + xOffset, y + yOffset
    end

    local object = {    
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

        setParent = function(self, p, ...)
            base.setParent(self, p, ...)
            parent = p
            return self
        end,

        draw = function(self)
            base.draw(self)
            self:addDraw("frame-objects", function()
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

        blit = function (self, x, y, t, f, b)
            local obx, oby = getPosition()
            if (y >= 1) and (y <= self:getHeight()) then
                local w = self:getWidth()
                t = sub(t, max(1 - x + 1, 1), w - x + 1)
                f = sub(f, max(1 - x + 1, 1), w - x + 1)
                b = sub(b, max(1 - x + 1, 1), w - x + 1)
                parent:blit(max(x + (obx - 1), obx), oby + y - 1, t, f, b)
            end
        end,

        setCursor = function(self, blink, x, y, color)
            local obx, oby = getPosition()
            parent:setCursor(blink or false, (x or 0)+obx-1, (y or 0)+oby-1, color or colors.white)
            return self
        end,
    }

    for k,v in pairs({"drawBackgroundBox", "drawForegroundBox", "drawTextBox"})do
        object[v] = function(self, x, y, width, height, symbol)
            local obx, oby = getPosition()
            local w, h  = self:getSize()            
            height = (y < 1 and (height + y > h and h or height + y - 1) or (height + y > h and h - y + 1 or height))
            width = (x < 1 and (width + x > w and w or width + x - 1) or (width + x > w and w - x + 1 or width))
            parent[v](parent, max(x + (obx - 1), obx), max(y + (oby - 1), oby), width, height, symbol)
        end
    end

    for k,v in pairs({"setBG", "setFG", "setText"})do
        object[v] = function(self, x, y, str)
            local obx, oby = getPosition()
            local w, h  = self:getSize()
            if (y >= 1) and (y <= h) then
                parent[v](parent, max(x + (obx - 1), obx), oby + y - 1, sub(str, max(1 - x + 1, 1), max(w - x + 1,1)))
            end
        end
    end

    object.__index = object
    return setmetatable(object, base)
end