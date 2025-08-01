import "events.lua"
import "Assets/Images"

local gfx = playdate.graphics

Bubbles = {
    data = {},
    active = {},

    -- bubbles functions
    resolveCollisions = function(bubble, other)
        if bubble == other then
            return
        end

    end,
    load = function()

    end,
    update = function()
        local updateBubble = Bubbles.updateBubble
        local resolveCollisions = Bubbles.resolveCollisions

        local active = Bubbles.active

        -- move
        for i = 1, #active, 1 do
            updateBubble(active[i])
        end

        -- resolve collisions
        for i = 1, #active, 1 do
            for j = 1, #active, 1 do
                resolveCollisions(active[i], active[j])
            end
        end
    end,
    draw = function()
        local drawBubble = Bubbles.drawBubble

        local active = Bubbles.active
        
        for i = 1, #active, 1 do
            drawBubble(active[i])
        end
    end,
    unload = function()
        Bubbles.active = {}
    end,

    -- bubble functions
    drawBubble = function(bubble)
        local x, y = bubble.x, bubble.y
        gfx.drawCircleAtPoint(x, y, radius)
    end,
}

