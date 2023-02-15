local utils = require("utils")
local tHex = require("tHex")

return function(name, basalt)
    local base = basalt.getObject("VisualObject")(name, basalt)
    local objectType = "Treeview"
    local object = {}

    base:setSize(25, 10)
    base:setZIndex(5)

    local scrollable = true
    local xOffset, yOffset = 0, 0

    local function recreateList(root, x, y)
        local add = 1
        for _, v in pairs(root.getList())do
            base:addText(x, y, v.getName())
            y = y + 1
            local branch = v.getList()
            if(branch~=nil)and(#branch>0)then
                local subAdd = recreateList(v, x + 1, y)
                y = y + #branch + subAdd
                add = #branch + subAdd - 1
            end
        end
        return add
    end

    local function branchTree(name, expandable, fgCol, bgCol)
        local list = {}
        return {
            add = function(branchName, _expandable, fg, bg)
                table.insert(list, branchTree(branchName, _expandable, fg, bg))
            end,
            remove = function(id)
                table.remove(list, id)
            end,
            updateList = function(newList)
                list = newList
            end,
            getList = function() return list end,
            getBranch = function(id) return list[id] end,
            getName = function() return name end,
            setExpandable = function(_expandable) expandable = _expandable end,
            setBackground = function(bg)
                bgCol = bg
            end,
            setForeground = function(fg)
                fgCol = fg
            end,
        }
    end

    local root = branchTree("root", true, base:getForeground(), base:getBackground())

    object = {
        init = function(self)
            local parent = self:getParent()
            self:listenEvent("mouse_click")
            self:listenEvent("mouse_drag")
            self:listenEvent("mouse_scroll")
            return base.init(self)
        end,

        addBranch = function(self, name, expandable)
            root.add(name, expandable, self:getForeground(), self:getBackground())
            return self
        end,

        getBranch = function(self, id)
            return root.getBranch(id)
        end,

        getType = function(self)
            return objectType
        end,

        getBase = function(self)
            return base
        end,

        setScrollable = function(self, scroll)
            scrollable = scroll
            if(scroll==nil)then scrollable = true end
            return self
        end,

        mouseHandler = function(self, button, x, y)
            if(base.mouseHandler(self, button, x, y))then

                self:updateDraw()
                return true
            end
        end,

        scrollHandler = function(self, dir, x, y)
            if(base.scrollHandler(self, dir, x, y))then
                
                return true
            end
            return false
        end,

        draw = function(self)
            base.draw(self)
            self:addDraw("treeview", function()
                local parent = self:getParent()
                local obx, oby = self:getPosition()
                local w,h = self:getSize()
                
                --local itemSelectedBG, itemSelectedFG = self:getSelectionColor()
                recreateList(root, 1, 1)

            end)
        end,
    }

    object.__index = object
    return setmetatable(object, base)
end