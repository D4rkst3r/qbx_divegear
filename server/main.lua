-- Auto-register all 26 diving gear variants
for i = 0, 25 do
    local itemName = 'diving_gear_' .. i
    exports.qbx_core:CreateUseableItem(itemName, function(source)
        -- Read current oxygen from item metadata
        local items = exports.ox_inventory:Search(source, 'slots', itemName)
        local oxygen = 100
        if items and items[1] and items[1].metadata then
            oxygen = items[1].metadata.oxygen or 100
        end
        TriggerClientEvent('qbx_divegear:client:useGear', source, itemName, oxygen)
    end)
end

-- Diving Fill Item
exports.qbx_core:CreateUseableItem('diving_fill', function(source)
    local success = lib.callback.await('qbx_divegear:client:fillTank', source)
    if success then
        exports.ox_inventory:RemoveItem(source, 'diving_fill', 1)
    end
end)

-- Client updates oxygen level → save to item metadata (remove + re-add with new metadata)
RegisterNetEvent('qbx_divegear:server:updateOxygen', function(itemName, oxygen)
    local source = source
    local items = exports.ox_inventory:Search(source, 'slots', itemName)
    if not items or not items[1] then return end

    local slot = items[1].slot
    exports.ox_inventory:RemoveItem(source, itemName, 1, nil, slot)
    exports.ox_inventory:AddItem(source, itemName, 1, {
        oxygen = oxygen,
        durability = oxygen,
    }, slot)
end)
