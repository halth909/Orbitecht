VFX = {
    inverted = false,
    invertedEnd = -1,
    screenShake = -1,
    invert = function(duration)
        local endTime = playdate.getCurrentTimeMilliseconds() + duration

        if endTime <= VFX.invertedEnd then
            return
        end

        VFX.invertedEnd = endTime
        VFX.inverted = true
        playdate.display.setInverted(true)
    end,
    shakeScreen = function(magnitude)
        VFX.screenShake = math.max(VFX.screenShake, 0) + magnitude
    end,
    update = function()
        local updateInverted = function()
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

        local updateScreenShake = function()
            if VFX.screenShake < 0 then
                playdate.display.setOffset(0, 0)
                return
            end

            VFX.screenShake -= 0.5

            local magnitude = math.ceil(VFX.screenShake)
            local shakeX = math.random(-magnitude, magnitude)
            local shakeY = math.random(-magnitude, magnitude)
            playdate.display.setOffset(shakeX, shakeY)
        end

        updateInverted()
        updateScreenShake()
    end
}