--require "/rexDump.lua"

function apply(item)
	local cg = config.getParameter
	local aType = cg("attachementType")
	local aInfo = cg("attachementInfo")
	if not item.parameters.giveBack then
		item.parameters.giveBack = {}
	end
	if item.parameters.gunConfig.attachments[aType] and item.parameters.gunConfig.attachments[aType].itemName then
		item.parameters.giveBack[#item.parameters.giveBack + 1] = {
				name = item.parameters.gunConfig.attachments[aType].itemName, 
				count = 1, 
				parameters = item.parameters.gunConfig.attachments[aType]
			}
	end
	item.parameters.gunConfig.attachments[aType] = {
		itemName = cg("itemName"),
		rarity = cg("rarity"),
		image = cg("image"),
		category = cg("category"),
		price = cg("price"),
		maxStack = cg("maxStack"),
		script = cg("script"),
		shortdescription = cg("shortdescription"),
		attachementInfo = aInfo,
		attachementType = aType,
		inventoryIcon = cg("inventoryIcon")
	}
	--sb.logInfo(rexDump(_ENV))
	--not sure if it actually consumes it
	return item
end