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

        menu:addMenuItem("room gen", StateRoomGen.push)
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
    pushRoomGen = function()
        playdate.inputHandlers.pop()
        playdate.inputHandlers.push({})

        local menu = playdate.getSystemMenu()
        menu:removeAllMenuItems()
        menu:addMenuItem("game menu", StateMainMenu.push)
    end,
    pushSingleplayer = function()
        playdate.inputHandlers.pop()
        playdate.inputHandlers.push({
            upButtonDown = function()
                print("player up")
                Singleplayer.direction(0, -1)
            end,
            rightButtonDown = function()
                print("player right")
                Singleplayer.direction(1, 0)
            end,
            downButtonDown = function()
                print("player down")
                Singleplayer.direction(0, 1)
            end,
            leftButtonDown = function()
                print("player left")
                Singleplayer.direction(-1, 0)
            end,
            BButtonDown = function()
                print("player b")
                Singleplayer.switch()
            end,
            AButtonDown = function()
                print("player a")
                Singleplayer.jump()
            end,
        })

        local menu = playdate.getSystemMenu()
        menu:removeAllMenuItems()
        menu:addMenuItem("game menu", StateMainMenu.push)
    end,
    pushRoomSelect = function()
        playdate.inputHandlers.pop()
        playdate.inputHandlers.push({
            AButtonDown = function()
                StateCartSelect.push()
                Event.menuAccept()
            end,
            BButtonDown = function()
                StateMainMenu.push()
                Event.menuReturn()
            end,
            downButtonDown = function()
                StateRoomSelect.incrementRoom()
                Event.menuNext()
            end,
        })

        local menu = playdate.getSystemMenu()
        menu:removeAllMenuItems()

        menu:addMenuItem("game menu", StateMainMenu.push)
    end,
    pushCartSelect = function()
        playdate.inputHandlers.pop()
        playdate.inputHandlers.push({
            downButtonDown = function()
                print("player 1 press")
                StateCartSelect.incrementMinecart(1)
                SFX.menuSelect.play(1)
            end,
            BButtonDown = function()
                print("player 2 press")
                StateCartSelect.incrementMinecart(2)
                SFX.menuSelect.play(2)
            end,
            AButtonDown = function()
                print("player 3 press")
                StateCartSelect.incrementMinecart(3)
                SFX.menuSelect.play(3)
            end,
        })

        local menu = playdate.getSystemMenu()
        menu:removeAllMenuItems()

        menu:addMenuItem("game menu", StateMainMenu.push)
        menu:addMenuItem("select arena", StateRoomSelect.push)
    end,
    pushMultiplayer = function()
        playdate.inputHandlers.pop()
        playdate.inputHandlers.push({
            downButtonDown = function()
                print("player 1 press")
                Multiplayers.switch(1)
            end,
            BButtonDown = function()
                print("player 2 press")
                Multiplayers.switch(2)
            end,
            AButtonDown = function()
                print("player 3 press")
                Multiplayers.switch(3)
            end,
        })

        local menu = playdate.getSystemMenu()
        menu:removeAllMenuItems()

        if DEBUG then
            menu:addMenuItem("*skip*", StateScoreboard.push)
        else
            menu:addMenuItem("game menu", StateMainMenu.push)
        end

        menu:addMenuItem("select arena", StateRoomSelect.push)
        menu:addMenuItem("reset room", StateMultiplayer.push)
    end,
    pushScoreboard = function()
        playdate.inputHandlers.pop()
        playdate.inputHandlers.push({})

        local menu = playdate.getSystemMenu()
        menu:removeAllMenuItems()

        menu:addMenuItem("game menu", StateMainMenu.push)
        menu:addMenuItem("select arena", StateRoomSelect.push)
        menu:addMenuItem("play again", StateMultiplayer.push)
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