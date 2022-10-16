local Object = require("Object")
local utils = require("utils")
local xmlValue = utils.getValueFromXML
local tHex = require("tHex")

return function(name)
    -- Graph
    local base = Object(name)
    local objectType = "Graph"

    local graphAmount = {}
    local lastTime = 0

    base:setZIndex(5)

    local object = {
        init = function(self)
            if(base.init(self))then
                self.bgColor = self.parent:getTheme("GraphBG")
                self.fgColor = self.parent:getTheme("GraphText")    
            end    
        end,
        getType = function(self)
            return objectType
        end;


        setValuesByXMLData = function(self, data)
            base.setValuesByXMLData(self, data)

            return self
        end,

        add = function(self, val)
            
            return self
        end,

        clear = function(self)

            return self
        end,

        draw = function(self)
            if (base.draw(self)) then

            end
        end,

    }
    return setmetatable(object, base)
end