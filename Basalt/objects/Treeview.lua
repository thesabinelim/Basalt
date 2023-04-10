local utils = require("utils")
local tHex = require("tHex")

return function(name, basalt)
    local base = basalt.getObject("ChangeableObject")(name, basalt)
    local objectType = "Treeview"

    local nodes = {}
    local itemSelectedBG = colors.black
    local itemSelectedFG = colors.lightGray
    local selectionColorActive = true
    local textAlign = "left"
    local xOffset, yOffset = 0, 0
    local scrollable = true

    base:setSize(16, 8)
    base:setZIndex(5)

    local Node = {}
    Node.__index = Node

    function Node.new(text, expandable)
        local self = setmetatable({}, Node)
        self.text = text
        self.expandable = expandable or false
        self.expanded = false
        self.parent = nil
        self.children = {}
        return self
    end

    function Node:addChild(text, expandable)
        local childNode = Node.new(text, expandable)
        childNode.parent = self
        table.insert(self.children, childNode)
        return childNode
    end

    function Node:setExpanded(expanded)
        self.expanded = expanded
        base:updateDraw()
    end

    function Node:isExpanded()
        return self.expanded
    end

    function Node:setExpandable(expandable)
        self.expandable = expandable
        base:updateDraw()
    end

    function Node:isExpandable()
        return self.expandable
    end

    function Node:removeChild(index)
        table.remove(self.children, index)
    end

    function Node:findChildrenByText(searchText)
        local foundNodes = {}
        for _, child in ipairs(self.children) do
            if child.text == searchText then
                table.insert(foundNodes, child)
            end
        end
        return foundNodes
    end

    local object = {
        init = function(self)
            local parent = self:getParent()
            self:listenEvent("mouse_click")
            self:listenEvent("mouse_scroll")
            return base.init(self)
        end,

        getBase = function(self)
            return base
        end,

        getType = function(self)
            return objectType
        end,

        isType = function(self, t)
            return objectType == t or base.isType ~= nil and base.isType(t) or false
        end,

        setOffset = function(self, x, y)
            xOffset = x
            yOffset = y
            return self
        end,

        getOffset = function(self)
            return xOffset, yOffset
        end,

        setScrollable = function(self, scroll)
            scrollable = scroll
            return self
        end,

        setSelectionColor = function(self, bgCol, fgCol, active)
            itemSelectedBG = bgCol or self:getBackground()
            itemSelectedFG = fgCol or self:getForeground()
            selectionColorActive = active~=nil and active or true
            self:updateDraw()
            return self
        end,

        getSelectionColor = function(self)
            return itemSelectedBG, itemSelectedFG
        end,

        isSelectionColorActive = function(self)
            return selectionColorActive
        end,

        addNode = function(self, text, parent, expandable)
            local newNode = Node.new(text, expandable)
            if parent then
                parent:addChild(newNode)
            else
                table.insert(nodes, newNode)
            end
            self:updateDraw()
            return newNode
        end,

        removeNode = function(self, node)
            if node.parent then
                for i, child in ipairs(node.parent.children) do
                    if child == node then
                        node.parent:removeChild(i)
                        break
                    end
                end
            else
                for i, root in ipairs(nodes) do
                    if root == node then
                        table.remove(nodes, i)
                        break
                    end
                end
            end
            self:updateDraw()
        end,

        mouseHandler = function(self, button, x, y)
            if base.mouseHandler(self, button, x, y) then
                local currentLine = 1 - yOffset
                local obx, oby = self:getAbsolutePosition()
                local w, h = self:getSize()
                local function checkNodeClick(node, level)
                    if y == oby+currentLine-1 then
                        if x >= obx and x < obx + w then
                            node.expanded = not node.expanded
                            self:setValue(node)
                            self:updateDraw()
                            return true
                        end
                    end
                    currentLine = currentLine + 1
                    if node.expanded then
                        for _, child in ipairs(node.children) do
                            if checkNodeClick(child, level + 1) then
                                return true
                            end
                        end
                    end
                    return false
                end
        
                for _, root in ipairs(nodes) do
                    if checkNodeClick(root, 1) then
                        return true
                    end
                end
            end
        end,

        scrollHandler = function(self, dir, x, y)
            if base.scrollHandler(self, dir, x, y) then
                if scrollable then
                    local _, h = self:getSize()
                    yOffset = yOffset + dir
        
                    if yOffset < 0 then
                        yOffset = 0
                    end
        
                    if dir >= 1 then
                        local visibleLines = 0
                        local function countVisibleLines(node, level)
                            visibleLines = visibleLines + 1
                            if node.expanded then
                                for _, child in ipairs(node.children) do
                                    countVisibleLines(child, level + 1)
                                end
                            end
                        end
        
                        for _, root in ipairs(nodes) do
                            countVisibleLines(root, 1)
                        end
        
                        if visibleLines > h then
                            if yOffset > visibleLines - h then
                                yOffset = visibleLines - h
                            end
                        else
                            yOffset = yOffset - 1
                        end
                    end
                    self:updateDraw()
                end
                return true
            end
            return false
        end,

        draw = function(self)
            base.draw(self)
            self:addDraw("treeview", function()
                local currentLine = 1 - yOffset
                local lastClickedNode = self:getValue()
                local function drawNode(node, level)
                    local w, h = self:getSize()
        
                    if currentLine >= 1 and currentLine <= h then
                        local bg = (node == lastClickedNode) and itemSelectedBG or self:getBackground()
                        local fg = (node == lastClickedNode) and itemSelectedFG or self:getForeground()
        
                        self:addBlit(1 + level + xOffset, currentLine, node.text, tHex[fg]:rep(#node.text), tHex[bg]:rep(#node.text))
                    end
        
                    currentLine = currentLine + 1
        
                    if(node.expandable)then
                        if node.expanded then
                            for _, child in ipairs(node.children) do
                                drawNode(child, level + 1)
                            end
                        end
                    else
                        for _, child in ipairs(node.children) do
                            drawNode(child, level + 1)
                        end
                    end
                end
        
                for _, root in ipairs(nodes) do
                    drawNode(root, 1)
                end
            end)
        end,


    }

    object.__index = object
    return setmetatable(object, base)
end