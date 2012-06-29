local rocket1,rocket2 = {},{}
local firePrimary = 0
local fireSecondary = 0
local targetSecondary = nil
local lockonSecondary = 0
function ProjectBang_onClientResourceStart()
	bang_window = guiCreateWindow(xscreen*0.5-160,yscreen*0.5-110,320,240,"Projectile Vehicles",false)
	guiWindowSetSizable(bang_window,false)
	guiSetVisible(bang_window,false)
	bang_vehicle = guiCreateGridList(0.02,0.1,0.45,0.7,true,bang_window)
	guiGridListSetSortingEnabled(bang_vehicle,false)
	guiGridListAddColumn(bang_vehicle,"Vehicle",0.8)
	for i,model in ipairs({429,541,415,480,562,565,559,561,560,506,558,477}) do
		local row = guiGridListAddRow(bang_vehicle)
		guiGridListSetItemText(bang_vehicle,row,1,getVehicleNameFromModel(model),false,false)
		guiGridListSetItemData(bang_vehicle,row,1,tostring(model))
	end
	bang_skill = guiCreateGridList(0.51,0.1,0.45,0.7,true,bang_window)
	guiGridListSetSortingEnabled(bang_skill,false)
	guiGridListAddColumn(bang_skill,"Skill",0.8)
	for i,skill in ipairs({"Hydraulics","Seeking Rocket","2 Fast Rockets","Quick Reload"}) do
		local row = guiGridListAddRow(bang_skill)
		guiGridListSetItemText(bang_skill,row,1,tostring(skill),false,false)
	end
	bang_accept = guiCreateButton(0.36,0.88,0.28,0.1,"Accept",true,bang_window)
	guiSetFont(bang_accept,"default-bold-small")
	guiSetProperty(bang_accept,"NormalTextColour","C000FF00")
end
function ProjectBang_onClientMapStopping(mapinfo)
	if (mapinfo.modename ~= "bang") then return end
	showRoundHudComponent("timeleft",false)
	showRoundHudComponent("teamlist",false)
	setRoundHudComponent("teamlist")
	removeEventHandler("onClientPreRender",root,ProjectBang_onClientPreRender)
	removeEventHandler("onClientHUDRender",root,ProjectBang_onClientHUDRender)
	removeEventHandler("onClientGUIClick",root,ProjectBang_onClientGUIClick)
	removeEventHandler("onClientExplosion",root,ProjectBang_onClientExplosion)
	removeEventHandler("onClientElementStreamIn",root,ProjectBang_onClientElementStreamIn)
	removeEventHandler("onClientPlayerRoundSpawn",localPlayer,ProjectBang_onClientPlayerRoundSpawn)
	unbindKey("vehicle_fire","down",ProjectBang_onClientFirePrimary)
	unbindKey("vehicle_secondary_fire","down",ProjectBang_onClientFireSecondary)
	unbindKey("q","down",ProjectBang_onClientSwitchSecondary)
	unbindKey("e","down",ProjectBang_onClientSwitchSecondary)
	unbindKey("b","down",ProjectBang_onClientVehicleShow)
	if (guiGetVisible(bang_window)) then
		guiSetVisible(bang_window,false)
		if (isAllGuiHidden()) then showCursor(false) end
	end
end
function ProjectBang_onClientMapStarting(mapinfo)
	if (mapinfo.modename ~= "bang") then return end
	showPlayerHudComponent("ammo",false)
	showPlayerHudComponent("area_name",false)
	showPlayerHudComponent("armour",false)
	showPlayerHudComponent("breath",true)
	showPlayerHudComponent("clock",true)
	showPlayerHudComponent("health",true)
	showPlayerHudComponent("money",false)
	showPlayerHudComponent("radar",true)
	showPlayerHudComponent("vehicle_name",false)
	showPlayerHudComponent("weapon",true)
	showRoundHudComponent("timeleft",true)
	setRoundHudComponent("teamlist","images/health.png",function(team)
		local healths = 0
		for _,player in ipairs(getPlayersInTeam(team)) do
			if (getPlayerGameStatus(player) == "Play") then
				healths = healths + math.floor(getElementHealth(player))
			end
		end
		return healths
	end)
	showRoundHudComponent("teamlist",true)
	addEventHandler("onClientPreRender",root,ProjectBang_onClientPreRender)
	addEventHandler("onClientHUDRender",root,ProjectBang_onClientHUDRender)
	addEventHandler("onClientGUIClick",root,ProjectBang_onClientGUIClick)
	addEventHandler("onClientExplosion",root,ProjectBang_onClientExplosion)
	addEventHandler("onClientElementStreamIn",root,ProjectBang_onClientElementStreamIn)
	addEventHandler("onClientPlayerRoundSpawn",localPlayer,ProjectBang_onClientPlayerRoundSpawn)
	bindKey("vehicle_fire","down",ProjectBang_onClientFirePrimary)
	bindKey("vehicle_secondary_fire","down",ProjectBang_onClientFireSecondary)
	bindKey("q","down",ProjectBang_onClientSwitchSecondary,-1)
	bindKey("e","down",ProjectBang_onClientSwitchSecondary,1)
	bindKey("b","down",ProjectBang_onClientVehicleShow)
	firePrimary = 0
	fireSecondary = 0
	targetSecondary = nil
	lockonSecondary = 0
end
function ProjectBang_onClientPlayerRoundSpawn()
	if (getRoundState() == "stopped") then setCameraPrepair() end
end
function ProjectBang_onClientElementStreamIn()
	if (getElementType(source) == "vehicle") then
		if (rocket1[source] and isElement(rocket1[source])) then destroyElement(rocket1[source]) end
		if (rocket2[source] and isElement(rocket2[source])) then destroyElement(rocket2[source]) end
		rocket1[source] = createObject(3786,0,0,0)
		rocket2[source] = createObject(3786,0,0,0)
		setElementParent(rocket1[source],source)
		setElementParent(rocket2[source],source)
		setElementCollisionsEnabled(rocket1[source],false)
		setElementCollisionsEnabled(rocket2[source],false)
		local minx,miny,minz,maxx,maxy,maxz = getElementBoundingBox(source)
		attachElements(rocket1[source],source,minx-0.1,0,0,0,0,270)
		attachElements(rocket2[source],source,maxx+0.1,0,0,0,0,270)
	end
end
function ProjectBang_onClientFirePrimary()
	if (getPlayerGameStatus(localPlayer) ~= "Play" or isCursorShowing() or firePrimary > 0) then return end
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if (not vehicle or isElementFrozen(vehicle)) then return end
	local xaim1,yaim1,zaim1 = getWorldFromScreenPosition(xscreen*0.5,yscreen*0.3,0)
	local xaim2,yaim2,zaim2 = getWorldFromScreenPosition(xscreen*0.5,yscreen*0.3,300)
	local hitaim,xaim,yaim,zaim = processLineOfSight(xaim1,yaim1,zaim1,xaim2,yaim2,zaim2)
	if (not hitaim) then xaim,yaim,zaim = xaim2,yaim2,zaim2 end
	local minx,miny,minz,maxx,maxy,maxz = getElementBoundingBox(vehicle)
	local vector = getElementVector(vehicle,minx - 0.1,0,0.5)
	local xrot = 90 + getAngleBetweenPoints2D(0,0,math.sqrt((vector[1] - xaim)^2 + (vector[2] - yaim)^2),vector[3] - zaim)
	local zrot = 0 - getAngleBetweenPoints2D(vector[1],vector[2],xaim,yaim)
	local xvel = 0.5*math.sin(math.rad(zrot))*math.abs(math.cos(math.rad(xrot)))
	local yvel = 0.5*math.cos(math.rad(zrot))*math.abs(math.cos(math.rad(xrot)))
	local zvel = -0.5*math.cos(math.rad(xrot - 90))
	createProjectile(vehicle,19,vector[1],vector[2],vector[3],1.0,nil,xrot,0,zrot,xvel,yvel,zvel)
	firePrimary = 2000
end
function ProjectBang_onClientFireSecondary()
	if (getPlayerGameStatus(localPlayer) ~= "Play" or isCursorShowing() or fireSecondary > 0) then return end
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if (not vehicle or isElementFrozen(vehicle)) then return end
	local secondaryname = getElementData(localPlayer,"ProjectBang_Skill")
	if (secondaryname == "Rocket") then
		local xaim1,yaim1,zaim1 = getWorldFromScreenPosition(xscreen*0.5,yscreen*0.3,0)
		local xaim2,yaim2,zaim2 = getWorldFromScreenPosition(xscreen*0.5,yscreen*0.3,300)
		local hitaim,xaim,yaim,zaim = processLineOfSight(xaim1,yaim1,zaim1,xaim2,yaim2,zaim2)
		if (not hitaim) then xaim,yaim,zaim = xaim2,yaim2,zaim2 end
		local minx,miny,minz,maxx,maxy,maxz = getElementBoundingBox(vehicle)
		local vector = getElementVector(vehicle,minx - 0.1,0,0.5)
		local xrot = 90 + getAngleBetweenPoints2D(0,0,math.sqrt((vector[1] - xaim)^2 + (vector[2] - yaim)^2),vector[3] - zaim)
		local zrot = 0 - getAngleBetweenPoints2D(vector[1],vector[2],xaim,yaim)
		local xvel = 0.5*math.sin(math.rad(zrot))*math.abs(math.cos(math.rad(xrot)))
		local yvel = 0.5*math.cos(math.rad(zrot))*math.abs(math.cos(math.rad(xrot)))
		local zvel = -0.5*math.cos(math.rad(xrot - 90))
		createProjectile(vehicle,19,vector[1],vector[2],vector[3],1.0,nil,xrot,0,zrot,xvel,yvel,zvel)
		fireSecondary = 2000
	elseif (secondaryname == "Hydraulics" and isVehicleOnGround(vehicle)) then
		local xvel,yvel,zvel = getElementVelocity(vehicle)
		setElementVelocity(vehicle,xvel,yvel,zvel + 0.5)
		fireSecondary = 10000
	end
	if (secondaryname == "Anti-Seeking Flare") then
		local xpos,ypos,zpos = getElementPosition(vehicle)
		local xvel,yvel,zvel = getElementVelocity(vehicle)
		createProjectile(vehicle,20,xpos,ypos,zpos + 1.5,1.0,nil,0,0,0,xvel,yvel,zvel + 0.5)
		fireSecondary = 10000
	end
	if (secondaryname == "Seeking Rocket") then
		if (targetSecondary and isElement(targetSecondary) and lockonSecondary == 0) then
			local xaim1,yaim1,zaim1 = getWorldFromScreenPosition(xscreen*0.5,yscreen*0.3,0)
			local xaim2,yaim2,zaim2 = getWorldFromScreenPosition(xscreen*0.5,yscreen*0.3,300)
			local hitaim,xaim,yaim,zaim = processLineOfSight(xaim1,yaim1,zaim1,xaim2,yaim2,zaim2)
			if (not hitaim) then xaim,yaim,zaim = xaim2,yaim2,zaim2 end
			local minx,miny,minz,maxx,maxy,maxz = getElementBoundingBox(vehicle)
			local vector = getElementVector(vehicle,maxx - 0.1,0,0.5)
			local xrot = 90 + getAngleBetweenPoints2D(0,0,math.sqrt((vector[1] - xaim)^2 + (vector[2] - yaim)^2),vector[3] - zaim)
			local zrot = 0 - getAngleBetweenPoints2D(vector[1],vector[2],xaim,yaim)
			local xvel = 0.5*math.sin(math.rad(zrot))*math.abs(math.cos(math.rad(xrot)))
			local yvel = 0.5*math.cos(math.rad(zrot))*math.abs(math.cos(math.rad(xrot)))
			local zvel = -0.5*math.cos(math.rad(xrot - 90))
			createProjectile(vehicle,20,vector[1],vector[2],vector[3],1.0,targetSecondary,xrot,0,zrot,xvel,yvel,zvel)
			fireSecondary = 10000
		end
	end
	if (secondaryname == "2 Fast Rockets") then
		local xaim1,yaim1,zaim1 = getWorldFromScreenPosition(xscreen*0.5,yscreen*0.3,0)
		local xaim2,yaim2,zaim2 = getWorldFromScreenPosition(xscreen*0.5,yscreen*0.3,300)
		local hitaim,xaim,yaim,zaim = processLineOfSight(xaim1,yaim1,zaim1,xaim2,yaim2,zaim2)
		if (not hitaim) then xaim,yaim,zaim = xaim2,yaim2,zaim2 end
		local minx,miny,minz,maxx,maxy,maxz = getElementBoundingBox(vehicle)
		local vector = getElementVector(vehicle,maxx - 0.1,0,0.5)
		local xrot = 90 + getAngleBetweenPoints2D(0,0,math.sqrt((vector[1] - xaim)^2 + (vector[2] - yaim)^2),vector[3] - zaim)
		local zrot = 0 - getAngleBetweenPoints2D(vector[1],vector[2],xaim,yaim)
		local xvel = 5*math.sin(math.rad(zrot))*math.abs(math.cos(math.rad(xrot)))
		local yvel = 5*math.cos(math.rad(zrot))*math.abs(math.cos(math.rad(xrot)))
		local zvel = -5*math.cos(math.rad(xrot - 90))
		createProjectile(vehicle,19,vector[1],vector[2],vector[3],1.0,nil,xrot,0,zrot,xvel,yvel,zvel)
		setTimer(createProjectile,100,1,vehicle,19,vector[1],vector[2],vector[3],1.0,nil,xrot,0,zrot,xvel,yvel,zvel)
		fireSecondary = 10000
	end
	if (secondaryname == "Quick Reload") then
		local xaim1,yaim1,zaim1 = getWorldFromScreenPosition(xscreen*0.5,yscreen*0.3,0)
		local xaim2,yaim2,zaim2 = getWorldFromScreenPosition(xscreen*0.5,yscreen*0.3,300)
		local hitaim,xaim,yaim,zaim = processLineOfSight(xaim1,yaim1,zaim1,xaim2,yaim2,zaim2)
		if (not hitaim) then xaim,yaim,zaim = xaim2,yaim2,zaim2 end
		local minx,miny,minz,maxx,maxy,maxz = getElementBoundingBox(vehicle)
		local vector = getElementVector(vehicle,maxx - 0.1,0,0.5)
		local xrot = 90 + getAngleBetweenPoints2D(0,0,math.sqrt((vector[1] - xaim)^2 + (vector[2] - yaim)^2),vector[3] - zaim)
		local zrot = 0 - getAngleBetweenPoints2D(vector[1],vector[2],xaim,yaim)
		local xvel = 0.5*math.sin(math.rad(zrot))*math.abs(math.cos(math.rad(xrot)))
		local yvel = 0.5*math.cos(math.rad(zrot))*math.abs(math.cos(math.rad(xrot)))
		local zvel = -0.5*math.cos(math.rad(xrot - 90))
		createProjectile(vehicle,19,vector[1],vector[2],vector[3],1.0,nil,xrot,0,zrot,xvel,yvel,zvel)
		fireSecondary = 2000
	end
end
function ProjectBang_onClientSwitchSecondary(key,state,switch)
	local vehicle = getPedOccupiedVehicle(localPlayer)
	local secondaryname = getElementData(localPlayer,"ProjectBang_Skill")
	if (secondaryname == "Seeking Rocket") then
		local current = 1
		local targets = {}
		for i,element in ipairs(getElementsByType("vehicle",root,true)) do
			if (element ~= vehicle and isElementOnScreen(element)) then
				table.insert(targets,element)
				if (targetSecondary == element) then current = #targets end
			end
		end
		lockonSecondary = 3000
		if (current + switch > 0 and targets[current + switch]) then
			targetSecondary = targets[current + switch]
		elseif (#targets > 0) then
			if (switch > 0) then
				targetSecondary = targets[1]
			else
				targetSecondary = targets[#targets]
			end
		end
	end
end
function ProjectBang_onClientHUDRender()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if (vehicle) then
		local health = getElementHealth(vehicle)
		local pedhealth = (health-250)/7.5
		if (health <= 250) then pedhealth = 1 end
		setElementHealth(localPlayer,pedhealth)
		if (getControlState("vehicle_fire")) then ProjectBang_onClientFirePrimary() end
		if (getControlState("vehicle_secondary_fire")) then ProjectBang_onClientFireSecondary() end
	end
end
function ProjectBang_onClientPreRender(frame)
	if (getPlayerGameStatus(localPlayer) == "Play") then
		local secondaryname = getElementData(localPlayer,"ProjectBang_Skill")
		firePrimary = math.max(0,firePrimary - frame*getGameSpeed())
		fireSecondary = math.max(0,fireSecondary - frame*getGameSpeed())
		lockonSecondary = math.max(0,lockonSecondary - frame*getGameSpeed())
		dxDrawRectangle(xscreen*0.776,yscreen*0.173,xscreen*0.174,yscreen*0.04,0xFF000000)
		dxDrawRectangle(xscreen*0.780,yscreen*0.178,xscreen*0.166,yscreen*0.03,0xFF804000)
		dxDrawRectangle(xscreen*0.780,yscreen*0.178,xscreen*(0.166*(2000-firePrimary)/2000),yscreen*0.03,0xFFFF8000)
		dxDrawText("Rocket",xscreen*0.863,yscreen*0.193,xscreen*0.863,yscreen*0.193,0xFF000000,getFont(1),"default-bold","center","center")
		if (secondaryname) then
			local reload = (secondaryname == "Quick Reload" and 2000) or 10000
			dxDrawRectangle(xscreen*0.776,yscreen*0.218,xscreen*0.174,yscreen*0.04,0xFF000000)
			dxDrawRectangle(xscreen*0.780,yscreen*0.223,xscreen*0.166,yscreen*0.03,0xFF408000)
			dxDrawRectangle(xscreen*0.780,yscreen*0.223,xscreen*(0.166*(reload-fireSecondary)/reload),yscreen*0.03,0xFF80FF00)
			dxDrawText(secondaryname,xscreen*0.863,yscreen*0.238,xscreen*0.863,yscreen*0.238,0xFF000000,getFont(1),"default-bold","center","center")
		end
		if (secondaryname == "Seeking Rocket") then
			if (not targetSecondary or not isElement(targetSecondary) or not isElementOnScreen(targetSecondary)) then
				local targets = {}
				local vehicle = getPedOccupiedVehicle(localPlayer)
				for i,element in ipairs(getElementsByType("vehicle",root,true)) do
					if (element ~= vehicle and isElementOnScreen(element)) then
						table.insert(targets,element)
					end
				end
				if (targets[1]) then
					lockonSecondary = 3000
					targetSecondary = targets[1]
				end
			else
				local xpos,ypos,zpos = getElementPosition(targetSecondary)
				local xaim,yaim = getScreenFromWorldPosition(xpos,ypos,zpos)
				local rotation = 0.36*(getTickCount() % 1000)
				if (lockonSecondary > 0) then
					if (xaim) then
						dxDrawImage(xaim - xscreen*0.036,yaim - xscreen*0.036,xscreen*0.072,xscreen*0.072,"images/aim_lockon.png")
						dxDrawImage(xaim - xscreen*0.018,yaim - xscreen*0.018,xscreen*0.036,xscreen*0.036,"images/aim_lockon2.png",rotation)
					end
				elseif (xaim) then
					dxDrawImage(xaim - xscreen*0.036,yaim - xscreen*0.036,xscreen*0.072,xscreen*0.072,"images/aim_lockon.png",0,0,0,0xFFFF0000)
					dxDrawImage(xaim - xscreen*0.018,yaim - xscreen*0.018,xscreen*0.036,xscreen*0.036,"images/aim_lockon2.png",rotation,0,0,0xFFFF0000)
				end
			end
		end
	end
	dxDrawImage(xscreen*0.5 - xscreen*0.036,yscreen*0.3 - yscreen*0.05125,xscreen*0.072,yscreen*0.1025,"images/aim_rocket.png")
end
function ProjectBang_onClientGUIClick(button,state,x,y)
	if (button ~= "left") then return end
	if (source == bang_accept) then
		guiSetVisible(bang_window,false)
		if (isAllGuiHidden()) then showCursor(false) end
		if (not getElementData(localPlayer,"Weapons")) then
			return outputChatBox(getLanguageString('weapon_choice_disabled'),255,100,100)
		end
		local select = guiGridListGetSelectedItem(bang_vehicle)
		local vehicle = (select ~= -1 and tonumber(guiGridListGetItemData(bang_vehicle,select,1))) or nil
		select = guiGridListGetSelectedItem(bang_skill)
		local skill = (select ~= -1 and guiGridListGetItemText(bang_skill,select,1)) or nil
		callServerFunction("ProjectBang_onPlayerVehicleChoose",localPlayer,vehicle,skill)
	end
end
function ProjectBang_toggleVehicleManager(force)
	if (not force) then
		guiSetVisible(bang_window,true)
		showCursor(true)
	else
		local select = guiGridListGetSelectedItem(bang_vehicle)
		local vehicle = (select ~= -1 and tonumber(guiGridListGetItemData(bang_vehicle,select,1))) or nil
		select = guiGridListGetSelectedItem(bang_skill)
		local skill = (select ~= -1 and guiGridListGetItemText(bang_skill,select,1)) or nil
		callServerFunction("ProjectBang_onPlayerVehicleChoose",localPlayer,vehicle,skill)
	end
end
function ProjectBang_onClientVehicleShow()
	guiSetVisible(bang_window,true)
	showCursor(true)
end
function ProjectBang_onClientExplosion(x,y,z,type)
	if (getElementType(source) == "player") then
		local myvehicle = getPedOccupiedVehicle(localPlayer)
		if (myvehicle) then
			local team = getPlayerTeam(source)
			local myteam = getPlayerTeam(localPlayer)
			if (team ~= myteam or getTeamFriendlyFire(team) or source == localPlayer) then
				local xpos,ypos,zpos = getElementPosition(myvehicle)
				local loss = 83.0*((16 - math.min(getDistanceBetweenPoints3D(xpos,ypos,zpos,x,y,z),16))/16)
				if (loss > 0) then
					triggerServerEvent("ProjectBang_onVehicleDamage",myvehicle,source,loss)
				end
			end
		end
	end
end
addEventHandler("onClientMapStarting",root,ProjectBang_onClientMapStarting)
addEventHandler("onClientMapStopping",root,ProjectBang_onClientMapStopping)
addEventHandler("onClientResourceStart",resourceRoot,ProjectBang_onClientResourceStart)
