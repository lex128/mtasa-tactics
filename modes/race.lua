local isRace = false
local rankingTimer = false
local vehicleTimer = {}
local playerVehicle = {}
local playerFinish = {}
local replaceModels = {nitro = 2221,repair = 2222,vehiclechange = 2223}
function RaceMatch_onResourceStart(resource)
	createTacticsMode("race",{timelimit="30:00",type_play="individual|individual,teamplay",increase_checkpoints="4",disable_weapons="true",respawn="true",respawn_lives="0",respawn_time="0:05",finish="0:30",player_radarblip="all|none,team,all"})
end
function RaceMatch_onMapStopping(mapinfo)
	if (mapinfo.modename ~= "race" or not isRace) then return end
	if (wasghostmode) then setTacticsData(wasghostmode,"settings","ghostmode") end
	if (isTimer(rankingTimer)) then killTimer(rankingTimer) end
	removeEventHandler("onPlayerRoundSpawn",root,RaceMatch_onPlayerRoundSpawn)
	removeEventHandler("onPlayerQuit",root,RaceMatch_onPlayerQuit)
	removeEventHandler("onPlayerWasted",root,RaceMatch_onPlayerWasted)
	removeEventHandler("onPlayerRoundRespawn",root,RaceMatch_onPlayerRoundRespawn)
	removeEventHandler("onRoundTimesup",root,RaceMatch_onRoundTimesup)
	removeEventHandler("onPlayerReachCheckpointInternal",root,RaceMatch_onPlayerReachCheckpointInternal)
	removeEventHandler("onPlayerFinish",root,RaceMatch_onPlayerFinish)
	removeEventHandler("onPlayerPickUpRacePickup",root,RaceMatch_onPlayerPickUpRacePickup)
	removeEventHandler("onVehicleEnter",root,RaceMatch_onVehicleEnter)
	removeEventHandler("onVehicleStartExit",root,RaceMatch_onVehicleStartExit)
	removeEventHandler("onPauseToggle",root,RaceMatch_onPauseToggle)
	for vehicle,timer in pairs(vehicleTimer) do
		if (isTimer(timer)) then killTimer(timer) end
		vehicleTimer[vehicle] = nil
	end
end
function RaceMatch_onMapStarting(mapinfo)
	if (mapinfo.modename ~= "race" or #getElementsByType("checkpoint",getRoundMapRoot()) == 0) then return end
	isRace = true
	wasghostmode = getTacticsData("settings","ghostmode")
	if (isTimer(restartTimer)) then killTimer(restartTimer) end
	spawnCounter = 1
	finishCounter = {}
	playerFinish = {}
	waitingTimer = "wait"
	rankingTimer = setTimer(RaceMatch_onPlayersRanking,1000,0)
	addEventHandler("onPlayerRoundSpawn",root,RaceMatch_onPlayerRoundSpawn)
	addEventHandler("onPlayerQuit",root,RaceMatch_onPlayerQuit)
	addEventHandler("onPlayerWasted",root,RaceMatch_onPlayerWasted)
	addEventHandler("onPlayerRoundRespawn",root,RaceMatch_onPlayerRoundRespawn)
	addEventHandler("onRoundTimesup",root,RaceMatch_onRoundTimesup)
	addEventHandler("onPlayerReachCheckpointInternal",root,RaceMatch_onPlayerReachCheckpointInternal)
	addEventHandler("onPlayerFinish",root,RaceMatch_onPlayerFinish)
	addEventHandler("onPlayerPickUpRacePickup",root,RaceMatch_onPlayerPickUpRacePickup)
	addEventHandler("onVehicleEnter",root,RaceMatch_onVehicleEnter)
	addEventHandler("onVehicleStartExit",root,RaceMatch_onVehicleStartExit)
	addEventHandler("onPauseToggle",root,RaceMatch_onPauseToggle)
	setTabboardColumns({{"Rank",0.14},{"Checkpoint",0.15}})
	setTacticsData("true","settings","ghostmode")
	setSideNames("Side 1","Side 2")
	for i,racepickup in ipairs(getElementsByType("racepickup",getRoundMapRoot())) do
		local x,y,z = getElementPosition(racepickup)
		local type = getElementData(racepickup,"type")
		local object = createObject(replaceModels[type],x,y,z)
		setElementParent(object,racepickup)
		setElementInterior(object,getTacticsData("Interior"))
		local colshape = createColSphere(x,y,z,3.5)
		setElementParent(colshape,object)
	end
	triggerClientEvent(root,"onClientSetMapName",root,mapinfo.name)
end
function RaceMatch_onPlayerPickUpRacePickup(colshape,pickuptype,vehicle)
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
function RaceMatch_onPlayersRanking()
	local players = {}
	for i,player in ipairs(getElementsByType("player")) do
		if (getPlayerGameStatus(player) == "Play") then
			local check = tonumber(getElementData(player,"Checkpoint")) or 1
			local checkpoint = getElementsByType("checkpoint",getRoundMapRoot())[check]
			if (checkpoint) then
				local x1,y1,z1 = getElementPosition(player)
				local x2,y2,z2 = getElementPosition(checkpoint)
				table.insert(players,{player,check,getDistanceBetweenPoints3D(x1,y1,z1,x2,y2,z2)})
			end
		end
	end
	table.sort(players,function(a,b) return a[2] > b[2] or (a[2] == b[2] and a[3] < b[3]) end)
	for place,player in ipairs(players) do
		setElementData(player[1],"Rank",place + #finishCounter)
		local vehicle = getPedOccupiedVehicle(player[1])
		if (not vehicle or (isElementInWater(vehicle) and getVehicleType(vehicle) ~= "Boat" and getElementModel(vehicle) ~= 460 and getElementModel(vehicle) ~= 447 and getElementModel(vehicle) ~= 417 and getElementModel(vehicle) ~= 539)) then
			killPed(player[1])
		end
	end
end
function RaceMatch_onPlayerRoundSpawn()
	local team = getPlayerTeam(source)
	local model = getElementModel(source)
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
		setElementParent(vehicle,element)
		setElementFrozen(vehicle,true)
		setElementInterior(vehicle,interior)
		setVehicleLocked(vehicle,true)
		warpPedIntoVehicle(source,vehicle)
		toggleAllControls(source,true)
		setCameraTarget(source,source)
		callClientFunction(source,"setCameraInterior",interior)
		setElementData(source,"Rank",1)
		setElementData(source,"Checkpoint",nil)
		setElementData(source,"Checkpoint",1)
		setElementData(source,"Status","Play")
	else
		setElementData(source,"Status","Spectate")
	end
	if (getRoundModeSettings("respawn") == "false") then
		RaceMatch_onCheckRound()
	end
end
function RaceMatch_onPlayerRoundRespawn()
	playerFinish[source] = nil
	local vehicle = playerVehicle[source]
	if (isTimer(vehicleTimer[vehicle])) then killTimer(vehicleTimer[vehicle]) end
	if (isTimer(wastedTimer[source])) then killTimer(wastedTimer[source]) end
	local team = getPlayerTeam(source)
	local skin = getElementModel(source)
	if (not skin or skin == 0) then skin = getElementData(team,"Skins")[1] end
	if (vehicle and isElement(vehicle)) then
		destroyElement(vehicle)
	end
	local point = math.max((getElementData(source,"Checkpoint") or 1)-1,0)
	local model,xpos,ypos,zpos,xrot,yrot,zrot,xvel,yvel,zvel,xturn,yturn,zturn,property,geardown,nitrolevel = unpack(getElementData(source,"checksave"..point) or {})
	if (not model) then
		if (not spawnCounter) then spawnCounter = 1 end
		spawnCounter = spawnCounter + 1
		if (spawnCounter > #getElementsByType("spawnpoint",getRoundMapRoot())) then
			spawnCounter = 1
		end
		local parent = getElementsByType("spawnpoint",getRoundMapRoot())[spawnCounter]
		model = tonumber(getElementData(parent,"vehicle")) or 411
		xpos,ypos,zpos = getElementPosition(parent)
		xrot,yrot,zrot = 0,0,tonumber(getElementData(parent,"rotation")) or 0
		xvel,yvel,zvel,xturn,yturn,zturn = 0,0,0,0,0,0
		property,geardown,nitrolevel = 0,true,0
	end
	local interior = getTacticsData("Interior")
	spawnPlayer(source,xpos,ypos,zpos,0,skin,interior,0,team)
	vehicle = createVehicle(model,xpos,ypos,zpos,xrot,yrot,zrot)
	if (property) then callClientFunction(root,"setVehicleAdjustableProperty",vehicle,property) end
	setVehicleLandingGearDown(vehicle,geardown or false)
	if (nitrolevel) then setElementData(vehicle,"nitrolevel",nitrolevel) end
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
	setElementData(source,"Checkpoint",nil)
	setElementData(source,"Checkpoint",math.max(1,point))
	setTimer(function(vehicle,xvel,yvel,zvel,xturn,yturn,zturn)
		if (isElement(vehicle)) then
			setElementFrozen(vehicle,false)
			setElementCollisionsEnabled(vehicle,true)
			setElementVelocity(vehicle,xvel,yvel,zvel)
			setVehicleTurnVelocity(vehicle,xturn,yturn,zturn)
		end
	end,2000,1,vehicle,xvel,yvel,zvel,xturn,yturn,zturn)
	local playername = getPlayerName(source)
	for i,finish in ipairs(finishCounter) do
		if (finish[1] == playername) then
			table.remove(finishCounter,i)
			break
		end
	end
end
function RaceMatch_onPlayerQuit(type,reason,element)
	if (getPlayerGameStatus(source) == "Play") then
		if (playerVehicle[source]) then
			if (isTimer(vehicleTimer[playerVehicle[source]])) then killTimer(vehicleTimer[playerVehicle[source]]) end
			vehicleTimer[playerVehicle[source]] = setTimer(function(vehicle)
				if (not isRoundPaused()) then destroyElement(vehicle) end
			end,4000,1,playerVehicle[source])
		end
		setElementData(source,"Status",nil)
		if (getRoundModeSettings("respawn") == "false") then
			RaceMatch_onCheckRound()
		end
	end
end
function RaceMatch_onPlayerReachCheckpointInternal(checkpointnum)
	if (isRoundPaused() or getPlayerGameStatus(source) ~= "Play") then return end
	triggerEvent("onPlayerReachCheckpoint",source,checkpointnum,time)
	if (checkpointnum > #getElementsByType("checkpoint",getRoundMapRoot())) then
		local time = getTickCount()-getTacticsData("timestart")
		local place = #finishCounter+1
		triggerEvent("onPlayerFinish",source,place,time)
		triggerClientEvent(root,"onClientPlayerFinish",source,place,time)
	end
end
function RaceMatch_onPlayerFinish(place,time)
	if (getResourceFromName("killchat") and getResourceState(getResourceFromName("killchat")) == "running") then
		local r,g,b = getTeamColor(getPlayerTeam(source))
		local timestring = (place == 1 and MSecToTime(time,3)) or "+"..MSecToTime(time-finishCounter[1][3],3)
		exports.killchat:outputKillChatMessage({place..") "..timestring,{"padding",width=3},{"image",path=":"..getResourceName(getThisResource()).."/images/finish.png"},{"padding",width=3},{"color",r=r or 255,g=g or 255,b=b or 255},getPlayerName(source)})
	end
	table.insert(finishCounter,{getPlayerName(source),getPlayerTeam(source),time})
	playerFinish[source] = true
	setElementData(source,"Status",nil)
	if (isTimer(wastedTimer[source])) then killTimer(wastedTimer[source]) end
	wastedTimer[source] = setTimer(function(player)
		if (isElement(player)) then
			removePedFromVehicle(player)
			setElementFrozen(player,true)
			setElementPosition(player,0,0,0)
			if (isElement(playerVehicle[player])) then
				destroyElement(playerVehicle[player])
			end
			setCameraSpectating(player)
		end
	end,2000,1,source)
	if (isTimer(overtimeTimer)) then
		local remaining = getTimerDetails(overtimeTimer)
		local finish = TimeToSec(getRoundModeSettings("finish") or "0:30")
		if (remaining > finish*1000) then
			killTimer(overtimeTimer)
			setTacticsData(getTickCount() + finish*1000,"timeleft")
			overtimeTimer = setTimer(triggerEvent,finish*1000,1,"onRoundTimesup",root)
		end
	end
	RaceMatch_onCheckRound()
end
function RaceMatch_onCheckRound()
	if (getRoundState() ~= "started" or isRoundPaused()) then return end
	local count = 0
	for i,player in ipairs(getElementsByType("player")) do
		if (getPlayerGameStatus(player) == "Play" and not playerFinish[player]) then
			count = count + 1
		end
	end
	if (count == 0) then
		if (#finishCounter < 1) then
			return endRound('draw_round')
		end
		local type_play = getRoundModeSettings("type_play")
		if (type_play == "teamplay") then
			local reason = ""
			local firsttime = finishCounter[1][3]
			local teamscores = {}
			for rank=1,math.min(#finishCounter,5) do
				local name,team,time = unpack(finishCounter[rank])
				local score = ({10,8,6,4,2})[rank]
				teamscores[team] = (teamscores[team] or 0) + score
				reason = reason.."\n"..rank..") "..name.." (+"..score..")"
			end
			local teams = getElementsByType("team")
			if (#teams > 1) then
				table.sort(teams,function(a,b)
					local ascore = teamscores[a] or 0
					local bscore = teamscores[b] or 0
					return ascore > bscore
				end)
				if (#teams > 1 and teamscores[teams[1]] and teamscores[teams[1]] > 0 and (not teamscores[teams[2]] or teamscores[teams[1]] > teamscores[teams[2]])) then
					local r,g,b = getTeamColor(teams[1])
					endRound({r,g,b,'race_winner',getTeamName(teams[1])},reason,teamscores)
				else
					endRound('draw_round')
				end
			else
				endRound('draw_round')
			end
		elseif (type_play == "individual") then
			-- local reason = ""
			-- local firsttime = finishCounter[1][3]
			-- for rank,data in ipairs(finishCounter) do
				-- local name,team,time = unpack(data)
				-- if (rank == 1) then
					-- reason = reason.."\n"..rank..") "..name.."     "..MSecToTime(time)
				-- else
					-- reason = reason.."\n"..rank..") "..name.."     "..MSecToTime(time).." (+"..MSecToTime(time-firsttime)..")"
				-- end
			-- end
			endRound({'race_winner',finishCounter[1][1]})
		end
	end
end
function RaceMatch_onRoundTimesup()
	if (#finishCounter < 1) then
		return endRound('draw_round',{'time_over',""})
	end
	local type_play = getRoundModeSettings("type_play")
	if (type_play == "teamplay") then
		local reason = ""
		local firsttime = finishCounter[1][3]
		local teamscores = {}
		for rank=1,math.min(#finishCounter,5) do
			local name,team,time = unpack(finishCounter[rank])
			local score = ({10,8,6,4,2})[rank]
			teamscores[team] = (teamscores[team] or 0) + score
			reason = reason.."\n"..rank..") "..name.." (+"..score..")"
		end
		local teams = getElementsByType("team")
		if (#teams > 1) then
			table.sort(teams,function(a,b)
				local ascore = teamscores[a] or 0
				local bscore = teamscores[b] or 0
				return ascore > bscore
			end)
			if (#teams > 1 and teamscores[teams[1]] and teamscores[teams[1]] > 0 and (not teamscores[teams[2]] or teamscores[teams[1]] > teamscores[teams[2]])) then
				local r,g,b = getTeamColor(teams[1])
				endRound({r,g,b,'race_winner',getTeamName(teams[1])},{'time_over',reason},teamscores)
			else
				endRound('draw_round',{'time_over',""})
			end
		else
			endRound('draw_round',{'time_over',""})
		end
	elseif (type_play == "individual") then
		-- local reason = ""
		-- local firsttime = finishCounter[1][3]
		-- for rank,data in ipairs(finishCounter) do
			-- local name,team,time = unpack(data)
			-- if (rank == 1) then
				-- reason = reason.."\n"..rank..") "..name.."     "..MSecToTime(time)
			-- else
				-- reason = reason.."\n"..rank..") "..name.."     "..MSecToTime(time).." (+"..MSecToTime(time-firsttime)..")"
			-- end
		-- end
		endRound({'race_winner',finishCounter[1][1]},{'time_over',""})
	end
end
function RaceMatch_onPlayerWasted(ammo,killer,weapon,bodypart,stealth)
	if (playerFinish[source]) then return end
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
	if (getRoundModeSettings("respawn") == "false") then
		RaceMatch_onCheckRound()
	end
end
function RaceMatch_onVehicleEnter(player,seat,jacked)
	if (seat == 0) then playerVehicle[player] = source end
end
function RaceMatch_onVehicleStartExit(player,seat,jacked)
	cancelEvent()
end
function RaceMatch_onPauseToggle(paused)
	if (not paused) then
		for i,vehicle in ipairs(getElementsByType("vehicle",getRoundMapRoot())) do
			if (not getVehicleController(vehicle) and not isTimer(vehicleTimer[vehicle])) then
				destroyElement(vehicle)
			end
		end
	end
end
addEvent("onPlayerReachCheckpointInternal",true)
addEvent("onPlayerPickUpRacePickup",true)
addEvent("onPlayerReachCheckpoint")
addEvent("onPlayerFinish")
addEventHandler("onMapStarting",root,RaceMatch_onMapStarting)
addEventHandler("onMapStopping",root,RaceMatch_onMapStopping)
addEventHandler("onResourceStart",resourceRoot,RaceMatch_onResourceStart)
