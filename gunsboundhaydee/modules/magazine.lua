magazine = {
	storage = {
	}
}

function magazine:processCompatible(a)
	if type(a) == "string" then
		return root.assetJson(a)
	end
	return a
end

function magazine:insert(co)
	local compat = config.getParameter("compatibleAmmo", jarray())
	if type(compat) == "string" then
		compat = processDirectory(compat)
	end
	if not co then
		co = weapon.stats.maxMagazine - #self.storage
	end
	for i,v in pairs(self:processCompatible(compat)) do
		if co > 0 then
			if player.hasItem({name = v, count = 1}) then
				local con = player.consumeItem({name = v, count = co}, true)
				
				for i = 1,con.count do
					table.insert(self.storage, {name = v, count = 1, parameters = con.parameters or {}})
					co = co - 1
				end
			end
		end
	end
	activeItem.setInstanceValue("magazine", self.storage)
end

function magazine:playerHasAmmo()

	local compat = config.getParameter("compatibleAmmo", jarray())
	if type(compat) == "string" then
		compat = processDirectory(compat)
	end
	for i,v in pairs(self:processCompatible(compat)) do
		if player.hasItem({name = v, count = 1}) then
			return true
		end
	end
	return false
end

function magazine:remove()
	local togive = jarray()
	for i,v in pairs(self.storage) do
		if #togive == 0 then
			table.insert(togive,v)
		else
			local matched = false
			for i2,v2 in pairs(togive) do
				if sb.printJson(v.parameters) == sb.printJson(v2.parameters) and v.name == v2.name then
					matched = true
					togive[i2].count = togive[i2].count + v.count
				end
			end
			if not matched then
				table.insert(togive, v)
			end
		end
	end
	for i,v in pairs(togive) do
		player.giveItem(v)
	end
	self.storage = jarray();
	activeItem.setInstanceValue("magazine", self.storage)
end

function magazine:init()
	self.storage = config.getParameter("magazine", jarray())
	
end

function magazine:lateinit()
	animation:addEvent("insert_mag", function() magazine:insert() end)
	animation:addEvent("insert_bullet", function() magazine:insert(1) end)
	animation:addEvent("remove_mag", function() magazine:remove() end)
end

function magazine:take()
	if #self.storage > 0 then
		local ammoPull = self.storage[#self.storage]
		table.remove(self.storage,#self.storage)
		activeItem.setInstanceValue("magazine", self.storage)
		return ammoPull
	end
	return nil
end

function magazine:update(dt)
	activeItem.setScriptedAnimationParameter("magazine", self.storage)
	activeItem.setScriptedAnimationParameter("maxMagazine", weapon.stats.maxMagazine or 30)
end

function magazine:uninit()
	activeItem.setInstanceValue("magazine", self.storage)
end

addClass("magazine", -2)