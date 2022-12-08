local VisualObject = require("VisualObject")
local utils = require("utils")
local rpairs = utils.rpairs

return function(name, basalt)
    local base = VisualObject(name, basalt)
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
                        return true;
                    end
                else
                    if (value == obj) then
                        table.remove(objects[a], key)
                        removeEvents(container, value)
                        self:updateDraw()
                        return true;
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
        return obj
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
                            if(parent~=nil)then
                                if(tableCount(events[event])<=0)then
                                    activeEvents[event] = false
                                    parent:removeEvent(event, self)
                                end
                            end
                        end
                        return true;
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

        removeFocusedObject = function(self)
            if(focusedObject~=nil)then
                if(getObject(focusedObject)~=nil)then
                    focusedObject:loseFocusHandler()
                end
            end
            focusedObject = nil
            return self
        end,

        setFocusedObject = function(self, obj)
            if(focusedObject~=obj)then
                if(focusedObject~=nil)then
                    if(getObject(focusedObject)~=nil)then
                        focusedObject:loseFocusHandler()
                    end
                end
                if(obj~=nil)then
                    if(getObject(obj)~=nil)then
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

        getBasalt = function(self)
            return basalt
        end
    }

    for k,v in pairs({mouse_click="mouseHandler",mouse_up="mouseUpHandler",mouse_drag="dragHandler",mouse_scroll="scrollHandler",mouse_hover="hoverHandler", other_event="eventHandler"})do
        container[v] = function(self, ...)
            if(base[v]~=nil)then
                if(base[v](self, ...))then
                    if(events[k]~=nil)then
                        for _, index in ipairs(eventZIndex[k]) do
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
                    self:removeFocusedObject()
                    return true
                end
            end
            return false
        end
    end


    for k,v in pairs({key="keyHandler",key_up="keyUpHandler",char="charHandler"})do
        container[v] = function(self, ...)
            if (self:isFocused())or(self:getParent()==nil)then
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