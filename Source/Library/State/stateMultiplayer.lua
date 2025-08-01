import '../Audio/music.lua'

StateMultiplayer = {
    timer = nil,
    push = function()
        State.reset()
        Multiplayers.init()

        StateRoomSelect.assign()
        StateCartSelect.assign()
        Minecarts.loadMultiplayer()
        Collectables.settings = CollectablesSettings.multiplayer
        MusicPlayer.play()

        Input.pushMultiplayer()

        local ms = 1000 * MusicPlayer.getDuration()
        StateMultiplayer.timer = Timer.new(ms, StateScoreboard.push)

        function playdate.update()
            State.preUpdate()

            Collectables.update()
            Minecarts.update()
            
            UIMultiplayer.update()
            
            RoomCurrent.draw(0, 0)
            UIMultiplayer.draw()

            State.postUpdate()
        end
    end
}