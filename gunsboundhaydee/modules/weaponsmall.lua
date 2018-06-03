weapon = {
	recoil = 0,
	recoilCamera = {0,0},
	delay = 0.5,
	load = nil,
	reloadLoop = false,
	stats = {},
	global = {autoReload = true},
	animations = {}, --animation Names
	burstCount = 0,
	burstDelay = 0.4,
	fireSelect = 1,
	bypassShellEject = false
}

function weapon:lerp(value, to, speed)
	return value + ((to - value ) / speed ) 
end

function weapon:lerpr(value, to, ratio)
	return value + ((to - value ) * ratio ) 
end

function weapon:casingPosition()
	local casingConfig = config.getParameter("casing")
	local offset = {0,0}
	if casingConfig then
		offset = animator.partPoint(casingConfig.part, casingConfig.tag)
	end
	return vec2.add(mcontroller.position(), activeItem.handPosition(offset))
end

function weapon:init()
	message.setHandler("isLocal", function(_, loc) return loc end )
	activeItem.setScriptedAnimationParameter("entityID", activeItem.ownerEntityId())
	self.stats = config.getParameter("gunStats")
	self.fireSounds = config.getParameter("fireSounds",jarray())
	animator.setSoundPool("fireSounds",self.fireSounds or jarray())
	self.load = config.getParameter("gunLoad")
	self.burstDelay = config.getParameter("burstCooldown", 0.4)
	self.fireTypes = config.getParameter("fireTypes")
	self.animations = config.getParameter("gunAnimations")
	self.bypassShellEject = config.getParameter("bypassShellEject", false)
	activeItem.setCursor("/gunsboundhaydee/crosshair/crosshairsmall.cursor")
	animation:addEvent("eject_ammo", function() weapon:eject_ammo() end)
	animation:addEvent("load_ammo", function() weapon:load_ammo() end)
	animation:addEvent("reload_loop", function() weapon.reloadLoop = true end)
	animation:addEvent("reloadLoop", function() weapon.reloadLoop = true end)
end

function weapon:lateinit()
	if weapon:isDry() and self.animations["draw_dry"] then
		animation:play(self.animations["draw_dry"])
	else
		animation:play(self.animations.draw or "draw")
	end
end

function weapon:activate(fireMode, shiftHeld)
	if shiftHeld and fireMode == "alt" then
		self.fireSelect = self.fireSelect + 1
		animator.playSound("dry")
		if #self.fireTypes < self.fireSelect then
			self.fireSelect = 1
		end
	end
end

function weapon:rel(pos)
	return vec2.add(mcontroller.position(), activeItem.handPosition(pos))
end

function weapon:debug(dt)
	world.debugPoint(self:rel(animator.partPoint("gun", "muzzle_begin")), "green")
	world.debugPoint(self:rel(animator.partPoint("gun", "muzzle_end")), "red")
	world.debugLine(self:rel(animator.partPoint("gun", "muzzle_begin")),self:rel(weapon:calculateInAccuracy(animator.partPoint("gun", "muzzle_end"))), "red")
	--world.debugText("inAccuracy = "..(self:getInAccuracy()), "", vec2.add(mcontroller.position(), {0,1}), "green")
	--world.debugText("magazine = "..(#magazine.storage), "", vec2.add(mcontroller.position(), {0,2}), "green")
	--world.debugText("load = "..sb.printJson(self.load or {}), "", vec2.add(mcontroller.position(), {0,3}), "green")
end

function weapon:angle()
	return vec2.sub(self:rel(animator.partPoint("gun", "muzzle_end")),self:rel(animator.partPoint("gun", "muzzle_begin")))
end

function whichhigh(a,b)
	if a > b then
		return a
	else
		return b
	end
end

function weapon:calculateRPM(r)
	return 60 / r
end

function weapon:getInAccuracy()
	local crouchMult = 1
	if mcontroller.crouching() then
		crouchMult = self.stats.crouchInaccuracyMultiplier
	end
	local velocity = whichhigh(math.abs(mcontroller.xVelocity()), math.abs(mcontroller.yVelocity() + 1.28))
	local percent = math.min(velocity / 14, 1)
	return self:lerpr(self.stats.standingInaccuracy, self.stats.movingInaccuracy, percent) * crouchMult
end

function weapon:calculateInAccuracy(pos)
	local angle = (math.random(0,2000) - 1000) / 1000
	local crouchMult = 1
	if mcontroller.crouching() then
		crouchMult = self.stats.crouchInaccuracyMultiplier
	end
	if not pos then
		return math.rad((angle * self:getInAccuracy()))
	end
	return vec2.rotate(pos, math.rad((angle * self:getInAccuracy())))
end

function weapon:fire()
	if self.load and not self.load.parameters.fired then
		local newConfig = root.itemConfig({name = self.load.name, count = 1, parameters = self.load.parameters})
		if not newConfig then
			weapon:eject_ammo()
			return
		end
		self.load.parameters = sb.jsonMerge(newConfig.config, newConfig.parameters)
		
		self.recoil = self.recoil + self.stats.recoil
		self.recoilCamera = {math.sin(math.rad(self.recoil * 80)) * ((self.recoil / 5) ^ 1.25), self.recoil / 2}
		for i=1,self.load.parameters.projectileCount or 1 do
			world.spawnProjectile(
				self.load.parameters.projectile or "bullet-4", 
				self:rel(animator.partPoint("gun", "muzzle_begin")), 
				activeItem.ownerEntityId(), 
				self:calculateInAccuracy(self:angle()), 
				false,
				self.load.parameters.projectileConfig or {}
			)
		end
		self.load.parameters.fired = true
		
		if not self.bypassShellEject then
			weapon:eject_ammo()
			self.hasToLoad = true
		end
		
		if #magazine.storage == 0 then
			animation:play(self.animations["shoot_dry"] or self.animations.shoot)
		else
			animation:play(self.animations.shoot)
		end
		
		animator.playSound("fireSounds")
		if self.stats.muzzleFlash == 1 then
			animator.setAnimationState("firing", "on")
		end
		activeItem.setInstanceValue("gunLoad", self.load)
		self.delay = weapon:calculateRPM(self.stats.rpm or 600)
	else
		animator.playSound("dry")
		if not animation:isAnyPlaying() then
			animation:play(self.animations.shoot_null)
		end
		self.delay = weapon:calculateRPM(self.stats.rpm or 600)
	end
end

function weapon:eject_ammo()
	if self.load then
		if not self.load.parameters.fired then
			player.giveItem(self.load)
		elseif self.load.parameters.casingProjectile then
			
			world.spawnProjectile(
				self.load.parameters.casingProjectile, 
				self:casingPosition(), 
				activeItem.ownerEntityId(), 
				vec2.rotate({0,1}, math.rad(math.random(90) - 45)), 
				false,
				self.load.parameters.casingProjectileConfig or {}
			)
		end
		self.load = nil
		activeItem.setInstanceValue("gunLoad", self.load)
	end
	if #magazine.storage == 0 then
		
		animation:play(self.animations.dry)
	end
end

function weapon:load_ammo()
	self.load = magazine:take()
	activeItem.setInstanceValue("gunLoad", self.load)
end

function weapon:isDry()
	return (not self.load and #magazine.storage == 0)
end

function weapon:shouldAutoReload()
	if not self.global.autoReload then
		return false
	end
	if self.load and not self.load.parameters.fired then
		return false
	end
	for i,v in pairs(magazine.storage) do
		if v.parameters and not v.parameters.fired then
			return false
		end
	end
	return true and self.global.autoReload
end

function weapon:update(dt)

	if (updateInfo.shiftHeld and updateInfo.moves.up and not self.reloadLoop and not animation:isAnyPlaying())
		or (self:shouldAutoReload() and not animation:isAnyPlaying() and not self.reloadLoop and magazine:playerHasAmmo() and self.delay == 0) then
		if weapon:isDry() and self.animations["reload_dry"] then
			animation:play(self.animations["reload_dry"])
		else
			animation:play(self.animations.reload)
		end
	end
	
	if (not updateInfo.shiftHeld and updateInfo.moves.up and not self.reloadLoop and not animation:isAnyPlaying())
		or ((not self.load or self.load.parameters.fired) and #magazine.storage > 0 and not self.reloadLoop and not animation:isAnyPlaying() and self.global.autoReload and self.delay == 0) then
		if not self.load and self.animations["cock_dry"] then
			animation:play(self.animations["cock_dry"])
		else
			animation:play(self.animations.cock)
		end
	end
	
	if (self.reloadLoop and not animation:isAnyPlaying() and #magazine.storage < weapon.stats.maxMagazine and magazine:playerHasAmmo()) then
		if weapon:isDry() and self.animations["reloadLoop_dry"] then
			animation:play(self.animations["reloadLoop_dry"])
		else
			animation:play(self.animations.reloadLoop)
		end
	elseif self.reloadLoop and not animation:isAnyPlaying() then
		if weapon:isDry() and self.animations["reloadEnd_dry"] then
			animation:play(self.animations["reloadEnd_dry"])
		else
			animation:play(self.animations.reloadEnd)
		end
		self.reloadLoop = false
	end
	
	if updateInfo.fireMode == "primary" and self.fireTypes[self.fireSelect] == "auto" and (not animation:isAnyPlaying() or animation:isPlaying({self.animations.shoot, self.animations["shoot_dry"]})) and self.delay <= 0 then
		self:fire()
	end
	
	if updateInfo.fireMode == "primary" and updateLast.fireMode ~= "primary" and self.fireTypes[self.fireSelect] == "semi" and (not animation:isAnyPlaying() or animation:isPlaying({self.animations.shoot, self.animations["shoot_dry"]})) and self.delay <= 0 then
		self:fire()
	end
	
	if updateInfo.fireMode == "primary" and self.fireTypes[self.fireSelect] == "burst" and self.burstCount <= 0 and self.delay <= 0 then
		self.burstCount = self.stats.burst or 3
	end
	
	if self.delay == 0 and self.burstCount > 0 then
		self:fire()
		self.burstCount = self.burstCount - 1
		if self.burstCount == 0 then
			self.delay = self.burstDelay
		end
	end
	
	--camerasystem
	local distance = world.distance(activeItem.ownerAimPosition(), mcontroller.position())
	camera.target = vec2.add({distance[1] * util.clamp(self.stats.aimLookRatio, 0, 0.5),distance[2] * util.clamp(self.stats.aimLookRatio, 0, 0.5)}, self.recoilCamera)
	camera.smooth = 4
	self.recoilCamera = {self:lerp(self.recoilCamera[1],0,self.stats.recoilRecovery),self:lerp(self.recoilCamera[2],0,self.stats.recoilRecovery)}
	self.recoil = self:lerp(self.recoil, 0, self.stats.recoilRecovery + self.delay)
	
	--aiming system
	local angle, dir = activeItem.aimAngleAndDirection(0, vec2.add(activeItem.ownerAimPosition(), vec2.div(mcontroller.velocity(), 28)))
	aim.target = math.deg(angle)
	aim.dir = dir
	
	--timers
	self.delay = math.max(self.delay - dt, 0)
	if self.delay == 0 and self.hasToLoad then
		self.hasToLoad = false
		weapon:load_ammo()
	end
	weapon:debug(dt)
end

function weapon:uninit()
	activeItem.setInstanceValue("gunLoad", self.load)
end

addClass("weapon", 1)