require "/scripts/augments/item.lua"

function apply(input)
	local override = config.getParameter("gunConfig")
	local output = Item.new(input)
	
	local ammoItem
	local ammoKind
	
	if override.compatibleAmmo then -- compatibleAmmo should contain the [item that will be consumed, general category of ammo this gun accepts]
		ammoItem = override.compatibleAmmo[1]
		ammoKind = override.compatibleAmmo[2]
	else
		return nil
	end
	
	override.compatibleAmmo = nil
	override.magazineCurrent = 1
	
	if override then
		local outputConfig = output:instanceValue("gunConfig",nil)
		if 	outputConfig 
			and outputConfig.compatibleAmmo[2] 
			and outputConfig.compatibleAmmo[2] == ammoKind
			and outputConfig.compatibleAmmo[1] ~= ammoItem
		then
			if outputConfig.magazineCurrent then	--push the existing ammo into an array to return to player later
				local rAmmo --has to support return ammo already being filled because the return script won't run until player holds the gun
				
				if outputConfig.returnAmmo and outputConfig.returnAmmo[outputConfig.compatibleAmmo[1]] then
					rAmmo = outputConfig.returnAmmo[outputConfig.compatibleAmmo[1]]
				else
					rAmmo = 0
				end
				
				if not outputConfig.returnAmmo then outputConfig.returnAmmo = {} end
				
				outputConfig.returnAmmo[outputConfig.compatibleAmmo[1]] = outputConfig.magazineCurrent + rAmmo
			end

			for k,v in pairs(override) do  --override the gunConfig of the gun with the override
				outputConfig[k] = v
			end
			
			outputConfig.compatibleAmmo[1] = ammoItem 
			outputConfig.reloadForce = true
			
			output:setInstanceValue("gunConfig",outputConfig)
			return output:descriptor(), 1
		else
			return nil
		end
	end

  --[[local augmentConfig = config.getParameter("augment")
  local output = Item.new(input)
  if augmentConfig then
    if output:instanceValue("acceptsAugmentType", "") == augmentConfig.type then
      local currentAugment = output:instanceValue("currentAugment")
      if currentAugment then
        if currentAugment.name == augmentConfig.name then
          return nil
        end
      end

      output:setInstanceValue("currentAugment", augmentConfig)
      return output:descriptor(), 1
    end
  end]]--
end