uimanager = {}

function uimanager:init()
end

function uimanager:update(dt)
	
	activeItem.setScriptedAnimationParameter("load", type(weapon.load))
	
	
	--to fix
	local t = false
	
	if weapon.load and weapon.load.parameters.fired then
		t = true
		activeItem.setScriptedAnimationParameter("fired", true)
	end
	
	if not t then
		activeItem.setScriptedAnimationParameter("fired", false)
	end
	
	activeItem.setScriptedAnimationParameter("fireSelect",  weapon.fireTypes[weapon.fireSelect])
	activeItem.setScriptedAnimationParameter("inAccuracy",  weapon:getInAccuracy())
	activeItem.setScriptedAnimationParameter("muzzleDistance",  world.distance(activeItem.ownerAimPosition(),weapon:rel(animator.partPoint("gun", "muzzle_begin"))))

end

function uimanager:uninit()
end

addClass("uimanager", 620)