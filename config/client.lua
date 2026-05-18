local suits = {}

-- Auto-generate all 26 texture variants (0-25)
-- Each variant changes: Brille (prop 1) + Unterhemd (component 11)
for i = 0, 25 do
    suits['diving_gear_' .. i] = {
        components = {
            [1]  = { drawable = 0,   texture = 0 },
            [3]  = { drawable = 0,   texture = 0 },
            [4]  = { drawable = 0,   texture = 3 },
            [5]  = { drawable = 0,   texture = 0 },
            [6]  = { drawable = 0,   texture = 0 },
            [7]  = { drawable = 0,   texture = 0 },
            [8]  = { drawable = 215, texture = 8 },
            [9]  = { drawable = 0,   texture = 0 },
            [11] = { drawable = 0,   texture = i },  -- Unterhemd texture variant
        },
        props = {
            [1] = { drawable = 34, texture = i },    -- Brille texture variant
        },
        label = 'Diving Gear (Variant ' .. i .. ')'
    }
end

return {
    startingOxygenLevel = 100,
    putOnSuitTimeMs = 5000,
    takeOffSuitTimeMs = 5000,
    refillTankTimeMs = 5000,
    decayRate = 1,
    divingSuits = suits,
}
