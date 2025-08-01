local gfx = playdate.graphics

Rooms = {
    mainMenu = {},
    singleplayer = {},
    multiplayer = {},

    -- rooms functions
    parse = function(image)
        local room = {}

        for j = 1, 24, 1 do
            local row = {}

            local x = 12 - j // 2 -- 12, 11, 11, 10, 10, 9
            local y = (j - 1) // 2 -- 0, 0, 1, 1, 2, 2, 3, 3

            for i = 1, 9, 1 do
                local sample = image:sample(x, y)
                table.insert(row, sample)

                x += 1
                y += 1
            end

            table.insert(room, row)
        end

        return room
    end,
    getPreviewImage = function(index)
        if index == nil then
            return Images.roomRandom
        end
        
        local room = Rooms.multiplayer[index]

        if room.previewImage == nil then
            RoomCurrent.load(room)
            room.previewImage = RoomCurrent.previewImage
            RoomCurrent.unload()
        end

        return room.previewImage
    end
}

local mainMenuTable = gfx.imagetable.new("Images/rooms-mainMenu")
local singleplayerTable = gfx.imagetable.new("Images/rooms-singleplayer")
local multiplayerTable = gfx.imagetable.new("Images/rooms-multiplayer")

for i = 1, LEVEL_COUNT_MAINMENU, 1 do
    Rooms.mainMenu[i] = {
        grid = Rooms.parse(mainMenuTable:getImage(i))
    }
end

Rooms.singleplayer = {
    intro = {
        grid = Rooms.parse(singleplayerTable:getImage(1))
    },
    boss = {
        grid = Rooms.parse(singleplayerTable:getImage(10))
    }
}

for i = 1, LEVEL_COUNT_MULTIPLAYER, 1 do
    Rooms.multiplayer[i] = {
        grid = Rooms.parse(multiplayerTable:getImage(i))
    }
end
