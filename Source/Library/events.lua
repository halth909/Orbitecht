import 'Audio/SFX.lua'

Event = {
    menuNext = function()
        SFX.menuSelect:play()
    end,
    menuPrevious = function()
        SFX.menuSelect:play()
    end,
    menuReturn = function()
        SFX.menuReturn:play()
    end,
    menuAccept = function()
        SFX.menuAccept:play()
    end,

    orbImpact = function()
        SFX.orbImpact:play()
        VFX.shakeScreen(2)
    end,
    orbCollect = function()
        SFX.orbCollect:play()
        VFX.shakeScreen(5)
    end,
    lose = function()
        SFX.menuReturn:play()
    end,
}