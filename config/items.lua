-- Diving Gear Item Configuration for ox_inventory
-- Add these to your ox_inventory/data/items.lua or use this separately

return {
    ['diving_gear'] = {
        label = 'Diving Gear',
        weight = 30000,
        stack = false,
        close = true,
        description = 'Complete diving suit with oxygen tank'
    },
    ['diving_fill'] = {
        label = 'Diving Tank Refill',
        weight = 3000,
        stack = true,
        close = true,
        description = 'Oxygen refill tube for diving gear'
    }
}
