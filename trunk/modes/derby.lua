local isDestructionDerby = false
local rankingTimer = false
local vehicleTimer = {}
local playerVehicle = {}
local startTick = 0
local pauseTick = 0
local replaceModels = {nitro = 2221,repair = 2222,vehiclechange = 2223}
finishCounter = {}
function DestructionDerby_onResourceStart(resource)
	createTacticsMode("derby",{timelimit="30:00",type_play="individual|individual,teamplay",disable_weapons="false",player_radarblip="all|none,team,all",firewater="false"})
end
function DestructionDerby_onMapStopping(mapinfo)
	if ((mapinfo.modename ~= "race" and mapinfo.modename ~= "derby") or not isDestructionDerby) then return end
	if (wasghostmode) then setTacticsData(wasghostmode,"settings","ghostmode",true) end
	if (isTimer(rankingTimer)) then killTimer(rankingTimer) end
	removeEventHandler("onPlayerRoundSpawn",root,DestructionDerby_onPlayerRoundSpawn)
	removeEventHandler("onPlayerQuit",root,DestructionDerby_onPlayerQuit)
	removeEventHandler("onPlayerWasted",root,DestructionDerby_onPlayerWasted)
	removeEventHandler("onPlayerRoundRespawn",root,DestructionDerby_onPlayerRoundRespawn)
	removeEventHandler("onRoundStart",root,DestructionDerby_onRoundStart)
	removeEventHandler("onRoundTimesup",root,DestructionDerby_onRoundTimesup)
	removeEventHandler("onPlayerPickUpRacePickup",root,DestructionDerby_onPlayerPickUpRacePickup)
	removeEventHandler("onVehicleEnter",root,DestructionDerby_onVehicleEnter)
	removeEventHandler("onVehicleStartExit",root,DestructionDerby_onVehicleStartExit)
	removeEventHandler("onPauseToggle",root,DestructionDerby_onPauseToggle)
	for vehicle,timer in pairs(vehicleTimer) do
		if (isTimer(timer)) then killTimer(timer) end
		vehicleTimer[vehicle] = nil
	end
end
function DestructionDerby_onMapStarting(mapinfo)
	if ((mapinfo.modename ~= "race" and mapinfo.modename ~= "derby") or #getElementsByType("checkpoint",getRoundMapRoot()) > 0) then return end
	isDestructionDerby = true
	setTacticsData("derby","Map")
	wasghostmode = getTacticsData("settings","ghostmode")
	if (wasghostmode ~= "none" and wasghostmode ~= "team") then
		setTacticsData("none","settings","ghostmode",true)
	else
		wasghostmode = nil
	end
	if (isTimer(restartTimer)) then killTimer(restartTimer) end
	spawnCounter = 1
	finishCounter = {}
	waitingTimer = "wait"
	rankingTimer = setTimer(DestructionDerby_onPlayersRanking,1000,0)
	addEventHandler("onPlayerRoundSpawn",root,DestructionDerby_onPlayerRoundSpawn)
	addEventHandler("onPlayerQuit",root,DestructionDerby_onPlayerQuit)
	addEventHandler("onPlayerWasted",root,DestructionDerby_onPlayerWasted)
	addEventHandler("onPlayerRoundRespawn",root,DestructionDerby_onPlayerRoundRespawn)
	addEventHandler("onRoundStart",root,DestructionDerby_onRoundStart)
	addEventHandler("onRoundTimesup",root,DestructionDerby_onRoundTimesup)
	addEventHandler("onPlayerPickUpRacePickup",root,DestructionDerby_onPlayerPickUpRacePickup)
	addEventHandler("onVehicleEnter",root,DestructionDerby_onVehicleEnter)
	addEventHandler("onVehicleStartExit",root,DestructionDerby_onVehicleStartExit)
	addEventHandler("onPauseToggle",root,DestructionDerby_onPauseToggle)
	setTabboardColumns()
	setSideNames("Side 1","Side 2")
	for i,racepickup in ipairs(getElementsByType("racepickup",getRoundMapRoot())) do
		local x,y,z = getElementPosition(racepickup)
		local pickuptype = getElementData(racepickup,"type")
		local object = createObject(replaceModels[pickuptype],x,y,z)
		setElementParent(object,racepickup)
		setElementInterior(object,getTacticsData("Interior"))
		local colshape = createColSphere(x,y,z,3.5)
		setElementParent(colshape,object)
	end
	triggerClientEvent(root,"onClientSetMapName",root,mapinfo.name)
end
function DestructionDerby_onRoundStart()
	startTick = getTickCount()
end
function DestructionDerby_onPlayerPickUpRacePickup(colshape,pickuptype,vehicle)
	local object = getElementParent(colshape)
	local racepickup = getElementParent(object)
	local pickuptype = getElementData(racepickup,"type")
	if (pickuptype == "nitro") then
		addVehicleUpgrade(vehicle,1008)
	elseif (pickuptype == "repair") then
		fixVehicle(vehicle)
	elseif (pickuptype == "vehiclechange") then
		local model = tonumber(getElementData(racepickup,"vehicle"))
		if (model) then
			if (getVehicleType(getElementModel(vehicle)) ~= "Plane" and getVehicleType(model) == "Plane") then
				setVehiclePanelState(vehicle,0,0)
				setVehiclePanelState(vehicle,2,0)
				setVehiclePanelState(vehicle,3,0)
				setVehiclePanelState(vehicle,4,0)
			end
			if (getVehicleType(getElementModel(vehicle)) == "Plane" and getVehicleType(model) ~= "Plane") then
				setVehicleLandingGearDown(vehicle,true)
			end
			setElementModel(vehicle,model)
		end
	end
	local respawn = getElementData(racepickup,"respawn")
	if (respawn and tonumber(respawn) >= 50) then
		destroyElement(colshape)
		destroyElement(object)
		setTimer(function(racepickup)
			if (isElement(racepickup)) then
				local interior = tonumber(getTacticsData("Interior")) or 0
				local x,y,z = getElementPosition(racepickup)
				local pickuptype = getElementData(racepickup,"type")
				local object = createObject(replaceModels[pickuptype],x,y,z)
				setElementParent(object,racepickup)
				setElementInterior(object,interior)
				local colshape = createColSphere(x,y,z,3.5)
				setElementParent(colshape,object)
				setElementInterior(colshape,interior)
			end
		end,tonumber(respawn),1,racepickup)
	end
end
function DestructionDerby_onPlayersRanking()
	local players = {}
	for i,player in ipairs(getElementsByType("player")) do
		if (getPlayerGameStatus(player) == "Play") then
			table.insert(players,player)
		end
	end
	for i,player in ipairs(players) do
		setElementData(player,"Rank",#players)
		local vehicle = getPedOccupiedVehicle(player)
		if (not vehicle or (isElementInWater(vehicle) and getVehicleType(vehicle) ~= "Boat" and getElementModel(vehicle) ~= 460 and getElementModel(vehicle) ~= 447 and getElementModel(vehicle) ~= 417 and getElementModel(vehicle) ~= 539)) then
			if (getRoundModeSettings("firewater") == "true" and vehicle) then
				blowVehicle(vehicle)
			else
				killPed(player)
			end
		end
	end
end
function DestructionDerby_onPlayerRoundSpawn()
	local team = getPlayerTeam(source)
	local model = getElementModel(source) or getElementData(team,"Skins")[1]
	if (getRoundState() == "stopped") then
		if (not spawnCounter) then spawnCounter = 1 end
		spawnCounter = spawnCounter + 1
		if (spawnCounter > #getElementsByType("spawnpoint",getRoundMapRoot())) then
			spawnCounter = 1
		end
		local element = getElementsByType("spawnpoint",getRoundMapRoot())[spawnCounter]
		local vehmodel = tonumber(getElementData(element,"vehicle")) or 411
		local posX = tonumber(getElementData(element,"posX"))
		local posY = tonumber(getElementData(element,"posY"))
		local posZ = tonumber(getElementData(element,"posZ"))
		local rotX = tonumber(getElementData(element,"rotX")) or 0.0
		local rotY = tonumber(getElementData(element,"rotY")) or 0.0
		local rotZ = tonumber(getElementData(element,"rotZ")) or tonumber(getElementData(element,"rotation")) or 0.0
		local interior = getTacticsData("Interior")
		spawnPlayer(source,posX,posY,posZ,rotZ,model,interior,0,team)
		local vehicle = createVehicle(vehmodel,posX,posY,posZ,rotX,rotY,rotZ)
		setElementParent(vehicle,getRoundMapDynamicRoot())
		setElementFrozen(vehicle,true)
		setElementInterior(vehicle,interior)
		setVehicleLocked(vehicle,true)
		warpPedIntoVehicle(source,vehicle)
		toggleAllControls(source,true)
		setCameraTarget(source,source)
		callClientFunction(source,"setCameraInterior",interior)
		setElementData(source,"Status","Play")
	else
		setElementData(source,"Status","Spectate")
	end
	DestructionDerby_onCheckRound()
end
function DestructionDerby_onPlayerRoundRespawn()
	local vehicle = playerVehicle[source]
	if (isTimer(vehicleTimer[vehicle])) then killTimer(vehicleTimer[vehicle]) end
	if (isTimer(wastedTimer[source])) then killTimer(wastedTimer[source]) end
	local team = getPlayerTeam(source)
	local skin = getElementModel(source) or getElementData(team,"Skins")[1]
	if (vehicle and isElement(vehicle)) then destroyElement(vehicle) end
	if (not spawnCounter) then spawnCounter = 1 end
	spawnCounter = spawnCounter + 1
	if (spawnCounter > #getElementsByType("spawnpoint",getRoundMapRoot())) then
		spawnCounter = 1
	end
	local parent = getElementsByType("spawnpoint",getRoundMapRoot())[spawnCounter]
	local model = tonumber(getElementData(parent,"vehicle")) or 411
	local xpos,ypos,zpos = getElementPosition(parent)
	local xrot,yrot,zrot = 0,0,tonumber(getElementData(parent,"rotation")) or 0
	local interior = getTacticsData("Interior")
	spawnPlayer(source,xpos,ypos,zpos,zrot,skin,interior,0,team)
	vehicle = createVehicle(model,xpos,ypos,zpos,xrot,yrot,zrot)
	setElementFrozen(vehicle,true)
	setElementCollisionsEnabled(vehicle,false)
	setElementParent(vehicle,getRoundMapDynamicRoot())
	setElementInterior(vehicle,interior)
	setVehicleLocked(vehicle,true)
	warpPedIntoVehicle(source,vehicle)
	toggleAllControls(source,true)
	setCameraTarget(source,source)
	setElementData(source,"Status","Play")
	callClientFunction(source,"setCameraInterior",interior)
	setTimer(function(vehicle)
		if (isElement(vehicle)) then
			setElementFrozen(vehicle,false)
			setElementCollisionsEnabled(vehicle,true)
		end
	end,1500,1,vehicle)
	local playername = getPlayerName(source)
	for i,finish in ipairs(finishCounter) do
		if (finish[1] == playername) then
			table.remove(finishCounter,i)
			break
		end
	end
end
function DestructionDerby_onPlayerQuit(type,reason,element)
	if (getPlayerGameStatus(source) == "Play") then
		if (playerVehicle[source]) then
			if (isTimer(vehicleTimer[playerVehicle[source]])) then killTimer(vehicleTimer[playerVehicle[source]]) end
			vehicleTimer[playerVehicle[source]] = setTimer(function(vehicle)
				if (not isRoundPaused() and isElement(vehicle)) then destroyElement(vehicle) end
			end,4000,1,playerVehicle[source])
		end
		setElementData(source,"Status",nil)
		DestructionDerby_onCheckRound()
	end
end
function DestructionDerby_onCheckRound()
	if (getRoundState() ~= "started" or getTacticsData("Pause")) then return end
	local type_play = getRoundModeSettings("type_play")
	if (type_play == "teamplay") then
		local players = {}
		for i,team in ipairs(getElementsByType("team")) do
			if (i > 1) then
				local count = 0
				for j,player in ipairs(getPlayersInTeam(team)) do
					if (getPlayerGameStatus(player) == "Play") then
						count = count+1
					end
				end
				table.insert(players,{team,count})
			end
		end
		table.sort(players,function(a,b) return a[2] > b[2] end)
		if (players[1][2] > 0 and players[2][2] == 0) then
			if (#finishCounter < 1) then
				return endRound('draw_round')
			end
			local reason = ""
			local firsttime = finishCounter[#finishCounter][3]
			local alive = players[1][2]
			for rank,data in ipairs(finishCounter) do
				local name,team,time = unpack(data)
				if (rank == #finishCounter) then
					reason = reason.."\n"..(rank+alive)..") "..name.." ("..MSecToTime(time)..")"
				else
					reason = reason.."\n"..(rank+alive)..") "..name.." (+"..MSecToTime(time-firsttime)..")"
				end
			end
			local r,g,b = getTeamColor(players[1][1])
			endRound({r,g,b,'derby_winner',getTeamName(players[1][1])},reason,{[players[1][1]]=1})
		elseif (players[1][2] == 0) then
			if (#finishCounter < 1) then
				return endRound('draw_round')
			end
			local reason = ""
			local firsttime = finishCounter[#finishCounter][3]
			for rank,data in ipairs(finishCounter) do
				local name,team,time = unpack(data)
				if (rank == #finishCounter) then
					reason = reason.."\n"..rank..") "..name.." ("..MSecToTime(time)..")"
				else
					reason = reason.."\n"..rank..") "..name.." (+"..MSecToTime(time-firsttime)..")"
				end
			end
			endRound('draw_round',reason)
		end
	elseif (type_play == "individual") then
		local count = 0
		local winner = false
		for i,player in ipairs(getElementsByType("player")) do
			if (getPlayerGameStatus(player) == "Play") then
				count = count + 1
				winner = player
			end
		end
		if (count <= 1) then
			if (#finishCounter < 1) then
				return endRound('draw_round')
			end
			if (winner) then
				local reason = ""
				local firsttime = finishCounter[#finishCounter][3]
				for rank,data in ipairs(finishCounter) do
					local name,team,time = unpack(data)
					if (rank == #finishCounter) then
						reason = reason.."\n"..(rank+count)..") "..name.." ("..MSecToTime(time)..")"
					else
						reason = reason.."\n"..(rank+count)..") "..name.." (+"..MSecToTime(time-firsttime)..")"
					end
				end
				endRound({'derby_winner',getPlayerName(winner)},reason)
			else
				local reason = ""
				local firsttime = finishCounter[#finishCounter][3]
				for rank,data in ipairs(finishCounter) do
					local name,team,time = unpack(data)
					if (rank == #finishCounter) then
						reason = reason.."\n"..(rank+count)..") "..name.." ("..MSecToTime(time)..")"
					else
						reason = reason.."\n"..(rank+count)..") "..name.." (+"..MSecToTime(time-firsttime)..")"
					end
				end
				endRound('draw_round',reason)
			end
		end
	end
end
function DestructionDerby_onRoundTimesup()
	return endRound('draw_round',{'time_over',""})
end
function DestructionDerby_onPlayerWasted(ammo,killer,weapon,bodypart,stealth)
	if (getPlayerGameStatus(source) ~= "Play" or not getTacticsData("timestart")) then return end
	if (playerVehicle[source]) then
		if (isTimer(vehicleTimer[playerVehicle[source]])) then killTimer(vehicleTimer[playerVehicle[source]]) end
		vehicleTimer[playerVehicle[source]] = setTimer(function(vehicle,player)
			if (isElement(player)) then
				removePedFromVehicle(player)
				setElementFrozen(player,true)
				setElementPosition(player,0,0,0)
			end
			if (isElement(vehicle)) then
				destroyElement(vehicle)
			end
		end,4000,1,playerVehicle[source],source)
	end
	setElementData(source,"Status","Die")
	fadeCamera(source,false,2.0)
	local time = getTickCount()-getTacticsData("timestart")
	table.insert(finishCounter,1,{getPlayerName(source),getPlayerTeam(source),time})
	DestructionDerby_onCheckRound()
end
function DestructionDerby_onVehicleEnter(player,seat,jacked)
	if (seat == 0) then playerVehicle[player] = source end
end
function DestructionDerby_onVehicleStartExit(player,seat,jacked)
	cancelEvent()
end
function DestructionDerby_onPauseToggle(paused)
	if (not paused) then
		for i,vehicle in ipairs(getElementsByType("vehicle",getRoundMapRoot())) do
			if (not getVehicleController(vehicle) and not isTimer(vehicleTimer[vehicle])) then
				destroyElement(vehicle)
			end
		end
		startTick = startTick + (getTickCount() - pauseTick)
	else
		pauseTick = getTickCount()
	end
end
addEvent("onPlayerPickUpRacePickup",true)
addEventHandler("onMapStarting",root,DestructionDerby_onMapStarting)
addEventHandler("onMapStopping",root,DestructionDerby_onMapStopping)
addEventHandler("onResourceStart",resourceRoot,DestructionDerby_onResourceStart)
