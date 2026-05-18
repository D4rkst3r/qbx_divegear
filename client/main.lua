local currentGear = {
    maskAndTank = false,
    enabled = false,
}

local oxygenLevel = 0
local savedOutfit = {}

local function setGearClothing()
    local playerPed = cache.ped

    -- Save current outfit
    for i = 0, 11 do
        savedOutfit[i] = {
            drawable = GetPedDrawableVariation(playerPed, i),
            texture = GetPedTextureVariation(playerPed, i)
        }
    end

    -- Apply diving suit components
    local suit = Config.client.defaultDivingSuit
    for componentId, componentData in pairs(suit.components) do
        local compId = tonumber(componentId)
        SetPedComponentVariation(playerPed, compId, componentData.drawable, componentData.texture, 2)
    end

    -- Apply props
    for propId, propData in pairs(suit.props) do
        local pId = tonumber(propId)
        if propData.drawable ~= -1 then
            SetPedPropIndex(playerPed, pId, propData.drawable, propData.texture, true)
        end
    end
end

local function resetClothing()
    local playerPed = cache.ped

    -- Restore saved outfit
    for i = 0, 11 do
        if savedOutfit[i] then
            SetPedComponentVariation(playerPed, i, savedOutfit[i].drawable, savedOutfit[i].texture, 2)
        end
    end

    ClearAllPedProps(playerPed)
    savedOutfit = {}
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
                    lib.notify({
                        title = 'Oxygen depleted!',
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
            Wait(100)
            if IsPedSwimming(cache.ped) then
                local oxygenPercent = math.floor((oxygenLevel / Config.client.startingOxygenLevel) * 100)
                BeginTextCommandDisplayHelp("STRING")
                AddTextComponentString("~b~OXYGEN: ~s~" .. oxygenPercent .. "%")
                EndTextCommandDisplayHelp(0, false, true, -1)
            end
        end
    end)
end

local function putOnSuit()
    if currentGear.maskAndTank then
        return lib.notify({
            title = 'Suit already equipped',
            type = 'info'
        })
    end

    if IsEntityInWater(cache.ped) then
        return lib.notify({
            title = 'Cannot equip underwater',
            type = 'error'
        })
    end

    if GetVehiclePedIsIn(cache.ped) ~= 0 then
        return lib.notify({
            title = 'Cannot equip in vehicle',
            type = 'error'
        })
    end

    if lib.progressBar({
        duration = Config.client.putOnSuitTimeMs,
        label = 'Putting on suit...',
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
        setGearClothing()
        enableScuba()
        startOxygenLevelDecrementerThread()
        startOxygenLevelDrawTextThread()
        lib.notify({
            title = 'Suit equipped',
            type = 'success'
        })
    end
end

local function takeOffSuit()
    if not currentGear.maskAndTank then
        return lib.notify({
            title = 'No suit equipped',
            type = 'info'
        })
    end

    if lib.progressBar({
        duration = Config.client.takeOffSuitTimeMs,
        label = 'Taking off suit...',
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
        resetClothing()
        lib.notify({
            title = 'Suit removed',
            type = 'success'
        })
    end
end

local function fillTank()
    if not currentGear.maskAndTank then
        return lib.notify({
            title = 'No suit equipped',
            type = 'error'
        })
    end

    if IsEntityInWater(cache.ped) then
        return lib.notify({
            title = 'Cannot refill underwater',
            type = 'error'
        })
    end

    if lib.progressBar({
        duration = Config.client.refillTankTimeMs,
        label = 'Refilling tank...',
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
            title = 'Tank refilled',
            type = 'success'
        })
    end
end

RegisterNetEvent('qbx_divegear:client:useGear', function()
    if currentGear.maskAndTank then
        takeOffSuit()
    else
        putOnSuit()
    end
end)

lib.callback.register('qbx_divegear:client:fillTank', function(source, cb)
    fillTank()
    cb(true)
end)
