local gfx = playdate.graphics

UIGameplay = {
    draw = function()        
        gfx.drawInvertedTextAligned("1234", 200, 0, kTextAlignment.center)
    end
}