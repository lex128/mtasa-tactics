--[[**************************************************************************
*
*  ПРОЕКТ:        TACTICS MODES
*  ВЕРСИЯ ДВИЖКА: 1.2-r18
*  РАЗРАБОТЧИКИ:  Александр Романов <lexr128@gmail.com>
*
****************************************************************************]]
function DeathMatch_onClientMapStopping(mapinfo)
	if (mapinfo.modename ~= "dm") then return end
	showRoundHudComponent("timeleft",false)
	showRoundHudComponent("playerlist",false)
	removeEventHandler("onClientPlayerRoundSpawn",localPlayer,DeathMatch_onClientPlayerRoundSpawn)
	removeCommandHandler("gun",toggleWeaponManager)
	if (guiGetVisible(weapon_window)) then
		guiSetVisible(weapon_window,false)
		if (isAllGuiHidden()) then showCursor(false) end
	end
end
function DeathMatch_onClientMapStarting(mapinfo)
	if (mapinfo.modename ~= "dm") then return end
	showRoundHudComponent("timeleft",true)
	setRoundHudComponent("playerlist","images/frag.png",function(ped) return tonumber(getElementData(ped,"Frags")) or 0 end,true)
	showRoundHudComponent("playerlist",true)
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
	addEventHandler("onClientPlayerRoundSpawn",localPlayer,DeathMatch_onClientPlayerRoundSpawn)
	addCommandHandler("gun",toggleWeaponManager,false)
end
function DeathMatch_onClientPlayerRoundSpawn()
	if (getRoundState() == "stopped") then setCameraPrepair() end
end
addEventHandler("onClientMapStarting",root,DeathMatch_onClientMapStarting)
addEventHandler("onClientMapStopping",root,DeathMatch_onClientMapStopping)
