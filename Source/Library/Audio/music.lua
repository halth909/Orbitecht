MusicPlayer = {
    index = 1,
    current = nil,
    getDuration = function()
        return MusicPlayer.current:getLength()
    end,
    playMainMenu = function()
        if MusicPlayer.current ~= nil then
            MusicPlayer.current:stop()
        end

        MusicPlayer.current = playdate.sound.fileplayer.new("Music/hall")
        MusicPlayer.current:play()
    end,
    play = function()
        if MusicPlayer.current == nil then
            local track = MusicPlayer.tracks[MusicPlayer.index]
            MusicPlayer.index = (MusicPlayer.index) % #MusicPlayer.tracks + 1
            local path = track.path

            MusicPlayer.current = playdate.sound.fileplayer.new(path)
        end
        
        MusicPlayer.current:stop()
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
    { -- 32
        name = "Ukrainian Folk Song",
        path = "Music/folk",
    },
    { -- 51
        name = "Hungarian Dance No. 5",
        path = "Music/dance",
    },
    { -- 91
        name = "Minute Waltz",
        path = "Music/minute",
    },
    { -- 148
        name = "In the Hall of the Mountain King",
        path = "Music/hall",
    },
    { -- 149
        name = "Radetzky March",
        path = "Music/march",
    },
    { -- 150
        name = "The Sorcerer's Apprentice",
        path = "Music/apprentice_2",
    },
    { -- 200
        name = "William Tell Overture",
        path = "Music/tell",
    },
}

table.shuffle(MusicPlayer.tracks)