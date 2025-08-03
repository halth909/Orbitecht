local gfx = playdate.graphics

UIGameplay = {
    draw = function()
        gfx.drawInvertedTextAligned("Next", 0, 0, kTextAlignment.left)
        gfx.drawInvertedTextAligned("Bubble", 0, 20, kTextAlignment.left)

        gfx.drawInvertedTextAligned("Score", 400, 0, kTextAlignment.right)
        gfx.drawInvertedTextAligned(StateGameplay.score, 400, 20, kTextAlignment.right)
    end
}