function CaptureTheFlag_onClientMapStopping(mapinfo)
	if (mapinfo.modename ~= "ctf") then return end
	removeEventHandler("onClientElementColShapeHit",localPlayer,CaptureTheFlag_onClientElementColShapeHit)
	removeEventHandler("onClientPlayerRoundSpawn",localPlayer,CaptureTheFlag_onClientPlayerRoundSpawn)
	removeEventHandler("onClientPlayerBlipUpdate",localPlayer,CaptureTheFlag_onClientPlayerBlipUpdate)
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
	setRoundHudComponent("teamlist","images/flag.png",function(team) return tostring(getElementData(team,"Capture")) end)
	showRoundHudComponent("teamlist",true)
	addEventHandler("onClientElementColShapeHit",localPlayer,CaptureTheFlag_onClientElementColShapeHit)
	addEventHandler("onClientPlayerRoundSpawn",localPlayer,CaptureTheFlag_onClientPlayerRoundSpawn)
	addEventHandler("onClientPlayerBlipUpdate",localPlayer,CaptureTheFlag_onClientPlayerBlipUpdate)
	addCommandHandler("gun",onClientWeaponShow,false)
	for i,mark in ipairs(getElementsByType("marker")) do
		if (getElementData(mark,"Team")) then
			local x,y,z = getElementPosition(mark)
			local colshape = createColTube(x,y,z - 2,3,4)
			setElementParent(colshape,mark)
			setElementData(mark,"Colshape",colshape,false)
		end
	end
end
function CaptureTheFlag_onClientPlayerRoundSpawn()
	if (getRoundState() == "stopped") then setCameraPrepair() end
end
function CaptureTheFlag_onClientElementStreamIn()
	if (getElementType(source) ~= "marker" or isElementAttached(marker)) then return end
	local colshape = getElementData(source,"Colshape")
	if (not isElement(colshape)) then
		local x,y,z = getElementPosition(source)
		colshape = createColTube(x,y,z - 2,3,4)
		setElementParent(colshape,source)
		setElementData(source,"Colshape",colshape,false)
	end
end
function CaptureTheFlag_onClientElementColShapeHit(colshape,dimension)
	if (not isElement(colshape)) then return end
	local marker = getElementParent(colshape)
	if (not marker or isElementAttached(marker) or getPlayerGameStatus(source) ~= "Play") then return end
	callServerFunction("CaptureTheFlag_onElementFlagHit",marker,source)
end
function CaptureTheFlag_onClientFlagPickup(element,x,y,z)
	local colshape = getElementData(element,"Colshape")
	if (isElement(colshape)) then
		destroyElement(colshape)
		setElementData(element,"Colshape",nil,false)
	end
	triggerEvent("onClientPlayerBlipUpdate",localPlayer)
end
function CaptureTheFlag_onClientFlagDrop(element,x,y,z)
	local colshape = getElementData(element,"Colshape")
	if (isElement(colshape)) then
		setElementPosition(colshape,x,y,z - 1)
	else
		colshape = createColTube(x,y,z - 1,3,4)
		setElementParent(colshape,element)
		setElementData(element,"Colshape",colshape,false)
	end
	triggerEvent("onClientPlayerBlipUpdate",localPlayer)
end
function CaptureTheFlag_stolenFlag(team,myteam)
	if (myteam == getPlayerTeam(localPlayer)) then
		playVoice("audio/enemy_flag_stolen.mp3")
	elseif (team == getPlayerTeam(localPlayer)) then
		playVoice("audio/your_flag_stolen.mp3")
	end
	triggerEvent("onClientPlayerBlipUpdate",localPlayer)
end
function CaptureTheFlag_returnFlag(team)
	if (team == getPlayerTeam(localPlayer)) then
		playVoice("audio/your_flag_returned.mp3")
	else
		playVoice("audio/enemy_flag_returned.mp3")
	end
	triggerEvent("onClientPlayerBlipUpdate",localPlayer)
end
function CaptureTheFlag_captureFlag(team)
	if (team == getPlayerTeam(localPlayer)) then
		playVoice("audio/your_capture_flag.mp3")
	else
		playVoice("audio/enemy_capture_flag.mp3")
	end
	triggerEvent("onClientPlayerBlipUpdate",localPlayer)
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
				setBlipIcon(blip,19)
				setBlipColor(blip,255,255,255,255)
			else
				setBlipIcon(blip,0)
				setBlipColor(blip,0,0,0,0)
			end
		end
	end
end
addEventHandler("onClientMapStarting",root,CaptureTheFlag_onClientMapStarting)
addEventHandler("onClientMapStopping",root,CaptureTheFlag_onClientMapStopping)
addEventHandler("onClientPreviewMapCreating",root,CaptureTheFlag_onClientPreviewMapCreating)
