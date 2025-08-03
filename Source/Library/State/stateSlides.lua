local gfx = playdate.graphics
local animator = gfx.animator
local easingFunctions = playdate.easingFunctions

StateSlides = {
    deck = nil,
    page = nil,
    characters = 9999,
    push = function(deck)
        State.reset()

        StateSlides.deck = deck
        StateSlides.page = 1
        StateSlides.characters = 0
        State.uiAnimator = animator.new(1000, 1000, 0, easingFunctions.outQuad)

        Input.pushSlides()

        function playdate.update()
            State.preUpdate()

            if StateSlides.characters > -1 then
                StateSlides.characters += 3
            end
            
            UISlides.draw()

            State.postUpdate()
        end
    end,
    next = function()
        local currentLength = StateSlides.deck[StateSlides.page].length

        if StateSlides.characters < currentLength then
            StateSlides.characters = currentLength
            State.uiAnimator = animator.new(0, 0, 0)
            return
        end

        StateSlides.page = StateSlides.page + 1
        StateSlides.characters = 0
        State.uiAnimator = animator.new(1000, 1000, 0, easingFunctions.outQuad)

        if StateSlides.page > #StateSlides.deck then
            StateMainMenu.push()
        end
    end,
}