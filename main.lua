--[[
    Allumer un pixel: 
        GC20.SetVRAM(position, 1)
    
    Eteindre un pixel :
        GC20.SetVRAM(position, 0)
]]

io.stdout:setvbuf('no')

local engine = require('engine')
local models = require('models')

local screenW = 320
local screenH =200
local cellSize = 10
local map = {}
local mapOld = {}





local function getAdress(x, y)

    return x + (320 * (math.floor(y / 8))) + ((y % 8) * 8000)

end





local function modelDraw(line, column, schema)

    for l = 1, cellSize do
        for c = 1, cellSize do

            -- Calcul des coordonnées
            local x = (column - 1) * cellSize + (c - 1)
            local y = (line - 1) * cellSize + (l - 1)

            local id = schema[l][c]

            GC20.SetVRAM(getAdress(x, y), id)

        end
    end

end





function love.load()

    engine.load()

    for line = 1, screenH / cellSize do
        map[line] = {}
        mapOld[line] = {}
        for column = 1, screenW /cellSize do
            map[line][column] = models.ground.id
            mapOld[line][column] = models.ground.id
        end
    end

end





function love.update(dt)

    -- Affichage des cellules mise à jour
    for line = 1, screenH / cellSize do
        for column = 1, screenW /cellSize do

            if map[line][column] ~= mapOld[line][column] then
                local schema

                for modelName, model in pairs(models) do

                    if model.id == map[line][column] then
                        modelDraw(line, column, model.schema)
                    end
                end

                mapOld[line][column] = map[line][column]
            end
        end
    end
    
    engine.update(dt)

end





function love.keypressed(key)

    if key == 'escape' then love.event.quit() end

end
