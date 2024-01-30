--this script will detect when there are/aren't notes on the player's and/or opponent's lanes (made by kornelbut, credit would be neat)
--https://gamebanana.com/mods/458232

--no touchy these
local plNotes, opNotes = 0, 0
local nuhuh, nuhuh1 = false, false
local runOnce, stopFunctionFix = false, false
local turnOffOncePl1, turnOffOncePl2, turnOffOnceOp1, turnOffOnceOp2 = true, false, true, false

--customizable variables here!!!!!!!!!!!!!!!!!!!!!!!!!!!!
local dontDoTheScript = false --set to true if you don't want this script to work
local plOnly = false --set to true if you only want player's strum to do this
local opOnly = false --set to true if you only want opponent's strum to do this

local appearSpeed = 1 --speed of strums appearing
local disappearSpeed = 0 --speed of strums disappearing
local undimOpacity = 0.8 --opacity of strums when notes are on-screen
local dimOpacity = 0.2 --opacity of strums when notes aren't on-screen
local undimDuration = 0.25 --duration time for strums undimming
local dimDuration = 0.25 --duration time for strums dimming
local undimEase = 'sineInOut'
local dimEase = 'sineInOut'
local bannedPlNote = 'insert note name' --player's strum will ignore this note
local bannedOpNote = 'insert note name' --opponent's strum will ignore this note
local turnOffDimPl = false --use this var to turn off player's dimming mid-song (for example in onStepHit)
local turnOffDimOp = false --use this var to turn off opponent's dimming mid-song (for example in onStepHit)

function onCreate()
	--[[ if you put this file in the scripts folder but want it to behave differently in specific songs, remove the comment and change your songPath to your song's name and the variables accordingly
	if songPath == "insert your song data folder name" then
		insert variables
	end ]]
	if not dontDoTheScript then
		setProperty('skipArrowStartTween', true)
	end
	opStru = getPropertyFromClass('backend.ClientPrefs', 'data.opponentStrums')
end

function onCreatePost()
	if plOnly and opOnly then
		plOnly, opOnly = false, false
	end
	if middlescroll and opStru then
		for i = 0,3 do
			setPropertyFromGroup('opponentStrums', i, 'alpha', dimOpacity)
		end
	end
	if not dontDoTheScript then
		local only, turnOff, strumProperty, defaultStrumY, passThrough
		for i = 1, 2 do
			if i == 1 then
				only = opOnly
				turnOff = turnOffDimPl
				strumProperty = 'playerStrums'
				defaultStrumY = 'defaultPlayerStrumY'
				passThrough = true
			else
				only = plOnly
				turnOff = turnOffDimOp
				strumProperty = 'opponentStrums'
				defaultStrumY = 'defaultOpponentStrumY'
				if not middlescroll and opStru then
					passThrough = true
				else
					passThrough = false
				end
			end

			if passThrough then
				if not turnOff then
					if not only then
						setPropertyFromGroup(strumProperty, i, 'alpha', dimOpacity)
					else
						setPropertyFromGroup(strumProperty, i, 'alpha', undimOpacity)
					end
				end
			end
		end
	end
end

function onSpawnNote(id, dir, noteType, holdNote)
	if not dontDoTheScript and not getPropertyFromGroup('unspawnNotes', id, 'ignoreNote') then
		if not getPropertyFromGroup('unspawnNotes', id, 'mustPress') and not plOnly and noteType ~= bannedOpNote then
			if not holdNote then
				opNotes = opNotes + 1
			end
			if not nuhuh then
				runTimer('opWait', appearSpeed, 1)
			end
			nuhuh = true
		elseif getPropertyFromGroup('unspawnNotes', id, 'mustPress') and not opOnly and noteType ~= bannedPlNote then
			if not holdNote then
				plNotes = plNotes + 1
			end
			if not nuhuh1 then
				runTimer('plWait', appearSpeed, 1)
			end
			nuhuh1 = true
		end
	end
end

function goodNoteHit(id, dir, noteType, holdNote)
	if not dontDoTheScript and not opOnly and not getPropertyFromGroup('notes', id, 'ignoreNote') and noteType ~= bannedPlNote then
		if not holdNote then
			plNotes = plNotes - 1
		end
		runTimer('plStrum', disappearSpeed, 1)
	end
end

function noteMiss(id, dir, noteType, holdNote)
	if not dontDoTheScript and not opOnly and noteType ~= bannedPlNote then
		if not holdNote then
			plNotes = plNotes - 1
		end
		runTimer('plStrum', disappearSpeed, 1)
	end
end

function opponentNoteHit(id, dir, noteType, holdNote)
	if not dontDoTheScript and not plOnly and noteType ~= bannedOpNote then
		if not holdNote then
			opNotes = opNotes - 1
		end
		runTimer('opStrum', disappearSpeed, 1)
	end
end

function onUpdate()
	if not runOnce then
		runOnce = true
		runTimer('functionStopCheck', 0.01)
	end
	if not dontDoTheScript and stopFunctionFix then
		for i = 0,3 do
			if not opOnly then
				setPropertyFromGroup('playerStrums', i, 'alpha', dimOpacity)
			end
			if not plOnly then
				setPropertyFromGroup('opponentStrums', i, 'alpha', dimOpacity)
			end
			if opOnly then
				setPropertyFromGroup('playerStrums', i, 'alpha', undimOpacity)
				if getPropertyFromGroup('opponentStrums', i, 'alpha') == dimOpacity then
					stopFunctionFix = false
				end
			elseif plOnly then
				setPropertyFromGroup('opponentStrums', i, 'alpha', undimOpacity)
				if getPropertyFromGroup('playerStrums', i, 'alpha') == dimOpacity then
					stopFunctionFix = false
				end
			else
				if getPropertyFromGroup('playerStrums', i, 'alpha') == dimOpacity and getPropertyFromGroup('opponentStrums', i, 'alpha') == dimOpacity then
					stopFunctionFix = false
				end
			end
		end
	end

	if getProperty('notes.length') == 0 then
		if plNotes > 0 then
			plNotes = 0
			runTimer('plStrum', disappearSpeed, 1)
		end
		if opNotes > 0 then
			opNotes = 0
			runTimer('opStrum', disappearSpeed, 1)
		end
	end
	if not dontDoTheScript then
		turnOffCheck()
	end
end

function turnOffCheck()
	if turnOffDimPl and turnOffOncePl1 then
		turnOffOncePl1 = false
		turnOffOncePl2 = true
	elseif not turnOffDimPl and turnOffOncePl2 then
		turnOffOncePl1 = true
		turnOffOncePl2 = false
		if getPropertyFromGroup('playerStrums', 0, 'alpha') ~= dimOpacity and plNotes == 0 then
			noteDetection('pl', 'hide')
		elseif getPropertyFromGroup('playerStrums', 0, 'alpha') ~= undimOpacity and plNotes > 0 then
			noteDetection('pl', 'show')
		end
	end

	if turnOffDimOp and turnOffOnceOp1 then
		turnOffOnceOp1 = false
		turnOffOnceOp2 = true
	elseif not turnOffDimOp and turnOffOnceOp2 then
		turnOffOnceOp1 = true
		turnOffOnceOp2 = false
		if getPropertyFromGroup('opponentStrums', 0, 'alpha') ~= dimOpacity and opNotes == 0 then
			noteDetection('op', 'hide')
		elseif getPropertyFromGroup('opponentStrums', 0, 'alpha') ~= undimOpacity and opNotes > 0 then
			noteDetection('op', 'show')
		end
	end
end

function onTimerCompleted(tag)
	if not turnOffDimOp then
		if tag == 'opStrum' and opNotes == 0 then
			noteDetection('op', 'hide')
		elseif tag == 'opWait' and getPropertyFromGroup('opponentStrums', 0, 'alpha') ~= undimOpacity and opNotes > 0 then
			noteDetection('op', 'show')
		end
	end
	if not turnOffDimPl then
		if tag == 'plStrum' and plNotes == 0 then
			noteDetection('pl', 'hide')
		elseif tag == 'plWait' and getPropertyFromGroup('playerStrums', 0, 'alpha') ~= undimOpacity and plNotes > 0 then
			noteDetection('pl', 'show')
		end
	end
		if tag == 'functionStopCheck' and not turnOffDimOp and not turnOffDimPl then
			if getPropertyFromGroup('playerStrums', 0, 'alpha') ~= dimOpacity or getPropertyFromGroup('opponentStrums', 0, 'alpha') ~= dimOpacity then
				stopFunctionFix = true
			end
		end
end

function noteDetection(who, what)
	local tweenName, i1, i2, defaultStrumY, offNumber, passThrough
	if who == 'pl' then
		tweenName = 'pl'
		i1 = 4
		i2 = 7
		defaultStrumY = 'defaultPlayerStrumY'
		offNumber = 4
		passThrough = true
	else
		tweenName = 'op'
		i1 = 0
		i2 = 3
		defaultStrumY = 'defaultOpponentStrumY'
		offNumber = 0
		if not middlescroll and opStru then
			passThrough = true
		else
			passThrough = false
		end
	end
	if passThrough then
		if what == 'hide' then
			for i = i1,i2 do
				noteTweenAlpha(tweenName..'D'..i, i, dimOpacity, dimDuration, dimEase)
			end
		else
			for i = i1,i2 do
				noteTweenAlpha(tweenName..'D'..i, i, undimOpacity, undimDuration, undimEase)
			end
		end
	end
end

function onTweenCompleted(tag)
	if tag == 'opD0' then
		nuhuh = false
	elseif tag == 'plD4' then
		nuhuh1 = false
	end
end