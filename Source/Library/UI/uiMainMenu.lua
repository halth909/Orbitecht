import 'uiBottomBanner.lua'

local gfx = playdate.graphics
local dither = gfx.image.kDitherTypeBayer8x8

UIMainMenu = {
    selectY = nil,
    draw = function()
        UI.drawFrame(400)

        local titleAnimator = State.uiAnimator
        local c = titleAnimator:currentValue() / 1000

        local x = 50
        local y = 30 - 30 * c
        Images.title:drawFaded(x, y, titleAnimator:progress(), dither)

        local options = StateMainMenu.options
        local offset = c * 150

        for i = 1, #options, 1 do
            local option = options[i]
            x = 65 - 100 * c
            y = 80 + 25 * i + offset
            gfx.drawInvertedTextAligned(option.label, x, y, kTextAlignment.left)

            if not option.enabled then
                gfx.setColor(gfx.kColorWhite)
                gfx.fillRect(x - 6, y + 9, 90, 2)
            end
        end

        local current = StateMainMenu.currentIndex
        y = 78 + 25 * current

        if UIMainMenu.selectY == nil then
            UIMainMenu.selectY = y
        else
            UIMainMenu.selectY = lerp(UIMainMenu.selectY, y, 0.3)
        end

        gfx.setImageDrawMode(gfx.kDrawModeXOR)
        Images.selected:draw(x - 10, UIMainMenu.selectY + offset)
        gfx.setImageDrawMode(gfx.kDrawModeCopy)

        UIBottomBanner.draw("⬇ Select   Ⓐ Confirm", 0, 10)
    end
}