-- Server-side item usage handlers for qbx_divegear
-- Uses qbx_core:CreateUseableItem API

-- Diving Gear Item - Toggle suit on/off
exports.qbx_core:CreateUseableItem('diving_gear', function(source)
    print('^2[qbx_divegear] Player ' .. source .. ' used diving_gear^7')
    TriggerClientEvent('qbx_divegear:client:useGear', source)
end)

-- Diving Fill Item - Refill oxygen tank
exports.qbx_core:CreateUseableItem('diving_fill', function(source)
    print('^2[qbx_divegear] Player ' .. source .. ' used diving_fill^7')
    local success = lib.callback.await('qbx_divegear:client:fillTank', source)
    if success then
        -- Remove the used fill item from inventory
        exports.ox_inventory:RemoveItem(source, 'diving_fill', 1)
        print('^3[qbx_divegear] Removed diving_fill from player ' .. source .. '^7')
    end
end)
