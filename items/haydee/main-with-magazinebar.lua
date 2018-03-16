require "/items/gunsbound/animationkey.lua"
require "/scripts/vec2.lua"
require "/scripts/util.lua"


animation = {step = 30, fixed = false, currentstep = 1, key = 1, tracks = {shoot = {{sound = {}, value ={}},{sound = {}, value = {}}}}, playing = nil, doneplaying = ""}

parts = {gun_x = 0, gun_y = 0, gun_rotation = 0}

transform = {
	gun = {}
}

cooldown = 0
recoil = 0
lerpedrecoil = 0 --for visuals
smoke = 0
burstcount = 0

function init()
	

	
	self.gunConfig = config.getParameter("gunConfig",{	
			projectileType = "bullet-4", 
			fireOffset = {0,0}, 
			fireSpeed = 0.06, 
			fireMode = "auto", 
			recoilPower = 10, 
			recoilRecovery = 4,
			magazineMax = false,
			magazineCurrent = 0,
			reloadCooldown = 0.5
	})
	if not self.gunConfig.magazineCurrent then
		self.gunConfig.magazineCurrent = 0
	end
	animation = config.getParameter("animationKey", {
			step = 30, 
			fixed = false, 
			currentstep = 1, 
			key = 1, 
			tracks = {shoot = {{sound = {}, value ={}},{sound = {}, value = {}}}}, 
			playing = nil, 
			doneplaying = ""
	})
	
	if self.gunConfig.returnAmmo and type(self.gunConfig.returnAmmo)=="table" then
		for k,v in pairs(self.gunConfig.returnAmmo) do
			player.giveItem({name = k, count = v})
			self.gunConfig.returnAmmo[v] = nil
		end
		self.gunConfig.returnAmmo = nil
	else
		self.gunConfig.returnAmmo = nil
	end
	
	parts = config.getParameter("parts", {gun_x = 0, gun_y = 0, gun_rotation = 0})
	parts.armangle = 0
	local itemInfo = root.itemConfig({count = 1, name = config.getParameter("itemName")}, 1, 01)
	transform = root.assetJson(itemInfo.directory.."gunsprite.animation").transformationGroups
	updateAnimation()
	updateAim()
	self.barUUID = sb.makeUuid()
	--sb.logInfo(sb.printJson(self.gunConfig,1))
	
end

function uninit()
	if self.gunConfig.magazineMax then
		activeItem.setInstanceValue("gunConfig",self.gunConfig)
		world.sendEntityMessage(activeItem.ownerEntityId(),"removeBar",config.getParameter("itemName")..self.barUUID)
	end
end

function update(dt, fireMode, shiftHeld, moves)

	if cooldown > 0 then
		cooldown = cooldown - dt
	else
		activeItem.setRecoil(false)
		if self.reloading then
			self.reloading = false
			if animator.hasSound("reloadEnd") then
				animator.playSound("reloadEnd")
			end
		end
	end
	
	if self.gunConfig.reloadForce or (moves.up and self.gunConfig.magazineCurrent < self.gunConfig.magazineMax and cooldown<=0) then	
		magreload()
	end
	
	if smoke > 0 and cooldown <= 0 then
		smoke = smoke - dt
		if smoke < 1.5 and self.gunConfig.smokeEffect then
			animator.burstParticleEmitter("smoke")
		end
	end
	
	if self.gunConfig.magazineMax then
		if not self.reloading then
			local percent = self.gunConfig.magazineCurrent/self.gunConfig.magazineMax
			world.sendEntityMessage(activeItem.ownerEntityId(),"setBar",config.getParameter("itemName")..self.barUUID,percent,{255-math.ceil(255*percent),127+math.ceil(128*percent),0,255})
		else
			world.sendEntityMessage(activeItem.ownerEntityId(),"setBar",config.getParameter("itemName")..self.barUUID,1-cooldown/self.gunConfig.reloadCooldown,{255,128,0,255})
		end
	end
	
	if mcontroller.crouching() then
		recoil = recoil - (recoil / (self.gunConfig.recoilRecovery * 0.8))
	else
		recoil = recoil - (recoil / self.gunConfig.recoilRecovery)
	end
	updateFire(dt, fireMode, shiftHeld)
	updateAnimation()
	updateAim()
	updateDrawable()
end

function updateFire(dt, fireMode, shiftHeld)
	if fireMode == "primary" and self.gunConfig.fireMode == "auto" and cooldown <= 0 then
		shoot()
	end
	
	if fireMode == "primary" and self.gunConfig.fireMode == "semi" and cooldown <= 0 and not self.onetap then
		shoot()
		self.onetap = true
		elseif self.onetap and fireMode ~= "primary" then
		self.onetap = nil
	end
	
	if fireMode == "primary" and self.gunConfig.fireMode == "burst" and cooldown <= 0 and burstcount <= 0 then
		burstcount = self.gunConfig.burstAmount or 3
	end
	
	if burstcount > 0 and cooldown <= 0 then
		burstcount = burstcount - 1
		shoot()
		if burstcount == 0 then
			cooldown = self.gunConfig.burstCooldown or self.gunConfig.fireSpeed * 2
		end
	end
end

function updateDrawable()
	for i,v in pairs(transform) do
		animator.resetTransformationGroup(i)
		if parts[i.."_rotation"] then
			if parts[i.."_xRot"] and parts[i.."_yRot"] then
				animator.rotateTransformationGroup(i, math.rad(parts[i.."_rotation"]), {parts[i.."_xRot"], parts[i.."_yRot"]})
			else
				animator.rotateTransformationGroup(i, math.rad(parts[i.."_rotation"]))
			end
		end
		if parts[i.."_x"] and parts[i.."_y"] then
			animator.translateTransformationGroup(i, {parts[i.."_x"], parts[i.."_y"]})
		end
	end
	animator.resetTransformationGroup("muzzle")
	animator.translateTransformationGroup("muzzle", self.gunConfig.fireOffset or {0,0})
	animator.resetTransformationGroup("case")
	animator.translateTransformationGroup("case", self.gunConfig.shellOffset or {0,0})
end

function updateAim()
	self.aimAngle, self.facingDirection = activeItem.aimAngleAndDirection(0, vec2.sub(activeItem.ownerAimPosition(), {0, self.gunConfig.fireOffset[2]}))
	activeItem.setFacingDirection(self.facingDirection)
	lerpedrecoil = lerp(lerpedrecoil, recoil, 3)
	activeItem.setArmAngle(self.aimAngle + math.rad(lerpedrecoil)	+ math.rad(parts.armangle))
end

function lerp(value, to, speed)
	return value + ((to - value ) / speed ) 
end

function magreload()
	while player.hasItem(self.gunConfig.compatibleAmmo[1]) and self.gunConfig.magazineCurrent < self.gunConfig.magazineMax do
		player.consumeItem(self.gunConfig.compatibleAmmo[1])
		self.gunConfig.magazineCurrent = self.gunConfig.magazineCurrent + 1
	end
	if self.gunConfig.reloadCooldown then
		cooldown = self.gunConfig.reloadCooldown
	end
	if animator.hasSound("reload") then
		animator.playSound("reload")
	end
	self.gunConfig.reloadForce = false
	self.reloading = true
end

function shoot()
	if self.gunConfig.compatibleAmmo then
		local itemammo = nil
		
		--sb.logInfo(sb.printJson(self.gunConfig,1))
		
		if self.gunConfig.magazineMax then
			if self.gunConfig.magazineCurrent > 0 then
				self.gunConfig.magazineCurrent = self.gunConfig.magazineCurrent - 1
				itemammo = true
			else
				magreload()
				return
			end
		else
			itemammo = player.consumeItem(self.gunConfig.compatibleAmmo[1])
		end
		
		if itemammo then
			local projectile = "bullet-2"
			local projectileconf = {}
			
			
			projectile = self.gunConfig.projectileType or "bullet-2"
			projectileconf = copy(self.gunConfig.projectileConfig or {})
			projectileconf.powerMultiplier = activeItem.ownerPowerMultiplier()


			playAnimation("shoot")
			world.spawnProjectile(
				projectile,
				offset(),
				activeItem.ownerEntityId(),
				aim(),
				false,
				projectileconf
			)
			smoke = 2
			recoil = recoil + self.gunConfig.recoilPower
			cooldown = self.gunConfig.fireSpeed or 0.1
			activeItem.setRecoil(true)
			animator.setAnimationState("firing", "fire")
			if self.gunConfig.shellEffect then
				animator.burstParticleEmitter("case")
			end
			for _,v in pairs(self.gunConfig.gunSounds) do
				if animator.hasSound(v) then
					animator.playSound(v)
				end
			end
		else
			if animator.hasSound("dry") then
				animator.playSound("dry")
			end
			smoke = 0
			activeItem.setRecoil(false)
			cooldown = 0.5
			recoil = recoil + 1
		end
		
	end
end

function posi(val)
	if val > 0 then
		return val
	else
		return -val
	end
end

function offset()
	local offset = {mcontroller.position()[1] + vec2.rotate(activeItem.handPosition(self.gunConfig.fireOffset), mcontroller.rotation())[1], mcontroller.position()[2] + vec2.rotate(activeItem.handPosition(self.gunConfig.fireOffset), mcontroller.rotation())[2]}
	return offset
end

function aim()
  local randoms = 0
  local inaccuracy = self.gunConfig.inaccuracy or 45
  if not (mcontroller.xVelocity() < 1 and mcontroller.xVelocity() > -1) then
	randoms = (math.random (0,20 * math.floor(math.min(posi(mcontroller.xVelocity()), inaccuracy))) - 10 * math.floor(math.min(posi(mcontroller.xVelocity()), inaccuracy))) / 10
  end
  if not mcontroller.onGround() then
	randoms = (math.random (0,20 * math.floor(math.min(inaccuracy, inaccuracy))) - 10 * math.floor(math.min(inaccuracy, inaccuracy))) / 10
  end
  local aimVector = vec2.rotate({1, 0}, self.aimAngle + math.rad(recoil) + math.rad(parts.armangle) + math.rad(randoms))
  aimVector[1] = aimVector[1] * self.facingDirection
  aimVector[2] = aimVector[2]
  return aimVector
end