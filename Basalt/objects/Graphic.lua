local Object = require("Object")
local tHex = require("tHex")
local xmlValue = require("utils").getValueFromXML
local bimgLib = require("bimgLibrary")

local sub,len,max,min = string.sub,string.len,math.max,math.min

return function(name)
    -- Graphic
    local base = Object(name)
    local objectType = "Graphic"
    local imgData = bimgLib()
    local bimg
    base:setZIndex(5)

    local xOffset, yOffset = 0, 0
   
    local object = {
        getType = function(self)
            return objectType
        end;

        setOffset = function(self, _x, _y, rel)
            if(rel)then
                xOffset = xOffset + _x or 0
                yOffset = yOffset + _y or 0
            else
                xOffset = _x or xOffset
                yOffset = _y or yOffset
            end
            self:updateDraw()
            return self
        end,

        getOffset = function(self)
            return xOffset,yOffset
        end,

        setValuesByXMLData = function(self, data)
            base.setValuesByXMLData(self, data)
        
            return self
        end,

        setPixel = function(self, text, fg, bg, _x, _y)
            x = _x or x
            y = _y or y
            imgData.blit(text, fg, bg, x, y)
            bimg = imgData.getBimgData()[1]
            self:updateDraw()
            return self
        end,

        setText = function(self, text, _x, _y)
            x = _x or x
            y = _y or y
            imgData.text(text, x, y)
            bimg = imgData.getBimgData()[1]
            self:updateDraw()
            return self
        end,

        setBg = function(self, bg, _x, _y)
            x = _x or x
            y = _y or y
            imgData.bg(bg, x, y)
            bimg = imgData.getBimgData()[1]
            self:updateDraw()
            return self
        end,

        setFg = function(self, fg, _x, _y)
            x = _x or x
            y = _y or y
            imgData.fg(fg, x, y)
            bimg = imgData.getBimgData()[1]
            self:updateDraw()
            return self
        end,

        getImageSize = function(self)
            return imgData.getSize()
        end,

        setImageSize = function(self, w, h)
            imgData.setSize(w, h)
            bimg = imgData.getBimgData()[1]
            self:updateDraw()
            return self
        end,

        clear = function(self)
            imgData = bimgLib()
            bimg = nil
            self:updateDraw()
            return self
        end,

        getImage = function(self)
            return imgData.getBimgData()
        end,

        draw = function(self)
            if (base.draw(self)) then
                if (self.parent ~= nil) then
                    local obx, oby = self:getAnchorPosition()
                    local w,h = self:getSize()
                    if(bimg~=nil)then
                        for k,v in pairs(bimg)do
                            if(k<=h-yOffset)and(k+yOffset>=1)then
                                self.parent:blit(obx+xOffset, oby+k-1+yOffset, v[1], v[2], v[3])
                            end
                        end
                    end
                end
            end
        end,

        init = function(self)
            self.bgColor = self.parent:getTheme("GraphicBG")
        end,
    }

    return setmetatable(object, base)
end