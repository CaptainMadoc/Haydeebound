aim = {
	current = 0,
	target = 0,
	dir = 1,
	disabled = false,
	anglesmooth = 2,
	armoffset = 0
}

function aim:lerp(value, to, speed)
	return value + ((to - value ) / speed ) 
end

function aim:init()
	message.setHandler("disableAim", function(_, loc) if loc then self.disabled = true end end)
	message.setHandler("enableAim", function(_, loc) if loc then self.disabled = false end end)
end

function aim:update(dt)
	if self.disabled then
		activeItem.setArmAngle(0)
		return
	end
	self.current = self:lerp(self.current, self.target, math.max(self.anglesmooth / (dt * 60), 1)) --smoothing aim
	activeItem.setArmAngle(math.rad(self.current + self.armoffset)) --applies aiming
	activeItem.setFacingDirection(self.dir)
end

addClass("aim", 500)