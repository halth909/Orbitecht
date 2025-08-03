SaveData = {
    data = {
        frameTarget = FRAME_TARGET_DEFAULT,
        highScores = {},
    },
    load = function()
        local saveData = playdate.datastore.read()

        if saveData ~= nil then
            SaveData.data = saveData
        end

        SaveData.apply()
    end,
    apply = function()
        FRAME_TARGET = SaveData.data.frameTarget
        playdate.display.setRefreshRate(FRAME_TARGET)
        playdate.datastore.write(SaveData.data)
    end,
    setFrameTarget = function(value)
        playdate.display.setRefreshRate(value)
        SaveData.data.frameTarget = value
        SaveData.apply()
    end,
    addHighScore = function(score)
        local highScores = SaveData.data.highScores
        table.insert(highScores, score)

        printTable(highScores)

        table.sort(highScores, function(a, b) return a > b end)

        -- save 16 only
        while #highScores > 16 do
            table.remove(highScores, #highScores)
        end
        
        SaveData.apply()
    end,
}

