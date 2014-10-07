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


newEffect {
	name = 'GRAYSWANDIR_TAUNTED',
	desc = 'Taunted',
	long_desc = function(self, eff)
		return ('The target has been taunted by %s - any attacks not directed at it will do %d%% less damage. This effect will end when the target dies.'):format(eff.src.name, eff.power)
		end,
	type = 'mental', subtype = {morale = true,},
	status = 'detrimental',
	decrease = 0,
	parameters = {power = 10,},
	on_gain = function(self, eff)
		return ('%s taunts #Target#!'):format(eff.src.name:capitalize()), '+Taunted'
		end,
	on_lose = function(self, eff)
		return '#Target# is no longer taunted.', '-Taunted'
		end,
	activate = function(self, eff)
		self:setTarget(eff.src)
		eff.power = util.bound(eff.power, 0, 100)
		end,
	deactivate = function(self, eff) end,
	callbackOnAct = function(self, eff)
		if not eff.src or eff.src.dead then
			self:removeEffect('EFF_GRAYSWANDIR_TAUNTED', false, true)
			end end,}

class:bindHook('DamageProjector:base', function(self, data)
		local Map = require 'engine.Map'
		local target = game.level.map(data.x, data.y, Map.ACTOR)
		if not target then return end
		local taunted = data.src.hasEffect and data.src:hasEffect 'EFF_GRAYSWANDIR_TAUNTED'
		if taunted and taunted.src ~= target then
			data.dam = data.dam * 0.01 * (100 - taunted.power)
			end
		return true
		end)
