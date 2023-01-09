local utils = require("utils")
local rpairs = utils.rpairs
local tableCount = utils.tableCount

return function(name, basalt)
    local base = basalt.getObject("VisualObject")(name, basalt)
    local objectType = "Container"

    local objects = {}
    local objZIndex = {}

    local events = {}
    local eventZIndex = {}

    local container = {}
    local activeEvents = {}

    local focusedObject

    local function getObject(self, name)
        if(type(name)=="table")then name = name:getName() end
        for _, value in pairs(objects) do
            for _, b in pairs(value) do
                if (b:getName() == name) then
                    return b
                end
            end
        end
    end

    local function getDeepObject(self, name)
        local o = getObject(name)
        if(o~=nil)then return o end
        for _, value in pairs(objects) do
            for _, b in pairs(value) do
                if (b:getType() == "Container") then
                    local oF = b:getDeepObject(name)
                    if(oF~=nil)then return oF end
                end
            end
        end
    end

    local function addObject(self, obj)
        local zIndex = obj:getZIndex()
        if (getObject(obj:getName()) ~= nil) then
            return nil
        end
        if (objects[zIndex] == nil) then
            table.insert(objZIndex, zIndex)
            table.sort(objZIndex)
            objects[zIndex] = {}
        end
        obj:setParent(self, true)
        if(obj.init~=nil)then
            obj:init()
        end
        if(obj.load~=nil)then
            obj:load()
        end
        if(obj.draw~=nil)then
            obj:draw()
        end
        table.insert(objects[zIndex], obj)
        return obj
    end

    local function removeEvents(self, obj)
        local parent = self:getParent()
        for a, b in pairs(events) do
            for c, d in pairs(b) do
                for key, value in pairs(d) do
                    if (value == obj) then
                        table.remove(events[a][c], key)
                        if(parent~=nil)then
                            if(tableCount(events[a])<=0)then
                                parent:removeEvent(a, self)
                            end
                        end
                    end
                end
            end
        end
    end

    local function removeObject(self, obj)
        for a, b in pairs(objects) do
            for key, value in pairs(b) do
                if(type(obj)=="string")then
                    if (value:getName() == obj) then
                        table.remove(objects[a], key)
                        removeEvents(container, value)
                        self:updateDraw()
                        return true
                    end
                else
                    if (value == obj) then
                        table.remove(objects[a], key)
                        removeEvents(container, value)
                        self:updateDraw()
                        return true
                    end
                end
            end
        end
        return false
    end

    local function getEvent(self, event, name)
        for _, value in pairs(events[event]) do
            for _, b in pairs(value) do
                if (b:getName() == name) then
                    return b
                end
            end
        end
    end

    local function addEvent(self, event, obj)
        local parent = self:getParent()
        local zIndex = obj:getZIndex()
        if(events[event]==nil)then events[event] = {} end
        if(eventZIndex[event]==nil)then eventZIndex[event] = {} end
        if (getEvent(self, event, obj:getName()) ~= nil) then
            return nil
        end
        if(parent~=nil)then
            parent:addEvent(event, self)
        end
        activeEvents[event] = true
        if (events[event][zIndex] == nil) then
            table.insert(eventZIndex[event], zIndex)
            table.sort(eventZIndex[event])
            events[event][zIndex] = {}
        end
        table.insert(events[event][zIndex], obj)
    end

    local function removeEvent(self, event, obj)
        local parent = self:getParent()
        if(events[event]~=nil)then
            for a, b in pairs(events[event]) do
                for key, value in pairs(b) do
                    if (value == obj) then
                        table.remove(events[event][a], key)
                        if(#events[event][a]<=0)then
                            events[event][a] = nil
                            if(tableCount(events[event])<=0)then
                                activeEvents[event] = false
                                if(parent~=nil)then
                                    parent:removeEvent(event, self)
                                end
                            end
                        end
                        return true
                    end
                end
            end
        end
        return false
    end

    local function getObjects(self)
        return objects, objZIndex
    end

    container = {
        getType = function()
            return objectType
        end,

        getBase = function(self)
            return base
        end,  
        
        isType = function(self, t)
            return objectType==t or base.isType~=nil and base.isType(t) or false
        end,
        
        setSize = function(self, ...)
            base.setSize(self, ...)
            self:customEventHandler("basalt_FrameResize")
            return self
        end,

        setPosition = function(self, ...)
            base.setPosition(self, ...)
            self:customEventHandler("basalt_FrameReposition")
            return self
        end,

        setImportant = function(self, obj)
            for a, b in pairs(events) do
                for c, d in pairs(b) do
                    for key, value in pairs(d) do
                        if (value == obj) then
                            table.remove(events[a][c], key)
                            table.insert(events[a][c], value)
                        end
                    end
                end
            end
            for a, b in pairs(objects) do
                for key, value in pairs(b) do
                    if(type(obj)=="string")then
                        if (value:getName() == obj) then
                            table.remove(objects[a], key)
                            table.insert(objects[a], value)
                            self:updateDraw()
                            return true
                        end
                    else
                        if (value == obj) then
                            table.remove(objects[a], key)
                            table.insert(objects[a], value)
                            self:updateDraw()
                            return true
                        end
                    end
                end
            end
            return false
        end,

        removeFocusedObject = function(self)
            if(focusedObject~=nil)then
                if(getObject(self, focusedObject)~=nil)then
                    focusedObject:loseFocusHandler()
                end
            end
            focusedObject = nil
            return self
        end,

        setFocusedObject = function(self, obj)
            if(focusedObject~=obj)then
                if(focusedObject~=nil)then
                    if(getObject(self, focusedObject)~=nil)then
                        focusedObject:loseFocusHandler()
                    end
                end
                if(obj~=nil)then
                    if(getObject(self, obj)~=nil)then
                        obj:getFocusHandler()
                    end
                end
                focusedObject = obj
            end
            return self
        end,

        getFocusedObject = function(self)
            return focusedObject
        end,
        
        getObject = getObject,
        getObjects = getObjects,
        getDeepObject = getDeepObject,
        addObject = addObject,
        removeObject = removeObject,
        getEvent = getEvent,
        addEvent = addEvent,
        removeEvent = removeEvent,

        listenEvent = function(self, event)
            activeEvents[event] = true
            if(events[event]==nil)then events[event] = {} end
            if(eventZIndex[event]==nil)then eventZIndex[event] = {} end
            local parent = self:getParent()
            if(parent~=nil)then
                parent:addEvent(event, self)
            end
            return self
        end,

        customEventHandler = function(self, ...)
            base.customEventHandler(self, ...)
            for _, index in rpairs(objZIndex) do
                if (objects[index] ~= nil) then
                    for _, value in pairs(objects[index]) do
                        if (value.customEventHandler ~= nil) then
                            value:customEventHandler(...)
                        end
                    end
                end
            end
        end,

        loseFocusHandler = function(self)
            base.loseFocusHandler(self)
            if(focusedObject~=nil)then focusedObject:loseFocusHandler() focusedObject = nil end
        end,

        getBasalt = function(self)
            return basalt
        end,

        eventHandler = function(self, ...)
            if(events["other_event"]~=nil)then
                if(base.eventHandler~=nil)then
                    base.eventHandler(self, ...)
                    for _, index in ipairs(eventZIndex["other_event"]) do
                        if (events["other_event"][index] ~= nil) then
                            for _, value in rpairs(events["other_event"][index]) do
                                if (value.eventHandler ~= nil) then
                                    value.eventHandler(value, ...)
                                end
                            end
                        end
                    end
                end
            end
        end,
    }

    for k,v in pairs({mouse_click={"mouseHandler", true},mouse_up={"mouseUpHandler", false},mouse_drag={"dragHandler", false},mouse_scroll={"scrollHandler", true},mouse_hover={"hoverHandler", false}})do
        container[v[1]] = function(self, ...)
            if(events[k]~=nil)then
                if(base[v[1]]~=nil)then
                    if(base[v[1]](self, ...))then
                        for _, index in ipairs(eventZIndex[k]) do
                            if (events[k][index] ~= nil) then
                                for _, value in rpairs(events[k][index]) do
                                    if (value[v[1]] ~= nil) then
                                        if (value[v[1]](value, ...)) then
                                            if(k~="other_event")then             
                                                return true
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        if(v[2])then
                            self:removeFocusedObject()
                        end
                        return true
                    end
                end
            end
        end
    end

    for k,v in pairs({key="keyHandler",key_up="keyUpHandler",char="charHandler"})do
        container[v] = function(self, ...)
            if (self:isFocused())then
                local val = self:getEventSystem():sendEvent(k, self, k, ...)
                if(val==false)then return false end
                if(events[k]~=nil)then
                    for _, index in pairs(eventZIndex[k]) do
                        if (events[k][index] ~= nil) then
                            for _, value in rpairs(events[k][index]) do
                                if (value[v] ~= nil) then
                                    if (value[v](value, ...)) then
                                        return true
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    for k,v in pairs(basalt.getObjects())do
        container["add"..k] = function(self, name)
            return addObject(self, v(name, basalt))
        end
    end

    container.__index = container
    return setmetatable(container, base)
end