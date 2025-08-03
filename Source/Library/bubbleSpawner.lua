import "events.lua"

BubbleSpawner = {
    count = nil,
    flavors = nil,
    flavorVelocity = nil,
    speed = nil,
    speedAcceleration = nil,
    load = function()
        BubbleSpawner.count = 0
        BubbleSpawner.flavors = 1
        BubbleSpawner.flavorVelocity = 0.3
        BubbleSpawner.speed = 2
        BubbleSpawner.speedAcceleration = 0.05

        BubbleSpawner.spawn()
    end,
    spawn = function()
        local angleDegrees = math.random(360)
        local radians = math.rad(angleDegrees)
        local vx = math.cos(radians)
        local vy = math.sin(radians)
        table.insert(Bubbles.data, {
            flavor = math.random(math.floor(BubbleSpawner.flavors)),
            radius = BUBBLE_RADIUS,
            x = SPINNER_POSITION_X - vx * BUBBLE_SPAWN_RADIUS,
            y = SPINNER_POSITION_Y - vy * BUBBLE_SPAWN_RADIUS,
            vx = vx * BubbleSpawner.speed,
            vy = vy * BubbleSpawner.speed
        })

        printTable(Bubbles.data)

        BubbleSpawner.flavors += BubbleSpawner.flavorVelocity
        BubbleSpawner.flavors = math.min(BUBBLE_FLAVORS, BubbleSpawner.flavors)
        BubbleSpawner.speed += BubbleSpawner.speedAcceleration
    end,
    unload = function()
        Bubbles.data = {}
    end,
}

