import "events.lua"
import "health.lua"
import "Assets/Images"

local gfx = playdate.graphics
local dither = gfx.image.kDitherTypeDiagonalLine

Minecarts = {
    data = {},
    active = {},

    -- reusable tables
    levelCrossingTiles = {},
    levelCrossingRails = {},

    -- minecarts functions
    anyWithSwitch = function(tile)
        local active = Minecarts.active

        for i = 1, #active, 1 do
            local minecart = active[i]
            if minecart.switch.tile == nil then
                goto continue
            end

            if minecart.switch.tile == tile then
                return true
            end

            ::continue::
        end

        return false
    end,
    loadMainMenu = function()
        Minecarts.speedDefault = 4000
        Minecarts.speedPowered = 8000
        Minecarts.acceleration = 0.5
        Minecarts.switchSearchDistance = 0

        local minecart = Minecarts.data[math.random(#Minecarts.data)]
        local success, openTiles = Tiles.tryGetOpen(1)
        if not success then return end

        Minecarts.setTile(minecart, openTiles[1])
        Minecarts.active[1] = minecart

        Minecarts.onPortal = function(minecart, portalIndex)
            Minecarts.redeemItem(minecart)
            StateMainMenu.newRoom()

            table.shuffle(Tiles.portals)

            return Tiles.portals[1]
        end
    end,
    loadSingleplayer = function()
        Minecarts.speedDefault = 5000
        Minecarts.speedPowered = 10000
        Minecarts.acceleration = 1
        Minecarts.switchSearchDistance = 999999

        local success, openTiles = Tiles.tryGetOpen(1)
        if not success then return end

        if openTiles == nil then
            return
        end

        Minecarts.setTile(Singleplayer.minecart, openTiles[1])
        Minecarts.active[1] = Singleplayer.minecart
    end,
    loadMultiplayer = function()
        Minecarts.speedDefault = 4000
        Minecarts.speedPowered = 8000
        Minecarts.acceleration = 0.5
        Minecarts.switchSearchDistance = 7000

        local players = Multiplayers.getActive()
        local success, openTiles = Tiles.tryGetOpen(#players)
        if not success then return end

        for i, player in pairs(players) do
            Minecarts.setTile(player.minecart, openTiles[i])
            Minecarts.active[i] = player.minecart
        end

        Minecarts.onPortal = function(minecart, portalIndex)
            Minecarts.redeemItem(minecart)

            table.shuffle(Tiles.portals)
            print("Portals: " .. #Tiles.portals)
            if Tiles.portals[1] == minecart.tile then
                return Tiles.portals[2]
            else
                return Tiles.portals[1]
            end
        end
    end,
    updateTile = function(minecart)
        local minecartProgress = minecart.progress
        local minecartDirection = minecart.direction

        local tile = minecart.tile
        local tileRail = tile.rail
        local tileRailLength = tileRail.length

        local carry

        if minecartProgress > tileRailLength then
            carry = minecartProgress - tileRailLength
        elseif minecartProgress < 0 then
            carry = -minecartProgress
        else
            return
        end

        minecart.pending_collection = true
        table.removeByReference(tile.minecarts, minecart)

        local nextHeading = Rails.directionToHeading(tileRail, minecartDirection)
        
        local nextTile = Tiles.getNeighbour(tile, nextHeading)
        if nextTile == nil and tile.portal then
            nextTile = Minecarts.onPortal(minecart, tile.portalIndex)
        end

        local nextDirection = Tiles.progressDirection(tile, nextTile, nextHeading)
        local nextPortal = nextTile ~= nil and nextTile.portal
        if nextPortal then
            local nextLocked = nextTile.isLocked and minecart.collectable ~= Collectables.key

            if nextLocked then
                print("NEXT TILE LOCKED PORTAL")
                nextTile = nil
            end
        end

        if nextDirection == nil or nextTile == nil then
            nextTile = minecart.tile
            minecart.direction = -minecartDirection
        else
            tileRailLength = nextTile.rail.length
            minecart.tile = nextTile
            minecart.direction = nextDirection
        end

        if minecart.direction == 1 then
            minecart.progress = carry
        else
            minecart.progress = tileRailLength - carry
        end

        if nextTile ~= nil then
            table.insert(nextTile.minecarts, minecart)
        end
    end,
    updateSwitch = function(minecart)
        minecart.switch.tile = nil

        local direction = minecart.direction
        local tile = minecart.tile
        local headingToNextTile = nil
        local distance = nil
        local found = false

        if direction == 1 then
            distance = tile.rail.length - minecart.progress
        else
            distance = minecart.progress
        end

        local levelCrossingTiles = Minecarts.levelCrossingTiles
        local levelCrossingRails = Minecarts.levelCrossingRails

        table.clear(levelCrossingTiles)
        table.clear(levelCrossingRails)

        table.insert(levelCrossingTiles, tile)
        levelCrossingRails[tile] = tile.rail

        while not found and distance < Minecarts.switchSearchDistance do
            headingToNextTile = Rails.directionToHeading(tile.rail, direction)
            local nextTile = Tiles.getNeighbour(tile, headingToNextTile)

            -- try reflection
            if nextTile == nil then
                nextTile = tile
                direction = -direction
            else
                -- resolve level crossing
                if nextTile.neighbourCount == 4 then
                    local rail = Rails.NS

                    if headingToNextTile % 2 == 0 then
                        rail = Rails.EW
                    end

                    nextTile.rail = rail

                    if levelCrossingRails[nextTile] == nil then
                        table.insert(levelCrossingTiles, nextTile)
                        levelCrossingRails[nextTile] = rail
                    end
                end

                direction = Tiles.progressDirection(tile, nextTile, headingToNextTile)
            end

            if nextTile == nil then
                goto continue
            end

            if nextTile.portal then
                goto continue
            end

            if nextTile.canSwitch then
                found = true
            end

            distance += nextTile.rail.length
            tile = nextTile
        end

        ::continue::

        local levelCrossingTile
        for i = 1, #levelCrossingTiles, 1 do
            levelCrossingTile = levelCrossingTiles[i]
            levelCrossingTile.rail = levelCrossingRails[levelCrossingTile]
        end

        if not found then
            return
        end

        minecart.switch.tile = tile
        minecart.switch.distance = distance
        minecart.switch.withHeading = (headingToNextTile + 1) % 4 + 1
    end,
    collect = function(minecart)
        if not Minecarts.isGrounded(minecart) then
            return
        end

        local tile = minecart.tile

        minecart.pending_collection = false

        if tile.collectable == nil then
            return
        end

        local collectable = tile.collectable
        tile.collectable = nil

        if collectable == Collectables.coin then
            local lx, ly = Rails.getLocalPos(tile.rail, minecart.progress)
            UIMultiplayer.addFloatingText("+1", tile.pos.x + lx, tile.pos.y + ly)
            minecart.deltaScore(1)
            collectable.count -= 1

            Event.collectCoin()
            return
        end

        -- swap collectables
        tile.collectable = minecart.collectable
        minecart.collectable = collectable

        if collectable == Collectables.diamond then
            Event.collectDiamond()
        end
    end,
    updateCollectable = function(minecart)
        local collectable = minecart.collectable
        local timer = minecart.collectableTimer

        local createTimer = collectable == Collectables.skull and timer == nil
        local removeTimer = collectable ~= Collectables.skull and timer ~= nil

        if createTimer then
            minecart.collectableTimer = Timer.new(Collectables.settings.skullSapInterval, function()
                local tile = minecart.tile
                local tilePos = tile.pos
                local lx, ly = Rails.getLocalPos(tile.rail, minecart.progress)
                UIMultiplayer.addFloatingText("-1", tilePos.x + lx, tilePos.y + ly)
                minecart.deltaScore(-1)
            end)
            minecart.collectableTimer.repeats = true
        elseif removeTimer then
            Timer.cancel(minecart.collectableTimer)
            minecart.collectableTimer = nil
        end
    end,
    updateMinecartGrounded = function(minecart)
        local tile = minecart.tile
        local desiredSpeed

        if tile.isPowered then
            if tile.rail == Rails.NS then
                desiredSpeed = minecart.direction * Minecarts.speedPowered
            else
                desiredSpeed = -minecart.direction * Minecarts.speedPowered
            end
        else
            desiredSpeed = Minecarts.speedDefault
        end

        if minecart.input ~= nil then
            desiredSpeed *= minecart.input
        end

        local newSpeed = lerp(minecart.speed, desiredSpeed, Minecarts.acceleration / FRAME_TARGET)

        if newSpeed < 0 then
            minecart.speed = -newSpeed
            minecart.direction *= -1
            minecart.pending_reversal = false
        else
            minecart.speed = newSpeed
        end
    end,
    updateMinecartAir = function(minecart)
        minecart.jump += MINECART_JUMP_SPEED

        if minecart.jump > 1 then
            minecart.jump = -1
        end
    end,
    updateMinecart = function(minecart)
        if minecart.jump < 0 then
            Minecarts.updateMinecartGrounded(minecart)
        else
            Minecarts.updateMinecartAir(minecart)
        end

        -- update progress through current tile
        minecart.progress += minecart.speed * minecart.direction / FRAME_TARGET

        -- transition to next tile if needed
        Minecarts.updateTile(minecart)

        -- update next switchable tile
        Minecarts.updateSwitch(minecart)

        if minecart.pending_collection then
            Minecarts.collect(minecart)
        end

        -- update collectable
        Minecarts.updateCollectable(minecart)
    end,
    resolveCollisionsCleanup = function(minecart, other)
        -- switch collectables
        local minecartCollectable = minecart.collectable
        minecart.collectable = other.collectable
        other.collectable = minecartCollectable

        Event.collision()
    end,
    resolveCollisionsHeadOn = function(minecart, other)
        -- switch directions
        minecart.direction *= -1
        other.direction *= -1

        Minecarts.resolveCollisionsCleanup(minecart, other)
    end,
    resolveCollisionsRearEnd = function(minecart, other, overlap)
        local offset = overlap / 2

        if minecart.speed < other.speed then
            minecart.progress += minecart.direction * offset
            other.progress -= other.direction * offset
        else
            minecart.progress -= minecart.direction * offset
            other.progress += other.direction * offset
        end

        local temp = other.speed
        other.speed = minecart.speed
        minecart.speed = temp

        Minecarts.resolveCollisionsCleanup(minecart, other)
    end,
    resolveSwitchCollisions = function(minecart, other)
        if minecart.switch.tile == nil then
            return
        end

        if other.switch.tile == nil then
            return
        end

        if minecart.switch.tile == other.switch.tile then
            local diff = minecart.switch.distance - other.switch.distance

            if diff > 0 then
                minecart.switch.tile = nil
            end

            if diff < 0 then
                other.switch.tile = nil
            end
        end
    end,
    resolveCollisions = function(minecart, other)
        if minecart == other then
            return
        end

        local overlap

        if minecart.tile == other.tile then
            -- moving in opposite directions
            if minecart.direction == 1 and other.direction == -1 and minecart.progress > other.progress then
                return
            elseif minecart.direction == -1 and other.direction == 1 and minecart.progress < other.progress then
                return
            end

            overlap = MINECART_COLLISION_DISTANCE - math.abs(minecart.progress - other.progress)
            if overlap > 0 then
                -- print("collision overlap " .. overlap)
                if minecart.direction == other.direction then
                    -- print("collision type 1")
                    Minecarts.resolveCollisionsRearEnd(minecart, other, overlap)
                else
                    -- print("collision type 2")
                    Minecarts.resolveCollisionsHeadOn(minecart, other)
                end
            end

            return
        end

        local nextHeading = Rails.directionToHeading(minecart.tile.rail, minecart.direction)
        local nextTile = Tiles.getNeighbour(minecart.tile, nextHeading)

        if other.tile == nextTile then
            overlap = MINECART_COLLISION_DISTANCE

            if minecart.direction == 1 then
                overlap -= (minecart.tile.rail.length - minecart.progress)
            else
                overlap -= minecart.progress
            end

            local otherTileDirection = Tiles.progressDirection(minecart.tile, nextTile, nextHeading)

            if otherTileDirection == nil then
                return
            end

            if otherTileDirection == 1 then
                overlap -= other.progress
            elseif nextTile ~= nil then
                overlap -= (nextTile.rail.length - other.progress)
            end

            if overlap > 0 then
                -- print("collision overlap " .. overlap)
                local tilesAligned = minecart.direction == otherTileDirection
                local minecartsAligned = minecart.direction == other.direction

                if tilesAligned == minecartsAligned then
                    -- print("collision type 3")
                    Minecarts.resolveCollisionsRearEnd(minecart, other, overlap)
                else
                    -- print("collision type 4")
                    Minecarts.resolveCollisionsHeadOn(minecart, other)
                end
            end
        end

        Minecarts.resolveSwitchCollisions(minecart, other)
    end,
    update = function()
        local updateMinecart = Minecarts.updateMinecart
        local resolveCollisions = Minecarts.resolveCollisions

        local active = Minecarts.active

        -- move
        for i = 1, #active, 1 do
            updateMinecart(active[i])
        end

        -- resolve collisions
        for i = 1, #active, 1 do
            for j = 1, #active, 1 do
                resolveCollisions(active[i], active[j])
            end
        end

        -- auto switch rails
        local alignTile = Tiles.align
        for i = 1, #active, 1 do
            alignTile(active[i].switch)
        end
    end,
    unload = function()
        local data = Minecarts.data
        for i = 1, #data, 1 do
            local minecart = data[i]
            minecart.speed = 0
            minecart.tile = nil
            minecart.collectable = nil
            minecart.deltaScore = function(delta) end

            if minecart.collectableTimer ~= nil then
                Timer.cancel(minecart.collectableTimer)
                minecart.collectableTimer = nil
            end
        end

        Minecarts.active = {}
    end,

    -- minecart functions
    setTile = function(minecart, newTile)
        table.insert(newTile.minecarts, minecart)

        minecart.tile = newTile
        minecart.progress = newTile.rail.length / 2
    end,
    jump = function(minecart)
        if minecart.jump > 0 then
            return
        end

        minecart.jump = 0
    end,
    isGrounded = function(minecart)
        return minecart.jump < 0
    end,
    switch = function(minecart)
        Tiles.switch(minecart.switch)
    end,
    reverse = function(minecart)
        if minecart == nil then
            return
        end

        minecart.direction *= -1;
    end,
    onPortal = function(minecart, portalIndex)
    end,
    redeemItem = function(minecart)
        if minecart.collectable == nil then
            Event.portalNone()
            return
        end

        local collectable = minecart.collectable

        if collectable ~= nil then
            minecart.collectable = nil
            collectable.count -= 1
        end

        if collectable == Collectables.diamond then
            local tile = minecart.tile
            local tilePos = tile.pos
            local lx, ly = Rails.getLocalPos(tile.rail, minecart.progress)
            UIMultiplayer.addFloatingText("+10", tilePos.x + lx, tilePos.y + ly)
            minecart.deltaScore(10)
            Event.portalDiamond()
        end
    end,
    screenPos = function(minecart)
        local tile = minecart.tile
        local tilePos = tile.pos
        local progress = minecart.progress
        local lx, ly = Rails.getLocalPos(tile.rail, progress)

        local x = tilePos.x + lx
        local y = tilePos.y + ly - TILE_HEIGHT - 1

        return x, y
    end,
    drawMinecart = function(minecart, ox, oy)
        local function getDrawMode()
            if SingleplayerHealth.state ~= HealthState.recovery then
                return gfx.kDrawModeCopy
            end

            local t = playdate.getCurrentTimeMilliseconds() - SingleplayerHealth.damageTime
            local copy = t % 400 > 200

            if copy then
                return gfx.kDrawModeCopy
            end

            return gfx.kDrawModeFillWhite
        end

        local tile = minecart.tile
        local progress = minecart.progress
        local rotation = Rails.getRotation(tile, progress)
        local image = Images.minecartFrames[minecart.index][rotation]
        
        local lx, ly = Minecarts.screenPos(minecart)
        local x, y = ox + lx, oy + ly

        -- jump
        if minecart.jump > 0 then
            -- 1-(2x-1)^2
            local jump = 1 - (2 * minecart.jump - 1)^2
            y -= MINECART_JUMP_HEIGHT * jump
        end

        -- portal
        local opacity = 1
        if tile.portal then
            if tile.rail == Rails.NS then
                opacity = minecart.progress / 1000
            else
                opacity = 1 - minecart.progress / 1000
            end
        end

        gfx.setImageDrawMode(getDrawMode())
        image:drawFaded(x, y, opacity, dither)
        gfx.setImageDrawMode(gfx.kDrawModeCopy)

        Collectables.draw(minecart.collectable, x - 1, y - 20)
    end,
    drawMask = function(radius)
        local mask = gfx.image.new(400, 240, playdate.graphics.kColorBlack)

        gfx.pushContext(mask)
        gfx.setColor(gfx.kColorWhite)

        local active = Minecarts.active

        for i = 1, #active, 1 do
            local minecart = active[i]
            local tile = minecart.tile
            local tilePos = tile.pos
            local progress = minecart.progress
            local lx, ly = Rails.getLocalPos(tile.rail, progress)
            gfx.fillCircleAtPoint(tilePos.x + lx + 16, tilePos.y + ly, radius)
        end

        gfx.popContext()

        gfx.setImageDrawMode(gfx.kDrawModeWhiteTransparent)
        mask:draw(0, 0)
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
    end,
}

for i = 1, MINECART_COUNT do
    Minecarts.data[i] = {
        index = i,
        speed = 0,
        tile = nil,
        jump = -1,
        switch = {},
        input = 1,
        pending_collection = false,
        direction = 1,
        collectable = nil,
        collectableTimer = nil,
        thumbnail = Images.minecartThumbs[i],
        deltaScore = function(delta) end,
    }
end
