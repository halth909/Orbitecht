About = {
    {
        lines = {
            "WE ARE UNDER ATTACK",
            "",
            "USE THE CRANK TO ROTATE YOUR SHIELD",
            "",
            "COLLECT AND ELIMINATE MATCHING ORBS",
        }
    }
}

Credits = {
    {
        lines = {
            "THANK YOU FOR PLAYING",
            "",
            "ORBITECHT",
            "",
            "A GAME BY THOMAS HALL",
        }
    },
    {
        lines = {
            "ORIGINAL GAME DESIGN",
            "",
            "CHRISTOPHER CALANDIR BROWN",
        }
    },
    {
        lines = {
            "SOFTWARE",
            "",
            "VISUAL STUDIO CODE",
            "PLAYDATE SIMULATOR",
            "GITHUB DESKTOP",
            "ASEPRITE",
            "INKSCAPE"
        }
    }
}

Slides = {
    onLoad = function()
        Slides.process(About)
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