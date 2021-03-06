--[[**************************************************************************
*
*  ПРОЕКТ:        TACTICS MODES
*  ВЕРСИЯ ДВИЖКА: 1.2-r18
*  РАЗРАБОТЧИКИ:  Александр Романов <lexr128@gmail.com>
*
****************************************************************************]]
local dynamites = {}
-- local dynamitebag = {}
function BombMatch_onClientMapStopping(mapinfo)
	if (mapinfo.modename ~= "bomb") then return end
	showRoundHudComponent("timeleft",false)
	showRoundHudComponent("teamlist",false)
	unbindKey("fire","both",BombMatch_onBombingToggle)
	removeEventHandler("onClientPreRender",root,BombMatch_onClientPreRender)
	removeEventHandler("onClientHUDRender",root,BombMatch_onClientHUDRender)
	removeEventHandler("onClientElementColShapeHit",localPlayer,BombMatch_onClientElementColShapeHit)
	removeEventHandler("onClientElementColShapeLeave",localPlayer,BombMatch_onClientElementColShapeLeave)
	removeEventHandler("onClientElementStreamOut",root,BombMatch_onClientElementStreamOut)
	removeEventHandler("onClientPlayerBlipUpdate",localPlayer,BombMatch_onClientPlayerBlipUpdate)
	removeEventHandler("onClientPauseToggle",root,BombMatch_onClientPauseToggle)
	removeEventHandler("onClientPlayerRoundSpawn",localPlayer,BombMatch_onClientPlayerRoundSpawn)
	-- removeEventHandler("onClientPlayerDamage",localPlayer,BombMatch_onClientPlayerDamage)
	removeCommandHandler("gun",toggleWeaponManager)
	setElementData(localPlayer,"planting",nil,false)
	setElementData(localPlayer,"defusing",nil,false)
	for player,dynamite in pairs(dynamites) do
		if (dynamite and isElement(dynamite)) then
			detachElementFromBone(dynamite)
			destroyElement(dynamite)
		end
	end
	-- for player,dynamite in pairs(dynamitebag) do
		-- if (dynamite and isElement(dynamite)) then
			-- detachElementFromBone(dynamite)
			-- destroyElement(dynamite)
		-- end
	-- end
	dynamites = {}
	-- dynamitebag = {}
end
function BombMatch_onClientMapStarting(mapinfo)
	if (mapinfo.modename ~= "bomb") then return end
	loadCustomObject(322,"models/bomb.txd")
	loadCustomObject(2221,"models/dynamite.txd","models/dynamite.dff")
	if (getElementByID("BombActive")) then
		setRoundHudComponent("timeleft","BOMB",255,0,0)
	end
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
	addEventHandler("onClientPreRender",root,BombMatch_onClientPreRender)
	addEventHandler("onClientHUDRender",root,BombMatch_onClientHUDRender)
	addEventHandler("onClientElementColShapeHit",localPlayer,BombMatch_onClientElementColShapeHit)
	addEventHandler("onClientElementColShapeLeave",localPlayer,BombMatch_onClientElementColShapeLeave)
	addEventHandler("onClientElementStreamOut",root,BombMatch_onClientElementStreamOut)
	addEventHandler("onClientPlayerBlipUpdate",localPlayer,BombMatch_onClientPlayerBlipUpdate)
	addEventHandler("onClientPauseToggle",root,BombMatch_onClientPauseToggle)
	addEventHandler("onClientPlayerRoundSpawn",localPlayer,BombMatch_onClientPlayerRoundSpawn)
	-- addEventHandler("onClientPlayerDamage",localPlayer,BombMatch_onClientPlayerDamage)
	addCommandHandler("gun",toggleWeaponManager,false)
	bindKey("fire","both",BombMatch_onBombingToggle)
	setElementData(localPlayer,"planting",nil,false)
	setElementData(localPlayer,"defusing",nil,false)
end
function BombMatch_onClientPlayerRoundSpawn()
	if (getRoundState() == "stopped") then setCameraPrepair() end
end
function BombMatch_onBombingToggle(key,state)
	if (state == "up") then
		toggleBombing = false
	elseif (getPedWeapon(localPlayer) == 0 or getPedWeapon(localPlayer) == 11) then
		toggleBombing = true
		if (isRoundPaused()) then return end
		local bombplanting = TimeToSec(getRoundModeSettings("planting") or "0:05")
		local bombdefusing = TimeToSec(getRoundModeSettings("defusing") or "0:10")
		local teamsides = getTacticsData("Teamsides")
		local team = getPlayerTeam(localPlayer)
		if (not teamsides[team]) then return end
		local xv,yv,zy = getElementVelocity(localPlayer)
		local speed = math.sqrt(xv^2+yv^2+zy^2)
		if (teamsides[team]%2 == 1 and getPedWeapon(localPlayer) == 11) then
			setControlState("fire",false)
			if (not getElementByID("BombActive") and speed < 0.1) then
				for i,colshape in ipairs(getElementsByType("colshape")) do
					if (getElementID(colshape) == "Bomb_Place" and isElementWithinColShape(localPlayer,colshape)) then
						setPedAnimation(localPlayer,"BOMBER","BOM_Plant_Loop",-1,true,false,false)
						setElementData(localPlayer,"planting",getTickCount() + bombplanting*1000,false)
						callServerFunction("setPedAnimation",localPlayer,"BOMBER","BOM_Plant_Loop",-1,true,false,false)
						break
					end
				end
			end
		elseif (teamsides[team]%2 == 0) then
			if (getElementByID("BombColshape") and getElementByID("BombActive") and getPedWeapon(localPlayer) == 0 and speed < 0.1) then
				if (isElementWithinColShape(localPlayer,getElementByID("BombColshape"))) then
					setControlState("fire",false)
					setElementData(localPlayer,"defusing",getTickCount() + bombdefusing*1000,false)
					callServerFunction("setPedAnimation",localPlayer,"BOMBER","BOM_Plant_Loop",-1,true,false,false)
					local x,y = getElementPosition(localPlayer)
					setPedRotation(localPlayer,getAngleBetweenPoints2D(x,y,getElementPosition(getElementByID("Bomb"))))
				end
			end
		end
	end
end
function BombMatch_onClientPreRender(frametick)
	for i,player in ipairs(getElementsByType("player",root,true)) do
		if (getPedWeapon(player) == 11) then
			if (not isElement(dynamites[player])) then
				dynamites[player] = createObject(2221,0,0,0)
				setElementParent(dynamites[player],player)
				setElementInterior(dynamites[player],getElementInterior(player))
				attachElementToBone(dynamites[player],player,12,0,0,0.1,0,-90,0)
			end
		elseif (isElement(dynamites[player])) then
			detachElementFromBone(dynamites[player])
			destroyElement(dynamites[player])
		end
		-- if (getPedWeapon(player,10) == 11) then
			-- if (not isElement(dynamitebag[player])) then
				-- dynamitebag[player] = createObject(1310,0,0,0)
				-- setObjectScale(dynamitebag[player],0.8)
				-- setElementParent(dynamitebag[player],player)
				-- setElementInterior(dynamitebag[player],getElementInterior(player))
				-- attachElementToBone(dynamitebag[player],player,3,0,-0.1,0,0,0,0)
			-- end
		-- elseif (isElement(dynamitebag[player])) then
			-- detachElementFromBone(dynamitebag[player])
			-- destroyElement(dynamitebag[player])
		-- end
	end
	local BombActive = getElementByID("BombActive")
	if (BombActive) then
		local sound = getElementData(BombActive,"BombSound")
		if (not sound) then
			setRoundHudComponent("timeleft","BOMB",255,0,0)
			local x,y,z = getElementPosition(BombActive)
			local time = getTacticsData("timeleft") - (getTickCount() + addTickCount)
			sound = playSound3D("audio/bomb_tick.mp3",x,y,z,true)
			setSoundMaxDistance(sound,50)
			setSoundMinDistance(sound,0)
			setSoundSpeed(sound,(time < 10000 and 1.5) or (time < 30000 and 1.25) or 1.0)
			attachElements(sound,BombActive)
			setElementParent(sound,BombActive)
			setElementData(BombActive,"BombSound",sound,false)
		elseif (getTacticsData("timeleft")) then
			local time = getTacticsData("timeleft") - (getTickCount() + addTickCount)
			setSoundSpeed(sound,(time < 10000 and 1.5) or (time < 30000 and 1.25) or 1.0)
		end
	end
end
function BombMatch_onClientHUDRender()
	local planting = getElementData(localPlayer,"planting")
	local defusing = getElementData(localPlayer,"defusing")
	if (planting) then
		local bombplanting = TimeToSec(getRoundModeSettings("planting") or "0:05")
		if (isRoundPaused()) then
			progress = bombplanting*1000 - planting
		else
			progress = bombplanting*1000 - (planting - getTickCount())
			if ((not toggleBombing or getRoundState() ~= "started" or getPlayerGameStatus(localPlayer) ~= "Play") and progress > 500) then
				setElementData(localPlayer,"planting",nil,false)
				if (getPedAnimation(localPlayer) == "bomber") then
					callServerFunction("setPedAnimation",localPlayer,"BOMBER","null")
				end
			end
			if (getPedAnimation(localPlayer) ~= "bomber") then
				setElementData(localPlayer,"planting",nil,false)
			end
		end
		if (progress >= bombplanting*1000) then
			progress = bombplanting*1000
			setElementData(localPlayer,"planting",nil,false)
			if (getPedAnimation(localPlayer) == "bomber") then
				callServerFunction("setPedAnimation",localPlayer,"BOMBER","null")
			end
			triggerServerEvent("onPlayerBombPlanted",localPlayer)
		end
		if (guiCheckBoxGetSelected(config_performance_roundhud)) then
			dxDrawRectangle(xscreen*0.776,yscreen*0.173,xscreen*0.174,yscreen*0.04,0xFF000000)
			dxDrawRectangle(xscreen*0.780,yscreen*0.178,xscreen*0.166,yscreen*0.03,tocolor(64,128,0))
			dxDrawRectangle(xscreen*0.780,yscreen*0.178,xscreen*(0.166*progress/(bombplanting*1000)),yscreen*0.03,tocolor(128,255,0))
			dxDrawText(getLanguageString('bomb_planting'),xscreen*0.863,yscreen*0.193,xscreen*0.863,yscreen*0.193,0xFF000000,getFont(1),"default-bold","center","center")
		end
	elseif (defusing) then
		local bombdefusing = TimeToSec(getRoundModeSettings("defusing") or "0:10")
		if (isRoundPaused()) then
			progress = bombdefusing*1000 - defusing
		else
			progress = bombdefusing*1000 - (defusing - getTickCount())
			if ((not toggleBombing or getRoundState() ~= "started" or getPlayerGameStatus(localPlayer) ~= "Play") and progress > 500) then
				setElementData(localPlayer,"defusing",nil,false)
				if (getPedAnimation(localPlayer) == "bomber") then
					callServerFunction("setPedAnimation",localPlayer,"BOMBER","null")
				end
			end
			if (getPedAnimation(localPlayer) ~= "bomber") then
				setElementData(localPlayer,"defusing",nil,false)
			end
		end
		if (progress >= bombdefusing*1000) then
			progress = bombdefusing*1000
			setElementData(localPlayer,"defusing",nil,false)
			if (getPedAnimation(localPlayer) == "bomber") then
				callServerFunction("setPedAnimation",localPlayer,"BOMBER","null")
			end
			triggerServerEvent("onPlayerBombDefuse",localPlayer)
		end
		if (guiCheckBoxGetSelected(config_performance_roundhud)) then
			dxDrawRectangle(xscreen*0.776,yscreen*0.173,xscreen*0.174,yscreen*0.04,0xFF000000)
			dxDrawRectangle(xscreen*0.780,yscreen*0.178,xscreen*0.166,yscreen*0.03,tocolor(0,64,128))
			dxDrawRectangle(xscreen*0.780,yscreen*0.178,xscreen*(0.166*progress/(bombdefusing*1000)),yscreen*0.03,tocolor(0,128,255))
			dxDrawText(getLanguageString('bomb_defusing'),xscreen*0.863,yscreen*0.193,xscreen*0.863,yscreen*0.193,0xFF000000,getFont(1),"default-bold","center","center")
		end
	end
end
function BombMatch_onClientPlayerBlipUpdate()
	local myteam = getPlayerTeam(localPlayer)
	local blip = getElementByID("BombBlip")
	if (blip) then
		if (myteam == getElementsByType("team")[1]) then
			setBlipIcon(blip,56)
		elseif (myteam) then
			local teamsides = getTacticsData("Teamsides")
			if (teamsides[myteam]%2 == 1) then
				setBlipIcon(blip,56)
			else
				setBlipIcon(blip,0)
				setBlipColor(blip,0,0,0,0)
			end
		end
	end
end
local help
function BombMatch_onClientElementColShapeHit(colshape,dimension)
	if (not isElement(colshape)) then return end
	if (dimension and getElementID(colshape) == "BombColshape") then
		local teamsides = getTacticsData("Teamsides")
		if (teamsides[getPlayerTeam(localPlayer)]%2 == 0) then
			help = outputInfo(string.format(getLanguageString('help_defusing'),string.upper(next(getBoundKeys("fire")))))
		end
	end
	if (dimension and getElementID(colshape) == "Bomb_Place") then
		local bombblip = getElementByID("BombBlip")
		if (bombblip and getElementAttachedTo(bombblip) == localPlayer) then
			local teamsides = getTacticsData("Teamsides")
			if (teamsides[getPlayerTeam(localPlayer)]%2 == 1) then
				help = outputInfo(string.format(getLanguageString('help_planting'),string.upper(next(getBoundKeys("fire")))))
			end
		end
	end
end
function BombMatch_onClientElementColShapeLeave(colshape,dimension)
	if (not isElement(colshape)) then return end
	if (dimension and getElementID(colshape) == "BombColshape") then
		local teamsides = getTacticsData("Teamsides")
		if (teamsides[getPlayerTeam(localPlayer)]%2 == 0) then
			if (help) then hideInfo(help) end
			if (getElementData(localPlayer,"defusing")) then
				setElementData(localPlayer,"defusing",nil,false)
			end
			if (getPedAnimation(localPlayer) == "bomber") then
				callServerFunction("setPedAnimation",localPlayer,"BOMBER","null")
			end
		end
	end
	if (dimension and getElementID(colshape) == "Bomb_Place") then
		local teamsides = getTacticsData("Teamsides")
		if (teamsides[getPlayerTeam(localPlayer)]%2 == 1) then
			if (help) then hideInfo(help) end
			if (getElementData(localPlayer,"planting")) then
				setElementData(localPlayer,"planting",nil,false)
			end
			if (getPedAnimation(localPlayer) == "bomber") then
				callServerFunction("setPedAnimation",localPlayer,"BOMBER","null")
			end
		end
	end
end
function BombMatch_createBombExplosion(xe,ye,ze)
	createExplosion(xe,ye,ze,7,true,0,false)
	createExplosion(xe+1,ye,ze,4,true,0,false)
	createExplosion(xe-1,ye,ze,4,true,0,false)
	createExplosion(xe,ye+1,ze,4,true,0,false)
	createExplosion(xe,ye-1,ze,4,true,0,false)
	if (getPlayerGameStatus(localPlayer) == "Play") then
		local xp,yp,zp = getElementPosition(localPlayer)
		createExplosion(xp + (xe-xp)/14.285,yp + (ye-yp)/14.285,zp + (ze-zp)/14.285,8,true,3.0,true)
		createExplosion(xp + (xe-xp)/14.285,yp + (ye-yp)/14.285,zp + (ze-zp)/14.285,8,true,3.0,true)
	end
end
function BombMatch_onClientElementStreamOut()
	if (getElementType(source) == "object" and getElementModel(source) == 2221) then
		destroyElement(source)
	end
end
function BombMatch_onClientPauseToggle(ispause)
	local planting = getElementData(localPlayer,"planting")
	local defusing = getElementData(localPlayer,"defusing")
	if (planting) then
		if (ispause) then
			setElementData(localPlayer,"planting",planting - getTickCount(),false)
		else
			setElementData(localPlayer,"planting",getTickCount() + planting,false)
		end
	end
	if (defusing) then
		if (ispause) then
			setElementData(localPlayer,"defusing",defusing - getTickCount(),false)
		else
			setElementData(localPlayer,"defusing",getTickCount() + defusing,false)
		end
	end
end
function BombMatch_onClientPreviewMapCreating(modename,elements)
	if (modename ~= "bomb") then return end
	for _,data in ipairs(elements) do
		if (data[1] == "Bomb_Place") then
			local marker = createMarker(tonumber(data[2].posX),tonumber(data[2].posY),tonumber(data[2].posZ),"cylinder",20,64,192,64,64)
			setElementParent(marker,source)
			setElementDimension(marker,10)
			local blip = createBlipAttachedTo(marker,31,2,255,40,0,255,-1)
			setElementParent(blip,source)
			setElementDimension(blip,10)
		end
	end
end
-- function BombMatch_onClientPlayerDamage()
	-- if (getElementData(localPlayer,"defusing")) then
		-- setElementData(localPlayer,"defusing",nil,false)
	-- end
	-- if (getElementData(localPlayer,"planting")) then
		-- setElementData(localPlayer,"planting",nil,false)
	-- end
	-- if (getPedAnimation(localPlayer) == "bomber") then
		-- callServerFunction("setPedAnimation",localPlayer,"BOMBER","null")
	-- end
-- end
addEventHandler("onClientMapStarting",root,BombMatch_onClientMapStarting)
addEventHandler("onClientMapStopping",root,BombMatch_onClientMapStopping)
addEventHandler("onClientPreviewMapCreating",root,BombMatch_onClientPreviewMapCreating)
