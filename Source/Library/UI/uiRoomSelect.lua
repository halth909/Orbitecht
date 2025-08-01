import 'uiBottomBanner.lua'

local gfx = playdate.graphics

UIRoomSelect = {
    draw = function()
        local index = StateRoomSelect.currentIndex
        local y = StateRoomSelect.animatorIn:currentValue()
        Rooms.getPreviewImage(index):draw(RoomCurrent.backgroundOffset, y)

        index = StateRoomSelect.previousIndex
        y = StateRoomSelect.animatorOut:currentValue()
        Rooms.getPreviewImage(index):draw(RoomCurrent.backgroundOffset, y)

        UI.drawFrame(400)

        local indexString
        if StateRoomSelect.currentIndex == nil then
            indexString = "?/" .. #Rooms.multiplayer
        else
            indexString = StateRoomSelect.currentIndex .. "/" .. #Rooms.multiplayer
        end

        local halfFontHeight = gfx.getFont():getHeight() // 2

        local offset = State.uiAnimator:currentValue() * -79 / 1000

        Images.bannerSideSmall:draw(offset,0)

        gfx.drawInvertedTextAligned("Arena", 45 + offset, 94 - halfFontHeight, kTextAlignment.center)
        gfx.drawInvertedTextAligned(indexString, 58 + offset, 120 - halfFontHeight, kTextAlignment.right)
        gfx.drawInvertedTextAligned("⬇", 46 + offset, 146 - halfFontHeight, kTextAlignment.center)

        UIBottomBanner.draw("Ⓑ Return   Ⓐ Confirm", 44, 10)
    end
}
