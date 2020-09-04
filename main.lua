--[[
    Allumer un pixel: 
        GC20.SetVRAM(position, 1)
    
    Eteindre un pixel :
        GC20.SetVRAM(position, 0)
]]

io.stdout:setvbuf('no')
love.math.setRandomSeed(love.timer.getTime())

local engine = require('engine')
local models = require('models')

local screenW = 320
local screenH =200
local cellSize = 10
local map = {}
local mapOld = {}
local ticTimer = 1
local tic = false
local snake = {}
local mouses = {}





local function getAdress(x, y)

    return x + (320 * (math.floor(y / 8))) + ((y % 8) * 8000)

end





local function addMouse()
   
    local validPosition = false
    repeat

        local randLine = love.math.random(1, #map)
        local randColumn = love.math.random(1, #map[1])

        if map[randLine][randColumn] == models.ground.id then
            table.insert(mouses, {
                line = randLine,
                column = randColumn
            })
            map[randLine][randColumn] = models.mouse.id
            validPosition = true
        end
    
    until validPosition

    
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



    -- Création de la grille et initialisation
    for line = 1, screenH / cellSize do
        map[line] = {}
        mapOld[line] = {}
        for column = 1, screenW /cellSize do
            map[line][column] = models.ground.id
            mapOld[line][column] = models.ground.id
        end
    end



    -- Création du serpent au milieu de la map
    snake[1] = {
        type = 'snakeHead',
        direction = 'right',
        line = math.floor(#map / 2),
        column = math.floor(#map[1] / 2)
    }
    snake[2] = {
        type = 'snake',
        line = math.floor(#map / 2),
        column = math.floor(#map[1] / 2) + 1
    }

    -- Création de la première souris
    addMouse()

end





function love.update(dt)

    -- Tic
    ticTimer = ticTimer - dt
    if ticTimer < 0 then
        ticTimer = 1
        tic = true
    else
        tic = false
    end



    -- Mise à jour des cellules 'serpent'
    for i = 1, #snake do
        local s = snake[i]

        map[s.line][s.column] = models[s.type].id

    end



    -- Affichage des cellules mise à jour
    for line = 1, #map do
        for column = 1, #map[line] do

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
