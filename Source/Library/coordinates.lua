Coordinates = {
    cartesianToPolar = function(x, y)
        return math.sqrt(x * x + y * y), math.atan(y, x)
    end,
    polarToCartesian = function(radius, radians)
        return math.cos(radians) * radius, math.sin(radians) * radius
    end,
}