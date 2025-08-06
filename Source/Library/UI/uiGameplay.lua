local gfx = playdate.graphics

UIGameplay = {
    draw = function()
        gfx.drawInvertedTextAligned("NEXT", 0, 0, kTextAlignment.left)
        Images.orbTable:getImage(BubbleSpawner.buffer.flavor):drawCentered(17, 23)

        UI.drawScore()
    end
}