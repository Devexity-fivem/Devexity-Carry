local carrying = {}
local carried = {}

RegisterServerEvent("CarryPeople:sync")
AddEventHandler("CarryPeople:sync", function(targetSrc)
    local source = source
    if #(GetEntityCoords(GetPlayerPed(source)) - GetEntityCoords(GetPlayerPed(targetSrc))) <= 3.0 then 
        TriggerClientEvent("CarryPeople:syncTarget", targetSrc, source)
        carrying[source] = targetSrc
        carried[targetSrc] = source
    end
end)

RegisterServerEvent("CarryPeople:stop")
AddEventHandler("CarryPeople:stop", function(targetSrc)
    local source = source

    if carrying[source] then
        TriggerClientEvent("CarryPeople:cl_stop", targetSrc)
        carrying[source] = nil
        carried[targetSrc] = nil
    elseif carried[source] then
        TriggerClientEvent("CarryPeople:cl_stop", carried[source])			
        carrying[carried[source]] = nil
        carried[source] = nil
    end

    TriggerClientEvent("CarryPeople:cl_stop", source)
end)

-- Callback to check if a player is carrying someone
lib.callback.register('carry:server:getCarriedPlayer', function(source)
    return carrying[source]
end)

-- Trunk state management
local trunkBusy = {}

-- Event to put carried player in trunk
RegisterServerEvent("CarryPeople:putInTrunk")
AddEventHandler("CarryPeople:putInTrunk", function(targetSrc, vehicleNetId)
    local source = source
    
    -- Verify the source is actually carrying the target
    if carrying[source] ~= targetSrc then
        return
    end
    
    -- Stop the carry
    carrying[source] = nil
    carried[targetSrc] = nil
    TriggerClientEvent("CarryPeople:cl_stop", source)
    TriggerClientEvent("CarryPeople:cl_stop", targetSrc)
    
    -- Put target in trunk
    TriggerClientEvent("CarryPeople:putInTrunk", targetSrc, vehicleNetId)
end)

-- Set trunk busy state
RegisterServerEvent('carry:server:setTrunkBusy')
AddEventHandler('carry:server:setTrunkBusy', function(plate, busy)
    if busy then
        trunkBusy[plate] = true
    else
        trunkBusy[plate] = nil
    end
end)

-- Callback to check if trunk is busy
lib.callback.register('carry:server:getTrunkBusy', function(source, plate)
    return trunkBusy[plate] or false
end)

-- Cleanup on disconnect
AddEventHandler('playerDropped', function()
    local source = source
	
    -- Cleanup carry state
    if carrying[source] then
        TriggerClientEvent("CarryPeople:cl_stop", carrying[source])
        carried[carrying[source]] = nil
        carrying[source] = nil
    end

    if carried[source] then
        TriggerClientEvent("CarryPeople:cl_stop", carried[source])
        carrying[carried[source]] = nil
        carried[source] = nil
    end
    
    -- Cleanup trunk state - find and clear any trunk the player was in
    -- This is a simple cleanup, you might want to track which plate each player is in
    -- For now, we'll let the client handle cleanup when they exit
end)
