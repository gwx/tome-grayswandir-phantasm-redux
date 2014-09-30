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


newAI('move_random', function(self)
		local Map = require 'engine.Map'
		local _, _, grids = util.findFreeGrid(self.x, self.y, 1, true, {[Map.ACTOR] = true,})
		if not grids or #grids == 0 then return end
		local grid = rng.table(grids)
		local x, y = unpack(grid)
		if not x or not y then return end
		return self:moveDirection(x, y)
		end)
