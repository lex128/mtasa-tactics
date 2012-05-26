spawnCounter = {}
playerPlane = {}
function FlyMatch_onResourceStart(resource)
	createTacticsMode("fly",{timelimit="10:00",player_radarblip="all|none,team,all",spawn_into_plane="none|none,rustler,hydra,hunter,seasparrow,rc baron"})
end
function FlyMatch_onMapStopping(mapinfo)
	if (mapinfo.modename ~= "fly") then return end
	removeEventHandler("onPlayerRoundSpawn",root,FlyMatch_onPlayerRoundSpawn)
	removeEventHandler("onPlayerQuit",root,FlyMatch_onPlayerQuit)
	removeEventHandler("onPlayerWasted",root,FlyMatch_onPlayerWasted)
	removeEventHandler("onPlayerRoundRespawn",root,FlyMatch_onPlayerRoundRespawn)
	removeEventHandler("onRoundFinish",root,FlyMatch_onRoundFinish)
	removeEventHandler("onRoundTimesup",root,FlyMatch_onRoundTimesup)
	removeEventHandler("onVehicleStartExit",root,FlyMatch_onVehicleStartExit)
	removeEventHandler("onPauseToggle",root,FlyMatch_onPauseToggle)
	removeEventHandler("onPlayerRestored",root,FlyMatch_onPlayerRestored)
	for i,player in ipairs(getElementsByType("player")) do
		setElementData(player,"Kills",getElementData(player,"Kills"))
		setElementData(player,"Deaths",getElementData(player,"Deaths"))
	end
end
function FlyMatch_onMapStarting(mapinfo)
	if (mapinfo.modename ~= "fly") then return end
	if (isTimer(restartTimer)) then killTimer(restartTimer) end
	setTabboardColumns()
	setSideNames("Side 1","Side 2")
	spawnCounter = {}
	waitingTimer = "wait"
	addEventHandler("onPlayerRoundSpawn",root,FlyMatch_onPlayerRoundSpawn)
	addEventHandler("onPlayerQuit",root,FlyMatch_onPlayerQuit)
	addEventHandler("onPlayerWasted",root,FlyMatch_onPlayerWasted)
	addEventHandler("onPlayerRoundRespawn",root,FlyMatch_onPlayerRoundRespawn)
	addEventHandler("onRoundFinish",root,FlyMatch_onRoundFinish)
	addEventHandler("onRoundTimesup",root,FlyMatch_onRoundTimesup)
	addEventHandler("onVehicleStartExit",root,FlyMatch_onVehicleStartExit)
	addEventHandler("onPauseToggle",root,FlyMatch_onPauseToggle)
	addEventHandler("onPlayerRestored",root,FlyMatch_onPlayerRestored)
	if (getRoundModeSettings("spawn_into_plane") ~= "none") then
		for i,vehicle in ipairs(getElementsByType("vehicle")) do
			destroyElement(vehicle)
		end
	end
end
function FlyMatch_onRoundFinish()
	for _,player in ipairs(getElementsByType("player")) do
		setElementData(player,"Kills",getElementData(player,"Kills"))
		setElementData(player,"Deaths",getElementData(player,"Deaths"))
	end
end
function FlyMatch_onPlayerRoundSpawn()
	local team = getPlayerTeam(source)
	local model = getElementModel(source) or getElementData(team,"Skins")[1]
	if (getRoundState() == "stopped") then
		local teamsides = getTacticsData("Teamsides")
		local spawnpoints = getElementsByType("Team"..teamsides[team])
		if (#spawnpoints <= 0) then spawnpoints = getElementsByType("Team1") end
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
		callClientFunction(source,"setCameraInterior",interior)
		if (getRoundModeSettings("spawn_into_plane") ~= "none") then
			local model = getVehicleModelFromName(getRoundModeSettings("spawn_into_plane"))
			if (isElement(playerPlane[source])) then destroyElement(playerPlane[source]) end
			playerPlane[source] = createMapVehicle(model,posX,posY,posZ+1,0,0,rotZ)
			setElementFrozen(playerPlane[source],true)
			warpPedIntoVehicle(source,playerPlane[source])
		end
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
	FlyMatch_onCheckRound()
end
function FlyMatch_onPlayerRoundRespawn()
	local team = getPlayerTeam(source)
	local model = getElementModel(source) or getElementData(team,"Skins")[1]
	local teamsides = getTacticsData("Teamsides")
	local spawnpoints = getElementsByType("Team"..teamsides[team])
	if (#spawnpoints <= 0) then spawnpoints = getElementsByType("Team1") end
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
	setElementFrozen(source,true)
	toggleAllControls(source,false,true,false)
	if (getRoundModeSettings("spawn_into_plane") ~= "none") then
		local model = getVehicleModelFromName(getRoundModeSettings("spawn_into_plane"))
		if (isElement(playerPlane[source])) then destroyElement(playerPlane[source]) end
		playerPlane[source] = createMapVehicle(model,posX,posY,posZ+1,0,0,rotZ)
		setElementFrozen(playerPlane[source],true)
		warpPedIntoVehicle(source,playerPlane[source])
	end
	setElementData(source,"Status","Play")
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
end
function FlyMatch_onPlayerQuit(type,reason,element)
	if (getPlayerGameStatus(source) == "Play") then
		setElementData(source,"Status",nil)
		FlyMatch_onCheckRound()
		setTimer(function(player)
			if (isElement(playerPlane[player]) and not isRoundPaused()) then destroyElement(playerPlane[player]) end
		end,50,1,source)
	end
end
function FlyMatch_onCheckRound()
	if (getRoundState() ~= "started" or getTacticsData("Pause")) then return end
	local players = {}
	for i,team in ipairs(getElementsByType("team")) do
		if (i > 1) then
			local count = {0,team}
			for i,player in ipairs(getPlayersInTeam(team)) do
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
function FlyMatch_onRoundTimesup()
	local players = {}
	for i,team in ipairs(getElementsByType("team")) do
		if (i > 1) then
			local count = {0,0,team}
			for i,player in ipairs(getPlayersInTeam(team)) do
				if (getPlayerGameStatus(player) == "Play" and getPedOccupiedVehicle(player)) then
					count[1] = count[1] + 1
					count[2] = count[2] + math.floor(getElementHealth(getPedOccupiedVehicle(player)))
				end
			end
			table.insert(players,count)
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
function FlyMatch_onPlayerWasted(ammo,attacker,killerweapon,bodypart,stealth)
	if (isElement(playerPlane[source])) then destroyElement(playerPlane[source]) end
	if (attacker and getPlayerGameStatus(source) == "Play" and attacker ~= source) then
		if (getElementType(attacker) == "vehicle") then attacker = getVehicleController(attacker) end
		if (attacker) then setElementData(attacker,"Kills",getElementData(attacker,"Kills") + 1,false) end
		setElementData(source,"Deaths",getElementData(source,"Deaths") + 1,false)
	end
	setElementData(source,"Status","Die")
	fadeCamera(source,false,2.0)
	FlyMatch_onCheckRound()
end
function FlyMatch_onVehicleStartExit(player,seat,jacked)
	cancelEvent()
end
function FlyMatch_onPauseToggle(paused)
	if (not paused and getRoundModeSettings("spawn_into_plane") ~= "none") then
		for player,vehicle in pairs(playerPlane) do
			if (isElement(vehicle)) then destroyElement(vehicle) end
		end
	end
end
function FlyMatch_onPlayerRestored(store)
	if (getRoundModeSettings("spawn_into_plane") ~= "none") then
		playerPlane[source] = getPedOccupiedVehicle(source)
	end
end
addEventHandler("onMapStarting",root,FlyMatch_onMapStarting)
addEventHandler("onMapStopping",root,FlyMatch_onMapStopping)
addEventHandler("onResourceStart",resourceRoot,FlyMatch_onResourceStart)
