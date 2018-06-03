flashlightmanager = {
	out = {}
}


function flashlightmanager:add(part, tag, tagEnd, lc)
	self.out[part] = {tag = tag, tagEnd = tagEnd, lightColor = lc or {255,255,255,128}}
	activeItem.setScriptedAnimationParameter("flashlight",  self.out)
end

function flashlightmanager:init()
	activeItem.setScriptedAnimationParameter("flashlight",  {})
end

function flashlightmanager:update(dt)
end

function flashlightmanager:uninit()
end

addClass("flashlightmanager", 621)