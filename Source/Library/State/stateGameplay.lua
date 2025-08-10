import 'CoreLibs/ui'
import '../Audio/music.lua'

StateGameplay = {
    score = 0,
    lossCondition = nil,
    push = function()
        State.reset()

        StateGameplay.lossCondition = false

        Bubbles.load()
        MusicPlayer.playGameplay()

        Input.pushGameplay()

        function playdate.update()        
            State.preUpdate()

            Spinner.update()
            BubbleGraph.update()
            Bubbles.update()

            Spinner.draw()
            BubbleGraph.draw()
            Bubbles.draw()
            UIGameplay.draw()

            State.postUpdate()

            if StateGameplay.lossCondition then
                StateScoreboard.push()
            end
        end
    end,
    lose = function()
        StateGameplay.lossCondition = true
    end
}