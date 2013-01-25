--[[**************************************************************************
*
*  ПРОЕКТ:        TACTICS MODES
*  ВЕРСИЯ ДВИЖКА: 1.2-r18
*  РАЗРАБОТЧИКИ:  Александр Романов <lexr128@gmail.com>
*
****************************************************************************]]
function Lobby_onResourceStart(resource)
	createTacticsMode("lobby",{car="true",gun="true",player_radarblip="all|none,team,all"})
end
function Lobby_onMapStopping(mapinfo)
	if (mapinfo.modename ~= "lobby") then return end
	removeEventHandler("onPlayerRoundSpawn",root,Lobby_onPlayerRoundSpawn)
end
function Lobby_onMapStarting(mapinfo)
	if (mapinfo.modename ~= "lobby") then return end
	if (isTimer(restartTimer)) then killTimer(restartTimer) end
	addEventHandler("onPlayerRoundSpawn",root,Lobby_onPlayerRoundSpawn)
	forcedStartRound("notround")
end
function Lobby_onPlayerRoundSpawn()
	local team = getPlayerTeam(source)
	local model = getElementModel(source) or getElementData(team,"Skins")[1]
	local element = getElementsByType("spawnpoint")[math.random(#getElementsByType("spawnpoint"))]
	local posX = tonumber(getElementData(element,"posX"))
	local posY = tonumber(getElementData(element,"posY"))
	local posZ = tonumber(getElementData(element,"posZ"))
	local rotation = tonumber(getElementData(element,"rotation")) or 0.0
	local interior = getTacticsData("Interior")
	spawnPlayer(source,posX,posY,posZ,rotation,model,interior,0,team)
	toggleAllControls(source,true)
	setCameraTarget(source,source)
	setElementData(source,"Status","Play")
	setElementData(source,"Weapons",true)
	callClientFunction(source,"setCameraInterior",interior)
end
addEventHandler("onMapStarting",root,Lobby_onMapStarting)
addEventHandler("onMapStopping",root,Lobby_onMapStopping)
addEventHandler("onResourceStart",resourceRoot,Lobby_onResourceStart)
