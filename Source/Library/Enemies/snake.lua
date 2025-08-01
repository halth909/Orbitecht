import '../rails.lua'

local gfx = playdate.graphics

local snakeTable = playdate.graphics.imagetable.new("Images/snake")
local snakeheadTable = playdate.graphics.imagetable.new("Images/snakehead")

local snakeParts = {}
snakeParts[Rails.NS] = {
    {
        {
            image = snakeheadTable:getImage(1, 1),
            flip = gfx.kImageFlippedX
        },
        {
            image = snakeheadTable:getImage(1, 2),
            flip = gfx.kImageUnflipped
        }
    },
    {
        {
            image = snakeTable:getImage(1, 1),
            flip = gfx.kImageFlippedX
        },
        {
            image = snakeTable:getImage(1, 1),
            flip = gfx.kImageFlippedX
        }
    },
    {
        {
            image = snakeTable:getImage(2, 1),
            flip = gfx.kImageFlippedX
        },
        {
            image = snakeTable:getImage(3, 1),
            flip = gfx.kImageFlippedX
        }
    },
}
snakeParts[Rails.EW] = {
    {
        {
            image = snakeheadTable:getImage(1, 2),
            flip = gfx.kImageFlippedX
        },
        {
            image = snakeheadTable:getImage(1, 1),
            flip = gfx.kImageUnflipped
        }
    },
    {
        {
            image = snakeTable:getImage(1, 1),
            flip = gfx.kImageUnflipped
        },
        {
            image = snakeTable:getImage(1, 1),
            flip = gfx.kImageUnflipped
        }
    },
    {
        {
            image = snakeTable:getImage(3, 1),
            flip = gfx.kImageUnflipped
        },
        {
            image = snakeTable:getImage(2, 1),
            flip = gfx.kImageUnflipped
        }
    },
}
snakeParts[Rails.NE] = {
    {
        {
            image = snakeheadTable:getImage(1, 1),
            flip = gfx.kImageUnflipped
        },
        {
            image = snakeheadTable:getImage(1, 2),
            flip = gfx.kImageUnflipped
        }
    },
    {
        {
            image = snakeTable:getImage(1, 2),
            flip = gfx.kImageUnflipped
        },
        {
            image = snakeTable:getImage(1, 2),
            flip = gfx.kImageUnflipped
        }
    },
    {
        {
            image = snakeTable:getImage(2, 2),
            flip = gfx.kImageUnflipped
        },
        {
            image = snakeTable:getImage(3, 2),
            flip = gfx.kImageUnflipped
        }
    },
}
snakeParts[Rails.SE] = {
    {
        {
            image = snakeheadTable:getImage(1, 1),
            flip = gfx.kImageFlippedX
        },
        {
            image = snakeheadTable:getImage(1, 1),
            flip = gfx.kImageUnflipped
        }
    },
    {
        {
            image = snakeTable:getImage(1, 3),
            flip = gfx.kImageUnflipped
        },
        {
            image = snakeTable:getImage(1, 3),
            flip = gfx.kImageUnflipped
        }
    },
    {
        {
            image = snakeTable:getImage(3, 3),
            flip = gfx.kImageUnflipped
        },
        {
            image = snakeTable:getImage(2, 3),
            flip = gfx.kImageUnflipped
        }
    },
}
snakeParts[Rails.SW] = {
    {
        {
            image = snakeheadTable:getImage(1, 2),
            flip = gfx.kImageFlippedX
        },
        {
            image = snakeheadTable:getImage(1, 1),
            flip = gfx.kImageFlippedX
        }
    },
    {
        {
            image = snakeTable:getImage(1, 4),
            flip = gfx.kImageUnflipped
        },
        {
            image = snakeTable:getImage(1, 4),
            flip = gfx.kImageUnflipped
        }
    },
    {
        {
            image = snakeTable:getImage(2, 4),
            flip = gfx.kImageUnflipped
        },
        {
            image = snakeTable:getImage(3, 4),
            flip = gfx.kImageUnflipped
        }
    },
}
snakeParts[Rails.NW] = {
    {
        {
            image = snakeheadTable:getImage(1, 2),
            flip = gfx.kImageFlippedX
        },
        {
            image = snakeheadTable:getImage(1, 2),
            flip = gfx.kImageUnflipped
        }
    },
    {
        {
            image = snakeTable:getImage(1, 5),
            flip = gfx.kImageUnflipped
        },
        {
            image = snakeTable:getImage(1, 5),
            flip = gfx.kImageUnflipped
        }
    },
    {
        {
            image = snakeTable:getImage(3, 5),
            flip = gfx.kImageUnflipped
        },
        {
            image = snakeTable:getImage(2, 5),
            flip = gfx.kImageUnflipped
        }
    },
}

Snake = {
    present = false,
    length = nil,
    progress = nil,
    positionQueue = {},
    positions = {},
    spawn = function()
        Snake.present = true
        Snake.length = 4
        Snake.progress = -10000
        Snake.positionQueue = {}
        Snake.positions = {}
    end,
    unload = function()
        for i = 1, #Snake.positions, 1 do
            Snake.positions[i].tile.snakeData = nil
        end

        Snake.present = false
        Snake.length = nil
        table.clear(Snake.positionQueue)
        table.clear(Snake.positions)
    end,
    setOnDraw = function(position, type)
        position.type = type
        position.tile.snakeData = position
    end,
    update = function()
        if not Snake.present then
            return false
        end

        local history = SingleplayerTileHistory.history

        if #history == 0 then
            return
        end

        local positionQueue = Snake.positionQueue

        if history[#history] ~= positionQueue[#positionQueue] then
            table.insert(positionQueue, history[#history])
        end

        -- update snake progress
        local speed = Minecarts.speedDefault
        Snake.progress = Snake.progress + speed / FRAME_TARGET

        local positions = Snake.positions

        -- trim snake if necessary
        for i = #positions, Snake.length + 1, -1 do
            positions[i].tile.snakeData = nil
            table.remove(positions, i)
        end

        -- increment position if necessary
        local currentLength = 0
        if #positions > 0 then
            currentLength = positions[1].rail.length
        end

        if Snake.progress > currentLength then
            Snake.progress -= currentLength

            local next = positionQueue[1]
            table.remove(positionQueue, 1)
            table.insert(positions, 1, next)

            -- collect diamond
            local collectable = next.tile.collectable
            if collectable ~= nil then
                next.tile.collectable = nil
                collectable.count -= 1

                if collectable == Collectables.diamond then
                    Snake.length += 1
                end
            end

            if #positions > Snake.length then
                positions[#positions].tile.snakeData = nil
                table.remove(positions, #positions)
            end
        end

        local setOnDraw = Snake.setOnDraw

        if #positions > 0 then
            setOnDraw(positions[#positions], 3)
     
            for i = 2, #positions - 1, 1 do
                setOnDraw(positions[i], 2)
            end
    
            setOnDraw(positions[1], 1)
        end

        Snake.positionQueue = positionQueue
        Snake.positions = positions
    end,
    resolveCollisions = function()
        if not Snake.present then
            return false
        end

        local minecarts = Minecarts.active
        local positions = Snake.positions

        local pt
        local m

        for i = 1, #positions, 1 do
            pt = positions[i].tile

            for j = 1, #minecarts, 1 do
                m = minecarts[j]

                if m.tile ~= pt then
                    goto nextMinecart
                end

                if not Minecarts.isGrounded(m) then
                    goto nextMinecart
                end

                SingleplayerHealth.decrement()

                if DEBUG then
                    print("COLLISION WITH SNAKE")
                end

                ::nextMinecart::
            end

            if i == 1 then
                goto nextPosition
            end

            if pt == positions[1].tile then
                BossHealth.decrement()

                if BossHealth.current == 0 then
                    Collectables.addOneAt(Collectables.key, positions[1].tile)
                    Snake.unload()
                    goto out
                end

                Snake.length = 4
                
                if DEBUG then
                    print("SNAKE SELF COLLISION")
                end
            end

            ::nextPosition::
        end

        ::out::
    end,
    drawOne = function(position)
        local rail = position.rail
        local tile = position.tile
        local type = position.type
        local direction = 1.5 + position.direction / 2

        local part = snakeParts[rail][type][direction]

        local xOffset = 0
        local yOffset = 0

        if rail == Rails.NS and type > 1 then
            xOffset = -1
        elseif rail == Rails.EW and type == 1 then
            xOffset = -1
        elseif rail == Rails.SW then
            yOffset = 1
        end

        if type == 1 then
            yOffset -= 3
        end

        local tilePos = tile.pos
        local x = tilePos.x - 1 + xOffset
        local y = tilePos.y - 8 + yOffset
        part.image:draw(x, y, part.flip)
    end
}