--[[**************************************************************************
*
*  ПРОЕКТ:        TACTICS MODES
*  ВЕРСИЯ ДВИЖКА: 1.2-r18
*  РАЗРАБОТЧИКИ:  Александр Романов <lexr128@gmail.com>
*
****************************************************************************]]
function TeamDeathMatch_onClientMapStopping(mapinfo)
	if (mapinfo.modename ~= "arena") then return end
	showRoundHudComponent("timeleft",false)
	showRoundHudComponent("teamlist",false)
	removeEventHandler("onClientPlayerRoundSpawn",localPlayer,TeamDeathMatch_onClientPlayerRoundSpawn)
	removeCommandHandler("gun",toggleWeaponManager)
end
function TeamDeathMatch_onClientMapStarting(mapinfo)
	if (mapinfo.modename ~= "arena") then return end
	showPlayerHudComponent("ammo",true)
	showPlayerHudComponent("area_name",false)
	showPlayerHudComponent("armour",true)
	showPlayerHudComponent("breath",true)
	showPlayerHudComponent("clock",true)
	showPlayerHudComponent("health",true)
	showPlayerHudComponent("money",false)
	showPlayerHudComponent("radar",true)
	showPlayerHudComponent("vehicle_name",false)
	showPlayerHudComponent("weapon",true)
	showRoundHudComponent("timeleft",true)
	showRoundHudComponent("teamlist",true)
	addEventHandler("onClientPlayerRoundSpawn",localPlayer,TeamDeathMatch_onClientPlayerRoundSpawn)
	addCommandHandler("gun",toggleWeaponManager,false)
end
function TeamDeathMatch_onClientPlayerRoundSpawn()
	if (getRoundState() == "stopped") then setCameraPrepair() end
end
addEventHandler("onClientMapStarting",root,TeamDeathMatch_onClientMapStarting)
addEventHandler("onClientMapStopping",root,TeamDeathMatch_onClientMapStopping)
