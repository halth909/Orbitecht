Animator = {
    new = function(milliseconds, imageTable)
        local count = imageTable:getLength()
        return {
            milliseconds = milliseconds,
            imageTable = imageTable,
            count = count,
            duration = count * milliseconds
        }
    end,
    draw = function(animator, ...)
        local time = playdate.getCurrentTimeMilliseconds()
        local index = math.floor(1 + (time % animator.duration) / animator.milliseconds)
        animator.imageTable:getImage(index):draw(...)
    end
}