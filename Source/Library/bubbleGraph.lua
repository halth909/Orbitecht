import "events.lua"

BubbleGraph = {
    roots = {},
    resolveCollisions = function(bubble)
        local roots = BubbleGraph.roots
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

        table.insert(roots, {
            bubble = bubble,
            radius = radius,
            radians = radians - spinnerAngleRadians,
            bubbles = {}
        })
    end,
    update = function()
        local spinnerAngleRadians = Spinner.angleRadians
        local roots = BubbleGraph.roots
        for i = 1, #roots, 1 do
            local node = roots[i]
            local bubble = node.bubble
            local radians = node.radians + spinnerAngleRadians
            local x, y = Coordinates.polarToCartesian(node.radius, radians)
            bubble.x, bubble.y = SPINNER_POSITION_X + x, SPINNER_POSITION_Y + y
            Bubbles.drawBubble(node.bubble)
        end
    end,
    draw = function()
        local roots = BubbleGraph.roots
        for i = 1, #roots, 1 do
            local node = roots[i]
            Bubbles.drawBubble(node.bubble)
        end
    end
}

