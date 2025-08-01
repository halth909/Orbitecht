local gfx = playdate.graphics

UISingleplayer = {
    draw = function()
        UI.drawFrame(400)
        
        local texts = UIMultiplayer.floatingTexts
        for i = #texts, 1, -1 do
            local text = texts[i]
            gfx.drawInvertedText(text.text, text.x, text.y)
        end

        Images.bannerSideLarge:draw(0, 0)

        local health = SingleplayerHealth.current
        local y = 60

        for i = 1, PLAYER_HEALTH, 1 do
            local x = i * 14
            if i < health + 1 then
                Images.healthFull:draw(x, y)
            else
                Images.healthEmpty:draw(x, y)
            end
        end

        for i = 1, PLAYER_HEALTH, 1 do
            local x = i * 14
            if i < health + 1 then
                Images.healthFull:draw(x, y)
            else
                Images.healthEmpty:draw(x, y)
            end
        end

        y = 152
        gfx.drawInvertedTextAligned(Boss.name, 42, y, kTextAlignment.center)
        
        y = 172
        for i = 1, BossHealth.max, 1 do
            local x = 28 + i * 14 - BossHealth.max * 7
            if i < BossHealth.current + 1 then
                Images.bossHealthFull:draw(x, y)
            else
                Images.bossHealthEmpty:draw(x, y)
            end
        end
    end
}