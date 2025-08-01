local gfx = playdate.graphics

UIScoreboard = {
    draw = function()
        UI.drawFrame(400)

        UI.drawMultiplayerScores()

        local currentScore = StateScoreboard.currentScore
        local currentScoreText = math.floor(currentScore)
        gfx.drawInvertedTextAligned(currentScoreText, 42, 162, kTextAlignment.center)

        local players = Multiplayers.getActive()
        local playerCount = #players
        local headingText = string.format("%d Player High Scores", playerCount)

        local c = State.uiAnimator:currentValue() / 1000
        local y = 20 - 40 * c
        gfx.drawInvertedTextAligned(headingText, 246, y, kTextAlignment.center)

        local highScores = SaveData.data.highScores[playerCount]
        local highScoresCount = #highScores
        local highlighted = false

        local offset = 180 * c

        for i = 16, 1, -1 do
            local x
            local y

            if i < 9 then
                x = 130
                y = offset + (i + 2) * 20
            else
                x = 260
                y = offset + (i - 6) * 20
            end

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

        UIBottomBanner.draw("⊙ Menu", 45, 10)
    end
}