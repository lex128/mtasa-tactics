local hostageTimer = false
function Hostage_onClientMapStopping(mapinfo)
	if (mapinfo.modename ~= "hostage") then return end
	if (isTimer(hostageTimer)) then killTimer(hostageTimer) end
	showRoundHudComponent("timeleft",false)
	showRoundHudComponent("teamlist",false)
	showRoundHudComponent("elementlist",false)
	removeEventHandler("onClientPlayerBlipUpdate",localPlayer,Hostage_onClientPlayerBlipUpdate)
	removeEventHandler("onClientPedDamage",root,Hostage_onClientPedDamage)
	removeEventHandler("onClientColShapeHit",root,Hostage_onClientColShapeHit)
	removeEventHandler("onClientPlayerRoundSpawn",localPlayer,Hostage_onClientPlayerRoundSpawn)
	removeCommandHandler("gun",toggleWeaponManager)
	if (guiGetVisible(weapon_window)) then
		guiSetVisible(weapon_window,false)
		if (isAllGuiHidden()) then showCursor(false) end
	end
	unbindKey("group_control_forwards","down",Hostage_onClientHostageControl)
	unbindKey("group_control_back","down",Hostage_onClientHostageControl)
end
function Hostage_onClientMapStarting(mapinfo)
	if (mapinfo.modename ~= "hostage") then return end
	showRoundHudComponent("timeleft",true)
	setRoundHudComponent("teamlist","images/health.png",function(team)
		local healths = 0
		for _,player in ipairs(getPlayersInTeam(team)) do
			if (getPlayerGameStatus(player) == "Play") then
				healths = healths + math.floor(getElementHealth(player)) + math.floor(getPedArmor(player))
			end
		end
		return healths
	end)
	showRoundHudComponent("teamlist",true)
	setRoundHudComponent("elementlist",function()
		local hostages = {}
		for i,ped in ipairs(getElementsByType("ped")) do
			if (getElementData(ped,"Hostage")) then table.insert(hostages,ped) end
		end
		return hostages
	end,function(elements,i)
		local r,g,b = 0,0,0
		if (getElementHealth(elements[i]) > 0) then r,g,b = 255,255,255 end
		return "images/player.png",r,g,b
	end)
	showRoundHudComponent("elementlist",true)
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
	hostageTimer = setTimer(Hostage_onClientHostageUpdate,1000,0)
	addEventHandler("onClientPlayerBlipUpdate",localPlayer,Hostage_onClientPlayerBlipUpdate)
	addEventHandler("onClientPedDamage",root,Hostage_onClientPedDamage)
	addEventHandler("onClientColShapeHit",root,Hostage_onClientColShapeHit)
	addEventHandler("onClientPlayerRoundSpawn",localPlayer,Hostage_onClientPlayerRoundSpawn)
	addCommandHandler("gun",toggleWeaponManager,false)
	bindKey("group_control_forwards","down",Hostage_onClientHostageControl)
	bindKey("group_control_back","down",Hostage_onClientHostageControl)
	for i,ped in ipairs(getElementsByType("ped")) do
		if (getElementData(ped,"Hostage")) then
			local blip = createBlipAttachedTo(ped,0,2,0,0,0,0,-1)
			setElementParent(blip,ped)
			setElementData(ped,"Blip",blip,false)
		end
	end
end
function Hostage_onClientPlayerRoundSpawn()
	if (getRoundState() == "stopped") then setCameraPrepair() end
end
function Hostage_onClientPlayerBlipUpdate()
	local myteam = getPlayerTeam(localPlayer)
	local hostages = getElementsByType("ped")
	local teamsides = getTacticsData("Teamsides")
	if (teamsides[myteam]%2 == 0 or myteam == getElementsByType("team")[1]) then
		for i,ped in ipairs(hostages) do
			local blip = getElementData(ped,"Blip")
			if (getElementData(ped,"Hostage") and blip) then
				setBlipIcon(blip,58)
			end
		end
	else
		for i,ped in ipairs(hostages) do
			local blip = getElementData(ped,"Blip")
			if (getElementData(ped,"Hostage") and blip) then
				setBlipIcon(blip,0)
				setBlipColor(blip,0,0,0,0)
			end
		end
	end
end
function Hostage_onClientPedDamage()
	if (getElementData(source,"Hostage") and getRoundModeSettings("hostagekill") == "false") then
		cancelEvent()
	end
end
function Hostage_onClientHostageUpdate()
	for i,hostage in ipairs(getElementsByType("ped")) do
		if (getElementData(hostage,"Hostage")) then
			local follow = getElementData(hostage,"Follow")
			if (follow) then
				local x,y,z = getElementPosition(follow)
				setPedLookAt(hostage,x,y,z,1000)
				local xpos,ypos,zpos = getElementPosition(hostage)
				local angle = getAngleBetweenPoints2D(xpos,ypos,x,y)
				setPedCameraRotation(hostage,0 - angle)
				local dist = getDistanceBetweenPoints2D(xpos,ypos,x,y)
				setPedControlState(hostage,"sprint",(dist > 10 and true) or false)
				setPedControlState(hostage,"walk",(dist < 5 and true) or false)
				if (dist > 3) then
					local xv,yv,zv = getElementVelocity(hostage)
					if (math.sqrt(xv*xv + yv*yv) < 0.09 and getPedControlState(hostage,"forwards")) then
						local rotation = math.rad(getPedRotation(hostage))
						if (isLineOfSightClear(xpos,ypos,zpos,xpos-math.sin(rotation),ypos+math.cos(rotation),zpos,true,true,false)) then
							setPedControlState(hostage,"jump",not getPedControlState(hostage,"jump"))
							setPedControlState(hostage,"left",false)
							setPedControlState(hostage,"right",false)
						elseif (isLineOfSightClear(xpos,ypos,zpos+2.5,xpos-math.sin(rotation),ypos+math.cos(rotation),zpos+2.5,true,true,false)) then
							setPedControlState(hostage,"jump",not getPedControlState(hostage,"jump"))
							setPedControlState(hostage,"left",false)
							setPedControlState(hostage,"right",false)
						else
							local hit,_,_,_,_,xnorm,ynorm = processLineOfSight(xpos,ypos,zpos,xpos-math.sin(rotation),ypos+math.cos(rotation),zpos,true,true,false)
							if (hit) then
								local rnorm = getAngleBetweenPoints2D(xnorm,ynorm,0,0)
								if (getAngleBetweenAngles2D(rnorm,angle) > 0) then
									setPedControlState(hostage,"left",false)
									setPedControlState(hostage,"right",true)
								else
									setPedControlState(hostage,"left",true)
									setPedControlState(hostage,"right",false)
								end
								setPedControlState(hostage,"jump",false)
							else
								setPedControlState(hostage,"left",false)
								setPedControlState(hostage,"right",false)
								setPedControlState(hostage,"jump",false)
							end
						end
					else
						setPedControlState(hostage,"left",false)
						setPedControlState(hostage,"right",false)
						setPedControlState(hostage,"jump",false)
					end
					setPedControlState(hostage,"forwards",true)
					setPedControlState(hostage,"backwards",false)
				elseif (dist < 1) then
					setPedControlState(hostage,"forwards",false)
					setPedControlState(hostage,"backwards",true)
					setPedControlState(hostage,"jump",false)
					setPedControlState(hostage,"left",false)
					setPedControlState(hostage,"right",false)
				else
					if (not getPedControlState(hostage,"forwards") and not getPedControlState(hostage,"backwards") and math.abs(getAngleBetweenAngles2D(getPedRotation(hostage),angle)) > 30) then
						setPedControlState(hostage,"forwards",true)
						setTimer(setPedControlState,50,1,hostage,"forwards",false)
					else
						setPedControlState(hostage,"forwards",false)
					end
					setPedControlState(hostage,"backwards",false)
					setPedControlState(hostage,"jump",false)
					setPedControlState(hostage,"left",false)
					setPedControlState(hostage,"right",false)
				end
			else
				setPedControlState(hostage,"sprint",false)
				setPedControlState(hostage,"walk",false)
				setPedControlState(hostage,"jump",false)
				setPedControlState(hostage,"forwards",false)
				setPedControlState(hostage,"backwards",false)
				setPedControlState(hostage,"left",false)
				setPedControlState(hostage,"right",false)
			end
		end
	end
end
function Hostage_onClientHostageControl(key)
	local target = getPedTarget(localPlayer)
	if (target and getElementType(target) == "ped" and getElementData(target,"Hostage")) then
		local x1,y1,z1 = getElementPosition(localPlayer)
		local x2,y2,z2 = getElementPosition(target)
		if (getDistanceBetweenPoints3D(x1,y1,z1,x2,y2,z2) > 10) then return end
		if (key == "group_control_forwards") then
			setElementData(target,"Follow",localPlayer)
		elseif (key == "group_control_back") then
			setElementData(target,"Follow",nil)
		end
	end
end
function Hostage_onClientColShapeHit(element,dimension)
	if (getElementData(source,"RescueVehicle") and getElementType(element) == "ped" and getElementData(element,"Hostage") and isElementSyncer(element)) then
		callServerFunction("Hostage_onHostageRescued",element)
	end
end
function Hostage_onClientPreviewMapCreating(modename,elements)
	if (modename ~= "hostage") then return end
	for _,data in ipairs(elements) do
		if (data[1] == "Rescue_Vehicle") then
			local marker = createMarker(tonumber(data[2].posX),tonumber(data[2].posY),tonumber(data[2].posZ),"cylinder",10,64,64,64,64)
			setElementParent(marker,source)
			setElementDimension(marker,10)
			local vehicle = createVehicle(427,tonumber(data[2].posX),tonumber(data[2].posY),tonumber(data[2].posZ),tonumber(data[2].rotX),tonumber(data[2].rotY),tonumber(data[2].rotZ))
			setElementParent(vehicle,source)
			setElementDimension(vehicle,10)
			local blip = createBlipAttachedTo(vehicle,51,2,255,40,0,255,-1)
			setElementParent(blip,source)
			setElementDimension(blip,10)
		end
		if (data[1] == "Hostage") then
			local ped = createPed(tonumber(data[2].model),tonumber(data[2].posX),tonumber(data[2].posY),tonumber(data[2].posZ),tonumber(data[2].rotation or data[2].rotZ))
			setElementParent(ped,source)
			setElementDimension(ped,10)
			local blip = createBlipAttachedTo(ped,58,2,255,40,0,255,-1)
			setElementParent(blip,source)
			setElementDimension(blip,10)
		end
	end
end
addEventHandler("onClientMapStarting",root,Hostage_onClientMapStarting)
addEventHandler("onClientMapStopping",root,Hostage_onClientMapStopping)
addEventHandler("onClientPreviewMapCreating",root,Hostage_onClientPreviewMapCreating)
