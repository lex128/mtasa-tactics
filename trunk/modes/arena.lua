spawnCounter = {}
function TeamDeathMatch_onResourceStart (resource)
	createTacticsMode ("arena", {timelimit="10:00"})
end
function TeamDeathMatch_onMapStopping (mapinfo)
	if (mapinfo.modename ~= "arena") then return end
	removeEventHandler ("onPlayerRoundSpawn", root, TeamDeathMatch_onPlayerRoundSpawn)
	removeEventHandler ("onPlayerQuit", root, TeamDeathMatch_onPlayerQuit)
	removeEventHandler ("onPlayerDamage", root, TeamDeathMatch_onPlayerDamage)
	removeEventHandler ("onPlayerWasted", root, TeamDeathMatch_onPlayerWasted)
	removeEventHandler ("onPlayerRoundRespawn", root,TeamDeathMatch_onPlayerRoundRespawn)
	removeEventHandler ("onRoundStart", root, TeamDeathMatch_onRoundStart)
	removeEventHandler ("onRoundFinish", root, TeamDeathMatch_onRoundFinish)
	removeEventHandler ("onRoundTimesup", root, TeamDeathMatch_onRoundTimesup)
	for i, player in ipairs (getElementsByType ("player")) do
		setPlayerProperty (player, "invulnerable", false)
		setElementData (player, "Kills", getElementData (player, "Kills"))
		setElementData (player, "Damage", getElementData (player, "Damage"))
		setElementData (player, "Deaths", getElementData (player, "Deaths"))
	end
end
function TeamDeathMatch_onMapStarting (mapinfo)
	if (mapinfo.modename ~= "arena") then return end
	if (isTimer (restartTimer)) then killTimer (restartTimer) end
	setTabboardColumns ({{"Kills", 0.09}, {"Deaths", 0.09}, {"Damage", 0.11}})
	setSideNames ("Side 1", "Side 2")
	spawnCounter = {}
	waitingTimer = "wait"
	addEventHandler ("onPlayerRoundSpawn", root, TeamDeathMatch_onPlayerRoundSpawn)
	addEventHandler ("onPlayerQuit", root, TeamDeathMatch_onPlayerQuit)
	addEventHandler ("onPlayerDamage", root, TeamDeathMatch_onPlayerDamage)
	addEventHandler ("onPlayerWasted", root, TeamDeathMatch_onPlayerWasted)
	addEventHandler ("onPlayerRoundRespawn", root, TeamDeathMatch_onPlayerRoundRespawn)
	addEventHandler ("onRoundStart", root, TeamDeathMatch_onRoundStart)
	addEventHandler ("onRoundFinish", root, TeamDeathMatch_onRoundFinish)
	addEventHandler ("onRoundTimesup", root, TeamDeathMatch_onRoundTimesup)
end
function TeamDeathMatch_onRoundStart ()
	for i, player in ipairs (getElementsByType ("player")) do
		if (getPlayerGameStatus (player) == "Play") then
			givePlayerProperty (player, "invulnerable", true, 5000)
			callClientFunction (player, "onClientWeaponChoose")
		end
	end
end
function TeamDeathMatch_onRoundFinish()
	for _,player in ipairs (getElementsByType ("player")) do
		setElementData (player, "Kills", getElementData (player, "Kills"))
		setElementData (player, "Damage", getElementData (player, "Damage"))
		setElementData (player, "Deaths", getElementData (player, "Deaths"))
	end
end
function TeamDeathMatch_onPlayerRoundSpawn()
	local team = getPlayerTeam (source)
	local model = getElementModel (source) or getElementData (team, "Skins")[1] or 7
	if (getRoundState() ~= "started" and not isTimer (winTimer)) then
		local teamsides = getTacticsData ("Teamsides")
		local spawnpoints = getElementsByType ("Team"..teamsides[team],getRoundMapRoot())
		if (#spawnpoints <= 0) then spawnpoints = getElementsByType ("Team1",getRoundMapRoot()) end
		if (not spawnCounter[teamsides[team]]) then spawnCounter[teamsides[team]] = 0 end
		spawnCounter[teamsides[team]] = spawnCounter[teamsides[team]] + 1
		if (spawnCounter[teamsides[team]] > #spawnpoints) then
			spawnCounter[teamsides[team]] = 1
		end
		local element = spawnpoints[spawnCounter[teamsides[team]]]
		local posX = getElementData (element, "posX")
		local posY = getElementData (element, "posY")
		local posZ = getElementData (element, "posZ")
		local rotZ = getElementData (element, "rotZ")
		local interior = getTacticsData ("Interior")
		spawnPlayer (source, posX, posY, posZ, rotZ, model, interior, 0, team)
		setElementFrozen (source, true)
		toggleAllControls (source, false, true, false)
		toggleControl (source, "next_weapon", true)
		toggleControl (source, "previous_weapon", true)
		setElementData (source, "Weapons", true)
		callClientFunction (source, "setCameraInterior", interior)
		if (not getElementData (source, "Kills")) then
			setElementData (source, "Kills", 0)
		end
		if (not getElementData (source, "Deaths")) then
			setElementData (source, "Deaths", 0)
		end
		if (not getElementData (source, "Damage")) then
			setElementData (source, "Damage", 0)
		end
		setElementData (source, "Status", "Play")
	else
		setElementData (source, "Status", "Spectate")
	end
	TeamDeathMatch_onCheckRound()
end
function TeamDeathMatch_onPlayerRoundRespawn()
	local team = getPlayerTeam (source)
	local model = getElementModel (source) or getElementData (team, "Skins")[1]
	local teamsides = getTacticsData ("Teamsides")
	local spawnpoints = getElementsByType ("Team"..teamsides[team],getRoundMapRoot())
	if (#spawnpoints <= 0) then spawnpoints = getElementsByType ("Team1",getRoundMapRoot()) end
	if (not spawnCounter[teamsides[team]]) then spawnCounter[teamsides[team]] = 0 end
	spawnCounter[teamsides[team]] = spawnCounter[teamsides[team]] + 1
	if (spawnCounter[teamsides[team]] > #spawnpoints) then
		spawnCounter[teamsides[team]] = 1
	end
	local element = spawnpoints[spawnCounter[teamsides[team]]]
	local posX = getElementData (element, "posX")
	local posY = getElementData (element, "posY")
	local posZ = getElementData (element, "posZ")
	local rotZ = getElementData (element, "rotZ")
	local interior = getTacticsData ("Interior")
	setCameraTarget (source, source)
	spawnPlayer (source, posX, posY, posZ, rotZ, model, interior, 0, team)
	setElementFrozen(source,false)
	toggleAllControls(source,true)
	setElementData(source,"Status","Play")
	setElementData(source,"Weapons",true)
	callClientFunction(source,"onClientWeaponChoose")
	callClientFunction(source,"setCameraInterior",interior)
	givePlayerProperty(source,"invulnerable",true,5000)
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
function TeamDeathMatch_onPlayerQuit(type,reason,element)
	if (getPlayerGameStatus(source) == "Play") then
		setElementData(source,"Status",nil)
		TeamDeathMatch_onCheckRound()
	end
end
function TeamDeathMatch_onCheckRound()
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
function TeamDeathMatch_onRoundTimesup()
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
function TeamDeathMatch_onPlayerDamage(attacker,weapon,bodypart,loss)
	if (attacker and getPlayerGameStatus(source) == "Play" and attacker ~= source) then
		if (getElementType(attacker) == "vehicle") then attacker = getVehicleController(attacker) end
		if (attacker) then
			setElementData(attacker,"Damage",math.floor(getElementData(attacker,"Damage") + loss),false)
		end
	end
end
function TeamDeathMatch_onPlayerWasted(ammo,killer,weapon,bodypart,stealth)
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
	TeamDeathMatch_onCheckRound()
end
addEventHandler("onMapStarting",root,TeamDeathMatch_onMapStarting)
addEventHandler("onMapStopping",root,TeamDeathMatch_onMapStopping)
addEventHandler("onResourceStart",resourceRoot,TeamDeathMatch_onResourceStart)
