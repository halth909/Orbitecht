import 'Audio/SFX.lua'

Event = {
    menuNext = function()
        SFX.menuSelect.random()
    end,
    menuPrevious = function()
        SFX.menuSelect.random()
    end,
    menuReturn = function()
        SFX.menuReturn:play()
    end,
    menuAccept = function()
        SFX.menuAccept:play()
    end,

    collectCoin = function()
        SFX.pickupCoin:play()
    end,
    collectDiamond = function()
        SFX.pickupDiamond:play()
    end,

    collision = function()
        SFX.collision:play()
    end,

    portalNone = function()
        SFX.portalNone:play()
    end,
    portalDiamond = function()
        SFX.portalDiamond:play()
    end,
}