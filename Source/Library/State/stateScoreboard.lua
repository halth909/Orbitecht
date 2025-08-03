import '../Audio/music.lua'

local gfx = playdate.graphics
local animator = gfx.animator
local easingFunctions = playdate.easingFunctions

StateScoreboard = {
    currentScore = nil,
    rightSide = nil,
    push = function()
        State.reset()
        State.uiAnimator = animator.new(1000, 1000, 0, easingFunctions.outQuad)

        StateScoreboard.backgroundImage = playdate.graphics.getDisplayImage()

        local score = StateGameplay.score
        StateScoreboard.currentScore = score
        SaveData.addHighScore(score)

        Input.pushScoreboard()

        function playdate.update()
            State.preUpdate()

            StateScoreboard.backgroundImage:draw(0, 0)
            UIScoreboard.draw()

            State.postUpdate()
        end
    end,
}