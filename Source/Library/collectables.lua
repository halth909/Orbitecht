import 'animator.lua'
import 'timer.lua'

CollectablesSettings = {
    snake = {
        coinCount = 0,
        diamondCount = 2,
        skullCount = 0,
        skullSapInterval = 1000,
        spawnDelay = 1000,
    },
    multiplayer = {
        coinCount = 3,
        diamondCount = 2,
        skullCount = 1,
        skullSapInterval = 1000,
        spawnDelay = 1000,
    }
}

Collectables = {
    settings = CollectablesSettings.multiplayer,
    currentTimer = nil,
    -- collectables functions
    addOneAt = function(template, tile)
        tile.collectable = template
        template.count += 1
    end,
    queueOne = function(template)
        local function addOne()
            local success, openTile = Tiles.tryGetOpen(1)
            if not success then return end

            openTile[1].collectable = template
            Collectables.currentTimer = nil
        end

        template.count += 1
        Collectables.currentTimer = Timer.new(Collectables.settings.spawnDelay, addOne);
    end,
    update = function()
        local queueOne = Collectables.queueOne

        if Collectables.currentTimer ~= nil then
            return
        end

        if Collectables.coin.count < Collectables.settings.coinCount then
            queueOne(Collectables.coin)
            return
        end

        if Collectables.diamond.count < Collectables.settings.diamondCount then
            queueOne(Collectables.diamond)
            return
        end

        if Collectables.skull.count < Collectables.settings.skullCount then
            queueOne(Collectables.skull)
            return
        end
    end,
    unload = function()
        Collectables.coin.count = 0
        Collectables.diamond.count = 0
        Collectables.skull.count = 0

        if Collectables.currentTimer ~= nil then
            Timer.cancel(Collectables.currentTimer)
            Collectables.currentTimer = nil
        end
    end,

    -- collectable functions
    draw = function(collectable, x, y)
        if collectable == nil then
            return
        end

        Animator.draw(collectable.animator, x + 7, y - 9)
    end,
}

local imageTable
local animator

-- coin
imageTable = playdate.graphics.imagetable.new( "Images/coin" )
animator = Animator.new( 150, imageTable )
Collectables.coin = { animator = animator, count = 0, }

-- diamond
imageTable = playdate.graphics.imagetable.new( "Images/diamond" )
animator = Animator.new( 300, imageTable )
Collectables.diamond = { animator = animator, count = 0, }

-- key
imageTable = playdate.graphics.imagetable.new( "Images/item_key" )
animator = Animator.new( 150, imageTable )
Collectables.key = { animator = animator, count = 0, }

-- skull
imageTable = playdate.graphics.imagetable.new( "Images/skull" )
animator = Animator.new( 100, imageTable )
Collectables.skull = { animator = animator, count = 0, }