local gfx = playdate.graphics
local random = math.random

function lerp(a,b,t) return a * (1-t) + b * t end

function ternary(c,a,b)
    if c then return a end
    return b
end

function math.sign(value)
    if value == 0 then return 0 end
    if value > 0 then return 1 end
    return -1
end

function math.inRange(value, range)
    if value < range.min then return false end
    if value > range.max then return false end
    return true
end

function table.indexOf(table, value)
    for i = #table, 1, -1 do
        if table[i] == value then
            return i
        end
    end

    return false
end

function table.contains(table, value)
    for i = #table, 1, -1 do
        if table[i] == value then
            return true
        end
    end

    return false
end

function table.removeByReference(t, value)
    local count = #t
    for i = 1, count, 1 do
        if t[i] == value then
            for j = i, count - 1, 1 do
                t[j] = t[j + 1]
            end
    
            t[count] = nil

            goto exit
        end
    end

    ::exit::
end

local j
function table.shuffle(table)
    for i = #table, 2, -1 do
        j = random(i)
        table[i], table[j] = table[j], table[i]
    end
end

function table.containsEquivalent(collection, set)
    local count = #set

    for i = 1, #collection do
        local current = collection[i]

        if #current ~= count then
            goto continue
        end

        for j = 1, count do
            if table.contains(current, set[j]) then
                goto continue
            end
        end

        do return true end

        ::continue::
    end

    return false
end

function table.shallowCopy(table)
    local copy = {}

    for k, v in pairs(table) do
        copy[k] = v
    end

    return copy
end

function table.clear(table)
    for k, _ in pairs(table) do
        table[k] = nil
    end
end

function gfx.drawInvertedText(...)
	local original_draw_mode = gfx.getImageDrawMode()

	gfx.setImageDrawMode( gfx.kDrawModeInverted )
	gfx.drawText(...)
	gfx.setImageDrawMode( original_draw_mode )
end

function gfx.drawInvertedTextAligned(...)
	local original_draw_mode = gfx.getImageDrawMode()

	gfx.setImageDrawMode( gfx.kDrawModeInverted )
	gfx.drawTextAligned(...)
	gfx.setImageDrawMode( original_draw_mode )
end