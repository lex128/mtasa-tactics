local isDestructionDerby = false
local font1 = (0.015*yscreen)/9
local pickups = {}
function DestructionDerby_onClientMapStopping(mapinfo)
	if ((mapinfo.modename ~= "race" and mapinfo.modename ~= "derby") or not isDestructionDerby) then return end
	showRoundHudComponent("timeleft",false)
	showRoundHudComponent("race",false)
	removeEventHandler("onClientRender",root,DestructionDerby_onClientRender)
	removeEventHandler("onClientColShapeHit",root,DestructionDerby_onClientColShapeHit)
	removeEventHandler("onClientElementStreamIn",root,DestructionDerby_onClientElementStreamIn)
	unbindKey("vehicle_fire","down",DestructionDerby_disableVehicleWeapons)
	unbindKey("vehicle_secondary_fire","down",DestructionDerby_disableVehicleWeapons)
	setPedCanBeKnockedOffBike(localPlayer,true)
end
function DestructionDerby_onClientMapStarting(mapinfo)
	if ((mapinfo.modename ~= "race" and mapinfo.modename ~= "derby") or #getElementsByType("checkpoint",getRoundMapRoot()) > 0) then return end
	isDestructionDerby = true
	loadCustomObject(2221,"models/nitro.txd","models/nitro.dff")
	loadCustomObject(2222,"models/repair.txd","models/repair.dff")
	loadCustomObject(2223,"models/vehiclechange.txd","models/vehiclechange.dff")
	showRoundHudComponent("timeleft",true)
	setRoundHudComponent("race",true)
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
	addEventHandler("onClientRender",root,DestructionDerby_onClientRender)
	addEventHandler("onClientColShapeHit",root,DestructionDerby_onClientColShapeHit)
	addEventHandler("onClientElementStreamIn",root,DestructionDerby_onClientElementStreamIn)
	bindKey("vehicle_fire","down",DestructionDerby_disableVehicleWeapons)
	bindKey("vehicle_secondary_fire","down",DestructionDerby_disableVehicleWeapons)
	for _,racepickup in ipairs(getElementsByType("racepickup",getRoundMapRoot())) do
		setElementCollisionsEnabled(racepickup,false)
	end
end
function DestructionDerby_onClientColShapeHit(element,dimension)
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if (element == vehicle and getPlayerGameStatus(localPlayer) == "Play") then
		local marker = getElementParent(source)
		local parent = getElementParent(marker)
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
					setElementModel(vehicle,model)
					callServerFunction("setElementModel",vehicle,model)
					playSoundFrontEnd(46)
				end
			end
			triggerServerEvent("onPlayerPickUpRacePickup",localPlayer,source,type,vehicle)
		end
	end
end
function DestructionDerby_onClientRender()
	local angle = getTickCount()*0.1%360
	for _,racepickup in ipairs(getElementsByType("racepickup",getRoundMapRoot())) do
		if (racepickup and getElementType(racepickup) == "racepickup") then
			setElementRotation(racepickup,0,0,angle)
			local x,y,z = getElementPosition(racepickup)
			local x2,y2 = getScreenFromWorldPosition(x,y,z+1,0)
			if (x2) then
				if (getDistanceBetweenPoints3D(x,y,z,getCameraMatrix()) < 100) then
					local pickuptext = ""
					if (getElementData(racepickup,"type") == "vehiclechange") then
						local model = tonumber(getElementData(racepickup,"vehicle"))
						pickuptext = getVehicleNameFromModel(model).."\n"
					elseif (getElementData(racepickup,"type") == "repair") then
						-- pickuptext = "Repair\n"
					elseif (getElementData(racepickup,"type") == "nitro") then
						-- pickuptext = "Nitro\n"
					end
					local respawn = getElementData(racepickup,"respawn")
					if (respawn and tonumber(respawn) >= 1000) then
						pickuptext = pickuptext..""..string.format("(%.0f sec)",tonumber(respawn)/1000)
					end
					dxDrawText(pickuptext,x2 + 1,y2 + 1,x2 + 1,y2 + 1,blackC0,font1,"default","center","bottom")
					dxDrawText(pickuptext,x2,y2,x2,y2,whiteC0,font1,"default","center","bottom")
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
function DestructionDerby_disableVehicleWeapons()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if (vehicle and (getVehicleType(vehicle) == "Plane" or getVehicleType(vehicle) == "Helicopter")) then
		if (getRoundModeSettings("disable_weapons") == "true") then
			setControlState("vehicle_fire",false)
			setControlState("vehicle_secondary_fire",false)
		end
	end
end
function DestructionDerby_onClientElementStreamIn()
	if (getElementType(source) == "vehicle" and getVehicleType(source) == "Helicopter") then
		setHelicopterRotorSpeed(source,0.2)
	end
end
addEvent("onClientSetMapName",true)
addEventHandler("onClientMapStarting",root,DestructionDerby_onClientMapStarting)
addEventHandler("onClientMapStopping",root,DestructionDerby_onClientMapStopping)
