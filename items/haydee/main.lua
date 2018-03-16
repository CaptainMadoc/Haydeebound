require "/items/gunsbound/animationkey.lua"
require "/items/gunsbound/portraitprocessor.lua"
require "/scripts/vec2.lua"
require "/scripts/util.lua"


animation = {step = 30, fixed = false, currentstep = 1, key = 1, tracks = {shoot = {{sound = {}, value ={}},{sound = {}, value = {}}}}, playing = nil, doneplaying = "", actions = {}}


function animation.actions.checkempty()


end

--Values for transform/drawables
parts = {gun_x = 0, gun_y = 0, gun_rotation = 0}

--Values for transforms
transform = {
	gun = {}
}

cooldown = 0 --shoot timer
recoil = 0 --recoil value
lerpedrecoil = 0 --for visuals
smoke = 0 --smokeEffect timer
burstcount = 0 --burst request

armInfo = {
found = false,
species = "human",
skindirectives = "",

backarm = "rotation",
backarmarmordirectives = "",
backarmarmor = "",

frontarm = "rotation",
frontarmarmordirectives = "",
frontarmarmor = "",

}


function getArmInfo()
	if not armInfo.found then
		if world.entityExists(activeItem.ownerEntityId()) then
			armInfo.found = true
			armInfo.species = world.entitySpecies(activeItem.ownerEntityId())
			armInfo.skindirectives = skinDirectives(autoPortrait(activeItem.ownerEntityId()))
			
			armInfo.backarmarmordirectives = getDirectives(autoPortrait(activeItem.ownerEntityId()), "BackArmArmor")
			armInfo.backarmarmor = getDirectory(autoPortrait(activeItem.ownerEntityId()), "BackArmArmor")
			
			armInfo.frontarmarmordirectives = getDirectives(autoPortrait(activeItem.ownerEntityId()), "FrontArmArmor")
			armInfo.frontarmarmor = getDirectory(autoPortrait(activeItem.ownerEntityId()), "FrontArmArmor")
			
			--sb.logInfo(sb.printJson(armInfo, 1))
		end
	end
end

function init()
	activeItem.setScriptedAnimationParameter("info", {entityId = activeItem.ownerEntityId(), uniqueId = world.entityUniqueId(activeItem.ownerEntityId())})
	activeItem.setScriptedAnimationParameter("drawables", {
			--{image = "/items/gunsbound/sprite/guns/9mmParabellum/HKMP5A2/icon.png", position = {1 , -1}}
		} 
	)
	for i,v in pairs(config.getParameter("giveBack", {})) do
		player.giveItem(v)
	end
	activeItem.setInstanceValue("giveBack", {})
	
	activeItem.setFrontArmFrame("rotation?scale=0.01")
	activeItem.setBackArmFrame("rotation?scale=0.01")
	
	--gets configs of the gun
	self.gunConfig = config.getParameter("gunConfig"
	--,
	--{	
	--		projectileType = "bullet-4", 
	--		fireOffset = {0,0}, 
	--		fireSpeed = 0.06, 
	--		fireMode = "auto", 
	--		recoilPower = 10, 
	--		recoilRecovery = 4,
	--		magazineMax = false,
	--		magazineCurrent = 0,
	--		reloadCooldown = 0.5
	--}
	)
	
	if not self.gunConfig.magazineCurrent then
		self.gunConfig.magazineCurrent = 0
	end
	
	
	--load animation tracks from item
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
	
	--loadup set parts from item
	parts = config.getParameter("parts", {gun_x = 0, gun_y = 0, gun_rotation = 0})
	--arm offset i think
	parts.armangle = 0
	
	local itemInfo = root.itemConfig({count = 1, name = config.getParameter("itemName")}, 1, 01)
	
	transform = root.assetJson(itemInfo.directory.."gunsprite.animation").transformationGroups
	
	--attachments
	
	--resets
	
	--loads
	for i,v in pairs(self.gunConfig.attachments) do
		if v.attachementInfo then
			if v.attachementInfo.script then
				self.gunConfig.attachments[i].instance = require(v.attachementInfo.script)
			end
			
			if v.attachementInfo.image then
				animator.setGlobalTag("a_"..i, v.attachementInfo.image)
			else
				animator.setGlobalTag("a_"..i, "")
			end
			
			if v.attachementInfo.replaceFireSound and self.gunConfig.gunSounds and #self.gunConfig.gunSounds > 0 then
				for i,v in pairs(self.gunConfig.gunSounds) do
					if animator.hasSound(v) then
						animator.setSoundPool(v, {"/assetmissing.ogg"})
					end
				end
				
				animator.setSoundPool(self.gunConfig.gunSounds[1], {v.attachementInfo.replaceFireSound})
			end
			
			if v.attachementInfo.offset then
				animator.resetTransformationGroup("a_"..i)
				animator.translateTransformationGroup("a_"..i, v.attachementInfo.offset)
			else
				animator.resetTransformationGroup("a_"..i)
			end
			
			if v.attachementInfo.hideMag and self.gunConfig.magToHideTransform and animator.hasTransformationGroup(self.gunConfig.magToHideTransform) then --for custom magazines
				animator.scaleTransformationGroup(self.gunConfig.magToHideTransform , {0,0})
			end
			
			if v.attachementInfo.stats then
				self.gunConfig.inaccuracy = math.max(self.gunConfig.inaccuracy * (v.attachementInfo.stats.inaccuracy or 1),0)
				self.gunConfig.recoilPower = math.max(self.gunConfig.recoilPower * (v.attachementInfo.stats.recoilPower or 1),0)
				self.gunConfig.recoilRecovery = math.max(self.gunConfig.recoilRecovery * (v.attachementInfo.stats.recoilRecovery or 1),0)
				self.gunConfig.magazineMax = v.attachementInfo.stats.magazineMax or self.gunConfig.magazineMax
				if type(v.attachementInfo.stats.smokeEffect) == "boolean" then
					self.gunConfig.smokeEffect = v.attachementInfo.stats.smokeEffect
				end
				if type(v.attachementInfo.stats.muzzleEffect) == "boolean" then
					self.gunConfig.muzzleEffect = v.attachementInfo.stats.muzzleEffect
				end
				if type(v.attachementInfo.stats.shellEffect) == "boolean" then
					self.gunConfig.shellEffect = v.attachementInfo.stats.shellEffect
				end
				self.gunConfig.fireSpeed = math.max(self.gunConfig.fireSpeed * (v.attachementInfo.stats.fireSpeed or 1),0)
			end
		end
	end
	
	updateAnimation() --Components update
	updateAim()
	--self.barUUID = sb.makeUuid()
	--sb.logInfo(sb.printJson(self.gunConfig,1))
	playAnimation("load")
end

function uninit() --unload
	if self.gunConfig.magazineMax then
		local changedgunConfig = config.getParameter("gunConfig")
		changedgunConfig.magazineCurrent = self.gunConfig.magazineCurrent 
		activeItem.setInstanceValue("gunConfig", changedgunConfig)
		--world.sendEntityMessage(activeItem.ownerEntityId(),"removeBar",config.getParameter("itemName")..self.barUUID) --deletes bar
	end
end

function update(dt, fireMode, shiftHeld, moves) --main thread
	
	activeItem.setScriptedAnimationParameter("particles", {
			{
				timeToLive = 1/64,
				color =  { 255, 255, 255, 255 },
				initialVelocity = {0,0},
				finalVelocity = {0,0},
				approach = {0,0},
				flippable = false,
				fullbright = true,
				text = "Mag:"..tostring(self.gunConfig.magazineCurrent),
				layer = "front",
				position = {1, -1},
				size = 0.5,
				type = "text"
			}
		} 
	)
	
	getArmInfo()
	
	if not self.loaded and animation.doneplaying == "load" then --init animation
		self.loaded = true
		if animator.hasSound("reloadEnd") then
			animator.playSound("reloadEnd")
		end
	end
	
	--Cooldown timer
	if cooldown > 0 then
		cooldown = cooldown - dt
	else
		activeItem.setRecoil(false)
	end
	
	if self.reloading and animation.doneplaying == "reload" then
		self.reloading = false
		while player.hasItem(self.gunConfig.compatibleAmmo[1]) and self.gunConfig.magazineCurrent < self.gunConfig.magazineMax do
			player.consumeItem(self.gunConfig.compatibleAmmo[1])
			self.gunConfig.magazineCurrent = self.gunConfig.magazineCurrent + 1
		end
		if animator.hasSound("reloadEnd") then
			animator.playSound("reloadEnd")
		end
	end
	
	--up to reload
	if not self.reloading and self.gunConfig.reloadForce and cooldown <=0 or (moves.up and self.gunConfig.magazineCurrent < self.gunConfig.magazineMax and cooldown <=0 ) then	
		magreload()
	end
	
	--Smoke timer after shot
	if smoke > 0 and cooldown <= 0 then
		smoke = smoke - dt
		if smoke < 1.5 and self.gunConfig.smokeEffect then
			animator.burstParticleEmitter("smoke")
		end
	end
	
	--idk
	if self.gunConfig.magazineMax then
		if not self.reloading then
			local percent = self.gunConfig.magazineCurrent/self.gunConfig.magazineMax
			--world.sendEntityMessage(activeItem.ownerEntityId(),"setBar",config.getParameter("itemName")..self.barUUID,percent,{255-math.ceil(255*percent),127+math.ceil(128*percent),0,255})
		else
			--world.sendEntityMessage(activeItem.ownerEntityId(),"setBar",config.getParameter("itemName")..self.barUUID,1-cooldown/self.gunConfig.reloadCooldown,{255,128,0,255})
		end
	end
	
	--recoil accuracy calculation
	if mcontroller.crouching() then
		recoil = recoil - (recoil / (self.gunConfig.recoilRecovery * 0.8))
	else
		recoil = recoil - (recoil / self.gunConfig.recoilRecovery)
	end
	
	--components update
	if self.loaded then
		updateFire(dt, fireMode, shiftHeld)
	end
	updateAnimation()
	updateAim()
	updateDrawable()
end

function updateFire(dt, fireMode, shiftHeld) --update if firing
	--auto mode
	if fireMode == "primary" and self.gunConfig.fireMode == "auto" and cooldown <= 0 then
		shoot()
	end
	
	--semi mode
	if fireMode == "primary" and self.gunConfig.fireMode == "semi" and cooldown <= 0 and not self.onetap then
		shoot()
		self.onetap = true
		elseif self.onetap and fireMode ~= "primary" then
		self.onetap = nil
	end
	
	--fixed shots click mode
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
	--
end

function updateDrawable() --drawables/transform apply
	animator.setGlobalTag("species", armInfo.species)

	if activeItem.hand() == "primary" or config.getParameter("twoHanded", false) then
		
		animator.setGlobalTag("armbackdirectives", armInfo.skindirectives)
		animator.setGlobalTag("armback", armInfo.backarm)
		
		if armInfo.backarmarmor then
			animator.setGlobalTag("armbackarmor", armInfo.backarmarmor..":"..armInfo.backarm..armInfo.backarmarmordirectives)
		else
			animator.setGlobalTag("armbackarmor", "")
		end
	else
		animator.setGlobalTag("armback", "")
		animator.setGlobalTag("armbackarmor", "")
	end
	
	if activeItem.hand() == "alt" or config.getParameter("twoHanded", false) then
		animator.setGlobalTag("armfrontdirectives", armInfo.skindirectives)
		animator.setGlobalTag("armfront", armInfo.frontarm)
		
		if armInfo.frontarmarmor then
			animator.setGlobalTag("armfrontarmor", armInfo.frontarmarmor..":"..armInfo.frontarm..armInfo.frontarmarmordirectives)
		else
			animator.setGlobalTag("armfrontarmor", "")
		end
	else
		animator.setGlobalTag("armfront", "")
		animator.setGlobalTag("armfrontarmor", "")
	end
	
	for i,v in pairs(transform) do
		--Resets so it doesnt break
		if parts[i.."_rotation"] or parts[i.."_xRot"] or parts[i.."_yRot"] or parts[i.."_x"] or parts[i.."_y"] then
			animator.resetTransformationGroup(i)
		end
		
		--rotation
		if parts[i.."_rotation"] then
			if parts[i.."_xRot"] and parts[i.."_yRot"] then
				animator.rotateTransformationGroup(i, math.rad(parts[i.."_rotation"]), {parts[i.."_xRot"], parts[i.."_yRot"]})
			else
				animator.rotateTransformationGroup(i, math.rad(parts[i.."_rotation"]))
			end
		end
		
		--position
		if parts[i.."_x"] and parts[i.."_y"] then
			animator.translateTransformationGroup(i, {parts[i.."_x"], parts[i.."_y"]})
		end
	end
	
	--might change stuff here idk
	animator.resetTransformationGroup("muzzle")
	animator.translateTransformationGroup("muzzle", self.gunConfig.fireOffset or {0,0})
	animator.resetTransformationGroup("case")
	animator.translateTransformationGroup("case", self.gunConfig.shellOffset or {0,0})
end

function updateAim() --aiming update

	--aiming
	self.aimAngle, self.facingDirection = activeItem.aimAngleAndDirection(0, vec2.sub(activeItem.ownerAimPosition(), {0, self.gunConfig.fireOffset[2]})) --get aim
	lerpedrecoil = lerp(lerpedrecoil, recoil, 2) --Smoothing recoil visual
	activeItem.setArmAngle(self.aimAngle + math.rad(lerpedrecoil)	+ math.rad(parts.armangle)) --applies arm visuals
	
	--facing
	activeItem.setFacingDirection(self.facingDirection)
end

function lerp(value, to, speed) --api do not tamper
	return value + ((to - value ) / speed ) 
end

function magreload() --reload function
	if not self.reloading and player.hasItem(self.gunConfig.compatibleAmmo[1]) then
		
		if animator.hasSound("reload") then
			animator.playSound("reload")
		end
		self.gunConfig.reloadForce = false
		self.reloading = true
		cooldown = 0
		playAnimation("reload")
	end
end

function shoot() --Shooting request
	if self.gunConfig.compatibleAmmo and not self.reloading then
		
		local itemammo = nil
		
		if self.gunConfig.magazineMax then
			if self.gunConfig.magazineCurrent > 0 then
				self.gunConfig.magazineCurrent = self.gunConfig.magazineCurrent - 1
				itemammo = true
			elseif player.hasItem(self.gunConfig.compatibleAmmo[1]) and cooldown <= 0 then
				magreload()
				return
			else
				animator.playSound("dry")
				smoke = 0
				activeItem.setRecoil(false)
				if self.gunConfig.magazineCurrent == 0 then
					cooldown = 0.5
				end
				return
			end
		else
			itemammo = player.consumeItem(self.gunConfig.compatibleAmmo[1])
		end
		
		if itemammo then --Ammo found!!
		
			local projectile = "bullet-2" --projectile default name
			local projectileconf = {}
			
			projectile = self.gunConfig.projectileType or "bullet-2"	--get projectile name **Might make some changes here
			projectileconf = copy(self.gunConfig.projectileConfig or {})	--multiplier dmg
			projectileconf.powerMultiplier = activeItem.ownerPowerMultiplier()	--multiplier dmg

			playAnimation("shoot") --Play animation track shoot
			
			world.spawnProjectile( --pew pew
				projectile,
				offset(),
				activeItem.ownerEntityId(),
				aim(),
				false,
				projectileconf
			)
			
			smoke = 2 --set smoke timer
			recoil = recoil + self.gunConfig.recoilPower --add recoil
			cooldown = self.gunConfig.fireSpeed or 0.1 --add cool timer
			activeItem.setRecoil(true)
			if self.gunConfig.muzzleEffect then
				animator.setAnimationState("firing", "fire")
			end
			
			if self.gunConfig.magazineCurrent == 0 then
				cooldown = 0.1
			end
			
			if self.gunConfig.shellEffect then --casing effect
				animator.burstParticleEmitter("case")
			end
			
			for _,v in pairs(self.gunConfig.gunSounds) do --sfx
				if animator.hasSound(v) then
					animator.playSound(v)
				end
			end
			
		else --Ammo not found
			if animator.hasSound("dry") then --sound empty
				animator.playSound("dry")
			end
			smoke = 0
			activeItem.setRecoil(false)
			if self.gunConfig.magazineCurrent == 0 then
				cooldown = 0.1
			end
			recoil = recoil + 1
		end
		
	end
end

function posi(val) --api do not tamper
	if val > 0 then
		return val
	else
		return -val
	end
end

function offset() --Projectile init position??
	local offset = {mcontroller.position()[1] + vec2.rotate(activeItem.handPosition(self.gunConfig.fireOffset), mcontroller.rotation())[1], mcontroller.position()[2] + vec2.rotate(activeItem.handPosition(self.gunConfig.fireOffset), mcontroller.rotation())[2]}
	return offset
end

function aim() --Aiming system
  local randoms = 0
  
  local inaccuracy = self.gunConfig.inaccuracy or 45
  
  if not (mcontroller.xVelocity() < 1 and mcontroller.xVelocity() > -1) then -- running
	randoms = (math.random (0,20 * math.floor(math.min(posi(mcontroller.xVelocity()), inaccuracy))) - 10 * math.floor(math.min(posi(mcontroller.xVelocity()), inaccuracy))) / 10
  end
  
  if not mcontroller.onGround() then --jumping
	randoms = (math.random (0,20 * math.floor(math.min(inaccuracy, inaccuracy))) - 10 * math.floor(math.min(inaccuracy, inaccuracy))) / 10
  end
  
  local aimVector = vec2.rotate({1, 0}, self.aimAngle + math.rad(recoil) + math.rad(parts.armangle) + math.rad(randoms))
  aimVector[1] = aimVector[1] * self.facingDirection
  aimVector[2] = aimVector[2]
  return aimVector --final
end
