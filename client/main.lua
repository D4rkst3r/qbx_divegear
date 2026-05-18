local config = require 'config.client'

-- Simple locale function
local function locale(key, args)
    local strings = {
        ['error.underwater'] = 'Cannot refill underwater',
        ['error.need_otube'] = 'You need an oxygen tube',
        ['error.not_standing_up'] = 'You must be standing on ground',
        ['info.filling_air'] = 'Filling oxygen tank...',
        ['info.pullout_suit'] = 'Taking off suit...',
        ['info.put_suit'] = 'Putting on suit...',
        ['success.tube_filled'] = 'Oxygen tank filled',
        ['success.took_out'] = 'Suit removed',
    }
    return strings[key] or key
end

local currentGear = {
    enabled = false,
    itemName = nil,
}

local savedOutfit = {}

local oxygenLevel = 0

local function enableScuba()
    SetEnableScuba(cache.ped, true)
    SetPedMaxTimeUnderwater(cache.ped, 2000.00)
end

local function disableScuba()
    SetEnableScuba(cache.ped, false)
    SetPedMaxTimeUnderwater(cache.ped, 1.00)
end

lib.callback.register('qbx_divegear:client:fillTank', function()
    if IsPedSwimmingUnderWater(cache.ped) then
        exports.qbx_core:Notify(locale('error.underwater', {oxygenlevel = oxygenLevel}), 'error')
        return false
    end

    if lib.progressBar({
        duration = config.refillTankTimeMs,
        label = locale('info.filling_air'),
        useWhileDead = false,
        canCancel = true,
        anim = {
            dict = 'clothingshirt',
            clip = 'try_shirt_positive_d',
            blendIn = 8.0
        }
    }) then
        oxygenLevel = config.startingOxygenLevel
        exports.qbx_core:Notify(locale('success.tube_filled'), 'success')
        if currentGear.enabled then
            enableScuba()
        end
        return true
    end
end)

local function deleteGear()
    local playerPed = cache.ped
    -- Restore saved outfit
    for compId, data in pairs(savedOutfit) do
        SetPedComponentVariation(playerPed, compId, data.drawable, data.texture, 2)
    end
    ClearAllPedProps(playerPed)
    savedOutfit = {}
end

local function attachGear(suitKey)
    local playerPed = cache.ped
    local suit = config.divingSuits[suitKey] or config.divingSuits['diving_gear_0']

    -- Save current outfit
    for i = 0, 11 do
        savedOutfit[i] = {
            drawable = GetPedDrawableVariation(playerPed, i),
            texture = GetPedTextureVariation(playerPed, i)
        }
    end

    -- Apply components from suit variant
    for compId, data in pairs(suit.components) do
        SetPedComponentVariation(playerPed, compId, data.drawable, data.texture, 2)
    end

    -- Apply props from suit variant
    for propId, data in pairs(suit.props) do
        SetPedPropIndex(playerPed, propId, data.drawable, data.texture, true)
    end
end

local function takeOffSuit()
    if lib.progressBar({
        duration = config.takeOffSuitTimeMs,
        label = locale('info.pullout_suit'),
        useWhileDead = false,
        canCancel = true,
        anim = {
            dict = 'clothingshirt',
            clip = 'try_shirt_positive_d',
            blendIn = 8.0
        }
    }) then
        SetEnableScuba(cache.ped, false)
        SetPedMaxTimeUnderwater(cache.ped, 50.00)
        currentGear.enabled = false
        -- Save oxygen to item metadata before removing
        TriggerServerEvent('qbx_divegear:server:updateOxygen', currentGear.itemName, oxygenLevel)
        currentGear.itemName = nil
        deleteGear()
        exports.qbx_core:Notify(locale('success.took_out'))
        -- Stop breathing suit audio
    end
end

local function startOxygenLevelDrawTextThread()
    CreateThread(function()
        while currentGear.enabled do
            if IsPedSwimmingUnderWater(cache.ped) then
                -- Simple oxygen level display
                BeginTextCommandDisplayHelp("STRING")
                AddTextComponentString("~b~OXYGEN: ~s~" .. oxygenLevel)
                EndTextCommandDisplayHelp(0, false, true, -1)
            end
            Wait(0)
        end
    end)
end

local function startOxygenLevelDecrementerThread()
    CreateThread(function()
        local updateTick = 0
        while currentGear.enabled do
            if IsPedSwimmingUnderWater(cache.ped) and oxygenLevel > 0 then
                oxygenLevel -= config.decayRate
                if oxygenLevel % 10 == 0 and oxygenLevel ~= config.startingOxygenLevel then
                    -- Initiate breathing suit audio
                end
                if oxygenLevel == 0 then
                    disableScuba()
                    -- Stop breathing suit audio
                end
            end

            -- Update item metadata every 10 seconds
            updateTick += 1
            if updateTick >= 10 then
                updateTick = 0
                TriggerServerEvent('qbx_divegear:server:updateOxygen', currentGear.itemName, oxygenLevel)
            end

            Wait(1000)
        end
    end)
end

local function putOnSuit(suitKey, savedOxygen)
    oxygenLevel = savedOxygen or config.startingOxygenLevel
    if oxygenLevel <= 0 then
        exports.qbx_core:Notify(locale('error.need_otube'), 'error')
        return
    end

    if IsPedSwimming(cache.ped) or cache.vehicle then
        exports.qbx_core:Notify(locale('error.not_standing_up'), 'error')
        return
    end

    if lib.progressBar({
        duration = config.putOnSuitTimeMs,
        label = locale('info.put_suit'),
        useWhileDead = false,
        canCancel = true,
        anim = {
            dict = 'clothingshirt',
            clip = 'try_shirt_positive_d',
            blendIn = 8.0
        }
    }) then
        deleteGear()
        attachGear(suitKey)
        enableScuba()
        currentGear.enabled = true
        currentGear.itemName = suitKey
        -- Initiate breathing suit audio
        startOxygenLevelDecrementerThread()
        startOxygenLevelDrawTextThread()
    end
end

RegisterNetEvent('qbx_divegear:client:useGear', function(suitKey, savedOxygen)
    if currentGear.enabled then
        takeOffSuit()
    else
        putOnSuit(suitKey, savedOxygen)
    end
end)
