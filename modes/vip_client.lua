function VeryImportantPerson_onClientMapStopping(mapinfo)
	if (mapinfo.modename ~= "vip") then return end
	showRoundHudComponent("timeleft",false)
	showRoundHudComponent("teamlist",false)
	unbindKey("enter_exit","down",VeryImportantPerson_enteringVip)
	removeEventHandler("onClientPlayerBlipUpdate",localPlayer,VeryImportantPerson_onClientPlayerBlipUpdate)
	removeEventHandler("onClientPlayerRoundSpawn",localPlayer,VeryImportantPerson_onClientPlayerRoundSpawn)
	removeEventHandler("onClientPedDamage",root,VeryImportantPerson_onClientPedDamage)
	removeEventHandler("onClientPlayerHeliKilled",root,VeryImportantPerson_onClientPlayerHeliKilled)
	removeCommandHandler("gun",onClientWeaponShow)
	if (guiGetVisible(weapon_window)) then
		guiSetVisible(weapon_window,false)
		if (isAllGuiHidden()) then showCursor(false) end
	end
end
function VeryImportantPerson_onClientMapStarting(mapinfo)
	if (mapinfo.modename ~= "vip") then return end
	showRoundHudComponent("timeleft",true)
	showRoundHudComponent("teamlist",true)
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
	bindKey("enter_exit","down",VeryImportantPerson_enteringVip)
	addEventHandler("onClientPlayerBlipUpdate",localPlayer,VeryImportantPerson_onClientPlayerBlipUpdate)
	addEventHandler("onClientPlayerRoundSpawn",localPlayer,VeryImportantPerson_onClientPlayerRoundSpawn)
	addEventHandler("onClientPedDamage",root,VeryImportantPerson_onClientPedDamage)
	addEventHandler("onClientPlayerHeliKilled",root,VeryImportantPerson_onClientPlayerHeliKilled)
	addCommandHandler("gun",onClientWeaponShow,false)
end
function VeryImportantPerson_onClientPlayerRoundSpawn()
	if (getRoundState() == "stopped") then setCameraPrepair() end
end
function VeryImportantPerson_onClientPlayerBlipUpdate()
	local myteam = getPlayerTeam(localPlayer)
	local blipVIP = getElementByID("BlipVIP")
	if (blipVIP) then
		if (myteam == getElementsByType("team")[1]) then
			setBlipIcon(blipVIP,60)
		else
			local teamsides = getTacticsData("Teamsides")
			if (teamsides[myteam] and teamsides[myteam]%2 == 1) then
				setBlipIcon(blipVIP,60)
			else
				setBlipIcon(blipVIP,0)
				setBlipColor(blipVIP,0,0,0,0)
			end
		end
	end
end
function VeryImportantPerson_onClientPedDamage(attacker,weapon,bodypart,loss)
	local parent = getElementParent(source)
	if (parent and getElementType(parent) == "Rescue_VIP") then
		cancelEvent()
	end
end
function VeryImportantPerson_onClientPlayerHeliKilled(vehicle)
	local parent = getElementParent(vehicle)
	if (parent and getElementType(parent) == "Rescue_VIP") then
		cancelEvent()
	end
end
function VeryImportantPerson_enteringVip()
	local blip = getElementByID("BlipVIP")
	if (not blip) then return end
	local playerVIP = getElementAttachedTo(blip)
	if (playerVIP ~= localPlayer) then return end
	outputDebugString("VeryImportantPerson_enteringVip")
	setControlState("enter_exit",false)
	setControlState("enter_passenger",true)
end
addEventHandler("onClientMapStarting",root,VeryImportantPerson_onClientMapStarting)
addEventHandler("onClientMapStopping",root,VeryImportantPerson_onClientMapStopping)
