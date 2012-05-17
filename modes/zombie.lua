infectionTimer = false
function ZombieMod_onResourceStart(resource)
	createTacticsMode("zombie",{timelimit="10:00",zombie_speed="1.2",zombie_regenerate="5",night="true",spawnprotect="0:15"})
end
function ZombieMod_onResourceStop(resource)
	for i,player in ipairs(getElementsByType("player")) do
		setPedStat(player,24,569)
		setPedHeadless(player,false)
	end
end
function ZombieMod_onMapStopping(mapinfo)
	if (mapinfo.modename ~= "zombie") then return end
	if (isTimer(infectionTimer)) then killTimer(infectionTimer) end
	removeEventHandler("onPlayerRoundSpawn",root,ZombieMod_onPlayerRoundSpawn)
	removeEventHandler("onPlayerRoundRespawn",root,ZombieMod_onPlayerRoundRespawn)
	removeEventHandler("onPlayerQuit",root,ZombieMod_onPlayerQuit)
	removeEventHandler("onPlayerWasted",root,ZombieMod_onPlayerWasted)
	removeEventHandler("onRoundStart",root,ZombieMod_onRoundStart)
	removeEventHandler("onRoundTimesup",root,ZombieMod_onRoundTimesup)
	removeEventHandler("onZombieInfected",root,ZombieMod_onZombieInfected)
	removeEventHandler("onWeaponPickup",root,ZombieMod_onWeaponPickup)
	for i,player in ipairs(getElementsByType("player")) do
		setPlayerProperty(player,"invulnerable",nil)
		setPlayerProperty(player,"movespeed",nil)
		setPlayerProperty(player,"regenerable",nil)
		local model = getElementData(getPlayerTeam(player),"Skins")[1]
		setElementModel(player,model)
		setPedStat(player,24,569)
		setPedHeadless(player,false)
	end
	if (getTacticsData("settings","autobalance") ~= "true") then balanceTeams() end
--	if (getTacticsData("mode","zombie","night") ~= "true") then balanceTeams() end
end
function ZombieMod_onMapStarting(mapinfo)
	if (mapinfo.modename ~= "zombie") then return end
	if (isTimer(restartTimer)) then killTimer(restartTimer) end
	if (isTimer(infectionTimer)) then killTimer(infectionTimer) end
	setTabboardColumns()
	setSideNames("Survived","Zombie")
	spawnCounter = {}
	waitingTimer = "wait"
	addEventHandler("onPlayerRoundSpawn",root,ZombieMod_onPlayerRoundSpawn)
	addEventHandler("onPlayerRoundRespawn",root,ZombieMod_onPlayerRoundRespawn)
	addEventHandler("onPlayerQuit",root,ZombieMod_onPlayerQuit)
	addEventHandler("onPlayerWasted",root,ZombieMod_onPlayerWasted)
	addEventHandler("onRoundStart",root,ZombieMod_onRoundStart)
	addEventHandler("onRoundTimesup",root,ZombieMod_onRoundTimesup)
	addEventHandler("onZombieInfected",root,ZombieMod_onZombieInfected)
	addEventHandler("onWeaponPickup",root,ZombieMod_onWeaponPickup)
	local sides = getTacticsData("Sides")
	for i,player in ipairs(getElementsByType("player")) do
		setPlayerTeam(player,sides[1])
	end
end
function ZombieMod_onRoundStart()
	local spawnprotect = TimeToSec(getRoundModeSettings("spawnprotect"))
	for i,player in ipairs(getElementsByType("player")) do
		if (getPlayerGameStatus(player,"Status") == "Play" or getElementData(player) == "Loading") then
			givePlayerProperty(player,"invulnerable",true,spawnprotect*1000)
			callClientFunction(player,"onClientWeaponChoose")
		end
	end
	if (isTimer(infectionTimer)) then killTimer(infectionTimer) end
	infectionTimer = setTimer(randomInfected,1000,0)
end
function randomInfected()
	local humans = {}
	for i,player in ipairs(getElementsByType("player")) do
		if (getPlayerGameStatus(player) == "Play" and not getPlayerProperty(player,"invulnerable")) then
			table.insert(humans,player)
		end
	end
	if (#humans == 0) then return false end
	local center = getElementsByType("Central_Marker")[1]
	local xc,yc,zc = getElementPosition(center)
	if (#humans > 1) then
		table.sort(humans,function(a,b)
			local xa,ya,za = getElementPosition(a)
			local xb,yb,zb = getElementPosition(b)
			return getDistanceBetweenPoints3D(xc,yc,zc,xa,ya,za) < getDistanceBetweenPoints3D(xc,yc,zc,xb,yb,zb)
		end)
	end
	triggerEvent("onZombieInfected",humans[1],false)
	return true
end
function ZombieMod_onZombieInfected(zombie)
	if (isTimer(infectionTimer)) then killTimer(infectionTimer) end
	setPlayerTeam(source,getTacticsData("Sides")[2])
	setElementModel(source,78)
	setPedStat(source,24,1000)
	setElementHealth(source,200)
	setPedHeadless(source,true)
	setElementData(source,"Weapons",false)
	takeAllWeapons(source)
	ZombieMod_onCheckRound()
	if (zombie) then
		outputRoundLog(getPlayerName(zombie).." infected "..getPlayerName(source))
	else
		outputRoundLog(getPlayerName(source).." infected")
	end
	triggerClientEvent(root,"onClientZombieInfected",source)
end
function ZombieMod_onPlayerRoundSpawn()
	local team = getPlayerTeam(source)
	local model = getElementModel(source) or getElementData(team,"Skins")[1]
	if (getRoundState() ~= "started" and not isTimer(winTimer)) then
		local sides = getTacticsData("Sides")
		local element = getElementsByType("spawnpoint")[math.random(#getElementsByType("spawnpoint"))]
		local posX = getElementData(element,"posX")
		local posY = getElementData(element,"posY")
		local posZ = getElementData(element,"posZ")
		local rotZ = getElementData(element,"rotZ")
		local interior = getTacticsData("Interior")
		spawnPlayer(source,posX,posY,posZ,rotZ,model,interior,0,sides[1])
		setElementFrozen(source,true)
		toggleAllControls(source,false,true,false)
		toggleControl(source,"next_weapon",true)
		toggleControl(source,"previous_weapon",true)
		setElementData(source,"Weapons",true)
		setPlayerProperty(source,"movespeed",nil)
		setPlayerProperty(source,"regenerable",nil)
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
	ZombieMod_onCheckRound()
end
function ZombieMod_onPlayerRoundRespawn()
	local sides = getTacticsData("Sides")
	local element = getElementsByType("spawnpoint")[math.random(#getElementsByType("spawnpoint"))]
	local posX = getElementData(element,"posX")
	local posY = getElementData(element,"posY")
	local posZ = getElementData(element,"posZ")
	local rotZ = getElementData(element,"rotZ")
	local interior = getTacticsData("Interior")
	setCameraTarget(source,source)
	spawnPlayer(source,posX,posY,posZ,rotZ,78,interior,0,sides[2])
	setElementFrozen(source,false)
	toggleAllControls(source,true)
	setElementData(source,"Status","Play")
	setElementData(source,"Weapons",false)
	callClientFunction(source,"setCameraInterior",interior)
	triggerEvent("onZombieInfected",source,false)
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
function ZombieMod_onPlayerQuit(type,reason,element)
	if (getPlayerGameStatus(source) == "Play") then
		setElementData(source,"Status",nil)
		ZombieMod_onCheckRound()
	end
end
function ZombieMod_onCheckRound()
	if (not isTimer(infectionTimer) and not isTimer(winTimer) and getRoundState() == "started") then
		infectionTimer = setTimer(function()
			local sides = getTacticsData("Sides")
			if (countPlayersInTeam(sides[2]) == 0) then
				randomInfected()
			end
		end,50,1)
	end
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
function ZombieMod_onRoundTimesup()
	local sides = getTacticsData("Sides")
	local r,g,b = getTeamColor(sides[1])
	endRound({r,g,b,'team_win_round',getTeamName(sides[1])},'time_over_humans_alive',{[sides[1]]=1})
end
function ZombieMod_onPlayerWasted(ammo,killer,killerweapon,bodypart,stealth)
	local loss = getElementHealth(source)
	setElementData(source,"Status","Die")
	fadeCamera(source,false,2.0)
	ZombieMod_onCheckRound()
end
function ZombieMod_onWeaponPickup(pickup)
	local sides = getTacticsData("Sides")
	if (getPlayerTeam(source) == sides[2]) then
		cancelEvent()
	end
end
addEvent("onZombieInfected",true)
addEventHandler("onMapStarting",root,ZombieMod_onMapStarting)
addEventHandler("onMapStopping",root,ZombieMod_onMapStopping)
addEventHandler("onResourceStart",resourceRoot,ZombieMod_onResourceStart)
addEventHandler("onResourceStop",resourceRoot,ZombieMod_onResourceStop)
