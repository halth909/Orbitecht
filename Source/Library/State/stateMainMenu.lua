import '../Audio/music.lua'
import '../Assets/slides.lua'

local gfx = playdate.graphics
local animator = gfx.animator
local easingFunctions = playdate.easingFunctions

StateMainMenu = {
    options = {
        {
            label = "Adventure",
            callback = StateSingleplayer.push,
            enabled = true,
        },
        {
            label = "Arena",
            callback = StateRoomSelect.push,
            enabled = true,
        },
        {
            label = "About",
            callback = function()
                StateSlides.push(About)
            end,
            enabled = true,
        },
        {
            label = "Credits",
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

        StateMainMenu.newRoom()
        Minecarts.loadMainMenu()
        MusicPlayer.playMainMenu()

        StateMainMenu.currentIndex = 1

        Input.pushMainMenu()

        function playdate.update()
            State.preUpdate()

            Collectables.update()
            Minecarts.update()

            local c = State.uiAnimator:currentValue() / 1000
            local x = 100 * c
            local y = 150 * c
            RoomCurrent.draw(35 + x, 30 + y)

            UIMainMenu.draw()
            State.postUpdate()

            -- Images.test:draw(0, 0)
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
    newRoom = function()
        local nextRoom = StateMainMenu.currentRoom

        while nextRoom == StateMainMenu.currentRoom do
            nextRoom = math.random(#Rooms.mainMenu)
        end

        StateMainMenu.currentRoom = nextRoom
        RoomCurrent.load(Rooms.mainMenu[nextRoom])
    end
}