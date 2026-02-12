-- OVERTAKER SLLAPER DAVNO ISTO PISAN, MALO BOLJI KOD U ODNOSU NA MOJE PREDHODNE SKRIPTE ONO RADIO SAM GA NA MAX FAZON U 3 UJUTRO LOL
-- ISTO MOZE SE RECI OUTDATED ZA NOVIJE SERVER ALI IPAK KORISAN

require "lib.moonloader"
events = require('samp.events')
json = require("json")
lfs = require("lfs")
bit = require("bit")
sampfuncs = require('sampfuncs')
raknet = require('samp.raknet')
imgui = require 'imgui'
mimgui = require 'mimgui'
ffi = require 'ffi'
encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
utf8 = encoding.UTF8
                     
local configs = {
    onfoot = {
        throw_speed_x = imgui.ImFloat(0.0),
        boost_interval_x = imgui.ImFloat(0.0),
        direction_x = imgui.ImInt(1),
        throw_speed_x_random_min = imgui.ImFloat(0.0),
        throw_speed_x_random_max = imgui.ImFloat(0.0),
        throw_speed_x_random_enabled = imgui.ImBool(false),

        throw_speed_y = imgui.ImFloat(0.3),
        boost_interval_y = imgui.ImFloat(1.5),
        direction_y = imgui.ImInt(1),
        throw_speed_y_random_min = imgui.ImFloat(0.0),
        throw_speed_y_random_max = imgui.ImFloat(0.0),
        throw_speed_y_random_enabled = imgui.ImBool(false),

        throw_speed_z = imgui.ImFloat(0.5),
        boost_interval_z = imgui.ImFloat(2.0),
        direction_z = imgui.ImInt(1),
        throw_speed_z_random_min = imgui.ImFloat(0.0),
        throw_speed_z_random_max = imgui.ImFloat(0.0),
        throw_speed_z_random_enabled = imgui.ImBool(false),

        offset_x_plus = imgui.ImFloat(0.0),

        offset_y_plus = imgui.ImFloat(0.0),

        offset_z_plus = imgui.ImFloat(0.0),

        vehicle_pitch = imgui.ImFloat(0.0),
        vehicle_roll = imgui.ImFloat(-90.0),
        vehicle_yaw = imgui.ImFloat(0.0),

        

        packets_ps = imgui.ImFloat(50.0),
        min_range = imgui.ImFloat(0.0),
        max_range = imgui.ImFloat(40.0),

        victim_selector = imgui.ImInt(0),

        update_vehicle_damage_status = imgui.ImBool(true),
        set_vehicle_params_ex = imgui.ImBool(true),
        world_vehicle_remove = imgui.ImBool(true),
        set_vehicle_z_angle = imgui.ImBool(true),
        set_vehicle_pos = imgui.ImBool(true),
        set_vehicle_velocity = imgui.ImBool(true),
        set_vehicle_health = imgui.ImBool(true),
        remove_player_from_vehicle = imgui.ImBool(true),
        disable_vehicle_collisions = imgui.ImBool(true),
    },

    incar = {
        throw_speed_x = imgui.ImFloat(0.0),
        boost_interval_x = imgui.ImFloat(0.0),
        direction_x = imgui.ImInt(1),
        throw_speed_x_random_min = imgui.ImFloat(0.0),
        throw_speed_x_random_max = imgui.ImFloat(0.0),
        throw_speed_x_random_enabled = imgui.ImBool(false),

        throw_speed_y = imgui.ImFloat(0.3),
        boost_interval_y = imgui.ImFloat(1.5),
        direction_y = imgui.ImInt(1),
        throw_speed_y_random_min = imgui.ImFloat(0.0),
        throw_speed_y_random_max = imgui.ImFloat(0.0),
        throw_speed_y_random_enabled = imgui.ImBool(false),

        throw_speed_z = imgui.ImFloat(0.5),
        boost_interval_z = imgui.ImFloat(2.0),
        direction_z = imgui.ImInt(1),
        throw_speed_z_random_min = imgui.ImFloat(0.0),
        throw_speed_z_random_max = imgui.ImFloat(0.0),
        throw_speed_z_random_enabled = imgui.ImBool(false),

        offset_x_plus = imgui.ImFloat(0.0),

        offset_y_plus = imgui.ImFloat(0.0),

        offset_z_plus = imgui.ImFloat(0.0),

        vehicle_pitch = imgui.ImFloat(0.0),
        vehicle_roll = imgui.ImFloat(-90.0),
        vehicle_yaw = imgui.ImFloat(0.0),

        

        packets_ps = imgui.ImFloat(50.0),
        min_range = imgui.ImFloat(0.0),
        max_range = imgui.ImFloat(40.0),

        victim_selector = imgui.ImInt(0),

        update_vehicle_damage_status = imgui.ImBool(true),
        set_vehicle_params_ex = imgui.ImBool(true),
        world_vehicle_remove = imgui.ImBool(true),
        set_vehicle_z_angle = imgui.ImBool(true),
        set_vehicle_pos = imgui.ImBool(true),
        set_vehicle_velocity = imgui.ImBool(true),
        set_vehicle_health = imgui.ImBool(true),
        remove_player_from_vehicle = imgui.ImBool(true),
        disable_vehicle_collisions = imgui.ImBool(true),
    }
}

local mainConfigDefaults = {
    attack_r_enabled = imgui.ImBool(false),
    attack_lmb_enabled = imgui.ImBool(true)
}

local general = {
    targetIndex = 1,
    targetId = -1,
    speedX = 0,
    speedY = 0,
    speedZ = 0,
    lastSpeedIncreaseX = 0,
    lastSpeedIncreaseY = 0,
    lastSpeedIncreaseZ = 0
}

local script = {
    isWorking = false,
    _wasOn = false,
    _wasOff = false,
    speed = 0,
    lastSpeedIncrease = 0
}


local last_vehicle_speed = { x = 0.0, y = 0.0, z = 0.0 }

local random_cache = {}

local main_GUI = imgui.ImBool(false)
local output_GUI = imgui.ImBool(false)

local GUI_Zrtva, GUI_Status = "N/A", "N/A"
local KordinateX, KordinateY, KordinateZ = 0, 0, 0
local OffsetX, OffsetY, OffsetZ = 0, 0, 0
local BrzinaX, BrzinaY, BrzinaZ = 0, 0, 0
local Quent1, Quent2, Quent3, Quent4 = nil, nil, nil, nil

function ChatMessage(...) 
    sampAddChatMessage(string.format('{b969ff}[BIGBANG OVERTAKER]: %s', string.format(...)), -1) 
end

function resetGUI()
    GUI_Zrtva, GUI_Status = "N/A", "N/A"
    KordinateX, KordinateY, KordinateZ = 0, 0, 0
    OffsetX, OffsetY, OffsetZ = 0, 0, 0
    BrzinaX, BrzinaY, BrzinaZ = 0, 0, 0
    Quent1, Quent2, Quent3, Quent4 = nil, nil, nil, nil
end

function getAttackKey()
    if mainConfigDefaults.attack_lmb_enabled.v then
        return 0x01 
    elseif mainConfigDefaults.attack_r_enabled.v then
        return 0x52 
    end
    return nil
end

local download_connected = false
local download_data_loaded = false
local download_script_version = 0
local download_black_list = {}


local function downloadCallback(id, status)
    local dlstatus = require('moonloader').download_status
    
    if status == dlstatus.STATUS_ENDDOWNLOADDATA then
        local temp_path = os.getenv('TEMP') .. '\\firebase_data.json'
        local f = io.open(temp_path, 'r')
        if f then
            local content = f:read('*a')
            f:close()
            os.remove(temp_path)
            
            local success, data = pcall(json.decode, content)
            if success and data then
                
                if data.Settings and data.Settings.script_version then
                    download_script_version = tonumber(data.Settings.script_version) or 0
                end
                
                
                if data.black_list then
                    for firebase_key, info in pairs(data.black_list) do
                        local ip_port = firebase_key:gsub("_", ".", 3)
                        ip_port = ip_port:gsub("_", ":", 1)
                        download_black_list[ip_port] = true
                    end
                end
                
                download_data_loaded = true
            end
        end
        download_connected = true
    else
        if status == dlstatus.STATUS_EXTERROR then
            download_connected = true
        end
    end
end


local last_config_state = {}
local last_main_config_state = {}
local config_check_timer = 0


function monitorConfigChanges()
    local current_time = os.clock()
    
    
    if current_time - config_check_timer < 0.1 then
        return
    end
    config_check_timer = current_time
    
    local config_changed = false
    local main_config_changed = false
    
    
    for key, val in pairs(mainConfigDefaults) do
        if last_main_config_state[key] ~= val.v then
            main_config_changed = true
            last_main_config_state[key] = val.v
        end
    end
    
    
    local activeConfig = getActiveConfig()
    if activeConfig then
        for key, val in pairs(activeConfig) do
            if type(val) == "userdata" and val.v ~= nil then
                if last_config_state[key] ~= val.v then
                    config_changed = true
                    last_config_state[key] = val.v
                end
            end
        end
    end
    
    
    if config_changed then
        saveSettings()
        setVariablesForActiveConfig()
    end
    
    if main_config_changed then
        saveMainConfig()
    end
end


function initializeConfigMonitoring()
    
    for key, val in pairs(mainConfigDefaults) do
        last_main_config_state[key] = val.v
    end
    
    
    local activeConfig = getActiveConfig()
    if activeConfig then
        for key, val in pairs(activeConfig) do
            if type(val) == "userdata" and val.v ~= nil then
                last_config_state[key] = val.v
            end
        end
    end
end

function safeStoreCarCharIsInNoSave(pedHandle)
    if not pedHandle then return 0 end
    if not pcall(doesCharExist, pedHandle) then return 0 end
    
    local ok, result = pcall(storeCarCharIsInNoSave, pedHandle)
    return ok and result or 0
end

function safeGetCarCharIsUsing(pedHandle)
    if not pedHandle then return 0 end
    if not pcall(doesCharExist, pedHandle) then return 0 end
    
    local ok, result = pcall(getCarCharIsUsing, pedHandle)
    return ok and result or 0
end


function main()
    while not isSampAvailable() do wait(0) end

    local url = ''
    local temp_path = os.getenv('TEMP') .. '\\firebase_data.json'
    
    
    download_connected = false
    download_data_loaded = false
    download_script_version = 0
    download_black_list = {}

    
    local function attemptDownload()
        download_connected = false
        download_data_loaded = false
        downloadUrlToFile(url, temp_path, downloadCallback)
        
        
        local wait_time = 0
        while not download_connected do
            wait(100)
            wait_time = wait_time + 100
            if wait_time >= 5000 then
                break
            end
        end
        return download_data_loaded
    end
    
    
    local download_success = false
    --[[
    while not download_success do
        download_success = attemptDownload()
        
        if not download_success then
            wait(3000)
        end
    end
   
     OPET SAM IZBACIO HAE RECI KREKO SVOJ CIT LOL

    
    
    if download_script_version ~= 2.0 then
        ChatMessage("{ff1100}Ova verzija je zastarjela. UNLOADED")
        --thisScript():unload()
        return
    end
    
     ]]

    cleanupInvalidConfigs()
    loadAllConfigs()
    initializeConfigMonitoring()
    ChatMessage('{87ff97}LOADED!')
    ChatMessage('{6b6b6b}Aktivacija: {ffffff}/bov ili tipka F3')

    sampRegisterChatCommand("bov", function()
        main_GUI.v = not main_GUI.v
    end)

    lua_thread.create(slapper_main)
     
    while true do
        wait(0)

        --[[
        if data_loaded then
            local ip, port = sampGetCurrentServerAddress()
            if ip and port then
                local current_server = ip .. ":" .. tostring(port)
                if black_list[current_server] then
                    ChatMessage("{ff1100}Ovaj server je blacklistovan. UNLOADED")
                    thisScript():unload()
                    return
                end
            end
        end
        ]]

        imgui.Process = main_GUI.v or output_GUI.v

        if not main_GUI.v and status_on_enabled.v then
            output_GUI.v = true
        else
            output_GUI.v = false
        end

        if main_GUI.v then
            imgui.ShowCursor = true
        else
            imgui.ShowCursor = false
        end

        if isKeyJustPressed(0x72) then 
            main_GUI.v = not main_GUI.v
        end
        
        if status_on_enabled and status_on_enabled.v and not script._wasOn then
            resetGUI()
            script.isWorking = false
            script.speed = 0
            general.targetId = -1
            script.lastSpeedIncrease = os.clock()
            script._wasOn = true
            script._wasOff = false
        end

        if status_off_enabled and status_off_enabled.v and not script._wasOff then
            resetGUI()
            script.isWorking = false
            script.speed = 0
            general.targetId = -1
            script._wasOff = true
            script._wasOn = false
        end

        monitorConfigChanges()
    end
end

function slapper_main()

    local send_timers = {} 
    local target_switch_cooldown = 0
    local TARGET_SWITCH_COOLDOWN_TIME = 0.2 
    local attack_started = false 
    local oscillation_start_time = 0


    local function getRandomValue(key, min, max, interval)
        if not min or not max then return 0 end
        if max < min then min, max = max, min end
        interval = interval or 0.45

        local now = os.clock()
        local cache = random_cache[key] or { lastTime = 0, value = min }

        if (now - cache.lastTime) >= interval then
            cache.value = math.random() * (max - min) + min
            cache.lastTime = now
            random_cache[key] = cache
        end
        return cache.value
    end

    local function getConfigForTarget(targetId)
        local result, handle = sampGetCharHandleBySampPlayerId(targetId)
        if not result then return configs.incar end
        if doesCharExist(handle) and isCharInAnyCar(handle) then
            return configs.incar
        else
            return configs.onfoot
        end
    end

    local function safeGetCharCoords(handle)
        if handle and doesCharExist(handle) then
            local ok, x, y, z = pcall(getCharCoordinates, handle)
            if ok and x and y and z then
                return x, y, z
            end
        end
        return nil
    end

    local function myCharCoords()
        return safeGetCharCoords(PLAYER_PED)
    end

    local function isTargetInSameCar(targetHandle)
        if not doesCharExist(targetHandle) then return false end
        local myCar = safeStoreCarCharIsInNoSave(PLAYER_PED)
        local targetCar = safeStoreCarCharIsInNoSave(targetHandle)
        return myCar ~= 0 and myCar == targetCar
    end
    
    local function isTargetAllowedBySelector(charHandle)
        if not charHandle or not doesCharExist(charHandle) then
            return false
        end

        if isTargetInSameCar(charHandle) then
            return false
        end

        local cfg = getActiveConfig()
        local vs = cfg.victim_selector.v

        if vs == 0 then
            return true
        end

        local inCar = isCharInAnyCar(charHandle)
        if vs == 1 then
            return inCar
        elseif vs == 2 then
            return not inCar
        else
            return true
        end
    end
    
    local function isTargetInValidRange(dist, cfg)
        local MIN_RANGE = math.max(0, cfg.min_range.v)
        local MAX_RANGE = math.max(0, cfg.max_range.v)

        if MAX_RANGE < MIN_RANGE then
            MIN_RANGE, MAX_RANGE = MAX_RANGE, MIN_RANGE
        end
    
        return dist >= MIN_RANGE and dist <= MAX_RANGE
    end
    
    local function getValidTargets(cfg)
        local targets = {}
        local pX, pY, pZ = myCharCoords()
        if not pX then return targets end

        local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
        
        for i = 0, 1000 do
            if sampIsPlayerConnected(i) and not sampIsPlayerPaused(i) and i ~= myid then
                local result, handle = sampGetCharHandleBySampPlayerId(i)
                if result and doesCharExist(handle) and isTargetAllowedBySelector(handle) then
                    local tX, tY, tZ = safeGetCharCoords(handle)
                    if tX then
                        local dist = getDistanceBetweenCoords3d(pX, pY, pZ, tX, tY, tZ)
                        if isTargetInValidRange(dist, cfg) then
                            table.insert(targets, {
                                id = i,
                                dist = dist,
                                handle = handle,
                                nickname = sampGetPlayerNickname(i)
                            })
                        end
                    end
                end
            end
        end
        
        
        table.sort(targets, function(a, b) return a.dist < b.dist end)
        return targets
    end

    local function findNextTarget(currentTargetId, cfg)
        local targets = getValidTargets(cfg)
        if #targets == 0 then
            return -1, {}
        end
        
        
        if currentTargetId == -1 then
            return targets[1].id, targets
        end
        
        
        local currentIndex = 0
        for i, target in ipairs(targets) do
            if target.id == currentTargetId then
                currentIndex = i
                break
            end
        end
        
        
        if currentIndex == 0 or currentIndex == #targets then
            return targets[1].id, targets
        else
            
            return targets[currentIndex + 1].id, targets
        end
    end

    local function axisMaxSpeed(cfg, axis, keyBase)
        if axis == "x" then
            return cfg.throw_speed_x_random_enabled.v
                and getRandomValue(keyBase.."throw_speed_x", cfg.throw_speed_x_random_min.v, cfg.throw_speed_x_random_max.v, 0.45)
                or cfg.throw_speed_x.v
        elseif axis == "y" then
            return cfg.throw_speed_y_random_enabled.v
                and getRandomValue(keyBase.."throw_speed_y", cfg.throw_speed_y_random_min.v, cfg.throw_speed_y_random_max.v, 0.45)
                or cfg.throw_speed_y.v
        else
            return cfg.throw_speed_z_random_enabled.v
                and getRandomValue(keyBase.."throw_speed_z", cfg.throw_speed_z_random_min.v, cfg.throw_speed_z_random_max.v, 0.45)
                or cfg.throw_speed_z.v
        end
    end

    local function axisBoostInterval(cfg, axis)
        return (axis == "x" and cfg.boost_interval_x.v)
            or (axis == "y" and cfg.boost_interval_y.v)
            or cfg.boost_interval_z.v
    end

    local function axisDirection(cfg, axis)
        return (axis == "x" and cfg.direction_x.v)
            or (axis == "y" and cfg.direction_y.v)
            or cfg.direction_z.v
    end

    local direction_cache = {}

    local function getRandomDirection(key, interval)
        interval = interval or 0.45
        local now = os.clock()
        local cache = direction_cache[key] or { lastTime = 0, value = 1 }

        if (now - cache.lastTime) >= interval then
            cache.value = (math.random(0,1) == 1) and 1 or -1
            cache.lastTime = now
            direction_cache[key] = cache
        end
        return cache.value
    end

    local function calcSpeedForAxis(cfg, axis, currSpeed, key)
        local dir = axisDirection(cfg, axis)
        local magnitude = math.abs(currSpeed)
    
        if dir == 1 then
            return magnitude
        elseif dir == -1 then
            return -magnitude
        elseif dir == 2 then
            return getRandomDirection(key, 0.45) * magnitude
        else
            return 0
        end
    end

    
    local function eulerToQuaternion(pitch, roll, yaw)
        local pitch_rad = math.rad(pitch)
        local roll_rad = math.rad(roll)
        local yaw_rad = math.rad(yaw)
        
        local cy = math.cos(yaw_rad * 0.5)
        local sy = math.sin(yaw_rad * 0.5)
        local cp = math.cos(pitch_rad * 0.5)
        local sp = math.sin(pitch_rad * 0.5)
        local cr = math.cos(roll_rad * 0.5)
        local sr = math.sin(roll_rad * 0.5)
        
        local q = {}
        q.w = cr * cp * cy + sr * sp * sy
        q.x = sr * cp * cy - cr * sp * sy
        q.y = cr * sp * cy + sr * cp * sy
        q.z = cr * cp * sy - sr * sp * cy
        
        return q
    end

    
    local function calculateVehicleQuaternion()
        local cfg = getActiveConfig()
        local pitch = cfg.vehicle_pitch.v
        local roll = cfg.vehicle_roll.v
        local yaw = cfg.vehicle_yaw.v
        
        local quaternion = eulerToQuaternion(pitch, roll, yaw)
        
        return {
            quaternion.x,
            quaternion.y,
            quaternion.z,
            quaternion.w
        }
    end

    local function resetTargetState()
        resetGUI()
        general.targetId = -1
        general.speedX, general.speedY, general.speedZ = 0, 0, 0
        general.lastSpeedIncreaseX = os.clock()
        general.lastSpeedIncreaseY = general.lastSpeedIncreaseX
        general.lastSpeedIncreaseZ = general.lastSpeedIncreaseX
        attack_started = false
        oscillation_start_time = 0

    end

    local function isValidTarget(targetId)
        if targetId == -1 then return false end
        
        local result, handle = sampGetCharHandleBySampPlayerId(targetId)
        if not result or not doesCharExist(handle) then
            return false
        end
        
        if not sampIsPlayerConnected(targetId) or sampIsPlayerPaused(targetId) then
            return false
        end
        
        return true
    end

    local function stepAxis(axis, lastInc, currSpeed, cfg, now, keyBase)
        local maxS = axisMaxSpeed(cfg, axis, keyBase)
        local interval = axisBoostInterval(cfg, axis)

        if interval <= 0 then
            return maxS, lastInc
        end

        local elapsed = now - (lastInc or now)
        if elapsed <= 0 then
            return 0, lastInc
        end

        local ratio = elapsed / interval
        if ratio >= 1 then
            return maxS, lastInc
        else
            local newS = maxS * ratio
            return newS, lastInc
        end
    end

    
    local function sendZeroSpeedSync(targetId)
        if not isValidTarget(targetId) then return end
        
        local ok, tHandle = sampGetCharHandleBySampPlayerId(targetId)
        local tX, tY, tZ = safeGetCharCoords(tHandle)
        
        if tX then
            local zeroData = samp_create_sync_data('vehicle')
            local NaN = tonumber("NaN")
            local pX, pY, pZ = myCharCoords()
            --zeroData.position = { x = pX, y = pY, z = pZ }
            --zeroData.moveSpeed = { x = 0.0, y = 0.0, z = NaN }
            --zeroData.quaternion = calculateVehicleQuaternion()
            -- izbacio ljudino nema smisla 
            
        end
    end

    local function setVehicleCoordinates(vehicle, x, y, z)
        if doesVehicleExist(vehicle) then
            setCarCoordinates(vehicle, x, y, z)
        end
    end


    
    resetTargetState()

    local lastSoundTime = 0
    local lastTargetSwitchTime = 0

    while true do
        wait(0)
        local now = os.clock()
        local sound_timer = os.clock() * 1000

        
        if target_switch_cooldown > 0 then
            target_switch_cooldown = target_switch_cooldown - 0.016 
            if target_switch_cooldown < 0 then target_switch_cooldown = 0 end
        end

        
        if not main_GUI.v and status_on_enabled and status_on_enabled.v and isCharInAnyCar(PLAYER_PED) then
            local myCar = safeStoreCarCharIsInNoSave(PLAYER_PED)
            if myCar ~= 0 and getDriverOfCar(myCar) == PLAYER_PED and isKeyDown(getAttackKey()) then
                local cfg = getConfigForTarget((general.targetId ~= -1) and general.targetId or PLAYER_PED)

                
                if wasKeyPressed(VK_RBUTTON) and target_switch_cooldown <= 0 then
                    local newTargetId, allTargets = findNextTarget(general.targetId, cfg)
                    
                    if newTargetId ~= -1 then
                        
                        general.targetId = newTargetId
                        attack_started = false 
                        
                        addOneOffSound(0, 0, 0, 1150)
                        target_switch_cooldown = TARGET_SWITCH_COOLDOWN_TIME
                    end
                end

                
                if general.targetId == -1 then
                    local newTargetId = findNextTarget(-1, cfg)
                    if newTargetId ~= -1 then
                        general.targetId = newTargetId
                        attack_started = false 
                        
                    end
                else
                    
                    if not isValidTarget(general.targetId) then
                        
                        local newTargetId = findNextTarget(general.targetId, cfg)
                        if newTargetId ~= -1 then
                            general.targetId = newTargetId
                            attack_started = false 
                        else
                            resetTargetState()
                        end
                    else
                        
                        local ok, tHandle = sampGetCharHandleBySampPlayerId(general.targetId)
                        local tX, tY, tZ = safeGetCharCoords(tHandle)
                        local pX, pY, pZ = myCharCoords()
                        
                        if tX and pX then
                            local dist = getDistanceBetweenCoords3d(pX, pY, pZ, tX, tY, tZ)
                            if not isTargetInValidRange(dist, cfg) then
                                
                                local newTargetId = findNextTarget(general.targetId, cfg)
                                if newTargetId ~= -1 then
                                    general.targetId = newTargetId
                                    attack_started = false 
                                else
                                    resetTargetState()
                                end
                            end
                        else
                            resetTargetState()
                        end
                    end
                end

                
                if general.targetId ~= -1 and isValidTarget(general.targetId) then
                    local ok, tHandle = sampGetCharHandleBySampPlayerId(general.targetId)
                    local tX, tY, tZ = safeGetCharCoords(tHandle)
                    local pX, pY, pZ = myCharCoords()

                    if sound_timer - lastSoundTime >= 50 then
                        addOneOffSound(0, 0, 0, 1137)
                        lastSoundTime = sound_timer
                    end

                    if tX and pX then
                        local dist = getDistanceBetweenCoords3d(pX, pY, pZ, tX, tY, tZ)
                        if isTargetInValidRange(dist, cfg) then
                            local keyBase = string.format("tgt[%d]_%s_", general.targetId, (isCharInAnyCar(tHandle) and "incar" or "onfoot"))

                            general.speedX, general.lastSpeedIncreaseX = stepAxis("x", general.lastSpeedIncreaseX, general.speedX, cfg, now, keyBase)
                            general.speedY, general.lastSpeedIncreaseY = stepAxis("y", general.lastSpeedIncreaseY, general.speedY, cfg, now, keyBase)
                            general.speedZ, general.lastSpeedIncreaseZ = stepAxis("z", general.lastSpeedIncreaseZ, general.speedZ, cfg, now, keyBase)

                            local time_elapsed = now - oscillation_start_time
                            local horizontal_phase = time_elapsed * 2.0 * 2 * math.pi
                            
                            local offX = cfg.offset_x_plus.v + 1.0 * math.cos(horizontal_phase)
                            local offY = cfg.offset_y_plus.v + 1.0 * math.sin(horizontal_phase)
                            local offZ = cfg.offset_z_plus.v + 0.5 * math.sin(horizontal_phase)
                            
                            local send_key = general.targetId
                            local last_send = send_timers[send_key] or -math.huge  
                            local packets_per_second = cfg.packets_ps.v or 30 
                            local actual_packets_ps = math.max(1, math.min(100, packets_per_second))
                            local cd = 1.0 / actual_packets_ps
                            
                            if cd <= 0 or (now - last_send) >= cd then
                                if not attack_started then
                                    
                                    sendZeroSpeedSync(general.targetId)
                                    oscillation_start_time = now  
                                    attack_started = true
                                end

                                local data = samp_create_sync_data('vehicle')
                                if data then
                                    data.position   = { x = tX + offX, y = tY + offY, z = tZ + offZ }
                                    
                                    local targetSpeedX = calcSpeedForAxis(cfg, "x", general.speedX, keyBase.."dir_rand_x")
                                    local targetSpeedY = calcSpeedForAxis(cfg, "y", general.speedY, keyBase.."dir_rand_y") 
                                    local targetSpeedZ = calcSpeedForAxis(cfg, "z", general.speedZ, keyBase.."dir_rand_z")

                                    
                                    local finalSpeedX = math.max(last_vehicle_speed.x, targetSpeedX)
                                    local finalSpeedY = math.max(math.abs(last_vehicle_speed.y), math.abs(targetSpeedY)) * (targetSpeedY >= 0 and 1 or -1)
                                    local finalSpeedZ = math.max(last_vehicle_speed.z, targetSpeedZ)

                                    data.moveSpeed  = {
                                        x = finalSpeedX,
                                        y = finalSpeedY, 
                                        z = finalSpeedZ,                            
                                    }

                                    data.quaternion = calculateVehicleQuaternion()

                                    
                                    KordinateX, KordinateY, KordinateZ = data.position.x, data.position.y, data.position.z
                                    OffsetX, OffsetY, OffsetZ         = offX, offY, offZ
                                    BrzinaX, BrzinaY, BrzinaZ         = data.moveSpeed.x, data.moveSpeed.y, data.moveSpeed.z
                                    Quent1, Quent2, Quent3, Quent4    = data.quaternion[0], data.quaternion[1], data.quaternion[2], data.quaternion[3]

                                    local carHandle = storeCarCharIsInNoSave(PLAYER_PED)
                                    local ok, vehId = sampGetVehicleIdByCarHandle(carHandle)
                                    
                                    if ok then
                                        data.vehicleId = vehId
                                    else
                                        data.vehicleId = 0
                                    end
                                    
                                    data.leftRightKeys = 1
                                    data.upDownKeys = 1
                                    data.keysData = 8
                                    data.keys.accel_zoomOut = 1
                                    
                                    data.send()
                                    send_timers[send_key] = now
                                end
                            end
                        
                            
                            GUI_Zrtva = sampGetPlayerNickname(general.targetId) or "N/A"
                            GUI_Status = doesCharExist(tHandle) and (isCharInAnyCar(tHandle) and "INCAR" or "ONFOOT") or "N/A"
                        else
                            
                            resetTargetState()
                        end
                    else
                        
                        resetTargetState()
                    end
                end
            else
                
                if general.targetId ~= -1 then
                    sendZeroSpeedSync(general.targetId)
                end
                resetTargetState()
            end
        else
            
            if general.targetId ~= -1 then
                sendZeroSpeedSync(general.targetId)
            end
            resetTargetState()
        end
    end
end

function events.onSendVehicleSync(data)
    
    if data.moveSpeed then
        last_vehicle_speed.x = data.moveSpeed.x or last_vehicle_speed.x
        last_vehicle_speed.y = data.moveSpeed.y or last_vehicle_speed.y
        last_vehicle_speed.z = data.moveSpeed.z or last_vehicle_speed.z
    end
    
    if general.targetId ~= -1 then
        events._syncUnblocked = false
        events._unblockTimer = nil
        return false
    else
        if not events._syncUnblocked then
            if not events._unblockTimer then
                events._unblockTimer = os.clock()
                return false
            else
                if os.clock() - events._unblockTimer >= 2.0 then
                    events._syncUnblocked = true
                    events._unblockTimer = nil
                    return true
                else
                    return false
                end
            end
        else
            return true
        end
    end
end

function events.onReceiveRpc(id, bitStream)
    local cfg = getActiveConfig()
    if cfg and status_on_enabled.v and cfg.set_vehicle_pos and id == 159 then return false end
    if cfg and status_on_enabled.v and cfg.set_vehicle_velocity and id == 91 then return false end
    if cfg and status_on_enabled.v and cfg.set_vehicle_z_angle and id == 160 then return false end
    if cfg and status_on_enabled.v and cfg.remove_player_from_vehicle and id == 71 then return false end
    if cfg and status_on_enabled.v and cfg.set_vehicle_health and id == 147 then return false end
    if cfg and status_on_enabled.v and cfg.update_vehicle_damage_status and id == 106 then return false end
    if cfg and status_on_enabled.v and cfg.disable_vehicle_collisions and id == 167 then return false end
    if cfg and status_on_enabled.v and cfg.world_vehicle_remove and id == 165 then return false end
    if cfg and status_on_enabled.v and cfg.set_vehicle_params_ex and id == 24 then return false end
end

function samp_create_sync_data(sync_type, copy_from_player)
    local ffi = require 'ffi'
    local raknet = require 'samp.raknet'

    local function ensure_struct(name, def)
        local ok = pcall(function() ffi.sizeof('struct ' .. name) end)
        if not ok and def then
            pcall(ffi.cdef, def)
            print(string.format("[samp_create_sync_data] Registered missing struct: %s", name))
        end
    end

    ensure_struct("VehicleSyncData", [[
        typedef struct {
            float x;
            float y;
            float z;
        } VectorXYZ;
    
        typedef struct {
            uint16_t vehicleId;
            uint16_t leftRightKeys;
            uint16_t upDownKeys;
            union {
                uint16_t keysData;
                struct {
                    uint8_t fire : 1;
                    uint8_t altFire : 1;
                    uint8_t aim : 1;
                    uint8_t crouch : 1;
                    uint8_t sprint : 1;
                    uint8_t jump : 1;
                    uint8_t enterExitVehicle : 1;
                    uint8_t nextWeapon : 1;
                    uint8_t previousWeapon : 1;
                    uint8_t specialAction : 1;
                    uint8_t unused : 6;
                } keys;
            };
            float quaternion[4];
            VectorXYZ position;
            VectorXYZ moveSpeed;
            float vehicleHealth;
            uint8_t playerHealth;
            uint8_t armor;
            uint8_t currentWeapon : 6;
            uint8_t specialKey : 2;
            uint8_t siren;
            uint8_t landingGearState;
            uint16_t trailerId;
            union {
                float bikeLean;
                float trainSpeed;
                uint16_t hydraThrustAngle[2];
            };
        } VehicleSyncData;
    ]])
    
    local sync_traits = {
        player     = {'PlayerSyncData',    raknet.PACKET.PLAYER_SYNC,     sampStorePlayerOnfootData},
        vehicle    = {'VehicleSyncData',   raknet.PACKET.VEHICLE_SYNC,    sampStorePlayerIncarData},
        passenger  = {'PassengerSyncData', raknet.PACKET.PASSENGER_SYNC,  sampStorePlayerPassengerData},
        aim        = {'AimSyncData',       raknet.PACKET.AIM_SYNC,        sampStorePlayerAimData},
        trailer    = {'TrailerSyncData',   raknet.PACKET.TRAILER_SYNC,    sampStorePlayerTrailerData},
        unoccupied = {'UnoccupiedSyncData',raknet.PACKET.UNOCCUPIED_SYNC, nil},
        bullet     = {'BulletSyncData',    raknet.PACKET.BULLET_SYNC,     nil},
        spectator  = {'SpectatorSyncData', raknet.PACKET.SPECTATOR_SYNC,  nil}
    }

    local sync_info = sync_traits[sync_type]
    if not sync_info then
        print("[samp_create_sync_data] Greška: Nepoznat sync_type: " .. tostring(sync_type))
        return nil
    end

    local data_type = 'struct ' .. sync_info[1]
    local data
    local ok, err = pcall(function() data = ffi.new(data_type, {}) end)
    if not ok or not data then
        print(string.format("[samp_create_sync_data] Greska: '%s' nije registrovan (%s)", data_type, tostring(err)))
        return nil
    end

    local raw_data_ptr = tonumber(ffi.cast('uintptr_t', ffi.new(data_type .. '*', data)))

    if copy_from_player ~= false then
        local copy_func = sync_info[3]
        if copy_func then
            local _, player_id
            if copy_from_player == true or copy_from_player == nil then
                _, player_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
            else
                player_id = tonumber(copy_from_player)
            end

            if player_id then
                local ok_copy, err_copy = pcall(copy_func, player_id, raw_data_ptr)
                if not ok_copy then
                    print(string.format("[samp_create_sync_data] Upozorenje: Neuspijelo kopiranje sync podataka (%s)", tostring(err_copy)))
                end
            else
                print("[samp_create_sync_data] Upozorenje: player_id nije pronadjen.")
            end
        end
    end

    local func_send = function()
        local ok_send, err_send = pcall(function()
            local bs = raknetNewBitStream()
            raknetBitStreamWriteInt8(bs, sync_info[2])
            raknetBitStreamWriteBuffer(bs, raw_data_ptr, ffi.sizeof(data))
            raknetSendBitStreamEx(bs, sampfuncs.HIGH_PRIORITY, sampfuncs.UNRELIABLE_SEQUENCED, 1)
            raknetDeleteBitStream(bs)
        end)

        if not ok_send then
            print(string.format("[samp_create_sync_data] Greska pri slanju paketa: %s", tostring(err_send)))
        end
    end

    local mt = {
        __index = function(t, index) return data[index] end,
        __newindex = function(t, index, value)
            local ok_set, err_set = pcall(function() data[index] = value end)
            if not ok_set then
                print(string.format("[samp_create_sync_data] Greska pri postavljanju '%s': %s", tostring(index), tostring(err_set)))
            end
        end
    }

    return setmetatable({ send = func_send }, mt)
end


function join_rgba(r, g, b, a)
    local rgba = r 
    rgba = bit.bor(rgba, bit.lshift(g, 8)) 
    rgba = bit.bor(rgba, bit.lshift(b, 16)) 
    rgba = bit.bor(rgba, bit.lshift(a, 24)) 
    return rgba
end

mimgui.OnFrame(
    function()
        return not isPauseMenuActive() 
            and isCharInAnyCar(PLAYER_PED) 
            and general.targetId ~= -1
    end,
    function(line)
        line.HideCursor = true

        if not general or type(general.targetId) ~= "number" then return end
        if not sampIsPlayerConnected(general.targetId) then return end

        local ok, tHandle = sampGetCharHandleBySampPlayerId(general.targetId)
        if not ok or not doesCharExist(tHandle) then return end

        local tX, tY, tZ = getCharCoordinates(tHandle)
        local pX, pY, pZ = getCharCoordinates(PLAYER_PED)

        local px, py = convert3DCoordsToScreen(pX, pY, pZ)
        local result, sx, sy = convert3DCoordsToScreenEx(tX, tY, tZ, true, true)

        if not result or not isCharOnScreen(tHandle) then return end

        local draw = mimgui.GetBackgroundDrawList()
        local purpleAnim = AnimatedPinkPurpleShade_3D()
        local time = os.clock()

        local dist = math.sqrt((tX - pX)^2 + (tY - pY)^2 + (tZ - pZ)^2)
        local distText = string.format("%.1f m", dist)

        local pulse = (math.sin(time * 3) + 1) / 2
        local glowAlpha = math.floor(85 + 40 * pulse)

        local a_orig = bit.rshift(bit.band(purpleAnim, 0xFF000000), 24)
        local r_orig = bit.rshift(bit.band(purpleAnim, 0x00FF0000), 16)
        local g_orig = bit.rshift(bit.band(purpleAnim, 0x0000FF00), 8)
        local b_orig = bit.band(purpleAnim, 0x000000FF)

        
        local dynamicColor = bit.bor(bit.lshift(glowAlpha, 24), bit.lshift(r_orig, 16), bit.lshift(g_orig, 8), b_orig)

        
        local lineGlowAlpha = math.floor(80 + 40 * pulse)
        local lineCoreAlpha = math.floor(200 + 55 * pulse)
        local colorGlow = bit.bor(bit.band(dynamicColor, 0x00FFFFFF), bit.lshift(lineGlowAlpha, 24))
        local colorCore = bit.bor(bit.band(dynamicColor, 0x00FFFFFF), bit.lshift(lineCoreAlpha, 24))

        
        draw:AddLine(mimgui.ImVec2(px, py), mimgui.ImVec2(sx, sy), colorGlow, 8.0)
        
        draw:AddLine(mimgui.ImVec2(px, py), mimgui.ImVec2(sx, sy), colorCore, 3.0)

        
        local ringRadius = 20 + pulse * 8
        
        
        draw:AddCircle(mimgui.ImVec2(sx, sy), ringRadius + 8, colorGlow, 64, 4.0)
        draw:AddCircle(mimgui.ImVec2(sx, sy), ringRadius + 4, colorGlow, 64, 3.0)
        
        
        draw:AddCircle(mimgui.ImVec2(sx, sy), ringRadius, colorCore, 64, 2.5)

        
        local orbitTime = time * 2.5
        for i = 1, 3 do
            local orbitRadius = ringRadius + 12 + i * 3
            local segmentAngle = (orbitTime + i * 1.2) % (2 * math.pi)
            local segmentLength = math.pi / (2 + i * 0.5)
            
            
            draw:PathArcTo(mimgui.ImVec2(sx, sy), orbitRadius, segmentAngle, segmentAngle + segmentLength, 16)
            local orbitAlpha = math.floor(150 - i * 30)
            local orbitColor = bit.bor(bit.band(dynamicColor, 0x00FFFFFF), bit.lshift(orbitAlpha, 24))
            draw:PathStroke(orbitColor, false, 2.0 - i * 0.3)

            
            local whiteAlpha = math.floor(80 + 50 * pulse)
            local whiteColor = bit.bor(bit.lshift(whiteAlpha, 24), 0xFFFFFF)
            draw:PathArcTo(mimgui.ImVec2(sx, sy), orbitRadius, segmentAngle, segmentAngle + segmentLength, 16)
            draw:PathStroke(whiteColor, false, 1.2)
        end

        
        local corePulse = 4 + math.sin(time * 8) * 1.5
        local coreAlpha = math.floor(200 + 55 * pulse)
        local coreColor = bit.bor(bit.band(dynamicColor, 0x00FFFFFF), bit.lshift(coreAlpha, 24))

        
        draw:AddCircleFilled(mimgui.ImVec2(sx, sy), corePulse + 3, colorGlow, 32)
        
        draw:AddCircleFilled(mimgui.ImVec2(sx, sy), corePulse, coreColor, 32)

        
        local textY = sy - ringRadius - 35
        local textSize = mimgui.CalcTextSize(distText)
        local textPos = mimgui.ImVec2(sx - textSize.x / 2, textY)
        
        draw:AddText(mimgui.ImVec2(textPos.x - 1, textPos.y - 1), 0xFF000000, distText)
        draw:AddText(mimgui.ImVec2(textPos.x + 1, textPos.y - 1), 0xFF000000, distText)
        draw:AddText(mimgui.ImVec2(textPos.x - 1, textPos.y + 1), 0xFF000000, distText)
        draw:AddText(mimgui.ImVec2(textPos.x + 1, textPos.y + 1), 0xFF000000, distText)
        
        local textBgAlpha = math.floor(100 + 50 * pulse)
        local textBgColor = bit.bor(bit.band(colorGlow, 0x00FFFFFF), bit.lshift(textBgAlpha, 24))
        draw:AddRectFilled(
            mimgui.ImVec2(textPos.x - 5, textPos.y - 2),
            mimgui.ImVec2(textPos.x + textSize.x + 5, textPos.y + textSize.y + 2),
            textBgColor, 3.0
        )
        
        local textPulse = 0.8 + 0.2 * pulse
        local textBrightness = math.floor(255 * textPulse)
        local brightPurple = bit.bor(0xFF000000, bit.lshift(textBrightness, 16), bit.lshift(math.floor(textBrightness * 0.6), 8), textBrightness)
        draw:AddText(textPos, brightPurple, distText)

        
        local lineLength = math.sqrt((sx - px)^2 + (sy - py)^2)
        local dotCount = math.floor(lineLength / 25)
        
        for i = 1, dotCount do
            local t = i / (dotCount + 1)
            local dotX = px + (sx - px) * t
            local dotY = py + (sy - py) * t
            local dotSize = 2 + math.sin(time * 4 + i * 0.8) * 1.5
            local dotAlpha = math.floor(150 + 100 * math.sin(time * 3 + i))
            local dotColor = bit.bor(bit.band(dynamicColor, 0x00FFFFFF), bit.lshift(dotAlpha, 24))
            draw:AddCircleFilled(mimgui.ImVec2(dotX, dotY), dotSize, dotColor, 12)
        end
    end
)

mimgui.OnFrame(
    function()
        return not isPauseMenuActive()
            and isCharInAnyCar(PLAYER_PED)
            and general.targetId ~= -1
    end,
    function(line)
        line.HideCursor = true

        
        if not general or type(general.targetId) ~= "number" then return end
        if not sampIsPlayerConnected(general.targetId) then return end

        local ok, tHandle = sampGetCharHandleBySampPlayerId(general.targetId)
        if not ok or not doesCharExist(tHandle) then return end

        local tX, tY, tZ = getCharCoordinates(tHandle)
        local pX, pY, pZ = getCharCoordinates(PLAYER_PED)

        if isCharOnScreen(tHandle) then return end

        local draw = mimgui.GetBackgroundDrawList()
        local screenWidth, screenHeight = getScreenResolution()
        local centerX, centerY = screenWidth / 2, screenHeight / 2

        local arrowDistance = 150
        local arrowSize = 28
        local glowSize = 8

        local leftPos = mimgui.ImVec2(centerX - arrowDistance, centerY)
        local rightPos = mimgui.ImVec2(centerX + arrowDistance, centerY)
        local bottomPos = mimgui.ImVec2(centerX, centerY + arrowDistance)

        local purpleAnim = AnimatedPinkPurpleShade_3D()
        local time = os.clock()
        
        
        local pulse1 = (math.sin(time * 2.5) + 1) / 2
        local pulse2 = (math.sin(time * 3.2 + 1) + 1) / 2
        local pulse3 = (math.sin(time * 4.1 + 2) + 1) / 2

        
        local a_orig = bit.rshift(bit.band(purpleAnim, 0xFF000000), 24)
        local r_orig = bit.rshift(bit.band(purpleAnim, 0x00FF0000), 16)
        local g_orig = bit.rshift(bit.band(purpleAnim, 0x0000FF00), 8)
        local b_orig = bit.band(purpleAnim, 0x000000FF)

        
        local mainAlpha = math.floor(180 + 60 * pulse1)
        local colorMain = bit.bor(bit.lshift(mainAlpha, 24), bit.lshift(r_orig, 16), bit.lshift(g_orig, 8), b_orig)
        
        
        local innerAlpha = math.floor(120 + 80 * pulse2)
        local r_inner = math.min(255, r_orig + 40)
        local g_inner = math.min(255, g_orig + 20)
        local b_inner = math.min(255, b_orig + 30)
        local colorInner = bit.bor(bit.lshift(innerAlpha, 24), bit.lshift(r_inner, 16), bit.lshift(g_inner, 8), b_inner)

        
        local glowAlpha1 = math.floor(80 + 40 * pulse1)
        local glowAlpha2 = math.floor(50 + 30 * pulse2)
        local glowAlpha3 = math.floor(30 + 20 * pulse3)

        local colorGlow1 = bit.bor(bit.lshift(glowAlpha1, 24), bit.lshift(r_orig, 16), bit.lshift(g_orig, 8), b_orig)
        local colorGlow2 = bit.bor(bit.lshift(glowAlpha2, 24), bit.lshift(r_orig, 16), bit.lshift(g_orig, 8), b_orig)
        local colorGlow3 = bit.bor(bit.lshift(glowAlpha3, 24), bit.lshift(r_orig, 16), bit.lshift(g_orig, 8), b_orig)

        local result, screenX, screenY = convert3DCoordsToScreenEx(tX, tY, tZ, true, true)
        local angle
        if result then
            angle = math.atan2(screenY - centerY, screenX - centerX)
        else
            angle = math.atan2(tY - pY, tX - pX)
            local vehicle = safeStoreCarCharIsInNoSave(PLAYER_PED)
            if vehicle and doesVehicleExist(vehicle) then
                local carHeading = getCarHeading(vehicle)
                angle = angle - math.rad(carHeading)
            end
        end

        local degrees = (math.deg(angle) + 360) % 360
        local showLeft, showRight, showBottom = false, false, false

        if degrees >= 45 and degrees < 135 then
            showBottom = true
        elseif degrees >= 135 and degrees < 225 then
            showLeft = true
        elseif degrees >= 225 and degrees < 315 then
            showBottom = true 
        else
            showRight = true
        end

        local function drawArrow(pos, direction)
            local points = {}
            if direction == "left" then
                points = {
                    mimgui.ImVec2(pos.x, pos.y),
                    mimgui.ImVec2(pos.x + arrowSize, pos.y - arrowSize * 0.8),
                    mimgui.ImVec2(pos.x + arrowSize, pos.y + arrowSize * 0.8)
                }
            elseif direction == "right" then
                points = {
                    mimgui.ImVec2(pos.x, pos.y),
                    mimgui.ImVec2(pos.x - arrowSize, pos.y - arrowSize * 0.8),
                    mimgui.ImVec2(pos.x - arrowSize, pos.y + arrowSize * 0.8)
                }
            elseif direction == "bottom" then
                points = {
                    mimgui.ImVec2(pos.x, pos.y),
                    mimgui.ImVec2(pos.x - arrowSize * 0.8, pos.y - arrowSize),
                    mimgui.ImVec2(pos.x + arrowSize * 0.8, pos.y - arrowSize)
                }
            end

            
            for i = 1, 3 do
                local offset = glowSize * (i / 3)
                local alpha = i == 1 and glowAlpha1 or (i == 2 and glowAlpha2 or glowAlpha3)
                local glowColor = bit.bor(bit.lshift(alpha, 24), bit.lshift(r_orig, 16), bit.lshift(g_orig, 8), b_orig)
                
                if direction == "left" then
                    draw:AddTriangle(
                        mimgui.ImVec2(points[1].x - offset, points[1].y),
                        mimgui.ImVec2(points[2].x - offset, points[2].y),
                        mimgui.ImVec2(points[3].x - offset, points[3].y),
                        glowColor, 3.0
                    )
                elseif direction == "right" then
                    draw:AddTriangle(
                        mimgui.ImVec2(points[1].x + offset, points[1].y),
                        mimgui.ImVec2(points[2].x + offset, points[2].y),
                        mimgui.ImVec2(points[3].x + offset, points[3].y),
                        glowColor, 3.0
                    )
                elseif direction == "bottom" then
                    draw:AddTriangle(
                        mimgui.ImVec2(points[1].x, points[1].y + offset),
                        mimgui.ImVec2(points[2].x, points[2].y + offset),
                        mimgui.ImVec2(points[3].x, points[3].y + offset),
                        glowColor, 3.0
                    )
                end
            end

            
            draw:AddTriangleFilled(points[1], points[2], points[3], colorMain)
            
            
            local midPoint = mimgui.ImVec2(
                (points[1].x + points[2].x + points[3].x) / 3,
                (points[1].y + points[2].y + points[3].y) / 3
            )
            
            local innerPoints1 = {
                midPoint,
                mimgui.ImVec2((points[1].x + points[2].x) / 2, (points[1].y + points[2].y) / 2),
                mimgui.ImVec2((points[1].x + points[3].x) / 2, (points[1].y + points[3].y) / 2)
            }
            draw:AddTriangleFilled(innerPoints1[1], innerPoints1[2], innerPoints1[3], colorInner)
            
            local innerPoints2 = {
                midPoint,
                mimgui.ImVec2((points[2].x + points[3].x) / 2, (points[2].y + points[3].y) / 2),
                mimgui.ImVec2((points[1].x + points[2].x) / 2, (points[1].y + points[2].y) / 2)
            }
            draw:AddTriangleFilled(innerPoints2[1], innerPoints2[2], innerPoints2[3], colorInner)
            
            local innerPoints3 = {
                midPoint,
                mimgui.ImVec2((points[1].x + points[3].x) / 2, (points[1].y + points[3].y) / 2),
                mimgui.ImVec2((points[2].x + points[3].x) / 2, (points[2].y + points[3].y) / 2)
            }
            draw:AddTriangleFilled(innerPoints3[1], innerPoints3[2], innerPoints3[3], colorInner)
        end

        if showLeft then
            drawArrow(leftPos, "left")
        elseif showRight then
            drawArrow(rightPos, "right")
        elseif showBottom then
            drawArrow(bottomPos, "bottom")
        end
    end
)


gui_mode = 1

configfiles_list = {}
selected_index = imgui.ImInt(1)
new_item_text = imgui.ImBuffer(64)

feedback_message = ""
feedback_color = imgui.ImVec4(1, 1, 1, 1)
feedback_timer = 0

status_on_enabled = imgui.ImBool(false)
status_off_enabled = imgui.ImBool(true)

config_type_onfoot = imgui.ImBool(true)
config_type_incar = imgui.ImBool(false)

configDir = getWorkingDirectory() .. "\\BIGBANG_OVERTAKER"
mainConfigFile = configDir .. "\\main.json"

function xorCrypt(str, key)
    local res = {}
    for i = 1, #str do
        local c = str:byte(i)
        local k = key:byte((i - 1) % #key + 1)
        res[i] = string.char(bit.bxor(c, k)) 
    end
    return table.concat(res)
end

local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
function base64enc(data)
    return ((data:gsub('.', function(x) 
        local r,bits='',x:byte()
        for i=8,1,-1 do r=r..(bits%2^i-bits%2^(i-1)>0 and '1' or '0') end
        return r
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

function base64dec(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end
local configKey = "BIGBANGOVERTAKER-hakenajjaciljudinaznaciBoze" 

function encryptJson(tbl)
    local jsonData = json.encode(tbl)
    return base64enc(xorCrypt(jsonData, configKey))
end

function decryptJson(data)
    local ok, tbl = pcall(json.decode, xorCrypt(base64dec(data), configKey))
    if ok then
        return tbl
    else
        return nil
    end
end

if not doesDirectoryExist(configDir) then
    createDirectory(configDir)
end

function isValidConfigName(str)
    if str:match("^[%w%s]*$") then
        return str:match("%w") ~= nil
    end
    return false
end

function getActiveConfig()
    if config_type_onfoot.v then
        return configs.onfoot
    elseif config_type_incar.v then
        return configs.incar
    end
    return configs.onfoot 
end

function getActiveConfigType()
    if config_type_onfoot.v then
        return "onfoot"
    elseif config_type_incar.v then
        return "incar"
    end
    return "onfoot" 
end

function saveSettings()
    local configName = configfiles_list[selected_index.v]
    if configName == "default" then return end

    local filePath = string.format("%s\\%s.json", configDir, configName)
    local file = io.open(filePath, "w")
    if file then
        local configData = {}
        for typeName, cfg in pairs(configs) do
            configData[typeName] = {}
            for key, val in pairs(cfg) do
                if type(val) == "userdata" and val.v ~= nil then
                    configData[typeName][key] = val.v
                else
                    configData[typeName][key] = val
                end
            end
        end
        file:write(encryptJson(configData))
        file:close()
    end
end

function saveMainConfig()
    local data = {}

    for key, val in pairs(mainConfigDefaults) do
        data[key] = val.v
    end

    local file = io.open(mainConfigFile, "w")
    if file then
        file:write(encryptJson(data))
        file:close()
    end
end

function loadMainConfig()
    local file = io.open(mainConfigFile, "r")
    if file then
        local content = file:read("*a")
        file:close()

        local data = decryptJson(content)
        if data then
            for key, val in pairs(mainConfigDefaults) do
                if data[key] ~= nil then
                    val.v = data[key]
                else
                    val.v = mainConfigDefaults[key].v
                end
            end
            return
        end
    end

    saveMainConfig()
end


function loadConfig(name)
    local filePath = string.format("%s\\%s.json", configDir, name)
    local file = io.open(filePath, "r")
    if not file then
        print("Config fajl nije pronadjen: " .. tostring(filePath))
        return
    end

    local content = file:read("*a")
    file:close()

    if content == "" or content == nil then
        print("Config fajl je prazan: " .. tostring(name))
        return
    end

    local data = decryptJson(content)
    if not data then
        print("Ne mogu dekriptovati config: " .. tostring(name))
        return
    end

    
    if type(data) ~= "table" then
        print("Invalidni podaci configa: " .. tostring(name))
        return
    end

    
    for typeName, cfg in pairs(data) do
        if configs[typeName] then
            for key, val in pairs(cfg) do
                if configs[typeName][key] then
                    
                    if type(configs[typeName][key]) == "userdata" then
                        configs[typeName][key].v = val
                    else
                        configs[typeName][key] = val
                    end
                end
            end
        end
    end
end


function loadAllConfigs()
    configfiles_list = { "default" }
    for file in lfs.dir(configDir) do
        if file:match("%.json$") and file:lower() ~= "main.json" then
            local name = file:gsub("%.json$", "")
            
            if name and name ~= "nil" and name ~= "" and isValidConfigName(name) then 
                table.insert(configfiles_list, name) 
            end
        end
    end
    
    
    if selected_index.v > #configfiles_list then
        selected_index.v = 1
    end
    
    loadMainConfig()
    local activeName = configfiles_list[selected_index.v]
    if activeName and activeName ~= "default" then
        loadConfig(activeName)
    else
        resetToDefault()
    end
end

function ConfigListBox(label, size)
    if imgui.ListBoxHeader(label, size) then
        for i, item in ipairs(configfiles_list) do
            
            if item and item ~= "nil" then
                local is_selected = (selected_index.v == i)

                if is_selected then
                    imgui.PushStyleColor(imgui.Col.Header, AnimatedPinkPurpleShade())
                    imgui.PushStyleColor(imgui.Col.HeaderHovered, AnimatedPinkPurpleShade())
                    imgui.PushStyleColor(imgui.Col.HeaderActive, AnimatedPinkPurpleShade())
                end

                if imgui.Selectable(item, is_selected) then
                    selected_index.v = i
                    if item ~= "default" then
                        loadConfig(item)
                    else
                        resetToDefault()
                    end
                end
                
                if is_selected then
                    imgui.PopStyleColor(3)
                end
            end
        end
        imgui.ListBoxFooter()
    end
end

function makeFreshDefaults()
    local raw_defaults = {
        onfoot = {
            throw_speed_x = imgui.ImFloat(0.0),
            boost_interval_x = imgui.ImFloat(0.0),
            direction_x = imgui.ImInt(1),
            throw_speed_x_random_min = imgui.ImFloat(0.0),
            throw_speed_x_random_max = imgui.ImFloat(0.0),
            throw_speed_x_random_enabled = imgui.ImBool(false),
    
            throw_speed_y = imgui.ImFloat(0.3),
            boost_interval_y = imgui.ImFloat(1.5),
            direction_y = imgui.ImInt(1),
            throw_speed_y_random_min = imgui.ImFloat(0.0),
            throw_speed_y_random_max = imgui.ImFloat(0.0),
            throw_speed_y_random_enabled = imgui.ImBool(false),
    
            throw_speed_z = imgui.ImFloat(0.5),
            boost_interval_z = imgui.ImFloat(2.0),
            direction_z = imgui.ImInt(1),
            throw_speed_z_random_min = imgui.ImFloat(0.0),
            throw_speed_z_random_max = imgui.ImFloat(0.0),
            throw_speed_z_random_enabled = imgui.ImBool(false),
    
            offset_x_plus = imgui.ImFloat(0.0),
    
            offset_y_plus = imgui.ImFloat(0.0),

    
            offset_z_plus = imgui.ImFloat(0.0),

    
            vehicle_pitch = imgui.ImFloat(0.0),
            vehicle_roll = imgui.ImFloat(-90.0),
            vehicle_yaw = imgui.ImFloat(0.0),
    
            
    
            packets_ps = imgui.ImFloat(50.0),
            min_range = imgui.ImFloat(0.0),
            max_range = imgui.ImFloat(40.0),
    
            victim_selector = imgui.ImInt(0),
    
            update_vehicle_damage_status = imgui.ImBool(true),
            set_vehicle_params_ex = imgui.ImBool(true),
            world_vehicle_remove = imgui.ImBool(true),
            set_vehicle_z_angle = imgui.ImBool(true),
            set_vehicle_pos = imgui.ImBool(true),
            set_vehicle_velocity = imgui.ImBool(true),
            set_vehicle_health = imgui.ImBool(true),
            remove_player_from_vehicle = imgui.ImBool(true),
            disable_vehicle_collisions = imgui.ImBool(true),
        },
    
        incar = {
            throw_speed_x = imgui.ImFloat(0.0),
            boost_interval_x = imgui.ImFloat(0.0),
            direction_x = imgui.ImInt(1),
            throw_speed_x_random_min = imgui.ImFloat(0.0),
            throw_speed_x_random_max = imgui.ImFloat(0.0),
            throw_speed_x_random_enabled = imgui.ImBool(false),
    
            throw_speed_y = imgui.ImFloat(0.3),
            boost_interval_y = imgui.ImFloat(1.5),
            direction_y = imgui.ImInt(1),
            throw_speed_y_random_min = imgui.ImFloat(0.0),
            throw_speed_y_random_max = imgui.ImFloat(0.0),
            throw_speed_y_random_enabled = imgui.ImBool(false),
    
            throw_speed_z = imgui.ImFloat(0.5),
            boost_interval_z = imgui.ImFloat(2.0),
            direction_z = imgui.ImInt(1),
            throw_speed_z_random_min = imgui.ImFloat(0.0),
            throw_speed_z_random_max = imgui.ImFloat(0.0),
            throw_speed_z_random_enabled = imgui.ImBool(false),
    
            offset_x_plus = imgui.ImFloat(0.0),

    
            offset_y_plus = imgui.ImFloat(0.0),

    
            offset_z_plus = imgui.ImFloat(0.0),

    
            vehicle_pitch = imgui.ImFloat(0.0),
            vehicle_roll = imgui.ImFloat(-90.0),
            vehicle_yaw = imgui.ImFloat(0.0),
    
            
    
            packets_ps = imgui.ImFloat(50.0),
            min_range = imgui.ImFloat(0.0),
            max_range = imgui.ImFloat(40.0),
    
            victim_selector = imgui.ImInt(0),
    
            update_vehicle_damage_status = imgui.ImBool(true),
            set_vehicle_params_ex = imgui.ImBool(true),
            world_vehicle_remove = imgui.ImBool(true),
            set_vehicle_z_angle = imgui.ImBool(true),
            set_vehicle_pos = imgui.ImBool(true),
            set_vehicle_velocity = imgui.ImBool(true),
            set_vehicle_health = imgui.ImBool(true),
            remove_player_from_vehicle = imgui.ImBool(true),
            disable_vehicle_collisions = imgui.ImBool(true),
        }
    }

    local fresh = {}
    for typeName, cfg in pairs(raw_defaults) do
        fresh[typeName] = {}
        for key, val in pairs(cfg) do
            if type(val) == "boolean" then
                fresh[typeName][key] = imgui.ImBool(val)
            elseif type(val) == "number" then
                if math.type and math.type(val) == "integer" then
                    fresh[typeName][key] = imgui.ImInt(val)
                else
                    fresh[typeName][key] = imgui.ImFloat(val)
                end
            else
                fresh[typeName][key] = val
            end
        end
    end
    return fresh
end

function cleanupInvalidConfigs()
    for file in lfs.dir(configDir) do
        if file:match("%.json$") and file:lower() ~= "main.json" then
            local name = file:gsub("%.json$", "")
            local filePath = configDir .. "\\" .. file
            
            
            local f = io.open(filePath, "r")
            if f then
                local content = f:read("*a")
                f:close()
                
                if content == "" or content == nil or name == "nil" or name == "" then
                    os.remove(filePath)
                    print("Obrisan invalidan config: " .. filePath)
                end
            end
        end
    end
end

function resetToDefault()
    configs = makeFreshDefaults()
end

function createConfig()
    local text = tostring(new_item_text.v or ""):gsub("^%s*(.-)%s*$", "%1")

    if text == "" then
        feedback_message = "Morate unijeti ime configa."
        feedback_color = imgui.ImVec4(0.95, 0.25, 0.25, 1.0)
        feedback_timer = os.clock()
        return
    end

    if text == "" or text == "nil" or text == "null" then
        feedback_message = "Nevalidno ime configa."
        feedback_color = imgui.ImVec4(0.95, 0.25, 0.25, 1.0)
        feedback_timer = os.clock()
        return
    end

    if not text or type(text) ~= "string" then
        feedback_message = "Nevalidan tip imena."
        feedback_color = imgui.ImVec4(0.95, 0.25, 0.25, 1.0)
        feedback_timer = os.clock()
        return
    end

    if text:lower() == "main" then
        feedback_message = "Ne mozete koristiti ime 'main' za config."
        feedback_color = imgui.ImVec4(0.95, 0.25, 0.25, 1.0)
        feedback_timer = os.clock()
        return
    end

    if not isValidConfigName(text) then
        feedback_message = "Ime configa moze sadrzati samo slova i brojeve."
        feedback_color = imgui.ImVec4(0.95, 0.25, 0.25, 1.0)
        feedback_timer = os.clock()
        return
    end

    for _, v in ipairs(configfiles_list) do
        if v:lower() == text:lower() then
            feedback_message = "Config pod ovim imenom vec postoji."
            feedback_color = imgui.ImVec4(0.95, 0.25, 0.25, 1.0)
            feedback_timer = os.clock()
            return
        end
    end

    resetToDefault()

    
    table.insert(configfiles_list, text)
    selected_index.v = #configfiles_list

    
    local filePath = string.format("%s\\%s.json", configDir, text)
    local file = io.open(filePath, "w")
    if file then
        local configData = {}
        for typeName, cfg in pairs(configs) do
            configData[typeName] = {}
            for key, val in pairs(cfg) do
                if type(val) == "userdata" and val.v ~= nil then
                    configData[typeName][key] = val.v
                else
                    configData[typeName][key] = val
                end
            end
        end
        file:write(encryptJson(configData))
        file:close()
    end

    feedback_message = "Uspijesno ste kreirali novi config."
    feedback_color = imgui.ImVec4(0.4, 1.0, 0.6, 1.0)
    feedback_timer = os.clock()
    new_item_text.v = ""
end

function deleteConfig()
    if selected_index.v > 0 and selected_index.v <= #configfiles_list then
        if selected_index.v <= 1 then
            feedback_message = "Ne mozete obrisati default config."
            feedback_color = imgui.ImVec4(0.95, 0.25, 0.25, 1.0)
            feedback_timer = os.clock()
            return
        end
        
        local configName = configfiles_list[selected_index.v]
        local filePath = string.format("%s\\%s.json", configDir, configName)
        
        
        os.remove(filePath)
        
        
        local oldIndex = selected_index.v
        
        
        table.remove(configfiles_list, oldIndex)
        
        
        if oldIndex > #configfiles_list then
            selected_index.v = #configfiles_list
        end
        
        
        if #configfiles_list == 1 then  
            selected_index.v = 1
            resetToDefault()
        else
            
            local activeName = configfiles_list[selected_index.v]
            if activeName and activeName ~= "default" then
                loadConfig(activeName)
            else
                resetToDefault()
            end
        end
        
        feedback_message = "Uspijesno ste obrisali config: " .. configName
        feedback_color = imgui.ImVec4(0.95, 0.25, 0.25, 1.0)
        feedback_timer = os.clock()
    end
end

function setVariablesForActiveConfig()
    local activeConfigName = configfiles_list[selected_index.v]
    local activeConfig = getActiveConfig()
    local activeType = getActiveConfigType() 

    if activeConfigName and activeConfig then
        
        for key, val in pairs(activeConfig) do
            local t = type(val)
            if t == "userdata" then
                local ts = tostring(val)
                if ts:find("ImBool") or ts:find("ImFloat") or ts:find("ImInt") then
                    
                    configs[activeType][key].v = val.v
                end
            else
                
                configs[activeType][key] = val
            end
        end
    end
end

local pinkpurple_timer = os.clock()
function AnimatedPinkPurpleShade()
    local function hexToRgb(hex)
        hex = hex:gsub("#","")
        return tonumber("0x"..hex:sub(1,2))/255,
               tonumber("0x"..hex:sub(3,4))/255,
               tonumber("0x"..hex:sub(5,6))/255
    end

    local elapsed = os.clock() - pinkpurple_timer
    local period = 0.3
    local t = (elapsed % (2 * period))
    if t > period then
        t = 2 * period - t
    end
    local normalized = t / period

    local start_r, start_g, start_b = hexToRgb("#bc47ff")
    local end_r, end_g, end_b = hexToRgb("#ac70ff")

    local a = 1.0
    local r = start_r + (end_r - start_r) * normalized
    local g = start_g + (end_g - start_g) * normalized
    local b = start_b + (end_b - start_b) * normalized

    return imgui.ImVec4(r, g, b, a)
end

function AnimatedPinkPurpleShade_3D()
    local function hexToRgb(hex)
        hex = hex:gsub("#","")
        return tonumber("0x"..hex:sub(1,2))/255,
               tonumber("0x"..hex:sub(3,4))/255,
               tonumber("0x"..hex:sub(5,6))/255
    end

    local elapsed = os.clock() - pinkpurple_timer
    local period = 0.6  
    local t = (elapsed % (2 * period))
    if t > period then
        t = 2 * period - t
    end
    local normalized = t / period

    local start_r, start_g, start_b = hexToRgb("#9419ff") 
    local end_r, end_g, end_b = hexToRgb("#bf75ff")       

    local a = 1.0
    local r = start_r + (end_r - start_r) * normalized
    local g = start_g + (end_g - start_g) * normalized
    local b = start_b + (end_b - start_b) * normalized

    
    return imgui.ColorConvertFloat4ToU32(imgui.ImVec4(r, g, b, a))
end

function imgui.OnDrawFrame()
    
    local screenW, screenH = getScreenResolution()

    local responsiveHeightConfig = {
        main = {
            no_buttons = 485,  
            with_buttons = 565
        },
        brzina = {
            none   = 500, 
            x_on   = 525, 
            y_on   = 525, 
            z_on   = 525, 
            xy_on  = 550, 
            xz_on  = 550, 
            yz_on  = 550, 
            xyz_on = 570  
        },
        offseti = {
            none   = 520,  
            x_on   = 540,  
            y_on   = 540,  
            z_on   = 540,  
            xy_on  = 565,  
            xz_on  = 565,  
            yz_on  = 565,  
            xyz_on = 590   
        },
        ostalo = 520
    }

    local function getWindowHeight()
        local cfg = getActiveConfig()

        if gui_mode == 1 then
            local hasVictimButtons = (selected_index.v > 1)
            return hasVictimButtons and responsiveHeightConfig.main.with_buttons or responsiveHeightConfig.main.no_buttons
        
        elseif gui_mode == 2 then
            if selected_index.v <= 1 then
                
                local hasVictimButtons = (selected_index.v > 1)
                return hasVictimButtons and responsiveHeightConfig.main.with_buttons or responsiveHeightConfig.main.no_buttons
            end
    
            local x = cfg.throw_speed_x_random_enabled.v
            local y = cfg.throw_speed_y_random_enabled.v
            local z = cfg.throw_speed_z_random_enabled.v
    
            if not x and not y and not z then return responsiveHeightConfig.brzina.none
            elseif  x and not y and not z then return responsiveHeightConfig.brzina.x_on
            elseif not x and  y and not z then return responsiveHeightConfig.brzina.y_on
            elseif not x and not y and  z then return responsiveHeightConfig.brzina.z_on
            elseif  x and  y and not z then return responsiveHeightConfig.brzina.xy_on
            elseif  x and not y and  z then return responsiveHeightConfig.brzina.xz_on
            elseif not x and  y and  z then return responsiveHeightConfig.brzina.yz_on
            elseif  x and  y and  z then return responsiveHeightConfig.brzina.xyz_on
            end
    
        elseif gui_mode == 3 then
            
            return 530 
        
    
        elseif gui_mode == 4 then
            if selected_index.v <= 1 then
                
                local hasVictimButtons = (selected_index.v > 1)
                return hasVictimButtons and responsiveHeightConfig.main.with_buttons or responsiveHeightConfig.main.no_buttons
            end
    
            return responsiveHeightConfig.ostalo
        end
    
        return 550
    end
    
    
    local function OffsetControl(label, value)
        imgui.InputFloat(label, value, 0, 0, "%.2f")
    end
    
    local function OffsetRandomControl(label, min_value, max_value)
        imgui.InputFloat(label .. " Min", min_value, 0, 0, "%.2f")
        imgui.InputFloat(label .. " Max", max_value, 0, 0, "%.2f")
    end
    
    local function ThrowSpeedControl(label, value)
        imgui.InputFloat(label, value, 0, 0, "%.2f")
    end
    
    local function ThrowSpeedRandomControl(label, min_value, max_value)
        imgui.InputFloat(label .. " Min", min_value, 0, 0, "%.2f")
        imgui.InputFloat(label .. " Max", max_value, 0, 0, "%.2f")
    end


    if output_GUI.v then

        local screenWidth, screenHeight = getScreenResolution()
        local windowWidth, windowHeight = 320, 185
        local posxOutputBar = (screenWidth - windowWidth) / 2
        local bottomOffset = 40
        local posyOutputBar = screenHeight - windowHeight - bottomOffset
    
        imgui.SetNextWindowPos(imgui.ImVec2(posxOutputBar, posyOutputBar), imgui.Cond.Always)
        imgui.SetNextWindowSize(imgui.ImVec2(windowWidth, windowHeight), imgui.Cond.Always)
    
    
        imgui.Begin("BIGBANG OVERTAKER OUTPUT", output_GUI, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)
    
        
        local titleText = "BIGBANG OVERTAKER OUTPUT"
        imgui.SetWindowFontScale(1.2)
        local titleSize = imgui.CalcTextSize(titleText)
        imgui.SetCursorPosX((windowWidth - titleSize.x) / 2)
        imgui.TextColored(AnimatedPinkPurpleShade(), titleText)
        imgui.SetWindowFontScale(1.0)
        
    
        imgui.Separator()
        imgui.Dummy(imgui.ImVec2(0, 3))
    
        
        local function DrawStatusLine(label, value, color)
            imgui.Text(label)
            local textSize = imgui.CalcTextSize(tostring(value))
            imgui.SameLine(windowWidth - textSize.x - 8)
            imgui.TextColored(color or imgui.ImVec4(0.8, 0.8, 0.85, 1.0), tostring(value))
        end
    
        DrawStatusLine("Zrtva:", GUI_Zrtva or "N/A", imgui.ImVec4(0.85, 0.3, 0.3, 1.0))
        DrawStatusLine("Status:", GUI_Status or "N/A", AnimatedPinkPurpleShade())
        imgui.Dummy(imgui.ImVec2(0, 3))
        
        DrawStatusLine("Kordinate:", string.format("%.2f, %.2f, %.2f", KordinateX or 0, KordinateY or 0, KordinateZ or 0))
        DrawStatusLine("Offseti:", string.format("%.2f, %.2f, %.2f", OffsetX or 0, OffsetY or 0, OffsetZ or 0))
        DrawStatusLine("Brzina:", string.format("%.2f, %.2f, %.2f", BrzinaX or 0, BrzinaY or 0, BrzinaZ or 0))
        DrawStatusLine("Orijentacija:", string.format("%s, %s, %s, %s",
        Quent1 ~= nil and string.format("%.2f", Quent1) or "N/A",
        Quent2 ~= nil and string.format("%.2f", Quent2) or "N/A",
        Quent3 ~= nil and string.format("%.2f", Quent3) or "N/A",
        Quent4 ~= nil and string.format("%.2f", Quent4) or "N/A"
        
    ))

        imgui.End()
    end
    
    if main_GUI.v then

        local windowWidth = 530
        local windowHeight = getWindowHeight()
    
        imgui.SetNextWindowPos(imgui.ImVec2((screenW - windowWidth) / 2, (screenH - windowHeight) / 2))
        imgui.SetNextWindowSize(imgui.ImVec2(windowWidth, windowHeight))

        imgui.Begin("BIGBANG OVERTAKER", main_GUI, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)

        imgui.SetWindowFontScale(1.4)
        local title = "BIGBANG OVERTAKER"
        local title_size = imgui.CalcTextSize(title)
        imgui.SetCursorPosX((windowWidth - title_size.x) / 2)
        imgui.PushStyleColor(imgui.Col.Text, AnimatedPinkPurpleShade())
        imgui.Text(title)
        imgui.PopStyleColor()
        imgui.SetWindowFontScale(1.0)

        local btn_w, btn_h = 90, 26
        local modes = { "Main","Brzina", "Offseti", "Ostalo", "FAQ" }

        local total_width = (#modes * btn_w) + ((#modes - 1) * 5)  
        
        imgui.SetCursorPosX((windowWidth - total_width) / 2)
        
        for i, name in ipairs(modes) do
            if i > 1 then imgui.SameLine(nil, 5) end 
            imgui.PushStyleColor(imgui.Col.Button, (gui_mode == i) and AnimatedPinkPurpleShade() or imgui.ImVec4(0.4, 0.4, 0.4, 1))
            if imgui.Button(name, imgui.ImVec2(btn_w, btn_h)) then gui_mode = i end
            imgui.PopStyleColor()
        end
        
        imgui.Separator()

        
        if gui_mode == 1 then
            imgui.NewLine()
            imgui.Text("Konfiguracije:")
        

            ConfigListBox("##listbox", imgui.ImVec2(515, 150))


            imgui.Separator()
        
            imgui.InputText("##NewItem", new_item_text)
            imgui.SameLine()

            if imgui.Button("NAPRAVI", imgui.ImVec2(78, 20)) then
                createConfig()
            end

            imgui.SameLine()

            if imgui.Button("IZBRISI", imgui.ImVec2(78, 20)) then
                deleteConfig()
            end

            if feedback_message ~= "" then
                if os.clock() - feedback_timer <= 1.5 then
                    imgui.PushStyleColor(imgui.Col.Text, feedback_color)
    
                    local feedbackmsg_width = imgui.CalcTextSize(feedback_message).x
                    imgui.SetCursorPosX((windowWidth - feedbackmsg_width) / 2)
                    imgui.Text(feedback_message)

                    imgui.PopStyleColor()
                else
                    feedback_message = ""
                end
            end


            if selected_index.v > 1 then
                imgui.NewLine()
                local text2 = "Svaka promjena postavki primijenit ce se na zrtve sa statusom:"
                local text2_width = imgui.CalcTextSize(text2).x
                imgui.SetCursorPosX((windowWidth - text2_width) / 2)
                imgui.Text(text2)
                
        
                local victim_btn_w, victim_btn_h = 90, 26
                local victim_total_width = (victim_btn_w * 2) + (10 * 2)
                imgui.SetCursorPosX((windowWidth - victim_total_width) / 2)

                if config_type_onfoot.v then
                    imgui.PushStyleColor(imgui.Col.Button, AnimatedPinkPurpleShade())
                else
                    imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.Button])
                end
                if imgui.Button("ONFOOT", imgui.ImVec2(victim_btn_w, victim_btn_h)) then
                    config_type_onfoot.v = true
                    config_type_incar.v = false
                end
                imgui.PopStyleColor()
        
                imgui.SameLine()
        
                
                if config_type_incar.v then
                    imgui.PushStyleColor(imgui.Col.Button, AnimatedPinkPurpleShade())
                else
                    imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.Button])
                end
                if imgui.Button("INCAR", imgui.ImVec2(victim_btn_w, victim_btn_h)) then
                    config_type_onfoot.v = false
                    config_type_incar.v = true
                end
                imgui.PopStyleColor()
        
            end

        
            
            imgui.NewLine()
            imgui.NewLine()
            local text = "Tipka za aktivaciju:"
            local text_width = imgui.CalcTextSize(text).x
            imgui.SetCursorPosX((windowWidth - text_width) / 2)
            imgui.Text(text)
            
        
            local attack_btn_w, attack_btn_h = 70, 26
            local attack_total_width = (attack_btn_w * 2) + 10
            imgui.SetCursorPosX((windowWidth - attack_total_width) / 2)
        
            
            if mainConfigDefaults.attack_lmb_enabled.v then
                imgui.PushStyleColor(imgui.Col.Button, AnimatedPinkPurpleShade())
            else
                imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.Button])
            end
            if imgui.Button("LMB", imgui.ImVec2(attack_btn_w, attack_btn_h)) then
                mainConfigDefaults.attack_r_enabled.v = false
                mainConfigDefaults.attack_lmb_enabled.v = true
            end
            imgui.PopStyleColor()
        
            imgui.SameLine()
        
            
            if mainConfigDefaults.attack_r_enabled.v then
                imgui.PushStyleColor(imgui.Col.Button, AnimatedPinkPurpleShade())
            else
                imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.Button])
            end
            if imgui.Button("R", imgui.ImVec2(attack_btn_w, attack_btn_h)) then
                mainConfigDefaults.attack_r_enabled.v = true
                mainConfigDefaults.attack_lmb_enabled.v = false
            end
            imgui.PopStyleColor()
        
            
            imgui.NewLine()
            imgui.NewLine()
            local text3 = "Kontrola skripte:"
            local text3_width = imgui.CalcTextSize(text3).x
            imgui.SetCursorPosX((windowWidth - text3_width) / 2)
            imgui.Text(text3)
            
        
            local status_btn_w, status_btn_h = 70, 26
            local status_total_width = (status_btn_w * 2) + 10
            imgui.SetCursorPosX((windowWidth - status_total_width) / 2)
        
            
            if status_on_enabled.v then
                imgui.PushStyleColor(imgui.Col.Button, AnimatedPinkPurpleShade())
            else
                imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.Button])
            end
            if imgui.Button("ON", imgui.ImVec2(status_btn_w, status_btn_h)) then
                status_on_enabled.v = true
                status_off_enabled.v = false
            end
            imgui.PopStyleColor()
        
            imgui.SameLine()
        
            
            if status_off_enabled.v then
                imgui.PushStyleColor(imgui.Col.Button, AnimatedPinkPurpleShade())
            else
                imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.Button])
            end
            if imgui.Button("OFF", imgui.ImVec2(status_btn_w, status_btn_h)) then
                status_on_enabled.v = false
                status_off_enabled.v = true
            end
            imgui.PopStyleColor()
        
        elseif gui_mode == 2 then
            local cfg = getActiveConfig()

            if selected_index.v <= 1 then
                local msg = "Ne mozete podesavati postavke dok koristitie default config."
                local msg_width = imgui.CalcTextSize(msg).x
                imgui.SetCursorPosY(windowHeight / 2 - imgui.GetTextLineHeight() / 2)
                imgui.SetCursorPosX((windowWidth - msg_width) / 2)
                imgui.Text(msg)
            else

                imgui.NewLine()
                imgui.Text("X Osa")
                if cfg.throw_speed_x_random_enabled.v then
                    ThrowSpeedRandomControl("Brzina Bacanja X", cfg.throw_speed_x_random_min, cfg.throw_speed_x_random_max)
                else
                    ThrowSpeedControl("Brzina Bacanja X", cfg.throw_speed_x)
                end
                OffsetControl("Interval Povecanja X", cfg.boost_interval_x)
                imgui.PushStyleColor(imgui.Col.CheckMark, AnimatedPinkPurpleShade())
                imgui.Checkbox("Random Brzina X", cfg.throw_speed_x_random_enabled)
                imgui.Text("Polaritet X")
                imgui.SameLine()
                local btn_w, btn_h = 60, 22
            
                if cfg.direction_x.v == nil then cfg.direction_x.v = 2 end
            
                local neg_col = (cfg.direction_x.v == -1) and AnimatedPinkPurpleShade() or imgui.ImVec4(0.4, 0.4, 0.4, 1)
                local mid_col = (cfg.direction_x.v == 2) and AnimatedPinkPurpleShade() or imgui.ImVec4(0.4, 0.4, 0.4, 1)
                local pos_col = (cfg.direction_x.v == 1) and AnimatedPinkPurpleShade() or imgui.ImVec4(0.4, 0.4, 0.4, 1)
            
                imgui.PushStyleColor(imgui.Col.Button, neg_col)
                if imgui.Button("-##x", imgui.ImVec2(btn_w, btn_h)) then
                    cfg.direction_x.v = -1
                end
                imgui.PopStyleColor()
            
                imgui.SameLine()
            
                imgui.PushStyleColor(imgui.Col.Button, mid_col)
                if imgui.Button("%##x", imgui.ImVec2(btn_w, btn_h)) then
                    cfg.direction_x.v = 2
                end
                imgui.PopStyleColor()
            
                imgui.SameLine()
            
                imgui.PushStyleColor(imgui.Col.Button, pos_col)
                if imgui.Button("+##x", imgui.ImVec2(btn_w, btn_h)) then
                    cfg.direction_x.v = 1
                end
                imgui.PopStyleColor()
                imgui.PopStyleColor()

                imgui.NewLine()

                imgui.Text("Y Osa")
                if cfg.throw_speed_y_random_enabled.v then
                    ThrowSpeedRandomControl("Brzina Bacanja Y", cfg.throw_speed_y_random_min, cfg.throw_speed_y_random_max)
                else
                    ThrowSpeedControl("Brzina Bacanja Y", cfg.throw_speed_y)
                end
                OffsetControl("Interval Povecanja Y", cfg.boost_interval_y)
                imgui.PushStyleColor(imgui.Col.CheckMark, AnimatedPinkPurpleShade())
                imgui.Checkbox("Random Brzina Y", cfg.throw_speed_y_random_enabled)
                imgui.Text("Polaritet Y")
                imgui.SameLine()
                local btn_w, btn_h = 60, 22
            
                if cfg.direction_y.v == nil then cfg.direction_y.v = 2 end
            
                local neg_col = (cfg.direction_y.v == -1) and AnimatedPinkPurpleShade() or imgui.ImVec4(0.4, 0.4, 0.4, 1)
                local mid_col = (cfg.direction_y.v == 2) and AnimatedPinkPurpleShade() or imgui.ImVec4(0.4, 0.4, 0.4, 1)
                local pos_col = (cfg.direction_y.v == 1) and AnimatedPinkPurpleShade() or imgui.ImVec4(0.4, 0.4, 0.4, 1)
            
                imgui.PushStyleColor(imgui.Col.Button, neg_col)
                if imgui.Button("-##y", imgui.ImVec2(btn_w, btn_h)) then
                    cfg.direction_y.v = -1
                end
                imgui.PopStyleColor()
            
                imgui.SameLine()
            
                imgui.PushStyleColor(imgui.Col.Button, mid_col)
                if imgui.Button("%##y", imgui.ImVec2(btn_w, btn_h)) then
                    cfg.direction_y.v = 2
                end
                imgui.PopStyleColor()
            
                imgui.SameLine()
            
                imgui.PushStyleColor(imgui.Col.Button, pos_col)
                if imgui.Button("+##y", imgui.ImVec2(btn_w, btn_h)) then
                    cfg.direction_y.v = 1
                end
                imgui.PopStyleColor()
                
                imgui.PopStyleColor()

                imgui.NewLine()

                imgui.Text("Z Osa")
                if cfg.throw_speed_z_random_enabled.v then
                    ThrowSpeedRandomControl("Brzina Bacanja Z", cfg.throw_speed_z_random_min, cfg.throw_speed_z_random_max)
                else
                    ThrowSpeedControl("Brzina Bacanja Z", cfg.throw_speed_z)
                end
                OffsetControl("Interval Povecanja Z", cfg.boost_interval_z)
                imgui.PushStyleColor(imgui.Col.CheckMark, AnimatedPinkPurpleShade())
                imgui.Checkbox("Random Brzina Z", cfg.throw_speed_z_random_enabled)
                imgui.Text("Polaritet Z")
                imgui.SameLine()
                local btn_w, btn_h = 60, 22
            
                if cfg.direction_z.v == nil then cfg.direction_z.v = 2 end
            
                local neg_col = (cfg.direction_z.v == -1) and AnimatedPinkPurpleShade() or imgui.ImVec4(0.4, 0.4, 0.4, 1)
                local mid_col = (cfg.direction_z.v == 2) and AnimatedPinkPurpleShade() or imgui.ImVec4(0.4, 0.4, 0.4, 1)
                local pos_col = (cfg.direction_z.v == 1) and AnimatedPinkPurpleShade() or imgui.ImVec4(0.4, 0.4, 0.4, 1)
            
                imgui.PushStyleColor(imgui.Col.Button, neg_col)
                if imgui.Button("-##z", imgui.ImVec2(btn_w, btn_h)) then
                    cfg.direction_z.v = -1
                end
                imgui.PopStyleColor()
            
                imgui.SameLine()
            
                imgui.PushStyleColor(imgui.Col.Button, mid_col)
                if imgui.Button("%##z", imgui.ImVec2(btn_w, btn_h)) then
                    cfg.direction_z.v = 2
                end
                imgui.PopStyleColor()
            
                imgui.SameLine()
            
                imgui.PushStyleColor(imgui.Col.Button, pos_col)
                if imgui.Button("+##z", imgui.ImVec2(btn_w, btn_h)) then
                    cfg.direction_z.v = 1
                end
                imgui.PopStyleColor()
                imgui.PopStyleColor()

                imgui.NewLine()
            end

        elseif gui_mode == 3 then
            local cfg = getActiveConfig()

            if selected_index.v <= 1 then
                local msg = "Ne mozete podesavati postavke dok koristitie default config."
                local msg_width = imgui.CalcTextSize(msg).x
                imgui.SetCursorPosY(windowHeight / 2 - imgui.GetTextLineHeight() / 2)
                imgui.SetCursorPosX((windowWidth - msg_width) / 2)
                imgui.Text(msg)
            else
                imgui.NewLine()
                imgui.Text("X Osa")

                OffsetControl("Offset X Plus", cfg.offset_x_plus)

                imgui.PushStyleColor(imgui.Col.CheckMark, AnimatedPinkPurpleShade())
                imgui.PopStyleColor()

                imgui.NewLine()

                imgui.Text("Y Osa")
                OffsetControl("Offset Y Plus", cfg.offset_y_plus)

                imgui.PushStyleColor(imgui.Col.CheckMark, AnimatedPinkPurpleShade())
                imgui.PopStyleColor()

                imgui.NewLine()

                imgui.Text("Z Osa")

                OffsetControl("Offset Z Plus", cfg.offset_z_plus)

                imgui.PushStyleColor(imgui.Col.CheckMark, AnimatedPinkPurpleShade())
                imgui.PopStyleColor()

                imgui.NewLine()

                imgui.Text("Orjentacija vozila")

                imgui.PushItemWidth(350)
                

                imgui.SliderFloat("##Yaw", cfg.vehicle_yaw, -180.0, 180.0, "%.1f")
                imgui.SameLine()
                imgui.Text("Yaw")
                

                imgui.SliderFloat("##Pitch", cfg.vehicle_pitch, -90.0, 90.0, "%.1f")
                imgui.SameLine()
                imgui.Text("Pitch")
                

                imgui.SliderFloat("##Roll", cfg.vehicle_roll, -180.0, 180.0, "%.1f")
                imgui.SameLine()
                imgui.Text("Roll")
                
                imgui.PopItemWidth()


            end
            
        elseif gui_mode == 4 then
            local cfg = getActiveConfig()
            if selected_index.v <= 1 then
                local msg = "Ne mozete podesavati postavke dok koristitie default config."
                local msg_width = imgui.CalcTextSize(msg).x
                imgui.SetCursorPosY(windowHeight / 2 - imgui.GetTextLineHeight() / 2)
                imgui.SetCursorPosX((windowWidth - msg_width) / 2)
                imgui.Text(msg)
            else
                imgui.NewLine()
                imgui.Text("Ostali Paramteri")
        
                OffsetControl("Minimalni domet", cfg.min_range)
                OffsetControl("Maksimalni domet", cfg.max_range)
                OffsetControl("Paketa po sekundi", cfg.packets_ps)
        
        
                imgui.NewLine()
        
                imgui.Text("NOPovi")
                imgui.PushStyleColor(imgui.Col.CheckMark, AnimatedPinkPurpleShade())
                imgui.Checkbox("SetVehiclePos", cfg.set_vehicle_pos)
                imgui.Checkbox("SetVehicleVelocity", cfg.set_vehicle_velocity)
                imgui.Checkbox("SetVehicleZAngle", cfg.set_vehicle_z_angle)
                imgui.Checkbox("RemovePlayerFromVehicle", cfg.remove_player_from_vehicle)
                imgui.Checkbox("SetVehicleHealth", cfg.set_vehicle_health)
                imgui.Checkbox("UpdateVehicleDamageStatus", cfg.update_vehicle_damage_status)
                imgui.Checkbox("DisableVehicleCollisions", cfg.disable_vehicle_collisions)
                imgui.Checkbox("WorldVehicleRemove", cfg.world_vehicle_remove)
                imgui.Checkbox("SetVehicleParamsEx", cfg.set_vehicle_params_ex)
                imgui.PopStyleColor()

                imgui.NewLine()

                local btn_w, btn_h = 90, 26
                local windowWidth = imgui.GetWindowSize().x
                local text = "Odabir tipa zrtava koje ce skripta ciljano napadati:"
                local textWidth = imgui.CalcTextSize(text).x
                imgui.SetCursorPosX((windowWidth - textWidth) * 0.5)
                imgui.Text(text)
                
                local totalButtonsWidth = (btn_w * 3) + (imgui.GetStyle().ItemSpacing.x * 2)
                imgui.SetCursorPosX((windowWidth - totalButtonsWidth) * 0.5)

                
                local col_all = (configs.onfoot.victim_selector.v == 0 and configs.incar.victim_selector.v == 0)
                    and AnimatedPinkPurpleShade() or imgui.ImVec4(0.3,0.3,0.3,1)
                imgui.PushStyleColor(imgui.Col.Button, col_all)
                if imgui.Button("ALL##ftm", imgui.ImVec2(btn_w, btn_h)) then
                    configs.onfoot.victim_selector.v = 0
                    configs.incar.victim_selector.v = 0
                end
                imgui.PopStyleColor()
                imgui.SameLine()

                
                local col_icar = (configs.onfoot.victim_selector.v == 1 and configs.incar.victim_selector.v == 1)
                    and AnimatedPinkPurpleShade() or imgui.ImVec4(0.3,0.3,0.3,1)
                imgui.PushStyleColor(imgui.Col.Button, col_icar)
                if imgui.Button("INCAR##ftm", imgui.ImVec2(btn_w, btn_h)) then
                    configs.onfoot.victim_selector.v = 1
                    configs.incar.victim_selector.v = 1
                end
                imgui.PopStyleColor()
                imgui.SameLine()

                
                local col_oft = (configs.onfoot.victim_selector.v == 2 and configs.incar.victim_selector.v == 2)
                    and AnimatedPinkPurpleShade() or imgui.ImVec4(0.3,0.3,0.3,1)
                imgui.PushStyleColor(imgui.Col.Button, col_oft)
                if imgui.Button("ONFOOT##ftm", imgui.ImVec2(btn_w, btn_h)) then
                    configs.onfoot.victim_selector.v = 2
                    configs.incar.victim_selector.v = 2
                end
                imgui.PopStyleColor()

            end
        elseif gui_mode == 5 then
            imgui.NewLine()
        
            local windowWidth = imgui.GetWindowSize().x
            local title = "FAQ - Cesto postavljana pitanja"
            local textSize = imgui.CalcTextSize(title)
            imgui.SetCursorPosX((windowWidth - textSize.x) * 0.5)
            imgui.TextColored(imgui.ImVec4(0.8, 0.4, 0.9, 1), title)

            imgui.NewLine()

        
            local faq = {
                {question = "Za sta se koristi ova skripta?", 
                 answer = "Skripta sluzi za bacanje zrtava koristeci samo vase vozilo. To znaci da je ovo slapper koji radi dok ste u vozilu i napada sve zrtve, bilo da su onfoot ili u vozilu."},
            
                {question = "Koje keybindove koristim?", 
                 answer = "Za napadanje zrtve koristite LMB (lijevi klik) ili R tipku, zavisno od konfiguracije. Pritiskom na RMB mozete prebaciti ciljanje na druge zrtve u blizini, sto omogucava selekciju."},
            
                {question = "Za sta sluze konfiguracije?", 
                 answer = "Konfiguracije omogucavaju kreiranje razlicitih setova postavki, jer serveri razlicito rade i zahtijevaju druge konfiguracije kako vas anticheat ne bi flagovao. Sve se cuva u .json datoteci u moonloader folderu."},
            
                {question = "Za sta je ONFOOT, a za sta INCAR opcija?", 
                 answer = "Ove opcije pruzaju mogucnost da pravite konfiguracije zavisno od statusa zrtve. Ako je zrtva onfoot, koriste se ONFOOT postavke, a ako je u vozilu, koriste se INCAR postavke. Na tabu Ostalo mozete odabrati da li napadate sve zrtve ili samo odredjene."},
            
                {question = "Za sta sluzi default config?", 
                 answer = "Default config je unaprijed napravljen da radi na vecini servera. Nije podesavan za kikovanje ili prejako bacanje igraca, vec normalno baca igrace bez dodatnih konfiguracija."}
            }
            
        
            for i, item in ipairs(faq) do
                imgui.TextColored(imgui.ImVec4(0.9, 0.6, 0.9, 1), "Q: " .. item.question)
                imgui.Dummy(imgui.ImVec2(0, 1)) 
        
                imgui.Indent(5)
                imgui.TextWrapped("A: " .. item.answer)
                imgui.Unindent(5)
        
                imgui.NewLine()
            end
        end
        
        imgui.End()

    end

end

function GUI_THEME()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col

    style.WindowRounding = 7
    style.FrameRounding  = 6
    style.ScrollbarRounding = 9
    style.GrabRounding = 6

    colors[clr.WindowBg]             = imgui.ImVec4(0.05, 0.05, 0.06, 1.00)
    colors[clr.PopupBg]              = imgui.ImVec4(0.07, 0.07, 0.08, 0.98)
    colors[clr.Border]               = imgui.ImVec4(0.15, 0.15, 0.18, 1.00)

    colors[clr.Text]                 = imgui.ImVec4(0.98, 0.98, 0.99, 1.00)
    colors[clr.TextDisabled]         = imgui.ImVec4(0.35, 0.35, 0.40, 1.00)

    colors[clr.FrameBg]              = imgui.ImVec4(0.09, 0.09, 0.11, 1.00)
    colors[clr.FrameBgHovered]       = AnimatedPinkPurpleShade()
    colors[clr.FrameBgActive]        = AnimatedPinkPurpleShade()

    colors[clr.Button]               = imgui.ImVec4(0.11, 0.11, 0.13, 1.00)
    colors[clr.ButtonHovered]        = AnimatedPinkPurpleShade()
    colors[clr.ButtonActive]         = imgui.ImVec4(0.18, 0.18, 0.21, 1.00)

    colors[clr.CheckMark]            = AnimatedPinkPurpleShade()

    colors[clr.Header]               = imgui.ImVec4(0.11, 0.11, 0.13, 1.00)
    colors[clr.HeaderHovered]        = AnimatedPinkPurpleShade()
    colors[clr.HeaderActive]         = AnimatedPinkPurpleShade()

    colors[clr.Separator]            = imgui.ImVec4(0.18, 0.18, 0.21, 1.00)
    colors[clr.SeparatorHovered]     = AnimatedPinkPurpleShade()
    colors[clr.SeparatorActive]      = AnimatedPinkPurpleShade()

    colors[clr.TitleBg]              = imgui.ImVec4(0.06, 0.06, 0.07, 1.00)
    colors[clr.TitleBgActive]        = imgui.ImVec4(0.10, 0.10, 0.12, 1.00)
    colors[clr.TitleBgCollapsed]     = imgui.ImVec4(0.05, 0.05, 0.06, 1.00)

    colors[clr.ScrollbarBg]          = imgui.ImVec4(0.04, 0.04, 0.05, 1.00)
    colors[clr.ScrollbarGrab]        = imgui.ImVec4(0.14, 0.14, 0.17, 1.00)
    colors[clr.ScrollbarGrabHovered] = AnimatedPinkPurpleShade()
    colors[clr.ScrollbarGrabActive]  = AnimatedPinkPurpleShade()
end
GUI_THEME()

function onExitScript()
    saveSettings()
    saveMainConfig()
end