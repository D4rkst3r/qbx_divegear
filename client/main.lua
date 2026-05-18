-- Localization strings
local locales = {
    ['already_equipped'] = 'Suit already equipped',
    ['cannot_equip_underwater'] = 'Cannot equip suit underwater',
    ['cannot_equip_in_vehicle'] = 'Cannot equip suit in vehicle',
    ['putting_on_suit'] = 'Putting on suit...',
    ['suit_equipped'] = 'Suit equipped',
    ['no_suit_equipped'] = 'No suit equipped',
    ['taking_off_suit'] = 'Taking off suit...',
    ['suit_removed'] = 'Suit removed',
    ['cannot_refill_underwater'] = 'Cannot refill underwater',
    ['refilling_tank'] = 'Refilling tank...',
    ['tank_refilled'] = 'Tank refilled',
    ['oxygen_depleted'] = 'Oxygen depleted!'
}

local function locale(key)
    return locales[key] or key
end

local currentGear = {
    maskAndTank = false,
    enabled = false,
    currentSuit = nil,
}

local oxygenLevel = 0
local savedClothes = {}

local function setGearOutfit(outfit)
    if not outfit then return end

    local playerPed = cache.ped

    -- Save current clothes before changing
    for i = 0, 11 do
        savedClothes[tostring(i)] = {
            drawable = GetPedDrawableVariation(playerPed, i),
            texture = GetPedTextureVariation(playerPed, i)
        }
    end

    -- Apply all components from the outfit
    for componentId, componentData in pairs(outfit.components) do
        local compId = tonumber(componentId)
        SetPedComponentVariation(playerPed, compId, componentData.drawable, componentData.texture, 2)
    end

    -- Apply props (masks, helmets, etc)
    for propId, propData in pairs(outfit.props) do
        local pId = tonumber(propId)
        if propData.drawable ~= -1 then
            SetPedPropIndex(playerPed, pId, propData.drawable, propData.texture, true)
        end
    end

    currentGear.currentSuit = outfit
end

local function resetClothes()
    local playerPed = cache.ped

    -- Restore saved clothes
    for componentId, componentData in pairs(savedClothes) do
        local compId = tonumber(componentId)
        SetPedComponentVariation(playerPed, compId, componentData.drawable, componentData.texture, 2)
    end

    -- Clear props
    ClearAllPedProps(playerPed)
    savedClothes = {}
    currentGear.currentSuit = nil
end

local function enableScuba()
    if currentGear.enabled then return end
    currentGear.enabled = true
    SetEnableScuba(cache.ped, true)
end

local function disableScuba()
    if not currentGear.enabled then return end
    currentGear.enabled = false
    SetEnableScuba(cache.ped, false)
end

local function startOxygenLevelDecrementerThread()
    CreateThread(function()
        while currentGear.maskAndTank do
            Wait(1000)
            if IsPedSwimming(cache.ped) and currentGear.enabled then
                oxygenLevel = math.max(oxygenLevel - Config.client.decayRate, 0)

                if oxygenLevel <= 0 then
                    disableScuba()
                    TriggerEvent('ox_lib:notify', {
                        title = locale('oxygen_depleted'),
                        type = 'error'
                    })
                end
            end
        end
    end)
end

local function startOxygenLevelDrawTextThread()
    CreateThread(function()
        while currentGear.maskAndTank do
            Wait(0)
            if IsPedSwimming(cache.ped) then
                BeginScaleformMovieMethod(RequestScaleformMovie("OXYGEN"))
                PushScaleformMovieFunctionVoid("SET_SPEED")
                PushScaleformMovieFunctionFloat(oxygenLevel / Config.client.startingOxygenLevel)
                local scaleform = EndScaleformMovieMethod()
                DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
            end
        end
    end)
end

local function putOnSuit(suitVariant)
    if currentGear.maskAndTank then
        return lib.notify({
            title = locale('already_equipped'),
            type = 'info'
        })
    end

    if IsEntityInWater(cache.ped) then
        return lib.notify({
            title = locale('cannot_equip_underwater'),
            type = 'error'
        })
    end

    if GetVehiclePedIsIn(cache.ped) ~= 0 then
        return lib.notify({
            title = locale('cannot_equip_in_vehicle'),
            type = 'error'
        })
    end

    local suit = suitVariant or Config.client.defaultDivingSuit

    if lib.progressBar({
        duration = Config.client.putOnSuitTimeMs,
        label = locale('putting_on_suit'),
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
            move = true,
            combat = true
        },
        anim = {
            dict = 'combat@damage@rb_writhe',
            clip = 'rb_writhe_loop'
        }
    }) then
        oxygenLevel = Config.client.startingOxygenLevel
        currentGear.maskAndTank = true

        -- Apply complete diving suit outfit
        setGearOutfit(suit)
        enableScuba()
        startOxygenLevelDecrementerThread()
        startOxygenLevelDrawTextThread()

        lib.notify({
            title = locale('suit_equipped'),
            description = suit.label,
            type = 'success'
        })
    end
end

local function takeOffSuit()
    if not currentGear.maskAndTank then
        return lib.notify({
            title = locale('no_suit_equipped'),
            type = 'info'
        })
    end

    if lib.progressBar({
        duration = Config.client.takeOffSuitTimeMs,
        label = locale('taking_off_suit'),
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
            move = true,
            combat = true
        },
        anim = {
            dict = 'combat@damage@rb_writhe',
            clip = 'rb_writhe_loop'
        }
    }) then
        disableScuba()
        currentGear.maskAndTank = false
        oxygenLevel = 0

        -- Reset to saved clothes
        resetClothes()

        lib.notify({
            title = locale('suit_removed'),
            type = 'success'
        })
    end
end

local function fillTank()
    if not currentGear.maskAndTank then
        return lib.notify({
            title = locale('no_suit_equipped'),
            type = 'error'
        })
    end

    if IsEntityInWater(cache.ped) then
        return lib.notify({
            title = locale('cannot_refill_underwater'),
            type = 'error'
        })
    end

    if lib.progressBar({
        duration = Config.client.refillTankTimeMs,
        label = locale('refilling_tank'),
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
            move = true,
            combat = true
        }
    }) then
        oxygenLevel = Config.client.startingOxygenLevel
        lib.notify({
            title = locale('tank_refilled'),
            type = 'success'
        })
    end
end

RegisterNetEvent('qbx_divegear:client:useGear', function(suitVariant)
    if currentGear.maskAndTank then
        takeOffSuit()
    else
        putOnSuit(suitVariant)
    end
end)

-- Callback for tank refill
lib.callback.register('qbx_divegear:fillTank', function(source, cb)
    fillTank()
    cb(true)
end)
