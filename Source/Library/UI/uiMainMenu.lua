import 'uiBottomBanner.lua'

local gfx = playdate.graphics
local dither = gfx.image.kDitherTypeBayer8x8

UIMainMenu = {
    selectY = nil,
    draw = function()
        UI.drawFrame(400)

        local titleAnimator = State.uiAnimator
        local c = titleAnimator:currentValue() / 1000

        local x = -100 * c
        local y = 0
        Images.titleLeft:drawFaded(x, y, titleAnimator:progress(), dither)
        x = 100 * c
        Images.titleRight:drawFaded(x, y, titleAnimator:progress(), dither)

        local options = StateMainMenu.options
        local offset = c * 150

        for i = 1, #options, 1 do
            local option = options[i]
            x = 200
            y = 90 + 30 * i + offset
            gfx.drawInvertedTextAligned(option.label, x, y, kTextAlignment.center)

            if not option.enabled then
                gfx.setColor(gfx.kColorWhite)
                gfx.fillRect(x - 6, y + 9, 90, 2)
            end
        end

        local current = StateMainMenu.currentIndex
        y = 82 + 30 * current

        if UIMainMenu.selectY == nil then
            UIMainMenu.selectY = y
        else
            UIMainMenu.selectY = lerp(UIMainMenu.selectY, y, 0.3)
        end

        gfx.setImageDrawMode(gfx.kDrawModeXOR)
        Images.selected:draw(150, UIMainMenu.selectY + offset)
        gfx.setImageDrawMode(gfx.kDrawModeCopy)

        UIBottomBanner.draw("⬇ SELECT   Ⓐ CONFIRM", 0, 10)
    end
}