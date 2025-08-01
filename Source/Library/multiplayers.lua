Multiplayers = {
    data = {},

    -- players functions
    init = function()
        for i = 1, MAX_PLAYERS, 1 do
            Multiplayers.data[i] = {
                score = 0,
                minecart = nil,
            }
        end
    end,
    getActive = function()
        local result = {}
        for _, player in pairs(Multiplayers.data) do
            if player.minecart ~= nil then
                table.insert(result, player)
            end
        end
        return result
    end,
    switch = function(playerIndex)
       local player = Multiplayers.data[playerIndex]

       if player.minecart == nil then
            return
       end

       Minecarts.switch(player.minecart)
    end,

    -- player functions
    getMinecartIndex = function(player)
        if player.minecart == nil then
            return 0
        end

        return player.minecart.index
    end,
}
