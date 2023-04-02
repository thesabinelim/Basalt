local max,min,sub,rep = math.max,math.min,string.sub,string.rep

return function(name, basalt)
    local base = basalt.getObject("Frame")(name, basalt)
    local objectType = "ScrollableFrame"
    local parent

    local direction = 0

    local function getHorizontalScrollAmount(self)
        local amount = 0
        local objects = self:getObjects()
        for _, value in pairs(objects) do
            for _, b in pairs(value) do
                if(b.getWidth~=nil)and(b.getX~=nil)then
                    local h, y = b:getWidth(), b:getX()
                    local width = self:getWidth()
                    if (h + y - width >= amount) then
                        amount = max(h + y - width, 0)
                    end
                end
            end
        end
        return amount
    end

    local function getVerticalScrollAmount(self)
        local amount = 0
        local objects = self:getObjects()
        for _, b in pairs(objects) do
            if(b.element.getHeight~=nil)and(b.element.getY~=nil)then
                local h, y = b.element:getHeight(), b.element:getY()
                local height = self:getHeight()
                if (h + y - height >= amount) then
                    amount = max(h + y - height, 0)
                end
            end
        end
        return amount
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
        
        load = function(self)
            base.load(self)
            self:listenEvent("mouse_scroll")
        end,

        setParent = function(self, p, ...)
            base.setParent(self, p, ...)
            parent = p
            return self
        end,

        scrollHandler = function(self, dir, x, y)
            if(base.scrollHandler(self, dir, x, y))then
                local xO, yO = self:getOffset()
                if(direction==1)then
                    self:setOffset(math.min(0, math.max(xO - dir, -(getHorizontalScrollAmount(self)-1))), yO)
                elseif(direction==0)then
                    self:setOffset(xO, math.min(0, math.max(yO - dir, -(getVerticalScrollAmount(self)-1))))
                end
                self:updateDraw()
                return true
            end
        end,
    }

    object.__index = object
    return setmetatable(object, base)
end