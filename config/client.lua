local suits = {}

-- Auto-generate all 26 texture variants (0-25)
-- Each variant changes: Brille (prop 1) + Unterhemd (component 11)
for i = 0, 25 do
    suits['diving_gear_' .. i] = {
        components = {
            [8] = { drawable = 215, texture = i },  -- Flasche am Rücken texture variant
        },
        props = {
            [1] = { drawable = 34, texture = i }, -- Brille texture variant
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
