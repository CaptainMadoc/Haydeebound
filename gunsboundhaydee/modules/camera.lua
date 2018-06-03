camera = {
	current = {0,0},
	target = {0,0},
	smooth = 14,
	projID = nil
}

function camera:lerp(value, to, speed)
	return value + ((to - value ) / speed ) 
end

function camera:init()
	
end

function camera:update(dt) 
	self.current = {
		self:lerp(self.current[1], self.target[1],self.smooth),
		self:lerp(self.current[2], self.target[2],self.smooth)
	}
	
	if self.projID and world.entityExists(self.projID) then
		world.callScriptedEntity(self.projID, "mcontroller.setPosition", vec2.add(mcontroller.position(), self.current))
		world.callScriptedEntity(self.projID, "mcontroller.setVelocity", {0,0})
	else
		camera:respawnProjectile()
	end
end

function camera:uninit()
	world.callScriptedEntity(self.projID, "projectile.die")
end

function camera:respawnProjectile()
	self.projID = world.spawnProjectile(
		"scouteye",
		vec2.add(mcontroller.position(), self.current),
		activeItem.ownerEntityId(),
		{0,0},
		false,
		{
			timeToLive = 10000, 
			power = 0,
			damageType = "NoDamage",
			universalDamage = false,
			processing = "?setcolor=ffffffff?replace;ffffffff=00000000",
			actionOnReap = jarray(),
			periodicActions = jarray()
		}
	)
	activeItem.setCameraFocusEntity(self.projID)
end

addClass("camera", -47)