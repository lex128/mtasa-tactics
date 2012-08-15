spawnCounter = {}
playerVIP = nil
function VeryImportantPerson_onResourceStart(resource)
	createTacticsMode("vip",{timelimit="10:00", spawnprotect="0:05"})
end
function VeryImportantPerson_onMapStopping(mapinfo)
	if (mapinfo.modename ~= "vip") then return end
	removeEventHandler("onPlayerRoundSpawn",root,VeryImportantPerson_onPlayerRoundSpawn)
	removeEventHandler("onPlayerQuit",root,VeryImportantPerson_onPlayerQuit)
	removeEventHandler("onPlayerDamage",root,VeryImportantPerson_onPlayerDamage)
	removeEventHandler("onPlayerWasted",root,VeryImportantPerson_onPlayerWasted)
	removeEventHandler("onPlayerRoundRespawn",root,VeryImportantPerson_onPlayerRoundRespawn)
	removeEventHandler("onRoundStart",root,VeryImportantPerson_onRoundStart)
	removeEventHandler("onRoundFinish",root,VeryImportantPerson_onRoundFinish)
	removeEventHandler("onRoundTimesup",root,VeryImportantPerson_onRoundTimesup)
	removeEventHandler("onPlayerWeaponpackGot",root,VeryImportantPerson_onPlayerWeaponpackGot)
	removeEventHandler("onVehicleEnter",root,VeryImportantPerson_onVehicleEnter)
	removeEventHandler("onVehicleStartEnter",root,VeryImportantPerson_onVehicleStartEnter)
	removeEventHandler("onWeaponDrop",root,VeryImportantPerson_onWeaponDrop)
	removeEventHandler("onWeaponPickup",root,VeryImportantPerson_onWeaponPickup)
	for i,player in ipairs(getElementsByType("player")) do
		setPlayerProperty(player,"invulnerable",false)
		setElementData(player,"Kills",getElementData(player,"Kills"))
		setElementData(player,"Damage",getElementData(player,"Damage"))
		setElementData(player,"Deaths",getElementData(player,"Deaths"))
	end
	playerVIP = nil
end
function VeryImportantPerson_onMapStarting(mapinfo)
	if (mapinfo.modename ~= "vip") then return end
	if (isTimer(restartTimer)) then killTimer(restartTimer) end
	setTabboardColumns({{"Kills",0.09},{"Deaths",0.09},{"Damage",0.11}})
	setSideNames("VIP group","Terror")
	spawnCounter = {}
	waitingTimer = "wait"
	addEventHandler("onPlayerRoundSpawn",root,VeryImportantPerson_onPlayerRoundSpawn)
	addEventHandler("onPlayerQuit",root,VeryImportantPerson_onPlayerQuit)
	addEventHandler("onPlayerDamage",root,VeryImportantPerson_onPlayerDamage)
	addEventHandler("onPlayerWasted",root,VeryImportantPerson_onPlayerWasted)
	addEventHandler("onPlayerRoundRespawn",root,VeryImportantPerson_onPlayerRoundRespawn)
	addEventHandler("onRoundStart",root,VeryImportantPerson_onRoundStart)
	addEventHandler("onRoundFinish",root,VeryImportantPerson_onRoundFinish)
	addEventHandler("onRoundTimesup",root,VeryImportantPerson_onRoundTimesup)
	addEventHandler("onPlayerWeaponpackGot",root,VeryImportantPerson_onPlayerWeaponpackGot)
	addEventHandler("onVehicleEnter",root,VeryImportantPerson_onVehicleEnter)
	addEventHandler("onVehicleStartEnter",root,VeryImportantPerson_onVehicleStartEnter)
	addEventHandler("onWeaponDrop",root,VeryImportantPerson_onWeaponDrop)
	addEventHandler("onWeaponPickup",root,VeryImportantPerson_onWeaponPickup)
	local interior = getTacticsData("Interior") or 0
	for _,rescue_vip in ipairs(getElementsByType("Rescue_VIP")) do
		local x,y,z = getElementPosition(rescue_vip)
		local xr,yr,zr = getElementData(rescue_vip,"rotX"),getElementData(rescue_vip,"rotY"),getElementData(rescue_vip,"rotZ")
		local vehicle = createVehicle(563,x,y,z,xr,yr,zr)
		setElementParent(vehicle,rescue_vip)
		setVehicleColor(vehicle,255,0,0,255,255,255)
		setElementFrozen(vehicle,true)
		setVehicleDamageProof(vehicle,true)
		local blip = createBlipAttachedTo(vehicle,22,1,255,255,255,255,-2)
		setElementID(blip,"BlipRescue")
		setElementParent(blip,rescue_vip)
		setElementInterior(blip,interior)
		local pilot = createPed(284,x,y,z)
		setElementParent(pilot,rescue_vip)
		warpPedIntoVehicle(pilot,vehicle)
		setElementSyncer(pilot,true)
	end
	playerVIP = nil
end
function VeryImportantPerson_onRoundStart()
	local sides = getTacticsData("Sides")
	local vipgroup = {}
	for i,player in ipairs(getPlayersInTeam(sides[1])) do
		if (getPlayerGameStatus(player) == "Play") then
			table.insert(vipgroup,player)
		end
	end
	if (#vipgroup > 0) then
		local blipVIP = getElementByID("BlipVIP")
		if (blipVIP) then destroyElement(blipVIP) end
		blipVIP = createBlip(0,0,0,0,1,0,0,0,0,-1)
		setElementID(blipVIP,"BlipVIP")
		setElementParent(blipVIP,getRoundMapDynamicRoot())
		triggerClientEvent(root,"onClientPlayerBlipUpdate",root)
		playerVIP = vipgroup[math.random(#vipgroup)]
		takeAllWeapons(playerVIP)
		giveWeapon(playerVIP,23,17*6,true)
		attachElements(blipVIP,playerVIP)
	end
	local spawnprotect = TimeToSec(getRoundModeSettings("spawnprotect"))
	for i,player in ipairs(getElementsByType("player")) do
		if (getPlayerGameStatus(player) == "Play") then
			givePlayerProperty(player,"invulnerable",true,spawnprotect*1000)
			if (player ~= playerVIP) then callClientFunction(player,"toggleWeaponManager",true) end
		end
	end
end
function VeryImportantPerson_onRoundFinish()
	for _,player in ipairs(getElementsByType("player")) do
		setElementData(player,"Kills",getElementData(player,"Kills"))
		setElementData(player,"Damage",getElementData(player,"Damage"))
		setElementData(player,"Deaths",getElementData(player,"Deaths"))
	end
end
function VeryImportantPerson_onPlayerRoundSpawn()
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
	VeryImportantPerson_onCheckRound()
end
function VeryImportantPerson_onPlayerRoundRespawn()
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
function VeryImportantPerson_onPlayerQuit(type,reason,element)
	if (source == playerVIP) then
		local sides = getTacticsData("Sides")
		local r,g,b = getTeamColor(sides[2])
		return endRound({r,g,b,'team_win_round',getTeamName(sides[2])},'vip_killed',{[sides[2]]=1})
	end
	if (getPlayerGameStatus(source) == "Play") then
		setElementData(source,"Status",nil)
		VeryImportantPerson_onCheckRound()
	end
end
function VeryImportantPerson_onCheckRound()
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
	local sides = getTacticsData("Sides")
	if (not isElement(playerVIP) or isPedDead(playerVIP)) then
		local r,g,b = getTeamColor(sides[2])
		endRound({r,g,b,'team_win_round',getTeamName(sides[2])},'vip_killed',{[sides[2]]=1})
	elseif (players[1][1] > 0 and players[2][1] == 0) then
		local r,g,b = getTeamColor(players[1][2])
		endRound({r,g,b,'team_win_round',getTeamName(players[1][2])},'team_kill_all',{[players[1][2]]=1})
	elseif (players[1][1] == 0) then
		local r,g,b = getTeamColor(sides[2])
		endRound({r,g,b,'team_win_round',getTeamName(sides[2])},'vip_killed',{[sides[2]]=1})
	end
end
function VeryImportantPerson_onRoundTimesup()
	local sides = getTacticsData("Sides")
	local r,g,b = getTeamColor(sides[2])
	endRound({r,g,b,'team_win_round',getTeamName(sides[2])},'time_over_vip_not_rescued',{[sides[2]]=1})
end
function VeryImportantPerson_onPlayerDamage(attacker,weapon,bodypart,loss)
	if (attacker and getPlayerGameStatus(source) == "Play" and attacker ~= source) then
		if (getElementType(attacker) == "vehicle") then attacker = getVehicleController(attacker) end
		if (attacker) then
			setElementData(attacker,"Damage",math.floor(getElementData(attacker,"Damage") + loss),false)
		end
	end
end
function VeryImportantPerson_onPlayerWasted(ammo,killer,weapon,bodypart,stealth)
	local loss = getElementHealth(source)
	if (killer and getPlayerGameStatus(source) == "Play" and killer ~= source) then
		if (getElementType(killer) == "vehicle") then killer = getVehicleController(killer) end
		if (killer and getElementType(killer) == "player") then
			setElementData(killer,"Kills",getElementData(killer,"Kills") + 1,false)
			setElementData(killer,"Damage",math.floor(getElementData(killer,"Damage") + loss),false)
		end
		setElementData(source,"Deaths",getElementData(source,"Deaths") + 1,false)
	end
	setElementData(source,"Status","Die")
	fadeCamera(source,false,2.0)
	VeryImportantPerson_onCheckRound()
end
function VeryImportantPerson_onPlayerWeaponpackGot(weaponpack)
	if (getRoundState() ~= "started") then return end
	if (source == playerVIP) then
		takeAllWeapons(source)
		giveWeapon(source,23,17*6,true)
	end
end
function VeryImportantPerson_onVehicleEnter(player,seat,jacked)
	local parent = getElementParent(source)
	if (player == playerVIP and parent and getElementType(parent) == "Rescue_VIP") then
		local sides = getTacticsData("Sides")
		local r,g,b = getTeamColor(sides[1])
		endRound({r,g,b,'team_win_round',getTeamName(sides[1])},'vip_rescued',{[sides[1]]=1})
	end
end
function VeryImportantPerson_onVehicleStartEnter(player,seat,jacked,door)
	local parent = getElementParent(source)
	if (player ~= playerVIP and parent and getElementType(parent) == "Rescue_VIP") then
		cancelEvent()
	end
end
function VeryImportantPerson_onWeaponDrop()
	if (source == playerVIP) then
		cancelEvent()
	end
end
function VeryImportantPerson_onWeaponPickup()
	if (source == playerVIP) then
		cancelEvent()
	end
end
addEventHandler("onMapStarting",root,VeryImportantPerson_onMapStarting)
addEventHandler("onMapStopping",root,VeryImportantPerson_onMapStopping)
addEventHandler("onResourceStart",resourceRoot,VeryImportantPerson_onResourceStart)
