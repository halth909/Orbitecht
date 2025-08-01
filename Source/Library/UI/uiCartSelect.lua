local gfx = playdate.graphics
local dither = gfx.image.kDitherTypeDiagonalLine

UICartSelect = {
    playerStrings = { "⬇", "Ⓑ", "Ⓐ" },
    draw = function()
        UI.drawFrame(400)

        Rooms.getPreviewImage(StateRoomSelect.currentIndex):draw(RoomCurrent.backgroundOffset, 0)
        
        local offset = State.uiAnimator:currentValue()
        Images.bannerSideLarge:draw(offset, 0)

        local playerStrings = UICartSelect.playerStrings
        local minecartSelections = StateCartSelect.minecartSelections
        local minecartsData = Minecarts.data

        local imageX = 10 + offset

        for i = 1, #minecartSelections, 1 do
            local imageY = 30 + 32 * i

            local playerString = playerStrings[i]
            gfx.drawInvertedTextAligned(playerString, imageX + 50, imageY + 7, kTextAlignment.center)

            local minecartSelection = minecartSelections[i]
            local minecartIndex = minecartSelection.previousIndex

            if minecartIndex ~= nil then
                local anim = 0.02 * minecartSelection.animatorOut:currentValue()
                local minecart = minecartsData[minecartIndex]
                minecart.thumbnail:draw(imageX - 2 * anim, imageY + anim)
            end

            minecartIndex = minecartSelection.currentIndex

            if minecartIndex ~= nil then
                local animator = minecartSelection.animatorIn
                local anim = 0.02 * animator:currentValue()
                local minecart = minecartsData[minecartIndex]
                minecart.thumbnail:drawFaded(imageX + 2 * anim, imageY - anim, 2 * animator:progress(), dither)
            end
        end

        local timerX = 42 + offset

        if StateCartSelect.countdown ~= nil then
            local timeLeft = Timer.remaining(StateCartSelect.countdown)
            local seconds = math.floor(1 + timeLeft / 1000)
            gfx.drawInvertedTextAligned(seconds, timerX, 162, kTextAlignment.center)
        end

        UIBottomBanner.draw("⬇ Ⓑ Ⓐ Select", 44, 10)
    end
}
