HealthState = {
    normal = {},
    recovery = {}
}

SingleplayerHealth = {
    max = 4,
    current = 4,
    state = HealthState.normal,
    damageTime = -1,
    onZero = function()
        print("Single player health is zero!")
    end,
    decrement = function()
        local sph = SingleplayerHealth

        if sph.state == HealthState.recovery then
            return
        end

        local current = sph.current

        if current == 0 then
            return
        end

        print("Taking damage")

        local function resetState()
            sph.state = HealthState.normal
        end

        current -= 1

        if current == 0 then
            sph.onZero()
        end

        sph.current = current
        sph.state = HealthState.recovery
        sph.recoveryTimer = Timer.new(PLAYER_DAMAGE_INTERVAL, resetState);
        sph.damageTime = playdate.getCurrentTimeMilliseconds()
        VFX.invert(100)
    end
}

BossHealth = {
    max = 3,
    current = 3,
    damageTime = -1,
    onZero = function()
        print("Boss health is zero!")
    end,
    decrement = function()
        local bh = BossHealth
        local current = bh.current

        if current == 0 then
            return
        end

        print("Boss taking damage")

        current -= 1

        if current == 0 then
            bh.onZero()
        end

        bh.current = current
    end
}