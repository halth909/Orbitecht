-- local gfx = playdate.graphics
-- local animator = gfx.animator
-- local easingFunctions = playdate.easingFunctions

StateFloorGeneratorTest = {
    push = function()
        State.reset()

        FloorGenerator.generate(FloorGeneratorOptions.default)

        function playdate.update()
            State.preUpdate()

            FloorGenerator.draw()

            State.postUpdate()
        end
    end,
}
