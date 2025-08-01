import '../Audio/music.lua'

local gfx = playdate.graphics
local animator = gfx.animator
local easingFunctions = playdate.easingFunctions

StateScoreboard = {
    currentScore = nil,
    push = function()
        local duration = MusicPlayer.getDuration()

        State.reset()
        State.uiAnimator = animator.new(1000, 1000, 0, easingFunctions.outQuad)

        local players = Multiplayers.getActive()
        local playerCount = #players
        local score = 0

        for i = 1, playerCount, 1 do
            score += players[i].score
        end

        score *= 1000
        score /= duration

        StateScoreboard.currentScore = score
        SaveData.addHighScore(playerCount, score)

        Input.pushScoreboard()

        function playdate.update()
            State.preUpdate()

            UIScoreboard.draw()

            State.postUpdate()
        end
    end,
}