import 'CoreLibs/animation'
import 'CoreLibs/animator'
import 'CoreLibs/easing'
import 'CoreLibs/graphics'
import 'CoreLibs/sprites'
import 'CoreLibs/timer'

import 'Library/Assets/fonts.lua'
import 'Library/Assets/images.lua'

import 'Library/constants.lua'
import 'Library/saveData.lua'
import 'Library/extensions.lua'

import 'Library/collision.lua'
import 'Library/coordinates.lua'
import 'Library/spinner.lua'
import 'Library/bubbles.lua'
import 'Library/bubbleSpawner.lua'
import 'Library/bubbleGraph.lua'

import 'Library/vfx.lua'

import 'Library/State/state.lua'
import 'Library/UI/ui.lua'
import 'Library/input.lua'

import 'Library/debug.lua'

SaveData.load()
StateMainMenu.push()
-- StateGameplay.push()
