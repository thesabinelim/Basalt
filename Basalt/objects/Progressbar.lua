return function(name, basalt)
    local base = basalt.getObject("ChangeableObject")(name, basalt)
    local objectType = "Progressbar"

    local progress = 0

    base:setZIndex(5)
    base:setValue(false)
    base:setSize(25, 3)

    local activeBarColor = colors.black
    local activeBarSymbol = ""
    local activeBarSymbolCol = colors.white
    local bgBarSymbol = ""
    local direction = 0

    local object = {
        getType = function(self)
            return objectType
        end,

        setDirection = function(self, dir)
            direction = dir
            self:updateDraw()
            return self
        end,

        setProgressBar = function(self, color, symbol, symbolcolor)
            activeBarColor = color or activeBarColor
            activeBarSymbol = symbol or activeBarSymbol
            activeBarSymbolCol = symbolcolor or activeBarSymbolCol
            self:updateDraw()
            return self
        end,

        setBackgroundSymbol = function(self, symbol)
            bgBarSymbol = symbol:sub(1, 1)
            self:updateDraw()
            return self
        end,

        setProgress = function(self, value)
            if (value >= 0) and (value <= 100) and (progress ~= value) then
                progress = value
                self:setValue(progress)
                if (progress == 100) then
                    self:progressDoneHandler()
                end
            end
            self:updateDraw()
            return self
        end,

        getProgress = function(self)
            return progress
        end,

        onProgressDone = function(self, f)
            self:registerEvent("progress_done", f)
            return self
        end,

        progressDoneHandler = function(self)
            self:sendEvent("progress_done", self)
        end,

        draw = function(self)
            base.draw(self)
            self:addDraw("progressbar", function()
                local parent = self:getParent()
                local obx, oby = self:getPosition()
                local w,h = self:getSize()
                local bgCol,fgCol = self:getBackground(), self:getForeground()
                if(bgCol~=false)then parent:drawBackgroundBox(obx, oby, w, h, bgCol) end
                if(bgBarSymbol~="")then parent:drawTextBox(obx, oby, w, h, bgBarSymbol) end
                if(fgCol~=false)then parent:drawForegroundBox(obx, oby, w, h, fgCol) end
                if (direction == 1) then
                    parent:drawBackgroundBox(obx, oby, w, h / 100 * progress, activeBarColor)
                    parent:drawForegroundBox(obx, oby, w, h / 100 * progress, activeBarSymbolCol)
                    parent:drawTextBox(obx, oby, w, h / 100 * progress, activeBarSymbol)
                elseif (direction == 2) then
                    parent:drawBackgroundBox(obx, oby + math.ceil(h - h / 100 * progress), w, h / 100 * progress, activeBarColor)
                    parent:drawForegroundBox(obx, oby + math.ceil(h - h / 100 * progress), w, h / 100 * progress, activeBarSymbolCol)
                    parent:drawTextBox(obx, oby + math.ceil(h - h / 100 * progress), w, h / 100 * progress, activeBarSymbol)
                elseif (direction == 3) then
                    parent:drawBackgroundBox(obx + math.ceil(w - w / 100 * progress), oby, w / 100 * progress, h, activeBarColor)
                    parent:drawForegroundBox(obx + math.ceil(w - w / 100 * progress), oby, w / 100 * progress, h, activeBarSymbolCol)
                    parent:drawTextBox(obx + math.ceil(w - w / 100 * progress), oby, w / 100 * progress, h, activeBarSymbol)
                else
                    parent:drawBackgroundBox(obx, oby, w / 100 * progress, h, activeBarColor)
                    parent:drawForegroundBox(obx, oby, w / 100 * progress, h, activeBarSymbolCol)
                    parent:drawTextBox(obx, oby, w / 100 * progress, h, activeBarSymbol)
                end
            end)
        end,

    }

    object.__index = object
    return setmetatable(object, base)
end