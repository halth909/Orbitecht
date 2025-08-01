import "events.lua"
import "Assets/Images"

local gfx = playdate.graphics

Spinner = {
    angleDegrees = 0,
    update = function()
        if playdate:isCrankDocked() then
            playdate.ui.crankIndicator:draw()
            return
        end
        
        Spinner.angleDegrees = playdate.getCrankPosition()
    end,
    draw = function()
        local x = SPINNER_POSITION_X
        local y = SPINNER_POSITION_Y
        playdate.graphics.setColor(gfx.kColorWhite)
        gfx.fillCircleAtPoint(x, y, 30)
        gfx.drawCircleAtPoint(x, y, 90)

        local radius = SPINNER_RADIUS_INNER - 6
        local radians = math.rad(Spinner.angleDegrees)
        x = SPINNER_POSITION_X + math.cos(radians) * radius
        y = SPINNER_POSITION_Y + math.sin(radians) * radius
        gfx.setColor(gfx.kColorBlack)
        gfx.fillCircleAtPoint(x, y, 4)
    end,
}