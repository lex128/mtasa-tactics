captureTimer = false
spawnCounter = {}
function AttackDefend_onResourceStart(resource)
	createTacticsMode("base",{timelimit="15:00",capturing="0:20",def_veh_jacking="false"})
end
function AttackDefend_onMapStopping(mapinfo)
	if (mapinfo.modename ~= "base") then return end
	if (isTimer(captureTimer)) then killTimer(captureTimer) end
	setTacticsData(nil,"timecapture")
	setTacticsData(nil,"teamcapture")
	removeEventHandler("onPlayerRoundSpawn",root,AttackDefend_onPlayerRoundSpawn)
	removeEventHandler("onPlayerQuit",root,AttackDefend_onPlayerQuit)
	removeEventHandler("onPlayerDamage",root,AttackDefend_onPlayerDamage)
	removeEventHandler("onPlayerWasted",root,AttackDefend_onPlayerWasted)
	removeEventHandler("onPlayerRoundRespawn",root,AttackDefend_onPlayerRoundRespawn)
	removeEventHandler("onRoundStart",root,AttackDefend_onRoundStart)
	removeEventHandler("onRoundFinish",root,AttackDefend_onRoundFinish)
	removeEventHandler("onRoundTimesup",root,AttackDefend_onRoundTimesup)
	removeEventHandler("onColShapeHit",root,AttackDefend_onColShapeHit)
	removeEventHandler("onColShapeLeave",root,AttackDefend_onColShapeLeave)
	removeEventHandler("onPauseToggle",root,AttackDefend_onPauseToggle)
	removeEventHandler("onVehicleStartEnter",root,AttackDefend_onVehicleStartEnter)
	for i,player in ipairs(getElementsByType("player")) do
		setPlayerProperty(player,"invulnerable",false)
		setElementData(player,"Kills",getElementData(player,"Kills"))
		setElementData(player,"Damage",getElementData(player,"Damage"))
		setElementData(player,"Deaths",getElementData(player,"Deaths"))
	end
end
function AttackDefend_onMapStarting(mapinfo)
	if (mapinfo.modename ~= "base") then return end
	if (isTimer(restartTimer)) then killTimer(restartTimer) end
	setTabboardColumns({{"Kills",0.09},{"Deaths",0.09},{"Damage",0.11}})
	setSideNames("Attack","Defend")
	spawnCounter = {}
	waitingTimer = "wait"
	addEventHandler("onPlayerRoundSpawn",root,AttackDefend_onPlayerRoundSpawn)
	addEventHandler("onPlayerQuit",root,AttackDefend_onPlayerQuit)
	addEventHandler("onPlayerDamage",root,AttackDefend_onPlayerDamage)
	addEventHandler("onPlayerWasted",root,AttackDefend_onPlayerWasted)
	addEventHandler("onPlayerRoundRespawn",root,AttackDefend_onPlayerRoundRespawn)
	addEventHandler("onRoundStart",root,AttackDefend_onRoundStart)
	addEventHandler("onRoundFinish",root,AttackDefend_onRoundFinish)
	addEventHandler("onRoundTimesup",root,AttackDefend_onRoundTimesup)
	addEventHandler("onColShapeHit",root,AttackDefend_onColShapeHit)
	addEventHandler("onColShapeLeave",root,AttackDefend_onColShapeLeave)
	addEventHandler("onPauseToggle",root,AttackDefend_onPauseToggle)
	addEventHandler("onVehicleStartEnter",root,AttackDefend_onVehicleStartEnter)
	local basepoint = getElementsByType("Central_Marker",getRoundMapRoot())[1]
	local x,y,z = getElementPosition(basepoint)
	local r,g,b = getTeamColor(getTacticsData("Sides")[2])
	local marker = createMarker(x,y,z,"cylinder",2,r,g,b,128)
	setElementParent(marker,basepoint)
	local colshape = createColTube(x,y,z,2,2)
	setElementParent(colshape,basepoint)
	setElementID(colshape,"CaptureFlag")
	local blip = createBlipAttachedTo(marker,19,2,r,g,b,255,-1)
	setElementParent(blip,basepoint)
end
function AttackDefend_onRoundStart()
	local teamsides = getTacticsData("Teamsides")
	for i,player in ipairs(getElementsByType("player")) do
		if (getPlayerGameStatus(player) == "Play") then
			givePlayerProperty(player,"invulnerable",true,15000)
			if (teamsides[getPlayerTeam(player)]%2 == 1) then
				callClientFunction(player,"onClientWeaponChoose")
				callClientFunction(player,"onClientVehicleChoose")
			else
				callClientFunction(player,"onClientWeaponChoose")
			end
		end
	end
end
function AttackDefend_onRoundFinish()
	if (isTimer(captureTimer)) then killTimer(captureTimer) end
	setTacticsData(nil,"timecapture")
	setTacticsData(nil,"teamcapture")
	for _,player in ipairs(getElementsByType("player")) do
		setElementData(player,"Kills",getElementData(player,"Kills"))
		setElementData(player,"Damage",getElementData(player,"Damage"))
		setElementData(player,"Deaths",getElementData(player,"Deaths"))
	end
end
function AttackDefend_onPlayerRoundSpawn()
	local team = getPlayerTeam(source)
	local model = getElementModel(source) or getElementData(team,"Skins")[1]
	if (getRoundState() ~= "started" and not isTimer(winTimer)) then
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
		fadeCamera(source,true,2.0)
	end
	AttackDefend_onCheckRound()
end
function AttackDefend_onPlayerRoundRespawn()
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
	if (teamsides[team]%2 == 1) then
		callClientFunction(source,"onClientWeaponChoose")
		callClientFunction(source,"onClientVehicleChoose")
	else
		callClientFunction(source,"onClientWeaponChoose")
	end
	callClientFunction(source,"setCameraInterior",interior)
	fadeCamera(source,true,2.0)
	givePlayerProperty(source,"invulnerable",true,15000)
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
function AttackDefend_onPlayerQuit(type,reason,element)
	if (not getTacticsData("Pause") and getTacticsData("timecapture") and getPlayerGameStatus(source) == "Play") then
		local colshape = getElementByID("CaptureFlag")
		if (isElementWithinColShape(source,colshape)) then
			local sides = getTacticsData("Sides")
			local capture = false
			for i,side in ipairs(sides) do
				if (i % 2 == 1) then
					for j,player in ipairs(getPlayersInTeam(side)) do
						if (player ~= source and isElementWithinColShape(player,colshape) and getPlayerGameStatus(player) == "Play") then
							capture = true
							break
						end
					end
					if (capture) then break end
				end
			end
			if (not capture) then
				killTimer(captureTimer)
				setTacticsData(nil,"timecapture")
			end
		end
	end
	if (getPlayerGameStatus(source) == "Play") then
		setElementData(source,"Status",nil)
		AttackDefend_onCheckRound()
	end
end
function AttackDefend_onCheckRound()
	if (getRoundState() ~= "started" or getTacticsData("Pause")) then return end
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
	elseif (players[1][1] == 0) then
		endRound('draw_round','nobody_alive')
	end
end
function AttackDefend_onRoundTimesup()
	local sides = getTacticsData("Sides")
	local r,g,b = getTeamColor(sides[2])
	endRound({r,g,b,'team_win_round',getTeamName(sides[2])},'time_over_base_not_captured',{[sides[2]]=1})
end
function AttackDefend_onPlayerDamage(attacker,weapon,bodypart,loss)
	if (attacker and getPlayerGameStatus(source) == "Play" and attacker ~= source) then
		if (getElementType(attacker) == "vehicle") then attacker = getVehicleController(attacker) end
		if (attacker) then
			setElementData(attacker,"Damage",math.floor(getElementData(attacker,"Damage") + loss),false)
		end
	end
end
function AttackDefend_onPlayerWasted(ammo,killer,killerweapon,bodypart,stealth)
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
	if (not getTacticsData("Pause") and getTacticsData("timecapture")) then
		local colshape = getElementByID("CaptureFlag")
		if (isElementWithinColShape(source,colshape)) then
			local sides = getTacticsData("Sides")
			local capture = false
			for i,side in ipairs(sides) do
				if (i % 2 == 1) then
					for j,player in ipairs(getPlayersInTeam(side)) do
						if (player ~= source and isElementWithinColShape(player,colshape) and getPlayerGameStatus(player) == "Play") then
							capture = true
							break
						end
					end
					if (capture) then break end
				end
			end
			if (not capture) then
				killTimer(captureTimer)
				setTacticsData(nil,"timecapture")
			end
		end
	end
	AttackDefend_onCheckRound()
end
function AttackDefend_onColShapeHit(element)
	if (getElementID(source) == "CaptureFlag" and not getTacticsData("Pause") and not getTacticsData("timecapture") and getElementType(element) == "player" and getPlayerGameStatus(element) == "Play") then
		local histeam = getPlayerTeam(element)
		local teamsides = getTacticsData("Teamsides")
		if (teamsides[histeam]%2 == 1) then
			local capturing = TimeToSec(getTacticsData("modes","base","capturing") or "0:20")
			captureTimer = setTimer(function(team)
				local r,g,b = getTeamColor(team)
				endRound({r,g,b,'team_win_round',getTeamName(team)},'base_captured',{[team]=1})
			end,capturing*1000,1,histeam)
			setTacticsData(histeam,"teamcapture")
			return setTacticsData(getTickCount() + capturing*1000,"timecapture")
		end
	end
end
function AttackDefend_onColShapeLeave(element)
	if (getElementID(source) == "CaptureFlag" and not getTacticsData("Pause") and getTacticsData("timecapture") and getElementType(element) == "player" and getPlayerGameStatus(element) == "Play") then
		local sides = getTacticsData("Sides")
		for i,side in ipairs(sides) do
			if (i % 2 == 1) then
				for j,player in ipairs(getPlayersInTeam(side)) do
					if (player ~= element and isElementWithinColShape(player,source) and getPlayerGameStatus(player) == "Play") then
						return
					end
				end
				if (isTimer(captureTimer)) then killTimer(captureTimer) end
				return setTacticsData(nil,"timecapture")
			end
		end
	end
end
function AttackDefend_onPauseToggle(toggle)
	if (toggle and isTimer(captureTimer)) then
		local remaining = getTimerDetails(captureTimer)
		killTimer(captureTimer)
		setTacticsData(remaining,"timecapture")
	elseif (not toggle) then
		local remaining = getTacticsData("timecapture")
		if (remaining) then
			local sides = getTacticsData("Sides")
			local colshape = getElementByID("CaptureFlag")
			local capture = false
			for i,side in ipairs(sides) do
				if (i % 2 == 1) then
					for j,player in ipairs(getPlayersInTeam(side)) do
						if (isElementWithinColShape(player,colshape) and getPlayerGameStatus(player) == "Play") then
							capture = true
							break
						end
					end
					if (capture) then break end
				end
			end
			if (capture) then
				local team = getTacticsData("teamcapture")
				setTacticsData(getTickCount()+remaining,"timecapture")
				captureTimer = setTimer(function(team)
					local r,g,b = getTeamColor(team)
					endRound({r,g,b,'team_win_round',getTeamName(team)},'base_captured',{[team]=1})
				end,remaining,1,team)
			else
				setTacticsData(nil,"timecapture")
				setTacticsData(nil,"teamcapture")
			end
		end
	end
end
function AttackDefend_onVehicleStartEnter(player)
	local teamsides = getTacticsData("Teamsides")
	local side = teamsides[getPlayerTeam(player)]
	if (not side) then return end
	side = (side-1)%2 + 1
	if (side == 2 and getTacticsData("modes","base","def_veh_jacking") == "false") then
		cancelEvent()
	end
end
addEventHandler("onMapStarting",root,AttackDefend_onMapStarting)
addEventHandler("onMapStopping",root,AttackDefend_onMapStopping)
addEventHandler("onResourceStart",resourceRoot,AttackDefend_onResourceStart)
