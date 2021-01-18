-----------------------------------
-- ID: 5745
-- Item: serving_of_cherry_bavarois
-- Food Effect: 3Hrs, All Races
-----------------------------------
-- HP 25
-- Intelligence 3
-- MP 10
-- HP Recovered While Healing 3
-----------------------------------
require("scripts/globals/status")
require("scripts/globals/msg")
-----------------------------------
local item_object = {}

item_object.onItemCheck = function(target)
    local result = 0
    if target:hasStatusEffect(tpz.effect.FOOD) or target:hasStatusEffect(tpz.effect.FIELD_SUPPORT_FOOD) then
        result = tpz.msg.basic.IS_FULL
    end
    return result
end

item_object.onItemUse = function(target)
    target:addStatusEffect(tpz.effect.FOOD, 0, 0, 10800, 5745)
end

item_object.onEffectGain = function(target, effect)
    target:addMod(tpz.mod.HP, 25)
    target:addMod(tpz.mod.INT, 3)
    target:addMod(tpz.mod.MP, 10)
    target:addMod(tpz.mod.HPHEAL, 3)
end

item_object.onEffectLose = function(target, effect)
    target:delMod(tpz.mod.HP, 25)
    target:delMod(tpz.mod.INT, 3)
    target:delMod(tpz.mod.MP, 10)
    target:delMod(tpz.mod.HPHEAL, 3)
end

return item_object
