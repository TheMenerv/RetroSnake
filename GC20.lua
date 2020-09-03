local GC20 = {}

local gc20_screen_size_w = 320
local gc20_screen_size_h = 200
local gc20_vram_memory_size = gc20_screen_size_w * gc20_screen_size_h
local gc20_screen_pos_x = 0
local gc20_screen_pos_y = 0
local gc20_vram_memory_data = {}
local gc20_SegFault = false

local gc20_vram_mode = 0

function GC20.SetMode(pMode)
    gc20_vram_mode = pMode
end

function GC20.SetVRAM(pAddress, pValue)
    if pAddress < 0 or pAddress > gc20_vram_memory_size-1 then
        gc20_SegFault = true
    else
        pAddress = pAddress + 1
        gc20_vram_memory_data[pAddress] = pValue
    end
end

function GC20.load()
    gc20_vram_memory_data = {}
    for n=1,gc20_vram_memory_size do
        gc20_vram_memory_data[n] = 0
    end

    gc20_screen_pos_x = (love.graphics.getWidth() - gc20_screen_size_w * 2) / 2
    gc20_screen_pos_y = (love.graphics.getHeight() - gc20_screen_size_h * 2) / 2

end

function GC20.update(dt)

end

local function gc20_draw_linear()
    local sx = 0
    local sy = 0

    love.graphics.setColor(1, 1 , 1 , 1)

    for n=1,gc20_vram_memory_size do
        if gc20_vram_memory_data[n] == 1 then
            love.graphics.rectangle("fill", gc20_screen_pos_x + sx, gc20_screen_pos_y + sy, 2, 2)
        end
        sx = sx + 2
        if sx == gc20_screen_size_w * 2 then
            sx = 0
            sy = sy + 2
        end
    end
end

local function gc20_draw_nolinear()
    local sx = 0
    local sy = 0
    local offset = 0

    love.graphics.setColor(1, 1 , 1, 1)

    for n=1,gc20_vram_memory_size do
        if gc20_vram_memory_data[n] == 1 then
            love.graphics.rectangle("fill", gc20_screen_pos_x + sx, gc20_screen_pos_y + sy, 2, 2)
        end
        sx = sx + 2
        if sx == gc20_screen_size_w * 2 then
            sx = 0
            sy = sy + 2*8
            if sy >= gc20_screen_size_h * 2 then
                offset = offset + 2
                sy = 0 + offset
            end
        end
    end
end

local function gc20_draw()
    if gc20_vram_mode == 0 then
        gc20_draw_linear()
    else
        gc20_draw_nolinear()
    end
end

function GC20.draw()
    love.graphics.push()
    love.graphics.setColor(.5,.5,.5,1)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(0,0,0,1)
    love.graphics.rectangle("fill", gc20_screen_pos_x, gc20_screen_pos_y, gc20_screen_size_w*2, gc20_screen_size_h*2)
    love.graphics.setColor(1,1,1,1)
    if gc20_SegFault == false then
        gc20_draw()
    else
        love.graphics.print("SEGMENTATION FAULT", gc20_screen_pos_x, gc20_screen_pos_y)
    end
    love.graphics.pop()
end

return GC20