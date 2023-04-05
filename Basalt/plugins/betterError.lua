local utils = require("utils")
local wrapText = utils.wrapText

return {
    basalt = function(basalt)
        local frame
        local errorList
        return {
            basaltError = function(err)
                if(frame==nil)then
                    local mainFrame = basalt.getMainFrame()
                    local w, h = mainFrame:getSize()
                    frame = mainFrame:addMovableFrame():setSize(w-20, h-10):setBackground(colors.lightGray):setForeground(colors.white):setZIndex(500)
                    frame:addPane():setSize(w, 1):setPosition(1, 1):setBackground(colors.black):setForeground(colors.white)
                    frame:setPosition(w/2-frame:getWidth()/2, h/2-frame:getHeight()/2):setBorder(colors.black)
                    frame:addLabel():setText("Basalt Unexpected Error"):setPosition(2, 1):setBackground(colors.black):setForeground(colors.white)
                    errorList = frame:addList():setSize(frame:getWidth()-2, frame:getHeight()-3):setPosition(2, 3):setBackground(colors.lightGray):setForeground(colors.white):setSelectionColor(colors.lightGray, colors.gray)
                    frame:addButton():setText("x"):setPosition(frame:getWidth(), 1):setSize(1, 1):setBackground(colors.black):setForeground(colors.red):onClick(function() 
                        frame:hide()
                    end)
                end
                frame:show()
                local err = wrapText(err, frame:getWidth()-2)
                for i=1, #err do
                    errorList:addItem(err[i])
                end
                errorList:addItem("----------------------------------------")
            end
        }
    end
}