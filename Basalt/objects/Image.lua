local Object = require("Object")
local xmlValue = require("utils").getValueFromXML
local images = require("images")

local unpack,sub = table.unpack,string.sub
return function(name)
    -- Image
    local base = Object(name)
    local objectType = "Image"
    base:setZIndex(2)
    local originalImage
    local image
    local format = "nfp"

    local object = {
        init = function(self)
            self.bgColor = self.parent:getTheme("ImageBG")
        end,
        getType = function(self)
            return objectType
        end;

        loadImage = function(self, path, f)
            originalImage, _format = images.loadImage(path, f)
            image = originalImage
            if(_format~=nil)then
                format = _format
            end
            self:updateDraw()
            return self
        end;

        setImage = function(self, data, _format)
            originalImage = data
            format = _format
        end,

        getImageData = function(self)
            return image
        end,

        getImageSize = function(self)
            return #image[1][1][1], #image[1]
        end,

        resizeImage = function(self, w, h)
            if(format=="bimg")then
                image = images.resizeBIMG(originalImage, w, h)
                self:updateDraw()
            end
            return self
        end,

        setValuesByXMLData = function(self, data)
            base.setValuesByXMLData(self, data)
            if(xmlValue("path", data)~=nil)then self:loadImage(xmlValue("path", data)) end
            return self
        end,

        draw = function(self)
            if (base.draw(self)) then
                if (image ~= nil) then
                    local obx, oby = self:getAnchorPosition()
                    local w,h = self:getSize()
                    if(format=="nfp")then
                        
                    elseif(format=="bimg")then
                        for y,v in ipairs(image[1])do
                            local t, f, b  = unpack(v)
                            t = sub(t, 1,w)
                            f = sub(f, 1,w)
                            b = sub(b, 1,w)
                            self.parent:blit(obx, oby+y-1, t, f, b)
                            if(y==h)then break end
                        end
                    end
                end
            end
        end,
    }

    return setmetatable(object, base)
end