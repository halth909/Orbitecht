VFX = {
    inverted = false,
    invertedEnd = -1,
    screenShake = false,
    screenShakeEnd = -1,
    invert = function(duration)
        local endTime = playdate.getCurrentTimeMilliseconds() + duration

        if endTime <= VFX.invertedEnd then
            return
        end

        VFX.invertedEnd = endTime
        VFX.inverted = true
        playdate.display.setInverted(true)
    end,
    shakeScreen = function(duration)
        local endTime = playdate.getCurrentTimeMilliseconds() + duration
        
        if endTime <= VFX.screenShakeEnd then
            return
        end

        VFX.screenShakeEnd = endTime
        VFX.screenShake = true
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
            if not VFX.screenShake then
                return
            end

            local magnitude = 5
            local shakeX = math.random(-magnitude, magnitude)
            local shakeY = math.random(-magnitude, magnitude)
            playdate.display.setOffset(shakeX, shakeY)

            local currentTime = playdate.getCurrentTimeMilliseconds()
            if currentTime < VFX.screenShakeEnd then
                return
            end

            playdate.display.setOffset(0, 0)
            VFX.screenShake = false
        end

        updateInverted()
        updateScreenShake()
    end
}