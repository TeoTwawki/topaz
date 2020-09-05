------------------------------------
-- Records of Eminence
------------------------------------
require("scripts/globals/status")

tpz = tpz or {}
tpz.roe = tpz.roe or {}

tpz.roe.triggers = 
{
    mobkill = 1,
    wsuse = 2,
    lootitem = 3,
    synthsuccess = 4,
    
}
local triggers = tpz.roe.triggers

tpz.roe.checks = {}
local checks = tpz.roe.checks

-- Main general check function for all-purpose use.
-- Some functions may specify custom handlers (ie. gain exp or deal dmg.)
checks.masterCheck = function(self, player, params)
    for func in pairs(self.reqs) do
      if not checks[func](self, player, params) then
          return false
      end
    end
    return true
end


checks.mob = function(self, player, params)    -- Mob ID check
    return (params.mob and self.reqs.mob[params.mob:getID()]) and true or false
end

checks.mobxp = function(self, player, params)  -- Mob yields xp
     return (params.mob and player:checkKillCredit(params.mob)) and true or false
end

checks.zone = function(self, player, params)  -- Player in Zone
     return (self.reqs.zone[player:getZoneID()]) and true or false
end

checks.notzone = function(self, player, params)  -- Player not in Zone
     return (not self.reqs.zone[player:getZoneID()]) and true or false
end

checks.itemid = function(self, player, params)  -- itemid in set
     return (params.itemid and self.reqs.itemid[params.itemid]) and true or false
end


local defaults = {
    check = checks.masterCheck, -- Check function should return true/false
    increment = 1,              -- Amount to increment per successful check
    goal = 1,                   -- Progress goal
    reqs = {},                  -- Other requirements. List of function names from above, with required values.
}

--[[ **************************************************************************
    Complete a record of eminence. This is for internal roe use only.
    If record rewards items, and the player cannot carry them, return false.
    Otherwise, return true.
    Example of usage with params (all params are optional):
        npcUtil.completeRecord(player, record#, {
            item = { {640,2}, 641 },          -- see npcUtil.giveItem for formats (Only given on first completion)
            keyItem = tpz.ki.ZERUHN_REPORT,   -- see npcUtil.giveKeyItem for formats
            sparks = 500,
            xp = 1000
        })
     *************************************************************************** --]]
local function completeRecord(player, record, params)
    params = params or {}

    if not player:getEminenceCompleted(record) and params["item"] then
        if not npcUtil.giveItem(player, params["item"]) then
            player:messageBasic(tpz.msg.basic.ROE_UNABLE_BONUS_ITEM)
            return false
        end
    end

    player:messageBasic(tpz.msg.basic.ROE_COMPLETE,record)

    if params["sparks"] ~= nil and type(params["sparks"]) == "number" then
        local bonus = 1
        if player:getEminenceCompleted(record) then
            player:addCurrency('spark_of_eminence', params["sparks"] * bonus * SPARKS_RATE)
            player:messageBasic(tpz.msg.basic.ROE_RECEIVE_SPARKS, params["sparks"] * SPARKS_RATE, player:getCurrency("spark_of_eminence"))
        else
            bonus = 3
            player:addCurrency('spark_of_eminence', params["sparks"] * bonus * SPARKS_RATE)
            player:messageBasic(tpz.msg.basic.ROE_FIRST_TIME_SPARKS, params["sparks"] * bonus * SPARKS_RATE, player:getCurrency("spark_of_eminence"))
        end
    end

    if params["xp"] ~= nil and type(params["xp"]) == "number" then
        player:addExp(params["xp"] * ROE_EXP_RATE)
    end

    if params["keyItem"] ~= nil then
        npcUtil.giveKeyItem(player, params["keyItem"])
    end

    -- successfully complete the record
    if params["repeatable"] then
        player:messageBasic(tpz.msg.basic.ROE_REPEAT_OR_CANCEL)
        player:setEminenceCompleted(record, 1)
    else
        player:setEminenceCompleted(record)
    end
    return true
end


-- *** onRecordTrigger is the primary entry point for all record calls. ***
-- Even records which are completed through Lua scripts should point here and
-- have record information entered in the table below. This keeps everything neat.

function tpz.roe.onRecordTrigger(player, recordID, params)
    local entry = tpz.roe.records[recordID]
    if entry and entry:check(player, params) then
        local progress = player:getEminenceProgress(recordID) + entry.increment
        if progress >= entry.goal then
            completeRecord(player, recordID, entry.reward)
        else
            player:setEminenceProgress(recordID, progress, entry.goal)
        end
    end
end
tpz.roe.completeRecord = tpz.roe.onRecordTrigger


-- All implemented records must have their entries in this table.
-- Records not in this table can't be taken.

tpz.roe.records = 
{

  ----------------------------------------
  -- Tutorial -> Basics                 --
  ----------------------------------------

    [1   ] = { -- First Step Forward
        reward =  { item = { {4376,6} }, keyItem = tpz.ki.MEMORANDOLL, sparks = 100, xp = 300 }
    },

    [2   ] = { -- Vanquish 1 Enemy
        trigger = triggers.mobkill,
        reward =  { sparks = 100, xp = 500}       
    },

    [3   ] = { -- Undertake a FoV Training Regime
        reward =  { sparks = 100, xp = 500}       
    },

    [4   ] = { -- Heal without magic
        reward =  { sparks = 100, xp = 500}       
    },

    [11  ] = { -- Undertake a GoV Training Regime
        reward =  { sparks = 100, xp = 500}       
    },
    
  --------------------------------------------
  -- Combat (Wide Area) -> Combat (General) --
  --------------------------------------------
    
    [12  ] = { -- Vanquish Multiple Enemies I - 200
        trigger = triggers.mobkill,
        goal = 200,
        reqs = { mobxp = true },
        reward = { sparks = 1000, xp = 5000, unity = 100, repeatable = true },
    },

    [13  ] = { -- Vanquish Multiple Enemies II - 500
        trigger = triggers.mobkill,
        goal = 500,
        reqs = { mobxp = true },
        reward = { sparks = 2000, xp = 6000 , item = { 6180 } },
    },

    [14  ] = { -- Vanquish Multiple Enemies III - 750
        trigger = triggers.mobkill,
        goal = 750,
        reqs = { mobxp = true },
        reward = { sparks = 5000, xp = 10000 , item = { 6183 } },
    },

    [45  ] = { -- Weapon Skills 1
        trigger = triggers.wsuse,
        goal = 100,
        reward = { sparks = 500, xp = 2500 },
    },

  --------------------------------------------
  -- Crafting: General                      --
  --------------------------------------------

    [57  ] = { -- Total Successful Synthesis Attempts
        trigger = triggers.synthsuccess,
        goal = 30,
        reward = { sparks = 100, xp = 500, unity = 10, repeatable = true },
    },

  --------------------------------------------
  -- Combat (Wide Area) -> Spoils I         --
  --------------------------------------------

    [71  ] = { -- Spoils - Fire Crystals
        trigger = triggers.lootitem,
        goal = 10,
        reqs = { itemid = set{ 4096 } },
        reward = { sparks = 200, xp = 1000, unity = 20, repeatable = true },
    },

    [72  ] = { -- Spoils - Ice Crystals
        trigger = triggers.lootitem,
        goal = 10,
        reqs = { itemid = set{ 4097 } },
        reward = { sparks = 200, xp = 1000, unity = 20, repeatable = true },
    },

    [73  ] = { -- Spoils - Wind Crystals
        trigger = triggers.lootitem,
        goal = 10,
        reqs = { itemid = set{ 4098 } },
        reward = { sparks = 200, xp = 1000, unity = 20, repeatable = true },
    },

    [74  ] = { -- Spoils - Earth Crystals
        trigger = triggers.lootitem,
        goal = 10,
        reqs = { itemid = set{ 4099 } },
        reward = { sparks = 200, xp = 1000, unity = 20, repeatable = true },
    },

    [75  ] = { -- Spoils - Lightning Crystals
        trigger = triggers.lootitem,
        goal = 10,
        reqs = { itemid = set{ 4100 } },
        reward = { sparks = 200, xp = 1000, unity = 20, repeatable = true },
    },

    [76  ] = { -- Spoils - Water Crystals
        trigger = triggers.lootitem,
        goal = 10,
        reqs = { itemid = set{ 4101 } },
        reward = { sparks = 200, xp = 1000, unity = 20, repeatable = true },
    },

    [77  ] = { -- Spoils - Light Crystals
        trigger = triggers.lootitem,
        goal = 10,
        reqs = { itemid = set{ 4102 } },
        reward = { sparks = 200, xp = 1000, unity = 20, repeatable = true },
    },

    [78  ] = { -- Spoils - Dark Crystals
        trigger = triggers.lootitem,
        goal = 10,
        reqs = { itemid = set{ 4103 } },
        reward = { sparks = 200, xp = 1000, unity = 20, repeatable = true },
    },
    
  ----------------------------------------
  -- Combat (Region) - Original Areas 2 --
  ----------------------------------------

    [239 ] = { -- Conflict: Jugner Forest
        trigger = triggers.mobkill,
        goal = 10,
        reqs = { zone = set{104} },
        reward = { sparks = 12, xp = 600, unity = 5, item = { {4381, 12} }, repeatable = true },
    },

    [240 ] = { -- Subjugation: King Arthro
        trigger = triggers.mobkill,
        reqs = { mob = set{17093094, 17203216} },
        reward = { sparks = 500, xp = 1000 },
    },

    [241 ] = { -- Conflict: Batallia Downs
        trigger = triggers.mobkill,
        goal = 10,
        reqs = { zone = set{105} },
        reward = { sparks = 13, xp = 650, unity = 5, item = { 13685 }, repeatable = true },
    },

    [242 ] = { -- Subjugation: Lumber Jack
        trigger = triggers.mobkill,
        reqs = { mob = set{17207308, 17093074} },
        reward = { sparks = 500, xp = 1000 },
    },

    [243 ] = { -- Conflict: Eldieme Necropolis
        trigger = triggers.mobkill,
        goal = 10,
        reqs = { zone = set{195} },
        reward = { sparks = 14, xp = 100, unity = 5, item = { 13198 }, repeatable = true },
    },

    [244 ] = { -- Subjugation: Cwn Cyrff
        trigger = triggers.mobkill,
        reqs = { mob = set{17093049, 17576054} },
        reward = { sparks = 250, xp = 800 },
    },

    [245 ] = { -- Conflict: Davoi
        trigger = triggers.mobkill,
        goal = 10,
        reqs = { zone = set{149} },
        reward = { sparks = 13, xp = 650, unity = 5, item = { 12554 }, repeatable = true },
    },

    [246 ] = { -- Subjugation: Hawkeyed Dnatbat
        trigger = triggers.mobkill,
        reqs = { mob = set{17125433, 17387567} },
        reward = { sparks = 250, xp = 600 },
    },

    [247 ] = { -- Conflict: N. Gustaberg
        trigger = triggers.mobkill,
        goal = 10,
        reqs = { zone = set{106} },
        reward = { sparks = 10, xp = 500, unity = 5, item = { 4488 }, repeatable = true },
    },

    [248 ] = { -- Subjugation: Maighdean Uaine
        trigger = triggers.mobkill,
        reqs = { mob = set{17211702, 17092912} },
        reward = { sparks = 250, xp = 500 },
    },

    [249 ] = { -- Conflict: S. Gustaberg
        trigger = triggers.mobkill,
        goal = 10,
        reqs = { zone = set{107} },
        reward = { sparks = 10, xp = 500, unity = 5, item = { 12592 }, repeatable = true },
    },

    [250 ] = { -- Subjugation: Carnero
        trigger = triggers.mobkill,
        reqs = { mob = set{17092839, 17215613, 17215626} },
        reward = { sparks = 250, xp = 500 },
    },

    [251 ] = { -- Conflict: Zeruhn Mines
        trigger = triggers.mobkill,
        goal = 10,
        reqs = { zone = set{172} },
        reward = { sparks = 10, xp = 100, unity = 5, item = { 13335 }, repeatable = true },
    },

    [252 ] = { -- Conflict: Palborough Mines
        trigger = triggers.mobkill,
        goal = 10,
        reqs = { zone = set{143} },
        reward = { sparks = 10, xp = 500, unity = 5, item = { 13330 }, repeatable = true },
    },
    
    [253 ] = { -- Subjugation: Zi-Ghi Bone-eater
        trigger = triggers.mobkill,
        reqs = { mob = set{17363208} },
        reward = { sparks = 250, xp = 500 },
    },

    [254 ] = { -- Conflict: Dangruf Wadi
        trigger = triggers.mobkill,
        goal = 10,
        reqs = { zone = set{191} },
        reward = { sparks = 10, xp = 100, unity = 5, item = { 13473 }, repeatable = true },
    },

    [255 ] = { -- Subjugation: Teporingo
        trigger = triggers.mobkill,
        reqs = { mob = set{17093017, 17559584} },
        reward = { sparks = 250, xp = 500 },
    },

    [256 ] = { -- Conflict: Pashhow Marshlands
        trigger = triggers.mobkill,
        goal = 10,
        reqs = { zone = set{109} },
        reward = { sparks = 12, xp = 600, unity = 5, item = { {5721, 12} }, repeatable = true },
    },

    [257 ] = { -- Subjugation: Ni'Zho Bladebender
        trigger = triggers.mobkill,
        reqs = { mob = set{17223797} },
        reward = { sparks = 250, xp = 700 },
    },
    
    [258 ] = { -- Conflict: Rolanberry Fields
        trigger = triggers.mobkill,
        goal = 10,
        reqs = { zone = set{110} },
        reward = { sparks = 12, xp = 600, unity = 5, item = { 15487 }, repeatable = true },
    },

    [259 ] = { -- Subjugation: Simurgh
        trigger = triggers.mobkill,
        reqs = { mob = set{17228242, 17092905} },
        reward = { sparks = 250, xp = 1000 },
    },
    
    [260 ] = { -- Conflict: Crawler's Nest
        trigger = triggers.mobkill,
        goal = 10,
        reqs = { zone = set{197} },
        reward = { sparks = 14, xp = 100, unity = 5, item = { 13271 }, repeatable = true },
    },

    [261 ] = { -- Subjugation: Demonic Tiphia
        trigger = triggers.mobkill,
        reqs = { mob = set{17093057, 17584398} },
        reward = { sparks = 250, xp = 800 },
    },

    [262 ] = { -- Conflict: Beadeaux
        trigger = triggers.mobkill,
        goal = 10,
        reqs = { zone = set{147} },
        reward = { sparks = 13, xp = 650, unity = 5, item = { 13703 }, repeatable = true },
    },

    [263 ] = { -- Subjugation: Zo'Khu Blackcloud
        trigger = triggers.mobkill,
        reqs = { mob = set{17379564} },
        reward = { sparks = 250, xp = 700 },
    },

}

 -- Apply defaults for records
for i,v in pairs(tpz.roe.records) do
    setmetatable(v, { __index = defaults })
end

 -- Register triggers
for i,v in pairs(tpz.roe.triggers) do
    RoeRegisterHandler(v)
end

-- Build global map of implemented records.
-- This is used to deny taking records which aren't implemented in the above table.
RoeParseRecords(tpz.roe.records)
