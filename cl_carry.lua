local carry = {
    InProgress = false,
    targetSrc = -1,
    type = "",
    personCarrying = {
        animDict = "missfinale_c2mcs_1",
        anim = "fin_c2_mcs_1_camman",
        flag = 49,
    },
    personCarried = {
        animDict = "nm",
        anim = "firemans_carry",
        attachX = 0.27,
        attachY = 0.15,
        attachZ = 0.63,
        flag = 33,
    }
}

local trunk = {
    inTrunk = false,
    vehicle = nil,
    cam = 0,
}

-- Trunk offsets by vehicle class
local trunkClasses = {
    [0] = {allowed = true, x = 0.0, y = -1.5, z = 0.0}, -- Coupes
    [1] = {allowed = true, x = 0.0, y = -2.0, z = 0.0}, -- Sedans
    [2] = {allowed = true, x = 0.0, y = -1.0, z = 0.25}, -- SUVs
    [3] = {allowed = true, x = 0.0, y = -1.5, z = 0.0}, -- Coupes
    [4] = {allowed = true, x = 0.0, y = -2.0, z = 0.0}, -- Muscle
    [5] = {allowed = true, x = 0.0, y = -2.0, z = 0.0}, -- Sports Classics
    [6] = {allowed = true, x = 0.0, y = -2.0, z = 0.0}, -- Sports
    [7] = {allowed = true, x = 0.0, y = -2.0, z = 0.0}, -- Super
    [8] = {allowed = false, x = 0.0, y = -1.0, z = 0.25}, -- Motorcycles
    [9] = {allowed = true, x = 0.0, y = -1.0, z = 0.25}, -- Off-road
    [10] = {allowed = true, x = 0.0, y = -1.0, z = 0.25}, -- Industrial
    [11] = {allowed = true, x = 0.0, y = -1.0, z = 0.25}, -- Utility
    [12] = {allowed = true, x = 0.0, y = -1.0, z = 0.25}, -- Vans
    [13] = {allowed = true, x = 0.0, y = -1.0, z = 0.25}, -- Cycles
    [14] = {allowed = true, x = 0.0, y = -1.0, z = 0.25}, -- Boats
    [15] = {allowed = true, x = 0.0, y = -1.0, z = 0.25}, -- Helicopters
    [16] = {allowed = true, x = 0.0, y = -1.0, z = 0.25}, -- Planes
    [17] = {allowed = true, x = 0.0, y = -1.0, z = 0.25}, -- Service
    [18] = {allowed = true, x = 0.0, y = -1.0, z = 0.25}, -- Emergency
    [19] = {allowed = true, x = 0.0, y = -1.0, z = 0.25}, -- Military
    [20] = {allowed = true, x = 0.0, y = -1.0, z = 0.25}, -- Commercial
    [21] = {allowed = true, x = 0.0, y = -1.0, z = 0.25}, -- Trains
}

local disabledTrunk = {
    [`penetrator`] = true,
    [`vacca`] = true,
    [`monroe`] = true,
    [`turismor`] = true,
    [`osiris`] = true,
    [`comet`] = true,
    [`ardent`] = true,
    [`jester`] = true,
    [`nero`] = true,
    [`nero2`] = true,
    [`vagner`] = true,
    [`infernus`] = true,
    [`zentorno`] = true,
    [`comet2`] = true,
    [`comet3`] = true,
    [`comet4`] = true,
    [`bullet`] = true,
}

local function notify(text, type, duration)
    if lib and lib.notify then
        lib.notify({
            description = text,
            type = type or 'info',
            duration = duration or 5000
        })
    end
end

local function GetClosestPlayer(radius)
    local players = GetActivePlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for _, playerId in ipairs(players) do
        local targetPed = GetPlayerPed(playerId)
        if targetPed ~= playerPed then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(targetCoords - playerCoords)
            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = playerId
                closestDistance = distance
            end
        end
    end
    return (closestDistance ~= -1 and closestDistance <= radius) and closestPlayer or nil
end

local function ensureAnimDict(animDict)
    if not HasAnimDictLoaded(animDict) then
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Wait(0)
        end
    end
end

local function getVehiclePlate(vehicle)
    local plate = GetVehicleNumberPlateText(vehicle)
    if plate then
        -- Trim whitespace from plate
        return plate:gsub("^%s+", ""):gsub("%s+$", "")
    end
    return plate
end

local function TrunkCam(bool)
    if bool then
        local vehicle = trunk.vehicle
        if not vehicle or not DoesEntityExist(vehicle) then return end
        
        local drawPos = GetOffsetFromEntityInWorldCoords(vehicle, 0, -5.5, 0)
        local vehHeading = GetEntityHeading(vehicle)
        
        RenderScriptCams(false, false, 0, true, false)
        if DoesCamExist(trunk.cam) then
            DestroyCam(trunk.cam, false)
            trunk.cam = 0
        end

        trunk.cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
        SetCamActive(trunk.cam, true)
        SetCamCoord(trunk.cam, drawPos.x, drawPos.y, drawPos.z + 2)
        SetCamRot(trunk.cam, -2.5, 0.0, vehHeading, 0.0)
        RenderScriptCams(true, false, 0, true, true)
    else
        RenderScriptCams(false, false, 0, true, false)
        if DoesCamExist(trunk.cam) then
            DestroyCam(trunk.cam, false)
            trunk.cam = 0
        end
    end
end

local function DrawText3Ds(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextColour(255, 255, 255, 215)
    BeginTextCommandDisplayText("STRING")
    SetTextCentre(true)
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(x, y, z, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    local factor = string.len(text) / 370
    DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

RegisterCommand("carry", function()
    if carry.type == "beingcarried" then
        notify("You cannot uncarry yourself while being carried!", "error")
        return
    end

    if not carry.InProgress then
        local closestPlayer = GetClosestPlayer(3)
        if closestPlayer then
            local targetSrc = GetPlayerServerId(closestPlayer)
            if targetSrc ~= -1 then
                carry.InProgress = true
                carry.targetSrc = targetSrc
                TriggerServerEvent("CarryPeople:sync", targetSrc)
                ensureAnimDict(carry.personCarrying.animDict)

                -- Play animation for the person carrying
                TaskPlayAnim(PlayerPedId(), carry.personCarrying.animDict, carry.personCarrying.anim, 8.0, -8.0, -1, carry.personCarrying.flag, 0, false, false, false)
                carry.type = "carrying"
            else
                notify("No one nearby to carry!", "error")
            end
        else
            notify("No one nearby to carry!", "error")
        end
    else
        carry.InProgress = false
        carry.type = ""
        ClearPedSecondaryTask(PlayerPedId())
        DetachEntity(PlayerPedId(), true, false)
        TriggerServerEvent("CarryPeople:stop", carry.targetSrc)
        carry.targetSrc = 0
    end
end, false)

RegisterNetEvent("CarryPeople:syncTarget")
AddEventHandler("CarryPeople:syncTarget", function(targetSrc)
    local targetPed = GetPlayerPed(GetPlayerFromServerId(targetSrc))
    carry.InProgress = true
    ensureAnimDict(carry.personCarried.animDict)

    
    AttachEntityToEntity(PlayerPedId(), targetPed, 0, carry.personCarried.attachX, carry.personCarried.attachY, carry.personCarried.attachZ, 0.5, 0.5, 180, false, false, false, false, 2, false)
    
    
    TaskPlayAnim(PlayerPedId(), carry.personCarried.animDict, carry.personCarried.anim, 8.0, -8.0, -1, carry.personCarried.flag, 0, false, false, false)
    
    carry.type = "beingcarried"
end)

RegisterNetEvent("CarryPeople:cl_stop")
AddEventHandler("CarryPeople:cl_stop", function()
    carry.InProgress = false
    carry.type = ""
    ClearPedSecondaryTask(PlayerPedId())
    DetachEntity(PlayerPedId(), true, false)
end)

-- Function to put carried player in trunk
local function putCarriedPlayerInTrunk()
    if carry.type ~= "carrying" or not carry.InProgress then
        return false
    end

    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local closestVehicle = nil
    
    -- Try to get closest vehicle using lib if available
    if lib and lib.getClosestVehicle then
        closestVehicle = lib.getClosestVehicle(coords, 5.0, false)
    else
        -- Fallback method
        closestVehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
    end

    if not closestVehicle or closestVehicle == 0 then
        return false
    end

    local vehClass = GetVehicleClass(closestVehicle)
    local vehModel = GetEntityModel(closestVehicle)
    
    -- Check if vehicle class allows trunk
    if not trunkClasses[vehClass] or not trunkClasses[vehClass].allowed then
        return false
    end

    -- Check if vehicle is disabled
    if disabledTrunk[vehModel] then
        return false
    end

    -- Check if trunk is open
    if GetVehicleDoorAngleRatio(closestVehicle, 5) <= 0 then
        return false
    end

    local plate = getVehiclePlate(closestVehicle)
    local isBusy = lib.callback.await('carry:server:getTrunkBusy', false, plate)
    
    if isBusy then
        return false
    end

    -- Stop carrying
    carry.InProgress = false
    carry.type = ""
    ClearPedSecondaryTask(playerPed)
    DetachEntity(playerPed, true, false)
    
    -- Get vehicle network ID
    local vehicleNetId = NetworkGetNetworkIdFromEntity(closestVehicle)
    
    -- Put carried player in trunk
    TriggerServerEvent("CarryPeople:putInTrunk", carry.targetSrc, vehicleNetId)
    carry.targetSrc = 0
    
    notify("Put player in trunk!", "success")
    return true
end

-- Event to be put in trunk
RegisterNetEvent("CarryPeople:putInTrunk")
AddEventHandler("CarryPeople:putInTrunk", function(vehicleNetId)
    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
    
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
        -- Fallback: find closest vehicle
        local coords = GetEntityCoords(PlayerPedId())
        if lib and lib.getClosestVehicle then
            vehicle = lib.getClosestVehicle(coords, 5.0, false)
        else
            vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
        end
    end

    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
        return
    end

    local vehClass = GetVehicleClass(vehicle)
    if not trunkClasses[vehClass] or not trunkClasses[vehClass].allowed then
        return
    end

    -- Stop carry animations
    carry.InProgress = false
    carry.type = ""
    ClearPedSecondaryTask(PlayerPedId())
    DetachEntity(PlayerPedId(), true, false)

    -- Get trunk offset
    local offset = trunkClasses[vehClass]
    
    -- Play animation and attach to trunk
    ensureAnimDict("fin_ext_p1-7")
    local playerPed = PlayerPedId()
    if lib and lib.playAnim then
        lib.playAnim(playerPed, "fin_ext_p1-7", "cs_devin_dual-7", 8.0, 8.0, -1, 1, 999.0, false, false, false)
    else
        TaskPlayAnim(playerPed, "fin_ext_p1-7", "cs_devin_dual-7", 8.0, 8.0, -1, 1, 999.0, false, false, false)
    end
    AttachEntityToEntity(playerPed, vehicle, 0, offset.x, offset.y, offset.z, 0, 0, 40.0, true, true, true, true, 1, true)
    
    -- Set trunk state
    trunk.inTrunk = true
    trunk.vehicle = vehicle
    
    local plate = getVehiclePlate(vehicle)
    TriggerServerEvent('carry:server:setTrunkBusy', plate, true)
    
    Wait(500)
    SetVehicleDoorShut(vehicle, 5, false)
    
    TrunkCam(true)
end)

-- Event to exit trunk
RegisterNetEvent("CarryPeople:exitTrunk")
AddEventHandler("CarryPeople:exitTrunk", function()
    if not trunk.inTrunk or not trunk.vehicle or not DoesEntityExist(trunk.vehicle) then
        return
    end

    if GetVehicleDoorAngleRatio(trunk.vehicle, 5) <= 0 then
        return
    end

    local vehCoords = GetOffsetFromEntityInWorldCoords(trunk.vehicle, 0, -5.0, 0)
    DetachEntity(PlayerPedId(), true, true)
    ClearPedTasks(PlayerPedId())
    
    local plate = getVehiclePlate(trunk.vehicle)
    TriggerServerEvent('carry:server:setTrunkBusy', plate, false)
    
    SetEntityCoords(PlayerPedId(), vehCoords.x, vehCoords.y, vehCoords.z, false, false, false, false)
    SetEntityCollision(PlayerPedId(), true, true)
    
    trunk.inTrunk = false
    trunk.vehicle = nil
    TrunkCam(false)
end)

Citizen.CreateThread(function()
    while true do
        if carry.InProgress then
            if carry.type == "beingcarried" then
                if not IsEntityPlayingAnim(PlayerPedId(), carry.personCarried.animDict, carry.personCarried.anim, 3) then
                    TaskPlayAnim(PlayerPedId(), carry.personCarried.animDict, carry.personCarried.anim, 8.0, -8.0, -1, carry.personCarried.flag, 0, false, false, false)
                end
            
                -- Force Close ox_inventory if open
                if exports.ox_inventory then
                    exports.ox_inventory:closeInventory()
                end

            elseif carry.type == "carrying" then
                if not IsEntityPlayingAnim(PlayerPedId(), carry.personCarrying.animDict, carry.personCarrying.anim, 3) then
                    TaskPlayAnim(PlayerPedId(), carry.personCarrying.animDict, carry.personCarrying.anim, 8.0, -8.0, -1, carry.personCarrying.flag, 0, false, false, false)
                end
            end
        end
        Wait(0)
    end
end)

-- Trunk camera thread
Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        if DoesCamExist(trunk.cam) then
            local vehicle = trunk.vehicle
            if vehicle and DoesEntityExist(vehicle) then
                sleep = 0
                local drawPos = GetOffsetFromEntityInWorldCoords(vehicle, 0, -5.5, 0)
                local vehHeading = GetEntityHeading(vehicle)
                SetCamRot(trunk.cam, -2.5, 0.0, vehHeading, 0.0)
                SetCamCoord(trunk.cam, drawPos.x, drawPos.y, drawPos.z + 2)
            end
        end
        Wait(sleep)
    end
end)

-- Trunk exit thread (only when trunk is open)
Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        if trunk.inTrunk and trunk.vehicle and DoesEntityExist(trunk.vehicle) then
            local vehicle = trunk.vehicle
            local trunkOpen = GetVehicleDoorAngleRatio(vehicle, 5) > 0
            local drawPos = GetOffsetFromEntityInWorldCoords(vehicle, 0, -2.5, 0)
            
            if trunkOpen then
                sleep = 0
                DrawText3Ds(drawPos.x, drawPos.y, drawPos.z + 0.75, "[E] Exit Trunk")
                
                if IsControlJustPressed(0, 38) then -- E key
                    TriggerEvent("CarryPeople:exitTrunk")
                    Wait(100)
                end
            end
        end
        Wait(sleep)
    end
end)

-- Thread to show textui when carrying someone near open trunk
Citizen.CreateThread(function()
    local showingTextUI = false
    local lastPlate = nil
    local lastBusyCheck = 0
    local cachedIsBusy = false
    
    while true do
        local sleep = 1000
        
        -- Check if player is carrying someone
        if carry.type == "carrying" and carry.InProgress then
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            local closestVehicle = nil
            
            -- Try to get closest vehicle using lib if available
            if lib and lib.getClosestVehicle then
                closestVehicle = lib.getClosestVehicle(coords, 5.0, false)
            else
                -- Fallback method
                closestVehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
            end

            if closestVehicle and closestVehicle ~= 0 then
                local vehClass = GetVehicleClass(closestVehicle)
                local vehModel = GetEntityModel(closestVehicle)
                local trunkOpen = GetVehicleDoorAngleRatio(closestVehicle, 5) > 0
                
                -- Check if vehicle allows trunk and trunk is open
                if trunkOpen and trunkClasses[vehClass] and trunkClasses[vehClass].allowed and not disabledTrunk[vehModel] then
                    local plate = getVehiclePlate(closestVehicle)
                    local currentTime = GetGameTimer()
                    local isBusy = false
                    
                    -- Cache the busy check for 500ms to avoid spamming callbacks
                    if plate == lastPlate and (currentTime - lastBusyCheck) < 500 then
                        -- Use cached result
                        isBusy = cachedIsBusy
                    else
                        isBusy = lib.callback.await('carry:server:getTrunkBusy', false, plate)
                        lastPlate = plate
                        lastBusyCheck = currentTime
                        cachedIsBusy = isBusy
                    end
                    
                    if not isBusy then
                        sleep = 0
                        if not showingTextUI then
                            if lib and lib.showTextUI then
                                lib.showTextUI('[E] Put in Trunk')
                            end
                            showingTextUI = true
                        end
                        
                        -- Check for E key press
                        if IsControlJustPressed(0, 38) then -- E key
                            if putCarriedPlayerInTrunk() then
                                -- Successfully put in trunk, hide UI immediately
                                if lib and lib.hideTextUI then
                                    lib.hideTextUI()
                                end
                                showingTextUI = false
                                lastPlate = nil
                                lastBusyCheck = 0
                                cachedIsBusy = false
                            end
                            Wait(50) -- Reduced from 100ms
                        end
                    else
                        if showingTextUI then
                            if lib and lib.hideTextUI then
                                lib.hideTextUI()
                            end
                            showingTextUI = false
                        end
                        lastPlate = nil
                        lastBusyCheck = 0
                        cachedIsBusy = false
                    end
                else
                    if showingTextUI then
                        if lib and lib.hideTextUI then
                            lib.hideTextUI()
                        end
                        showingTextUI = false
                    end
                    lastPlate = nil
                    lastBusyCheck = 0
                    cachedIsBusy = false
                end
            else
                if showingTextUI then
                    if lib and lib.hideTextUI then
                        lib.hideTextUI()
                    end
                    showingTextUI = false
                end
                lastPlate = nil
                lastBusyCheck = 0
                cachedIsBusy = false
            end
        else
            if showingTextUI then
                if lib and lib.hideTextUI then
                    lib.hideTextUI()
                end
                showingTextUI = false
            end
            lastPlate = nil
            lastBusyCheck = 0
            cachedIsBusy = false
        end
        
        Wait(sleep)
    end
end)

