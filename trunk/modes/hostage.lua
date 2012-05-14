spawnCounter = {}
function Hostage_onResourceStart(resource)
	createTacticsMode("hostage",{timelimit="30:00",hostagekill="false"})
end
function Hostage_onMapStopping(mapinfo)
	if (mapinfo.modename ~= "hostage") then return end
	removeEventHandler("onPlayerRoundSpawn",root,Hostage_onPlayerRoundSpawn)
	removeEventHandler("onPlayerQuit",root,Hostage_onPlayerQuit)
	removeEventHandler("onPlayerDamage",root,Hostage_onPlayerDamage)
	removeEventHandler("onPlayerWasted",root,Hostage_onPlayerWasted)
	removeEventHandler("onPlayerRoundRespawn",root,Hostage_onPlayerRoundRespawn)
	removeEventHandler("onRoundStart",root,Hostage_onRoundStart)
	removeEventHandler("onRoundFinish",root,Hostage_onRoundFinish)
	removeEventHandler("onRoundTimesup",root,Hostage_onRoundTimesup)
	removeEventHandler("onVehicleStartEnter",root,Hostage_onVehicleStartEnter)
	removeEventHandler("onElementDataChange",root,Hostage_onElementDataChange)
	removeEventHandler("onPedWasted",root,Hostage_onPedWasted)
	for i,player in ipairs(getElementsByType("player")) do
		setPlayerProperty(player,"invulnerable",false)
		setElementData(player,"Kills",getElementData(player,"Kills"))
		setElementData(player,"Damage",getElementData(player,"Damage"))
		setElementData(player,"Deaths",getElementData(player,"Deaths"))
	end
end
function Hostage_onMapStarting(mapinfo)
	if (mapinfo.modename ~= "hostage") then return end
	if (isTimer(restartTimer)) then killTimer(restartTimer) end
	setTabboardColumns({{"Kills",0.09},{"Deaths",0.09},{"Damage",0.11}})
	setSideNames("Terror","Police")
	spawnCounter = {}
	waitingTimer = "wait"
	addEventHandler("onPlayerRoundSpawn",root,Hostage_onPlayerRoundSpawn)
	addEventHandler("onPlayerQuit",root,Hostage_onPlayerQuit)
	addEventHandler("onPlayerDamage",root,Hostage_onPlayerDamage)
	addEventHandler("onPlayerWasted",root,Hostage_onPlayerWasted)
	addEventHandler("onPlayerRoundRespawn",root,Hostage_onPlayerRoundRespawn)
	addEventHandler("onRoundStart",root,Hostage_onRoundStart)
	addEventHandler("onRoundFinish",root,Hostage_onRoundFinish)
	addEventHandler("onRoundTimesup",root,Hostage_onRoundTimesup)
	addEventHandler("onVehicleStartEnter",root,Hostage_onVehicleStartEnter)
	addEventHandler("onElementDataChange",root,Hostage_onElementDataChange)
	addEventHandler("onPedWasted",root,Hostage_onPedWasted)
	for _,rescue_vehicle in ipairs(getElementsByType("Rescue_Vehicle") or {}) do
		local x,y,z = getElementPosition(rescue_vehicle)
		local xr,yr,zr = getElementData(rescue_vehicle,"rotX"),getElementData(rescue_vehicle,"rotY"),getElementData(rescue_vehicle,"rotZ")
		local size = getElementData(rescue_vehicle,"size") or 10
		local vehicle = createVehicle(427,x,y,z,xr,yr,zr)
		setElementFrozen(vehicle,true)
		setVehicleDamageProof(vehicle,true)
		setVehicleLocked(vehicle,true)
		setVehicleSirensOn(vehicle,true)
		setElementParent(vehicle,rescue_vehicle)
		local colshape = createColSphere(x,y,z,size)
		setElementParent(colshape,rescue_vehicle)
		setElementData(colshape,"RescueVehicle",true)
		local blip = createBlipAttachedTo(vehicle,51,2,255,255,255,255,-1)
		setElementParent(blip,rescue_vehicle)
	end
	for _,hostage in ipairs(getElementsByType("Hostage") or {}) do
		local x,y,z = getElementPosition(hostage)
		local zr = getElementData(hostage,"rotZ")
		local model = getElementData(hostage,"model")
		local ped = createPed(model,x,y,z,zr)
		setElementSyncer(ped,true)
		setElementParent(ped,hostage)
		setElementData(ped,"Hostage",true)
	end
end
function Hostage_onRoundStart()
	for _,player in ipairs(getElementsByType("player")) do
		if (getPlayerGameStatus(player) == "Play") then
			givePlayerProperty(player,"invulnerable",true,5000)
			local team = getPlayerTeam(player)
			callClientFunction(player,"onClientWeaponChoose")
		end
	end
end
function Hostage_onRoundFinish()
	for _,player in ipairs(getElementsByType("player")) do
		setElementData(player,"Kills",getElementData(player,"Kills"))
		setElementData(player,"Damage",getElementData(player,"Damage"))
		setElementData(player,"Deaths",getElementData(player,"Deaths"))
	end
end
function Hostage_onPlayerRoundSpawn()
	local team = getPlayerTeam(source)
	local model = getElementModel(source) or getElementData(team,"Skins")[1]
	if (getRoundState() ~= "started" and not isTimer(winTimer)) then
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
	Hostage_onCheckRound()
end
function Hostage_onPlayerRoundRespawn()
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
function Hostage_onPlayerQuit(type,reason,element)
	if (getPlayerGameStatus(source) == "Play") then
		setElementData(source,"Status",nil)
		Hostage_onCheckRound()
	end
end
function Hostage_onCheckRound()
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
		endRound('draw_round','team_kill_all')
	end
end
function Hostage_onRoundTimesup()
	local sides = getTacticsData("Sides")
	local r,g,b = getTeamColor(sides[1])
	endRound({r,g,b,'team_win_round',getTeamName(sides[1])},'time_over_hostage_not_rescued',{[sides[1]]=1})
end
function Hostage_onPlayerDamage(attacker,weapon,bodypart,loss)
	if (attacker and getPlayerGameStatus(source) == "Play" and attacker ~= source) then
		if (getElementType(attacker) == "vehicle") then attacker = getVehicleController(attacker) end
		if (attacker) then
			setElementData(attacker,"Damage",math.floor(getElementData(attacker,"Damage") + loss),false)
		end
	end
end
function Hostage_onPlayerWasted(ammo,killer,weapon,bodypart,stealth)
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
	Hostage_onCheckRound()
end
function Hostage_onPedWasted(ammo,killer,weapon,bodypart,stealth)
	if (getElementData(source,"Hostage") and killer and getElementType(killer) == "player") then
		local teamkiller = getPlayerTeam(killer)
		local teamsides = getTacticsData("Teamsides")
		local sides = getTacticsData("Sides")
		if (teamsides[getPlayerTeam(killer)]%2 == 0) then
			local r,g,b = getTeamColor(sides[1])
			endRound({r,g,b,'team_win_round',getTeamName(sides[1])},'hostages_killed',{[sides[1]]=1})
		else
			local peds = 0
			for i,ped in ipairs(getElementsByType("ped")) do
				if (getElementData(ped,"Hostage") and ped ~= source and not isPedDead(ped)) then
					peds = peds + 1
				end
			end
			if (peds == 0) then
				local r,g,b = getTeamColor(sides[2])
				endRound({r,g,b,'team_win_round',getTeamName(sides[2])},'hostages_killed',{[sides[1]]=1})
			end
		end
	end
end
function Hostage_onHostageRescued(hostage)
	local player = getElementSyncer(hostage)
	if (player) then
		outputRoundLog(getPlayerName(player).." rescued hostage")
	else
		outputRoundLog("Hostage rescued")
	end
	destroyElement(hostage)
	callClientFunction(root,"playVoice","audio/hostage_rescued.mp3")
	local peds = 0
	for i,ped in ipairs(getElementsByType("ped")) do
		if (getElementData(ped,"Hostage") and not isPedDead(ped)) then
			peds = peds + 1
		end
	end
	if (peds == 0) then
		local sides = getTacticsData("Sides")
		local r,g,b = getTeamColor(sides[2])
		endRound({r,g,b,'team_win_round',getTeamName(sides[2])},'hostages_rescued',{[sides[2]]=1})
	end
end
function Hostage_onVehicleStartEnter(player,seat,jacked,door)
	cancelEvent()
end
function Hostage_onElementDataChange(data,old)
	if (getElementType(source) == "ped" and getElementData(source,"Hostage") and data == "Follow") then
		local follow = getElementData(source,data)
		if (follow) then
			setElementSyncer(source,follow)
		else
			setElementSyncer(source,true)
		end
	end
end
addEventHandler("onMapStarting",root,Hostage_onMapStarting)
addEventHandler("onMapStopping",root,Hostage_onMapStopping)
addEventHandler("onResourceStart",resourceRoot,Hostage_onResourceStart)
