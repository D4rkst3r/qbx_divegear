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

-- Client updates oxygen level → save to item metadata
RegisterNetEvent('qbx_divegear:server:updateOxygen', function(itemName, oxygen)
    local source = source
    local item = exports.ox_inventory:GetItem(source, itemName, nil, true)
    if not item then return end

    exports.ox_inventory:SetItemMetadata(source, item.slot, {
        oxygen = oxygen,
        durability = oxygen, -- ox_inventory zeigt durability als Balken an
        label = 'Oxygen: ' .. oxygen .. ' / 100'
    })
end)
