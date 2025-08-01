import '../animator.lua'
import '../constants.lua'

Images = {
    test = playdate.graphics.image.new("Images/test.png"),

    title = playdate.graphics.image.new("Images/title.png"),
    frame = playdate.graphics.image.new("Images/corner_0.png"),
    block = playdate.graphics.image.new("Images/block.png"),
    roomRandom = playdate.graphics.image.new("Images/room-random.png"),
    selected = playdate.graphics.image.new("Images/selected.png"),
    bannerBottom = playdate.graphics.image.new("Images/banner-bottom.png"),
    bannerSideSmall = playdate.graphics.image.new("Images/banner-side-small.png"),
    bannerSideLarge = playdate.graphics.image.new("Images/banner-side-large.png"),
    minecartThumbs = {},
    minecartFrames = {},
}

Animators = {}

local mapTable = playdate.graphics.imagetable.new("Images/floor_map")
Images.map_2 = mapTable:getImage(5, 2)

Images.map_1_1111 = mapTable:getImage(1, 1)
Images.map_1_1101 = mapTable:getImage(2, 1)
Images.map_1_0101 = mapTable:getImage(3, 1)
Images.map_1_1001 = mapTable:getImage(4, 1)
Images.map_1_1000 = mapTable:getImage(5, 1)
Images.map_1_0000 = mapTable:getImage(6, 1)

Images.map_0_1111 = mapTable:getImage(1, 2)
Images.map_0_1101 = mapTable:getImage(2, 2)
Images.map_0_0101 = mapTable:getImage(3, 2)
Images.map_0_1001 = mapTable:getImage(4, 2)

Images.map_lock   = mapTable:getImage(1, 3)
Images.map_boss   = mapTable:getImage(2, 3)
Images.map_player = mapTable:getImage(3, 3)

local railTable = playdate.graphics.imagetable.new("Images/rails")
Images.railStraight = railTable:getImage(1, 1)
Images.railStraightSwitch = railTable:getImage(1, 2)
Images.railCornerV = railTable:getImage(2, 1)
Images.railCornerVSwitch = railTable:getImage(2, 2)
Images.railCornerH = railTable:getImage(3, 1)
Images.railCornerHSwitch = railTable:getImage(3, 2)
Images.railLevelCrossing = railTable:getImage(4, 1)

local minecartTable = playdate.graphics.imagetable.new("Images/minecarts")

for i = 1, MINECART_COUNT do
    Images.minecartThumbs[i] = minecartTable:getImage(1,i)
    Images.minecartFrames[i] = {}
    for j = 1, MINECART_FRAMES do
        Images.minecartFrames[i][j] = minecartTable:getImage(j + 1,i)
    end
end

local placeholderTable = playdate.graphics.imagetable.new("Images/placeholder")
Images.placeholder = placeholderTable:getImage(1, 1)

-- portal
local portalTable = playdate.graphics.imagetable.new("Images/portal")
Images.portal = portalTable:getImage(1, 1)
Animators.portal = Animator.new( 150, portalTable )

portalTable = playdate.graphics.imagetable.new("Images/portal_locked")
Images.portalLock = playdate.graphics.image.new("Images/portal_lock.png")
Animators.portalLocked = Animator.new( 150, portalTable )

-- health
local healthTable = playdate.graphics.imagetable.new("Images/health")
Images.healthEmpty = healthTable:getImage(1, 1)
Images.healthFull = healthTable:getImage(2, 1)

healthTable = playdate.graphics.imagetable.new("Images/health_boss")
Images.bossHealthEmpty = healthTable:getImage(1, 1)
Images.bossHealthFull = healthTable:getImage(2, 1)

-- barrel
local barrelTable1 = playdate.graphics.imagetable.new("Images/barrel_1")
Animators.barrel1 = Animator.new( 85, barrelTable1 )
local barrelTable2 = playdate.graphics.imagetable.new("Images/barrel_2")
Animators.barrel2 = Animator.new( 85, barrelTable2 )

-- ghost
local ghostTable = playdate.graphics.imagetable.new("Images/ghost")
Images.ghostFrames = {}
for i = 1, 4, 1 do
    Images.ghostFrames[i] = ghostTable:getImage(i, 1)
end

-- powered
local poweredTable = playdate.graphics.imagetable.new("Images/powered")
Images.powered = poweredTable:getImage(1, 1)
Animators.powered = Animator.new( 100, poweredTable )