Grid = {
    pos = { x = 0, y = 0 },
}

GridPos = {
    imageToIndex = {},
    indexToLocal = function(x, y)
        local xPos = x * TILE_WIDTH
        local yPos = y * TILE_HEIGHT

        if y % 2 == 1 then
            xPos = xPos + TILE_WIDTH / 2
        end

        return { x = xPos, y = yPos }
    end,
    localToWorld = function(localPos)
        return {
            x = Grid.pos.x + localPos.x,
            y = Grid.pos.y + localPos.y
        }
    end,
}

for j = 1, 24, 1 do
    local x = 12 - j // 2 -- 12, 11, 11, 10, 10, 9
    local y = (j - 1) // 2 -- 0, 0, 1, 1, 2, 2, 3, 3

    for k = 1, 9, 1 do
        if GridPos.imageToIndex[x] == nil then
            GridPos.imageToIndex[x] = {}
        end

        GridPos.imageToIndex[x][y] = { x = j, y = k }

        x += 1
        y += 1
    end
end
