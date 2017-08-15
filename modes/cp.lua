--[[**************************************************************************
*
*  ПРОЕКТ:        TACTICS MODES
*  ВЕРСИЯ ДВИЖКА: 1.2-r18
*  РАЗРАБОТЧИКИ:  Александр Романов <lexr128@gmail.com>
*
****************************************************************************]]
local captureTimer = {}
local captureBase = {}
local captureTeam = {}
local spawnCounter = {}
function ControlPoints_onResourceStart(resource)
	createTacticsMode("cp",{timelimit="7:30",capturing_1="0:15",capturing_2="0:12",capturing_more="0:10",spawnprotect="0:03"})
end
function ControlPoints_onMapStopping(mapinfo)
	if (mapinfo.modename ~= "cp") then return end
	for base in pairs(captureTimer) do
		if (isTimer(captureTimer[base])) then killTimer(captureTimer[base]) end
		captureTimer[base] = nil
		captureBase[base] = nil
		captureTeam[base] = nil
	end
	captureTimer = {}
	captureBase = {}
	captureTeam = {}
	removeEventHandler("onPlayerRoundSpawn",root,ControlPoints_onPlayerRoundSpawn)
	removeEventHandler("onPlayerQuit",root,ControlPoints_onPlayerQuit)
	removeEventHandler("onPlayerDamage",root,ControlPoints_onPlayerDamage)
	removeEventHandler("onPlayerWasted",root,ControlPoints_onPlayerWasted)
	removeEventHandler("onPlayerRoundRespawn",root,ControlPoints_onPlayerRoundRespawn)
	removeEventHandler("onRoundStart",root,ControlPoints_onRoundStart)
	removeEventHandler("onRoundFinish",root,ControlPoints_onRoundFinish)
	removeEventHandler("onRoundTimesup",root,ControlPoints_onRoundTimesup)
	removeEventHandler("onColShapeHit",root,ControlPoints_onColShapeHit)
	removeEventHandler("onColShapeLeave",root,ControlPoints_onColShapeLeave)
	removeEventHandler("onPauseToggle",root,ControlPoints_onPauseToggle)
	for i,player in ipairs(getElementsByType("player")) do
		setPlayerProperty(player,"invulnerable",false)
		setElementData(player,"Kills",getElementData(player,"Kills"))
		setElementData(player,"Damage",getElementData(player,"Damage"))
		setElementData(player,"Deaths",getElementData(player,"Deaths"))
	end
end
function ControlPoints_onMapStarting(mapinfo)
	if (mapinfo.modename ~= "cp") then return end
	if (isTimer(restartTimer)) then killTimer(restartTimer) end
	setTabboardColumns({{"Kills",0.09},{"Deaths",0.09},{"Damage",0.11}})
	setSideNames("Side 1","Side 2")
	spawnCounter = {}
	waitingTimer = "wait"
	addEventHandler("onPlayerRoundSpawn",root,ControlPoints_onPlayerRoundSpawn)
	addEventHandler("onPlayerQuit",root,ControlPoints_onPlayerQuit)
	addEventHandler("onPlayerDamage",root,ControlPoints_onPlayerDamage)
	addEventHandler("onPlayerWasted",root,ControlPoints_onPlayerWasted)
	addEventHandler("onPlayerRoundRespawn",root,ControlPoints_onPlayerRoundRespawn)
	addEventHandler("onRoundStart",root,ControlPoints_onRoundStart)
	addEventHandler("onRoundFinish",root,ControlPoints_onRoundFinish)
	addEventHandler("onRoundTimesup",root,ControlPoints_onRoundTimesup)
	addEventHandler("onColShapeHit",root,ControlPoints_onColShapeHit)
	addEventHandler("onColShapeLeave",root,ControlPoints_onColShapeLeave)
	addEventHandler("onPauseToggle",root,ControlPoints_onPauseToggle)
	local sides = getTacticsData("Sides")
	for i,basepoint in ipairs(getElementsByType("Capture_Point")) do
		local x,y,z = tonumber(getElementData(basepoint,"posX")),tonumber(getElementData(basepoint,"posY")),tonumber(getElementData(basepoint,"posZ"))
		local size = tonumber(getElementData(basepoint,"size")) or 3
		local team = tonumber(getElementData(basepoint,"team")) or 0
		local r,g,b,a = 192,192,192,32
		if (sides[team]) then
			r,g,b = getTeamColor(sides[team])
		end
		local marker = createMarker(x,y,z,"cylinder",size,r,g,b,a)
		setElementParent(marker,basepoint)
		captureBase[basepoint] = createColTube(x,y,z,0.5*size,0.5*size)
		setElementParent(captureBase[basepoint],basepoint)
		local blip = createBlipAttachedTo(marker,0,3,r,g,b,255,-1)
		setElementParent(blip,basepoint)
		captureTeam[basepoint] = sides[team] or false
	end
end
function ControlPoints_onRoundStart()
	local spawnprotect = TimeToSec(getRoundModeSettings("spawnprotect"))
	local teamsides = getTacticsData("Teamsides")
	for i,player in ipairs(getElementsByType("player")) do
		if (getPlayerGameStatus(player) == "Play") then
			givePlayerProperty(player,"invulnerable",true,spawnprotect*1000)
			callClientFunction(player,"toggleWeaponManager",true)
		end
	end
end
function ControlPoints_onRoundFinish()
	for base in pairs(captureTimer) do
		if (isTimer(captureTimer[base])) then killTimer(captureTimer[base]) end
		removeElementData(base,"Capture")
	end
	for _,player in ipairs(getElementsByType("player")) do
		setElementData(player,"Kills",getElementData(player,"Kills"))
		setElementData(player,"Damage",getElementData(player,"Damage"))
		setElementData(player,"Deaths",getElementData(player,"Deaths"))
	end
end
function ControlPoints_onPlayerRoundSpawn()
	local team = getPlayerTeam(source)
	local model = getElementModel(source) or getElementData(team,"Skins")[1]
	if (getRoundState() == "stopped") then
		local teamsides = getTacticsData("Teamsides")
		local spawnpoints = getElementsByType("Team"..teamsides[team],getRoundMapRoot())
		if (#spawnpoints <= 0) then spawnpoints = getElementsByType("Team1",getRoundMapRoot()) end
		if (not spawnCounter[teamsides[team]]) then spawnCounter[teamsides[team]] = 0 end
		spawnCounter[teamsides[team]] = spawnCounter[teamsides[team]] + 1
		if (spawnCounter[teamsides[team]] > #spawnpoints) then
			spawnCounter[teamsides[team]] = 1
		end
		local element = spawnpoints[spawnCounter[teamsides[team]]]
		local posX = getElementData(element,"posX")
		local posY = getElementData(element,"posY")
		local posZ = getElementData(element,"posZ")
		local rotZ = getElementData(element,"rotZ")
		local interior = getTacticsData("Interior")
		spawnPlayer(source,posX,posY,posZ,rotZ,model,interior,0,team)
		setElementFrozen(source,true)
		toggleAllControls(source,false,true,false)
		toggleControl(source,"next_weapon",true)
		toggleControl(source,"previous_weapon",true)
		setElementData(source,"Weapons",true)
		callClientFunction(source,"setCameraInterior",interior)
		if (not getElementData(source,"Kills")) then
			setElementData(source,"Kills",0)
		end
		if (not getElementData(source,"Deaths")) then
			setElementData(source,"Deaths",0)
		end
		if (not getElementData(source,"Damage")) then
			setElementData(source,"Damage",0)
		end
		setElementData(source,"Status","Play")
	else
		setElementData(source,"Status","Spectate")
	end
	ControlPoints_onCheckRound()
end
function ControlPoints_onPlayerRoundRespawn()
	local team = getPlayerTeam(source)
	local model = getElementModel(source) or getElementData(team,"Skins")[1]
	local teamsides = getTacticsData("Teamsides")
	local spawnpoints = getElementsByType("Team"..teamsides[team],getRoundMapRoot())
	if (#spawnpoints <= 0) then spawnpoints = getElementsByType("Team1",getRoundMapRoot()) end
	if (not spawnCounter[teamsides[team]]) then spawnCounter[teamsides[team]] = 0 end
	spawnCounter[teamsides[team]] = spawnCounter[teamsides[team]] + 1
	if (spawnCounter[teamsides[team]] > #spawnpoints) then
		spawnCounter[teamsides[team]] = 1
	end
	local element = spawnpoints[spawnCounter[teamsides[team]]]
	local posX = getElementData(element,"posX")
	local posY = getElementData(element,"posY")
	local posZ = getElementData(element,"posZ")
	local rotZ = getElementData(element,"rotZ")
	local interior = getTacticsData("Interior")
	setCameraTarget(source,source)
	spawnPlayer(source,posX,posY,posZ,rotZ,model,interior,0,team)
	setElementFrozen(source,false)
	toggleAllControls(source,true)
	setElementData(source,"Status","Play")
	setElementData(source,"Weapons",true)
	callClientFunction(source,"toggleWeaponManager",true)
	callClientFunction(source,"setCameraInterior",interior)
	local spawnprotect = TimeToSec(getRoundModeSettings("spawnprotect"))
	givePlayerProperty(source,"invulnerable",true,spawnprotect*1000)
	if (not getElementData(source,"Kills")) then
		setElementData(source,"Kills",0)
	end
	if (not getElementData(source,"Deaths")) then
		setElementData(source,"Deaths",0)
	end
	if (not getElementData(source,"Damage")) then
		setElementData(source,"Damage",0)
	end
end
function ControlPoints_onPlayerQuit(type,reason,element)
	if (not isRoundPaused() and getPlayerGameStatus(source) == "Play") then
		for base,colshape in pairs(captureBase) do
			if (isElementWithinColShape(source,colshape) and getElementData(base,"Capture")) then
				local players = getElementsWithinColShape(colshape,"player")
				local index = {}
				local teams = {}
				for i,player in ipairs(players) do
					if (player ~= source and getPlayerGameStatus(player) == "Play") then
						local tm = getPlayerTeam(player)
						if (index[tm]) then
							teams[index[tm]].count = teams[index[tm]].count + 1
						else
							table.insert(teams,{team=tm,count=1})
							index[tm] = #teams
						end
					end
				end
				table.sort(teams,function(a,b)
					return a.count > b.count
				end)
				if (teams[1] and teams[1].count > 0) then
					local capturers = teams[1].count
					if (teams[2] and teams[2].count > 0) then capturers = 0 end
					local progress = 1
					local capturing = TimeToSec(getRoundModeSettings("capturing_1"))
					local remaining = capturing*1000
					if (getElementData(base,"Capture") and getElementData(base,"Capture")[3] == teams[1].team) then
						remaining = getElementData(base,"Capture")[1]
						if (isTimer(captureTimer[base])) then
							remaining = getTimerDetails(captureTimer[base])
							killTimer(captureTimer[base])
						end
						capturing = getElementData(base,"Capture")[2]
						progress = remaining/capturing/1000
					end
					if (capturers >= 3) then capturing = TimeToSec(getRoundModeSettings("capturing_more")) end
					if (capturers == 2) then capturing = TimeToSec(getRoundModeSettings("capturing_2")) end
					if (capturers == 1) then capturing = TimeToSec(getRoundModeSettings("capturing_1")) end
					if (capturers > 0 and teams[1].team ~= captureTeam[base]) then
						remaining = math.max(50,progress*capturing*1000)
						captureTimer[base] = setTimer(ControlPoints_onBaseCaptured,remaining,1,base,teams[1].team)
						setElementData(base,"Capture",{getTickCount()+remaining,capturing,teams[1].team})
					elseif (teams[1].team == captureTeam[base] and not teams[2]) then
						if (isTimer(captureTimer[base])) then killTimer(captureTimer[base]) end
						removeElementData(base,"Capture")
					else
						captureTimer[base] = true
						setElementData(base,"Capture",{remaining,capturing,teams[1].team,true})
					end
				else
					if (isTimer(captureTimer[base])) then killTimer(captureTimer[base]) end
					removeElementData(base,"Capture")
				end
			end
		end
	end
	if (getPlayerGameStatus(source) == "Play") then
		setElementData(source,"Status",nil)
		ControlPoints_onCheckRound()
	end
end
function ControlPoints_onPlayerDamage(attacker,weapon,bodypart,loss)
	if (attacker and getPlayerGameStatus(source) == "Play" and attacker ~= source) then
		if (getElementType(attacker) == "vehicle") then attacker = getVehicleController(attacker) end
		if (attacker) then
			setElementData(attacker,"Damage",math.floor(getElementData(attacker,"Damage") + loss),false)
		end
		for base,colshape in pairs(captureBase) do
			if (isElementWithinColShape(source,colshape) and getElementData(base,"Capture") and getPlayerTeam(source) == getElementData(base,"Capture")[3]) then
				local remaining,capturing,team,block = unpack(getElementData(base,"Capture"))
				if (isTimer(captureTimer[base])) then
					remaining = getTimerDetails(captureTimer[base])
					killTimer(captureTimer[base])
				end
				local progress = remaining/capturing/1000
				progress = math.min(1,progress + loss/100)
				remaining = math.max(50,progress*capturing*1000)
				if (not block and not isRoundPaused()) then
					captureTimer[base] = setTimer(ControlPoints_onBaseCaptured,remaining,1,base,team)
					setElementData(base,"Capture",{getTickCount()+remaining,capturing,team,block})
				else
					setElementData(base,"Capture",{remaining,capturing,team,block})
				end
			end
		end
	end
end
function ControlPoints_onPlayerWasted(ammo,killer,killerweapon,bodypart,stealth)
	local loss = getElementHealth(source)
	if (killer and getPlayerGameStatus(source) == "Play" and killer ~= source) then
		if (getElementType(killer) == "vehicle") then killer = getVehicleController(killer) end
		if (killer) then
			setElementData(killer,"Kills",getElementData(killer,"Kills") + 1,false)
			setElementData(killer,"Damage",math.floor(getElementData(killer,"Damage") + loss),false)
		end
		setElementData(source,"Deaths",getElementData(source,"Deaths") + 1,false)
	end
	setElementData(source,"Status","Die")
	fadeCamera(source,false,2.0)
	if (not isRoundPaused()) then
		for base,colshape in pairs(captureBase) do
			if (isElementWithinColShape(source,colshape) and getElementData(base,"Capture")) then
				local players = getElementsWithinColShape(colshape,"player")
				local index = {}
				local teams = {}
				for i,player in ipairs(players) do
					if (player ~= source and getPlayerGameStatus(player) == "Play") then
						local tm = getPlayerTeam(player)
						if (index[tm]) then
							teams[index[tm]].count = teams[index[tm]].count + 1
						else
							table.insert(teams,{team=tm,count=1})
							index[tm] = #teams
						end
					end
				end
				table.sort(teams,function(a,b)
					return a.count > b.count
				end)
				if (teams[1] and teams[1].count > 0) then
					local capturers = teams[1].count
					if (teams[2] and teams[2].count > 0) then capturers = 0 end
					local progress = 1
					local capturing = TimeToSec(getRoundModeSettings("capturing_1"))
					local remaining = capturing*1000
					if (getElementData(base,"Capture") and getElementData(base,"Capture")[3] == teams[1].team) then
						remaining = getElementData(base,"Capture")[1]
						if (isTimer(captureTimer[base])) then
							remaining = getTimerDetails(captureTimer[base])
							killTimer(captureTimer[base])
						end
						capturing = getElementData(base,"Capture")[2]
						progress = remaining/capturing/1000
					end
					if (capturers >= 3) then capturing = TimeToSec(getRoundModeSettings("capturing_more")) end
					if (capturers == 2) then capturing = TimeToSec(getRoundModeSettings("capturing_2")) end
					if (capturers == 1) then capturing = TimeToSec(getRoundModeSettings("capturing_1")) end
					if (capturers > 0 and teams[1].team ~= captureTeam[base]) then
						remaining = math.max(50,progress*capturing*1000)
						captureTimer[base] = setTimer(ControlPoints_onBaseCaptured,remaining,1,base,teams[1].team)
						setElementData(base,"Capture",{getTickCount()+remaining,capturing,teams[1].team})
					elseif (teams[1].team == captureTeam[base] and not teams[2]) then
						if (isTimer(captureTimer[base])) then killTimer(captureTimer[base]) end
						removeElementData(base,"Capture")
					else
						captureTimer[base] = true
						setElementData(base,"Capture",{remaining,capturing,teams[1].team,true})
					end
				else
					if (isTimer(captureTimer[base])) then killTimer(captureTimer[base]) end
					removeElementData(base,"Capture")
				end
			end
		end
	end
	ControlPoints_onCheckRound()
end
function ControlPoints_onCheckRound()
	if (getRoundState() ~= "started" or isRoundPaused()) then return end
	local players = {}
	for i,team in ipairs(getElementsByType("team")) do
		if (i > 1) then
			local count = {0,team}
			for j,player in ipairs(getPlayersInTeam(team)) do
				if (getPlayerGameStatus(player) == "Play") then
					count[1] = count[1] + 1
				end
			end
			table.insert(players,count)
		end
	end
	table.sort(players,function(a,b) return a[1] > b[1] end)
	if (players[1][1] > 0 and players[2][1] == 0) then
		local r,g,b = getTeamColor(players[1][2])
		endRound({r,g,b,'team_win_round',getTeamName(players[1][2])},'team_kill_all',{[players[1][2]]=1})
		return true
	elseif (players[1][1] == 0) then
		endRound('draw_round','nobody_alive')
		return true
	end
	return false
end
function ControlPoints_onBaseCaptured(base,team)
	local r,g,b = getTeamColor(team)
	captureTeam[base] = team
	local marker = getElementChildren(base,"marker")[1]
	setMarkerColor(marker,r,g,b,32)
	local blip = getElementChildren(base,"blip")[1]
	setBlipColor(blip,r,g,b,255)
	if (isTimer(captureTimer[base])) then killTimer(captureTimer[base]) end
	removeElementData(base,"Capture")
	if (not ControlPoints_onCheckRound()) then
		local capture = false
		for base,tm in pairs(captureTeam) do
			if (not capture) then capture = tm end
			if (capture ~= tm) then capture = true end
		end
		if (capture == team) then
			local r,g,b = getTeamColor(capture)
			endRound({r,g,b,'team_win_round',getTeamName(capture)},'base_captured',{[capture]=1})
		end
	end
end
function ControlPoints_onRoundTimesup()
	local teamcaptured = {}
	for base, tm in pairs(captureTeam) do
		if tm then
			teamcaptured[tm] = (teamcaptured[tm] or 0) + 1
		end
	end
	local captured = {}
	for tm, bases in pairs(teamcaptured) do
		captured[#captured + 1] = {bases, tm}
	end
	table.sort(captured,function(a,b) return a[1] > b[1] or (a[1] == b[1] and a[2] >= b[2]) end)
	if (#captured > 1 and captured[1][1] > captured[2][1]) or #captured == 1 then
		local r,g,b = getTeamColor(captured[1][2])
		endRound({r,g,b,'team_win_round',getTeamName(captured[1][2])},'base_captured',{[captured[1][2]]=1})
		return
	end

	local players = {}
	for i,team in ipairs(getElementsByType("team")) do
		if (i > 1) then
			local count = {0,0,team}
			for i,player in ipairs(getPlayersInTeam(team)) do
				if (getPlayerGameStatus(player) == "Play") then
					count[1] = count[1] + 1
					count[2] = count[2] + math.floor(getElementHealth(player))
				end
			end
			players[#players + 1] = count
		end
	end
	table.sort(players,function(a,b) return a[1] > b[1] or (a[1] == b[1] and a[2] >= b[2]) end)
	local reason = ""
	for i,data in ipairs(players) do
		reason = string.format("%s\n%s - %i / %i hp",reason,getTeamName(data[3]),data[1],data[2])
	end
	if (players[1][1] > players[2][1] and players[1][2] ~= 0) then
		local r,g,b = getTeamColor(players[1][3])
		endRound({r,g,b,'team_win_round',getTeamName(players[1][3])},{'time_over',reason},{[players[1][3]]=1})
	elseif (players[1][2] > players[2][2]) then
		local r,g,b = getTeamColor(players[1][3])
		endRound({r,g,b,'team_win_round',getTeamName(players[1][3])},{'time_over',reason},{[players[1][3]]=1})
	else
		endRound('draw_round',{'time_over',reason})
	end
end
function ControlPoints_onColShapeHit(element)
	if (not isRoundPaused() and getElementType(element) == "player" and getPlayerGameStatus(element) == "Play") then
		for base,colshape in pairs(captureBase) do
			if (source == colshape) then
				local players = getElementsWithinColShape(colshape,"player")
				local index = {}
				local teams = {}
				for i,player in ipairs(players) do
					if (getPlayerGameStatus(player) == "Play") then
						local tm = getPlayerTeam(player)
						if (index[tm]) then
							teams[index[tm]].count = teams[index[tm]].count + 1
						else
							table.insert(teams,{team=tm,count=1})
							index[tm] = #teams
						end
					end
				end
				table.sort(teams,function(a,b)
					return a.count > b.count
				end)
				if (teams[1] and teams[1].count > 0) then
					local capturers = teams[1].count
					if (teams[2] and teams[2].count > 0) then capturers = 0 end
					local progress = 1
					local capturing = TimeToSec(getRoundModeSettings("capturing_1"))
					local remaining = capturing*1000
					if (getElementData(base,"Capture") and getElementData(base,"Capture")[3] == teams[1].team) then
						remaining = getElementData(base,"Capture")[1]
						if (isTimer(captureTimer[base])) then
							remaining = getTimerDetails(captureTimer[base])
							killTimer(captureTimer[base])
						end
						capturing = getElementData(base,"Capture")[2]
						progress = remaining/capturing/1000
					end
					if (capturers >= 3) then capturing = TimeToSec(getRoundModeSettings("capturing_more")) end
					if (capturers == 2) then capturing = TimeToSec(getRoundModeSettings("capturing_2")) end
					if (capturers == 1) then capturing = TimeToSec(getRoundModeSettings("capturing_1")) end
					if (capturers > 0 and teams[1].team ~= captureTeam[base]) then
						remaining = math.max(50,progress*capturing*1000)
						captureTimer[base] = setTimer(ControlPoints_onBaseCaptured,remaining,1,base,teams[1].team)
						setElementData(base,"Capture",{getTickCount()+remaining,capturing,teams[1].team})
					elseif (teams[1].team == captureTeam[base] and not teams[2]) then
						if (isTimer(captureTimer[base])) then killTimer(captureTimer[base]) end
						removeElementData(base,"Capture")
					else
						captureTimer[base] = true
						setElementData(base,"Capture",{remaining,capturing,teams[1].team,true})
					end
				else
					if (isTimer(captureTimer[base])) then killTimer(captureTimer[base]) end
					removeElementData(base,"Capture")
				end
				break
			end
		end
	end
end
function ControlPoints_onColShapeLeave(element)
	if (not isRoundPaused() and getElementType(element) == "player" and getPlayerGameStatus(element) == "Play") then
		for base,colshape in pairs(captureBase) do
			if (source == colshape and getElementData(base,"Capture")) then
				local players = getElementsWithinColShape(colshape,"player")
				local index = {}
				local teams = {}
				for i,player in ipairs(players) do
					if (element ~= player and getPlayerGameStatus(player) == "Play") then
						local tm = getPlayerTeam(player)
						if (index[tm]) then
							teams[index[tm]].count = teams[index[tm]].count + 1
						else
							table.insert(teams,{team=tm,count=1})
							index[tm] = #teams
						end
					end
				end
				table.sort(teams,function(a,b)
					return a.count > b.count
				end)
				if (teams[1] and teams[1].count > 0) then
					local capturers = teams[1].count
					if (teams[2] and teams[2].count > 0) then capturers = 0 end
					local progress = 1
					local capturing = TimeToSec(getRoundModeSettings("capturing_1"))
					local remaining = capturing*1000
					if (getElementData(base,"Capture") and getElementData(base,"Capture")[3] == teams[1].team) then
						remaining = getElementData(base,"Capture")[1]
						if (isTimer(captureTimer[base])) then
							remaining = getTimerDetails(captureTimer[base])
							killTimer(captureTimer[base])
						end
						capturing = getElementData(base,"Capture")[2]
						progress = remaining/capturing/1000
					end
					if (capturers >= 3) then capturing = TimeToSec(getRoundModeSettings("capturing_more")) end
					if (capturers == 2) then capturing = TimeToSec(getRoundModeSettings("capturing_2")) end
					if (capturers == 1) then capturing = TimeToSec(getRoundModeSettings("capturing_1")) end
					if (capturers > 0 and teams[1].team ~= captureTeam[base]) then
						remaining = math.max(50,progress*capturing*1000)
						captureTimer[base] = setTimer(ControlPoints_onBaseCaptured,remaining,1,base,teams[1].team)
						setElementData(base,"Capture",{getTickCount()+remaining,capturing,teams[1].team})
					elseif (teams[1].team == captureTeam[base] and not teams[2]) then
						if (isTimer(captureTimer[base])) then killTimer(captureTimer[base]) end
						removeElementData(base,"Capture")
					else
						captureTimer[base] = true
						setElementData(base,"Capture",{remaining,capturing,teams[1].team,true})
					end
				else
					if (isTimer(captureTimer[base])) then killTimer(captureTimer[base]) end
					removeElementData(base,"Capture")
				end
				break
			end
		end
	end
end
function ControlPoints_onPauseToggle(toggle)
	if (toggle) then
		for base,colshape in pairs(captureBase) do
			if (isTimer(captureTimer[base])) then
				local remaining = getTimerDetails(captureTimer[base])
				killTimer(captureTimer[base])
				local capture = getElementData(base,"Capture")
				capture[1] = remaining
				setElementData(base,"Capture",capture)
			end
		end
	elseif (not toggle) then
		for base,colshape in pairs(captureBase) do
			local players = getElementsWithinColShape(colshape,"player")
			local index = {}
			local teams = {}
			for i,player in ipairs(players) do
				if (getPlayerGameStatus(player) == "Play") then
					local tm = getPlayerTeam(player)
					if (index[tm]) then
						teams[index[tm]].count = teams[index[tm]].count + 1
					else
						table.insert(teams,{team=tm,count=1})
						index[tm] = #teams
					end
				end
			end
			table.sort(teams,function(a,b)
				return a.count > b.count
			end)
			if (teams[1] and teams[1].count > 0) then
				local capturers = teams[1].count
				if (teams[2] and teams[2].count > 0) then capturers = 0 end
				local progress = 1
				local capturing = TimeToSec(getRoundModeSettings("capturing_1"))
				local remaining = capturing*1000
				if (getElementData(base,"Capture") and getElementData(base,"Capture")[3] == teams[1].team) then
					remaining = getElementData(base,"Capture")[1]
					if (isTimer(captureTimer[base])) then
						remaining = getTimerDetails(captureTimer[base])
						killTimer(captureTimer[base])
					end
					capturing = getElementData(base,"Capture")[2]
					progress = remaining/capturing/1000
				end
				if (capturers >= 3) then capturing = TimeToSec(getRoundModeSettings("capturing_more")) end
				if (capturers == 2) then capturing = TimeToSec(getRoundModeSettings("capturing_2")) end
				if (capturers == 1) then capturing = TimeToSec(getRoundModeSettings("capturing_1")) end
				if (capturers > 0 and teams[1].team ~= captureTeam[base]) then
					remaining = math.max(50,progress*capturing*1000)
					captureTimer[base] = setTimer(ControlPoints_onBaseCaptured,remaining,1,base,teams[1].team)
					setElementData(base,"Capture",{getTickCount()+remaining,capturing,teams[1].team})
				elseif (teams[1].team == captureTeam[base] and not teams[2]) then
					if (isTimer(captureTimer[base])) then killTimer(captureTimer[base]) end
					removeElementData(base,"Capture")
				else
					captureTimer[base] = true
					setElementData(base,"Capture",{remaining,capturing,teams[1].team,true})
				end
			else
				if (isTimer(captureTimer[base])) then killTimer(captureTimer[base]) end
				removeElementData(base,"Capture")
			end
		end
	end
end
addEventHandler("onMapStarting",root,ControlPoints_onMapStarting)
addEventHandler("onMapStopping",root,ControlPoints_onMapStopping)
addEventHandler("onResourceStart",resourceRoot,ControlPoints_onResourceStart)
