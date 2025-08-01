Singleplayer = {
    room = { x = -1, y = -1 },
    minecart = Minecarts.data[2],
    jump = function()
        print("player jump")
        Minecarts.jump(Singleplayer.minecart)
    end,
    switch = function()
        print("player switch")
        
        if Singleplayer.minecart == nil then
             return
        end

        Minecarts.switch(Singleplayer.minecart)
    end,
    direction = function(x, y)
        print("player direction " .. x .. " " .. y)

        if y == 1 then
            Minecarts.reverse(Singleplayer.minecart)
        end
    end,
    getMinecartIndex = function()
        if SinglePlayer.minecart == nil then
            return 0
        end

        return SinglePlayer.minecart.index
    end,
    update = function()
        SingleplayerTileHistory.update()
    end
}

SingleplayerTileHistory = {
    history = {},
    currentTile = nil,
    update = function()
        local history = SingleplayerTileHistory.history

        local newCurrentTile = Singleplayer.minecart.tile
        if SingleplayerTileHistory.currentTile == newCurrentTile then
            return
        end

        SingleplayerTileHistory.currentTile = newCurrentTile
        table.insert(history, {
            tile = newCurrentTile,
            rail = newCurrentTile.rail,
            direction = Singleplayer.minecart.direction
        })

        if #history > 10 then
            table.remove(history, 1)
        end

        SingleplayerTileHistory.history = history
    end
}