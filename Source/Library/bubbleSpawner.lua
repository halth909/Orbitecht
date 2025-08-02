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
        BubbleSpawner.flavorVelocity = 1
        BubbleSpawner.speed = 2
        BubbleSpawner.speedAcceleration = 1

        BubbleSpawner.spawn()
    end,
    spawn = function()
        local radius = 240
        local angleDegrees = math.random(360)
        local radians = math.rad(angleDegrees)
        local vx = math.cos(radians)
        local vy = math.sin(radians)
        Bubbles.active = {
            radius = 4,
            x = SPINNER_POSITION_X - vx * radius,
            y = SPINNER_POSITION_Y - vy * radius,
            vx = vx * BubbleSpawner.speed,
            vy = vy * BubbleSpawner.speed
        }

        printTable(Bubbles.active)
    end,
    unload = function()
        Bubbles.active = nil
    end,
}

