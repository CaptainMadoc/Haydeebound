require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/gunsboundhaydee/scripts/util.lua"

debugMode = true
_Delta = os.clock()

function processDirectory(str)
	if strStarts(str, "/") then
		return str
	end
	if selfItem or selfItem.rootDirectory then
		return selfItem.rootDirectory..str
	end
	local itemConfig = root.itemConfig({name = item.name()})
	return itemConfig.directory..str
end

pD = processDirectory

--

updateInfo = {dt = 1/62, fireMode = "none", shiftHeld = false, moves = {up = false, left = false, right = false, down = false}}
updateLast = {dt = 1/62, fireMode = "none", shiftHeld = false, moves = {up = false, left = false, right = false, down = false}}
selfItem = {classes = {},toCondense = false, condensedClasses = {}, rootDirectory = "/", hasLateInited = false}

function init()	
	
	message.setHandler("isLocal", function(_, loc) return loc end )
	activeItem.setScriptedAnimationParameter("entityID", activeItem.ownerEntityId())

	local ownitem = root.itemConfig({name = item.name(), count = 1})
	selfItem.rootDirectory = config.getParameter("rootDirectory", ownitem.directory)
	
	
	local scriptList = config.getParameter("scriptClass")
	if type(scriptList) == "string" then
		scriptList = root.assetJson(processDirectory(scriptList))
	end
	
	if type(scriptList) == "table" then
		for i,v in ipairs(scriptList) do
			require(processDirectory(v))
		end
	else
		log("Invalid scriptClass type", 2)
	end
	
	updateClass()
	for i,v in ipairs(selfItem.condensedClasses) do
		if _ENV[v] and _ENV[v].init then
			_ENV[v]:init()
		end
	end 
end

function updateClass()
	if selfItem.toCondense then
		selfItem.condensedClasses = table.condense(selfItem.classes,false)
		selfItem.toCondense = false
		return
	end
end

function addClass(name, prioity) --add for the class system to update
	if prioity then
		prioity = math.max(prioity, -9999)
		selfItem.classes[10000 + prioity] = name
		selfItem.toCondense = true
		return
	else
		selfItem.toCondense = true
		table.insert(selfItem.classes, name)
		return
	end
end

function update(dt, fireMode, shiftHeld, moves) 
	updateInfo = {dt = os.clock() - _Delta, fireMode = fireMode, shiftHeld = shiftHeld, moves = moves}

	updateClass()
	if not selfItem.hasLateInited then
		for i,v in ipairs(selfItem.condensedClasses) do --the reason behind of this, is because i use this when all the modules are properly inited. also cannot be recalled after loading another script in runtime.
			if _ENV[v] and _ENV[v].lateinit then
				_ENV[v]:lateinit(updateInfo.dt, fireMode, shiftHeld, moves)
			end
		end
		selfItem.hasLateInited = true
	end
	
	for i,v in ipairs(selfItem.condensedClasses) do
		if _ENV[v] and _ENV[v].update then
			_ENV[v]:update(updateInfo.dt, fireMode, shiftHeld, moves)
		end
	end
	
	updateLast = {dt = updateInfo.dt, fireMode = updateInfo.fireMode, shiftHeld = shiftHeld, moves = moves}
	world.debugText("deltaTime = "..updateInfo.dt, "", mcontroller.position(), "green")
	_Delta = os.clock()
end

function uninit()
	updateClass()
	for i,v in ipairs(selfItem.condensedClasses) do
		if _ENV[v] and _ENV[v].uninit then
			_ENV[v]:uninit()
		end
	end
end

function activate(fireMode, shiftHeld)
	updateClass()
	for i,v in ipairs(selfItem.condensedClasses) do
		if _ENV[v] and _ENV[v].activate then
			_ENV[v]:activate(fireMode, shiftHeld)
		end
	end
end