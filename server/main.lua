-- Auto-register all 26 diving gear variants
for i = 0, 25 do
    local itemName = 'diving_gear_' .. i
    exports.qbx_core:CreateUseableItem(itemName, function(source)
        TriggerClientEvent('qbx_divegear:client:useGear', source, itemName)
    end)
end

-- Diving Fill Item
exports.qbx_core:CreateUseableItem('diving_fill', function(source)
    local success = lib.callback.await('qbx_divegear:client:fillTank', source)
    if success then
        exports.ox_inventory:RemoveItem(source, 'diving_fill', 1)
    end
end)
