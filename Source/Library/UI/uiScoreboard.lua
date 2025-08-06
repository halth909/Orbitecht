local gfx = playdate.graphics

UIScoreboard = {
    draw = function()
        local c = State.uiAnimator:currentValue() / 1000
        StateScoreboard.backgroundImage:draw(80 * (1 - c), 0)

        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(-80 * c, 0, 160, 240)

        local sideOffset = 40
        if StateScoreboard.rightSide then
            sideOffset = 240
        end

        local currentScore = StateScoreboard.currentScore

        local y = 20 - 40 * c
        gfx.drawInvertedTextAligned("HIGH SCORES", sideOffset + 50, y, kTextAlignment.center)

        local highScores = SaveData.data.highScores
        local highScoresCount = #highScores
        local highlighted = false

        local yOffset = 180 * c

        for i = 8, 1, -1 do
            local x = sideOffset
            y = yOffset + (i + 2) * 20

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
                gfx.fillRoundRect(x - 15, y - 6, 130, 20, 4)
                highlighted = true
            end
        end

        UI.drawScore()

        UIBottomBanner.draw("[⊙] MENU", 45, 10)
    end
}