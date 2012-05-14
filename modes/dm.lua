function DeathMatch_onResourceStart(resource)
	createTacticsMode("dm",{timelimit="10:00",fraglimit="50",player_radarblip="none|none,team,all"})
end
function DeathMatch_onMapStopping(mapinfo)
	if (mapinfo.modename ~= "dm") then return end
	setTacticsData(friendly_fire,"settings","friendly_fire")
	removeEventHandler("onPlayerRoundSpawn",root,DeathMatch_onPlayerRoundSpawn)
	removeEventHandler("onPlayerQuit",root,DeathMatch_onPlayerQuit)
	removeEventHandler("onPlayerDamage",root,DeathMatch_onPlayerDamage)
	removeEventHandler("onPlayerWasted",root,DeathMatch_onPlayerWasted)
	removeEventHandler("onRoundStart",root,DeathMatch_onRoundStart)
	removeEventHandler("onRoundFinish",root,DeathMatch_onRoundFinish)
	removeEventHandler("onRoundTimesup",root,DeathMatch_onRoundTimesup)
	removeEventHandler("onWeaponDrop",root,DeathMatch_onWeaponDrop)
	for i,player in ipairs(getElementsByType("player")) do
		setPlayerProperty(player,"invulnerable",false)
		setElementData(player,"Kills",getElementData(player,"Kills"))
		setElementData(player,"Damage",getElementData(player,"Damage"))
		setElementData(player,"Deaths",getElementData(player,"Deaths"))
	end
	if (getTacticsData("settings","autobalance") ~= "true") then balanceTeams() end
end
function DeathMatch_onMapStarting(mapinfo)
	if (mapinfo.modename ~= "dm") then return end
	friendly_fire = getTacticsData("settings","friendly_fire")
	setTacticsData("true","settings","friendly_fire")
	if (isTimer(restartTimer)) then killTimer(restartTimer) end
	setTabboardColumns({{"Frags",0.07},{"Kills",0.07},{"Deaths",0.07},{"Damage",0.08}})
	setSideNames("Side 1","Side 2")
	spawnCounter = nil
	waitingTimer = "wait"
	addEventHandler("onPlayerRoundSpawn",root,DeathMatch_onPlayerRoundSpawn)
	addEventHandler("onPlayerQuit",root,DeathMatch_onPlayerQuit)
	addEventHandler("onPlayerDamage",root,DeathMatch_onPlayerDamage)
	addEventHandler("onPlayerWasted",root,DeathMatch_onPlayerWasted)
	addEventHandler("onRoundStart",root,DeathMatch_onRoundStart)
	addEventHandler("onRoundFinish",root,DeathMatch_onRoundFinish)
	addEventHandler("onRoundTimesup",root,DeathMatch_onRoundTimesup)
	addEventHandler("onWeaponDrop",root,DeathMatch_onWeaponDrop)
end
function DeathMatch_onRoundStart()
	local teamsides = getTacticsData("Teamsides")
	for i,player in ipairs(getElementsByType("player")) do
		if (getPlayerGameStatus(player,"Status") == "Play" or getElementData(player) == "Loading") then
			givePlayerProperty(player,"invulnerable",true,5000)
			local team = getPlayerTeam(player)
			if (teamsides[team]) then
				callClientFunction(player,"onClientWeaponChoose")
				setElementData(player,"Frags",0)
			end
		end
	end
end
function DeathMatch_onRoundFinish()
	for _,player in ipairs(getElementsByType("player")) do
		setElementData(player,"Kills",getElementData(player,"Kills"))
		setElementData(player,"Damage",getElementData(player,"Damage"))
		setElementData(player,"Deaths",getElementData(player,"Deaths"))
	end
end
function DeathMatch_onPlayerRoundSpawn()
	if (not isTimer(winTimer)) then
		local team = getTacticsData("Sides")[1]
		local model = getElementData(team,"Skins")[1]
		local spawnpoints = getElementsByType("spawnpoint")
		if (not spawnCounter) then spawnCounter = 0 end
		spawnCounter = spawnCounter + 1
		if (spawnCounter > #spawnpoints) then
			spawnCounter = 1
		end
		local element = spawnpoints[spawnCounter]
		local posX = getElementData(element,"posX")
		local posY = getElementData(element,"posY")
		local posZ = getElementData(element,"posZ")
		local rotZ = getElementData(element,"rotZ") or 0
		local interior = getTacticsData("Interior") or 0
		spawnPlayer(source,posX,posY,posZ,rotZ,model,interior,0,team)
		setElementData(source,"Weapons",true)
		if (getRoundState() ~= "started") then
			setElementFrozen(source,true)
			toggleAllControls(source,false,true,false)
			toggleControl(source,"next_weapon",true)
			toggleControl(source,"previous_weapon",true)
		else
			setElementData(source,"Status","Play")
			givePlayerProperty(source,"invulnerable",true,2000)
			setCameraTarget(source,source)
			callClientFunction(source,"onClientWeaponChoose")
		end
		callClientFunction(source,"setCameraInterior",interior)
		if (not getElementData(source,"Kills")) then
			setElementData(source,"Frags",0)
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
	DeathMatch_onCheckRound()
end
function DeathMatch_onPlayerQuit(type,reason,element)
	if (getPlayerGameStatus(source) == "Play") then
		setElementData(source,"Status",nil)
		DeathMatch_onCheckRound()
	end
end
function DeathMatch_onCheckRound(killer,frags)
	if (getRoundState() ~= "started" or getTacticsData("Pause")) then return end
	local fraglimit = tonumber(getTacticsData("modes","dm","fraglimit") or 50)
	local players = {}
	for i,player in ipairs(getElementsByType("player")) do
		local frags = getElementData(player,"Frags") or 0
		table.insert(players,{player,frags})
	end
	table.sort(players,function(a,b) return a[2] > b[2] end)
	if (players[1][2] >= fraglimit) then
		local reason = ""
		for i,data in ipairs(players) do
			if (i > 1) then
				reason = string.format("%s\n%i) %s - %i",reason,i,getPlayerName(data[1]),data[2])
			end
		end
		endRound({'dm_winner',getPlayerName(players[1][1]),players[1][2]},reason)
	elseif (killer) then
		if (players[1][2] == players[2][2] and frags == players[1][2]) then
			callClientFunction(killer,"playVoice","audio/you_caught_leader.mp3")
		elseif (players[1][1] == killer and players[1][2] == players[2][2] + 1) then
			callClientFunction(killer,"playVoice","audio/you_capture_leadership.mp3")
			for i,data in ipairs(players) do
				if (data[2] == frags - 1) then
					callClientFunction(data[1],"playVoice","audio/you_lost_leadership.mp3")
				end
			end
		end
	end
end
function DeathMatch_onRoundTimesup()
	local players = {}
	for i,player in ipairs(getElementsByType("player")) do
		local frags = getElementData(player,"Frags") or 0
		table.insert(players,{player,frags})
	end
	if (#players > 0) then table.sort(players,function(a,b) return a[2] > b[2] end) end
	if (#players > 0 and players[1][2] > players[2][2]) then
		local reason = ""
		for i,data in ipairs(players) do
			if (i > 1) then
				reason = string.format("%s\n%i) %s - %i",reason,i,getPlayerName(data[1]),data[2])
			end
		end
		endRound({'dm_winner',getPlayerName(players[1][1]),players[1][2]},{'time_over',reason})
	else
		local reason = ""
		for i,data in ipairs(players) do
			reason = string.format("%s\n%i) %s - %i",reason,i,getPlayerName(data[1]),data[2])
		end
		endRound('draw_round',{'time_over',reason})
	end
end
function DeathMatch_onPlayerDamage(attacker,weapon,bodypart,loss)
	if (attacker and getPlayerGameStatus(source) == "Play" and attacker ~= source) then
		if (getElementType(attacker) == "vehicle") then attacker = getVehicleController(attacker) end
		if (attacker) then
			setElementData(attacker,"Damage",math.floor(getElementData(attacker,"Damage") + loss),false)
		end
	end
end
function DeathMatch_onPlayerWasted(ammo,killer,weapon,bodypart,stealth)
	local loss = getElementHealth(source)
	if (killer and getPlayerGameStatus(source) == "Play" and killer ~= source) then
		if (getElementType(killer) == "vehicle") then killer = getVehicleController(killer) end
		if (killer) then
			setElementData(killer,"Frags",getElementData(killer,"Frags") + 1)
			setElementData(killer,"Kills",getElementData(killer,"Kills") + 1,false)
			setElementData(killer,"Damage",math.floor(getElementData(killer,"Damage") + loss),false)
		end
		setElementData(source,"Deaths",getElementData(source,"Deaths") + 1,false)
	end
	setElementData(source,"Status","Die")
	fadeCamera(source,false,2.0)
	if (killer) then
		DeathMatch_onCheckRound(killer,getElementData(killer,"Frags"))
	else
		DeathMatch_onCheckRound()
	end
end
function DeathMatch_onWeaponDrop()
	cancelEvent()
end
addEventHandler("onMapStarting",root,DeathMatch_onMapStarting)
addEventHandler("onMapStopping",root,DeathMatch_onMapStopping)
addEventHandler("onResourceStart",resourceRoot,DeathMatch_onResourceStart)
