local gfx = playdate.graphics

UIGameplay = {
    draw = function()
        gfx.drawInvertedTextAligned("NEXT", 0, 0, kTextAlignment.left)
        gfx.drawInvertedTextAligned("BUBBLE", 0, 20, kTextAlignment.left)

        gfx.drawInvertedTextAligned("SCORE", 400, 0, kTextAlignment.right)
        gfx.drawInvertedTextAligned(StateGameplay.score, 400, 20, kTextAlignment.right)
    end
}