-- if repeats is true then continue...

Timer = {
    active = {},
    new = function(milliseconds, callback)
        local timerData = {}

        timerData.interval = milliseconds
        timerData.executionTime = playdate.getCurrentTimeMilliseconds() + milliseconds
        timerData.callback = callback

        table.insert(Timer.active, timerData)
        return timerData
    end,
    update = function()
        local active = Timer.active
        local time = playdate.getCurrentTimeMilliseconds()
        for i = 1, #active, 1 do
            local timer = active[i]

            if timer == nil then
                goto continue
            end
            
            if time < timer.executionTime then
                goto continue
            end

            timer.callback()

            if timer.repeats then
                timer.executionTime += timer.interval
            else
                Timer.cancel(timer)
            end

            ::continue::
        end
    end,
    remaining = function(timer)
        return timer.executionTime - playdate.getCurrentTimeMilliseconds()
    end,
    cancel = function(timer)
        table.removeByReference(Timer.active, timer)
    end
}