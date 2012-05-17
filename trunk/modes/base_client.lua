function AttackDefend_onClientMapStopping(mapinfo)
	if (mapinfo.modename ~= "base") then return end
	showRoundHudComponent("timeleft",false)
	showRoundHudComponent("teamlist",false)
	removeEventHandler("onClientHUDRender",root,AttackDefend_onClientHUDRender)
	removeEventHandler("onClientColShapeLeave",root,AttackDefend_onClientColShapeLeave)
	removeEventHandler("onClientPlayerRoundSpawn",localPlayer,AttackDefend_onClientPlayerRoundSpawn)
	removeCommandHandler("car",AttackDefend_toggleVehicleManager)
	removeCommandHandler("gun",toggleWeaponManager)
	for i,colshape in ipairs(getElementsByType("colshape",getRoundMapRoot())) do
		if (getElementData(colshape,"Vehicling")) then destroyElement(colshape) end
	end
end
function AttackDefend_onClientMapStarting(mapinfo)
	if (mapinfo.modename ~= "base") then return end
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
	addEventHandler("onClientHUDRender",root,AttackDefend_onClientHUDRender)
	addEventHandler("onClientColShapeLeave",root,AttackDefend_onClientColShapeLeave)
	addEventHandler("onClientPlayerRoundSpawn",localPlayer,AttackDefend_onClientPlayerRoundSpawn)
	addCommandHandler("car",AttackDefend_toggleVehicleManager,false)
	addCommandHandler("gun",toggleWeaponManager,false)
	local sides = getTacticsData("Sides")
	for i,side in ipairs(sides) do
		if (i % 2 == 1) then
			local Teams = getElementsByType("Team"..i,getRoundMapRoot())
			if (#Teams > 0) then
				local xmax,xmin,ymax,ymin = -9000,9000,-9000,9000
				for j,point in ipairs(Teams) do
					local x,y = tonumber(getElementData(point,"posX")),tonumber(getElementData(point,"posY"))
					if (x > xmax) then xmax = x end
					if (x < xmin) then xmin = x end
					if (y > ymax) then ymax = y end
					if (y < ymin) then ymin = y end
				end
				local zone = {}
				local points = {}
				local xcenter = 0.5*(xmin + xmax)
				local ycenter = 0.5*(ymin + ymax)
				local radius = 50 + math.max(xmax - xmin,ymax - ymin)
				for angle = 0,20 do
					local x = xcenter - radius*math.sin(math.rad(angle*18))
					local y = ycenter + radius*math.cos(math.rad(angle*18))
					table.insert(zone,{x,y})
				end
				table.insert(points,xcenter)
				table.insert(points,ycenter)
				for j,point1 in ipairs(zone) do
					table.insert(points,point1[1])
					table.insert(points,point1[2])
				end
				createRadarPolyline(zone,0,128,0,255,true,12)
				local colshape = createColPolygon(unpack(points))
				setElementParent(colshape,getRoundMapDynamicRoot())
				setElementData(colshape,"Vehicling",true,false)
			end
		end
	end
end
function AttackDefend_onClientPlayerRoundSpawn()
	if (getRoundState() == "stopped") then setCameraPrepair() end
end
function AttackDefend_toggleVehicleManager(command,model)
	local sides = getTacticsData("Sides")
	for i,side in ipairs(sides) do
		if (i % 2 == 1 and side == getPlayerTeam(localPlayer)) then
			for j,colshape in ipairs(getElementsByType("colshape"),getRoundMapRoot()) do
				if (getElementData(colshape,"Vehicling") and isElementWithinColShape(localPlayer,colshape)) then
					toggleVehicleManager(command,model)
					return
				end
			end
		end
	end
end
function AttackDefend_onClientColShapeLeave(element,dimension)
	if (getElementData(source,"Vehicling") and element == localPlayer and guiGetVisible(vehicle_window)) then
		outputChatBox(getLangString('you_leave_vehcile_choice'),255,100,100)
		guiSetVisible(vehicle_window,false)
		if (isAllGuiHidden()) then showCursor(false) end
	end
end
function AttackDefend_onClientHUDRender()
	if (guiCheckBoxGetSelected(config_display_roundhud)) then
		local capture = getTacticsData("timecapture")
		if (capture) then
			local remaining = getTacticsData("Pause")
			local capturing = TimeToSec(getRoundModeSettings("capturing") or "0:20")
			if (remaining) then
				progress = capturing*1000 - capture
			else
				progress = capturing*1000 - (capture - (getTickCount() + addTickCount))
			end
			if (progress >= capturing*1000) then progress = capturing*1000 end
			dxDrawRectangle(xscreen*0.776,yscreen*0.173,xscreen*0.174,yscreen*0.04,tocolor(0,0,0))
			dxDrawRectangle(xscreen*0.780,yscreen*0.178,xscreen*0.166,yscreen*0.03,tocolor(128,64,0))
			dxDrawRectangle(xscreen*0.780,yscreen*0.178,xscreen*(0.166*progress/(capturing*1000)),yscreen*0.03,tocolor(255,128,0))
			dxDrawText(getLangString('base_capturing'),xscreen*0.863,yscreen*0.193,xscreen*0.863,yscreen*0.193,tocolor(0,0,0),getFont(1),"default-bold","center","center")
		end
	end
end
function AttackDefend_onClientPreviewMapCreating(modename,elements)
	if (modename ~= "base") then return end
	for _,data in ipairs(elements) do
		if (data[1] == "Central_Marker") then
			local marker = createMarker(tonumber(data[2].posX),tonumber(data[2].posY),tonumber(data[2].posZ),"cylinder",2,255,40,0,128)
			setElementParent(marker,source)
			setElementDimension(marker,10)
			local blip = createBlipAttachedTo(marker,19,2,255,40,0,255,-1)
			setElementParent(blip,source)
			setElementDimension(blip,10)
		end
	end
end
addEventHandler("onClientMapStarting",root,AttackDefend_onClientMapStarting)
addEventHandler("onClientMapStopping",root,AttackDefend_onClientMapStopping)
addEventHandler("onClientPreviewMapCreating",root,AttackDefend_onClientPreviewMapCreating)
