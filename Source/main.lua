import 'CoreLibs/animation'
import 'CoreLibs/animator'
import 'CoreLibs/easing'
import 'CoreLibs/graphics'
import 'CoreLibs/sprites'
import 'CoreLibs/timer'

import 'Library/Assets/fonts.lua'
import 'Library/Assets/images.lua'

import 'Library/Enemies/enemies.lua'

import 'Library/constants.lua'
import 'Library/saveData.lua'
import 'Library/extensions.lua'
import 'Library/minecarts.lua'
import 'Library/singleplayer.lua'

import 'Library/multiplayers.lua'
import 'Library/collectables.lua'

import 'Library/floorCurrent.lua'
import 'Library/floorGenerator.lua'
import 'Library/floorUtilities.lua'

import 'Library/roomCurrent.lua'
import 'Library/roomGenerator.lua'
import 'Library/rooms.lua'

import 'Library/rails.lua'
import 'Library/tiles.lua'
import 'Library/grid.lua'

import 'Library/vfx.lua'

import 'Library/State/state.lua'
import 'Library/UI/ui.lua'
import 'Library/input.lua'

import 'Library/debug.lua'

SaveData.load()
-- StateFloorGeneratorTest.push()
StateSingleplayer.push()
-- StateMainMenu.push()
