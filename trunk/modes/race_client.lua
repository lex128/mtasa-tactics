local isRace = false
local font1 = (0.015*yscreen)/9
local replaceModels = {nitro = 2221,repair = 2222,vehiclechange = 2223}
local replaces = {}
local pickups = {}
function RaceMatch_onClientMapStopping(mapinfo)
	if (mapinfo.modename ~= "race" or not isRace) then return end
	for _,data in ipairs(replaces) do
		local txd,dff,id = unpack(data)
		if (id) then engineRestoreModel(id) end
		if (txd) then destroyElement(txd) end
		if (dff) then destroyElement(dff) end
	end
	replaces = {}
	showRoundHudComponent("timeleft",false)
	showRoundHudComponent("race",false)
	removeEventHandler("onClientRender",root,RaceMatch_onClientRender)
	removeEventHandler("onClientColShapeHit",root,RaceMatch_onClientColShapeHit)
	removeEventHandler("onClientElementDataChange",root,RaceMatch_onClientElementDataChange)
--	removeEventHandler("onClientPlayerWasted",localPlayer,RaceMatch_onClientPlayerWasted)
	removeEventHandler("onClientElementStreamIn",root,RaceMatch_onClientElementStreamIn)
	removeEventHandler("onClientPlayerFinish",root,RaceMatch_onClientPlayerFinish)
	removeEventHandler("onClientRoundFinish",root,RaceMatch_onClientRoundFinish)
	unbindKey("vehicle_fire","down",RaceMatch_disableVehicleWeapons)
	unbindKey("vehicle_secondary_fire","down",RaceMatch_disableVehicleWeapons)
	setPedCanBeKnockedOffBike(localPlayer,true)
	for _,racepickup in ipairs(getElementsByType("racepickup",getRoundMapRoot())) do
		setElementCollisionsEnabled(racepickup,false)
	end
end
function RaceMatch_onClientMapStarting(mapinfo)
	if (mapinfo.modename ~= "race" or #getElementsByType("checkpoint",getRoundMapRoot()) == 0) then return end
	isRace = true
	for name,id in pairs(replaceModels) do
		local txd = engineLoadTXD("models/"..name..".txd")
		if (txd) then engineImportTXD(txd,id) end
		local dff = engineLoadDFF("models/"..name..".dff",id)
		if (dff) then engineReplaceModel(dff,id) end
		if (id) then engineSetModelLODDistance(id,60) end
		table.insert(replaces,{txd,dff,id})
	end
	showRoundHudComponent("timeleft",true)
	setRoundHudComponent("race",true,true)
	showRoundHudComponent("race",true)
	showPlayerHudComponent("ammo",false)
	showPlayerHudComponent("area_name",false)
	showPlayerHudComponent("armour",false)
	showPlayerHudComponent("breath",false)
	showPlayerHudComponent("clock",true)
	showPlayerHudComponent("health",true)
	showPlayerHudComponent("money",false)
	showPlayerHudComponent("radar",true)
	showPlayerHudComponent("vehicle_name",false)
	showPlayerHudComponent("weapon",false)
	setPedCanBeKnockedOffBike(localPlayer,false)
	addEventHandler("onClientRender",root,RaceMatch_onClientRender)
	addEventHandler("onClientColShapeHit",root,RaceMatch_onClientColShapeHit)
	addEventHandler("onClientElementDataChange",root,RaceMatch_onClientElementDataChange)
--	addEventHandler("onClientPlayerWasted",localPlayer,RaceMatch_onClientPlayerWasted)
	addEventHandler("onClientElementStreamIn",root,RaceMatch_onClientElementStreamIn)
	addEventHandler("onClientPlayerFinish",root,RaceMatch_onClientPlayerFinish)
	addEventHandler("onClientRoundFinish",root,RaceMatch_onClientRoundFinish)
	bindKey("vehicle_fire","down",RaceMatch_disableVehicleWeapons)
	bindKey("vehicle_secondary_fire","down",RaceMatch_disableVehicleWeapons)
	local checkpoints = getElementsByType("checkpoint",getRoundMapRoot())
	local color = getElementData(checkpoints[1],"color") or "#0080FF"
	local r,g,b,a = getColorFromString(color)
	createRadarPolyline(checkpoints,r,g,b,a,false)
end
function RaceMatch_onClientElementDataChange(data,old)
	if (data == "Checkpoint" and source == localPlayer) then
		local point = getElementData(localPlayer,"Checkpoint")
		for i,marker in ipairs(getElementsByType("marker",getRoundMapRoot())) do
			destroyElement(marker)
		end
		if (type(point) ~= "number") then return end
		if (getTacticsData("modes","race","respawn") ~= "false" and type(old) == "number") then
			local vehicle = getPedOccupiedVehicle(localPlayer)
			local xpos,ypos,zpos = getElementPosition(vehicle)
			local xrot,yrot,zrot = getElementRotation(vehicle)
			local xvel,yvel,zvel = getElementVelocity(vehicle)
			local xturn,yturn,zturn = getVehicleTurnVelocity(vehicle)
			local model = getElementModel(vehicle)
			local property = getVehicleAdjustableProperty(vehicle)
			local geardown = getVehicleLandingGearDown(vehicle)
			local nitrolevel = getElementData(vehicle,"nitrolevel")
			setElementData(localPlayer,"checksave"..(point-1),{model,xpos,ypos,zpos,xrot,yrot,zrot,xvel,yvel,zvel,xturn,yturn,zturn,property,geardown,nitrolevel})
		end
		local checkpoint = getElementsByType("checkpoint",getRoundMapRoot())[tonumber(point)]
		if (not checkpoint) then return end
		local posX = tonumber(getElementData(checkpoint,"posX"))
		local posY = tonumber(getElementData(checkpoint,"posY"))
		local posZ = tonumber(getElementData(checkpoint,"posZ"))
		local type = getElementData(checkpoint,"type") or "checkpoint"
		local size = tonumber(getElementData(checkpoint,"size")) or 1.0
		local color = getElementData(checkpoint,"color") or "#0080FF"
		local r,g,b,a = getColorFromString(color)
		local increase_checkpoints = getTacticsData("modes","race","increase_checkpoints") or 4
		local marker = createMarker(posX,posY,posZ,type,size*increase_checkpoints,r,g,b,a)
		setElementParent(marker,checkpoint)
		local blip = createBlipAttachedTo(marker,0,3,r,g,b,255,1)
		setElementParent(blip,marker)
		if (type == "checkpoint") then
			local colshape = createColCircle(posX,posY,size*increase_checkpoints+4)
			setElementParent(colshape,marker)
		else
			local colshape = createColSphere(posX,posY,posZ,size*increase_checkpoints+4)
			setElementParent(colshape,marker)
		end
		local target = getElementData(checkpoint,"nextid")
		if (target) then
			target = getElementByID(target)
			tposX = tonumber(getElementData(target,"posX"))
			tposY = tonumber(getElementData(target,"posY"))
			tposZ = tonumber(getElementData(target,"posZ"))
			if (type == "checkpoint" or type == "ring") then
				setMarkerTarget(marker,tposX,tposY,tposZ)
				if (type == "checkpoint") then setMarkerIcon(marker,"arrow") end
			end
			type = getElementData(target,"type") or "checkpoint"
			size = tonumber(getElementData(target,"size")) or 1.0
			color = getElementData(target,"color") or "#0080FF"
			r,g,b,a = getColorFromString(color)
			local nextmarker = createMarker(tposX,tposY,tposZ,type,size*increase_checkpoints,r,g,b,a/2)
			setElementParent(nextmarker,checkpoint)
			blip = createBlipAttachedTo(nextmarker,0,2,r,g,b,64,1)
			setElementParent(blip,nextmarker)
			if (type == "ring") then
				local target = getElementData(target,"nextid")
				if (target) then
					target = getElementByID(target)
					posX = tonumber(getElementData(target,"posX"))
					posY = tonumber(getElementData(target,"posY"))
					posZ = tonumber(getElementData(target,"posZ"))
					setMarkerTarget(nextmarker,posX,posY,posZ)
				else
					setMarkerTarget(nextmarker,posX,posY,posZ)
				end
			end
		else
			if (type == "checkpoint") then setMarkerIcon(marker,"finish") end
			if (type == "ring") then
			end
		end
	end
	if (getPlayerGameStatus(localPlayer) == "Spectate" and ((data == "spectarget" and source == localPlayer and getElementData(source,data)) or (data == "Checkpoint" and source == getElementData(localPlayer,"spectarget")))) then
		local new = getElementData(source,data)
		if (data == "spectarget") then new = getElementData(new,"Checkpoint") end
		for i,marker in ipairs(getElementsByType("marker",getRoundMapRoot())) do
			destroyElement(marker)
		end
		if (type(new) ~= "number") then return end
		local checkpoint = getElementsByType("checkpoint",getRoundMapRoot())[tonumber(new)]
		if (not checkpoint) then return end
		local posX = tonumber(getElementData(checkpoint,"posX"))
		local posY = tonumber(getElementData(checkpoint,"posY"))
		local posZ = tonumber(getElementData(checkpoint,"posZ"))
		local type = getElementData(checkpoint,"type") or "checkpoint"
		local size = tonumber(getElementData(checkpoint,"size")) or 1.0
		local color = getElementData(checkpoint,"color") or "#0080FF"
		local r,g,b,a = getColorFromString(color)
		local increase_checkpoints = getTacticsData("modes","race","increase_checkpoints") or 4
		local marker = createMarker(posX,posY,posZ,type,size*increase_checkpoints,r,g,b,a)
		setElementParent(marker,checkpoint)
		local blip = createBlipAttachedTo(marker,0,3,r,g,b,255,1)
		setElementParent(blip,marker)
		local target = getElementData(checkpoint,"nextid")
		if (target) then
			target = getElementByID(target)
			tposX = tonumber(getElementData(target,"posX"))
			tposY = tonumber(getElementData(target,"posY"))
			tposZ = tonumber(getElementData(target,"posZ"))
			if (type == "checkpoint" or type == "ring") then
				setMarkerTarget(marker,tposX,tposY,tposZ)
				if (type == "checkpoint") then setMarkerIcon(marker,"arrow") end
			end
			type = getElementData(target,"type") or "checkpoint"
			size = tonumber(getElementData(target,"size")) or 1.0
			color = getElementData(target,"color") or "#0080FF"
			r,g,b,a = getColorFromString(color)
			local nextmarker = createMarker(tposX,tposY,tposZ,type,size*increase_checkpoints,r,g,b,a/2)
			setElementParent(nextmarker,checkpoint)
			blip = createBlipAttachedTo(nextmarker,0,2,r,g,b,64,1)
			setElementParent(blip,nextmarker)
			if (type == "ring") then
				local target = getElementData(target,"nextid")
				if (target) then
					target = getElementByID(target)
					posX = tonumber(getElementData(target,"posX"))
					posY = tonumber(getElementData(target,"posY"))
					posZ = tonumber(getElementData(target,"posZ"))
					setMarkerTarget(nextmarker,posX,posY,posZ)
				else
					setMarkerTarget(nextmarker,posX,posY,posZ)
				end
			end
		else
			if (type == "checkpoint") then setMarkerIcon(marker,"finish") end
			if (type == "ring") then
			end
		end
	end
end
function RaceMatch_onClientColShapeHit(element,dimension)
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if (element == vehicle and getPlayerGameStatus(localPlayer) == "Play") then
		local marker = getElementParent(source)
		local parent = getElementParent(marker)
		if (parent and getElementType(parent) == "checkpoint") then
			local model = tonumber(getElementData(parent,"vehicle"))
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
				local dist1 = getElementDistanceFromCentreOfMassToBaseOfModel(vehicle)
				setElementModel(vehicle,model)
				callServerFunction("setElementModel",vehicle,model)
				local dist2 = getElementDistanceFromCentreOfMassToBaseOfModel(vehicle)
				local x,y,z = getElementPosition(vehicle)
				setElementPosition(vehicle,x,y,z + dist2 - dist1)
			end
			setElementData(localPlayer,"Checkpoint",getElementData(localPlayer,"Checkpoint") + 1)
			playSoundFrontEnd(43)
			triggerServerEvent("onPlayerReachCheckpointInternal",localPlayer,getElementData(localPlayer,"Checkpoint"))
		end
		if (parent and isElement(parent) and getElementType(parent) == "racepickup") then
			local type = getElementData(parent,"type")
			if (type == "nitro") then
				addVehicleUpgrade(vehicle,1008)
				callServerFunction("addVehicleUpgrade",vehicle,1008)
				setElementData(vehicle,"nitroLevel",20000)
				if (nitroLevel) then nitroLevel = 20000 end
				playSoundFrontEnd(46)
			elseif (type == "repair") then
				fixVehicle(vehicle)
				callServerFunction("fixVehicle",vehicle)
				playSoundFrontEnd(46)
			elseif (type == "vehiclechange") then
				local model = tonumber(getElementData(parent,"vehicle"))
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
					local dist1 = getElementDistanceFromCentreOfMassToBaseOfModel(vehicle)
					setElementModel(vehicle,model)
					callServerFunction("setElementModel",vehicle,model)
					local dist2 = getElementDistanceFromCentreOfMassToBaseOfModel(vehicle)
					local x,y,z = getElementPosition(vehicle)
					setElementPosition(vehicle,x,y,z + dist2 - dist1)
					playSoundFrontEnd(46)
				end
			end
			triggerServerEvent("onPlayerPickUpRacePickup",localPlayer,source,type,vehicle)
		end
	end
end
function RaceMatch_onClientRender()
	for i,marker in ipairs(getElementsByType("marker",getRoundMapRoot())) do
		local parent = getElementParent(marker)
		if (parent and getElementType(parent) == "checkpoint") then
			local model = tonumber(getElementData(parent,"vehicle"))
			if (model) then
				local vehname = getVehicleNameFromModel(model)
				local x,y,z = getElementPosition(parent)
				local x2,y2 = getScreenFromWorldPosition(x,y,z+1,0,true)
				if (x2 and getDistanceBetweenPoints3D(x,y,z,getCameraMatrix()) < 500) then
					dxDrawText(vehname,x2 + 1,y2 + 1,x2 + 1,y2 + 1,blackC0,font1,"default","center","bottom")
					dxDrawText(vehname,x2,y2,x2,y2,whiteC0,font1,"default","center","bottom")
				end
			end
		end
	end
	local angle = getTickCount()*0.1%360
	for _,racepickup in ipairs(getElementsByType("racepickup",getRoundMapRoot())) do
		if (racepickup and getElementType(racepickup) == "racepickup") then
			setElementRotation(racepickup,0,0,angle)
			local x,y,z = getElementPosition(racepickup)
			local x2,y2 = getScreenFromWorldPosition(x,y,z+1,0)
			if (x2) then
				if (getDistanceBetweenPoints3D(x,y,z,getCameraMatrix()) < 100) then
					if (getElementData(racepickup,"type") == "vehiclechange") then
						local model = tonumber(getElementData(racepickup,"vehicle"))
						local vehname = getVehicleNameFromModel(model)
						if (vehname) then
							dxDrawText(vehname,x2 + 1,y2 + 1,x2 + 1,y2 + 1,blackC0,font1,"default","center","bottom")
							dxDrawText(vehname,x2,y2,x2,y2,whiteC0,font1,"default","center","bottom")
						end
					elseif (getElementData(racepickup,"type") == "repair") then
						dxDrawText("Repair",x2 + 1,y2 + 1,x2 + 1,y2 + 1,blackC0,font1,"default","center","bottom")
						dxDrawText("Repair",x2,y2,x2,y2,whiteC0,font1,"default","center","bottom")
					elseif (getElementData(racepickup,"type") == "nitro") then
						dxDrawText("Nitro",x2 + 1,y2 + 1,x2 + 1,y2 + 1,blackC0,font1,"default","center","bottom")
						dxDrawText("Nitro",x2,y2,x2,y2,whiteC0,font1,"default","center","bottom")
					end
				end
			end
		end
	end
	if (getPlayerGameStatus(localPlayer) == "Play") then
		local vehicle = getPedOccupiedVehicle(localPlayer)
		if (vehicle) then
			local health = getElementHealth(vehicle)
			local pedhealth = math.max(1,(health-250)/7.5)
			if (not isVehicleBlown(vehicle) and health > 0 and getElementHealth(localPlayer) > 0) then
				setElementHealth(localPlayer,pedhealth)
			end
		end
	end
end
function RaceMatch_disableVehicleWeapons()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if (vehicle and (getVehicleType(vehicle) == "Plane" or getVehicleType(vehicle) == "Helicopter")) then
		if (getTacticsData("modes","race","disable_weapons") == "true") then
			setControlState("vehicle_fire",false)
			setControlState("vehicle_secondary_fire",false)
		end
	end
end
function RaceMatch_onClientElementStreamIn()
	if (getElementType(source) == "vehicle" and getVehicleType(source) == "Helicopter") then
		setHelicopterRotorSpeed(source,0.2)
	end
end
function RaceMatch_onClientPlayerFinish(place)
	if (getRoundState() == "started") then
		setRoundHudComponent("timeleft",nil,tocolor(255,0,0))
		if (source == localPlayer) then
			finishMusic = playMusic("audio/music_gtasa.mp3")
		end
	end
end
function RaceMatch_onClientRoundFinish()
	if (finishMusic and isElement(finishMusic)) then stopSound(finishMusic) end
end
-- addEvent("onClientSetMapName",true)
addEvent("onClientPlayerFinish",true)
addEventHandler("onClientMapStarting",root,RaceMatch_onClientMapStarting)
addEventHandler("onClientMapStopping",root,RaceMatch_onClientMapStopping)
