-- local armorbody = {}
local playerVIP = nil
function VeryImportantPerson_onClientMapStopping(mapinfo)
	if (mapinfo.modename ~= "vip") then return end
	showRoundHudComponent("timeleft",false)
	showRoundHudComponent("teamlist",false)
	unbindKey("enter_exit","down",VeryImportantPerson_enteringVip)
	removeEventHandler("onClientRoundStart",root,VeryImportantPerson_onClientRoundStart)
	-- removeEventHandler("onClientPreRender",root,VeryImportantPerson_onClientPreRender)
	removeEventHandler("onClientPlayerBlipUpdate",localPlayer,VeryImportantPerson_onClientPlayerBlipUpdate)
	removeEventHandler("onClientPlayerRoundSpawn",localPlayer,VeryImportantPerson_onClientPlayerRoundSpawn)
	removeEventHandler("onClientPedDamage",root,VeryImportantPerson_onClientPedDamage)
	removeEventHandler("onClientPlayerHeliKilled",root,VeryImportantPerson_onClientPlayerHeliKilled)
	removeCommandHandler("gun",onClientWeaponShow)
	if (guiGetVisible(weapon_window)) then
		guiSetVisible(weapon_window,false)
		if (isAllGuiHidden()) then showCursor(false) end
	end
	-- for player,object in pairs(armorbody) do
		-- if (object and isElement(object)) then
			-- detachElementFromBone(object)
			-- destroyElement(object)
		-- end
	-- end
	-- armorbody = {}
	playerVIP = nil
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
	addEventHandler("onClientRoundStart",root,VeryImportantPerson_onClientRoundStart)
	-- addEventHandler("onClientPreRender",root,VeryImportantPerson_onClientPreRender)
	addEventHandler("onClientPlayerBlipUpdate",localPlayer,VeryImportantPerson_onClientPlayerBlipUpdate)
	addEventHandler("onClientPlayerRoundSpawn",localPlayer,VeryImportantPerson_onClientPlayerRoundSpawn)
	addEventHandler("onClientPedDamage",root,VeryImportantPerson_onClientPedDamage)
	addEventHandler("onClientPlayerHeliKilled",root,VeryImportantPerson_onClientPlayerHeliKilled)
	addCommandHandler("gun",onClientWeaponShow,false)
end
function VeryImportantPerson_onClientRoundStart()
	playerVIP = getElementAttachedTo(getElementByID("BlipVIP"))
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
	if (playerVIP ~= localPlayer) then return end
	outputDebugString("VeryImportantPerson_enteringVip")
	setControlState("enter_exit",false)
	setControlState("enter_passenger",true)
end
-- function VeryImportantPerson_onClientPreRender()
	-- for i,player in ipairs(getElementsByType("player",root,true)) do
		-- if (playerVIP == player) then
			-- if (not isElement(armorbody[player])) then
				-- armorbody[player] = createObject(1242,0,0,0)
				-- setObjectScale(armorbody[player],1.55)
				-- setElementParent(armorbody[player],player)
				-- setElementInterior(armorbody[player],getElementInterior(player))
				-- attachElementToBone(armorbody[player],player,3,0,0.05,0.08,2,0,0)
			-- end
		-- elseif (isElement(armorbody[player])) then
			-- detachElementFromBone(armorbody[player])
			-- destroyElement(armorbody[player])
		-- end
	-- end
-- end
addEventHandler("onClientMapStarting",root,VeryImportantPerson_onClientMapStarting)
addEventHandler("onClientMapStopping",root,VeryImportantPerson_onClientMapStopping)
