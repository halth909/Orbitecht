FloorPathImages = {}
FloorPathImages["0000"] = { image = Images.map_0_0000, angle = 0 }

FloorPathImages["0100"] = { image = Images.map_0_1000, angle = 0 }
FloorPathImages["0010"] = { image = Images.map_0_1000, angle = 90 }
FloorPathImages["0001"] = { image = Images.map_0_1000, angle = 180 }
FloorPathImages["1000"] = { image = Images.map_0_1000, angle = 270 }

FloorPathImages["1100"] = { image = Images.map_0_1001, angle = 0 }
FloorPathImages["0110"] = { image = Images.map_0_1001, angle = 90 }
FloorPathImages["0011"] = { image = Images.map_0_1001, angle = 180 }
FloorPathImages["1001"] = { image = Images.map_0_1001, angle = 270 }

FloorPathImages["1010"] = { image = Images.map_0_0101, angle = 0 }
FloorPathImages["0101"] = { image = Images.map_0_0101, angle = 90 }

FloorPathImages["1110"] = { image = Images.map_0_1101, angle = 0 }
FloorPathImages["0111"] = { image = Images.map_0_1101, angle = 90 }
FloorPathImages["1011"] = { image = Images.map_0_1101, angle = 180 }
FloorPathImages["1101"] = { image = Images.map_0_1101, angle = 270 }

FloorPathImages["1111"] = { image = Images.map_0_1111, angle = 0 }

FloorRoomImages = {}
FloorRoomImages["0000"] = { image = Images.map_1_0000, angle = 0 }

FloorRoomImages["0100"] = { image = Images.map_1_1000, angle = 0 }
FloorRoomImages["0010"] = { image = Images.map_1_1000, angle = 90 }
FloorRoomImages["0001"] = { image = Images.map_1_1000, angle = 180 }
FloorRoomImages["1000"] = { image = Images.map_1_1000, angle = 270 }

FloorRoomImages["1100"] = { image = Images.map_1_1001, angle = 0 }
FloorRoomImages["0110"] = { image = Images.map_1_1001, angle = 90 }
FloorRoomImages["0011"] = { image = Images.map_1_1001, angle = 180 }
FloorRoomImages["1001"] = { image = Images.map_1_1001, angle = 270 }

FloorRoomImages["1010"] = { image = Images.map_1_0101, angle = 0 }
FloorRoomImages["0101"] = { image = Images.map_1_0101, angle = 90 }

FloorRoomImages["1110"] = { image = Images.map_1_1101, angle = 0 }
FloorRoomImages["0111"] = { image = Images.map_1_1101, angle = 90 }
FloorRoomImages["1011"] = { image = Images.map_1_1101, angle = 180 }
FloorRoomImages["1101"] = { image = Images.map_1_1101, angle = 270 }

FloorRoomImages["1111"] = { image = Images.map_1_1111, angle = 0 }

FloorUnvisitedImage = { image = Images.map_2, angle = 0 }

FloorUtilities = {
    directions = {{-1, 0}, {0, -1}, {1, 0}, {0, 1}},
    getNeighbour = function(x, y, i)
        local d = FloorUtilities.directions[i]
        return x + d[1], y + d[2], (i + 1) % 4 + 1
    end,
    isRoom = function(rooms, x, y)
        if rooms[x] == nil then
            return false
        end

        if rooms[x][y] == nil then
            return false
        end

        return true
    end,
    cellImage = function(rooms, x, y)
        local room = rooms[x][y]

        if not room.visited then
            return FloorUnvisitedImage
        end

        local imageKey = tostring(table.concat(room.connections));
        print(imageKey)

        if room.isComplex then
            return FloorRoomImages[imageKey]
        else
            return FloorPathImages[imageKey]
        end
    end,
}