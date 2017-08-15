--[[**************************************************************************
*
*  ПРОЕКТ:        TACTICS MODES
*  ВЕРСИЯ ДВИЖКА: 1.2-r18
*  РАЗРАБОТЧИКИ:  Александр Романов <lexr128@gmail.com>
*
****************************************************************************]]
local ProjectBang_vehicles = {}
local spawnCounter = {}
function ProjectBang_onResourceStart(resource)
	createTacticsMode("bang",{timelimit="10:00",player_radarblip="all|none,team,all"})
end
function ProjectBang_onMapStopping(mapinfo)
	if (mapinfo.modename ~= "bang") then return end
	removeEventHandler("onPlayerRoundSpawn",root,ProjectBang_onPlayerRoundSpawn)
	removeEventHandler("onPlayerRoundRespawn",root,ProjectBang_onPlayerRoundRespawn)
	removeEventHandler("onPlayerQuit",root,ProjectBang_onPlayerQuit)
	removeEventHandler("onPlayerWasted",root,ProjectBang_onPlayerWasted)
	removeEventHandler("onRoundStart",root,ProjectBang_onRoundStart)
	removeEventHandler("onRoundFinish",root,ProjectBang_onRoundFinish)
	removeEventHandler("onRoundTimesup",root,ProjectBang_onRoundTimesup)
	removeEventHandler("onVehicleStartExit",root,ProjectBang_onVehicleStartExit)
	for player,vehicle in pairs(ProjectBang_vehicles) do
		if (isElement(vehicle)) then destroyElement(vehicle) end
	end
	ProjectBang_vehicles = {}
	for i,player in ipairs(getElementsByType("player")) do
		setElementData(player,"Kills",getElementData(player,"Kills"))
		setElementData(player,"Damage",getElementData(player,"Damage"))
		setElementData(player,"Deaths",getElementData(player,"Deaths"))
	end
end
function ProjectBang_onMapStarting(mapinfo)
	if (mapinfo.modename ~= "bang") then return end
	if (isTimer(restartTimer)) then killTimer(restartTimer) end
	setTabboardColumns({{"Kills",0.09},{"Deaths",0.09},{"Damage",0.11}})
	setSideNames("Side 1","Side 2")
	spawnCounter = {}
	waitingTimer = "wait"
	addEventHandler("onPlayerRoundSpawn",root,ProjectBang_onPlayerRoundSpawn)
	addEventHandler("onPlayerRoundRespawn",root,ProjectBang_onPlayerRoundRespawn)
	addEventHandler("onPlayerQuit",root,ProjectBang_onPlayerQuit)
	addEventHandler("onPlayerWasted",root,ProjectBang_onPlayerWasted)
	addEventHandler("onRoundStart",root,ProjectBang_onRoundStart)
	addEventHandler("onRoundFinish",root,ProjectBang_onRoundFinish)
	addEventHandler("onRoundTimesup",root,ProjectBang_onRoundTimesup)
	addEventHandler("onVehicleStartExit",root,ProjectBang_onVehicleStartExit)
end
function ProjectBang_onPlayerVehicleChoose(player,vehicle,skill)
	if (not vehicle) then vehicle = 541 end
	setElementData(player,"ProjectBang_Vehicle",vehicle)
	setElementData(player,"ProjectBang_Skill",skill)
	local posX,posY,posZ = getElementPosition(ProjectBang_vehicles[player])
	local rotX,rotY,rotZ = getVehicleRotation(ProjectBang_vehicles[player])
	local frozen = isElementFrozen(ProjectBang_vehicles[player])
	destroyElement(ProjectBang_vehicles[player])
	ProjectBang_vehicles[player] = createVehicle(vehicle,posX,posY,posZ,rotX,rotY,rotZ)
	setVehicleDamageProof(ProjectBang_vehicles[player],true)
	warpPedIntoVehicle(player,ProjectBang_vehicles[player])
	setElementFrozen(ProjectBang_vehicles[player],frozen)
	setElementData(player,"Weapons",false)
end
function ProjectBang_onRoundStart()
	for i,player in ipairs(getElementsByType("player")) do
		if (getPlayerGameStatus(player) == "Play") then
			callClientFunction(player,"ProjectBang_onClientVehicleShow")
			setElementFrozen(ProjectBang_vehicles[player],false)
		end
	end
end
function ProjectBang_onRoundFinish()
	for _,player in ipairs(getElementsByType("player")) do
		setElementData(player,"Kills",getElementData(player,"Kills"))
		setElementData(player,"Damage",getElementData(player,"Damage"))
		setElementData(player,"Deaths",getElementData(player,"Deaths"))
	end
end
function ProjectBang_onPlayerRoundSpawn()
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
		if (isElement(ProjectBang_vehicles[source])) then destroyElement(ProjectBang_vehicles[source]) end
		local vehicle = getElementData(source,"ProjectBang_Vehicle") or 541
		ProjectBang_vehicles[source] = createVehicle(vehicle,posX,posY,posZ,0,0,rotZ)
		setVehicleDamageProof(ProjectBang_vehicles[source],true)
		warpPedIntoVehicle(source,ProjectBang_vehicles[source])
		setElementFrozen(ProjectBang_vehicles[source],true)
		giveWeapon(source,35,1,true)
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
	ProjectBang_onCheckRound()
end
function ProjectBang_onPlayerRoundRespawn()
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
	if (isElement(ProjectBang_vehicles[source])) then destroyElement(ProjectBang_vehicles[source]) end
	local vehicle = getElementData(source,"ProjectBang_Vehicle") or 541
	ProjectBang_vehicles[source] = createVehicle(vehicle,posX,posY,posZ,0,0,rotZ)
	setVehicleDamageProof(ProjectBang_vehicles[source],true)
	warpPedIntoVehicle(source,ProjectBang_vehicles[source])
	giveWeapon(source,35,1,true)
	setElementData(source,"Status","Play")
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
end
function ProjectBang_onPlayerQuit(type,reason,element)
	if (getPlayerGameStatus(source) == "Play") then
		setElementData(source,"Status",nil)
		ProjectBang_onCheckRound()
	end
end
function ProjectBang_onCheckRound()
	if (getRoundState() ~= "started" or isRoundPaused()) then return end
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
function ProjectBang_onRoundTimesup()
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
function ProjectBang_onPlayerWasted(ammo,killer,weapon,bodypart,stealth)
	takeAllWeapons(source)
	setElementData(source,"Status","Die")
	fadeCamera(source,false,2.0)
	ProjectBang_onCheckRound()
end
function ProjectBang_onVehicleStartExit(player,seat,jacked)
	cancelEvent()
end
function ProjectBang_onVehicleDamage(attacker,loss)
	local driver = getVehicleController(source)
	local health = getElementHealth(source)
	if (health - loss > 250) then
		setElementHealth(source,health - loss)
		if (driver ~= attacker) then
			setElementData(attacker,"Damage",math.floor(getElementData(attacker,"Damage") + loss),false)
		end
	else
		blowVehicle(source,true)
		if (driver ~= attacker) then
			setElementData(attacker,"Kills",getElementData(attacker,"Kills") + 1,false)
			setElementData(attacker,"Damage",math.floor(getElementData(attacker,"Damage") + health),false)
		end
		if (driver) then
			setElementData(driver,"Deaths",getElementData(driver,"Deaths") + 1,false)
			takeAllWeapons(driver)
			killPed(driver)
		end
	end
end
addEvent("ProjectBang_onVehicleDamage",true)
addEventHandler("ProjectBang_onVehicleDamage",root,ProjectBang_onVehicleDamage)
addEventHandler("onMapStarting",root,ProjectBang_onMapStarting)
addEventHandler("onMapStopping",root,ProjectBang_onMapStopping)
addEventHandler("onResourceStart",resourceRoot,ProjectBang_onResourceStart)
