import "Audio/SFX.lua"
import "events.lua"

Input = {
    pushMainMenu = function()
        playdate.inputHandlers.pop()
        playdate.inputHandlers.push({
            AButtonDown = function()
                StateMainMenu.select()
                Event.menuAccept()
            end,
            downButtonDown = function()
                StateMainMenu.next()
                Event.menuNext()
            end,
            upButtonDown = function()
                StateMainMenu.previous()
                Event.menuPrevious()
            end,
        })

        local menu = playdate.getSystemMenu()
        menu:removeAllMenuItems()

        local options = { "30 fps", "50 fps" }
        local index = SaveData.data.frameTarget == FRAME_TARGET_HIGH and 2 or 1

        menu:addOptionsMenuItem("graphics", options, options[index], function(value)
            if value == options[1] then
                SaveData.setFrameTarget(FRAME_TARGET_DEFAULT)
            else
                SaveData.setFrameTarget(FRAME_TARGET_HIGH)
            end
        end)

        menu:addCheckmarkMenuItem("debug", false, function(value)
            DEBUG = value
        end)
    end,
    pushSlides = function()
        playdate.inputHandlers.pop()
        playdate.inputHandlers.push({
            AButtonDown = function()
                StateSlides.next()
                Event.menuNext()
            end,
            BButtonDown = function()
                StateMainMenu.push()
                Event.menuReturn()
            end,
        })

        local menu = playdate.getSystemMenu()
        menu:removeAllMenuItems()
    end,
    pushGameplay = function()
        playdate.inputHandlers.pop()
        playdate.inputHandlers.push({})

        local menu = playdate.getSystemMenu()
        menu:removeAllMenuItems()
        menu:addMenuItem("game menu", StateMainMenu.push)
    end,
    pushScoreboard = function()
        playdate.inputHandlers.pop()
        playdate.inputHandlers.push({})

        local menu = playdate.getSystemMenu()
        menu:removeAllMenuItems()

        menu:addMenuItem("game menu", StateMainMenu.push)
        menu:addMenuItem("play again", StateGameplay.push)
    end,
}

playdate.inputHandlers.push({
    AButtonDown = InputHelp.show,
    BButtonDown = InputHelp.show,
    downButtonDown = InputHelp.show,
    leftButtonDown = InputHelp.show,
    rightButtonDown = InputHelp.show,
    upButtonDown = InputHelp.show,
})

playdate.inputHandlers.push({})