local gfx = playdate.graphics
local animator = gfx.animator
local easingFunctions = playdate.easingFunctions

StateCartSelect = {
    minecartSelections = {},
    countdown = nil,
    push = function()
        State.reset()
        State.uiAnimator = animator.new(300, -85, 0, easingFunctions.outBack)
        
        local selections = StateCartSelect.minecartSelections
        for i = 1, MAX_PLAYERS, 1 do
            selections[i] = {
                previousIndex = nil,
                currentIndex = nil,
            }
        end

        Input.pushCartSelect()

        function playdate.update()
            State.preUpdate()

            UICartSelect.draw()

            State.postUpdate()
        end
    end,
    incrementMinecart = function(playerIndex)
        local minecartSelections = StateCartSelect.minecartSelections
        local isCurrentlySelected = { false, false, false, false }

        for i = 1, #minecartSelections, 1 do
            local index = minecartSelections[i].currentIndex

            if index ~= nil then
                isCurrentlySelected[index] = true
            end
        end

        local minecartSelection = minecartSelections[playerIndex]
        local minecartSelectionIndex = minecartSelection.currentIndex

        if minecartSelectionIndex == nil then
            minecartSelectionIndex = 4
        end

        for i = 1, MINECART_COUNT, 1 do
            local attemptIndex = (minecartSelectionIndex + i - 1) % MINECART_COUNT + 1

            if not isCurrentlySelected[attemptIndex] then
                minecartSelection.previousIndex = minecartSelection.currentIndex
                minecartSelection.currentIndex = attemptIndex
                minecartSelection.animatorIn = animator.new(300, 1000, 0, easingFunctions.outBack)
                minecartSelection.animatorOut = animator.new(200, 0, 1000, easingFunctions.linear)
            
                goto exit
            end
        end

        ::exit::

        if StateCartSelect.countdown ~= nil then
            Timer.cancel(StateCartSelect.countdown)
        end

        StateCartSelect.countdown = Timer.new(2999, StateMultiplayer.push)
    end,
    assign = function()
        local playersData = Multiplayers.data
        local minecartsData = Minecarts.data
        local selections = StateCartSelect.minecartSelections
        for i = 1, MAX_PLAYERS, 1 do
            local minecartIndex = selections[i].currentIndex

            if minecartIndex == nil then
                goto continue
            end

            local minecart = minecartsData[selections[i].currentIndex]
            local player = playersData[i]

            player.minecart = minecart

            minecart.deltaScore = function(delta)
                player.score += delta
                player.score = math.max(0, player.score)
            end

            print("assigned " .. i)

            ::continue::
        end
    end
}
