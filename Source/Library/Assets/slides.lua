About = {
    {
        lines = {
            "Mythic Mine is a one button game.",
            "",
            "1, 2, or 3 players can enjoy together.",
            "",
            "Play using the ⬇, Ⓑ, and Ⓐ buttons.",
        }
    }
}

Adventure = {
    {
        lines = {
            "Mythic Mine is a one button game.",
            "",
            "1, 2, or 3 players can enjoy together.",
            "",
            "Play using the ⬇, Ⓑ, and Ⓐ buttons.",
        }
    }
}

Arena = {
    {
        lines = {
            "All o'er the world the people share",
            "The tales ",
            "Companions travel ancient ways",
            "All become unwitting slaves",
        }
    },
    {
        lines = {
            "They strive for freedom from their shackles",
            "A rising voice below them cackles",
            "\"A hundred years you'll grow my hoard",
            "To earn your place on my leaderboard...\"",
        }
    }
}

Credits = {
    {
        lines = {
            "Thank you for playing",
            "",
            "Mythic Mine",
            "",
            "A game by Thomas Hall",
        }
    },
    {
        lines = {
            "Special Thanks",
            "",
            { "Hayley Smyth", "Koen Witters (koonsolo)" },
            { "Hannah Lumley", "Malcolm Morrison" },
            { "Thomas Leask", "Tom Blomfield" },
        }
    },
    {
        lines = {
            "Visual Studio Code",
            "https://code.visualstudio.com/",
            "",
            "Playdate Simulator",
            "https://playdate-wiki.com/wiki/Playdate__Simulator",
            "",
            "GithHub Desktop",
            "https://github.com/apps/desktop",
        }
    },
    {
        lines = {
            "Aseprite",
            "https://www.aseprite.org/",
            "",
            "Inkscape",
            "https://inkscape.org/",
            "",
            "Gimp",
            "https://www.gimp.org/",
        }
    },
    {
        lines = {
            "GarageBand",
            "https://www.apple.com/mac/garageband/",
            "",
            "jsfxr",
            "https://sfxr.me/",
            "",
            "Playdate Caps",
            "https://play.date/caps/",
        }
    },
    {
        lines = {
            "The Sorcerer's Apprentice",
            "Composed by Paul Dukas",
            "Arranged by Joseph Hudson",
            "",
            "https://musescore.com/user/",
            "37070508/scores/6618017",
            "https://creativecommons.org/licenses/by/4.0/",
        }
    },
    {
        lines = {
            "Hungarian Dance No. 5",
            "Johannes Brahms",
            "",
            "https://creativecommons.org/public-domain/cc0/",
        }
    },
    {
        lines = {
            "In the Hall of the Mountain King",
            "Edvard Grieg",
            "",
            "https://creativecommons.org/public-domain/cc0/",
        }
    },
    {
        lines = {
            "Minute Waltz",
            "Frédéric Chopin",
            "",
            "https://creativecommons.org/public-domain/cc0/",
        }
    },
    {
        lines = {
            "Radetzky March",
            "Richard Georg Strauss",
            "",
            "https://musescore.com/user/",
            "46336/scores/4879864",
            "https://creativecommons.org/licenses/by/4.0/",
        }
    },
    {
        lines = {
            "Ukrainian Folk Song",
            "Ludwig van Beethoven",
            "",
            "https://musescore.com/user/",
            "32106469/scores/6011194",
            "https://creativecommons.org/licenses/by/4.0/",
        }
    },
    {
        lines = {
            "William Tell Overture",
            "Gioachino Rossini",
            "",
            "https://musescore.com/user/",
            "21127886/scores/5108322",
            "https://creativecommons.org/licenses/by/4.0/"
        }
    },
}

Slides = {
    onLoad = function()
        Slides.process(About)
        Slides.process(Adventure)
        Slides.process(Arena)
        Slides.process(Credits)
    end,
    process = function(deck)
        for i = 1, #deck, 1 do
            local length = 0
            local slide = deck[i]
            local lines = slide.lines

            for j = 1, #lines, 1 do
                local line = lines[j]
                if type(line) == "string" then
                    length += string.len(line)
                else
                    for k = 1, #line, 1 do
                        length += string.len(line[k])
                    end
                end
            end

            slide.length = length
        end
    end
}

Slides.onLoad()