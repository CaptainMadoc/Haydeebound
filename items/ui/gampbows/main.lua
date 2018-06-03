require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/poly.lua"

enabled = false
localmessage = nil
messaged = false
ownerid = 0
position = {0,0}
data = {}

function lerp(a,b,r)
	if type(a) == "table" then
		if type(b) == "number" then
			b = {b, b}
		end
		return {a[1] + (b[1] - a[1]) * r, a[2] + (b[2] - a[2]) * r}
	end
	return a + (b - a) * r
end

function update(dt)
	localAnimator.clearDrawables()
	localAnimator.clearLightSources()
	
	if animationConfig.animationParameter("entityID") and not localmessage and not messaged then
		localmessage = world.sendEntityMessage(animationConfig.animationParameter("entityID"), "isLocal")
		ownerid = animationConfig.animationParameter("entityID")
	end
	
	if enabled then
		data:update(dt)
		realUpdate(dt)
	elseif localmessage and localmessage:finished() then	
		enabled = localmessage:result()
		if enabled then
			realInit(dt)
		end
		messaged = true
	end
	
	updateFX(dt)
end

function partOffset(s, e, off)
	local angle = vec2.angle(vec2.sub(e, s))
	local e2 = vec2.add(vec2.rotate(e, -angle), off)
	return vec2.rotate(e2, angle)
end

function cb(s, e)
	local c = world.lineCollision(vec2.add(activeItemAnimation.ownerPosition(), activeItemAnimation.handPosition(s)), vec2.add(activeItemAnimation.ownerPosition(), activeItemAnimation.handPosition(e)))
	
	if not c then
		return activeItemAnimation.handPosition(e)
	end
	return vec2.sub(c,activeItemAnimation.ownerPosition())
end

function updateFX(dt)
	local f = animationConfig.animationParameter("flashlight") or {}
	for i,v in pairs(f) do
		local start = animationConfig.partPoint(i, v.tag)
		local e = animationConfig.partPoint(i, v.tagEnd)
		localAnimator.addLightSource(
			{
				position = vec2.add(activeItemAnimation.ownerPosition(), activeItemAnimation.handPosition(start)),
				color = v.lightColor,
				pointLight = true,
				pointBeam = 6,
				beamAngle = vec2.angle(vec2.sub(activeItemAnimation.handPosition(e), activeItemAnimation.handPosition(start)))
			}
		)
	end
	
	local l = animationConfig.animationParameter("laser") or {}
	for i,v in pairs(l) do
		local start = animationConfig.partPoint(i, v.tag)
		local e = animationConfig.partPoint(i, v.tagEnd)
		localAnimator.addDrawable(
			{
				width = 0.5, 
				position = activeItemAnimation.ownerPosition(),
				line = {activeItemAnimation.handPosition(start), cb(start, partOffset(start, e, {50,0}))},
				color = v.laserColor,
				fullbright = true
			}
		)
	end
end

function data:update(dt)
	for i,v in pairs(self) do
		if i ~= "update" then
			local pull = animationConfig.animationParameter(i)
			if type(pull) ~= "nil" then
				self[i] = pull
			end
		end
	end
end

function realInit(dt)
	data["magazine"] = 30
	data["maxMagazine"] = 30
	data["load"] = false
	data["fired"] = false
	data["fireSelect"] = "auto"
	data["inAccuracy"] = 1
	data["muzzleDistance"] = {0,0}
	position = activeItemAnimation.ownerPosition()
end

function circle(d,steps)
	local pos = {d,0}
	local pol = {}
	for i=1,steps do
		table.insert(pol,pos)
		pos = vec2.rotate(pos, math.rad(360 / steps))
	end
	return pol
end

function realUpdate(dt)
	localAnimator.clearDrawables()
	position = lerp(position, activeItemAnimation.ownerPosition(), 0.5)
	
	--ammo Display
	local matt = {
		{15 / data["maxMagazine"],0,0},
		{0,1,0},
		{0,0,1}
	}
	local shift = (-0.0625) * (30 / data["maxMagazine"])
	
	local ratio1 = 1
	if data["fired"] == true then
		ratio1 = 2
	end
	
	if data["load"] == "table" then
		localAnimator.addDrawable({image = "/items/ui/gampbows/ammo.png", position = vec2.add(position, {0, -3}), transformation = matt, fullbright = true, color = {255,255 / ratio1,255 / ratio1,255}}, "overlay")
		shift = 0
	end
	
	for i = 1,data["magazine"] do
		localAnimator.addDrawable({image = "/items/ui/gampbows/ammo.png", position = vec2.add(position, {((2.5 / data["maxMagazine"]) * i) + shift, -3.25}), transformation = matt, fullbright = true}, "overlay")
	end
	
	--Fire mode display
	if data["fireSelect"] then
		localAnimator.addDrawable({image = "/items/ui/gampbows/"..data["fireSelect"]..".png", position = vec2.add(activeItemAnimation.ownerAimPosition(), {0, -1}), fullbright = true}, "overlay")	
	end
	
	--crosshair radius
	local distance = (math.abs(data["muzzleDistance"][2]) + math.abs(data["muzzleDistance"][1])) / 2
	local cir = circle((0.125 + (data["inAccuracy"] / 45) * distance) ,16)
	for i=2,#cir do
		localAnimator.addDrawable({line = {cir[i - 1], cir[i]},width = 1, color = {255,255,255,72},fullbright = true, position = activeItemAnimation.ownerAimPosition()}, "overlay")
	end
	localAnimator.addDrawable({line = {cir[1], cir[#cir]},width = 1, color = {255,255,255,72},fullbright = true, position = activeItemAnimation.ownerAimPosition()}, "overlay")
end