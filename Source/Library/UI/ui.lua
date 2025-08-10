import 'uiMainMenu.lua'
import 'uiGameplay.lua'
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
    drawBackground = function()
        Images.background:draw(0,0)
    end,
    drawScore = function()
        gfx.drawInvertedTextAligned("SCORE", 400, 0, kTextAlignment.right)
        gfx.drawInvertedTextAligned(StateGameplay.score, 400, 20, kTextAlignment.right)
    end
}