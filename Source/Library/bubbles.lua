import "events.lua"
import "Assets/Images"

local gfx = playdate.graphics

Bubbles = {
    data = {},

    -- bubbles functions
    load = function()
        BubbleSpawner.load()
    end,
    update = function()
        local data = Bubbles.data
        local bubble

        for i = #data, 1, -1 do
            bubble = data[i]
            bubble.x += bubble.vx
            bubble.y += bubble.vy

            bubble = Spinner.resolveCollisions(bubble)

            if bubble ~= nil then
                bubble = BubbleGraph.resolveCollisions(bubble)
            end

            if bubble == nil then
                table.remove(data, i)
            end
        end

        if #data == 0 then
            BubbleSpawner.spawn()
        end
    end,
    draw = function()
        local drawBubble = Bubbles.drawBubble
        local data = Bubbles.data
        for i = 1, #data, 1 do
            drawBubble(data[i])
        end
    end,
    unload = function()
        Bubbles.data = {}
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

        gfx.setColor(gfx.kColorWhite)

        if offScreen then
            gfx.setLineWidth(1)
            gfx.drawRect((x - ofx * 5 - 5), (y - ofy * 5 - 5), 10, 10, bubble.radius)
        end

        Images.orbTable:draw(x, y)
    end,
}

