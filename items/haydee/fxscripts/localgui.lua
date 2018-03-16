require "/scripts/vec2.lua"
require "/scripts/util.lua"

drawables = {}
particles = {}
info = {}
lerp1 = {0,0}

function lerp(value, to, speed) --api do not tamper
	return value + ((to - value ) / speed ) 
end

function facing()
	local val1 = activeItemAnimation.ownerAimPosition()[1] - activeItemAnimation.ownerPosition()[1]
	if val1 < 0 then
		return -1
	else
		return 1
	end
end

function init()
	info = animationConfig.animationParameter("info")
end

function update(dt)
	localAnimator.clearDrawables()
	
	drawables = animationConfig.animationParameter("drawables")
	particles = animationConfig.animationParameter("particles")
	
	lerp1[1] = lerp(lerp1[1], activeItemAnimation.handPosition()[1], 8)
	lerp1[2] = lerp(lerp1[2], activeItemAnimation.handPosition()[2], 8)
	
	if info.entityId and world.entityExists(info.entityId) and world.entityUniqueId(info.entityId) == info.uniqueId then
		
		for i,v in pairs(drawables) do
			drawables[i].position = vec2.add(vec2.add(vec2.mul(drawables[i].position, {facing(), 1}), lerp1), activeItemAnimation.ownerPosition())
			localAnimator.addDrawable(v)
		end
		
	end
	
	if info.entityId and world.entityExists(info.entityId) and world.entityUniqueId(info.entityId) == info.uniqueId then
		
		for i,v in pairs(particles) do
			particles[i].position = vec2.add(vec2.add(vec2.mul(particles[i].position, {facing(), 1}), lerp1), activeItemAnimation.ownerPosition())
			localAnimator.spawnParticle(v)
		end
		
	end
	
end

function uninit()
	
end