local sub,rep = string.sub,string.rep

return function()
    local w, h = 0,0
    local t,fg,bg = {}, {}, {}
    local x, y = 1,1

    local function recalculateSize()
        for y=1,h do
            if(t[y]==nil)then
                t[y] = rep(" ", w)
            else
                t[y] = t[y]..rep(" ", w-#t[y])
            end
            if(fg[y]==nil)then
                fg[y] = rep("0", w)
            else
                fg[y] = fg[y]..rep("0", w-#fg[y])
            end
            if(bg[y]==nil)then
                bg[y] = rep("f", w)
            else
                bg[y] = bg[y]..rep("f", w-#bg[y])
            end
        end
    end

    local addText = function(text, _x, _y)
        x = _x or x
        y = _y or y
        if(t[y]==nil)then
            t[y] = rep(" ", x-1)..text..rep(" ", w-(#text+x))
        else
            t[y] = sub(t[y], 1, x-1)..rep(" ", x-#t[y])..text..sub(t[y], x+#text, w)
        end
        if(#t[y]>w)then w = #t[y] end
        if(y > h)then h = y end  
        recalculateSize()
    end

    local addBg = function(b, _x, _y)
        x = _x or x
        y = _y or y
        if(bg[y]==nil)then
            bg[y] = rep("f", x-1)..b..rep("f", w-(#b+x))
        else
            bg[y] = sub(bg[y], 1, x-1)..rep("f", x-#bg[y])..b..sub(bg[y], x+#b, w)
        end
        if(#bg[y]>w)then w = #bg[y] end
        if(y > h)then h = y end  
        recalculateSize()
    end

    local addFg = function(f, _x, _y)
        x = _x or x
        y = _y or y
        if(fg[y]==nil)then
            fg[y] = rep("0", x-1)..f..rep("0", w-(#f+x))
        else
            fg[y] = sub(fg[y], 1, x-1)..rep("0", x-#fg[y])..f..sub(fg[y], x+#f, w)
        end
        if(#fg[y]>w)then w = #fg[y] end
        if(y > h)then h = y end  
        recalculateSize()
    end

    local public = {
        blit = function(text, fgCol, bgCol, x, y)
            addText(text, x, y)
            addFg(fgCol, x, y)
            addBg(bgCol, x, y)
        end,
        text = addText,
        fg = addFg,
        bg = addBg,

        getSize = function()
            return w, h
        end,

        setSize = function(_w, _h)
            local nt,nfg,nbg = {}, {}, {}
            for _y=1,_h do
                if(t[_y]~=nil)then
                    nt[_y] = sub(t[_y], 1, _w)..rep(" ", _w - w)
                else
                    nt[_y] = rep(" ", _w)
                end
                if(fg[_y]~=nil)then
                    nfg[_y] = sub(fg[_y], 1, _w)..rep("0", _w - w)
                else
                    nfg[_y] = rep("0", _w)
                end
                if(bg[_y]~=nil)then
                    nbg[_y] = sub(bg[_y], 1, _w)..rep("f", _w - w)
                else
                    nbg[_y] = rep("f", _w)
                end
            end
            t, fg, bg = nt, nfg, nbg
            w, h = _w, _h
        end,

        getBimgData = function()
            local data = {}
            for k,v in pairs(t)do
                data[k] = {t[k], fg[k], bg[k]}
            end
            return {[1]=data,creator="Basalt Graphic 1.0",version="1.0.0"}
        end
    }
    return public
end