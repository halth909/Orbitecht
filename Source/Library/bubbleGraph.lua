import "events.lua"

BubbleGraph = {
    roots = {},
    addRoot = function(node)
        table.insert(BubbleGraph.roots, node)
    end,
    resolveNodeCollision = function(node, bubble)
        local lwx = bubble.x - SPINNER_POSITION_X
        local lwy = bubble.y - SPINNER_POSITION_Y
        local spinnerAngleRadians = Spinner.angleRadians
        local radius, radians = Coordinates.cartesianToPolar(lwx, lwy)
        table.insert(node.children, {
            bubble = bubble,
            radius = radius,
            radians = radians - spinnerAngleRadians,
            children = {}
        })
    end,
    resolveNodeCollisions = function(node, bubble)
        if DEBUG then
            playdate.graphics.drawLine(bubble.x, bubble.y, node.bubble.x, node.bubble.y)
        end

        local resolveNodeCollisions = BubbleGraph.resolveNodeCollisions

        -- resolve children
        local children = node.children
        for i = 1, #children, 1 do
            bubble = resolveNodeCollisions(children[i], bubble);

            if bubble == nil then
                return nil
            end
        end

        -- resolve self
        local lwx = bubble.x - node.bubble.x
        local lwy = bubble.y - node.bubble.y
        local distance = math.sqrt(lwx * lwx + lwy * lwy)
        local minDistance = node.bubble.radius + bubble.radius
        local collision = distance < minDistance

        if collision then
            print("COLLISION")
            BubbleGraph.resolveNodeCollision(node, bubble)
            bubble = nil
        end

        return bubble
    end,
    resolveCollisions = function(bubble)
        local resolveNodeCollisions = BubbleGraph.resolveNodeCollisions
        local roots = BubbleGraph.roots

        for i = 1, #roots, 1 do
            local node = roots[i]

            bubble = resolveNodeCollisions(node, bubble)
            if bubble == nil then
                goto breakloop
            end
        end

        ::breakloop::

        return bubble
    end,
    updateNode = function(node)
        local updateNode = BubbleGraph.updateNode

        -- update children
        local children = node.children
        for i = 1, #children, 1 do
            updateNode(children[i]);
        end

        -- update self
        local bubble = node.bubble
        local radians = node.radians + Spinner.angleRadians
        local x, y = Coordinates.polarToCartesian(node.radius, radians)
        bubble.x, bubble.y = SPINNER_POSITION_X + x, SPINNER_POSITION_Y + y
    end,
    update = function()
        local updateNode = BubbleGraph.updateNode

        local roots = BubbleGraph.roots
        for i = 1, #roots, 1 do
            updateNode(roots[i])
        end
    end,
    drawNode = function(node)
        local drawNode = BubbleGraph.drawNode

        -- draw children
        local children = node.children
        for i = 1, #children, 1 do
            drawNode(children[i]);
        end

        -- draw node
        Bubbles.drawBubble(node.bubble)
    end,
    draw = function()
        local drawNode = BubbleGraph.drawNode

        local roots = BubbleGraph.roots
        for i = 1, #roots, 1 do
            drawNode(roots[i]);
        end
    end
}

