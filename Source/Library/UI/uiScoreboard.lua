local gfx = playdate.graphics

UIScoreboard = {
    draw = function()
        -- UI.drawFrame(400)
        local sideOffset = 0 
        if StateScoreboard.rightSide then
            sideOffset = 200
        end

        local currentScore = StateScoreboard.currentScore
        local currentScoreText = math.floor(currentScore)
        gfx.drawInvertedTextAligned(currentScoreText, 42, 162, kTextAlignment.center)

        local c = State.uiAnimator:currentValue() / 1000
        local y = 20 - 40 * c
        gfx.drawInvertedTextAligned("HIGH SCORES", 246, y, kTextAlignment.center)

        local highScores = SaveData.data.highScores
        local highScoresCount = #highScores
        local highlighted = false

        local offset = 180 * c

        for i = 8, 1, -1 do
            local x = sideOffset + 130
            y = offset + (i + 2) * 20

            local score = highScores[i]
            local scoreText

            if highScoresCount < i then
                scoreText = "-"
            else
                scoreText = math.floor(score)
            end

            gfx.drawInvertedTextAligned(i, x, y, kTextAlignment.left)
            gfx.drawInvertedTextAligned(scoreText, x + 100, y, kTextAlignment.right)

            if not highlighted and currentScore == score then
                gfx.setColor(gfx.kColorXOR)
                gfx.fillRoundRect(x - 10, y + 1, 130, 20, 4)
                highlighted = true
            end
        end

        UIBottomBanner.draw("[⊙] MENU", 45, 10)
    end
}