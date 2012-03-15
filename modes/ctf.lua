spawnCounter = {}
function CaptureTheFlag_onResourceStart(resource)
	createTacticsMode("ctf",{timelimit="10:00",respawn="true",respawn_lives="0",respawn_time="0:05",flag_speed="0.8"})
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
	for i,player in ipairs(getElementsByType("player")) do
		setPlayerProperty(player,"invulnerable",nil)
		setPlayerProperty(player,"movespeed",nil)
		setElementData(player,"Kills",getElementData(player,"Kills"))
		setElementData(player,"Damage",getElementData(player,"Damage"))
		setElementData(player,"Deaths",getElementData(player,"Deaths"))
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
	for i,team in ipairs(getElementsByType("team")) do
		if (i > 1) then
			setElementData(team,"Capture",0)
		end
	end
	local interior = getTacticsData("Interior")
	local sides = getTacticsData("Sides")
	for i,side in ipairs(sides) do
		setElementData(side,"FlagStatus",true)
		local r,g,b = getTeamColor(side)
		for i2,flagpoint in ipairs(getElementsByType("Flag"..i)) do
			local x,y,z = tonumber(getElementData(flagpoint,"posX")),tonumber(getElementData(flagpoint,"posY")),tonumber(getElementData(flagpoint,"posZ"))
			local marker = createMarker(x,y,z + 1,"arrow",1,r,g,b,128)
			setElementInterior(marker,interior)
			setElementData(marker,"Team",side)
			setElementParent(marker,flagpoint)
			local blip = createBlipAttachedTo(marker,0,2,0,0,0,0,-1)
			setElementInterior(blip,interior)
			setElementData(marker,"Blip",blip)
			setElementParent(blip,flagpoint)
			local base = createMarker(x,y,z + 1,"checkpoint",1,r,g,b,16)
			setElementInterior(base,interior)
			setElementData(marker,"Base",base)
			setElementParent(base,flagpoint)
		end
	end
end
function CaptureTheFlag_onRoundStart()
	local teamsides = getTacticsData("Teamsides")
	for i,player in ipairs(getElementsByType("player")) do
		if (getPlayerGameStatus(player,"Status") == "Play" or getElementData(player) == "Loading") then
			givePlayerProperty(player,"invulnerable",true,5000)
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
		setElementFrozen(source,true)
	end
end
function CaptureTheFlag_onPlayerRoundRespawn()
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
function CaptureTheFlag_onElementFlagHit(marker,player)
	local source = getElementParent(source)
	if (not marker or isElementAttached(marker) or getElementType(player) ~= "player" or getPlayerGameStatus(player) ~= "Play") then return end
	local myteam = getPlayerTeam(player)
	local team = getElementData(marker,"Team")
	local base = getElementData(marker,"Base")
	if (team == myteam) then
		local parent = getElementParent(marker)
		local x1,y1,z1 = getElementPosition(parent)
		local attached = getAttachedElements(player)
		local flag = false
		if (attached) then
			for i,m in ipairs(attached) do
				if (getElementType(m) == "marker" and getElementData(m,"Team")) then
					flag = m
				end
			end
		end
		if (flag and isElementWithinMarker(marker,base)) then
			local parent = getElementParent(flag)
			local x,y,z = getElementPosition(parent)
			detachElements(flag,player)
			setPlayerProperty(player,"movespeed",nil)
			local xfx,yfx,zfx = getElementPosition(marker)
			local rfx,gfx,bfx = getMarkerColor(flag)
			callClientFunction(root,"fxAddGlass",xfx,yfx,zfx - 1,rfx,gfx,bfx,128,0.2,10)
			setElementPosition(flag,x,y,z + 1)
			callClientFunction(root,"CaptureTheFlag_onClientFlagDrop",flag,x,y,z)
			setElementData(myteam,"Capture",getElementData(myteam,"Capture") + 1)
			setElementData(getElementData(flag,"Team"),"FlagStatus",true)
			callClientFunction(root,"CaptureTheFlag_captureFlag",team)
		elseif (not isElementWithinMarker(marker,base)) then
			local xfx,yfx,zfx = getElementPosition(marker)
			local rfx,gfx,bfx = getMarkerColor(marker)
			callClientFunction(root,"fxAddGlass",xfx,yfx,zfx - 1,rfx,gfx,bfx,128,0.2,10)
			callClientFunction(root,"CaptureTheFlag_returnFlag",team)
		end
		setElementPosition(marker,x1,y1,z1 + 1)
		callClientFunction(root,"CaptureTheFlag_onClientFlagDrop",marker,x1,y1,z1)
		setElementData(myteam,"FlagStatus",true)
	elseif (team and myteam) then
		if (isElementWithinMarker(marker,base)) then
			callClientFunction(root,"CaptureTheFlag_stolenFlag",team,myteam)
		end
		attachElements(marker,player,0,0,2.5)
		setPlayerProperty(player,"movespeed",tonumber(getTacticsData("modes","ctf","flag_speed")) or 0.8)
		callClientFunction(root,"CaptureTheFlag_onClientFlagPickup",marker,player)
		setElementData(team,"FlagStatus",false)
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
	fadeCamera(source,false,5.0)
	local attached = getAttachedElements(source)
	if (attached) then
		for i,element in ipairs(attached) do
			if (getElementType(element) == "marker" and getElementData(element,"Team")) then
				local x,y,z = getElementPosition(source)
				detachElements(element,source)
				setPlayerProperty(source,"movespeed",nil)
				setElementPosition(element,x,y,z + 1)
				callClientFunction(root,"CaptureTheFlag_onClientFlagDrop",element,x,y,z)
			end
		end
	end
end
function CaptureTheFlag_onPlayerQuit()
	local attached = getAttachedElements(source)
	if (attached) then
		for i,element in ipairs(attached) do
			if (getElementType(element) == "marker" and getElementData(element,"Team")) then
				local x,y,z = getElementPosition(source)
				detachElements(element,source)
				setPlayerProperty(source,"movespeed",nil)
				setElementPosition(element,x,y,z + 1)
				callClientFunction(root,"CaptureTheFlag_onClientFlagDrop",element,x,y,z)
			end
		end
	end
end
function CaptureTheFlag_onWeaponDrop()
	cancelEvent()
end
addEventHandler("onMapStarting",root,CaptureTheFlag_onMapStarting)
addEventHandler("onMapStopping",root,CaptureTheFlag_onMapStopping)
addEventHandler("onResourceStart",resourceRoot,CaptureTheFlag_onResourceStart)
