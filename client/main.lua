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
    maskId = nil,
    tankId = nil,
    enabled = false,
}

local oxygenLevel = 0

local function attachGear()
    local playerPed = cache.ped

    -- Attach tank to back (bone 24818)
    local tankModel = "p_s_scuba_tank_s"
    lib.requestModel(tankModel)
    currentGear.tankId = CreateObject(GetHashKey(tankModel), GetEntityCoords(playerPed), true, false, true)
    AttachEntityToEntity(currentGear.tankId, playerPed, GetPedBoneIndex(playerPed, 24818), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)

    -- Attach mask to head (bone 12844)
    local maskModel = "p_d_scuba_mask_s"
    lib.requestModel(maskModel)
    currentGear.maskId = CreateObject(GetHashKey(maskModel), GetEntityCoords(playerPed), true, false, true)
    AttachEntityToEntity(currentGear.maskId, playerPed, GetPedBoneIndex(playerPed, 12844), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)

    lib.notify({
        title = locale('suit_equipped'),
        type = 'success'
    })
end

local function deleteGear()
    if currentGear.tankId then
        DeleteEntity(currentGear.tankId)
        currentGear.tankId = nil
    end
    if currentGear.maskId then
        DeleteEntity(currentGear.maskId)
        currentGear.maskId = nil
    end
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
        print('^2[qbx_divegear] Oxygen decay thread started^7')
        while currentGear.tankId do
            Wait(1000)
            if IsPedSwimming(cache.ped) and currentGear.enabled then
                oxygenLevel = math.max(oxygenLevel - Config.client.decayRate, 0)
                print('^3[qbx_divegear] Oxygen: ' .. oxygenLevel .. '^7')

                if oxygenLevel <= 0 then
                    disableScuba()
                    lib.notify({
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
        print('^2[qbx_divegear] Oxygen display thread started^7')
        while currentGear.tankId do
            Wait(100)
            if IsPedSwimming(cache.ped) then
                local oxygenPercent = math.floor((oxygenLevel / Config.client.startingOxygenLevel) * 100)

                -- Display oxygen bar using draw text
                BeginTextCommandDisplayHelp("STRING")
                AddTextComponentString("~b~OXYGEN: ~s~" .. oxygenPercent .. "%")
                EndTextCommandDisplayHelp(0, false, true, -1)
            end
        end
    end)
end

local function putOnSuit()
    if currentGear.tankId then
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
        attachGear()
        enableScuba()
        startOxygenLevelDecrementerThread()
        startOxygenLevelDrawTextThread()
    end
end

local function takeOffSuit()
    if not currentGear.tankId then
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
        deleteGear()
        oxygenLevel = 0

        lib.notify({
            title = locale('suit_removed'),
            type = 'success'
        })
    end
end

local function fillTank()
    if not currentGear.tankId then
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

RegisterNetEvent('qbx_divegear:client:useGear', function()
    if currentGear.tankId then
        takeOffSuit()
    else
        putOnSuit()
    end
end)

-- Callback for tank refill
lib.callback.register('qbx_divegear:fillTank', function(source, cb)
    fillTank()
    cb(true)
end)
