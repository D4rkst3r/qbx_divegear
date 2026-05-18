Config = Config or {}

Config.client = {
    startingOxygenLevel = 100,
    putOnSuitTimeMs = 5000,
    takeOffSuitTimeMs = 5000,
    refillTankTimeMs = 5000,
    decayRate = 1,

    -- Complete diving suit outfits using actual GTA components
    -- Based on clothing combinations exported from clothing editor
    defaultDivingSuit = {
        components = {
            ["11"] = { drawable = 318, texture = 3 },  -- Torso (diving suit)
            ["1"] = { drawable = 0, texture = 0 },     -- Mask/Head
            ["4"] = { drawable = 113, texture = 3 },   -- Legs
            ["5"] = { drawable = 0, texture = 0 },
            ["3"] = { drawable = 3, texture = 0 },     -- Arms
            ["8"] = { drawable = 215, texture = 8 },   -- Shoes
            ["9"] = { drawable = 0, texture = 0 },
            ["6"] = { drawable = 80, texture = 3 },    -- Feet
            ["7"] = { drawable = 140, texture = 0 }    -- Neck
        },
        props = {
            ["0"] = { drawable = -1, texture = 0 },
            ["1"] = { drawable = 34, texture = 3 }     -- Diving mask/helmet prop
        },
        label = "Standard Diving Suit"
    },

    -- Multiple diving suit variants with different color combinations
    divingSuits = {
        {
            components = {
                ["11"] = { drawable = 318, texture = 3 },
                ["1"] = { drawable = 0, texture = 0 },
                ["4"] = { drawable = 113, texture = 3 },
                ["5"] = { drawable = 0, texture = 0 },
                ["3"] = { drawable = 3, texture = 0 },
                ["8"] = { drawable = 215, texture = 8 },
                ["9"] = { drawable = 0, texture = 0 },
                ["6"] = { drawable = 80, texture = 3 },
                ["7"] = { drawable = 140, texture = 0 }
            },
            props = {
                ["0"] = { drawable = -1, texture = 0 },
                ["1"] = { drawable = 34, texture = 3 }
            },
            label = "Black & Yellow Suit"
        },
        {
            components = {
                ["11"] = { drawable = 318, texture = 0 },  -- Different texture (black)
                ["1"] = { drawable = 0, texture = 0 },
                ["4"] = { drawable = 113, texture = 0 },
                ["5"] = { drawable = 0, texture = 0 },
                ["3"] = { drawable = 3, texture = 0 },
                ["8"] = { drawable = 215, texture = 0 },
                ["9"] = { drawable = 0, texture = 0 },
                ["6"] = { drawable = 80, texture = 0 },
                ["7"] = { drawable = 140, texture = 0 }
            },
            props = {
                ["0"] = { drawable = -1, texture = 0 },
                ["1"] = { drawable = 34, texture = 0 }
            },
            label = "Full Black Suit"
        },
        {
            components = {
                ["11"] = { drawable = 318, texture = 1 },  -- Different texture
                ["1"] = { drawable = 0, texture = 0 },
                ["4"] = { drawable = 113, texture = 1 },
                ["5"] = { drawable = 0, texture = 0 },
                ["3"] = { drawable = 3, texture = 0 },
                ["8"] = { drawable = 215, texture = 1 },
                ["9"] = { drawable = 0, texture = 0 },
                ["6"] = { drawable = 80, texture = 1 },
                ["7"] = { drawable = 140, texture = 0 }
            },
            props = {
                ["0"] = { drawable = -1, texture = 0 },
                ["1"] = { drawable = 34, texture = 1 }
            },
            label = "Blue Diving Suit"
        },
        {
            components = {
                ["11"] = { drawable = 318, texture = 2 },
                ["1"] = { drawable = 0, texture = 0 },
                ["4"] = { drawable = 113, texture = 2 },
                ["5"] = { drawable = 0, texture = 0 },
                ["3"] = { drawable = 3, texture = 0 },
                ["8"] = { drawable = 215, texture = 2 },
                ["9"] = { drawable = 0, texture = 0 },
                ["6"] = { drawable = 80, texture = 2 },
                ["7"] = { drawable = 140, texture = 0 }
            },
            props = {
                ["0"] = { drawable = -1, texture = 0 },
                ["1"] = { drawable = 34, texture = 2 }
            },
            label = "Red Diving Suit"
        }
    }
}
