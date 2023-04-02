local function line(x1, y1, x2, y2)
    local points = {}

    if x1 == x2 and y1 == y2 then return {x=x1, y=y2} end

    local deltaX = x2 - x1
    local deltaY = y2 - y1
    local isSteep = math.abs(deltaY) > math.abs(deltaX)

    if isSteep then
        x1, y1 = y1, x1
        x2, y2 = y2, x2
    end

    if x1 > x2 then
        x1, x2 = x2, x1
        y1, y2 = y2, y1
    end

    deltaX = x2 - x1
    deltaY = y2 - y1
    local error = 0
    local deltaError = math.abs(deltaY / deltaX)

    local y = y1
    for x = x1, x2 do
        if isSteep then
            table.insert(points, {x=y, y=x})
        else
            table.insert(points, {x=x, y=y})
        end

        error = error + deltaError
        if error >= 0.5 then
            if y2 > y1 then
                y = y + 1
            else
                y = y - 1
            end
            error = error - 1
        end
    end

    return points
end

local function ellipse(x, y, radiusX, radiusY)
    local points = {}

    local xVal = 0
    local yVal = radiusY

    local aSquared = radiusX * radiusX
    local bSquared = radiusY * radiusY
    local twoASquared = 2 * aSquared
    local twoBSquared = 2 * bSquared
    local p = bSquared - aSquared * radiusY + 0.25 * aSquared

    while twoBSquared * xVal <= twoASquared * yVal do
        table.insert(points, {x=x + xVal, y=y + yVal})
        table.insert(points, {x=x - xVal, y=y + yVal})
        table.insert(points, {x=x + xVal, y=y - yVal})
        table.insert(points, {x=x - xVal, y=y - yVal})

        xVal = xVal + 1
        if p < 0 then
            p = p + twoBSquared * xVal + bSquared
        else
            yVal = yVal - 1
            p = p + twoBSquared * xVal - twoASquared * yVal + bSquared
        end
    end

    p = bSquared * (xVal + 0.5) * (xVal + 0.5) + aSquared * (yVal - 1) * (yVal - 1) - aSquared * bSquared
    while yVal >= 0 do
        table.insert(points, {x=x + xVal, y=y + yVal})
        table.insert(points, {x=x - xVal, y=y + yVal})
        table.insert(points, {x=x + xVal, y=y - yVal})
        table.insert(points, {x=x - xVal, y=y - yVal})

        yVal = yVal - 1
        if p > 0 then
            p = p - twoASquared * yVal + aSquared
        else
            xVal = xVal + 1
            p = p + twoBSquared * xVal - twoASquared * yVal + aSquared
        end
    end

    return points
end

local function circle(x, y, radius)
    local points = {}

    local xVal = 0
    local yVal = radius

    local p = 1 - radius

    while xVal <= yVal do
        table.insert(points, {x=x + xVal, y=y + yVal})
        table.insert(points, {x=x + yVal, y=y + xVal})
        table.insert(points, {x=x - xVal, y=y + yVal})
        table.insert(points, {x=x - yVal, y=y + xVal})
        table.insert(points, {x=x + xVal, y=y - yVal})
        table.insert(points, {x=x + yVal, y=y - xVal})
        table.insert(points, {x=x - xVal, y=y - yVal})
        table.insert(points, {x=x - yVal, y=y - xVal})

        xVal = xVal + 1
        if p < 0 then
            p = p + 2 * xVal + 1
        else
            yVal = yVal - 1
            p = p + 2 * (xVal - yVal) + 1
        end
    end

    return points
end

local function hexagon(radius)
local points = {}

for i = 1, 6 do
    local angle = 2 * math.pi * (i - 1) / 6

    local x = radius * math.cos(angle)
    local y = radius * math.sin(angle)

    table.insert(points, {x = x, y = y})
end

return points
end

function pentagon(x, y, radius)
    local points = {}
  
    for i = 1, 5 do
      local angle = 2 * math.pi * (i - 1) / 5
  
      local xO = radius * math.cos(angle)
      local yO = radius * math.sin(angle)
  
      table.insert(points, {x = x + xO, y = y + yO})
    end
  
    return points
end

local function heart(x, y, width, height)
    local points = {}

    local maxX = x + width / 2
    local minX = x - width / 2
    local maxY = y + height / 2
    local minY = y - height / 2

    for i = minX, maxX, 0.1 do
        local yVal = math.sqrt(math.pow(height / 2, 2) - math.pow(i - x, 2)) + y

        if yVal >= minY and yVal <= maxY then
        table.insert(points, {x = i, y = yVal})
        end
    end

    return points
end

local function star(x, y, outerRadius, innerRadius, numPoints)
    local points = {}
  
    for i = 1, numPoints do
      local angle = 2 * math.pi * (i - 1) / numPoints
  
      local radius = (i % 2 == 1) and outerRadius or innerRadius
  
      local xVal = radius * math.cos(angle) + x
      local yVal = radius * math.sin(angle) + y
  
      table.insert(points, {x = xVal, y = yVal})
    end
  
    return points
  end

  --[[
  return {
    line = line,
    circle = circle,
    eclipse = eclipse,
    hexagon = hexagon,
    pentagon = pentagon,
    heart = heart,
    star = star

  }
  ]]

term.clear()
local p = pentagon(30, 30, 8)
for k,v in pairs(p)do
    term.setCursorPos(v.x, v.y)
    term.write("X")
end