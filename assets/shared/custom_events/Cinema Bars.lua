local thing = {'Top', 'Bot'}
function onCreate()
    for i = 1, #thing do
        makeLuaSprite('bar' .. thing[i])
        makeGraphic('bar' .. thing[i], screenWidth, screenHeight, '000000')
        addLuaSprite('bar' .. thing[i], false)
        setObjectCamera('bar' .. thing[i], 'hud')
        setProperty('bar' .. thing[i] .. '.antialiasing', false)
        setProperty('bar' .. thing[i] .. '.y', false)
    end
    setProperty('barTop.y', getProperty('barTop.y') - (screenHeight / 1))
end

function onUpdate()
    --debugPrint(getProperty('barTop.y') + screenHeight .. ' ', getProperty('barBot.y') - screenHeight)
    setProperty('barBot.y', (getProperty('barTop.y') - (getProperty('barTop.y') * 2)))
    for i = 1, #thing do
        setObjectOrder('bar' .. thing[i], 0)
        screenCenter('bar' .. thing[i], 'X')
        setProperty('bar' .. thing[i] .. '.width', screenWidth)
        setProperty('bar' .. thing[i] .. '.height', screenHeight)
    end
end

function onEvent(name, value1, value2)
    if name == 'Cinema Bars' then
        Ylevel = tonumber(value1)
        --Ylevel = ((Ylevel == nil or Ylevel == '') and 95 or ((Ylevel < 0 and 0) or (Ylevel > 360 and 360)))
        if Ylevel == nil or Ylevel == '' then
            Ylevel = 95
        elseif Ylevel < 0 then
            Ylevel = 0
        elseif Ylevel > 360 then
            Ylevel = 360
        end
        
        local value2contents = {}
        value2contents = Split(value2, ',')
        ease = tostring(value2contents[1])
        if ease == nil or ease == '' then
            ease = 'sineOut'
        end
        duration = tonumber(value2contents[2])
        if duration == nil or duration == '' then
            duration = 1
        end

        doTweenY('moveBar', 'barTop', Ylevel - screenHeight, duration, ease)
    end
end

function onGameOverStart()
    for i = 1, #thing do
        removeLuaSprite('bar' .. thing[i], true)
    end
end

function Split(s, delimiter)
	result = {}
	for match in (s..delimiter):gmatch('(.-)'..delimiter) do
		table.insert(result, tostring(match))
	end
	return result
end
