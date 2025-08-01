local gfx = playdate.graphics
local animator = gfx.animator
local easingFunctions = playdate.easingFunctions

UIBottomBanner = {
    states = {
        showing = {},
        hiding = {},
        hidden = {}
    },
    text = nil,
    xOffset = nil,
    yMargin = nil,
    timer = nil,
    animator = nil,
    show = function(text, xOffset, yMargin)
        UIBottomBanner.text = text
        UIBottomBanner.xOffset = xOffset
        UIBottomBanner.yMargin = yMargin
        UIBottomBanner.animator = animator.new(300, 0, 1000, easingFunctions.outBack)
        UIBottomBanner.timer = nil
        UIBottomBanner.state = UIBottomBanner.states.showing
    end,
    hide = function()
        UIBottomBanner.animator = animator.new(300, 1000, 0, easingFunctions.inBack)
        UIBottomBanner.state = UIBottomBanner.states.hiding

        if UIBottomBanner.timer ~= nil then
            Timer.cancel(UIBottomBanner.timer)
        end

        UIBottomBanner.timer = Timer.new(300, function()
            UIBottomBanner.state = UIBottomBanner.states.hidden
        end)
    end,
    draw = function(newText, newXOffset, newYMargin)
        local show = InputHelp.showing
        local showing = UIBottomBanner.state == UIBottomBanner.states.showing
        local hidden = UIBottomBanner.state == UIBottomBanner.states.hidden
        
        if show and not showing then
            UIBottomBanner.show(newText, newXOffset, newYMargin)
        elseif showing and not show then
            UIBottomBanner.hide()
        end

        if hidden then
            return
        end

        local text = UIBottomBanner.text
        local xOffset = UIBottomBanner.xOffset
        local yMargin = UIBottomBanner.yMargin

        local banner = Images.bannerBottom
        local width, height = banner:getSize()
        local yPos = (yMargin + height) * UIBottomBanner.animator:currentValue() / 1000
        banner:draw(200 + xOffset - width // 2, 240 - yPos)
        gfx.drawInvertedTextAligned(text, 200 + xOffset, 253 - yPos, kTextAlignment.center)
    end,
}

UIBottomBanner.state = UIBottomBanner.states.hidden