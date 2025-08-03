import '../timer.lua'
import 'stateMainMenu.lua'
import 'stateGameplay.lua'
import 'stateScoreboard.lua'
import 'stateSlides.lua'

local gfx = playdate.graphics
gfx.setBackgroundColor(gfx.kColorBlack)

State = {
    reset = function()
        InputHelp.hide()
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