
function split(inputstr, sep) 
        if sep == nil then
            sep = "%s"
        end
        local t={} ; i=1
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            t[i] = str
            i = i + 1
        end
    return t
end


sleeveframe = {
["idle.1"]		=	1 ,
["idle.2"]		=	2 ,
["idle.3"]		=	3 ,
["idle.4"]		=	4 ,
["idle.5"]		=	5 ,
["duck.1"]		=	6 ,
["walk.1"]		=	7 ,
["walk.2"]		=	8 ,
["walk.3"]		=	9 ,
["walk.4"]		=	10,
["walk.5"]		=	11,
["rotation"]	=	12,
["run.1"]		=	13,
["run.2"]		=	14,
["run.3"]		=	15,
["run.4"]		=	16,
["run.5"]		=	17,
["jump.1"]		=	18,
["jump.2"]		=	19,
["jump.3"]		=	20,
["jump.4"]		=	21,
["fall.1"]		=	22,
["fall.2"]		=	23,
["fall.3"]		=	24,
["fall.4"]		=	25,
["swimIdle.1"]	=	26,
["swimIdle.2"]	=	27,
["swim.1"]		=	28,
["swim.2"]		=	29,
["swim.3"]		=	30,
["swim.4"]		=	31,
["swim.5"]		=	32,
["idleMelee"]	=	33,
["duckMelee"]	=	34
}

chestframe = {
["chest.1"] 	=	1,
["chest.2"] 	=	2,
["chest.3"] 	=	3,
["run"]			=	4,
["duck"]		=	5,
["swim"] 		=	6
}

zLevelHead = { 
		HeadArmor = 10,
		HeadHumanoid = 3, 
		HairHumanoid = 4,
		FaceHumanoid = 5,
		BrandHumanoid = 6,
		BeardHumanoid = 7,
		FluffHumanoid = 8,
		BeaksHumanoid = 9
}

armor = {
	["/pants.png"] = "LegArmor",
	["/chestm.png"] = "BodyArmor",
	["/head.png"] = "HeadArmor",
	["/fsleeve.png"] = "FrontArmArmor",
	["/bsleeve.png"] = "BackArmArmor",
	["/back.png"] = "BackArmor"
}

species = {
	human = {
		male = {
			["/humanoid/human/malehead.png"] = "HeadHumanoid",
			["/humanoid/human/emote.png"] = "FaceHumanoid",
			["/humanoid/human/hair/"] = "HairHumanoid",
			["/humanoid/human/malebody.png"] = "BodyHumanoid",
			["/humanoid/human/backarm.png"] = "BackArmHumanoid",
			["/humanoid/human/frontarm.png"] = "FrontArmHumanoid"
		},
		female = {
			["/humanoid/human/femalehead.png"] = "HeadHumanoid",
			["/humanoid/human/emote.png"] = "FaceHumanoid",
			["/humanoid/human/hair/"] = "HairHumanoid",
			["/humanoid/human/femalebody.png"] = "BodyHumanoid",
			["/humanoid/human/backarm.png"] = "BackArmHumanoid",
			["/humanoid/human/frontarm.png"] = "FrontArmHumanoid"
		}
	},
	avian = {
		male = {
			["/humanoid/avian/malehead.png"] = "HeadHumanoid",
			["/humanoid/avian/emote.png"] = "FaceHumanoid",
			["/humanoid/avian/hair/"] = "HairHumanoid",
			["/humanoid/avian/malebody.png"] = "BodyHumanoid",
			["/humanoid/avian/backarm.png"] = "BackArmHumanoid",
			["/humanoid/avian/frontarm.png"] = "FrontArmHumanoid",
			["/humanoid/avian/fluff/"] = "FluffHumanoid",
			["/humanoid/avian/beaks/"] = "BeaksHumanoid"
		},
		female = {
			["/humanoid/avian/femalehead.png"] = "HeadHumanoid",
			["/humanoid/avian/emote.png"] = "FaceHumanoid",
			["/humanoid/avian/hair/"] = "HairHumanoid",
			["/humanoid/avian/femalebody.png"] = "BodyHumanoid",
			["/humanoid/avian/backarm.png"] = "BackArmHumanoid",
			["/humanoid/avian/frontarm.png"] = "FrontArmHumanoid",
			["/humanoid/avian/fluff/"] = "FluffHumanoid",
			["/humanoid/avian/beaks/"] = "BeaksHumanoid"
		}
	},
	apex = {
		male = {
			["/humanoid/apex/malehead.png"] = "HeadHumanoid",
			["/humanoid/apex/emote.png"] = "FaceHumanoid",
			["/humanoid/apex/hairmale/"] = "HairHumanoid",
			["/humanoid/apex/malebody.png"] = "BodyHumanoid",
			["/humanoid/apex/backarm.png"] = "BackArmHumanoid",
			["/humanoid/apex/frontarm.png"] = "FrontArmHumanoid",
			["/humanoid/apex/beardmale/"] = "BeardHumanoid"
		},
		female = {
			["/humanoid/apex/femalehead.png"] = "HeadHumanoid",
			["/humanoid/apex/emote.png"] = "FaceHumanoid",
			["/humanoid/apex/hairfemale/"] = "HairHumanoid",
			["/humanoid/apex/femalebody.png"] = "BodyHumanoid",
			["/humanoid/apex/backarm.png"] = "BackArmHumanoid",
			["/humanoid/apex/frontarm.png"] = "FrontArmHumanoid",
			["/humanoid/apex/beardfemale/"] = "BeardHumanoid"
		}
	},
	floran = {
		male = {
			["/humanoid/floran/malehead.png"] = "HeadHumanoid",
			["/humanoid/floran/emote.png"] = "FaceHumanoid",
			["/humanoid/floran/hair/"] = "HairHumanoid",
			["/humanoid/floran/malebody.png"] = "BodyHumanoid",
			["/humanoid/floran/backarm.png"] = "BackArmHumanoid",
			["/humanoid/floran/frontarm.png"] = "FrontArmHumanoid"
		},
		female = {
			["/humanoid/floran/femalehead.png"] = "HeadHumanoid",
			["/humanoid/floran/emote.png"] = "FaceHumanoid",
			["/humanoid/floran/hair/"] = "HairHumanoid",
			["/humanoid/floran/femalebody.png"] = "BodyHumanoid",
			["/humanoid/floran/backarm.png"] = "BackArmHumanoid",
			["/humanoid/floran/frontarm.png"] = "FrontArmHumanoid"
		}
	},
	hylotl = {
		male = {
			["/humanoid/hylotl/malehead.png"] = "HeadHumanoid",
			["/humanoid/hylotl/emote.png"] = "FaceHumanoid",
			["/humanoid/hylotl/hair/"] = "HairHumanoid",
			["/humanoid/hylotl/malebody.png"] = "BodyHumanoid",
			["/humanoid/hylotl/backarm.png"] = "BackArmHumanoid",
			["/humanoid/hylotl/frontarm.png"] = "FrontArmHumanoid"
		},
		female = {
			["/humanoid/hylotl/femalehead.png"] = "HeadHumanoid",
			["/humanoid/hylotl/emote.png"] = "FaceHumanoid",
			["/humanoid/hylotl/hair/"] = "HairHumanoid",
			["/humanoid/hylotl/femalebody.png"] = "BodyHumanoid",
			["/humanoid/hylotl/backarm.png"] = "BackArmHumanoid",
			["/humanoid/hylotl/frontarm.png"] = "FrontArmHumanoid"
		}
	},
	novakid = {
		male = {
			["/humanoid/novakid/malehead.png"] = "HeadHumanoid",
			["/humanoid/novakid/emote.png"] = "FaceHumanoid",
			["/humanoid/novakid/hair/"] = "HairHumanoid",
			["/humanoid/novakid/brand/"] = "BrandHumanoid",
			["/humanoid/novakid/malebody.png"] = "BodyHumanoid",
			["/humanoid/novakid/backarm.png"] = "BackArmHumanoid",
			["/humanoid/novakid/frontarm.png"] = "FrontArmHumanoid"
		},
		female = {
			["/humanoid/novakid/femalehead.png"] = "HeadHumanoid",
			["/humanoid/novakid/emote.png"] = "FaceHumanoid",
			["/humanoid/novakid/hair/"] = "HairHumanoid",
			["/humanoid/novakid/brand/"] = "BrandHumanoid",
			["/humanoid/novakid/femalebody.png"] = "BodyHumanoid",
			["/humanoid/novakid/backarm.png"] = "BackArmHumanoid",
			["/humanoid/novakid/frontarm.png"] = "FrontArmHumanoid"
		}
	},
	glitch = {
		male = {
			["/humanoid/glitch/malehead.png"] = "HeadHumanoid",
			["/humanoid/glitch/emote.png"] = "FaceHumanoid",
			["/humanoid/glitch/hair/"] = "HairHumanoid",
			["/humanoid/glitch/malebody.png"] = "BodyHumanoid",
			["/humanoid/glitch/backarm.png"] = "BackArmHumanoid",
			["/humanoid/glitch/frontarm.png"] = "FrontArmHumanoid"
		},
		female = {
			["/humanoid/glitch/femalehead.png"] = "HeadHumanoid",
			["/humanoid/glitch/emote.png"] = "FaceHumanoid",
			["/humanoid/glitch/hair/"] = "HairHumanoid",
			["/humanoid/glitch/femalebody.png"] = "BodyHumanoid",
			["/humanoid/glitch/backarm.png"] = "BackArmHumanoid",
			["/humanoid/glitch/frontarm.png"] = "FrontArmHumanoid"
		}
	},
	wasphive = {
		male = {
			["/humanoid/wasphive/malehead.png"] = "HeadHumanoid",
			["/humanoid/wasphive/emote.png"] = "FaceHumanoid",
			["/humanoid/wasphive/hair/"] = "HairHumanoid",
			["/humanoid/wasphive/malebody.png"] = "BodyHumanoid",
			["/humanoid/wasphive/backarm.png"] = "BackArmHumanoid",
			["/humanoid/wasphive/frontarm.png"] = "FrontArmHumanoid"
		},
		female = {
			["/humanoid/wasphive/femalehead.png"] = "HeadHumanoid",
			["/humanoid/wasphive/emote.png"] = "FaceHumanoid",
			["/humanoid/wasphive/hair/"] = "HairHumanoid",
			["/humanoid/wasphive/femalebody.png"] = "BodyHumanoid",
			["/humanoid/wasphive/backarm.png"] = "BackArmHumanoid",
			["/humanoid/wasphive/frontarm.png"] = "FrontArmHumanoid"
		}
	},
	felin = {
		male = {
			["/humanoid/felin/malehead.png"] = "HeadHumanoid",
			["/humanoid/felin/emote.png"] = "FaceHumanoid",
			["/humanoid/felin/hair/"] = "HairHumanoid",
			["/humanoid/felin/malebody.png"] = "BodyHumanoid",
			["/humanoid/felin/backarm.png"] = "BackArmHumanoid",
			["/humanoid/felin/frontarm.png"] = "FrontArmHumanoid"
		},
		female = {
			["/humanoid/felin/femalehead.png"] = "HeadHumanoid",
			["/humanoid/felin/emote.png"] = "FaceHumanoid",
			["/humanoid/felin/hair/"] = "HairHumanoid",
			["/humanoid/felin/femalebody.png"] = "BodyHumanoid",
			["/humanoid/felin/backarm.png"] = "BackArmHumanoid",
			["/humanoid/felin/frontarm.png"] = "FrontArmHumanoid"
		}
	},
	avali = {
		male = {
			["/humanoid/avali/malehead.png"] = "HeadHumanoid",
			["/humanoid/avali/emote.png"] = "FaceHumanoid",
			["/humanoid/avali/hair/"] = "HairHumanoid",
			["/humanoid/avali/malebody.png"] = "BodyHumanoid",
			["/humanoid/avali/backarm.png"] = "BackArmHumanoid",
			["/humanoid/avali/frontarm.png"] = "FrontArmHumanoid"
		},
		female = {
			["/humanoid/avali/femalehead.png"] = "HeadHumanoid",
			["/humanoid/avali/emote.png"] = "FaceHumanoid",
			["/humanoid/avali/hair/"] = "HairHumanoid",
			["/humanoid/avali/femalebody.png"] = "BodyHumanoid",
			["/humanoid/avali/backarm.png"] = "BackArmHumanoid",
			["/humanoid/avali/frontarm.png"] = "FrontArmHumanoid"
		}
	},
	kemono = {
		male = {
			["/humanoid/kemono/malehead.png"] = "HeadHumanoid",
			["/humanoid/kemono/emote.png"] = "FaceHumanoid",
			["/humanoid/kemono/hair/"] = "HairHumanoid",
			["/humanoid/kemono/malebody.png"] = "BodyHumanoid",
			["/humanoid/kemono/backarm.png"] = "BackArmHumanoid",
			["/humanoid/kemono/frontarm.png"] = "FrontArmHumanoid"
		},
		female = {
			["/humanoid/kemono/femalehead.png"] = "HeadHumanoid",
			["/humanoid/kemono/emote.png"] = "FaceHumanoid",
			["/humanoid/kemono/hair/"] = "HairHumanoid",
			["/humanoid/kemono/femalebody.png"] = "BodyHumanoid",
			["/humanoid/kemono/backarm.png"] = "BackArmHumanoid",
			["/humanoid/kemono/frontarm.png"] = "FrontArmHumanoid"
		}
	},
	unsung = {
		male = {
			["/humanoid/unsung/malehead.png"] = "HeadHumanoid",
			["/humanoid/unsung/emote.png"] = "FaceHumanoid",
			["/humanoid/unsung/hair/"] = "HairHumanoid",
			["/humanoid/unsung/malebody.png"] = "BodyHumanoid",
			["/humanoid/unsung/backarm.png"] = "BackArmHumanoid",
			["/humanoid/unsung/frontarm.png"] = "FrontArmHumanoid"
		},
		female = {
			["/humanoid/unsung/femalehead.png"] = "HeadHumanoid",
			["/humanoid/unsung/emote.png"] = "FaceHumanoid",
			["/humanoid/unsung/hair/"] = "HairHumanoid",
			["/humanoid/unsung/femalebody.png"] = "BodyHumanoid",
			["/humanoid/unsung/backarm.png"] = "BackArmHumanoid",
			["/humanoid/unsung/frontarm.png"] = "FrontArmHumanoid"
		}
	}
}

function autoPortrait(id)
return speciesParts(world.entityPortrait(id, "full"), world.entitySpecies(id), world.entityGender(id))
end

function speciesParts(p, spe, gender)
	local tab = {}
	if not species[spe] or not species[spe][gender] then --if not found
		return tab
	end
	for i,v in pairs(p) do
		local splited = split(v.image, ":")
		for i2,v2 in pairs(species[spe][gender]) do
			if string.match(splited[1], i2) then
				v.zLevel = i
				tab[v2] = v
			end
		end
		for i2,v2 in pairs(armor) do
			if splited[1] and string.match(splited[1], i2) then
				v.zLevel = i
				tab[v2] = v
			end
		end
	end
	return tab
end

function filterHead(p)--filtering lol
	return { 
		HeadArmor = p["HeadArmor"],
		HeadHumanoid = p["HeadHumanoid"], 
		HairHumanoid = p["HairHumanoid"],
		FaceHumanoid = p["FaceHumanoid"],
		BrandHumanoid = p["BrandHumanoid"],
		BeardHumanoid = p["BeardHumanoid"],
		FluffHumanoid = p["FluffHumanoid"],
		BeaksHumanoid = p["BeaksHumanoid"]
	}
end

function skinDirectives(p) --Skin color
	if p.HeadHumanoid then
		local splited = split(p.HeadHumanoid.image, "?")
		local str2 = ""
		for i,v in pairs(splited) do
			if i ~= 1 then
				str2 = str2.."?"..v
			end
		end
		return str2
	else
		return nil
	end
end

function getDirectives(p, pic)
	if p[pic] then
		local splited = split(p[pic].image, "?")
		local str2 = ""
		for i,v in pairs(splited) do
			if i ~= 1 then
				str2 = str2.."?"..v
			end
		end
		return str2
	else
		return nil
	end
end

function getDirectory(p, pic)
	if p[pic] then
		local splited = split(p[pic].image, ":")
		return splited[1]
	else
		return nil
	end
end
