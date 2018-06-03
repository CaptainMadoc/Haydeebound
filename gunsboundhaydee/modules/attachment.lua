attachment = {
	statsInited = false,
	config = {},
	modules = {},
	loadedScripts = {},
	special = nil
}

function attachment:loadmodule(script)
	if not self.loadedScripts[script] then
		require(script)
	end
	if module then
		self.loadedScripts[script] = module
		module = nil
	end
	if self.loadedScripts[script] then
		return self.loadedScripts[script]
	end
end

function attachment:activate(fireMode, shiftHeld)
	if fireMode == "alt" and not shiftHeld then
		if self.special and self.modules[self.special] and self.modules[self.special].fireSpecial then
			self.modules[self.special]:fireSpecial(fireMode, shiftHeld)
		end
	end
end

function attachment:init()
	self.gunPart = config.getParameter("attachments_gunPart")
	self.config = config.getParameter("attachments")
	for i,v in pairs(config.getParameter("giveback", {})) do
		player.giveItem(v)
	end
	activeItem.setInstanceValue("giveback", jarray())
end

function attachment:createTransform(name, offset, scale, attachPart, gunTag, gunTagEnd)
	local somenewTransform = function(name, this, dt)
		if animator.hasTransformationGroup(name) then --Check to prevent crashing
			local setting  = {
				position = vec2.add(animator.partPoint(attachPart, gunTag), vec2.mul(offset or {0,0}, scale or {1,1})),
				scale = scale or {1,1},
				scalePoint = {0,0},
				rotation = vec2.angle(vec2.sub(animator.partPoint(attachPart, gunTagEnd), animator.partPoint(attachPart, gunTag))) or 0,
				rotationPoint = vec2.mul(offset or {0,0}, -1)
			}
			animator.resetTransformationGroup(name) 
			animator.scaleTransformationGroup(name, setting.scale, setting.scalePoint)
			animator.rotateTransformationGroup(name, setting.rotation, vec2.mul(setting.rotationPoint,setting.scale))
			animator.translateTransformationGroup(name, setting.position)
		end
	end
	transforms:lateAdd("attachment_"..name, {}, somenewTransform)
end

function attachment:lateinit() --item check
	for i,v in pairs(self.config) do
		if v.item then
			local originalItem = root.createItem({name = v.item.name, count = 1})
			local fp = {}
			if originalItem then
				fp = sb.jsonMerge(root.itemConfig(v.item).config, v.item.parameters) -- v.item.parameters
				local current;
				if fp.attachment then
					animator.setPartTag(v.part, "selfimage", fp.attachment.image)
					attachment:createTransform(i,fp.attachment.offset, fp.attachment.scale, v.attachPart, v.gunTag, v.gunTagEnd)
					if fp.attachment.script then
						self.modules[i] = self:loadmodule(fp.attachment.script):create(fp.attachment, i)
						if self.modules[i].special then
							self.special = i
						end
					end
				end
			end
		end
	end
	--attachment:updateParts()
end

function attachment:debug(dt)
	for i,v in pairs(self.config) do
		world.debugPoint(weapon:rel(animator.partPoint(v.attachPart, v.gunTag)), "blue")
	end
end

function vec2div2(vector, scalar_or_vector)
	if type(scalar_or_vector) == "table" then
	  return {
	    vector[1] / scalar_or_vector[1],
	    vector[2] / scalar_or_vector[2]
	  }
	else
	  return {
	    vector[1] / scalar_or_vector,
	    vector[2] / scalar_or_vector
	  }
	end
end


function attachment:update(dt)
	self:debug(dt)
	for i,v in pairs(self.modules) do
		if self.modules[i].update then
			self.modules[i]:update(dt)
		end
	end
end

function attachment:uninit()
	for i,v in pairs(self.modules) do
		if self.modules[i].uninit then
			self.modules[i]:uninit(dt)
		end
	end
end

addClass("attachment", 25)
