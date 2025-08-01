local gfx = playdate.graphics
local animator = gfx.animator
local easingFunctions = playdate.easingFunctions

StateRoomSelect = {
    animTime = 300,
    animFunc = easingFunctions.inOutQuad,
    previousIndex = nil,
    currentIndex = nil,
    animatorIn = nil,
    animatorOut = nil,
    push = function()
        local animTime = StateRoomSelect.animTime
        local animFunc = StateRoomSelect.animFunc
        
        State.reset()
        State.uiAnimator = animator.new(animTime, 1000, 0, animFunc)

        StateRoomSelect.previousIndex = nil
        StateRoomSelect.currentIndex = 1
        StateRoomSelect.animatorIn = animator.new(animTime, 240, 0, animFunc)
        StateRoomSelect.animatorOut = animator.new(0, 0, -9999)

        Input.pushRoomSelect()

        function playdate.update()
            State.preUpdate()

            UIRoomSelect.draw()
            
            State.postUpdate()
        end
    end,
    incrementRoom = function()
        local animTime = StateRoomSelect.animTime
        local animFunc = StateRoomSelect.animFunc
        local currentIndex = StateRoomSelect.currentIndex

        StateRoomSelect.previousIndex = currentIndex

        if currentIndex == nil then
            currentIndex = 1
        elseif currentIndex == #Rooms.multiplayer then
            currentIndex = nil
        else
            currentIndex = currentIndex % #Rooms.multiplayer + 1
        end

        StateRoomSelect.currentIndex = currentIndex

        StateRoomSelect.animatorIn = animator.new(animTime, 240, 0, animFunc)
        StateRoomSelect.animatorOut = animator.new(animTime, 0, -240, animFunc)
    end,
    assign = function()
        if StateRoomSelect.currentIndex == nil then
            print("randomising room")
            StateRoomSelect.currentIndex = math.random(#Rooms.multiplayer)
        end

        print("assigning world " .. StateRoomSelect.currentIndex)
        RoomCurrent.load(Rooms.multiplayer[StateRoomSelect.currentIndex])
    end
}
