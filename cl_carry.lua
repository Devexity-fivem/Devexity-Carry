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

local function drawNativeNotification(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
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

RegisterCommand("carry", function()
    if carry.type == "beingcarried" then
        drawNativeNotification("~r~You cannot uncarry yourself while being carried!")
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
                drawNativeNotification("~r~No one nearby to carry!")
            end
        else
            drawNativeNotification("~r~No one nearby to carry!")
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

Citizen.CreateThread(function()
    while true do
        if carry.InProgress then
            if carry.type == "beingcarried" then
                if not IsEntityPlayingAnim(PlayerPedId(), carry.personCarried.animDict, carry.personCarried.anim, 3) then
                    TaskPlayAnim(PlayerPedId(), carry.personCarried.animDict, carry.personCarried.anim, 8.0, -8.0, -1, carry.personCarried.flag, 0, false, false, false)
                end

                -- Combat and Weapon Controls
                DisableControlAction(0, 24, true)   -- Attack
                DisableControlAction(0, 257, true)  -- Attack 2
                DisableControlAction(0, 25, true)   -- Aim
                DisableControlAction(0, 263, true)  -- Melee Attack 1
                DisableControlAction(0, 47, true)   -- Disable weapon
                DisableControlAction(0, 264, true)  -- Disable melee
                DisableControlAction(0, 140, true)  -- Disable melee
                DisableControlAction(0, 141, true)  -- Disable melee
                DisableControlAction(0, 142, true)  -- Disable melee
                DisableControlAction(0, 143, true)  -- Disable melee
                DisableControlAction(0, 16, true)  -- Disable shift
                DisableControlAction(0, 76, true)  -- Disable L

                -- Inventory Controls
                DisableControlAction(0, 289, true)  -- F2 (ox_inventory, some QBCore inventories)
                DisableControlAction(0, 37, true)   -- Tab (QBCore Inventory)
                DisableControlAction(0, 170, true)  -- F3 (Sometimes used for inventory)

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

