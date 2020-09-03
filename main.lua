--[[
    Allumer un pixel: 
        GC20.SetVRAM(position, 1)
    
    Eteindre un pixel :
        GC20.SetVRAM(position, 0)
]]

local engine = require('engine')

local screenW = 320
local screenH =200





local function getAdress(x, y)

    return x + (320 * (math.floor(y / 8))) + ((y % 8) * 8000)

end





function love.load()

    engine.load()

    -- Code ici:

end





function love.update(dt)

    -- Code ici:
    
    engine.update(dt)

end
