import '../Audio/music.lua'
import '../Assets/slides.lua'
import 'stateGameplay.lua'

local gfx = playdate.graphics
local animator = gfx.animator
local easingFunctions = playdate.easingFunctions

StateMainMenu = {
    options = {
        {
            label = "START",
            callback = StateGameplay.push,
            enabled = true,
        },
        {
            label = "ABOUT",
            callback = function()
                StateSlides.push(About)
            end,
            enabled = true,
        },
        {
            label = "CREDITS",
            callback = function()
                StateSlides.push(Credits)
            end,
            enabled = true,
        },
    },
    currentIndex = nil,
    currentRoom = 0,
    push = function()
        State.reset()
        State.uiAnimator = animator.new(2000, 1000, 0, easingFunctions.outCirc)

        MusicPlayer.playMainMenu()

        StateMainMenu.currentIndex = 1

        Input.pushMainMenu()

        function playdate.update()
            State.preUpdate()

            UI.drawBackground()
            UIMainMenu.draw()
            State.postUpdate()
        end
    end,
    previous = function()
        local options = StateMainMenu.options
        local current = StateMainMenu.currentIndex
        local count = #options
        current = (current + count - 2) % count + 1
        local currentItem = options[current]

        while not currentItem.enabled do
            current = (current + count - 2) % count + 1
            currentItem = options[current]
        end

        StateMainMenu.currentIndex = current
    end,
    next = function()
        local options = StateMainMenu.options
        local current = StateMainMenu.currentIndex
        local count = #options
        current = current % count + 1
        local currentItem = options[current]

        while not currentItem.enabled do
            current = current % #options + 1
            currentItem = options[current]
        end

        StateMainMenu.currentIndex = current
    end,
    select = function()
        StateMainMenu.options[StateMainMenu.currentIndex].callback()
    end,
}