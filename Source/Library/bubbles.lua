import "events.lua"
import "Assets/Images"

local gfx = playdate.graphics

Bubbles = {
    active = nil,

    -- bubbles functions
    load = function()
        BubbleSpawner.load()
    end,
    update = function()
        local active = Bubbles.active
        active.x += active.vx
        active.y += active.vy

        active = BubbleGraph.resolveCollisions(active)

        if active == nil then
            print("test 1")
            BubbleSpawner.spawn()
        end
    end,
    draw = function()
        Bubbles.drawBubble(Bubbles.active)
    end,
    unload = function()
        Bubbles.active = {}
    end,

    -- bubble functions
    drawBubble = function(bubble)
        local x, y = bubble.x, bubble.y
        local offScreen = false
        local ofx = 0
        local ofy = 0

        if x < 0 then
            offScreen = true
            x = 0
            ofx = -1
        elseif 400 < x then
            offScreen = true
            x = 400
            ofx = 1
        end

        if y < 0 then
            offScreen = true
            y = 0
            ofy = -1
        elseif 240 < y then
            offScreen = true
            y = 240
            ofy = 1
        end

        print(x, y)
        gfx.setColor(gfx.kColorWhite)

        if offScreen then
            gfx.setLineWidth(1)
            gfx.drawRect((x - ofx * 5 - 5), (y - ofy * 5 - 5), 10, 10, bubble.radius)
        else
            gfx.fillCircleAtPoint(x, y, bubble.radius)
        end
    end,
}

