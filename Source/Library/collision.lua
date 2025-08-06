Collision = {
    resolve = function(ax, ay, ar, bx, by, br)
        local dx = bx - ax
        local dy = by - ay
        local distance = math.sqrt(dx * dx + dy * dy)
        local minDistance = ar + br
        local ratio = minDistance / distance
        return ratio > 1, ax + dx * ratio, ay + dy * ratio
    end
}