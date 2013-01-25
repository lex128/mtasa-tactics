--[[**************************************************************************
*
*  ПРОЕКТ:        TACTICS MODES
*  ВЕРСИЯ ДВИЖКА: 1.2-r18
*  РАЗРАБОТЧИКИ:  Александр Романов <lexr128@gmail.com>
*
****************************************************************************]]
function FlyMatch_onClientMapStopping(mapinfo)
	if (mapinfo.modename ~= "fly") then return end
	showRoundHudComponent("timeleft",false)
	showRoundHudComponent("teamlist",false)
	removeEventHandler("onClientPreRender",root,FlyMatch_onClientPreRender)
	removeEventHandler("onClientPlayerRoundSpawn",localPlayer,FlyMatch_onClientPlayerRoundSpawn)
end
function FlyMatch_onClientMapStarting(mapinfo)
	if (mapinfo.modename ~= "fly") then return end
	showRoundHudComponent("timeleft",true)
	showRoundHudComponent("teamlist",true)
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
	addEventHandler("onClientPreRender",root,FlyMatch_onClientPreRender)
	addEventHandler("onClientPlayerRoundSpawn",localPlayer,FlyMatch_onClientPlayerRoundSpawn)
end
function FlyMatch_onClientPlayerRoundSpawn()
	if (getRoundState() == "stopped") then setCameraPrepair(120) end
end
function FlyMatch_onClientPreRender()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if (vehicle) then
		local health = getElementHealth(vehicle)
		local pedhealth = (health-250)/7.5
		if (health <= 250) then pedhealth = 1 end
		if (not isVehicleBlown(vehicle) and health > 0) then
			setElementHealth(localPlayer,pedhealth)
		end
		if (isElementInWater(vehicle) and not isVehicleBlown(vehicle) and getVehicleType(vehicle) ~= "Boat" and getElementModel(vehicle) ~= 460 and getElementModel(vehicle) ~= 447 and getElementModel(vehicle) ~= 417 and getElementModel(vehicle) ~= 539) then
			blowVehicle(vehicle)
		end
	end
end
addEventHandler("onClientMapStarting",root,FlyMatch_onClientMapStarting)
addEventHandler("onClientMapStopping",root,FlyMatch_onClientMapStopping)
