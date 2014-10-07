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


local alpha_mult = alpha_mult or 1

local nb = 0
return { generator = function()
	local blue = rng.percent(30)
	local cross = rng.percent(30)
	local reverse = rng.percent(50)
	local radius = radius
	local sqrad = math.sqrt(radius)
	local inner = (engine.Map.tile_w + engine.Map.tile_h) / 2
	local sradius = (radius + 0.5) * inner
	local spokes = 15 + radius
	local ad = cross and (rng.range(0, spokes) + rng.float(-1, 1) / spokes) * 360 / spokes or rng.float(0, 360)
	local a = math.rad(ad)
	local r = rng.float(0.1 * inner, sradius) * (cross and 0.2 or 1)
	if cross and blue then
		ad = (rng.range(0, spokes) + rng.float(-0.5, 0.5) / spokes + 0.5) * 360 / spokes
		a = math.rad(ad)
		r = r + 0.5 * inner
		end
	if r < 1 then r = 1 end
	local x = r * math.cos(a)
	local y = r * math.sin(a)
	local bx = math.floor(x / engine.Map.tile_w)
	local by = math.floor(y / engine.Map.tile_h)

	return {
		trail = 1,
		life = 14 + radius,
		size = cross and (blue and 5 or 2) or 4 * math.sqrt(radius), sizev = 0.1, sizea = 0,

		x = x, xv = 0, xa = static and rng.float(-0.1, 0.1) or 0,
		y = y, yv = 0, ya = static and rng.float(-0.1, 0.1) or 0,
		dir = cross and a or a + (reverse and math.rad(90 + rng.range(10, 20)) or -math.rad(90 + rng.range(10, 20))),
		dirv = 0, --cross and 0 or (reverse and 0.08 or -0.08),
		dira = 0, --cross and 0 or (reverse and 0.01 or -0.01),
		vel = rng.float(2, 4) * (17 / (14 + radius)) * (cross and math.min(radius * 2/(blue and 4 or 3), sradius / r) or 1),
		velv = cross and 0 or -0.1, vela = 0.01,

		r = rng.range(220, 255)/255,  rv = 0, ra = 0,
		g = rng.range(200, 230)/255,  gv = 0, ga = 0,
		b = blue and 0.8 or 0,        bv = 0, ba = 0,
		a = rng.range(cross and 62 * alpha_mult or 0, cross and 250 * alpha_mult or 50)/255,    av = -0.005, aa = 0,
	}
end, },
function(self)
	if nb < 5 then
		self.ps:emit(radius*266)
		nb = nb + 1
		self.ps:emit(radius*266)
		nb = nb + 1
		self.ps:emit(radius*266)
		nb = nb + 1
		self.ps:emit(radius*266)
		nb = nb + 1
		self.ps:emit(radius*266)
		nb = nb + 1
	end
end,
5*radius*266
