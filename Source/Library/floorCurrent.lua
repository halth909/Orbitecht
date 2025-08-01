local gfx = playdate.graphics;

FloorCurrent = {
    playerOffset = nil,
    rooms = nil,
    backgroundImage = nil,
    updateBackgroundImage = function()
        local rooms = FloorCurrent.rooms
        local min = FloorCurrent.playerOffset
        local size = FloorGenerator.currentFloor.size
        local imageWidth = size.x * MAP_SPRITE_SIZE + 1
        local imageHeight = size.y * MAP_SPRITE_SIZE + 1
        local newImage = gfx.image.new(imageWidth, imageHeight, gfx.kColorBlack)
        local cellImage = FloorUtilities.cellImage

        gfx.setColor(gfx.kColorWhite)
        gfx.pushContext(newImage)

        for x = 1, FLOOR_WIDTH, 1 do
            for y = 1, FLOOR_HEIGHT, 1 do
                if not FloorUtilities.isRoom(rooms, x, y) then
                    goto continue
                end

                local imageData = cellImage(rooms, x, y)

                if imageData.image == nil then
                    print(x .. " " .. y)
                    printTable(rooms[x][y])
                    printTable(imageData)
                end

                local xFinal = math.floor(MAP_SPRITE_SIZE * (x - min.x) + MAP_SPRITE_SIZE / 2)
                local yFinal = math.floor(MAP_SPRITE_SIZE * (y - min.y) + MAP_SPRITE_SIZE / 2)
                print("Map draw: " .. xFinal .. " " .. yFinal)
                imageData.image:drawRotated(xFinal, yFinal, imageData.angle)

                ::continue::
            end
        end

        local boss = FloorGenerator.currentFloor.boss
        x = MAP_SPRITE_SIZE * (boss.x - min.x)
        y = MAP_SPRITE_SIZE * (boss.y - min.y)
        print("Map draw: " .. x .. " " .. y)
        Images.map_boss:draw(x, y)

        gfx.popContext()

        FloorCurrent.backgroundImage = newImage
    end,
    load = function(floor)
        FloorCurrent.playerOffset = floor.min
        FloorCurrent.rooms = floor.rooms

        local x = Singleplayer.room.x
        local y = Singleplayer.room.y
        print(x .. " " .. y)
        local currentRoom = FloorCurrent.rooms[x][y]
        RoomCurrent.load(currentRoom.roomData)

        currentRoom.visited = true
        FloorCurrent.updateBackgroundImage()
        FloorCurrent.drawToMenu()
    end,
    next = function(portalIndex)
        -- find out direction of this portal from current room
        local x = Singleplayer.room.x
        local y = Singleplayer.room.y
        local room = FloorCurrent.rooms[x][y]

        local toSkip = portalIndex - 1
        local i = 0
        local found = false
        while not found do
            i += 1

            if room.connections[i] ~= "1" then
                goto continue
            end

            if toSkip == 0 then
                found = true
            end

            toSkip -= 1
            ::continue::
        end
        print("DEBUG 1")

        local nx, ny, ni = FloorUtilities.getNeighbour(x, y, i)
        local nextRoom = FloorCurrent.rooms[nx][ny]
        

        local nextPortalIndex = 0
        local searchIndex = 0
        while searchIndex < ni do
            searchIndex += 1
            if nextRoom.connections[searchIndex] == "1" then
                nextPortalIndex += 1
            end
        end
        print("DEBUG 2")

        -- room current to load next room
        RoomCurrent.load(nextRoom.roomData)
        Singleplayer.room = { x = nx, y = ny }

        nextRoom.visited = true
        FloorCurrent.updateBackgroundImage()
        FloorCurrent.drawToMenu()

        -- return connecting portal tile in next room
        return Tiles.portals[nextPortalIndex]
    end,
    drawToMenu = function()
        local backgroundImage = FloorCurrent.backgroundImage
        if backgroundImage == nil then
            return
        end

        local width, height = backgroundImage:getSize()

        local x = (200 - width) / 2
        local y = (240 - height) / 2

        local menuImage = gfx.image.new(400, 240, gfx.kColorBlack)
        gfx.pushContext(menuImage)
        backgroundImage:draw(x, y)

        local player = Singleplayer.room
        x += MAP_SPRITE_SIZE * (player.x - FloorCurrent.playerOffset.x)
        y += MAP_SPRITE_SIZE * (player.y - FloorCurrent.playerOffset.y)
        Images.map_player:draw(x, y)

        UI.drawFrame(200)
        gfx.popContext()

        playdate.setMenuImage(menuImage)
    end
}
