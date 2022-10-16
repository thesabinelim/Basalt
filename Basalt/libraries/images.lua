local sub,floor = string.sub,math.floor

local function loadNFPAsBimg(path)
    return {[1]={{}, {}, paintutils.loadImage(path)}}, "bimg"
end

local function loadNFP(path)
    return paintutils.loadImage(path), "nfp"
end

local function loadBIMG(path)
    local f = fs.open(path, "rb")
    local content = textutils.unserialize(f.readAll())
    f.close()
    if(content~=nil)then
        return content, "bimg"
    end
end

local function loadBBF(path)

end

local function loadBBFAsBimg(path)

end

local function loadImage(path, f)
    if(f==nil)then
        if(path:find(".bimg"))then
            return loadBIMG(path)
        elseif(path:find(".bbf"))then
            return loadBBF(path)
        else
            return loadNFP(path)
        end
    end
    -- ...
end

local function loadImageAsBimg(path, f)
    if(f==nil)then
        if(path:find(".bimg"))then
            return loadBIMG(path)
        elseif(path:find(".bbf"))then
            return loadBBFAsBimg(path)
        else
            return loadNFPAsBimg(path)
        end
    end
end

local function resizeBIMG(source, w, h)
    local oW, oH = #source[1][1][1], #source[1]
    local newImg = {{}}
    for k,v in pairs(source)do if(k~=1)then newImg[k] = v end end
    local img = source[1]
    for y=1, h do
        local xT,xFG,xBG = "","",""
        local yR = floor(y / h * oH + 0.5)
        if(img[yR]~=nil)then
            for x=1, w do
                local xR = floor(x / w * oW + 0.5)
                xT = xT..sub(img[yR][1], xR,xR)
                xFG = xFG..sub(img[yR][2], xR,xR)
                xBG = xBG..sub(img[yR][3], xR,xR)
            end
            table.insert(newImg[1], {xT, xFG, xBG})
        end
    end
    return newImg
end

return {
    loadNFP = loadNFP,
    loadBIMG = loadBIMG,
    loadImage = loadImage,
    resizeBIMG = resizeBIMG,
    loadImageAsBimg = loadImageAsBimg,

}