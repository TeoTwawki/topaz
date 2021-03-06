-----------------------------------
-- Area: Zeruhn Mines
--  NPC: Makarim
-- Involved In Mission: The Zeruhn Report
-- !pos -58 8 -333 172
-----------------------------------
local ID = require("scripts/zones/Zeruhn_Mines/IDs")
require("scripts/globals/keyitems")
require("scripts/globals/missions")
-----------------------------------
local entity = {}

entity.onTrade = function(player, npc, trade)
end

entity.onTrigger = function(player, npc)
    if player:getCurrentMission(BASTOK) == xi.mission.id.bastok.THE_ZERUHN_REPORT then
        if player:hasKeyItem(xi.ki.ZERUHN_REPORT) then
            player:messageSpecial(ID.text.MAKARIM_DIALOG_I)
        else
            player:startEvent(121)
        end
    else
        player:startEvent(104)
    end
end

entity.onEventUpdate = function(player, csid, option)
end

entity.onEventFinish = function(player, csid, option)
    if csid == 121 then
        player:addKeyItem(xi.ki.ZERUHN_REPORT)
        player:messageSpecial(ID.text.KEYITEM_OBTAINED, xi.ki.ZERUHN_REPORT)
    end
end

return entity
