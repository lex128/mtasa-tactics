spawnCounter = {}
local flagRespawn = {}
local teamFlag = {}
local playerFlag = {}
function CaptureTheFlag_onResourceStart(resource)
	createTacticsMode("ctf",{timelimit="10:00",respawn="true",respawn_lives="0",respawn_time="0:05",flag_speed="0.8",flag_idle_respawn="1:00",flag_water_respawn="true", spawnprotect="0:05"})
end
function CaptureTheFlag_onMapStopping(mapinfo)
	if (mapinfo.modename ~= "ctf") then return end
	removeEventHandler("onPlayerRoundSpawn",root,CaptureTheFlag_onPlayerRoundSpawn)
	removeEventHandler("onPlayerRoundRespawn",root,CaptureTheFlag_onPlayerRoundRespawn)
	removeEventHandler("onPlayerDamage",root,CaptureTheFlag_onPlayerDamage)
	removeEventHandler("onPlayerWasted",root,CaptureTheFlag_onPlayerWasted)
	removeEventHandler("onPlayerQuit",root,CaptureTheFlag_onPlayerQuit)
	removeEventHandler("onRoundStart",root,CaptureTheFlag_onRoundStart)
	removeEventHandler("onRoundFinish",root,CaptureTheFlag_onRoundFinish)
	removeEventHandler("onRoundTimesup",root,CaptureTheFlag_onRoundTimesup)
	removeEventHandler("onWeaponDrop",root,CaptureTheFlag_onWeaponDrop)
	removeEventHandler("onColShapeHit",root,CaptureTheFlag_onColShapeHit)
	removeEventHandler("onFlagDrop",root,CaptureTheFlag_onFlagDrop)
	removeEventHandler("onFlagPickup",root,CaptureTheFlag_onFlagPickup)
	for i,player in ipairs(getElementsByType("player")) do
		setPlayerProperty(player,"invulnerable",nil)
		setPlayerProperty(player,"movespeed",nil)
		setElementData(player,"Kills",getElementData(player,"Kills"))
		setElementData(player,"Damage",getElementData(player,"Damage"))
		setElementData(player,"Deaths",getElementData(player,"Deaths"))
	end
	for flag,timer in pairs(flagRespawn) do
		if (isTimer(timer)) then
			killTimer(timer)
			flagRespawn[flag] = nil
		end
	end
end
function CaptureTheFlag_onMapStarting(mapinfo)
	if (mapinfo.modename ~= "ctf") then return end
	if (isTimer(restartTimer)) then killTimer(restartTimer) end
	setTabboardColumns({{"Capture",0.07},{"Kills",0.07},{"Deaths",0.07},{"Damage",0.08}})
	setSideNames("Side 1","Side 2")
	spawnCounter = {}
	waitingTimer = "wait"
	addEventHandler("onPlayerRoundSpawn",root,CaptureTheFlag_onPlayerRoundSpawn)
	addEventHandler("onPlayerRoundRespawn",root,CaptureTheFlag_onPlayerRoundRespawn)
	addEventHandler("onPlayerDamage",root,CaptureTheFlag_onPlayerDamage)
	addEventHandler("onPlayerWasted",root,CaptureTheFlag_onPlayerWasted)
	addEventHandler("onPlayerQuit",root,CaptureTheFlag_onPlayerQuit)
	addEventHandler("onRoundStart",root,CaptureTheFlag_onRoundStart)
	addEventHandler("onRoundFinish",root,CaptureTheFlag_onRoundFinish)
	addEventHandler("onRoundTimesup",root,CaptureTheFlag_onRoundTimesup)
	addEventHandler("onWeaponDrop",root,CaptureTheFlag_onWeaponDrop)
	addEventHandler("onColShapeHit",root,CaptureTheFlag_onColShapeHit)
	addEventHandler("onFlagDrop",root,CaptureTheFlag_onFlagDrop)
	addEventHandler("onFlagPickup",root,CaptureTheFlag_onFlagPickup)
	for i,team in ipairs(getElementsByType("team")) do
		if (i > 1) then
			setElementData(team,"Capture",0)
		end
	end
	teamFlag = {}
	playerFlag = {}
	local interior = getTacticsData("Interior")
	local sides = getTacticsData("Sides")
	for i,side in ipairs(sides) do
		setElementData(side,"IsStolen",nil)
		local r,g,b = getTeamColor(side)
		for i2,flagpoint in ipairs(getElementsByType("Flag"..i)) do
			local x,y,z = tonumber(getElementData(flagpoint,"posX")),tonumber(getElementData(flagpoint,"posY")),tonumber(getElementData(flagpoint,"posZ"))
			local marker = createMarker(x,y,z + 1,"arrow",1,r,g,b,128)
			setElementInterior(marker,interior)
			setElementData(marker,"Team",side)
			setElementParent(marker,flagpoint)
			teamFlag[side] = marker
			local blip = createBlipAttachedTo(marker,0,2,0,0,0,0,-1)
			setElementInterior(blip,interior)
			setElementData(marker,"Blip",blip)
			setElementParent(blip,flagpoint)
			local base = createMarker(x,y,z + 1,"checkpoint",1,r,g,b,16)
			setElementInterior(base,interior)
			setElementData(marker,"Base",base)
			setElementParent(base,flagpoint)
			local colshape = createColTube(x,y,z,3,4)
			setElementParent(colshape,marker)
			setElementData(marker,"Colshape",colshape)
		end
	end
end
function CaptureTheFlag_onRoundStart()
	local spawnprotect = TimeToSec(getRoundModeSettings("spawnprotect"))
	local teamsides = getTacticsData("Teamsides")
	for i,player in ipairs(getElementsByType("player")) do
		if (getPlayerGameStatus(player) == "Play" or getPlayerGameStatus(player) == "Loading") then
			givePlayerProperty(player,"invulnerable",true,spawnprotect*1000)
			local team = getPlayerTeam(player)
			if (teamsides[team]) then
				callClientFunction(player,"onClientWeaponChoose")
			end
		end
	end
end
function CaptureTheFlag_onRoundFinish()
	for _,player in ipairs(getElementsByType("player")) do
		setElementData(player,"Kills",getElementData(player,"Kills"))
		setElementData(player,"Damage",getElementData(player,"Damage"))
		setElementData(player,"Deaths",getElementData(player,"Deaths"))
	end
end
function CaptureTheFlag_onPlayerRoundSpawn()
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
end
function CaptureTheFlag_onPlayerRoundRespawn()
	local team = getPlayerTeam(source)
	local model = getElementModel(source) or getElementData(team,"Skins")[1]
	local teamsides = getTacticsData("Teamsides")
	local spawnpoints = getElementsByType("Team"..tostring(teamsides[team]))
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
function CaptureTheFlag_onRoundTimesup()
	local captures = {}
	for i,team in ipairs(getElementsByType("team")) do
		if (i > 1) then
			table.insert(captures,{team,getElementData(team,"Capture")})
		end
	end
	table.sort(captures,function(a,b) return a[2] > b[2] end)
	local reason = ""
	for i,data in ipairs(captures) do
		reason = string.format("%s\n%s - %i",reason,getTeamName(data[1]),data[2])
	end
	if (captures[1][2] > captures[2][2] and captures[1][2] ~= 0) then
		local r,g,b = getTeamColor(captures[1][1])
		endRound({r,g,b,'team_win_round',getTeamName(captures[1][1])},{'time_over',reason},{[captures[1][1]]=1})
	else
		endRound('draw_round',{'time_over',reason})
	end
end
function CaptureTheFlag_onColShapeHit(player,dim)
	if (getElementType(player) == "vehicle") then player = getVehicleOccupant(player) end
	if (not dim or getElementType(player) ~= "player" or getPlayerGameStatus(player) ~= "Play") then return end
	local marker = getElementParent(source)
	if (not marker or isElementAttached(marker) or getElementType(marker) ~= "marker") then return end
	local pteam = getPlayerTeam(player)
	local team = getElementData(marker,"Team")
	local base = getElementData(marker,"Base")
	if (team == pteam) then
		local parent = getElementParent(marker)
		local xbase,ybase,zbase = getElementPosition(parent)
		if (not isElementWithinMarker(marker,base)) then
			local x,y,z = getElementPosition(marker)
			CaptureTheFlag_RespawnFlag(marker)
			triggerClientEvent(root,"onClientFlagReturn",marker,player,x,y,z)
		else
			local flag = playerFlag[player]
			if (flag and getElementAttachedTo(flag) == player) then
				setPlayerProperty(player,"movespeed",nil)
				local captures = getElementData(pteam,"Capture") + 1
				setElementData(pteam,"Capture",captures)
				local x,y,z = getElementPosition(flag)
				CaptureTheFlag_RespawnFlag(flag)
				triggerClientEvent(root,"onClientFlagCapture",flag,player,x,y,z)
				outputRoundLog(getPlayerName(player).." captured the flag ("..captures..")")
			end
		end
	else
		local isStolen = isElementWithinMarker(marker,base)
		if (isStolen) then setElementData(team,"IsStolen",true) end
		playerFlag[player] = marker
		attachElements(marker,player,0,0,2.5)
		destroyElement(getElementData(marker,"Colshape"))
		setPlayerProperty(player,"movespeed",tonumber(getRoundModeSettings("flag_speed")) or 0.8)
		triggerEvent("onFlagPickup",marker,player,isStolen)
		triggerClientEvent(root,"onClientFlagPickup",marker,player,isStolen)
	end
end
function CaptureTheFlag_RespawnFlag(marker)
	local team = getElementData(marker,"Team")
	setElementData(team,"IsStolen",nil)
	local parent = getElementParent(marker)
	local x,y,z = getElementPosition(parent)
	local player = getElementAttachedTo(marker)
	if (player) then playerFlag[player] = nil end
	detachElements(marker)
	setElementPosition(marker,x,y,z + 1)
	setElementRotation(marker,0,0,0)
	if (isTimer(flagRespawn[marker])) then
		killTimer(flagRespawn[marker])
		flagRespawn[marker] = nil
	end
	local colshape = getElementData(marker,"Colshape")
	if (isElement(colshape)) then
		setElementPosition(colshape,x,y,z)
	else
		colshape = createColTube(x,y,z,3,4)
		setElementParent(colshape,marker)
		setElementData(marker,"Colshape",colshape)
	end
end
function CaptureTheFlag_onPlayerDamage(attacker,weapon,bodypart,loss)
	if (attacker and getPlayerGameStatus(source) == "Play" and attacker ~= source) then
		if (getElementType(attacker) == "vehicle") then attacker = getVehicleController(attacker) end
		if (attacker) then
			setElementData(attacker,"Damage",math.floor(getElementData(attacker,"Damage") + loss),false)
		end
	end
end
function CaptureTheFlag_onPlayerWasted(ammo,killer,weapon,bodypart,stealth)
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
	fadeCamera(source,false,5.0)
	local marker = playerFlag[source]
	if (marker and getElementAttachedTo(marker) == source) then
		playerFlag[source] = nil
		local x,y,z = getElementPosition(source)
		detachElements(marker)
		setElementPosition(marker,x,y,z + 1)
		setElementRotation(marker,0,0,0)
		local colshape = getElementData(marker,"Colshape")
		if (isElement(colshape)) then
			setElementPosition(colshape,x,y,z)
		else
			colshape = createColTube(x,y,z,3,4)
			setElementParent(colshape,marker)
			setElementData(marker,"Colshape",colshape)
		end
		setPlayerProperty(source,"movespeed",nil)
		triggerEvent("onFlagDrop",marker,source)
		triggerClientEvent(root,"onClientFlagDrop",marker,source)
	end
end
function CaptureTheFlag_onPlayerQuit()
	local marker = playerFlag[source]
	if (marker and getElementAttachedTo(marker) == source) then
		playerFlag[source] = nil
		local x,y,z = getElementPosition(source)
		detachElements(marker)
		setElementPosition(marker,x,y,z + 1)
		setElementRotation(marker,0,0,0)
		local colshape = getElementData(marker,"Colshape")
		if (isElement(colshape)) then
			setElementPosition(colshape,x,y,z)
		else
			colshape = createColTube(x,y,z,3,4)
			setElementParent(colshape,marker)
			setElementData(marker,"Colshape",colshape)
		end
		setPlayerProperty(source,"movespeed",nil)
		triggerEvent("onFlagDrop",marker,source)
		triggerClientEvent(root,"onClientFlagDrop",marker,source)
	end
end
function CaptureTheFlag_onWeaponDrop()
	cancelEvent()
	local marker = playerFlag[source]
	if (marker and getElementAttachedTo(marker) == source) then
		playerFlag[source] = nil
		local x,y,z = getElementPosition(source)
		detachElements(marker)
		setElementPosition(marker,x,y,z + 1)
		setElementRotation(marker,0,0,0)
		local colshape = getElementData(marker,"Colshape")
		if (isElement(colshape)) then
			setElementPosition(colshape,x,y,z)
		else
			colshape = createColTube(x,y,z,3,4)
			setElementParent(colshape,marker)
			setElementData(marker,"Colshape",colshape)
		end
		setPlayerProperty(source,"movespeed",nil)
		triggerEvent("onFlagDrop",marker,source)
		triggerClientEvent(root,"onClientFlagDrop",marker,source)
	end
end
function CaptureTheFlag_onFlagDrop(player)
	if (getRoundModeSettings("flag_water_respawn") == "true" and ({getElementPosition(source)})[3] <= 1.5) then
		local x,y,z = getElementPosition(source)
		CaptureTheFlag_RespawnFlag(source)
		triggerClientEvent(root,"onClientFlagReturn",source,getElementData(source,"Team"),x,y,z)
	else
		local idlerespawn = math.floor(TimeToSec(getRoundModeSettings("flag_idle_respawn"))*1000)
		if (idlerespawn > 50) then
			flagRespawn[source] = setTimer(function(marker)
				local x,y,z = getElementPosition(marker)
				CaptureTheFlag_RespawnFlag(marker)
				triggerClientEvent(root,"onClientFlagReturn",marker,getElementData(marker,"Team"),x,y,z)
			end,math.max(50,idlerespawn),1,source)
		end
	end
end
function CaptureTheFlag_onFlagPickup()
	if (isTimer(flagRespawn[source])) then
		killTimer(flagRespawn[source])
		flagRespawn[source] = nil
	end
end
addEvent("onFlagDrop")
addEvent("onFlagPickup")
addEventHandler("onMapStarting",root,CaptureTheFlag_onMapStarting)
addEventHandler("onMapStopping",root,CaptureTheFlag_onMapStopping)
addEventHandler("onResourceStart",resourceRoot,CaptureTheFlag_onResourceStart)
