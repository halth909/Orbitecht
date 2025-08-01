local gfx = playdate.graphics

Ghosts = {
    speed = 2000,
    data = {},
    spawn = function(tiles)
        Ghosts.unload()
        
        for i = 1, #tiles, 1 do
            local startTile = tiles[i]
            local headings = { 1, 2, 3, 4 }
            local heading = nil

            for i = 1, #headings, 1 do
                heading = headings[i]
                goalTile = Tiles.getNeighbour(startTile, heading)

                if goalTile ~= nil then
                    goto continue
                end
            end

            ::continue::

            local ghost = {
                startTile = startTile,
                goalTile = goalTile,
                heading = heading,
                progress = 500,
            }
            
            table.insert(Ghosts.data, ghost)
            table.insert(ghost.goalTile.ghosts, ghost)
        end
    end,
    updateGoal = function(ghost)
        -- backHeading
        if ghost.goalTile.portal then
            local temp = ghost.startTile
            ghost.startTile = ghost.goalTile
            ghost.goalTile = temp
            ghost.heading = (ghost.heading + 1) % 4 + 1
            return
        end
        
        ghost.startTile = ghost.goalTile
        local startTile = ghost.startTile
        local headings = { 1, 2, 3, 4 }

        if ghost.heading ~= nil then
            local backHeading = (ghost.heading + 1) % 4 + 1
            table.removeByReference(headings, backHeading)
        end

        table.shuffle(headings)

        local heading = nil
        local goalTile = nil

        for i = 1, #headings, 1 do
            heading = headings[i]
            goalTile = Tiles.getNeighbour(startTile, heading)

            if goalTile ~= nil then
                goto continue
            end
        end
        
        ::continue::

        ghost.heading = heading
        ghost.goalTile = goalTile
    end,
    updateTile = function(ghost)
        table.removeByReference(ghost.startTile.ghosts, ghost)
        table.insert(ghost.goalTile.ghosts, ghost)
    end,
    updateGhost = function(ghost)
        local previousProgress = ghost.progress

        ghost.progress += Ghosts.speed / FRAME_TARGET

        if previousProgress < 500 and 500 <= ghost.progress then
            Ghosts.updateTile(ghost)
        elseif ghost.progress > 1000 then
            Ghosts.updateGoal(ghost)
            ghost.progress -= 1000
        end
    end,
    update = function()
        local ghosts = Ghosts.data

        for i = 1, #ghosts, 1 do
            Ghosts.updateGhost(ghosts[i])
        end
    end,
    unload = function()
        Ghosts.data = {}
    end,
    resolveCollisions = function()
        local minecarts = Minecarts.active
        local ghosts = Ghosts.data

        for i = 1, #minecarts, 1 do
            local m = minecarts[i]

            if not Minecarts.isGrounded(m) then
                goto nextMinecart
            end

            local mx, my = Minecarts.screenPos(m)

            for j = 1, #ghosts, 1 do
                local g = ghosts[j]
                local gx, gy = Ghosts.screenPos(g)

                local ox = mx - gx
                local oy = (my - gy) * 2

                local collision = (ox * ox + oy * oy) < ENEMY_COLLISION_DISTANCE_SQUARED

                if collision then
                    SingleplayerHealth.decrement()
                end

                if DEBUG then
                    if collision then
                        print("COLLISION WITH GHOST")
                    end

                    gfx.setColor(ternary(collision, gfx.kColorBlack, gfx.kColorWhite))
                    gfx.drawLine(mx, my, gx, gy)
                end
            end

            ::nextMinecart::
        end
    end,

    -- ghost functions
    screenPos = function(ghost)
        local function getProgress()
            if ghost.heading < 3 then
                return (1499 - ghost.progress) % 1000
            end
            
            return (ghost.progress + 500) % 1000
        end

        local ghostTile = ternary(ghost.progress < 500, ghost.startTile, ghost.goalTile)
        local ghostTilePos = ghostTile.pos
        local ox = ghostTilePos.x
        local oy = ghostTilePos.y

        local rail = ternary(ghost.heading % 2 == 0, Rails.EW, Rails.NS)
        local progress = getProgress()
        local rx, ry = Rails.getLocalPos(rail, progress)
        return ox + rx, oy + ry - 12
    end,
    draw = function(ghost)
        if ghost == nil then
            return
        end

        local x, y = Ghosts.screenPos(ghost)
        Images.ghostFrames[ghost.heading]:draw(x, y)
    end,
}