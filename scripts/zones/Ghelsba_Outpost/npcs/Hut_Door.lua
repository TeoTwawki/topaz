-----------------------------------
-- Area: Ghelsba_Outpost
--  NPC: Hut Door
-- !pos -165.357 -11.672 77.771 140
-----------------------------------
require("scripts/globals/bcnm")
require("scripts/globals/titles")
require("scripts/globals/keyitems")
require("scripts/globals/quests")
require("scripts/globals/missions")
-----------------------------------
local entity = {}

entity.onTrade = function(player, npc, trade)
    TradeBCNM(player, npc, trade)
end

entity.onTrigger = function(player, npc)
    if EventTriggerBCNM(player, npc) then
        return
    end
end

entity.onEventUpdate = function(player, csid, option, extras)
    EventUpdateBCNM(player, csid, option, extras)
end

entity.onEventFinish = function(player, csid, option)
    if EventFinishBCNM(player, csid, option) then
        return
    end
end

return entity
