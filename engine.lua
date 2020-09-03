GC20 = require("GC20")
GC20.SetMode(1) -- 1: non linaire / 0: linéaire

local engine = {}

function engine.load()

    love.window.setTitle("GC20 System Emulation Running...")
    GC20.load()
    -- line = 0
    -- GC20.SetVRAM(24324,1)

end





function engine.update(dt)
    
    GC20.update(dt)

end





function love.draw()

    GC20.draw()
    love.graphics.print(love.timer.getFPS())

end





function love.keypressed(key)

    if key == 'escape' then love.event.quit() end

end





return engine
