MusicPlayer = {
    index = 1,
    current = nil,
    playMainMenu = function()
        MusicPlayer.index = 1
        MusicPlayer.play()
        MusicPlayer.current:setFinishCallback(function()
            if MusicPlayer.current == nil then
                return
            end
            
            MusicPlayer.current:play()
        end)
    end,
    playGameplay = function()
        local playNext = function()
            MusicPlayer.index = MusicPlayer.index % #MusicPlayer.tracks + 1
            MusicPlayer.play()
        end

        MusicPlayer.index = 2
        MusicPlayer.play()
        MusicPlayer.current:setFinishCallback(playNext)
    end,
    play = function()
        if MusicPlayer.current ~= nil then
            MusicPlayer.current:stop()
        end

        local track = MusicPlayer.tracks[MusicPlayer.index]
        local path = track.path
        print("Playing " .. path)

        MusicPlayer.current = playdate.sound.fileplayer.new(path)
        MusicPlayer.current:play()
    end,
    stop = function()
        if MusicPlayer.current == nil then
            return
        end

        MusicPlayer.current:stop()
        MusicPlayer.current = nil
    end,
}

MusicPlayer.tracks = {
    {
        path = "Music/neptune",
    },
    {
        path = "Music/danse",
    },
    {
        path = "Music/mars",
    }
}

table.shuffle(MusicPlayer.tracks)