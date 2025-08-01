import 'roomCurrent.lua'

local gfx = playdate.graphics

Tiles = {
    data = {},
    portals = {},
    renderQueue = {},
    -- tiles functions
    tryGetOpen = function(count)
        local openTiles = {}

        for _, row in pairs(Tiles.data) do
            for _, tile in pairs(row) do
                
                if tile.canSwitch then
                    goto continue
                end

                if tile.portal then
                    goto continue
                end

                if tile.powered then
                    goto continue
                end

                if tile.collectable ~= nil then
                    goto continue
                end

                if #tile.minecarts > 0 then
                    goto continue
                end

                table.insert(openTiles, tile)
                ::continue::
            end
        end

        table.shuffle(openTiles)

        if #openTiles < count then
            print("Not enough open tiles")
            return false, {}
        end

        return true, { table.unpack(openTiles, 1, count) }
    end,
    getStraights = function()
        local straights = {}

        for _, row in pairs(Tiles.data) do
            for _, startTile in pairs(row) do
                local current = startTile
                local length = 0
                local spoiled = false

                if Tiles.getNeighbour(current, 1) == nil then
                    while current ~= nil and not spoiled do
                        if current.portal then
                            spoiled = true
                        end

                        current = Tiles.getNeighbour(current, 3)
                        length += 1
                    end

                    if length > 3 and not spoiled then
                        table.insert(straights, {
                            start = startTile,
                            heading = 3,
                            length = length
                        })
                    end
                end

                current = startTile
                length = 0
                spoiled = false

                if Tiles.getNeighbour(current, 4) == nil then
                    while current ~= nil and not spoiled do
                        if current.portal then
                            spoiled = true
                        end

                        current = Tiles.getNeighbour(current, 2)
                        length += 1
                    end

                    if length > 3 and not spoiled then
                        table.insert(straights, {
                            start = startTile,
                            heading = 2,
                            length = length
                        })
                    end
                end
            end
        end

        table.sort(straights, function(a, b) return a.length > b.length end)
        return straights
    end,
    load = function()
        local function getNeighbourPositions(x, y)
            local offsets = { {0, -1}, {0, 1}, {-1, 1}, {-1, -1} }
            local results = {}
    
            for i = 1, 4 do
                results[i] = { x + offsets[i][1] + y % 2, y + offsets[i][2] }
            end
    
            return results
        end

        local function loadOne(type, x, y, neighbours)
            local tileData = Tiles.data[x][y]

            tileData.x = x
            tileData.y = y
            tileData.neighbourCount = neighbours.count
            tileData.neighbourPositions = neighbours.positions
            tileData.neighbours = neighbours.references
            tileData.canSwitch = false
            tileData.portal = neighbours.count == 1
            tileData.isLocked = false
            tileData.isPowered = type == 2
            tileData.ghosts = {}
            tileData.minecarts = {}
            tileData.minecartsForSwitch = {}
            tileData.localPos = GridPos.indexToLocal(x, y)
            tileData.pos = {}
    
            if neighbours.count == 1 then
                if neighbours.types[1] == 1 or neighbours.types[3] == 1 then
                    tileData.rail = Rails.NS
                else
                    tileData.rail = Rails.EW
                end
            elseif neighbours.count == 4 then
                tileData.rail = Rails.LC
            elseif neighbours.count == 2 then
                if neighbours.types[1] == 1 then
                    if neighbours.types[2] == 1 then
                        tileData.rail = Rails.NE
                    elseif neighbours.types[3] == 1 then
                        tileData.rail = Rails.NS
                    else -- neighbours.types[4] == 1
                        tileData.rail = Rails.NW
                    end
                elseif neighbours.types[2] == 1 then
                    if neighbours.types[3] == 1 then
                        tileData.rail = Rails.SE
                    else -- neighbours.types[4] == 1
                        tileData.rail = Rails.EW
                    end
                else -- neighbours.types[3] == 1 and neighbours.types[4] == 1
                    tileData.rail = Rails.SW
                end
            -- switchable tiles
            elseif neighbours.types[1] + neighbours.types[3] == 2 then
                tileData.rail = Rails.NS
                tileData.canSwitch = true
                tileData.railOptions = Rails.getOptions(neighbours.types)
            else
                tileData.rail = Rails.EW
                tileData.canSwitch = true
                tileData.railOptions = Rails.getOptions(neighbours.types)
            end
    
            if tileData.portal then
                table.insert(Tiles.portals, tileData)
                tileData.portalIndex = #Tiles.portals
            end

            table.insert(Tiles.renderQueue, tileData)

            return tileData
        end

        local bounds = {
            min = { x = 400, y = 240 },
            max = { x = 0, y = 0 }
        }

        -- preload
        for y, row in pairs(RoomCurrent.grid) do
            for x, type in pairs(row) do
                if type == 0 then
                    goto continue
                end

                if Tiles.data[x] == nil then
                    Tiles.data[x] = {}
                end

                Tiles.data[x][y] = {}

                ::continue::
            end
        end

        for y, row in pairs(RoomCurrent.grid) do
            for x, type in pairs(row) do
                if type == 0 then
                    goto continue
                end

                local neighbours = {
                    count = 0,
                    positions = getNeighbourPositions(x, y),
                    types = {},
                    references = {}
                }

                for i = 1, 4 do
                    local nx = neighbours.positions[i][1]
                    local ny = neighbours.positions[i][2]

                    if RoomCurrent.tileAt(nx, ny) then
                        neighbours.count += 1
                        neighbours.types[i] = 1
                        neighbours.references[i] = Tiles.data[nx][ny]
                    else
                        neighbours.types[i] = 0
                        neighbours.references[i] = nil
                    end
                end

                -- update bounds
                local tile = loadOne(type, x, y, neighbours)

                bounds.min.x = math.min(bounds.min.x, tile.localPos.x)
                bounds.min.y = math.min(bounds.min.y, tile.localPos.y)
                bounds.max.x = math.max(bounds.max.x, tile.localPos.x)
                bounds.max.y = math.max(bounds.max.y, tile.localPos.y)

                ::continue::
            end
        end

        -- centre of bounds
        Grid.pos = {
            x = 228 - (bounds.max.x + bounds.min.x) / 2,
            y = 112 - (bounds.max.y + bounds.min.y) / 2,
        }

        -- update tile positions
        for y, row in pairs(RoomCurrent.grid) do
            for x, type in pairs(row) do
                if type == 0 then
                    goto continue
                end

                local tile = Tiles.data[x][y]

                tile.pos = GridPos.localToWorld(tile.localPos)

                ::continue::
            end
        end
    end,
    unload = function()
        Tiles.data = {}
        Tiles.portals = {}
        Tiles.renderQueue = {}
    end,

    -- tile functions
    getNeighbour = function(tile, heading)
        local nPos = tile.neighbourPositions[heading]

        if Tiles.data[nPos[1]] == nil then
            return nil
        end

        return Tiles.data[nPos[1]][nPos[2]]
    end,
    progressDirection = function(tile, nextTile, exitHeading)
        if tile.portal and nextTile.portal then
            if nextTile.rail == Rails.NS then
                return 1
            else
                return -1
            end
        end

        if nextTile == nil or nextTile.rail == nil then
            return nil
        end

        return nextTile.rail.progressDirections[(exitHeading + 1) % 4 + 1]
    end,
    align = function(switch)
        if switch.tile == nil then
            return
        end

        local tile = switch.tile

        if #tile.minecarts > 0 then
            return
        end

        tile.rail = Rails.getCurrentOrNextOption(tile.rail, tile.railOptions, switch.withHeading)
    end,
    switch = function(switch)
        local tile = switch.tile
        
        if tile == nil then
            return
        end
        
        tile.rail = Rails.getNextOption(tile.rail, tile.railOptions, switch.withHeading)
    end,
    preRender = function()
        local offset = RoomCurrent.backgroundOffset
        local blockImage = Images.block

        local backgroundImage = gfx.image.new(308, 240)
        gfx.pushContext(backgroundImage)

        local renderQueue = Tiles.renderQueue

        for t = 1, #renderQueue, 1 do
            local tile = renderQueue[t]

            -- draw block
            local pos = tile.pos
            local xPos = pos.x - offset
            local yPos = pos.y
            blockImage:draw(xPos, yPos)

            -- draw static rail
            if not tile.isPowered and not tile.canSwitch and tile.rail ~= nil then
                Rails.draw(tile.rail, xPos, yPos, false, false)
            end
        end

        local previewImage = backgroundImage:copy()
        gfx.pushContext(previewImage)

        Tiles.draw(-offset, 0)

        gfx.popContext()
        gfx.popContext()

        return backgroundImage, previewImage
    end,
    draw = function(x, y)
        local anyMinecartWithSwitch = Minecarts.anyWithSwitch

        local drawRail = Rails.draw
        local drawBarrel = Barrels.draw
        local drawGhost = Ghosts.draw
        local drawCollectable = Collectables.draw
        local minecartDraw = Minecarts.drawMinecart

        local renderQueue = Tiles.renderQueue

        for t = 1, #renderQueue, 1 do
            local tile = renderQueue[t]

            local pos = tile.pos
            local xPos = pos.x + x
            local yPos = pos.y + y

            local tileRail = tile.rail

            -- draw powered rail
            if tile.isPowered and tileRail ~= nil then
                drawRail(tileRail, xPos, yPos, true, false)
            end

            -- draw switchable rail
            if tile.canSwitch and tileRail ~= nil then
                drawRail(tileRail, xPos, yPos, false, anyMinecartWithSwitch(tile))
            end

            -- draw portal
            if tile.portal then
                local flip = gfx.kImageUnflipped

                if tile.rail == Rails.EW then
                    flip = gfx.kImageFlippedX
                end

                if tile.isLocked then
                    -- Animators.portalLocked:draw(xPos, yPos - 20, flip)
                    Images.portalLock:draw(xPos, yPos - 20, flip)
                else
                    Animator.draw(Animators.portal, xPos, yPos - 20, flip)
                end
            end

            -- draw collectable
            drawCollectable(tile.collectable, xPos, yPos)

            -- draw snake
            if tile.snakeData ~= nil then
                Snake.drawOne(tile.snakeData)
            end

            -- draw barrel
            drawBarrel(tile.barrel, xPos, yPos)

            -- draw ghosts
            local ghosts = tile.ghosts
            
            for i = 1, #ghosts, 1 do
                local ghost = ghosts[i]
                drawGhost(ghost)
            end

            -- draw minecarts
            local minecarts = tile.minecarts

            table.sort(minecarts, function(a, b)
                local _, ay = Rails.getLocalPos(a.tile.rail, a.progress)
                local _, by = Rails.getLocalPos(b.tile.rail, b.progress)
                return a.tile.pos.y + ay < b.tile.pos.y + by
            end)

            for i = 1, #minecarts, 1 do
                local minecart = minecarts[i]
                minecartDraw(minecart, x, y)
            end
        end
    end
}
