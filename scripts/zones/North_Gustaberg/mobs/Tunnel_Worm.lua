-----------------------------------
-- Area: North Gustaberg
--  Mob: Tunnel Worm
-----------------------------------
require("scripts/globals/regimes")
-----------------------------------
local entity = {}

entity.onMobDeath = function(mob, player, isKiller)
    xi.regime.checkRegime(player, mob, 16, 1, xi.regime.type.FIELDS)
end

return entity
