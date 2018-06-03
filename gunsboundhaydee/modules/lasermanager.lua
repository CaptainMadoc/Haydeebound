lasermanager = {
	out = {}
}


function lasermanager:add(part, tag, tagEnd, lc)
	self.out[part] = {tag = tag, tagEnd = tagEnd, laserColor = lc or {255,255,255,127}}
	activeItem.setScriptedAnimationParameter("laser",  self.out)
end

function lasermanager:init()
	activeItem.setScriptedAnimationParameter("laser",  {})
end

function lasermanager:update(dt)
end

function lasermanager:uninit()
end

addClass("lasermanager", 622)