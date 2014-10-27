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


long_name = 'Phantasm Redux'
short_name = 'grayswandir-phantasm-redux'
for_module = 'tome'
version = {1, 2, 4,}
weight = 100
author = {'grayswandir',}
homepage = ''
description = [[Changes around the Spell/Phantasm tree.

Shadowblades will lose the ability to cast illuminate at will for damage, but they get a few other things to make up for it.

T1 - Illuminate: Light up the area and blind in a big radius.
T2 - Blur Image: Gives defense, bonus stealth, and projectile evasion.
T3 - Dancing Lights: Every few turns, summon a short-lived light in radius 4. Nearby enemies will be taunted by it, changing their target and making the deal less damage to other things while the light is alive.
T4 - Counter Flare: Whenever you lose a damage shield or break stealth, cast illuminate. This illuminate will also deal damage equal to a % of the damage shield's power or your stealth.]]
tags = {'tree', 'talent', 'magic', 'mage', 'spell', 'phantasm', 'light', 'archmage', 'shadowblade', 'redux',}

overload = true
superload = true
hooks = true
data = true
