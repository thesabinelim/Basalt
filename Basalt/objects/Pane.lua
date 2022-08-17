local Object = require("Object")

return function(name)
    -- Pane
    local base = Object(name)
    local objectType = "Pane"

    local object = {
        init = function(self)
            self.bgColor = self.parent:getTheme("PaneBG")
            self.fgColor = self.parent:getTheme("PaneBG")
        end,
        getType = function(self)
            return objectType
        end;


    }

    return setmetatable(object, base)
end