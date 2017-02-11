--[[**************************************************************************
*
*  ПРОЕКТ:        TACTICS MODES
*  ВЕРСИЯ ДВИЖКА: 1.2-r18
*  РАЗРАБОТЧИКИ:  Александр Романов <lexr128@gmail.com>
*
****************************************************************************]]
function ControlPoints_onClientMapStopping(mapinfo)
	if (mapinfo.modename ~= "cp") then return end
	showRoundHudComponent("timeleft",false)
	showRoundHudComponent("teamlist",false)
	removeEventHandler("onClientRender",root,ControlPoints_onClientRender)
	removeEventHandler("onClientPlayerRoundSpawn",localPlayer,ControlPoints_onClientPlayerRoundSpawn)
	removeCommandHandler("gun",toggleWeaponManager)
end
function ControlPoints_onClientMapStarting(mapinfo)
	if (mapinfo.modename ~= "cp") then return end
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
	addEventHandler("onClientRender",root,ControlPoints_onClientRender)
	addEventHandler("onClientPlayerRoundSpawn",localPlayer,ControlPoints_onClientPlayerRoundSpawn)
	addCommandHandler("gun",toggleWeaponManager,false)
end
function ControlPoints_onClientPlayerRoundSpawn()
	if (getRoundState() == "stopped") then setCameraPrepair() end
end
function ControlPoints_onClientRender()
	if (guiCheckBoxGetSelected(config_performance_roundhud)) then
		local ypos = 0
		for i,basepoint in ipairs(getElementsByType("Capture_Point")) do
			local capture = getElementData(basepoint,"Capture")
			if (capture) then
				local remaining,capturing,team,block = unpack(capture)
				if (isRoundPaused() or block == true) then
					progress = capturing*1000 - remaining
				else
					progress = capturing*1000 - (remaining - (getTickCount() + addTickCount))
				end
				if (progress >= capturing*1000) then progress = capturing*1000 end
				local r,g,b = 255,255,255
				local rb,gb,bb = getTeamColor(team)
				if (not block) then
					r,g,b = rb,gb,bb
				else
					local blink = 2*math.abs(0.5 - getTickCount()%1000/1000)
					r,g,b = rb+blink*(r-rb),gb+blink*(g-gb),bb+blink*(b-bb)
				end
				dxDrawRectangle(xscreen*0.776,yscreen*0.173 + ypos,xscreen*0.174,yscreen*0.04,tocolor(0,0,0))
				dxDrawRectangle(xscreen*0.780,yscreen*0.178 + ypos,xscreen*0.166,yscreen*0.03,tocolor(rb/2,gb/2,bb/2))
				dxDrawRectangle(xscreen*0.780,yscreen*0.178 + ypos,xscreen*(0.166*progress/(capturing*1000)),yscreen*0.03,tocolor(r,g,b))
				dxDrawText(getLanguageString('base_capturing'),xscreen*0.863,yscreen*0.193 + ypos,xscreen*0.863,yscreen*0.193 + ypos,tocolor(0,0,0),getFont(1),"default-bold","center","center")
				ypos = ypos + yscreen*0.05
			end
		end
	end
end
function ControlPoints_onClientPreviewMapCreating(modename,elements)
	if (modename ~= "cp") then return end
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
addEventHandler("onClientMapStarting",root,ControlPoints_onClientMapStarting)
addEventHandler("onClientMapStopping",root,ControlPoints_onClientMapStopping)
addEventHandler("onClientPreviewMapCreating",root,ControlPoints_onClientPreviewMapCreating)
