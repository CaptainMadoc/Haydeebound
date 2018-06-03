transforms = {
	updateChild = {},
	lateUpdateChild = {},

	original = {},
	current = {},
}

function dp(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[dp(orig_key)] = dp(orig_value)
        end
        setmetatable(copy, dp(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function vec2lerpR(a,b,r)
	return {
		a[1] + (b[1] - a[1]) * r[1],
		a[2] + (b[2] - a[2]) * r[2]	
	}
end

function transforms:add(name,tr,updatefunc)
	transforms.original[name] = dp(tr)
	self.updateChild[name] = updatefunc
end

function transforms:lateAdd(name,tr,updatefunc)
	transforms.original[name] = dp(tr)
	self.lateUpdateChild[name] = updatefunc
end

function transforms.calculateTransform(tab)
	local new = {
		scale = tab.scale or {1,1},
		scalePoint = tab.scalePoint or {0,0},
		position = vec2.mul(tab.position or {0,0}, tab.scale or {1,1}),
		rotation = tab.rotation or 0,
		rotationPoint = vec2lerpR(tab.scalePoint, tab.rotationPoint, tab.scale)
	}
	return new
end

function transforms:init()
	message.setHandler("getTransforms", function(_, loc, ...) if loc then return self.original end end)
	transforms:update(1/62)
end

function transforms:apply(name, tr)
	if self.original[name] then
		self.current[name] = sb.jsonMerge(dp(self.original[name]), tr)
	end
end

function transforms:update(dt)
	for i,v in pairs(self.current) do
		if type(self.updateChild[i]) == "function" then
			self.updateChild[i](i, v, dt)
		end
	end
	for i,v in pairs(self.current) do
		if type(self.lateUpdateChild[i]) == "function" then
			self.lateUpdateChild[i](i, v, dt)
		end
	end
end

addClass("transforms", 900)