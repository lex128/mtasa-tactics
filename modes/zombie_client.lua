--[[**************************************************************************
*
*  ПРОЕКТ:        TACTICS MODES
*  ВЕРСИЯ ДВИЖКА: 1.2-r18
*  РАЗРАБОТЧИКИ:  Александр Романов <lexr128@gmail.com>
*
****************************************************************************]]
function ZombieMod_onClientMapStopping(mapinfo)
	if (mapinfo.modename ~= "zombie") then return end
	showRoundHudComponent("timeleft",false)
	showRoundHudComponent("teamlist",false)
	removeEventHandler("onClientPlayerDamage",localPlayer,ZombieMod_onClientPlayerDamage)
	removeEventHandler("onClientPlayerRoundSpawn",localPlayer,ZombieMod_onClientPlayerRoundSpawn)
	removeEventHandler("onClientZombieInfected",root,ZombieMod_onClientZombieInfected)
	removeEventHandler("onClientCameraSpectateTargetChange",localPlayer,ZombieMod_onClientCameraSpectateTargetChange)
	removeEventHandler("onClientPlayerRPS",root,ZombieMod_onClientPlayerRPS)
	removeCommandHandler("gun",toggleWeaponManager)
	unbindKey("fire","down",ZombieMod_onClientZombiePush)
	if (guiGetVisible(weapon_window)) then
		guiSetVisible(weapon_window,false)
		if (isAllGuiHidden()) then showCursor(false) end
	end
	setPlayerProperty("movespeed",nil)
	setPlayerProperty("regenerable",nil)
	setCameraGoggleEffect("normal")
	setPedFootBloodEnabled(root,false)
end
function ZombieMod_onClientMapStarting(mapinfo)
	if (mapinfo.modename ~= "zombie") then return end
	loadCustomObject(78,"models/zombie.txd")
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
	showRoundHudComponent("teamlist",true)
	addEventHandler("onClientPlayerDamage",localPlayer,ZombieMod_onClientPlayerDamage)
	addEventHandler("onClientPlayerRoundSpawn",localPlayer,ZombieMod_onClientPlayerRoundSpawn)
	addEventHandler("onClientZombieInfected",root,ZombieMod_onClientZombieInfected)
	addEventHandler("onClientCameraSpectateTargetChange",localPlayer,ZombieMod_onClientCameraSpectateTargetChange)
	addEventHandler("onClientPlayerRPS",root,ZombieMod_onClientPlayerRPS)
	addCommandHandler("gun",toggleWeaponManager,false)
	bindKey("fire","down",ZombieMod_onClientZombiePush)
	setPlayerProperty("movespeed",nil)
	setPlayerProperty("regenerable",nil)
end
function ZombieMod_onClientPlayerRoundSpawn()
	if (getRoundState() == "stopped") then setCameraPrepair() end
end
function ZombieMod_onClientPlayerRPS()
	if (getPlayerTeam(source) == getTacticsData("Sides")[2]) then
		if (source == localPlayer) then setCameraGoggleEffect("thermalvision") end
		setPedFootBloodEnabled(source,true)
	end
end
function ZombieMod_onClientZombieInfected()
	triggerEvent("onClientPlayerBlipUpdate",source)
	local x,y,z = getElementPosition(source)
	local scream = playSound3D("audio/scream.mp3",x,y,z,false)
	attachElements(scream,source,0,0,0)
	setSoundMaxDistance(scream,200.0)
	setPedFootBloodEnabled(source,true)
	if (source == localPlayer) then
		setPlayerProperty("movespeed",tonumber(getRoundModeSettings("zombie_speed")) or 1.2)
		setPlayerProperty("regenerable",tonumber(getRoundModeSettings("zombie_regenerate")) or 5)
		fadeCamera(false,0,128,0,0)
		setCameraGoggleEffect("normal")
		setTimer(function()
			setCameraGoggleEffect("thermalvision")
			fadeCamera(true,1.0)
		end,100,1)
	end
end
function ZombieMod_onClientCameraSpectateTargetChange(old)
	local target = getCameraSpectateTarget()
	if (target and getPlayerTeam(target) == getTacticsData("Sides")[2]) then
		setCameraGoggleEffect("thermalvision")
	elseif (getCameraGoggleEffect() ~= "normal") then
		outputDebugString("setCameraGoggleEffect(\"normal\")")
		setCameraGoggleEffect("normal")
	end
end
function ZombieMod_onClientPlayerDamage(attacker,weapon,bodypart,loss)
	local sides = getTacticsData("Sides")
	if (getPlayerTeam(localPlayer) == sides[2] and attacker and attacker ~= localPlayer) then
		local x1,y1,z1 = getElementPosition(attacker)
		local x2,y2,z2 = getElementPosition(localPlayer)
		local dist = getDistanceBetweenPoints3D(x1,y1,z1,x2,y2,z2)
		local xdir,ydir,zdir = (x2-x1)/dist,(y2-y1)/dist,(z2-z1)/dist
		local xvel,yvel,zvel = getElementVelocity(localPlayer)
		setElementPosition(localPlayer,x2,y2,z2 + 0.7,true)
		setElementVelocity(localPlayer,xvel + 0.15*xdir,yvel + 0.15*ydir,zvel + 0.15*zdir)
	end
end
function ZombieMod_onClientZombiePush()
	local sides = getTacticsData("Sides")
	if (getPlayerTeam(localPlayer) == sides[2]) then
		if (not getControlState("jump") and getPedTask(localPlayer,"primary",4) == "TASK_SIMPLE_PLAYER_ON_FOOT" and getPedTask(localPlayer,"primary",1) ~= "TASK_COMPLEX_IN_AIR_AND_LAND" and getPedTask(localPlayer,"primary",3) ~= "TASK_COMPLEX_JUMP") then
			local x1,y1,z1 = getElementPosition(localPlayer)
			for i,player in ipairs(getElementsByType("player",root,true)) do
				if (getPlayerTeam(player) ~= sides[2]) then
					local x2,y2,z2 = getElementPosition(player)
					local rot1 = getPedRotation(localPlayer)
					local rot2 = getAngleBetweenPoints2D(x1,y1,x2,y2)
					if (getDistanceBetweenPoints3D(x1,y1,z1,x2,y2,z2) <= 1.6 and math.abs(getAngleBetweenAngles2D(rot1,rot2)) < 90) then
						triggerServerEvent("onZombieInfected",player,localPlayer)
					end
				end
			end
		end
	end
end
addEvent("onClientZombieInfected",true)
addEventHandler("onClientMapStarting",root,ZombieMod_onClientMapStarting)
addEventHandler("onClientMapStopping",root,ZombieMod_onClientMapStopping)
