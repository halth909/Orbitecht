import 'barrels.lua'
import 'ghosts.lua'
import "snake.lua"

EnemyType = {
    barrels = {},
    ghosts = {}
}

Enemies = {
    update = function()
        Barrels.update()
        Ghosts.update()
        Snake.update()

        Barrels.resolveCollisions()
        Ghosts.resolveCollisions()
        Snake.resolveCollisions()
    end
}

Boss = {
    name = "Snake"
}