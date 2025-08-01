StateRoomGen = {
    current = nil,
    push = function()
        State.reset()

        Input.pushRoomGen()

        function playdate.update()
            State.preUpdate()

            if RoomGenerator.current == nil then
                RoomGenerator.generate(RoomGeneratorOptions.singleplayerDebug)
            else
                RoomGenerator.draw()
            end

            State.postUpdate()
        end
    end
}