local gfx = playdate.graphics;

FloorGeneratorOptions = {
    current = nil,
    default = {
        maxRooms = 12,
        maxCycles = 1
    }
}

FloorGenerator = {
    inBoundsData = {},
    neighboursData = {},
    currentFloor = nil,
    inBounds = function(x, y)
        if (x < 1) then return false end
        if (FLOOR_WIDTH < x) then return false end
        if (y < 1) then return false end
        if (FLOOR_HEIGHT < y) then return false end
        local xEdge = x == 1 or x == FLOOR_WIDTH
        local yEdge = y == 1 or y == FLOOR_HEIGHT
        if xEdge and yEdge then return false end
        return true
    end,
    generate = function(options)
        FloorGeneratorOptions.current = options

        local isRoom = FloorUtilities.isRoom
        local inBounds = FloorGenerator.inBounds

        local min = { x = FLOOR_WIDTH, y = FLOOR_HEIGHT }
        local max = { x = 1, y = 1 }

        local rooms = {}
        local roomCount = 0

        local connectionOpportunitiesOuter = {}
        local connectionOpportunitiesInner = {}

        local preview = function(timeout)
            if not options.debug then
                return
            end

            local roomsImage = renderRoomImage()

            gfx.clear(gfx.kColorBlack)
            RoomCurrent.load({
                grid = Rooms.parse(roomsImage)
            })
            RoomCurrent.previewImage:draw(46, 0)

            gfx.clear(gfx.kColorWhite)
            roomImage:drawScaled(74, 0, 12)
            playdate.display.flush()

            playdate.wait(timeout)
        end

        local addRoom = function(x, y)
            min.x = math.min(min.x, x)
            max.x = math.max(max.x, x)
            min.y = math.min(min.y, y)
            max.y = math.max(max.y, y)

            if rooms[x] == nil then
                rooms[x] = {}
            end

            rooms[x][y] = {
                connections = { "0", "0", "0", "0" },
                connectionCount = 0,
                visited = false,
            }

            for i = 1, 4, 1 do
                local nx, ny, ni = FloorUtilities.getNeighbour(x, y, i)

                if not inBounds(nx, ny) then
                    goto continue
                end

                if not isRoom(rooms, nx, ny) then
                    table.insert(connectionOpportunitiesOuter, {
                        x = x,
                        y = y,
                        i = i
                    })
                    goto continue
                end

                -- move outer connections to inner connections
                for cooi = 1, #connectionOpportunitiesOuter, 1 do
                    local coo = connectionOpportunitiesOuter[cooi]
                    if coo ~= nil and coo.x == nx and coo.y == ny and coo.i == ni then
                        table.remove(connectionOpportunitiesOuter, cooi)
                        table.insert(connectionOpportunitiesInner, coo)
                    end
                end

                ::continue::
            end

            roomCount = roomCount + 1
            preview(1)
        end

        local getBestRoom = function(evaluator)
            local best = -9999
            local bestX, bestY

            for x = 1, FLOOR_WIDTH, 1 do
                for y = 1, FLOOR_HEIGHT, 1 do
                    if not isRoom(rooms, x, y) then
                        goto continue
                    end

                    local room = rooms[x][y]
                    if room.connectionCount ~= 1 then
                        goto continue
                    end

                    local score = evaluator(y)
                    if score > best then
                        bestX, bestY = x, y
                        best = score
                    end

                    ::continue::
                end
            end

            return bestX, bestY
        end

        local cleanupConnectionOpportunities = function(list, x, y, i)
            for index = 1, #list, 1 do
                local o = list[index]

                if o.x == x and o.y == y and o.i == i then
                    -- clean up primary direction
                    table.remove(list, index)
                elseif o.x == nx and o.y == ny and o.i == ni then
                    -- clean up secondary direction
                    table.remove(list, index)
                end
            end
        end

        local openConnectionInner = function(x, y, i)
            local nx, ny, ni = FloorUtilities.getNeighbour(x, y, i)

            if rooms[x][y].connections[i] == "1" then
                print("ALREADY OPEN 1")
                return false
            end

            if rooms[nx][ny].connections[ni] == "1" then
                print("ALREADY OPEN 2")
                return false
            end

            rooms[x][y].connections[i] = "1"
            rooms[x][y].connectionCount = rooms[x][y].connectionCount + 1
            rooms[nx][ny].connections[ni] = "1"
            rooms[nx][ny].connectionCount = rooms[nx][ny].connectionCount + 1

            return true
        end

        local openConnectionOuter = function()
            table.shuffle(connectionOpportunitiesOuter)
            local connection = connectionOpportunitiesOuter[1]

            local x = connection.x
            local y = connection.y
            local i = connection.i

            local nx, ny = FloorUtilities.getNeighbour(x, y, i)
            addRoom(nx, ny)
            openConnectionInner(x, y, i)

            cleanupConnectionOpportunities(connectionOpportunitiesOuter, x, y, i)
        end

        local cycleCount = 0
        local addCycles = function()
            while cycleCount < options.maxCycles do
                table.shuffle(connectionOpportunitiesInner)
                local connection = connectionOpportunitiesInner[1]

                local x = connection.x
                local y = connection.y
                local i = connection.i

                if openConnectionInner(x, y, i) then
                    cycleCount += 1
                end
            end
        end

        local generateRoomData = function()
            local introX, introY = getBestRoom(function(y) return math.random() - y end)
            rooms[introX][introY].roomData = Rooms.singleplayer.intro
            Singleplayer.room = { x = introX, y = introY }

            local complexCount = 0.0
            local simpleCount = 0.0
            for x = 1, FLOOR_WIDTH, 1 do
                for y = 1, FLOOR_HEIGHT, 1 do
                    if not isRoom(rooms, x, y) then
                        goto continue
                    end

                    local room = rooms[x][y]
                    if room.roomData ~= nil then
                        room.isComplex = true
                        goto continue
                    end

                    if room.connectionCount > 1 then
                        local complex = complexCount / simpleCount < 4

                        if complex then
                            complexCount += 1
                        else
                            simpleCount += 1
                        end

                        room.isComplex = complex
                    else
                        room.isComplex = true
                        complexCount += 1
                    end

                    local connectionMax = 0
                    if room.isComplex then
                        local a, b = 3, 9999
                        connectionMax = math.random(0, 1) and a or b
                    end

                    RoomGenerator.generate({
                        connectionMax = connectionMax,
                        portalMin = room.connectionCount,
                        portalMax = room.connectionCount,
                        portalLocked = false,
                        debug = false
                    })

                    room.roomData = RoomGenerator.currentRoom

                    ::continue::
                end
            end
        end

        -- initial room
        addRoom(3, 4)

        -- additional rooms
        while roomCount < options.maxRooms do
            openConnectionOuter()
        end

        addCycles()

        local bossX, bossY = getBestRoom(function(y) return y + math.random() end)
        rooms[bossX][bossY].roomData = Rooms.singleplayer.boss

        generateRoomData()

        FloorGenerator.currentFloor = {
            min = min,
            size = {
                x = max.x - min.x + 1,
                y = max.y - min.y + 1
            },
            rooms = rooms,
            boss = {
                x = bossX,
                y = bossY
            },
        }

        local garbage = collectgarbage("count")
        collectgarbage("collect")
        if DEBUG then
            print("Garbage collected: " .. garbage .. " => " .. collectgarbage("count"))
        end
    end
}
