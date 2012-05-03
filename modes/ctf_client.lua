function CaptureTheFlag_onClientMapStopping(mapinfo)
	if (mapinfo.modename ~= "ctf") then return end
	removeEventHandler("onClientPlayerRoundSpawn",localPlayer,CaptureTheFlag_onClientPlayerRoundSpawn)
	removeEventHandler("onClientPlayerBlipUpdate",localPlayer,CaptureTheFlag_onClientPlayerBlipUpdate)
	removeEventHandler("onClientFlagDrop",root,CaptureTheFlag_onClientFlagDrop)
	removeEventHandler("onClientFlagPickup",root,CaptureTheFlag_onClientFlagPickup)
	removeEventHandler("onClientFlagReturn",root,CaptureTheFlag_onClientFlagReturn)
	removeEventHandler("onClientFlagCapture",root,CaptureTheFlag_onClientFlagCapture)
	showRoundHudComponent("timeleft",false)
	showRoundHudComponent("teamlist",false)
	setRoundHudComponent("teamlist")
	removeCommandHandler("gun",onClientWeaponShow)
end
function CaptureTheFlag_onClientMapStarting(mapinfo)
	if (mapinfo.modename ~= "ctf") then return end
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
	setRoundHudComponent("teamlist",
		function(team)
			return (getElementData(team,"IsStolen") and "images/question.png") or "images/flag.png"
		end,
		function(team)
			return tostring(getElementData(team,"Capture"))
		end
	)
	showRoundHudComponent("teamlist",true)
	addEventHandler("onClientPlayerRoundSpawn",localPlayer,CaptureTheFlag_onClientPlayerRoundSpawn)
	addEventHandler("onClientPlayerBlipUpdate",localPlayer,CaptureTheFlag_onClientPlayerBlipUpdate)
	addEventHandler("onClientFlagDrop",root,CaptureTheFlag_onClientFlagDrop)
	addEventHandler("onClientFlagPickup",root,CaptureTheFlag_onClientFlagPickup)
	addEventHandler("onClientFlagReturn",root,CaptureTheFlag_onClientFlagReturn)
	addEventHandler("onClientFlagCapture",root,CaptureTheFlag_onClientFlagCapture)
	addCommandHandler("gun",onClientWeaponShow,false)
end
function CaptureTheFlag_onClientPlayerRoundSpawn()
	if (getRoundState() == "stopped") then setCameraPrepair() end
end
function CaptureTheFlag_onClientFlagPickup(player,isStolen)
	if (isStolen) then
		local team = getElementData(source,"Team")
		local pteam = getPlayerTeam(player)
		if (pteam == getPlayerTeam(localPlayer)) then
			playVoice("audio/enemy_flag_stolen.mp3")
		elseif (team == getPlayerTeam(localPlayer)) then
			playVoice("audio/your_flag_stolen.mp3")
		end
	end
	triggerEvent("onClientPlayerBlipUpdate",source)
end
function CaptureTheFlag_onClientFlagDrop(player)
	triggerEvent("onClientPlayerBlipUpdate",source)
end
function CaptureTheFlag_onClientFlagReturn(player,x,y,z)
	local r,g,b = getMarkerColor(source)
	fxAddGlass(x,y,z - 1,r,g,b,128,0.2,10)
	if (player == getPlayerTeam(localPlayer) or getPlayerTeam(player) == getPlayerTeam(localPlayer)) then
		playVoice("audio/your_flag_returned.mp3")
	else
		playVoice("audio/enemy_flag_returned.mp3")
	end
	triggerEvent("onClientPlayerBlipUpdate",source)
end
function CaptureTheFlag_onClientFlagCapture(player,x,y,z)
	local r,g,b = getMarkerColor(source)
	fxAddGlass(x,y,z - 1,r,g,b,128,0.2,10)
	local team = getPlayerTeam(player)
	if (team == getPlayerTeam(localPlayer)) then
		playVoice("audio/your_capture_flag.mp3")
	else
		playVoice("audio/enemy_capture_flag.mp3")
	end
	triggerEvent("onClientPlayerBlipUpdate",source)
end
function CaptureTheFlag_onClientPreviewMapCreating(modename,elements)
	if (modename ~= "ctf") then return end
	for _,data in ipairs(elements) do
		if (data[1] == "Flag1") then
			local marker = createMarker(tonumber(data[2].posX),tonumber(data[2].posY),tonumber(data[2].posZ),"checkpoint",1,128,0,0,255)
			setElementParent(marker,source)
			setElementDimension(marker,10)
			local flag = createMarker(tonumber(data[2].posX),tonumber(data[2].posY),tonumber(data[2].posZ),"arrow",1,128,0,0,255)
			setElementParent(flag,source)
			setElementDimension(flag,10)
			local blip = createBlipAttachedTo(marker,0,2,128,0,0,255,-1)
			setElementParent(blip,source)
			setElementDimension(blip,10)
		end
		if (data[1] == "Flag2") then
			local marker = createMarker(tonumber(data[2].posX),tonumber(data[2].posY),tonumber(data[2].posZ),"checkpoint",1,0,0,128,255)
			setElementParent(marker,source)
			setElementDimension(marker,10)
			local flag = createMarker(tonumber(data[2].posX),tonumber(data[2].posY),tonumber(data[2].posZ),"arrow",1,0,0,128,255)
			setElementParent(flag,source)
			setElementDimension(flag,10)
			local blip = createBlipAttachedTo(marker,0,2,0,0,128,255,-1)
			setElementParent(blip,source)
			setElementDimension(blip,10)
		end
	end
end
function CaptureTheFlag_onClientPlayerBlipUpdate()
	local myteam = getPlayerTeam(localPlayer)
	for i,marker in ipairs(getElementsByType("marker")) do
		local parent = getElementParent(marker)
		local blip = getElementData(marker,"Blip")
		local team = getElementData(marker,"Team")
		local base = getElementData(marker,"Base")
		local player = getElementAttachedTo(marker)
		local x1 = getElementPosition(parent)
		local x2 = getElementPosition(marker)
		if (parent and blip and team and base) then
			if (isElementWithinMarker(marker,base) or (player and getPlayerTeam(player) == myteam) or myteam == getElementsByType("team")[1]) then
				local r,g,b = getTeamColor(team)
				setBlipColor(blip,r/1.25,g/1.25,b/1.25,128)
			else
				setBlipColor(blip,0,0,0,0)
			end
		end
	end
end
addEvent("onClientFlagDrop",true)
addEvent("onClientFlagPickup",true)
addEvent("onClientFlagReturn",true)
addEvent("onClientFlagCapture",true)
addEventHandler("onClientMapStarting",root,CaptureTheFlag_onClientMapStarting)
addEventHandler("onClientMapStopping",root,CaptureTheFlag_onClientMapStopping)
addEventHandler("onClientPreviewMapCreating",root,CaptureTheFlag_onClientPreviewMapCreating)
