--[[ Rexmeck Animation System thing. imported for gunsbound
Templates examples
vvvvvvvvv

animation = {
	step = 30, --more == smoother
	fixed = false, --do not touch if you want to auto-fix some value unless you know what are you doing.
	currentstep = 1,
	key = 1,
	tracks = {
		ani1 = {
			{
				sound = {"/sfx/melee/charge_traildash1.ogg"}, --If the key reached there it should play a sound.
				value ={
					hand2 = 3, --Value moves.
				}
			},
			{
				sound = {"/sfx/melee/charge_traildash2.ogg"},
				value = {
					hand = 0
				}
			}
		}
	},
	playing = nil,
	doneplaying = ""
}

parts = {hand = 0, hand2 = 3}

]]

function anisound(sounddata) --For animation sounds do not tamper unless you know what are you doing
  local soundIde = world.spawnProjectile(
		"invisibleprojectile",
		mcontroller.position(),
		activeItem.ownerEntityId(),
		mcontroller.position(),
		true,
		{
			timeToLive = 0.01, 
			power = 0,
			damageType = "NoDamage",
			universalDamage = false,
			actionOnReap = {{action = "sound", options = sounddata}},
			processing = "?replace;F7D5D3=F7D5D300;754C23=00000000;A47844=A4784400"
		}
	)
 end

function playAnimation(trk, stp) --Plays the animation (STRING AnimationTrack, Optional INT speed) --Some tracks may have override speed
	if animation then
		if animation.tracks[trk] then
			animation.doneplaying = animation.playing
			animation.playing = trk
			animation.currentstep = 1
			animation.key = 1
			if #animation.tracks[animation.playing][animation.key].sound > 0 then
				anisound(animation.tracks[animation.playing][animation.key].sound)
			end
			if animation.tracks[animation.playing][animation.key].func and type(animation.tracks[animation.playing][animation.key].func) == "function" then
				animation.tracks[animation.playing][animation.key].func()
			end
			if animation.tracks[animation.playing][animation.key].step then
				animation.step = animation.tracks[animation.playing][animation.key].step
			end
			if stp then
				animation.step = stp
			else
				animation.step = 4
			end
		else
		sb.logWarn("Animation "..trk.." does not exists!")
		end
	else
		sb.logWarn("Animation Table is missing! Please check examples from api!")
	end
end

function fixAnimation() --This fixes empty spots on the json animation so it will not require extra work updateAnimation does this automaticly once
	for i,v in pairs(animation.tracks) do
		for i2,v2 in pairs(parts) do
			if not animation.tracks[i][1].value[i2] then
				animation.tracks[i][1].value[i2] = v2
			end
		end
	end
	for i,v in pairs(animation.tracks) do
		for i2,v2 in pairs(animation.tracks[i]) do
			if animation.tracks[i][i2 + 1] then --ani
				for i3,v3 in pairs(animation.tracks[i][i2].value) do
					if not animation.tracks[i][i2 + 1].value[i3] then
						animation.tracks[i][i2 + 1].value[i3] = v3
					end
				end
			end
		end
	end
	
	for i,v in pairs(animation.tracks) do
		for i2,v2 in pairs(v) do
			if animation.tracks[i][i2].func and type(animation.tracks[i][i2].func) == "string" and animation.actions[animation.tracks[i][i2].func] then
				animation.tracks[i][i2].func = animation.actions[animation.tracks[i][i2].func]
			elseif  animation.tracks[i][i2].func and type(animation.tracks[i][i2].func) == "string" and animation.actions[animation.tracks[i][i2].func] then
			
			end
		end
	end
end

function copyreplace(copy, add) --api do not tamper
	for i,v in pairs(add) do
		copy[i] = v
	end
return copy
end

function skipAnimation() --Skip current playing animation
	if animation.playing ~= nil then
	parts = copyreplace(parts,animation.tracks[animation.playing][#animation.tracks[animation.playing]].value)
	animation.doneplaying = animation.playing
	animation.playing = nil
	animation.currentstep = 1
	end
end

function updateAnimation() --Put this before the update of the drawables in your update scripts
		if not animation.fixed then --autofix
			fixAnimation()
			animation.fixed = true
		end
		if animation.playing ~= nil then
			if animation.tracks[animation.playing][animation.key + 1] then
			for i,v in pairs(animation.tracks[animation.playing][animation.key].value) do
					if parts[i] and animation.tracks[animation.playing][animation.key + 1].value[i] and animation.tracks[animation.playing][animation.key].value[i] then
					parts[i] = animation.tracks[animation.playing][animation.key].value[i] + (((animation.tracks[animation.playing][animation.key + 1].value[i] - animation.tracks[animation.playing][animation.key].value[i]) / animation.step) * animation.currentstep)
				end
			end
			if animation.currentstep < animation.step then
				animation.currentstep = animation.currentstep + 1
			else
				animation.currentstep = 1
				if animation.tracks[animation.playing][animation.key].loop and animation.tracks[animation.playing][animation.key].loop ~= animation.key then --loop to an integer
					parts = copyreplace(parts,animation.tracks[animation.playing][animation.tracks[animation.playing][animation.key].loop].value)
					animation.key = animation.tracks[animation.playing][animation.key].loop
				else
					animation.key = animation.key + 1
				end
				if #animation.tracks[animation.playing][animation.key].sound > 0 then
					anisound(animation.tracks[animation.playing][animation.key].sound)
				end
				if animation.tracks[animation.playing][animation.key].func and type(animation.tracks[animation.playing][animation.key].func) == "function" then
					animation.tracks[animation.playing][animation.key].func()
				end
				if animation.tracks[animation.playing][animation.key].step then
					animation.step = animation.tracks[animation.playing][animation.key].step
				end
				--print("SWITCH!: "..animation.playing.." = "..animation.key)
			end
		else
				animation.currentstep = 1
				if animation.tracks[animation.playing][animation.key].loop and animation.tracks[animation.playing][animation.tracks[animation.playing][animation.key].loop] and animation.tracks[animation.playing][animation.key].loop ~= animation.key then --loop to an integer
					animation.currentstep = 1
					if #animation.tracks[animation.playing][animation.key].sound > 0 then
						anisound(animation.tracks[animation.playing][animation.key].sound)
					end
					if animation.tracks[animation.playing][animation.key].func and type(animation.tracks[animation.playing][animation.key].func) == "function" then
						animation.tracks[animation.playing][animation.key].func()
					end
					parts = copyreplace(parts,animation.tracks[animation.playing][animation.tracks[animation.playing][animation.key].loop].value)
					animation.key = animation.tracks[animation.playing][animation.key].loop
					if animation.tracks[animation.playing][animation.key].step then
						animation.step = animation.tracks[animation.playing][animation.key].step
					end
				else
					animation.currentstep = 1
					animation.doneplaying = animation.playing
					animation.playing = nil
				end
			end
		end
end