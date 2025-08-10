import "events.lua"

BubbleGraph = {
    roots = {},
    addRoot = function(node)
        table.insert(BubbleGraph.roots, node)
    end,
    destroyChain = function(flavor, chainRoot)
        local destroyChain = BubbleGraph.destroyChain
        for i = #chainRoot.children, 1, -1 do
            local child = chainRoot.children[i]
            destroyChain(flavor, child)
        end

        if chainRoot.bubble.flavor ~= flavor then
            Bubbles.resetVelocity(chainRoot.bubble)
        end

        if chainRoot.parent ~= nil then
            table.removeByReference(chainRoot.parent.children, chainRoot)
        end

        if table.contains(BubbleGraph.roots, chainRoot) then
            table.removeByReference(BubbleGraph.roots, chainRoot)
        end
    end,
    measureChain = function(flavor, chainRoot)
        local measureChain = BubbleGraph.measureChain
        local chainLength = 0

        for i = #chainRoot.children, 1, -1 do
            local child = chainRoot.children[i]
            chainLength += measureChain(flavor, child)
        end

        if chainRoot.bubble.flavor == flavor then
            chainLength += 1
        end

        return chainLength
    end,
    resolveNodeCollision = function(node, bubble)
        local lwx = bubble.x - SPINNER_POSITION_X
        local lwy = bubble.y - SPINNER_POSITION_Y
        local spinnerAngleRadians = Spinner.angleRadians
        local radius, radians = Coordinates.cartesianToPolar(lwx, lwy)

        local newNode = {
            bubble = bubble,
            radius = radius,
            radians = radians - spinnerAngleRadians,
            parent = node,
            children = {},
        }

        table.insert(node.children, newNode)

        local chainRoot = newNode
        while chainRoot.parent ~= nil and chainRoot.parent.bubble.flavor == chainRoot.bubble.flavor do
            chainRoot = chainRoot.parent
        end

        local flavor = chainRoot.bubble.flavor
        local chainLength = BubbleGraph.measureChain(flavor, chainRoot)

        if chainLength > 2 then
            BubbleGraph.destroyChain(flavor, chainRoot)
            StateGameplay.score += bubble.flavor * chainLength * chainLength
            Event.orbCollect()
            return
        end

        Event.orbImpact()

        if radius > SPINNER_RADIUS_OUTER then
            StateGameplay.lose(lwx > 0)
        end
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
        local collision, x, y = Collision.resolve(
            node.bubble.x, node.bubble.y, node.bubble.radius,
            bubble.x, bubble.y, bubble.radius)

        if collision then
            bubble.x = x
            bubble.y = y
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
    end,
    unload = function()
        BubbleGraph.roots = {}
    end,
}
