VFX = {
    inverted = false,
    invertedEnd = -1,
    invert = function(duration)
        local endTime = playdate.getCurrentTimeMilliseconds() + duration

        if endTime <= VFX.invertedEnd then
            return
        end

        VFX.invertedEnd = endTime
        VFX.inverted = true
        playdate.display.setInverted(true)
    end,
    update = function()
        if not VFX.inverted then
            return
        end

        local currentTime = playdate.getCurrentTimeMilliseconds()

        if currentTime < VFX.invertedEnd then
            return
        end

        VFX.inverted = false
        playdate.display.setInverted(false)
    end
}