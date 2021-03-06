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
local speed = 0.1
local ticTimer = speed
local tic = false
local snake = {}
local mouses = {}
local direction = {}
direction.up = 'up'
direction.right = 'right'
direction.down = 'down'
direction.left = 'left'
local snakeType = {}
snakeType.head = 'snakeHead'
snakeType.body = 'snakeBody'
local highScore = 0
local score = 0





local function getAdress(x, y)

    return x + (320 * (math.floor(y / 8))) + ((y % 8) * 8000)

end





local function addMouse()
   
    local validPosition = false
    repeat

        local randLine = love.math.random(1, #map)
        local randColumn = love.math.random(1, #map[1])

        validPosition = true
        for i = 1, #snake do
            local s = snake[i]
            if s.line == randLine and s.column == randColumn then
                validPosition = false
            end
        end

        if validPosition then
            table.insert(mouses, {
                line = randLine,
                column = randColumn
            })
        end
    
    until validPosition

end





local function moveSnake(pDirection)

    local actualDirection = snake[1].direction

    if
        pDirection ~= actualDirection and
        (
            (pDirection == direction.up and actualDirection ~= direction.down) or
            (pDirection == direction.right and actualDirection ~= direction.left) or
            (pDirection == direction.down and actualDirection ~= direction.up) or
            (pDirection == direction.left and actualDirection ~= direction.right)
        )
    then
        snake[1].nextDirection = pDirection
    end

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





local function reset()

    if score > highScore then
        highScore = score
    end
    score = 0

    love.window.setTitle("GC20 System Emulation Running... High Score: "..highScore.." Score: "..score)

    map = {}
    snake = {}
    mouses = {}
    ticTimer = 3
    for i = 0, (320 * 200 - 1) do
        GC20.SetVRAM(i, 0)
    end

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
        type = snakeType.head,
        direction = direction.right,
        nextDirection = direction.right,
        line = math.floor(#map / 2),
        column = math.floor(#map[1] / 2)
    }
    snake[2] = {
        type = snakeType.body,
        line = math.floor(#map / 2),
        column = math.floor(#map[1] / 2) - 1
    }

    -- Création de la première souris
    addMouse()

end





function love.load()

    engine.load()

    reset()

end





function love.update(dt)

    -- Tic
    ticTimer = ticTimer - dt
    if ticTimer < 0 then
        ticTimer = speed
        tic = true
    else
        tic = false
    end



    -- Mise à jour des cellules vides
    for line = 1, #map do
        for column = 1, #map[line] do
            if
                map[line][column] == models.snakeBody.id or
                map[line][column] == models.snakeHead.id or
                map[line][column] == models.mouse.id
            then
                map[line][column] = models.ground.id
            end
        end
    end



    -- Mise à jour des cellules 'souris'
    for j = 1, #mouses do
        local mouse = mouses[j]
        map[mouse.line][mouse.column] = models.mouse.id
    end



    -- Mise à jour des cellules 'serpent'
    for i = 1, #snake do
        local s = snake[i]
        if s.line < 1 then s.line = #map end
        if s.line > #map then s.line = 1 end
        if s.column < 1 then s.column = #map[1] end
        if s.column > #map[1] then s.column = 1 end
        map[s.line][s.column] = models[s.type].id
    end



    -- Mise à jour position du serpent
    if tic then
        snake[1].direction = snake[1].nextDirection
        local lastTail = snake[#snake]
        for i = #snake, 1, -1 do
            local s = snake[i]

            -- Tête
            if i == 1 then
                -- Mange une souris
                for j = #mouses, 1, -1 do
                    local mouse = mouses[j]
                    if
                        s.line == mouse.line and
                        s.column == mouse.column
                    then
                        table.remove(mouses, j)
                        table.insert(snake, {
                            type = snakeType.body,
                            line = lastTail.line,
                            column = lastTail.column
                        })
                        addMouse()
                        score = score + 1
                        love.window.setTitle("GC20 System Emulation Running... High Score: "..highScore.." Score: "..score)
                    end
                end
                -- Déplacement
                if s.direction == direction.up then
                    s.line = s.line - 1
                elseif s.direction == direction.right then
                    s.column = s.column + 1
                elseif s.direction == direction.down then
                    s.line = s.line + 1
                elseif s.direction == direction.left then
                    s.column = s.column - 1
                end
                -- Mange la queue
                for k = 2, #snake do
                    if
                        s.line == snake[k].line and
                        s.column == snake[k].column
                    then
                        reset()
                        return
                    end
                end
            else
                snake[i].line = snake[i - 1].line
                snake[i].column = snake[i - 1].column
            end

        end
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

    if key == 'z' or key == 'up' then
        moveSnake(direction.up)
    end

    if key == 'd' or key == 'right' then
        moveSnake(direction.right)
    end

    if key == 's' or key == 'down' then
        moveSnake(direction.down)
    end

    if key == 'q' or key == 'left' then
        moveSnake(direction.left)
    end

end
