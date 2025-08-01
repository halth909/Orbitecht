local gfx = playdate.graphics;
local random = math.random

RoomGeneratorOptions = {
    current = nil,
    singleplayerPath = {
        connectionMax = 0,
        portalMin = 2,
        portalMax = 2,
        portalLocked = false,
        debug = false
    },
    singleplayerSplit = {
        connectionMax = 0,
        portalMin = 3,
        portalMax = 3,
        portalLocked = true,
        debug = false
    },
    singleplayerSimple = {
        connectionMax = 3,
        portalMin = 3,
        portalMax = 3,
        portalLocked = false,
        debug = false
    },
    singleplayerDefault = {
        connectionMax = 9999,
        portalMin = 3,
        portalMax = 9999,
        portalLocked = false,
        debug = false
    },
    singleplayerDebug = {
        connectionMax = 9999,
        portalMin = 2,
        portalMax = 3,
        portalLocked = false,
        debug = true
    }
}

RoomGenerator = {
    width = 21,
    height = 20,
    inBoundsData = {},
    neighboursData = {},
    currentImage = nil,
    currentRoom = nil,
    generate = function(options)
        local directions = {{-1, 0}, {0, -1}, {1, 0}, {0, 1}}

        local width = RoomGenerator.width
        local height = RoomGenerator.height

        local inBounds = RoomGenerator.inBoundsData
        local neighbourPositions = RoomGenerator.neighboursData

        local tileData

        local pointInList = function(point, list)
            for i = 1, #list do
                local other = list[i]
                if other.x == point.x and other.y == point.y then
                    return true
                end
            end

            return false
        end

        local initTileData = function()
            local tileData = {}

            for x = 1, width, 1 do
                for y = 1, height, 1 do
                    if tileData[x] == nil then
                        tileData[x] = {}
                    end
    
                    tileData[x][y] = false
                end
            end

            return tileData
        end

        local isPlaced = function(x, y)
            if not inBounds[x][y] then
                return false
            end

            return tileData[x][y]
        end

        local renderRoomImage = function()
            local roomsImage = gfx.image.new(width, height, gfx.kColorBlack)

            gfx.setColor(gfx.kColorWhite)
            gfx.pushContext(roomsImage)

            for x = 1, width, 1 do
                for y = 1, height, 1 do
                    if isPlaced(x, y) then
                        gfx.drawPixel(x - 1, y - 1)
                    end
                end
            end

            gfx.popContext()

            return roomsImage
        end

        local getNeighbours = function(x, y)
            local nps = neighbourPositions[x][y]
            local ns = {}
            local c = 0

            for i = 1, #nps, 1 do
                local np = nps[i]

                if isPlaced(np.x, np.y) then
                    ns[c + 1] = np
                    c += 1
                end
            end

            return ns
        end

        local getNeighbourCount = function(x, y)
            local nps = neighbourPositions[x][y]
            local c = 0

            for i = 1, #nps, 1 do
                local np = nps[i]

                if isPlaced(np.x, np.y) then
                    c += 1
                end
            end

            return c
        end

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

        local arc = function(x, y, d1, d2)
            if not isPlaced(x + d1[1], y + d1[2]) then return false end
            if not isPlaced(x + d2[1], y + d2[2]) then return false end
            if not isPlaced(x + d1[1] + d2[1], y + d1[2] + d2[2]) then return false end
            return true
        end

        local anyArc = function(x, y)
            if arc(x, y, {0, 1}, {1, 0}) then return true end
            if arc(x, y, {0, 1}, {-1, 0}) then return true end
            if arc(x, y, {0, -1}, {1, 0}) then return true end
            if arc(x, y, {0, -1}, {-1, 0}) then return true end
            return false
        end

        local tryFillTile = function(x, y)
            if not inBounds[x][y] then
                return false
            end

            if tileData[x][y] then
                return false
            end

            if anyArc(x, y) then
                return false
            end

            tileData[x][y] = true

            local intersectionCollision
            local nc -- neighbour count
            local np -- neighbour position
            intersectionCollision = function(ox, oy, cx, cy, dist)
                if dist > 2 then
                    return false
                end

                if dist > 0 and ox == cx and oy == cy then
                    return false
                end

                nc = getNeighbourCount(cx, cy)

                if nc == 4 then
                    return true
                end

                if dist > 0 and nc > 2 then
                    return true
                end

                local nps = neighbourPositions[cx][cy]

                for i = 1, #nps, 1 do
                    np = nps[i]
                    if intersectionCollision(ox, oy, np.x, np.y, dist + 1) then
                        return true
                    end
                end

                return false
            end
            
            if getNeighbourCount(x, y) > 2 then
                if intersectionCollision(x, y, x, y, 0) then
                    tileData[x][y] = false
                    return false
                end
            else
                local nps = neighbourPositions[x][y]

                for i = 1, #nps, 1 do
                    np = nps[i]
                    
                    if getNeighbourCount(np.x, np.y) < 3 then
                        goto continue
                    end

                    if intersectionCollision(np.x, np.y, np.x, np.y, 0) then
                        tileData[x][y] = false
                        return false
                    end

                    ::continue::
                end
            end

            preview(1)

            return true
        end

        local flood
        flood = function(x, y, d)
            local continue = tryFillTile(x, y)

            if not continue then
                return
            end

            if random(100) < 60 then
                flood(x + d[1], y + d[2], d)
            end

            table.shuffle(directions)

            for i = 1, 4, 1 do
                d = directions[i]
                flood(x + d[1], y + d[2], d)
            end
        end

        local trimBackwardPortal = function(x, y)
            if not isPlaced(x, y) then
                return
            end

            local nc = getNeighbourCount(x, y)
            local ns = getNeighbours(x, y)

            while #ns == 1 do
                local n = ns[1]

                if x == n.x - 1 or y == n.y + 1 then
                    tileData[x][y] = false
                    preview(1)

                    x = n.x
                    y = n.y

                    ns = getNeighbours(x, y)
                else
                    return
                end
            end
        end

        local pruneShortPortal = function(x, y)
            if not isPlaced(x, y) then
                return
            end

            local ns = getNeighbours(x, y)

            if #ns ~= 1 then
                return
            end

            local n = ns[1]
            local nns = getNeighbours(n.x, n.y)

            if #nns > 2 then
                tileData[x][y] = false
            end
        end

        local prunePortal = function(x, y)
            if not isPlaced(x, y) then
                return
            end

            local ns = getNeighbours(x, y)

            while #ns == 1 do
                local n = ns[1]

                tileData[x][y] = false
                preview(1)

                x = n.x
                y = n.y

                ns = getNeighbours(x, y)
            end
        end

        local portals = {}
        local prunePortals = function()
            for x = 1, width, 1 do
                for y = 1, height, 1 do
                    trimBackwardPortal(x, y)
                end
            end

            for x = 1, width, 1 do
                for y = 1, height, 1 do
                    pruneShortPortal(x, y)
                end
            end

            portals = {}
            local portalCount = 0

            for x = 1, width, 1 do
                for y = 1, height, 1 do
                    if isPlaced(x, y) and getNeighbourCount(x, y) == 1 then
                        portalCount += 1
                        portals[portalCount] = {
                            x = x,
                            y = y,
                            v = x + y
                        }
                    end
                end
            end

            if portalCount < options.portalMin then
                return false
            end

            local randomPortalCount = random(options.portalMin, options.portalMax)

            for i = randomPortalCount + 1, portalCount, 1 do
                local portal = portals[i]
                prunePortal(portal.x, portal.y)
            end

            preview(2500)
            return true
        end

        local connections = {}
        local addConnection = function(nodes)
            local first = nodes[1]
            local last = nodes[#nodes]
            local offsetX = first.x - last.x
            local offsetY = first.y - last.y

            if offsetX < 0 then return end
            if offsetX == 0 and offsetY < 0 then return end

            table.insert(connections, {
                first = first,
                last = last,
                nodes = nodes
            })
        end

        local populateConnectionsRecursive
        populateConnectionsRecursive = function(visited)
            local last = visited[#visited]
            local neighbours = getNeighbours(last.x, last.y)

            for n = 1, #neighbours do
                local next = neighbours[n]

                local isVisited = pointInList(next, visited)
                
                if isVisited then
                    goto continue
                end

                local nextVisited = table.shallowCopy(visited)
                table.insert(nextVisited, next)

                local isIntersection = #getNeighbours(next.x, next.y) == 3

                if isIntersection then
                    addConnection(nextVisited)
                    return
                end

                populateConnectionsRecursive(nextVisited)

                ::continue::
            end
        end

        local populateConnections = function()
            connections = {}
            local intersections = 0
            for x = 1, width, 1 do
                for y = 1, height, 1 do
                    if not isPlaced(x, y) then
                        goto continue
                    end

                    local neighbours = getNeighbours(x, y)
                    if #neighbours ~= 3 then
                        goto continue
                    end

                    if DEBUG then
                        print("Intersection: " .. x .. " " .. y)
                    end

                    intersections += 1
                    populateConnectionsRecursive({{ x = x, y = y }})

                    ::continue::
                end
            end

            if DEBUG then
                print("Intersections: " .. intersections)
            end
        end

        local nodeId = function(node)
            return node.x .. " " .. node.y 
        end

        local neighbours = {}
        local cycles = {}
        local populateCyclesRecursive
        populateCyclesRecursive = function(keys, nodes)
            local last = keys[#keys]
            local nexts = neighbours[last]

            if #keys > 2 and keys[1] == last then
                table.insert(cycles, nodes)
                return
            end

            for i = 1, #nexts do
                local next = nexts[i]
                local nextKey = next.value
                local connectionNodes = next.nodes

                if keys[1] ~= nextKey and table.contains(keys, nextKey) then
                    goto continue
                end

                local nextKeys = table.shallowCopy(keys)
                local nextNodes = table.shallowCopy(nodes)
                
                table.insert(nextKeys, nextKey)
                table.insert(nextNodes, connectionNodes)

                populateCyclesRecursive(nextKeys, nextNodes)

                ::continue::
            end
        end

        local populateCycles = function()
            neighbours = {}
            cycles = {}

            local function addNeighbour(n1, n2, nodes)
                local key = nodeId(n1)
                local value = nodeId(n2)

                if neighbours[key] == nil then
                    neighbours[key] = {}
                end

                table.insert(neighbours[key], {
                    value = value,
                    nodes = nodes
                })
            end

            for i = 1, #connections do
                local connection = connections[i]
                local n1 = connection.first
                local n2 = connection.last
                addNeighbour(n1, n2, connection.nodes)
                addNeighbour(n2, n1, connection.nodes)
            end

            for key, value in pairs(neighbours) do
                populateCyclesRecursive({ key }, {})
            end
        end

        local pruneConnections = function()
            populateConnections()
            if DEBUG then
                print("Connections populated: " .. #connections)
            end
            
            populateCycles()
            if DEBUG then
                print("Cycles populated: " .. #cycles)
            end

            local tries = 10

            while #connections > options.connectionMax do
                tries -= 1
                if tries == 0 then goto exit end

                table.shuffle(cycles)
                local cycle = cycles[1]

                table.shuffle(cycle)
                local connection = cycle[1]

                if DEBUG then
                    print("Pruning connection")
                end

                for j = 2, #connection - 1 do
                    local node = connection[j]
                    tileData[node.x][node.y] = false
                end

                populateConnections()
                populateCycles()
            end

            ::exit::
            
            return true
        end

        local generate = function()
            tileData = initTileData()

            local time = playdate.getCurrentTimeMilliseconds()
            if DEBUG then
                print("A: " .. playdate.getCurrentTimeMilliseconds() - time)
            end

            table.shuffle(directions)
            flood(10, 10, directions[1]) -- 100kb

            if DEBUG then
                print("B: " .. playdate.getCurrentTimeMilliseconds() - time)
            end

            local portalSuccess = prunePortals()
            if DEBUG then
                print("C: " .. playdate.getCurrentTimeMilliseconds() - time)
            end

            if not portalSuccess then return false end

            local connectionSuccess = true -- pruneConnections() -- 100kb
            if DEBUG then
                print("D: " .. playdate.getCurrentTimeMilliseconds() - time)
            end

            if not connectionSuccess then return false end

            return true
        end

        local success = false

        while not success do
            success = generate()
        end

        local garbage = collectgarbage("count")
        collectgarbage("collect")
        if DEBUG then
            print("Garbage collected: " .. garbage .. " => " .. collectgarbage("count"))
        end

        RoomGenerator.currentImage = renderRoomImage()
        RoomGenerator.currentRoom = {
            grid = Rooms.parse(RoomGenerator.currentImage),
            portalLocked = options.portalLocked
        }
    end,
    draw = function()
        if RoomGenerator.current ~= nil then
            RoomGenerator.current:drawScaled(124, 0, 12)
        end
    end
}

for x = 0, RoomGenerator.width + 1, 1 do
    RoomGenerator.inBoundsData[x] = {}
    for y = 0, RoomGenerator.height + 1, 1 do
        local result = true

        if y < -x + 13 then
            result = false
        elseif y < x - 12 then
            result = false
        elseif y > x + 11 then
            result = false
        elseif y > -x + 30 then
            result = false
        end

        RoomGenerator.inBoundsData[x][y] = result
    end
end

local xos = { -1, 0, 1, 0 }
local yos = { 0, -1, 0, 1 }

for x = 1, RoomGenerator.width, 1 do
    RoomGenerator.neighboursData[x] = {}
    for y = 1, RoomGenerator.height, 1 do
        RoomGenerator.neighboursData[x][y] = {}
        for n = 1, 4, 1 do
            local xn = x + xos[n]
            local yn = y + yos[n]

            if not RoomGenerator.inBoundsData[xn][yn] then
                goto continue
            end

            table.insert(RoomGenerator.neighboursData[x][y], { x = xn, y = yn })

            ::continue::
        end
    end
end

