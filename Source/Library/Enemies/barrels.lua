local gfx = playdate.graphics

BarrelState = {
    entering = {},
    active = {},
    exiting = {}
}

Barrels = {
    timeToNext = 0,
    speed = 4000,
    start = nil,
    heading = -1,
    rail = nil,
    direction = 0,
    data = {},
    setPath = function(straight)
        Barrels.unload()

        Barrels.start = straight.start
        Barrels.heading = straight.heading
        Barrels.rail = ternary(straight.heading % 2 == 0, Rails.EW, Rails.NS)
        Barrels.direction = ternary(straight.heading % 2 == 0, -1, 1)

        for i = 1, 100 do
            Barrels.update()
        end
    end,
    updateBarrelEntering = function(barrel)
        barrel.progress += 30

        if barrel.progress > 1000 then
            barrel.state = BarrelState.active
            barrel.progress = 0.5 * Barrels.rail.length
        end
    end,
    updateBarrelExiting = function(barrel)
        barrel.progress += 30

        if barrel.progress > 1000 then
            barrel.tile.barrel = nil
            table.removeByReference(Barrels.data, barrel)
        end
    end,
    updateBarrel = function(barrel)
        if barrel.state == BarrelState.entering then
            Barrels.updateBarrelEntering(barrel)
            return
        elseif barrel.state == BarrelState.exiting then
            Barrels.updateBarrelExiting(barrel)
            return
        end

        local barrelProgress = barrel.progress
        local railLength = Barrels.rail.length

        barrelProgress += Barrels.direction * Barrels.speed / FRAME_TARGET

        local carry

        if barrelProgress > railLength then
            carry = barrelProgress - railLength
        elseif barrelProgress < 0 then
            carry = -barrelProgress
        else
            barrel.progress = barrelProgress
            return
        end

        barrel.tile.barrel = nil

        local nextTile = Tiles.getNeighbour(barrel.tile, Barrels.heading)

        if nextTile == nil then
            barrel.state = BarrelState.exiting
            barrel.progress = 0
            barrel.tile.barrel = barrel
            return
        end

        barrel.tile = nextTile

        if Barrels.direction == 1 then
            barrel.progress = carry
        else
            barrel.progress = railLength - carry
        end

        nextTile.barrel = barrel
    end,
    addOne = function()
        if Barrels.start == nil then
            return
        end

        local start = Barrels.start
        local x = start.x
        local y = start.y

        local instance = {
            tile = Tiles.data[x][y],
            state = BarrelState.entering,
            progress = 0
        }

        table.insert(Barrels.data, instance)
        instance.tile.barrel = instance
    end,
    update = function()
        local updateBarrel = Barrels.updateBarrel
        local addOne = Barrels.addOne
        
        for i = #Barrels.data, 1, -1 do
            updateBarrel(Barrels.data[i])
        end

        Barrels.timeToNext -= 1000 / FRAME_TARGET

        if Barrels.timeToNext < 0 then
            addOne()
            Barrels.timeToNext += BARREL_SPAWN_DELAY
        end
    end,
    unload = function()
        Barrels.start = nil
        Barrels.data = {}

        if Barrels.currentTimer ~= nil then
            Timer.cancel(Barrels.currentTimer)
            Barrels.currentTimer = nil
        end
    end,
    resolveCollisions = function()
        local minecarts = Minecarts.active
        local barrels = Barrels.data

        for i = 1, #minecarts, 1 do
            local m = minecarts[i]

            if not Minecarts.isGrounded(m) then
                goto nextMinecart
            end

            local mx, my = Minecarts.screenPos(m)

            for j = 1, #barrels, 1 do
                local b = barrels[j]
                local bx, by = Barrels.screenPos(b)

                if bx == -1 then
                    goto nextBarrel
                end

                local ox = mx - bx
                local oy = (my - by) * 2

                local collision = (ox * ox + oy * oy) < ENEMY_COLLISION_DISTANCE_SQUARED

                if collision then
                    SingleplayerHealth.decrement()
                end

                if DEBUG then
                    if collision then
                        print("COLLISION WITH BARREL")
                        print(playdate.getCurrentTimeMilliseconds())
                    end
    
                    gfx.setColor(ternary(collision, gfx.kColorBlack, gfx.kColorWhite))
                    gfx.drawLine(mx, my, bx, by)
                end

                ::nextBarrel::
            end

            ::nextMinecart::
        end
    end,

    -- barrel functions
    screenPos = function(barrel)
        if barrel.state ~= BarrelState.active then
            return -1, -1
        end

        local barrelTile = barrel.tile
        local barrelTilePos = barrelTile.pos
        
        local ox = barrelTilePos.x
        local oy = barrelTilePos.y

        local rx, ry = Rails.getLocalPos(Barrels.rail, barrel.progress)

        return ox + rx, oy + ry - 8
    end,
    draw = function(barrel, ox, oy)
        if barrel == nil then
            return
        end

        local rail = Barrels.rail
        local barrelProgress = barrel.progress
        local direction = Barrels.direction
        local railGetLocalPos = Rails.getLocalPos

        local function drawBarrelAt(x, y)
            x += ox
            y += oy

            if Barrels.heading % 2 == 0 then
                Animator.draw(Animators.barrel1, x, y - 8)
            else
                Animator.draw(Animators.barrel2, x, y - 8)
            end
        end

        local function drawBarrelEntering()
            local railProgress = 0.5 * rail.length
            local x, y = railGetLocalPos(rail, railProgress)
            y -= 0.4 * (1000 - barrelProgress)
            drawBarrelAt(x, y)
        end

        local function drawBarrelExiting()
            local x, y = railGetLocalPos(rail, 500 + direction * 500)
            local m = 0.05 * barrelProgress
            x -= m * Barrels.direction
            y += 0.01 * m * barrelProgress
            drawBarrelAt(x, y)
        end

        local barrelState = barrel.state

        if barrelState == BarrelState.entering then
            drawBarrelEntering()
        elseif barrelState == BarrelState.exiting then
            drawBarrelExiting()
        else
            local x, y = railGetLocalPos(Barrels.rail, barrelProgress)
            drawBarrelAt(x, y)
        end
    end,
}