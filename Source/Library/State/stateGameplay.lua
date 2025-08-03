import 'CoreLibs/ui'
import '../Audio/music.lua'

StateGameplay = {
    score = 0,
    push = function()
        State.reset()

        Bubbles.load()
        MusicPlayer.play()

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
        end
    end
}