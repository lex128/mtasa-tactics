local replaceModels = {nitro=2221,repair=2222,vehiclechange=2223,weapon=2221}
local replaces = {}
function onStart()
	for name,id in pairs(replaceModels) do
		replaces[name] = {}
		replaces[name].txd = engineLoadTXD(":tactics/models/"..name..".txd")
		engineImportTXD(replaces[name].txd,id)
		replaces[name].dff = engineLoadDFF(":tactics/models/"..name..".dff",id)
		engineReplaceModel(replaces[name].dff,id)
	end
	for i,racepickup in pairs(getElementsByType("racepickup")) do
		checkElementType(racepickup)
	end
end
function onStop()
	for name,id in pairs(replaceModels) do
		destroyElement(replaces[name].txd)
		destroyElement(replaces[name].dff)
	end
end
function checkElementType(element)
	element = element or source
	if (getElementType(element) == "racepickup") then
		local pickuptype = exports.edf:edfGetElementProperty(element,"type")
		local object = getRepresentation(element,"object")
		if (object) then
			setElementModel(object[1],replaceModels[pickuptype] or 1346)
			setElementAlpha(object[2],0)
		end
	end
end
addEventHandler("onClientElementCreate",root,checkElementType)
addEventHandler("onClientElementPropertyChanged",root,function(propertyName)
	if (getElementType(source) == "racepickup") then
		if (propertyName == "type") then
			local pickupType = exports.edf:edfGetElementProperty(source,"type")
			local object = getRepresentation(source,"object")
			if (object) then
				setElementModel(object[1],replaceModels[pickupType] or 1346)
			end
		end
	end
end)
addEventHandler("onClientRender",getRootElement(),function()
	local zone = {}
	for i,point in pairs(getElementsByType("Anti_Rush_Point",getRootElement(),true)) do
		local x,y = getElementPosition(point)
		table.insert(zone,{x,y})
	end
	if (#zone > 0) then
		if (#zone == 2) then
			zone = {
				{math.min(zone[1][1],zone[2][1]),math.min(zone[1][2],zone[2][2])},
				{math.max(zone[1][1],zone[2][1]),math.min(zone[1][2],zone[2][2])},
				{math.max(zone[1][1],zone[2][1]),math.max(zone[1][2],zone[2][2])},
				{math.min(zone[1][1],zone[2][1]),math.max(zone[1][2],zone[2][2])}
			}
		end
		if (#zone > 1) then
			for j,point1 in ipairs(zone) do
				local point2 = (j < #zone and zone[j+1]) or zone[1]
				local x1,y1 = getScreenFromWorldPosition(point1[1],point1[2],getGroundPosition(point1[1],point1[2],1500),360)
				local x2,y2 = getScreenFromWorldPosition(point2[1],point2[2],getGroundPosition(point2[1],point2[2],1500),360)
				if (x1 and x2) then dxDrawLine(x1,y1,x2,y2,0x80A00000,5) end
			end
		end
	end
	local angle = getTickCount()*0.1%360
	for i,racepickup in pairs(getElementsByType("racepickup",getRootElement(),true)) do
		setElementRotation(racepickup,0,0,angle)
	end
end)
function getRepresentation(element,type)
	local elemTable = {}
	for i,elem in ipairs(getElementsByType(type,element)) do
		if elem ~= exports.edf:edfGetHandle(elem) then
			table.insert(elemTable,elem)
		end
	end
	if (#elemTable == 0) then
		return false
	elseif (#elemTable == 1) then
		return elemTable[1]
	else
		return elemTable
	end
end
