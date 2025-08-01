import 'Assets/images.lua'
import 'constants.lua'

Rails = {
    NS = {
        length = 1000,
        connections = {1, 3},
        progressDirections = {1, nil, -1, nil}, -- lookup by entrance heading
        entrance = { x = TILE_WIDTH / 4, y = -TILE_HEIGHT / 2 },
        exit = { x = -TILE_WIDTH / 4, y = TILE_HEIGHT / 2 },
        defaultImage = Images.railStraight,
        switchImage = Images.railStraightSwitch,
        flip = playdate.graphics.kImageFlippedX,
    },
    EW = {
        length = 1000,
        connections = {2, 4},
        progressDirections =  {nil, 1, nil, -1}, -- lookup by entrance heading
        entrance = { x = TILE_WIDTH / 4, y = TILE_HEIGHT / 2 },
        exit = { x = -TILE_WIDTH / 4, y = -TILE_HEIGHT / 2 },
        defaultImage = Images.railStraight,
        switchImage = Images.railStraightSwitch,
        flip = playdate.graphics.kImageUnflipped,
    },
    LC = { -- room crossing, for prerendering only
        defaultImage = Images.railLevelCrossing,
        flip = playdate.graphics.kImageUnflipped,
    },
    NE = {
        length = 785,
        connections = {1, 2},
        progressDirections = {1, -1, nil, nil}, -- lookup by entrance heading
        entrance = { x = TILE_WIDTH / 4, y = -TILE_HEIGHT / 2 },
        exit = { x = TILE_WIDTH / 4, y = TILE_HEIGHT / 2 },
        defaultImage = Images.railCornerV,
        switchImage = Images.railCornerVSwitch,
        flip = playdate.graphics.kImageFlippedX,
        progressFrames = {1, 4, 3},
    },
    SE = {
        length = 785,
        connections = {2, 3},
        progressDirections =  {nil, 1, -1, nil}, -- lookup by entrance heading
        entrance = { x = TILE_WIDTH / 4, y = TILE_HEIGHT / 2 },
        exit = { x = -TILE_WIDTH / 4, y = TILE_HEIGHT / 2 },
        defaultImage = Images.railCornerH,
        switchImage = Images.railCornerHSwitch,
        flip = playdate.graphics.kImageFlippedY,
        progressFrames = {3, 2, 1},
    },
    SW = {
        length = 785,
        connections = {3, 4},
        progressDirections =  {nil, nil, 1, -1}, -- lookup by entrance heading
        entrance = { x = -TILE_WIDTH / 4, y = TILE_HEIGHT / 2 },
        exit = { x = -TILE_WIDTH / 4, y = -TILE_HEIGHT / 2 },
        defaultImage = Images.railCornerV,
        switchImage = Images.railCornerVSwitch,
        flip = playdate.graphics.kImageUnflipped,
        progressFrames = {1, 4, 3},
    },
    NW = {
        length = 785,
        connections = {1, 4},
        progressDirections = {1, nil, nil, -1}, -- lookup by entrance heading
        entrance = { x = TILE_WIDTH / 4, y = -TILE_HEIGHT / 2 },
        exit = { x = -TILE_WIDTH / 4, y = -TILE_HEIGHT / 2 },
        defaultImage = Images.railCornerH,
        switchImage = Images.railCornerHSwitch,
        flip = playdate.graphics.kImageUnflipped,
        progressFrames = {1, 2, 3},
    },

     -- rails functions
    getOptions = function(headingTileTypes)
        if headingTileTypes[1] == 0 then
            return { Rails.EW, Rails.SE, Rails.SW }
        elseif headingTileTypes[2] == 0 then
            return { Rails.NS, Rails.SW, Rails.NW }
        elseif headingTileTypes[3] == 0 then
            return { Rails.EW, Rails.NW, Rails.NE }
        elseif headingTileTypes[4] == 0 then
            return { Rails.NS, Rails.NE, Rails.SE }
        else -- 4 way
            return { Rails.NS, Rails.EW }
        end
    end,
    getCurrentOrNextOption = function(current, options, withHeading)
        if table.contains(current.connections, withHeading) then
            return current
        end

        return Rails.getNextOption(current, options, withHeading)
    end,
    getNextOption = function(current, options, withHeading)
        local currentIndex = table.indexOf(options, current)

        for i = 1, #options, 1 do
            if i == currentIndex then
                goto continue
            end

            local nextOption = options[i]

            if table.contains(nextOption.connections, withHeading) then
                return nextOption
            end

            ::continue::
        end
    end,
    -- rail functions
    getLocalPos = function(rail, progress)
        if rail == nil then
            return false
        end

        if rail == Rails.NS or rail == Rails.EW then
            local roX = (rail.exit.x - rail.entrance.x) * progress / rail.length
            local roY = (rail.exit.y - rail.entrance.y) * progress / rail.length
            return roX + rail.entrance.x, roY + rail.entrance.y
        end

        local p = 90 * progress / rail.length

        local angle
        local offsetX = 0
        local offsetY = 0

        if rail == Rails.NE then
            angle = 315 - p
            offsetX = 16
        elseif rail == Rails.SE then
            angle = 45 - p
            offsetY = 8
        elseif rail == Rails.SW then
            angle = 135 - p
            offsetX = -16
        elseif rail == Rails.NW then
            angle = 135 + p
            offsetY = -8
        end

        local r = 11.314
        local result = playdate.geometry.vector2D.newPolar(r, angle)
        return offsetX + result.dx, offsetY + result.dy / 2
    end,
    getRotation = function(tile, progress)
        local rail = tile.rail
        if rail == nil then
            return false
        end

        if rail == Rails.NS then
            return 1
        elseif rail == Rails.EW then
            return 3
        end

        local p = progress / rail.length

        if p < 0.25 then
            return rail.progressFrames[1]
        elseif p < 0.75 then
            return rail.progressFrames[2]
        else
            return rail.progressFrames[3]
        end
    end,
    directionToHeading = function(rail, direction)
        return rail.connections[(direction + 3) / 2]
    end,
    draw = function(rail, x, y, powered, switch)
        if powered then
            Animator.draw(Animators.powered, x, y, rail.flip)
        elseif switch then
            rail.switchImage:draw(x, y, rail.flip)
        else
            rail.defaultImage:draw(x, y, rail.flip)
        end
    end
}
