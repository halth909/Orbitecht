import 'uiMainMenu.lua'
import 'uiSingleplayer.lua'
import 'uiRoomSelect.lua'
import 'uiCartSelect.lua'
import 'uiMultiplayer.lua'
import 'uiScoreboard.lua'
import 'uiSlides.lua'

local gfx = playdate.graphics

UI = {
    frameSize = 32,
    frameMargin = 0,
    frameImage = Images.frame,

    -- ui functions
    drawFrame = function(width)
        local s = UI.frameSize
        local m = UI.frameMargin
        local image = UI.frameImage
        local smm = s + m
        image:draw(m, m, gfx.kImageFlippedXY)
        image:draw(width - smm, m, gfx.kImageFlippedY)
        image:draw(m, 240 - smm, gfx.kImageFlippedX)
        image:draw(width - smm, 240 - smm)
    end,
    drawMultiplayerScores = function()
        Images.bannerSideLarge:draw(0, 0)

        local imageX = 10
        local textX = 70
        local textY = 4
        local players = Multiplayers.getActive()
        local y = 110 - 16 * #players

        for i = 1, #players, 1 do
            local player = players[i]

            player.minecart.thumbnail:draw(imageX, y)
            gfx.drawInvertedTextAligned(player.score, textX, y + textY, kTextAlignment.right)
            y += 32
        end
    end,
}