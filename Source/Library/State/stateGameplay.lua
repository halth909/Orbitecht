import 'CoreLibs/ui'
import '../Audio/music.lua'

StateGameplay = {
    push = function()
        State.reset()

        Bubbles.load()
        MusicPlayer.play()

        Input.pushGameplay()

        function playdate.update()        
            State.preUpdate()

            Spinner.update()
            Bubbles.update()

            Spinner.draw()
            Graph.draw()
            Bubbles.draw()
            UIGameplay.draw()

            State.postUpdate()
        end
    end,
    newRoom = function(scenario)
        local newRoomIntro = function()
            RoomCurrent.load(Rooms.singleplayer.intro)
            Tiles.portals[1].isLocked = false
            return Tiles.portals[1]
        end

        local newRoomBoss = function()
            RoomCurrent.load(Rooms.singleplayer.boss)

            Tiles.portals[1].isLocked = false
            Timer.new(0, function()
                Tiles.portals[1].isLocked = true
            end)

            Barrels.unload()
            Ghosts.unload()
            Snake.spawn()
            return Tiles.portals[1]
        end

        if scenario == Scenarios.intro then
            return newRoomIntro()
        elseif scenario == Scenarios.boss then
            return newRoomBoss()
        end

        local options = scenario.options
        local enemy

        if not scenario.enemies then
            enemy = nil
        elseif math.random(2) == 1 then
            if DEBUG then print("BARRELS") end
            enemy = EnemyType.barrels
        else
            if DEBUG then print("GHOSTS") end
            enemy = EnemyType.ghosts
        end

        RoomGenerator.generate(options)
        RoomCurrent.load(RoomGenerator.currentRoom)
        
        if enemy == EnemyType.barrels then
            local straights = Tiles.getStraights()

            while #straights == 0 do
                RoomGenerator.generate(options)
                RoomCurrent.load(RoomGenerator.currentRoom)
                straights = Tiles.getStraights()
            end

            Barrels.setPath(straights[1])
        else
            Barrels.unload()
        end

        table.shuffle(Tiles.portals)

        if DEBUG then print("Portals: " .. #Tiles.portals) end

        if enemy == EnemyType.ghosts then
            local ghostTiles = {}

            for i = 2, #Tiles.portals, 1 do
                table.insert(ghostTiles, Tiles.portals[i])
            end

            Ghosts.spawn(ghostTiles)
        else
            Ghosts.unload()
        end

        if options.portalLocked and #Tiles.portals > 1 then
            Tiles.portals[2].isLocked = true
        end

        return Tiles.portals[1]
    end
}