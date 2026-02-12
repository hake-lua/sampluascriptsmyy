local sampev = require 'lib.samp.events'
local ffi = require 'ffi'


-- Skripta znaci nidje veze ja je pisao iz dosade da hajmo reci simuliram enter, animacije itd kada lik ulazi u auto, 
-- trebalo mi bilo za njinja jack destroyera pa ono mislio radit v3 i nisam imao vremena pa hajd eto da objavim.


local ANIMATION_SEQUENCE = {
    
    {id = 1189, flags = 33000, count = 1, delay = 50}, 
    {id = 1009, flags = 32772, count = 1, delay = 50}, 
    
    
    {id = 1043, flags = 32772, count = 10, delay = 50}, 
    
    
    {id = 1026, flags = 32772, count = 15, delay = 50}, 
    
    
    {id = 1013, flags = 33000, count = 1, delay = 50}, 
}

local SPECIAL_ACTION_ENTER = 3 

local aktivno = false 

function sampev.onSendPlayerSync(data)
    if aktivno then 
        return false 
    end 
end


function executeSimulatedEnter(vehicleID)
    aktivno = true 
    local myPed = PLAYER_PED
    local result, carHandle = sampGetCarHandleBySampVehicleId(vehicleID)
    
    if not result then
        sampAddChatMessage("Er: Vozilo ID " .. vehicleID .. " nema ga..", 0xFF0000)
        aktivno = false
        return
    end

    sampAddChatMessage("--- Aktivirano --", 0x00FF00)

    
    local function sendFakePlayerSync(animID, animFlags)
        local data = samp_create_sync_data("player") 

        data.animation.id = animID

        data.animation.id = animID

        data.animationFlags = animFlags 
        
        data.animation.id = animID
        
        data.animation.id = animID
        data.animationFlags = animFlags 
        
        data.send()
    end

    
    
    
    sendFakePlayerSync(ANIMATION_SEQUENCE[1].id, ANIMATION_SEQUENCE[1].flags)
    wait(ANIMATION_SEQUENCE[1].delay)
    
    
    sendFakePlayerSync(ANIMATION_SEQUENCE[2].id, ANIMATION_SEQUENCE[2].flags)
    wait(ANIMATION_SEQUENCE[2].delay)

    
    sampAddChatMessage("RPC EnterVehicle...", 0xFFFF00)
    sampSendEnterVehicle(vehicleID, false) 
    wait(50) 
    
    
    
    sampAddChatMessage("Simulacija animacije (1043 & 10266)...", 0x00FFFF)
    
    
    for i = 3, #ANIMATION_SEQUENCE do
        local step = ANIMATION_SEQUENCE[i]
        for j = 1, step.count do
            sendFakePlayerSync(step.id, step.flags)
            wait(step.delay)
        end
    end
    
    sampAddChatMessage("Warp u auto i prelazak na VehicleSync...", 0xFFFF00)
    
    
    taskWarpCharIntoCarAsDriver(myPed, carHandle) 
    
    
    for i = 1, 5 do 
        sampForceVehicleSync(vehicleID) 
        wait(50)
    end
    
    aktivno = false 
    sampAddChatMessage("--- Ulazak Done ---", 0x00FF00)
end

function cmdSimulatedEnter(arg)
    local vehicleID = tonumber(arg)
    
    if aktivno then
        sampAddChatMessage("Proces je već aktivan. Sačekajte da završi.", 0xFF0000)
        return
    end

    if vehicleID and vehicleID > 0 then
        local result, carHandle = sampGetCarHandleBySampVehicleId(vehicleID)
        if result then
            lua_thread.create(executeSimulatedEnter, vehicleID)
        else
            sampAddChatMessage("Vozilo nije pronađeno/učitano.", 0xFF0000)
        end
    else
        sampAddChatMessage("Korištenje: /en [ID vozila].", 0xFFFF00)
    end
end
sampRegisterChatCommand("en", cmdSimulatedEnter)


function samp_create_sync_data(sync_type, copy_from_player) 
    
    
    local sampfuncs = require 'sampfuncs' 
    local raknet = require 'samp.raknet' 
    require 'samp.synchronization' 
    copy_from_player = copy_from_player or true 
    
    local sync_traits = { 
        player = {'PlayerSyncData', raknet.PACKET.PLAYER_SYNC, sampStorePlayerOnfootData}, 
        vehicle = {'VehicleSyncData', raknet.PACKET.VEHICLE_SYNC, sampStorePlayerIncarData}, 
        passenger = {'PassengerSyncData', raknet.PACKET.PASSENGER_SYNC, sampStorePlayerPassengerData}, 
        aim = {'AimSyncData', raknet.PACKET.AIM_SYNC, sampStorePlayerAimData}, 
        trailer = {'TrailerSyncData', raknet.PACKET.TRAILER_SYNC, sampStorePlayerTrailerData}, 
        unoccupied = {'UnoccupiedSyncData', raknet.PACKET.UNOCCUPIED_SYNC, nil}, 
        bullet = {'BulletSyncData', raknet.PACKET.BULLET_SYNC, nil}, 
        spectator = {'SpectatorSyncData', raknet.PACKET.SPECTATOR_SYNC, nil} 
    } 
    
    local sync_info = sync_traits[sync_type] 
    if not sync_info then 
        error("Unknown sync type: " .. tostring(sync_type)) 
    end 
    
    local data_type = 'struct ' .. sync_info[1] 
    local data = ffi.new(data_type, {}) 
    local raw_data_ptr = tonumber(ffi.cast('uintptr_t', ffi.new(data_type .. '*', data))) 
    
    if copy_from_player then 
        local copy_func = sync_info[3] 
        if copy_func then 
            local _, player_id 
            if copy_from_player == true then 
                _, player_id = sampGetPlayerIdByCharHandle(PLAYER_PED) 
            else 
                player_id = tonumber(copy_from_player) 
            end 
            if player_id then 
                copy_func(player_id, raw_data_ptr) 
            end 
        end 
    end 
    
    local func_send = function() 
        local bs = raknetNewBitStream() 
        raknetBitStreamWriteInt8(bs, sync_info[2]) 
        raknetBitStreamWriteBuffer(bs, raw_data_ptr, ffi.sizeof(data)) 
        raknetSendBitStreamEx(bs, sampfuncs.HIGH_PRIORITY, sampfuncs.UNRELIABLE_SEQUENCED, 1) 
        raknetDeleteBitStream(bs) 
    end 
    
    local mt = { 
        __index = function(t, index) 
            return data[index] 
        end, 
        __newindex = function(t, index, value) 
            data[index] = value 
        end 
    } 
    
    return setmetatable({send = func_send}, mt) 
end