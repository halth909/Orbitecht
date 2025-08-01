local roomCurrentBackgroundImage = nil
local roomCurrentBackgroundOffset = 92

RoomCurrent = {
    data = nil,
    grid = nil,
    backgroundImage = roomCurrentBackgroundImage,
    backgroundOffset = roomCurrentBackgroundOffset,
    previewImage = nil,
    load = function(room)
        RoomCurrent.unload()
        RoomCurrent.data = room
        RoomCurrent.grid = room.grid

        -- load data
        Tiles.load()

        -- draw background image
        roomCurrentBackgroundImage, RoomCurrent.previewImage = Tiles.preRender()
    end,
    draw = function(x, y)
        roomCurrentBackgroundImage:draw(x + roomCurrentBackgroundOffset, y)
        Tiles.draw(x, y)
        -- Minecarts.drawMask(60)
    end,
    unload = function()
        Tiles.unload()
        Collectables.unload()
    end,
    directionOf = function(portalIndex)
        
    end,
    tileAt = function(x, y)
        if x < 1 or y < 1 then
            return false
        end

        if #RoomCurrent.grid < y then
            return false
        end

        local row = RoomCurrent.grid[y]

        if #row < x then
            return false
        end

        return row[x] ~= 0
    end
}
