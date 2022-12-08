local args = {...}   
local plugins = {} 

local dir = fs.getDir(args[2] or "Basalt")
for _,v in pairs(fs.list(fs.combine(dir, "plugins")))do
    local newPlugin = require(v:gsub(".lua", ""))
    if(type(newPlugin)=="table")then
        for a,b in pairs(newPlugin)do
            if(type(a)=="string")then
                if(plugins[a]==nil)then plugins[a] = {} end
                table.insert(plugins[a], b)
            end
        end
    end
end

local function get(name)
    return plugins[name]
end

return {
    get = get,
    addPlugins = function(objects)
        for k,v in pairs(objects)do
            local plugList = get(k)
            if(plugList~=nil)then
                objects[k] = function(...)
                    local moddedObject = v(...)
                    for a,b in pairs(plugList)do
                        local ext = b(moddedObject, ...)
                        ext.__index = ext
                        moddedObject = setmetatable(ext, moddedObject)
                    end
                    return moddedObject
                end
            end
        end
        return objects
    end
}