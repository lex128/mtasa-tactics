function Lobby_onClientMapStopping(mapinfo)
	if (mapinfo.modename ~= "lobby") then return end
	removeCommandHandler("car",toggleVehicleManager)
	removeCommandHandler("gun",toggleWeaponManager)
end
function Lobby_onClientMapStarting(mapinfo)
	if (mapinfo.modename ~= "lobby") then return end
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
	if (getRoundModeSettings("car") == "true") then
		addCommandHandler("car",toggleVehicleManager,false)
	end
	if (getRoundModeSettings("gun") == "true") then
		addCommandHandler("gun",toggleWeaponManager,false)
	end
end
addEventHandler("onClientMapStarting",root,Lobby_onClientMapStarting)
addEventHandler("onClientMapStopping",root,Lobby_onClientMapStopping)
