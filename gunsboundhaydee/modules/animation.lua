animation = {
	transforms = {},
	list = {},
	events = {},
	
	--
	from = nil,
	current = nil,
	to = {
		
	}
}

function randomHash()
	local str1 = ""
	for i = 1,8 do
		str1 = str1..string.format("%X", math.random(255))
	end
	return str1
end

function animation:interpolateTransforms(tr, timing)
	if self.current then
		self.from = dp(self.current)
	end
	animation:initTC()
	
	self.to = sb.jsonMerge(transforms.original, dp(tr))
	
	for i,v in pairs(self.to) do
		self.to[i].time = timing
	end
end

function animation:forceTransforms(tr, timing)
	animation:initTC()
	self.current = sb.jsonMerge(self.current, dp(tr))
	for i,v in pairs(self.current) do
		self.current[i].time = 0
	end
	self.from = dp(tr)
	self.to = dp(tr)
	
	for i,v in pairs(self.to) do
		self.to[i].time = timing
		if self.from[i] then
			self.from[i].time = timing
		end
	end
end

function animation:initTC()
	self.current = dp(transforms.original)
	for i,v in pairs(self.current) do
		self.current[i].time = 0
	end
end

function animation:initTF()
	self.from = dp(transforms.original)
end

function animation:add(name, keyFrames, delete)
	self.list[name] = {
		playing = false,
		played = 0,
		current = 1,
		waiting = 0,
		deleteOnFinished = delete,
		keyFrames = keyFrames
	}
end

function animation:play(str)
	if type(str) == "table" then
		local randhash = randomHash()
		animation:add(randhash, str, true)
		animation:play(randhash)
		return randhash
	end

	if not self.list[str] then return end
	if not self.list[str].keyFrames then sb.logWarn("keyFrames is nil") return end
	if #self.list[str].keyFrames == 0 then sb.logWarn("keyFrames contains nothing") return end

	if self.list[str].playing then self:skip(str) end --Skip since its already playing

	self.list[str].playing = true
	self.list[str].played = self.list[str].played + 1
	self.list[str].current = 1
	self.list[str].waiting = self.list[str].keyFrames[self.list[str].current].wait or 0
	animation:applykeyFrames(self.list[str].keyFrames[self.list[str].current], self.list[str].keyFrames[self.list[str].current].wait, true)
	return true
end

function animation:isPlaying(str)
	if type(str) == "table" then
		for i,v in ipairs(str) do
			if self:isPlaying(v) then
				return true
			end
		end
		return false
	end
	if not self.list[str] then return false end
	return self.list[str].playing
end

function animation:isAnyPlaying(str)
	local p = false
	for i,v in pairs(self.list) do if v.playing then p = true end end
	return p
end

function animation:addEvent(str,func)
	self.events[str] = func
end

function animation:fireEvent(str)
	if type(str) == "string" and self.events[str] then
		self.events[str]()
	end
end

function animation:applykeyFrames(key,timing,force)
	self.transforms = {}
	if not key then return end
	for transformName,transform in pairs(key.transforms) do
		if not self.transforms[transformName] then self.transforms[transformName] = {} end
		for property, value in pairs(transform) do
			self.transforms[transformName][property] = value
		end
	end

	if force then
		self:forceTransforms(dp(key.transforms), timing)
	else
		self:interpolateTransforms(dp(key.transforms), timing)
	end
	
	for i,v in pairs(key.playSounds or {}) do
		if type(v) == "string" and type(i) == "number" then
			if animator.hasSound(v) then
				animator.playSound(v)
			end
		else
			sb.logWarn("Invalid playSounds input")
		end
	end
	for i,v in pairs(key.animationState or {}) do
		if type(v) == "string" and type(i) == "string" then
			animator.setAnimationState(i,v)
		else
			sb.logWarn("Invalid animationState input")
		end
	end
	for i,v in pairs(key.burstParticle or {}) do
		if type(v) == "string" and type(i) == "number" then
			animator.burstParticleEmitter(v)
		else
			sb.logWarn("Invalid burstParticle input")
		end
	end
	for i,v in pairs(key.lights or {}) do
		if type(v) == "bool" and type(i) == "string" then
			animator.setLightActive(i,v)
		else
			sb.logWarn("Invalid lights input")
		end
	end
	for i,v in ipairs(key.fireEvents or {}) do
		self:fireEvent(v)
	end
end

function animation:skip(str)
	if self.list[str] and self.list[str].playing then
		self:applykeyFrames(self.list[str].keyFrames[#self.list[str].keyFrames], 0)
		self.list[str].playing = false
		self.list[str].current = #self.list[str].keyFrames
		self.list[str].waiting = 0
	end
	return false
end

function animation:skipAll(str)
	for i,v in pairs(self.list) do
		if self.list[i].playing then
			animation:skip(i)
		end
	end
end

function animation:init()
	local ani = config.getParameter("animationsKeyFrames", {})
	if type(ani) == "string" then
		ani = root.assetJson(pD(ani), {})
	end
	for i,v in pairs(ani) do
		self:add(i,v)
	end
	
	local configanimation = config.getParameter("animation")
	local animations = {}
	
	if configanimation then
		animations = root.assetJson(itemDir(configanimation), {})
	end
	local animationCustom = config.getParameter("animationCustom", {})
	local animationTranformationGroup = sb.jsonMerge(animationCustom, animations).transformationGroups or {} 
	
	for i,v in pairs(animationTranformationGroup) do
		if not v.ignore then
			local newtrans = {position = {0,0}, scale = {1,1}, scalePoint = {0,0}, rotation = 0, rotationPoint = {0,0}}
			if v.transform then
				newtrans = sb.jsonMerge(newtrans, v.transform)
			end
			transforms:add(i, newtrans,
				function(name,thisTransform, dt) 
					if animator.hasTransformationGroup(name) then --Check to prevent crashing
						local setting  = transforms.calculateTransform({
							position = thisTransform.position or {0,0},
							scale = thisTransform.scale or {1,1},
							scalePoint = thisTransform.scalePoint or {0,0},
							rotation = thisTransform.rotation or 0,
							rotationPoint = thisTransform.rotationPoint or {0,0}
						})
						
						animator.resetTransformationGroup(name) 
						animator.scaleTransformationGroup(name, setting.scale, setting.scalePoint)
						animator.rotateTransformationGroup(name, util.toRadians(setting.rotation), setting.rotationPoint)
						animator.translateTransformationGroup(name, setting.position)
					end
				end
			)
		end
	end


	message.setHandler("play", function(_, loc, tr) if loc then self:play(tr) end end)
	message.setHandler("isAnyPlaying", function(_, loc) if loc then return self:isAnyPlaying() end end)
	message.setHandler("setTransforms", function(_, loc, tr) if loc then self:forceTransforms(tr, 0) end end)
end

function animation:update(dt)
	for str,v in pairs(self.list) do
		if v.playing then
			self.list[str].waiting = math.max(self.list[str].waiting - dt, 0)

			--animation keyFrames switch
			if self.list[str].waiting == 0 and #self.list[str].keyFrames > v.current then
				self.list[str].current = v.current + 1
				self.list[str].waiting = self.list[str].keyFrames[v.current].wait
				self:applykeyFrames(self.list[str].keyFrames[v.current], self.list[str].keyFrames[v.current].wait)
			elseif self.list[str].waiting == 0 and #self.list[str].keyFrames == v.current then --end of animation
				self.list[str].playing = false
				self.list[str].current = v.current + 1
				--self:applykeyFrames({transforms = {}}, 0.02)
				if self.list[str].deleteOnFinished then
					self.list[str] = nil
				end
			end
		end
	end
	
	if not self.current then
		self:initTC()
	end
	if not self.from then
		self:initTF()
	end
	
	--local int = 1
	
	for i,v in pairs(self.current) do
		if not self.to[i] then
			self.to[i] = dp(transforms.original[i])
			self.to[i].time = 1
		end
		if not self.from[i] then
			self.from[i] = dp(transforms.original[i])
			self.from[i].time = 1
		end
		
		if self.to[i] then
			self.current[i].time = math.min(self.current[i].time + dt, self.to[i].time)
			local timeRatio = (self.current[i].time / self.to[i].time) ^ (self.to[i].curve or 0)
			for property, value in pairs(v) do
				if property ~= "time" and property ~= "curve" and self.from[i][property] then
					if not self.to[i][property] then
						
					elseif type(value) == "table" and #value == 2 then
						self.current[i][property][1] = self.from[i][property][1] + ((self.to[i][property][1] - self.from[i][property][1]) * timeRatio)
						self.current[i][property][2] = self.from[i][property][2] + ((self.to[i][property][2] - self.from[i][property][2]) * timeRatio)
					elseif type(value) == "number" then
						self.current[i][property] = self.from[i][property] + ((self.to[i][property] - self.from[i][property]) * timeRatio)
					end
				end
			end
		end
		transforms:apply(i, self.current[i])
		--world.debugText(i.." = "..sb.print(v), "", vec2.add(mcontroller.position(), {0,1 + int * 0.5}), "green")
		--int = int + 1
	end
end

addClass("animation", 705)