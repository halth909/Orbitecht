import "events.lua"
import "Assets/Images"

local gfx = playdate.graphics

Spinner = {
    angleRadians = 0,
    resolveCollisions = function(bubble)
        local lwx = bubble.x - SPINNER_POSITION_X
        local lwy = bubble.y - SPINNER_POSITION_Y
        local distance = math.sqrt(lwx * lwx + lwy * lwy)
        local minDistance = SPINNER_RADIUS_INNER + bubble.radius
        local collision = distance < minDistance

        if not collision then
            return bubble
        end

        local spinnerAngleRadians = Spinner.angleRadians
        local radius, radians = Coordinates.cartesianToPolar(lwx, lwy)
        BubbleGraph.addRoot({
            bubble = bubble,
            radius = radius,
            radians = radians - spinnerAngleRadians,
            children = {}
        })
    end,
    update = function()
        if playdate:isCrankDocked() then
            playdate.ui.crankIndicator:draw()
            return
        end
        
        local degrees = playdate.getCrankPosition()
        Spinner.angleRadians = math.rad(degrees)
    end,
    draw = function()
        local x = SPINNER_POSITION_X
        local y = SPINNER_POSITION_Y
        playdate.graphics.setColor(gfx.kColorWhite)
        gfx.fillCircleAtPoint(x, y, 30)
        gfx.drawCircleAtPoint(x, y, 90)

        local radius = SPINNER_RADIUS_INNER - 6
        local radians = Spinner.angleRadians
        x, y = Coordinates.polarToCartesian(radius, radians)
        x += SPINNER_POSITION_X
        y += SPINNER_POSITION_Y
        gfx.setColor(gfx.kColorBlack)
        gfx.fillCircleAtPoint(x, y, 4)
    end,
}