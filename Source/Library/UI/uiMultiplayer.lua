local gfx = playdate.graphics

UIMultiplayer = {
    floatingTexts = {},

    -- ui functions
    addFloatingText = function(text, x, y)
        table.insert(UIMultiplayer.floatingTexts, { text = text, x = x + 16, y = y - 24 })
    end,
    update = function()
        local texts = UIMultiplayer.floatingTexts
        for i = #texts, 1, -1 do
            texts[i].y -= 1
        end

        for i = #texts, 1, -1 do
            if texts[i].y < -20 then
                table.remove(texts, i)
            end
        end
    end,
    draw = function()
        UI.drawFrame(400)
        
        local texts = UIMultiplayer.floatingTexts
        for i = #texts, 1, -1 do
            local text = texts[i]
            gfx.drawInvertedText(text.text, text.x, text.y)
        end

        UI.drawMultiplayerScores()
        
        if StateMultiplayer.timer ~= nil then
            local timeLeft = Timer.remaining(StateMultiplayer.timer)
            local seconds = math.floor(timeLeft / 1000)
            local timerText = string.format("%d:%02d", seconds // 60, seconds % 60)
            gfx.drawInvertedTextAligned(timerText, 42, 162, kTextAlignment.center)
        end
    end
}