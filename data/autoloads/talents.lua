-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.


local Entity = require 'engine.Entity'
local get = util.getval

local phantasm_talents = Talents.talents_types_def['spell/phantasm'].talents

table.merge(Talents:getTalentFromId 'T_ILLUMINATE', {
		display_entity = Entity.new {image = 'talents/grayswandir_illuminate.png', is_talent = true,},
		radius = function(self, t)
			return self:scale {low = 3, high = 9, t, after = 'ceil',}
			end,
		target = function(self, t)
			return {type = 'ball', talent = t, selffire = false,
				range = get(t.range, self, t),
				radius = get(t.radius, self, t),}
			end,
		tactical = {DISABLE = 2,},
		duration = function(self, t)
			return self:scale {low = 3, high = 6, t, after = 'floor',}
			end,
		action = function(self, t)
			local tg = get(t.target, self, t)
			self:project(tg, self.x, self.y, 'LITE', 1)
			local damage = self:attr 'grayswandir_illuminate_damage'
			if damage then damage = self:spellCrit(damage) end
			local duration = get(t.duration, self, t)
			local apply = self:combatSpellpower()
			self:project(tg, self.x, self.y, function(x, y)
					local actor = game.level.map(x, y, Map.ACTOR)
					if not actor then return end
					if actor:canBe 'blind' then
						actor:setEffect('EFF_BLINDED', duration, {apply_power = apply,})
					else
						game.logSeen(actor, '%s resists the blinding light!', actor.name:capitalize())
						end
					if damage then self:projectOn(actor, 'LIGHT', damage) end
					end)
			game.level.map:particleEmitter(self.x, self.y, tg.radius, 'sunburst', {
					radius = tg.radius, tx = self.x, ty = self.y, max_alpha = 80,})
			game:playSoundNear(self, 'talents/heal')
			return true
			end,
		info = function(self, t)
			return ([[Creates a globe of pure light with radius %d #SLATE#[*]#LAST#, illuminating the area and blinding #SLATE#[spell vs. phys, blind]#LAST# targets for %d #SLATE#[*]#LAST# turns.]])
				:format(get(t.radius, self, t), get(t.duration, self, t))
			end,})

table.merge(Talents:getTalentFromId 'T_BLUR_SIGHT', {
		name = 'Blur Image',
		display_entity = Entity.new {image = 'talents/grayswandir_blur_image.png', is_talent = true,},
		defense = function(self, t)
			return self:scale {low = 10, high = 40, t, 'mag', synergy = 0.9,}
			end,
		stealth = function(self, t)
			return self:scale {low = 10, high = 40, t, 'mag', synergy = 0.9,}
			end,
		evasion = function(self, t)
			return self:scale {low = 10, high = 30, t, 'mag',}
			end,
		evasion_spread = function(self, t)
			return self:scale {low = 1, high = 2.2, t, after = 'floor',}
			end,
		activate = function(self, t)
			return self:autoTemporaryValues {temps = {
					combat_def = get(t.defense, self, t),
					inc_stealth = get(t.stealth, self, t),
					projectile_evasion = get(t.evasion, self, t),
					projectile_evasion_spread = get(t.evasion_spread, self, t),},
				particles = self:addParticles(Particles.new('phantasm_shield', 1)),}
			end,
		deactivate = function(self, t, p)
			self:removeParticles(p.particles)
			return true
			end,
		callbackOnStatChange = function(self, t, stat, v)
			if stat == self.STAT_MAG then
				self:updateTalentPassives(t)
				end
			end,
		info = function(self, t)
			return ([[Blur your image, giving you %d #SLATE#[*, mag]#LAST# defense, %d #SLATE#[*, mag]#LAST# bonus stealth, and giving projectiles targeted at you a %d%% #SLATE#[*, mag]#LAST# chance to instead target a space up to %d #SLATE#[*]#LAST# tiles away from you.]])
				:format(get(t.defense, self, t),
					get(t.stealth, self, t),
					get(t.evasion, self, t),
					get(t.evasion_spread, self, t))
			end,})

-- Move phantasmal shield into spell/other.
local phantasmal_shield = Talents:getTalentFromId 'T_PHANTASMAL_SHIELD'
phantasmal_shield.type = {'spell/other', 1,}
table.removeFromList(phantasm_talents, phantasmal_shield)
table.insert(Talents.talents_types_def['spell/other'].talents, phantasmal_shield)

newTalent {
	name = 'Dancing Lights', short_name = 'GRAYSWANDIR_DANCING_LIGHTS',
	type = {'spell/phantasm', 3,},
	points = 5,
	mode = 'sustained',
	require = phantasmal_shield.require,
	tactical = {BUFF = 4,},
	range = 0,
	min_radius = 2,
	max_radius = 4,
	duration = 3,
	lite = 2,
	life = function(self, t)
		return self:scale {low = 10, high = 150, t, 'spell', synergy = 0.9, after = 'damage',}
		end,
	taunt = function(self, t) return self:scale {low = 10, high = 40, limit = 55, t,} end,
	cooldown = 6,
	no_energy = true,
	sustain_mana = 10,
	summon_mana = function(self, t)
		local base = self:scale {low = 3, high = 1, limit = 0.5, t,}
		return base * 0.01 * (100 + 2 * self:combatFatigue())
		end,
	activate = function(self, t) return {} end,
	deactivate = function(self, t, p) return true end,
	callbackOnActBase = function(self, t)
		local _, _, grids = util.findFreeGrid(
			self.x, self.y, get(t.max_radius, self, t), true, {[Map.ACTOR] = true,})
		local min_radius = get(t.min_radius, self, t)
		local grid
		while not grid and #grids > 0 do
			grid = table.remove(grids, rng.range(1, #grids))
			if grid[3] < min_radius then grid = nil end
			end
		if not grid then return end
		local x, y = unpack(grid)
		if not x or not y then return end
		local cost = get(t.summon_mana, self, t)
		if self:getMana() < 1 + cost then return end

		local life = get(t.life, self, t)
		local lite = get(t.lite, self, t)
		local taunt = get(t.taunt, self, t)
		local apply = self:combatSpellpower()
		local light = require('mod.class.NPC').new {
			name = 'Dancing Light',
			type = 'elemental', subtype = 'light',
			color = colors.YELLOW, display = '*', image = 'npc/elemental_light_wisp.png',
			level_range = {self.level, self.level,},
			faction = self.faction, summoner = self, summoner_gain_exp = true,
			summon_time = get(t.duration, self, t),
			autolevel = 'none', exp_worth = 0,
			ai = 'summoned', ai_real = 'move_random',
			x = x, y = y,
			energy = {mod = 1, value = 1000,},
			lite = lite,
			levitation = 1, no_breath = 1, poison_immune = 1, cut_immune = 1,
			disease_immune = 1, stun_immune = 1, blind_immune = 1, knockback_immune = 1,
			confusion_immune = 1,
			resists = {LIGHT = 100, DARKNESS = -100,},}
		light:resolve() light:resolve(nil, true)
		light:setTarget(self) -- so it moves
		light.max_life = life
		light.life = life
		game.level:addEntity(light)
		game.zone:addEntity(game.level, light, 'actor', x, y)
		game.level.map:particleEmitter(x, y, lite, 'summon')
		light:project({type = 'ball', range = 0, radius = lite,}, light.x, light.y, function(x, y)
				local target = game.level.map(x, y, Map.ACTOR)
				if not target or not target.reactionToward or not target.checkHit then return end
				if target:reactionToward(self) >= 0 then return end
				if target:checkHit(target:combatMentalResist(), apply, 0, 95) then return end
				target:setEffect('EFF_GRAYSWANDIR_TAUNTED', 1, {src = light, power = taunt,})
				end)
		self:incMana(-cost)
		end,
	info = function(self, t)
		return ([[Every turn, summon a #YELLOW#Dancing Light#LAST# to a random space within radius %d to %d. The lights will last for %d turns, have %d #SLATE#[*, spell]#LAST# life and have give off a light of radius %d. When they are summoned, they will #PINK#taunt#LAST# #SLATE#[spell vs. mind]#LAST# any creatures in their light radius, switching their target to the light. While creatures are #PINK#taunted#LAST#, they will do %d%% less damage to everything but the light. Each light will cost %.1f mana to summon.]])
			:format(get(t.min_radius, self, t),
				get(t.max_radius, self, t),
				get(t.duration, self, t),
				get(t.life, self, t),
				get(t.lite, self, t),
				get(t.taunt, self, t),
				get(t.summon_mana, self, t))
		end,}
phantasm_talents[3], phantasm_talents[4] = phantasm_talents[4], phantasm_talents[3]

table.merge(Talents:getTalentFromId 'T_INVISIBILITY', {
		name = 'Counter Flare',
		display_entity = Entity.new {image = 'talents/grayswandir_counter_flare.png', is_talent = true,},
		sustain_mana = 35,
		cooldown = 24,
		shield_pct = function(self, t) return self:scale {low = 0, high = 70, t,} end,
		stealth_pct = function(self, t) return self:scale {low = 0, high = 165, t,} end,
		activate = function(self, t) return {} end,
		deactivate = function(self, t, p) return true end,
		trigger = function(self, t, power)
			self:attr('grayswandir_illuminate_damage', power)
			self:forceUseTalent('T_ILLUMINATE', {ignore_energy = true, ignore_cd = true,})
			self:attr('grayswandir_illuminate_damage', -power)
			end,
		callbackOnLoseShield = function(self, t, shield)
			local power = self.damage_shield_absorb_max * 0.01 * self:callTalent('T_INVISIBILITY', 'shield_pct')
			self:callTalent('T_INVISBILITY', 'trigger', power)
			end,
		info = function(self, t)
			return ([[Whenever you lose a damage shield or break stealth, cast Illuminate, without affecting its cooldown. In addition, that illuminate will also deal #YELLOW#light#LAST# damage equal to %d%% #SLATE#[*]#LAST# of the lost shield's maximum value or %d%% #SLATE#[*]#LAST# of your stealth power.]])
				:format(get(t.shield_pct, self, t), get(t.stealth_pct, self, t))
			end,})

local stealth = Talents:getTalentFromId 'T_STEALTH'
local stealth_deactivate = stealth.deactivate
stealth.deactivate = function(self, t, p)
	if self:isTalentActive 'T_INVISIBILITY' then
		local illuminate = self:getTalentFromId 'T_ILLUMINATE'
		illuminate.no_break_stealth = true -- so we don't get into an infinite loop.
		local power = (self:attr 'stealth' or 0) + (self:attr 'inc_stealth' or 0)
		power = power * 0.01 * self:callTalent('T_INVISIBILITY', 'stealth_pct')
		self:callTalent('T_INVISIBILITY', 'trigger', power)
		illuminate.no_break_stealth = nil
		end
	return stealth_deactivate(self, t, p)
	end
