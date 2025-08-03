local gfx = playdate.graphics
local dither = gfx.image.kDitherTypeBayer8x8

UISlides = {
    draw = function()
        local c = State.uiAnimator:currentValue() / 1000
        local p = State.uiAnimator:progress()
        local y = 30 * c

        local deck = StateSlides.deck
        local page = deck[StateSlides.page]
        local lines = page.lines
        local lineCount = #lines
        local yOffset = 25 * (4 - lineCount / 2) - 10

        local remainingChars = StateSlides.characters

        gfx.setStencilPattern(p, dither)

        local function drawString(line, x, y, alignment)
            local length = string.len(line)

            if length > remainingChars then
                line = string.sub(line, 1, remainingChars)
                length = remainingChars
            end

            gfx.drawInvertedTextAligned(line, x, y, alignment)
            remainingChars -= length
        end

        for i = 1, lineCount, 1 do
            if remainingChars == 0 then
                goto continue
            end

            local line = lines[i]
            local lineY = y + yOffset + 25 * i

            if type(line) == "string" then
                local width = Fonts.alphaOne:getTextWidth(line)
                drawString(line, 200 - width / 2, lineY, kTextAlignment.left)
            else
                drawString(line[1], 30, lineY, kTextAlignment.left)
                drawString(line[2], 200, lineY, kTextAlignment.left)
            end
        end

        ::continue::

        gfx.clearStencil()

        local pageText = string.format("%d OF %d", StateSlides.page, #deck)
        gfx.drawInvertedTextAligned(pageText, 380, 205, kTextAlignment.right)

        UI.drawFrame(400)
        UIBottomBanner.draw("B RETURN   A CONTINUE", 0, 10)
    end
}