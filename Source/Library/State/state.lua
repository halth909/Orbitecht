import '../Audio/music.lua'

import 'stateRoomSelect.lua'
import 'stateCartSelect.lua'
import 'StateFloorGeneratorTest.lua'
import 'stateMultiplayer.lua'
import 'stateScoreboard.lua'
import 'stateSingleplayer.lua'
import 'stateSlides.lua'
import 'stateMainMenu.lua'

import 'stateRoomGen.lua'

local gfx = playdate.graphics

State = {
    reset = function()
        RoomCurrent.unload()
        Minecarts.unload()
        Barrels.unload()
        Ghosts.unload()
        
        MusicPlayer.stop()
        InputHelp.hide()
        UIMultiplayer.floatingTexts = {}

        if StateCartSelect.countdown ~= nil then
            Timer.cancel(StateCartSelect.countdown)
            StateCartSelect.countdown = nil
        end

        if StateMultiplayer.timer ~= nil then
            Timer.cancel(StateMultiplayer.timer)
            StateMultiplayer.timer = nil
        end
    end,
    preUpdate = function()
        Timer.update()
        gfx.clear(gfx.kColorBlack)
    end,
    postUpdate = function()
        VFX.update()

        if DEBUG then
            playdate.drawFPS()
        end
    end,
}

InputHelp = {
    showing = false,
    inputsTimer = nil,
    show = function()
        InputHelp.hide()
        InputHelp.inputsTimer = Timer.new(2500, InputHelp.hide);
        InputHelp.showing = true
    end,
    hide = function()
        if InputHelp.inputsTimer ~= nil then
            Timer.cancel(InputHelp.inputsTimer)
            InputHelp.inputsTimer = nil
        end

        InputHelp.showing = false
    end,
}