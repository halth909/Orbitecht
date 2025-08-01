local sampleplayer = playdate.sound.sampleplayer

SFX = {
    collision = sampleplayer.new("SFX/collision"),
    menuAccept = sampleplayer.new("SFX/menu_accept"),
    menuReturn = sampleplayer.new("SFX/menu_return"),
    menuSelect = {
        samples = {
            sampleplayer.new("SFX/menu_select_a"),
            sampleplayer.new("SFX/menu_select_b"),
            sampleplayer.new("SFX/menu_select_c"),
        },
        index = 1,
        play = function(index)
            SFX.menuSelect.samples[index]:play()
        end,
        random = function()
            local i = SFX.menuSelect.index
            SFX.menuSelect.play(i)
            i = (i + math.random(2) - 1) % 3 + 1
            SFX.menuSelect.index = i
        end,
    },
    pickupCoin = sampleplayer.new("SFX/pickup_coin"),
    pickupDiamond = sampleplayer.new("SFX/pickup_diamond"),
    portalDiamond = sampleplayer.new("SFX/portal_diamond"),
    portalNone = sampleplayer.new("SFX/portal_none"),
}