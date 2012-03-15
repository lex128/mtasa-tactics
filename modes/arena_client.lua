function TeamDeathMatch_onClientMapStopping(mapinfo)
	if (mapinfo.modename ~= "arena") then return end
	showRoundHudComponent("timeleft",false)
	showRoundHudComponent("teamlist",false)
	removeEventHandler("onClientPlayerRoundSpawn",localPlayer,TeamDeathMatch_onClientPlayerRoundSpawn)
	removeCommandHandler("gun",onClientWeaponShow)
	if (guiGetVisible(weapon_window)) then
		guiSetVisible(weapon_window,false)
		if (isAllGuiHidden()) then showCursor(false) end
	end
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
	addCommandHandler("gun",onClientWeaponShow,false)
end
function TeamDeathMatch_onClientPlayerRoundSpawn()
	if (getRoundState() == "stopped") then setCameraPrepair() end
end
addEventHandler("onClientMapStarting",root,TeamDeathMatch_onClientMapStarting)
addEventHandler("onClientMapStopping",root,TeamDeathMatch_onClientMapStopping)
