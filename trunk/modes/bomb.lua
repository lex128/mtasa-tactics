spawnCounter = {}
teamPlanted = false
function BombMatch_onResourceStart(resource)
	createTacticsMode("bomb",{timelimit="15:00",bombtimer="1:50",planting="0:05",defusing="0:10"})
end
function BombMatch_onMapStopping(mapinfo)
	if (mapinfo.modename ~= "bomb") then return end
	removeEventHandler("onPlayerRoundSpawn",root,BombMatch_onPlayerRoundSpawn)
	removeEventHandler("onPlayerQuit",root,BombMatch_onPlayerQuit)
	removeEventHandler("onPlayerDamage",root,BombMatch_onPlayerDamage)
	removeEventHandler("onPlayerWasted",root,BombMatch_onPlayerWasted)
	removeEventHandler("onPlayerRoundRespawn",root,BombMatch_onPlayerRoundRespawn)
	removeEventHandler("onRoundStart",root,BombMatch_onRoundStart)
	removeEventHandler("onRoundFinish",root,BombMatch_onRoundFinish)
	removeEventHandler("onRoundTimesup",root,BombMatch_onRoundTimesup)
	removeEventHandler("onPlayerBombPlanted",root,BombMatch_onPlayerBombPlanted)
	removeEventHandler("onPlayerBombDefuse",root,BombMatch_onPlayerBombDefuse)
	removeEventHandler("onPlayerWeaponpackGot",root,BombMatch_onPlayerWeaponpackGot)
	removeEventHandler("onWeaponDrop",root,BombMatch_onWeaponDrop)
	removeEventHandler("onWeaponPickup",root,BombMatch_onWeaponPickup)
	removeEventHandler("onElementDataChange",root,BombMatch_onElementDataChange)
	removeEventHandler("onPlayerRestored",root,BombMatch_onPlayerRestored)
	for i,player in ipairs(getElementsByType("player")) do
		setPlayerProperty(player,"invulnerable",false)
		setElementData(player,"Kills",getElementData(player,"Kills"))
		setElementData(player,"Damage",getElementData(player,"Damage"))
		setElementData(player,"Deaths",getElementData(player,"Deaths"))
	end
end
function BombMatch_onMapStarting(mapinfo)
	if (mapinfo.modename ~= "bomb") then return end
	if (isTimer(restartTimer)) then killTimer(restartTimer) end
	setTabboardColumns({{"Kills",0.09},{"Deaths",0.09},{"Damage",0.11}})
	setSideNames("Bomber","Defend")
	spawnCounter = {}
	waitingTimer = "wait"
	addEventHandler("onPlayerRoundSpawn",root,BombMatch_onPlayerRoundSpawn)
	addEventHandler("onPlayerQuit",root,BombMatch_onPlayerQuit)
	addEventHandler("onPlayerDamage",root,BombMatch_onPlayerDamage)
	addEventHandler("onPlayerWasted",root,BombMatch_onPlayerWasted)
	addEventHandler("onPlayerRoundRespawn",root,BombMatch_onPlayerRoundRespawn)
	addEventHandler("onRoundStart",root,BombMatch_onRoundStart)
	addEventHandler("onRoundFinish",root,BombMatch_onRoundFinish)
	addEventHandler("onRoundTimesup",root,BombMatch_onRoundTimesup)
	addEventHandler("onPlayerBombPlanted",root,BombMatch_onPlayerBombPlanted)
	addEventHandler("onPlayerBombDefuse",root,BombMatch_onPlayerBombDefuse)
	addEventHandler("onPlayerWeaponpackGot",root,BombMatch_onPlayerWeaponpackGot)
	addEventHandler("onWeaponDrop",root,BombMatch_onWeaponDrop)
	addEventHandler("onWeaponPickup",root,BombMatch_onWeaponPickup)
	addEventHandler("onElementDataChange",root,BombMatch_onElementDataChange)
	addEventHandler("onPlayerRestored",root,BombMatch_onPlayerRestored)
	local interior = getTacticsData("Interior") or 0
	for i,bombpoint in ipairs(getElementsByType("Bomb_Place")) do
		local x,y,z = getElementPosition(bombpoint)
		local size = tonumber(getElementData(bombpoint,"size")) or 20
		local colsphere = createColSphere(x,y,z,size)
		setElementInterior(colsphere,interior)
		setElementParent(colsphere,bombpoint)
		setElementID(colsphere,"Bomb_Place")
		local icon = 31
		if (i % 2 == 1) then icon = 32 end
		local blip = createBlipAttachedTo(colsphere,icon,1,255,255,255,255,-2)
		setElementInterior(blip,interior)
		setElementParent(blip,bombpoint)
	end
end
function BombMatch_onRoundStart()
	for i,player in ipairs(getElementsByType("player")) do
		if (getPlayerGameStatus(player) == "Play") then
			givePlayerProperty(player,"invulnerable",true,5000)
			callClientFunction(player,"onClientWeaponChoose")
		end
	end
	local sides = getTacticsData("Sides")
	local bombers = {}
	for i,player in ipairs(getPlayersInTeam(sides[1])) do
		if (getPlayerGameStatus(player) == "Play") then
			table.insert(bombers,player)
		end
	end
	if (#bombers > 0) then
		local bombblip = getElementByID("BombBlip")
		if (bombblip) then destroyElement(bombblip) end
		bombblip = createBlip(0,0,0,0,1,0,0,0,0,-1)
		setElementID(bombblip,"BombBlip")
		setElementParent(bombblip,getRoundMapDynamicRoot())
		triggerClientEvent(root,"onClientPlayerBlipUpdate",root)
		local bomber = bombers[math.random(#bombers)]
		giveWeapon(bomber,11,1,true)
		attachElements(bombblip,bomber)
	end
end
function BombMatch_onRoundFinish()
	for _,player in ipairs(getElementsByType("player")) do
		setElementData(player,"Kills",getElementData(player,"Kills"))
		setElementData(player,"Damage",getElementData(player,"Damage"))
		setElementData(player,"Deaths",getElementData(player,"Deaths"))
	end
end
function BombMatch_onPlayerRoundSpawn()
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
		fadeCamera(source,true,2.0)
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
	BombMatch_onCheckRound()
end
function BombMatch_onPlayerRoundRespawn ()
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
	fadeCamera(source,true,2.0)
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
function BombMatch_onPlayerQuit(type,reason,element)
	if (getPedWeapon(source,10) == 11) then dropWeapon(source,10) end
	if (getPlayerGameStatus(source) == "Play") then
		setElementData(source,"Status",nil)
		BombMatch_onCheckRound()
	end
end
function BombMatch_onCheckRound()
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
	if (players[1][1] > 0 and players[2][1] == 0) then
		for i,side in ipairs(sides) do
			if (players[1][2] == side) then
				if (i % 2 == 1 or not getElementByID("BombActive")) then
					local r,g,b = getTeamColor(players[1][2])
					return endRound({r,g,b,'team_win_round',getTeamName(players[1][2])},'team_kill_all',{[players[1][2]]=1})
				end
			end
		end
	elseif (players[1][1] == 0) then
		if (not getElementByID("BombActive")) then
			local r,g,b = getTeamColor(sides[2])
			return endRound({r,g,b,'team_win_round',getTeamName(sides[2])},'nobody_alive_bomb_not_planted',{[sides[2]]=1})
		else
			local r,g,b = getTeamColor(teamPlanted)
			return endRound({r,g,b,'team_win_round',getTeamName(teamPlanted)},'nobody_alive_bomb_planted',{[teamPlanted]=1})
		end
	end
end
function BombMatch_onPlayerBombPlanted()
	if (getElementByID("BombActive") or isRoundPaused() or getPedWeapon(source) ~= 11) then return end
	takeWeapon(source,11)
	teamPlanted = getPlayerTeam(source)
	local x,y,z = getElementPosition(source)
	local element = createObject(2221,x,y,z-0.9,-90,0,0)
	setElementID(element,"Bomb")
	setElementInterior(element,getElementInterior(source))
	setElementDimension(element,getElementDimension(source))
	setElementParent(element,getRoundMapDynamicRoot())
	local active = createMarker(x,y,z-0.9,"corona",0.5,255,0,0,128)
	setElementID(active,"BombActive")
	setElementPosition(active,x,y,z-0.9)
	setElementInterior(active,getElementInterior(source))
	setElementDimension(active,getElementDimension(source))
	setElementParent(active,element)
	local colsphere = createColSphere(x,y,z,2)
	setElementID(colsphere,"BombColshape")
	setElementParent(colsphere,element)
	detachElements(getElementByID("BombBlip"),source)
--	local blip = createBlipAttachedTo(colsphere,0,1,0,0,0,0,-1)
--	setElementID(blip,"BombBlip")
--	setElementParent(blip,element)
	killTimer(overtimeTimer)
	local bombtimer = TimeToSec(getTacticsData("modes","bomb","bombtimer") or "1:30")
	overtimeTimer = setTimer(triggerEvent,bombtimer*1000,1,"onRoundTimesup",root)
	setTacticsData(getTickCount() + bombtimer*1000,"timeleft")
	callClientFunction(root,"playVoice","audio/bomb_planted.mp3")
	triggerClientEvent(root,"onClientPlayerBlipUpdate",root)
end
function BombMatch_onPlayerBombDefuse()
	if (not getElementByID("BombActive") or isRoundPaused()) then return end
	destroyElement(getElementByID("BombActive"))
	local team = getPlayerTeam(source)
	local r,g,b = getTeamColor(team)
	endRound({r,g,b,'team_win_round',getTeamName(team)},{'player_defuse_bomb',getPlayerName(source)},{[team]=1})
end
function BombMatch_onRoundTimesup()
	if (not getElementByID("BombActive")) then
		local sides = getTacticsData("Sides")
		local r,g,b = getTeamColor(sides[2])
		endRound({r,g,b,'team_win_round',getTeamName(sides[2])},'time_over_bomb_not_planted',{[sides[2]]=1})
	else
		local bomb = getElementByID("Bomb")
		local x,y,z = getElementPosition(bomb)
		destroyElement(bomb)
		local r,g,b = getTeamColor(teamPlanted)
		endRound({r,g,b,'team_win_round',getTeamName(teamPlanted)},'time_over_bomb_explosed',{[teamPlanted]=1})
		callClientFunction(root,"BombMatch_createBombExplosion",x,y,z)
	end
end
function BombMatch_onPlayerDamage(attacker,weapon,bodypart,loss)
	if (attacker and getPlayerGameStatus(source) == "Play" and attacker ~= source) then
		if (getElementType(attacker) == "vehicle") then attacker = getVehicleController(attacker) end
		if (attacker) then
			setElementData(attacker,"Damage",math.floor(getElementData(attacker,"Damage") + loss),false)
		end
	end
end
function BombMatch_onPlayerWasted(ammo,killer,weapon,bodypart,stealth)
	if (getPedWeapon(source,10) == 11 and getPedWeaponSlot(source) ~= 10) then dropWeapon(source,10) end
	local loss = getElementHealth(source)
	if (isTimer(wastedTimer[source])) then killTimer(wastedTimer[source]) end
	wastedTimer[source] = setTimer(triggerEvent,2000,1,"onPlayerRoundSpawn",source)
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
	BombMatch_onCheckRound()
end
function BombMatch_onPlayerWeaponpackGot(weaponpack)
	if (getRoundState() ~= "started") then return end
	local bombblip = getElementByID("BombBlip")
	if (bombblip and getElementAttachedTo(bombblip) == source) then
		giveWeapon(source,11,1,true)
	elseif (not bombblip and getPlayerTeam(source) and getTacticsData("Teamsides")[getPlayerTeam(source)]%2 == 1) then
		bombblip = createBlip(0,0,0,0,1,0,0,0,0,-1)
		setElementID(bombblip,"BombBlip")
		setElementParent(bombblip,getRoundMapDynamicRoot())
		triggerClientEvent(root,"onClientPlayerBlipUpdate",root)
		giveWeapon(source,11,1,true)
		attachElements(bombblip,source)
	end
end
function BombMatch_onWeaponDrop(pickup)
	if (getPickupWeapon(pickup) == 11) then
		setPickupType(pickup,3,2221)
		detachElements(getElementByID("BombBlip"),source)
	end
end
function BombMatch_onWeaponPickup(pickup)
	if (getPickupWeapon(pickup) == 11) then
		local team = getPlayerTeam(source)
		local teamsides = getTacticsData("Teamsides")
		if (teamsides[team]%2 == 0) then
			cancelEvent()
		else
			attachElements(getElementByID("BombBlip"),source)
		end
	end
end
function BombMatch_onElementDataChange(data,old)
	if (data == "Status" and old == "Play" and getElementData(source,data) ~= "Die") then
		if (getPedWeapon(source,10) == 11) then dropWeapon(source,10) end
	end
end
function BombMatch_onPlayerRestored(row)
	if (getPedWeapon(source,10) == 11 and getElementByID("BombBlip")) then
		takeWeapon(source,11)
	end
end
addEvent("onPlayerBombPlanted",true)
addEvent("onPlayerBombDefuse",true)
addEventHandler("onMapStarting",root,BombMatch_onMapStarting)
addEventHandler("onMapStopping",root,BombMatch_onMapStopping)
addEventHandler("onResourceStart",resourceRoot,BombMatch_onResourceStart)
