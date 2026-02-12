-- Arcane AI BOT
-- Prvi bot ovakvog tipa koji ste vidjeli.
-- Autor: Hake
-- Powered by BIGBANG COMMUNITY HQ SCRIPTS
-- U skriptu je ulozeno sate i sate progamiranja, sate i sate ucenja.
-- Perfektno radi, koristi najbolje moguce napravljene algoritme u LUA jeziku za pathfinding.
-- Ne znam da li ce ovo kada biti opensource, ali opet sam napisao ove komentare, radi sebe.
-- 5. JULY 2025

-- DEPENDENCIES
require 'lib.sampfuncs'
require 'lib.moonloader'
encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
utf8 = encoding.UTF8
inicfg = require "inicfg"
memory = require "memory"
sampev = require("samp.events")
imgui = require 'imgui'
script_version = 0

-- GUI
arcbot_GUI = imgui.ImBool(false)
screenW, screenH = getScreenResolution()
windowWidth = 315
windowHeight = 315


local bazen = {
    {1954.5300, -1218.7100, 20.0200},
    {1955.5400, -1218.8200, 20.0200},
    {1956.5300, -1218.9300, 20.0200},
    {1957.5300, -1219.0400, 20.0200},
    {1958.5400, -1219.1600, 20.0200},
    {1959.5600, -1219.2700, 20.0200},
    {1960.5600, -1219.3800, 20.0200},
    {1961.5600, -1219.5000, 20.0200},
    {1962.5800, -1219.6200, 20.0200},
    {1963.5900, -1219.7000, 20.0200},
    {1964.5900, -1219.7600, 20.0200},
    {1965.6200, -1219.8100, 20.0200},
    {1966.6300, -1219.8300, 20.0200},
    {1967.6500, -1219.8600, 20.0200},
    {1968.6600, -1219.8900, 20.0200},
    {1969.6800, -1219.9200, 20.0200},
    {1970.7200, -1219.9300, 20.0200},
    {1971.7500, -1219.9300, 20.0200},
    {1972.7700, -1219.9300, 20.0200},
    {1973.7900, -1219.9000, 20.0200},
    {1974.7900, -1219.8500, 20.0200},
    {1975.8100, -1219.7900, 20.0200},
    {1976.8400, -1219.7300, 20.0200},
    {1977.8500, -1219.6600, 20.0200},
    {1978.8600, -1219.5700, 20.0200},
    {1979.8600, -1219.4500, 20.0200},
    {1980.8500, -1219.2900, 20.0200},
    {1981.8800, -1219.1300, 20.0200},
    {1982.8800, -1218.9900, 20.0200},
    {1983.9100, -1218.8300, 20.0200},
    {1984.9100, -1218.6500, 20.0200},
    {1985.9200, -1218.4600, 20.0200},
    {1986.9200, -1218.2800, 20.0200},
    {1987.9200, -1218.1000, 20.0200},
    {1988.9100, -1217.8900, 20.0200},
    {1989.9100, -1217.6600, 20.0200},
    {1990.9200, -1217.4000, 20.0200},
    {1991.8900, -1217.1200, 20.0200},
    {1992.8600, -1216.8300, 20.0200},
    {1993.8100, -1216.5100, 20.0200},
    {1994.7600, -1216.1800, 20.0200},
    {1995.7100, -1215.7900, 20.0200},
    {1996.6500, -1215.4000, 20.0200},
    {1997.5800, -1215.0200, 20.0200},
    {1998.5100, -1214.6300, 20.0200},
    {1999.4200, -1214.2100, 20.0200},
    {2000.3200, -1213.7400, 20.0200},
    {2001.1900, -1213.2400, 20.0200},
    {2002.0700, -1212.7100, 20.0200},
    {2002.9300, -1212.1700, 20.0200},
    {2003.7700, -1211.5900, 20.0200},
    {2004.6000, -1210.9900, 20.0200},
    {2005.4000, -1210.3600, 20.0200},
    {2006.1700, -1209.6700, 20.0200},
    {2006.9100, -1208.9500, 20.0200},
    {2007.6200, -1208.2300, 20.0200},
    {2008.3200, -1207.4800, 20.0200},
    {2008.9600, -1206.7100, 20.0200},
    {2009.5400, -1205.8800, 20.0200},
    {2010.0500, -1205.0000, 20.0200},
    {2010.4400, -1204.0600, 20.0200},
    {2010.7900, -1203.0900, 20.0200},
    {2011.0900, -1202.1100, 20.0200},
    {2011.2900, -1201.1100, 20.0200},
    {2011.3200, -1200.0900, 20.0200},
    {2011.1800, -1199.0800, 20.0200},
    {2011.0300, -1198.0700, 20.0200},
    {2010.9100, -1197.0700, 20.0200},
    {2010.7800, -1196.0500, 20.0200},
    {2010.5600, -1195.0700, 20.0200},
    {2010.1500, -1194.1300, 20.0200},
    {2009.5800, -1193.2400, 20.0200},
    {2008.9900, -1192.4300, 20.0200},
    {2008.3600, -1191.6000, 20.0200},
    {2007.7300, -1190.7900, 20.0200},
    {2007.0700, -1190.0300, 20.0200},
    {2006.3200, -1189.3600, 20.0200},
    {2005.4900, -1188.7400, 20.0200},
    {2004.6400, -1188.1600, 20.0200},
    {2003.7900, -1187.6300, 20.0200},
    {2002.9000, -1187.1000, 20.0200},
    {2002.0400, -1186.5900, 20.0200},
    {2001.1400, -1186.0700, 20.0200},
    {2000.2400, -1185.5700, 20.0200},
    {1999.3300, -1185.0900, 20.0200},
    {1998.4300, -1184.6400, 20.0200},
    {1997.5000, -1184.2100, 20.0200},
    {1996.5500, -1183.8000, 20.0200},
    {1995.5800, -1183.4300, 20.0200},
    {1994.6100, -1183.0900, 20.0200},
    {1993.6400, -1182.7600, 20.0200},
    {1992.6700, -1182.4900, 20.0200},
    {1991.6500, -1182.2300, 20.0200},
    {1990.6600, -1181.9900, 20.0200},
    {1989.6800, -1181.7400, 20.0200},
    {1988.7000, -1181.5000, 20.0200},
    {1987.7100, -1181.2500, 20.0200},
    {1986.7300, -1181.0000, 20.0200},
    {1985.7400, -1180.7600, 20.0200},
    {1984.7000, -1180.5800, 20.0200},
    {1983.6900, -1180.4500, 20.0200},
    {1982.6500, -1180.3200, 20.0200},
    {1981.6500, -1180.2400, 20.0200},
    {1980.6200, -1180.1600, 20.0200},
    {1979.5900, -1180.0600, 20.0200},
    {1978.5800, -1179.9500, 20.0200},
    {1977.5800, -1179.8400, 20.0200},
    {1976.5600, -1179.7400, 20.0200},
    {1975.5600, -1179.6400, 20.0200},
    {1974.5200, -1179.5800, 20.0200},
    {1973.5100, -1179.5600, 20.0200},
    {1972.4800, -1179.5500, 20.0200},
    {1971.4400, -1179.5400, 20.0200},
    {1970.4200, -1179.5200, 20.0300},
    {1969.3900, -1179.5000, 20.0200},
    {1968.3400, -1179.4700, 20.0200},
    {1967.3100, -1179.4600, 20.0200},
    {1966.3000, -1179.4700, 20.0200},
    {1965.2900, -1179.4800, 20.0200},
    {1964.2700, -1179.5000, 20.0200},
    {1963.2200, -1179.5600, 20.0200},
    {1962.2200, -1179.6600, 20.0200},
    {1961.2300, -1179.8100, 20.0200},
    {1960.2400, -1179.9800, 20.0200},
    {1959.2400, -1180.1400, 20.0200},
    {1958.2600, -1180.3200, 20.0200},
    {1957.2700, -1180.5300, 20.0200},
    {1956.2800, -1180.7400, 20.0200},
    {1955.3000, -1180.9400, 20.0200},
    {1954.3200, -1181.1500, 20.0200},
    {1953.3300, -1181.3600, 20.0200},
    {1952.3300, -1181.5800, 20.0200},
    {1951.3400, -1181.7800, 20.0200},
    {1950.4400, -1181.3300, 20.0200},
    {1950.3900, -1180.3200, 20.0200},
    {1950.2000, -1179.3400, 20.0200},
    {1949.2700, -1178.9600, 20.0200},
    {1948.2900, -1179.1900, 20.0200},
    {1948.5000, -1180.1800, 20.0200},
    {1948.4900, -1181.2000, 20.0200},
    {1948.3800, -1182.2200, 20.0200},
    {1947.8900, -1183.0900, 20.0200},
    {1946.9500, -1183.4400, 20.0200},
    {1945.9900, -1183.7700, 20.0200},
    {1945.0500, -1184.1700, 20.0200},
    {1944.1100, -1184.5900, 20.0200},
    {1943.1700, -1185.0000, 20.0200},
    {1942.2800, -1185.4600, 20.0200},
    {1941.4000, -1185.9700, 20.0200},
    {1940.5200, -1186.4800, 20.0200},
    {1939.6300, -1187.0000, 19.9900},
    {1938.7600, -1187.5400, 19.9100},
    {1937.9200, -1188.0800, 20.0200},
    {1937.0700, -1188.6200, 20.0200},
    {1936.1900, -1189.1800, 20.0200},
    {1935.3600, -1189.7700, 20.0200},
    {1934.5800, -1190.4100, 20.0200},
    {1933.8600, -1191.1300, 20.0200},
    {1933.1700, -1191.9000, 20.0200},
    {1932.5600, -1192.7000, 20.0200},
    {1931.9600, -1193.5100, 20.0200},
    {1931.3900, -1194.3400, 20.0200},
    {1930.9500, -1195.2500, 20.0200},
    {1930.6000, -1196.2100, 20.0300},
    {1930.3400, -1197.2000, 20.0300},
    {1930.1100, -1198.2100, 20.0300},
    {1929.9600, -1199.2300, 20.0300},
    {1929.9500, -1200.2500, 20.0200},
    {1930.1700, -1201.2400, 20.0200},
    {1930.5000, -1202.2000, 20.0200},
    {1930.8300, -1203.1600, 20.0200},
    {1931.1300, -1204.1400, 20.0200},
    {1931.4500, -1205.1400, 20.0200},
    {1931.8700, -1206.0500, 20.0200},
    {1932.4400, -1206.8800, 20.0200},
    {1933.1000, -1207.6500, 20.0200},
    {1933.7600, -1208.4200, 20.0200},
    {1934.4500, -1209.1800, 20.0200},
    {1935.2100, -1209.9100, 20.0200},
    {1936.0100, -1210.5300, 20.0200},
    {1936.8800, -1211.0500, 20.0200},
    {1937.7400, -1211.5800, 20.0200},
    {1938.5900, -1212.1100, 20.0200},
    {1939.4700, -1212.6500, 20.0200},
    {1940.3500, -1213.1700, 20.0200},
    {1941.2500, -1213.6600, 20.0200},
    {1942.1700, -1214.1100, 20.0200},
    {1943.1000, -1214.5600, 20.0200},
    {1944.0100, -1214.9900, 20.0200},
    {1944.9100, -1215.4300, 20.0200},
    {1945.8200, -1215.8700, 20.0200},
    {1946.7300, -1216.3000, 20.0200},
    {1947.6600, -1216.6900, 20.0200},
    {1948.5900, -1217.0700, 20.0200},
    {1949.5300, -1217.4100, 20.0200},
    {1950.5000, -1217.7100, 20.0200},
    {1951.6700, -1218.7200, 20.0200},
    {1952.6700, -1218.7800, 20.0200}
}

function isNearBazen(px, py, pz)
    for i = 1, #bazen do
        local bx, by, bz = bazen[i][1], bazen[i][2], bazen[i][3]
        local dist = getDistanceBetweenCoords3d(px, py, pz, bx, by, bz)
        if dist < 5.0 then
            return true
        end
    end
    return false
end

-- AUTOVERIFICATION
local tdIds = {
    2136, 2124, 2140, 2125, 2131, 2138, 2135, 2143, 2126, 2134,
    2129, 2142, 2145, 2144, 2133, 2139, 2128, 2127, 2137, 2130,
    2141, 2132
}

local segment_ids = {
    top = nil, top_left = nil, top_right = nil,
    middle = nil, bottom_left = nil,
    bottom_right = nil, bottom = nil
}

local segment_ids2 = {
    top = nil, top_left = nil, top_right = nil,
    middle = nil, bottom_left = nil,
    bottom_right = nil, bottom = nil
}

local segment_ids3 = {
    top = nil, top_left = nil, top_right = nil,
    middle = nil, bottom_left = nil,
    bottom_right = nil, bottom = nil
}

local digit_segments = {
    ["1111110"] = "0", ["0110000"] = "1",
    ["1101101"] = "2", ["1111001"] = "3",
    ["0110011"] = "4", ["1011011"] = "5",
    ["1011111"] = "6", ["1110000"] = "7",
    ["1111111"] = "8", ["1111011"] = "9"
}

local last_valid_code = nil
local segment_warning_shown = false

-- BOT STATE
local isEnabled = false 
local isRunning = false
local isNavigating = false
local navigationStartTime = 0
local rotationDirection = 0

local routePoints = {}
local nodeUsage = {}
local destination = nil
local activePath = {}
local routeRadius = 1.0
local maxNeighborDistance = 1.0
local spatialGrid = {}
local gridCellSize = 5.0

local activeMarkers = {}
local currentMarkerIndex = 1

local markerBase = 0xC7DD88
local markerCount = 32
local markerStep = 160

local maxJumps = 3
local jumpCooldown = os.clock() * 1000 + math.random(1000, 3000)
local jumpCount = maxJumps
local canjump = false
local jumpIntervalMax = 15

local maxCtrlPresses = 2
local ctrlCount = maxCtrlPresses
local ctrlCooldown = 0
local ctrlIntervalMax = math.random(1000,10000)

local lastX, lastY = 0, 0
local isStuck = false
local stuckTimer = os.clock()
local stuckDuration = 0
local maxStuckDuration = 5
local isTouchingObject = false
local retryAttempted = false
local retryWaitStart = 0

local configFileName = "settings_arcbot"

local defaultSettings = {
    config = {
        auto_vfc = true,
        jump_habit = true,
        punch_habit = true,
        infinity_run = true,
        panic_enabled = true
    }
}

local settings = inicfg.load(defaultSettings, configFileName)

if not doesFileExist("moonloader/" .. configFileName .. ".ini") then
    inicfg.save(settings, configFileName)
end


local auto_vfc = imgui.ImBool(settings.config.auto_vfc)
local jump_habit = imgui.ImBool(settings.config.jump_habit)
local punch_habit = imgui.ImBool(settings.config.punch_habit)
local infinity_run = imgui.ImBool(settings.config.infinity_run)
local panic_enabled = imgui.ImBool(settings.config.panic_enabled)

function saveSettings()
    settings.config.auto_vfc = auto_vfc.v
    settings.config.jump_habit = jump_habit.v
    settings.config.punch_habit = punch_habit.v
    settings.config.infinity_run = infinity_run.v
    settings.config.panic_enabled = panic_enabled.v
    inicfg.save(settings, configFileName)
end

-- OTHER
local loaded_yes = false

-- FILE INIT
function ensure_file_structure()
    if not doesDirectoryExist('moonloader/ARCANEAIBOT') then
        createDirectory('moonloader/ARCANEAIBOT')
    end
    if not doesFileExist('moonloader/ARCANEAIBOT/rute.txt') then
        local f = io.open('moonloader/ARCANEAIBOT/rute.txt', 'w') if f then f:close() end
    end
end

-- DATABASE CONNECTOR
function data_base_connect()
    local temp_path = os.getenv('TEMP') .. '\\route_data.json'
    local url = ''
    local dlstatus = require('moonloader').download_status

    local routePoints = {}
    local downloadComplete = false
    local downloadSuccess = false
    local file_path = 'moonloader/ARCANEAIBOT/rute.txt'

    sampAddChatMessage("{e2abff}(ARCANE AI BOT): {ffd391}LOADING...", -1)

    local attempt = 0
    repeat
        downloadComplete = false
        downloadSuccess = false
        routePoints = {}

        downloadUrlToFile(url, temp_path, function(id, status)
            if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                local f = io.open(temp_path, 'r')
                if not f then
                    print("ARCANE AI BOT ERROR: Ne mogu otvoriti JSON fajl.")
                    downloadComplete = true
                    downloadSuccess = false
                    return
                end

                local content = f:read('*a')
                f:close()
                local success, data = pcall(decodeJson, content)
                if not success or type(data) ~= 'table' then
                    print("ARCANE AI BOT ERROR: Neuspjesno citanje JSON-a.")
                    downloadComplete = true
                    downloadSuccess = false
                    return
                end

                if type(data.routePoints) == 'table' then
                    for _, point in ipairs(data.routePoints) do
                        if point.x and point.y and point.z then
                            table.insert(routePoints, {
                                x = tonumber(point.x),
                                y = tonumber(point.y),
                                z = tonumber(point.z)
                            })
                        end
                    end
                end

                if type(data.script_version) == 'number' then
                    script_version = data.script_version
                    print(string.format("ARCANE AI BOT: Script state je %.2f", script_version))
                end

                downloadComplete = true
                downloadSuccess = true
            elseif status == dlstatus.STATUS_FAILED then
                print("ARCANE AI BOT ERROR: Preuzimanje nije uspjelo.")
                downloadComplete = true
                downloadSuccess = false
            end
        end)

        local waitTimeout = 0
        while not downloadComplete and waitTimeout < 200 do
            wait(100)
            waitTimeout = waitTimeout + 1
        end

        attempt = attempt + 1
    until downloadSuccess or attempt >= 2

    if not downloadSuccess then
        local f = io.open(file_path, 'r')
        local hasValidData = false
        if f then
            print("ARCANE AI BOT: Ucitavam lokalni fajl rute.txt...")
            routePoints = {}
            for line in f:lines() do
                local x, y, z = line:match("{([%d%.-]+), ([%d%.-]+), ([%d%.-]+)}")
                if x and y and z then
                    table.insert(routePoints, {
                        x = tonumber(x),
                        y = tonumber(y),
                        z = tonumber(z)
                    })
                    hasValidData = true
                end
            end
            f:close()
        end

        if not hasValidData then
            print("ARCANE AI BOT: Lokalni fajl ne postoji ili je prazan. Pocinjem beskonačne pokušaje skidanja s interneta...")
            repeat
                downloadComplete = false
                downloadSuccess = false
                routePoints = {}

                downloadUrlToFile(url, temp_path, function(id, status)
                    if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                        local f2 = io.open(temp_path, 'r')
                        if not f2 then
                            print("ARCANE AI BOT ERROR: Ne mogu otvoriti JSON fajl.")
                            downloadComplete = true
                            downloadSuccess = false
                            return
                        end

                        local content = f2:read('*a')
                        f2:close()
                        local success, data = pcall(decodeJson, content)
                        if not success or type(data) ~= 'table' then
                            print("ARCANE AI BOT ERROR: Neuspjesno citanje JSON-a.")
                            downloadComplete = true
                            downloadSuccess = false
                            return
                        end

                        if type(data.routePoints) == 'table' then
                            for _, point in ipairs(data.routePoints) do
                                if point.x and point.y and point.z then
                                    table.insert(routePoints, {
                                        x = tonumber(point.x),
                                        y = tonumber(point.y),
                                        z = tonumber(point.z)
                                    })
                                end
                            end
                        end

                        if type(data.script_version) == 'number' then
                            script_version = data.script_version
                            print(string.format("ARCANE AI BOT: Script state je %.2f", script_version))
                        end

                        downloadComplete = true
                        downloadSuccess = true
                    elseif status == dlstatus.STATUS_FAILED then
                        print("ARCANE AI BOT ERROR: Preuzimanje nije uspjelo.")
                        downloadComplete = true
                        downloadSuccess = false
                    end
                end)

                waitTimeout = 0
                while not downloadComplete and waitTimeout < 200 do
                    wait(100)
                    waitTimeout = waitTimeout + 1
                end

                if not downloadSuccess then
                    wait(2000) 
                end
            until downloadSuccess
        else
            downloadSuccess = true
        end
    end

    if downloadSuccess and #routePoints > 0 then
        local f = io.open(file_path, 'w')
        if f then
            for _, point in ipairs(routePoints) do
                f:write(string.format("{%f, %f, %f}\n", point.x, point.y, point.z))
            end
            f:close()
        else
            print("ARCANE AI BOT ERROR: Ne mogu zapisati u rute.txt.")
        end
    end

    loaded_yes = true
    sampAddChatMessage("{e2abff}(ARCANE AI BOT): {c8ff91}LOADED...", -1)
    sampAddChatMessage("{e2abff}(ARCANE AI BOT): {9a5cff}Komanda: /arcbot & F4", 0x7CFC00)

    return routePoints, script_version
end



math.randomseed(os.time())
math.random(); math.random(); math.random() 

local function shuffle(t)
    local n = #t
    for i = n, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
end


function load_points()
    local points = {}
    local f = io.open('moonloader/ARCANEAIBOT/rute.txt', 'r')
    if not f then return points end
    for line in f:lines() do
        local x, y, z = line:match("{([%d%-%.]+),%s*([%d%-%.]+),%s*([%d%-%.]+)}")
        if x and y and z then
            table.insert(points, {
                x = tonumber(x),
                y = tonumber(y),
                z = tonumber(z)
            })
        end
    end
    f:close()

    shuffle(points)

    return points
end


function almostEqual(a, b, epsilon)
    return math.abs(a - b) < epsilon
end

function isBright(color)
    local r = bit.band(bit.rshift(color, 16), 0xFF)
    local g = bit.band(bit.rshift(color, 8), 0xFF)
    local b = bit.band(color, 0xFF)
    local brightness = 0.299 * r + 0.587 * g + 0.114 * b
    return brightness > 100
end

function detectDigit(segments)
    local segment_status = {}
    for name, id in pairs(segments) do
        if sampTextdrawIsExists(id) then
            local _, color = sampTextdrawGetBoxEnabledColorAndSize(id)
            local on = isBright(color)
            segment_status[name] = on and 1 or 0
        else
            segment_status[name] = 0
        end
    end

    if not segment_status.top or not segment_status.top_right or not segment_status.bottom_right or
       not segment_status.bottom or not segment_status.bottom_left or not segment_status.top_left or
       not segment_status.middle then
        segment_warning_shown = true
        return "?"
    else
        segment_warning_shown = false
    end

    local key = string.format(
        "%d%d%d%d%d%d%d",
        segment_status.top,
        segment_status.top_right,
        segment_status.bottom_right,
        segment_status.bottom,
        segment_status.bottom_left,
        segment_status.top_left,
        segment_status.middle
    )

    return digit_segments[key] or "?"
end

function checkTextdraws()
    local lineTextdraws = {}
    local longLines = {}

    for _, id in ipairs(tdIds) do
        if sampTextdrawIsExists(id) then
            local x, y = sampTextdrawGetPos(id)
            local letSizeX, letSizeY = sampTextdrawGetLetterSizeAndColor(id)

            if almostEqual(letSizeX, 0.60, 0.01) and almostEqual(letSizeY, -0.20, 0.01) then
                table.insert(lineTextdraws, {id = id, x = x, y = y})
            end

            if almostEqual(letSizeX, 0.60, 0.02) and almostEqual(math.abs(letSizeY), 1.10, 0.05) then
                table.insert(longLines, {id = id, x = x, y = y})
            end
        end
    end

    local thresholdX = 5.0

    local lineColumns = {}
    for _, td in ipairs(lineTextdraws) do
        local assigned = false
        for _, col in ipairs(lineColumns) do
            if math.abs(col.x - td.x) < thresholdX then
                table.insert(col.items, td)
                assigned = true
                break
            end
        end
        if not assigned then
            table.insert(lineColumns, {x = td.x, items = {td}})
        end
    end
    table.sort(lineColumns, function(a, b) return a.x < b.x end)
    for _, col in ipairs(lineColumns) do
        table.sort(col.items, function(a, b) return a.y < b.y end)
    end

    local longColumns = {}
    for _, td in ipairs(longLines) do
        local assigned = false
        for _, col in ipairs(longColumns) do
            if math.abs(col.x - td.x) < thresholdX then
                table.insert(col.items, td)
                assigned = true
                break
            end
        end
        if not assigned then
            table.insert(longColumns, {x = td.x, items = {td}})
        end
    end
    table.sort(longColumns, function(a, b) return a.x < b.x end)
    for _, col in ipairs(longColumns) do
        table.sort(col.items, function(a, b) return a.y < b.y end)
    end

    local digitsSegments = {segment_ids, segment_ids2, segment_ids3}

    for digitIndex = 1, 3 do
        local lineCol = lineColumns[digitIndex]
        local longCol1 = longColumns[(digitIndex - 1) * 2 + 1]
        local longCol2 = longColumns[(digitIndex - 1) * 2 + 2]

        local segments = digitsSegments[digitIndex]

        if lineCol and #lineCol.items >= 3 then
            segments.top = lineCol.items[1].id
            segments.middle = lineCol.items[2].id
            segments.bottom = lineCol.items[3].id
        else
            segments.top = lineCol and lineCol.items[1] and lineCol.items[1].id or nil
            segments.middle = lineCol and lineCol.items[2] and lineCol.items[2].id or nil
            segments.bottom = lineCol and lineCol.items[3] and lineCol.items[3].id or nil
        end

        if longCol1 and #longCol1.items >= 2 then
            segments.top_left = longCol1.items[1].id
            segments.bottom_left = longCol1.items[2].id
        else
            segments.top_left, segments.bottom_left = nil, nil
        end

        if longCol2 and #longCol2.items >= 2 then
            segments.top_right = longCol2.items[1].id
            segments.bottom_right = longCol2.items[2].id
        else
            segments.top_right, segments.bottom_right = nil, nil
        end
    end
end

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then return end
    while not isSampAvailable() do wait(0) end


    lua_thread.create(function()
        ensure_file_structure()
        data_base_connect()
    end)

    if isNavigating and infinity_run.v then
        memory.setint8(0xB7CEE4, 1)
    end

    sampRegisterChatCommand("arcbot", function()
        if loaded_yes then
            arcbot_GUI.v = not arcbot_GUI.v
        else
            sampAddChatMessage("{e2abff}(ARCANE AI BOT): {ff564a}Skripta je u procesu ucitavanja..", 0xFF4444)
        end
    end)

    local markerScanTimer = 0

    while true do
        wait(0)

        if loaded_yes and script_version ~= 1.0 then
            os.execute("start https://discord.gg/CHP3SyycaD")
            sampAddChatMessage("{e2abff}(ARCANE AI BOT): {ff564a}Skripta je zastarjela! Posjetite BIGBANG Discord za najnoviju verziju (ako postoji).", 0xFF4444)
            thisScript():unload()
        end
        

        imgui.Process = arcbot_GUI.v


        if isKeyJustPressed(VK_F4) then
            if loaded_yes then
                arcbot_GUI.v = not arcbot_GUI.v
            else
                sampAddChatMessage("{e2abff}(ARCANE AI BOT): {ff564a}Skripta je u procesu ucitavanja..", 0xFF4444)
            end
        end

        if isKeyJustPressed(VK_F5) and loaded_yes then
            isEnabled = false   
            isNavigating = false
            activePath = {}
            sampAddChatMessage("{e2abff}(ARCANE AI BOT): {ff564a}Navigacija zaustavljena.", 0xFF4444)
        end

        if isEnabled and auto_vfc.v then
            checkTextdraws()

            local digit1 = detectDigit(segment_ids)
            local digit2 = detectDigit(segment_ids2)
            local digit3 = detectDigit(segment_ids3)

            local full_code = digit1 .. digit2 .. digit3

            if digit1 ~= "?" and digit2 ~= "?" and digit3 ~= "?" then
                last_valid_code = full_code
            else
                last_valid_code = "Nepoznato"
            end
        end

        maxNeighborDistance = isCharInWater(PLAYER_PED) and 1.5 or 1.0

        local px, py, pz = getCharCoordinates(PLAYER_PED)
        local objects = getAllObjects()
        isTouchingObject = false

        for _, obj in ipairs(objects) do
            if isCharTouchingObject(PLAYER_PED, obj) then
                isTouchingObject = true
                break
            end
        end

        scan_for_new_markers()

        local tick = os.clock() * 1000
        local px, py, pz = getCharCoordinates(PLAYER_PED)

        local canjump = isNavigating and destination and is_on_straight_path({x = px, y = py}, destination, 2.0) and not isNearBazen(px, py, pz)

        if isNavigating and isRunning and destination and is_valid_path(activePath) and not isCharInWater(PLAYER_PED) then
            local distToDest = get_distance_2d(px, py, destination.x, destination.y)

            if distToDest >= 13.0 then
                
                if distToDest >= routeRadius then
                    local nextIndex = find_closest_future_point(px, py, 500)
                    if not nextIndex then
                        activePath = find_path({x=px, y=py, z=pz}, destination)
                        nextIndex = find_closest_future_point(px, py, 500)
                    end
                end

                if tick > jumpCooldown and not sampIsChatInputActive() and (os.clock() - navigationStartTime) >= 2 then
                    if jumpCount < maxJumps and canjump and jump_habit.v then
                        setGameKeyState(14, 255)
                        jumpCount = jumpCount + 1
                        jumpCooldown = tick + math.random(0, jumpIntervalMax)
                    else
                        jumpCooldown = tick + math.random(jumpIntervalMax, jumpIntervalMax)
                        jumpCount = 0
                    end
                end
            end

            if tick > ctrlCooldown and not sampIsChatInputActive() and  (os.clock() - navigationStartTime) >= 2 then
                if ctrlCount < maxCtrlPresses and punch_habit.v then
                    setGameKeyState(17, 255)
                    ctrlCount = ctrlCount + 1
                    ctrlCooldown = tick + math.random(0, ctrlIntervalMax) + math.random(0, 300)
                else
                    ctrlCooldown = tick + math.random(ctrlIntervalMax, ctrlIntervalMax + 4000) + math.random(1500, 4000)
                    ctrlCount = 0
                end
            end
        end

        if isNavigating and destination and get_distance_2d(px, py, destination.x, destination.y) < routeRadius then
            currentMarkerIndex = currentMarkerIndex + 1
            if activeMarkers[currentMarkerIndex] then
                destination = activeMarkers[currentMarkerIndex]
                activePath = find_path({x = px, y = py, z = pz}, destination)
            else
                restart_navigation()
            end
        end

        if isNavigating and not sampIsChatInputActive() and #activePath > 0 then
            local nextIndex = find_closest_future_point(px, py, 500)
            if not nextIndex then
                activePath = find_path({x=px, y=py, z=pz}, destination)
                nextIndex = find_closest_future_point(px, py, 500)
                if not nextIndex then
                    restart_navigation()
                end
            else
                local nextPoint = activePath[nextIndex]
                set_camera_heading(nextPoint.x, nextPoint.y)
                hodaj()

                if get_distance_2d(px, py, nextPoint.x, nextPoint.y) < routeRadius then
                    for i = 1, nextIndex do table.remove(activePath, 1) end
                    if #activePath == 0 then
                        restart_navigation()
                    end
                end
            end
        end

        local currentX, currentY = getCharCoordinates(PLAYER_PED)
        local distanceThreshold = isCharInWater(PLAYER_PED) and 8.0 or 3.0
        
        local inRetryTimeout = retryAttempted and (os.clock() - retryWaitStart < 2.0)
        
        if isNavigating and not sampIsChatInputActive() and isRunning and is_valid_path(activePath) and #activePath > 1 and

           (getDistanceBetweenCoords2d(currentX, currentY, lastX, lastY) < distanceThreshold or isTouchingObject) and
           not inRetryTimeout then
        
            if os.clock() - stuckTimer > 1.0 then
                stuckDuration = stuckDuration + (os.clock() - stuckTimer)
                stuckTimer = os.clock()
        
                local nextPoint = activePath[find_closest_future_point(px, py, 500)] or destination
                if nextPoint then
                    local heading = getCharHeading(PLAYER_PED)
                    local dirX, dirY = math.cos(heading), math.sin(heading)
                    local dx, dy = nextPoint.x - px, nextPoint.y - py
                    local cross = dirX * dy - dirY * dx
                    rotationDirection = cross < 0 and -128 or 255
                end
        
                if stuckDuration > maxStuckDuration then
                    if not retryAttempted then
                        sampAddChatMessage("{e2abff}(ARCANE AI BOT): {ffaa00}Bot je zapeo, pokusavam ponovo...", -1)
                        retryAttempted = true
                        retryWaitStart = os.clock()
                        restart_navigation() 
                        stuckDuration = 0
                    else
                        sampAddChatMessage("{e2abff}(ARCANE AI BOT): {ff564a}Bot je zapeo drugi put, navigacija zaustavljena.", -1)
                        isEnabled = false
                        isNavigating = false
                        activePath = {}
                        retryAttempted = false
                        retryWaitStart = 0
                    end
                end
            end
        else
            stuckTimer = os.clock()
            lastX, lastY = currentX, currentY
            stuckDuration = 0
            rotationDirection = 0

            if not inRetryTimeout then
                retryAttempted = false
                retryWaitStart = 0
            end
        end
        
    end
end


function distance(x1, y1, z1, x2, y2, z2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)
end

function scan_for_new_markers()
    local px, py, pz = getCharCoordinates(PLAYER_PED)

    for i = 0, markerCount - 1 do   
        local addr = markerBase + i * markerStep
        local x = representIntAsFloat(readMemory(addr, 4, false))
        local y = representIntAsFloat(readMemory(addr + 4, 4, false))
        local z = representIntAsFloat(readMemory(addr + 8, 4, false))

        if (x ~= 0.0 or y ~= 0.0 or z ~= 0.0)
            and distance(px, py, pz, x, y, z) < 400.0 then

            local exists = false
            for _, m in ipairs(activeMarkers) do
                if math.abs(m.x - x) < 0.01 and math.abs(m.y - y) < 0.01 and math.abs(m.z - z) < 0.01 then
                    exists = true
                    break
                end
            end

            if not exists then
                table.insert(activeMarkers, {x = x, y = y, z = z})

                if not isNavigating and isEnabled then
                    destination = activeMarkers[#activeMarkers]
                    currentMarkerIndex = #activeMarkers
                    activePath = find_path({x = px, y = py, z = pz}, destination)
                    if #activePath > 0 then
                        isNavigating = true
                        navigationStartTime = os.clock()
                    end
                end
            end
        end
    end
end

function update_markers()
    local px, py, pz = getCharCoordinates(PLAYER_PED)
    activeMarkers = {}

    for i = 0, markerCount - 1 do
        local addr = markerBase + i * markerStep
        local x = representIntAsFloat(readMemory(addr, 4, false))
        local y = representIntAsFloat(readMemory(addr + 4, 4, false))
        local z = representIntAsFloat(readMemory(addr + 8, 4, false))

        if (x ~= 0.0 or y ~= 0.0 or z ~= 0.0)
            and distance(px, py, pz, x, y, z) < 400.0 then

            table.insert(activeMarkers, {x = x, y = y, z = z})
        end
    end
end


-- BINARY HEAP
local BinaryHeap = {}
BinaryHeap.__index = BinaryHeap
function BinaryHeap.new() return setmetatable({ items = {} }, BinaryHeap) end
function BinaryHeap:push(node, f)
    table.insert(self.items, { node = node, f = f })
    self:_sift_up(#self.items)
end
function BinaryHeap:pop()
    if #self.items == 0 then return nil end
    local root = self.items[1]
    local last = table.remove(self.items)
    if #self.items > 0 then
        self.items[1] = last
        self:_sift_down(1)
    end
    return root.node
end
function BinaryHeap:is_empty() return #self.items == 0 end
function BinaryHeap:_sift_up(i)
    while i > 1 do
        local p = math.floor(i / 2)
        if self.items[p].f > self.items[i].f then
            self.items[p], self.items[i] = self.items[i], self.items[p]
            i = p
        else break end
    end
end
function BinaryHeap:_sift_down(i)
    local size = #self.items
    while true do
        local left, right = 2*i, 2*i+1
        local smallest = i
        if left <= size and self.items[left].f < self.items[smallest].f then smallest = left end
        if right <= size and self.items[right].f < self.items[smallest].f then smallest = right end
        if smallest == i then break end
        self.items[i], self.items[smallest] = self.items[smallest], self.items[i]
        i = smallest
    end
end

function get_distance_2d(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end
function set_camera_heading(x, y)
    local cx, cy = getActiveCameraCoordinates()
    setCameraPositionUnfixed(0.0, (getHeadingFromVector2d(x - cx, y - cy) - 90.0) / 57.2957795)
end

function find_closest_future_point(px, py, range)
    local minDist, bestIndex = math.huge, nil
    for i = 1, math.min(#activePath, range) do
        local pt = activePath[i]
        local dist = get_distance_2d(px, py, pt.x, pt.y)
        if dist < minDist and dist <= maxNeighborDistance * 2 then
            minDist, bestIndex = dist, i
        end
    end
    return bestIndex
end
function track_node_usage(node)
    local key = string.format("%.3f:%.3f", node.x, node.y)
    nodeUsage[key] = (nodeUsage[key] or 0) + 1
end




function find_path(start, goal)
    local function point_key(p)
        return string.format("%.3f:%.3f", p.x, p.y)
    end

    local function heuristic(a, b)
        local dx, dy = a.x - b.x, a.y - b.y
        local base = dx * dx + dy * dy
        return base * (1.0 + math.random(-5, 5) * 0.005)
    end

    local function are_paths_similar(path1, path2)
        if #path1 ~= #path2 then return false end
        for i = 1, #path1 do
            local dx = path1[i].x - path2[i].x
            local dy = path1[i].y - path2[i].y
            if (dx * dx + dy * dy) > 1.0 then 
                return false
            end
        end
        return true
    end

    local function try_path_with_distance(distance, jitter)
        maxNeighborDistance = distance

        local openHeap = BinaryHeap.new()
        local cameFrom = {}
        local gScore = {}
        local fScore = {}
        local openSet = {}
        local modifiedStart = {
            x = start.x + (jitter and math.random(-100, 100) * 0.01 or 0),
            y = start.y + (jitter and math.random(-100, 100) * 0.01 or 0)
        }

        local startKey = point_key(modifiedStart)
        gScore[startKey] = 0
        fScore[startKey] = heuristic(modifiedStart, goal)
        openHeap:push(modifiedStart, fScore[startKey])
        openSet[startKey] = true

        while not openHeap:is_empty() do
            local current = openHeap:pop()
            local currentKey = point_key(current)
            openSet[currentKey] = nil

            if heuristic(current, goal) < routeRadius * 2 then
                return reconstruct_path(cameFrom, current), true
            end

            local neighbors = get_neighbors(current)

            for i = #neighbors, 2, -1 do
                local j = math.random(i)
                neighbors[i], neighbors[j] = neighbors[j], neighbors[i]
            end

            for _, neighbor in ipairs(neighbors) do
                if math.random() < 0.9 then
                    local nKey = point_key(neighbor)
                    local tentative_g = gScore[currentKey] + heuristic(current, neighbor)

                    if tentative_g < (gScore[nKey] or math.huge) then
                        cameFrom[nKey] = current
                        gScore[nKey] = tentative_g
                        fScore[nKey] = tentative_g + heuristic(neighbor, goal)
                        if not openSet[nKey] then
                            openHeap:push(neighbor, fScore[nKey])
                            openSet[nKey] = true
                        end
                    end
                end
            end
        end

        return {}, false
    end

    local path1, success1 = try_path_with_distance(1.0, false)
    if success1 then return path1 end

    local path2, success2 = try_path_with_distance(1.5, true)
    if success2 and not are_paths_similar(path1, path2) then
        return path2
    end

    restart_navigation()
    return {}
end



function is_valid_path(path)
    return path and #path > 0
end
function reconstruct_path(cameFrom, current)
    local path = {current}
    local k = string.format("%.3f:%.3f", current.x, current.y)
    while cameFrom[k] do
        current = cameFrom[k]
        k = string.format("%.3f:%.3f", current.x, current.y)
        table.insert(path, 1, current)
    end
    return path
end
function shuffle(t)
    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
end
function get_neighbors(node)
    local neighbors = {}
    local gx = math.floor(node.x / gridCellSize)
    local gy = math.floor(node.y / gridCellSize)
    local range = math.ceil(maxNeighborDistance / gridCellSize)

    for dx = -range, range do
        for dy = -range, range do
            local cell = spatialGrid[gx + dx] and spatialGrid[gx + dx][gy + dy]
            if cell then
                for _, pt in ipairs(cell) do
                    local dist = get_distance_2d(node.x, node.y, pt.x, pt.y)
                    if dist > 0.01 and dist <= maxNeighborDistance then
                        table.insert(neighbors, pt)
                    end
                end
            end
        end
    end

    return neighbors
end

function get_direction_vector(start, goal)
    local dx = goal.x - start.x
    local dy = goal.y - start.y
    local length = math.sqrt(dx^2 + dy^2)
    return {x = dx / length, y = dy / length} 
end
function is_on_straight_path(current, destination, tolerance)
    local direction = get_direction_vector(current, destination)
    local playerDirection = {x = math.cos(getCharHeading(PLAYER_PED)), y = math.sin(getCharHeading(PLAYER_PED))}

    local dotProduct = direction.x * playerDirection.x + direction.y * playerDirection.y
    local angle = math.acos(dotProduct) * (180 / math.pi) 

    return angle <= tolerance
end
function insert_into_grid(pt)
    local gx = math.floor(pt.x / gridCellSize)
    local gy = math.floor(pt.y / gridCellSize)
    spatialGrid[gx] = spatialGrid[gx] or {}
    spatialGrid[gx][gy] = spatialGrid[gx][gy] or {}
    table.insert(spatialGrid[gx][gy], pt)
end
function build_spatial_index()
    for _, pt in ipairs(routePoints) do
        insert_into_grid(pt)
    end
end



function hodaj()
    local px, py, pz = getCharCoordinates(PLAYER_PED)
    if isNavigating and destination then
        local distToDest = get_distance_2d(px, py, destination.x, destination.y)
        if distToDest <= routeRadius then
            setGameKeyState(1, 0)   
            setGameKeyState(16, 0)  
            isRunning = false       
            return
        end
    end

    setGameKeyState(1, -128)

    local shouldRun = true
    for _, marker in ipairs(activeMarkers) do
        local distToMarker = get_distance_2d(px, py, marker.x, marker.y)
        if distToMarker <= 5.0 then
            shouldRun = false
            break
        end
    end

    if shouldRun then
        setGameKeyState(16, 255) 
        isRunning = true
    else
        setGameKeyState(16, 0)   
        isRunning = false
    end

    if rotationDirection ~= 0 then
        setGameKeyState(0, rotationDirection)
    else
        setGameKeyState(0, 0) 
    end
end


function restart_navigation()
    isNavigating = false
    activePath = {}
    activeMarkers = {}
    currentMarkerIndex = 1

    if #activeMarkers == 0 then
        return
    end

    local px, py, pz = getCharCoordinates(PLAYER_PED)
    destination = activeMarkers[currentMarkerIndex]
    activePath = find_path({x = px, y = py, z = pz}, destination)
end
-- AUTOVERIFICATION
function sampev.onShowDialog(id, style, title, label_button1, label_button0, text)
    if id == 252 and isEnabled and auto_vfc.v and last_valid_code then
        lua_thread.create(function()
            wait(400)
            sampSendDialogResponse(252, 1, _, last_valid_code)
            sampAddChatMessage("{e2abff}(ARCANE AI BOT):{FFFFFF}: {5e5e5e}Unesen kod za verifikaciju: {e2abff}" .. last_valid_code, 0xFFFFFFFF)
        end)
        return false
    end
end

function sampev.onServerMessage(color, text)
    if isEnabled and text:find("Unijeli ste pogresan kod!") then
        lua_thread.create(function()
            wait(2000) 
            sampSendChat("/vf")
        end)
    end
end

function imgui.OnDrawFrame()
    if not arcbot_GUI.v then return end

    imgui.SetNextWindowPos(imgui.ImVec2((screenW - windowWidth) / 2, (screenH - windowHeight) / 2), imgui.Cond.Always)
    imgui.SetNextWindowSize(imgui.ImVec2(windowWidth, windowHeight), imgui.Cond.Always)

    if imgui.Begin(u8"ARCANE MARKER AI BOT", arcbot_GUI, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar) then
        imgui.SetWindowFontScale(1.4)

        local title = u8"ARCANE AI MARKER BOT"
        local title_size = imgui.CalcTextSize(title)
        imgui.SetCursorPosX((windowWidth - title_size.x) / 2)
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.9, 0.4, 0.8, 1.0))
        imgui.Text(title)
        imgui.PopStyleColor()

        imgui.SetWindowFontScale(0.85)
        imgui.Spacing()

        local subtitle = u8"#freepalestine"
        local subtitle_size = imgui.CalcTextSize(subtitle)
        imgui.SetCursorPos(imgui.ImVec2((windowWidth - subtitle_size.x) / 2 + 60, 25))
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.0, 0.0, 0.0, 1.0))
        imgui.Text(subtitle)
        imgui.PopStyleColor()

        imgui.SetWindowFontScale(1.0)
        imgui.PushItemWidth(windowWidth - 40)
        imgui.Spacing()

        imgui.Columns(2, nil, false)
        imgui.SetColumnWidth(-1, windowWidth - 60)

        local offset = 25
        imgui.SetCursorPosX(imgui.GetCursorPosX() + offset)
        imgui.Text(u8"AutoVFC V2")
        imgui.NextColumn()
        imgui.Checkbox("##vfc", auto_vfc)
        if imgui.IsItemHovered() then
            imgui.BeginTooltip()
            imgui.Text(u8"Automatska verifikacija ukoliko se pojavi. /vf")
            imgui.EndTooltip()
        end
        imgui.NextColumn()

        imgui.SetCursorPosX(imgui.GetCursorPosX() + offset)
        imgui.Text(u8"JumpHabit")
        imgui.NextColumn()
        imgui.Checkbox("##jump", jump_habit)
        if imgui.IsItemHovered() then
            imgui.BeginTooltip()
            imgui.Text(u8"Bot ce povremeno skakati kako bi izgledao prirodnije.")
            imgui.EndTooltip()
        end
        imgui.NextColumn()

        imgui.SetCursorPosX(imgui.GetCursorPosX() + offset)
        imgui.Text(u8"PunchHabit")
        imgui.NextColumn()
        imgui.Checkbox("##punch", punch_habit)
        if imgui.IsItemHovered() then
            imgui.BeginTooltip()
            imgui.Text(u8"Bot ce povremeno udaraiti sakom kako bi izgledao prirodnije.")
            imgui.EndTooltip()
        end
        imgui.NextColumn()


        imgui.SetCursorPosX(imgui.GetCursorPosX() + offset)
        imgui.Text(u8"Infinity Run")
        imgui.NextColumn()
        imgui.Checkbox("##infinity_run", infinity_run)
        if imgui.IsItemHovered() then
            imgui.BeginTooltip()
            imgui.Text(u8"Dobivate beskonacni sprint, bez animacije umora.")
            imgui.EndTooltip()
        end

        imgui.NextColumn()

        imgui.SetCursorPosX(imgui.GetCursorPosX() + offset)
        imgui.Text(u8"Panic Button (F5)")
        imgui.NextColumn()
        imgui.Checkbox("##panic", panic_enabled)
        if imgui.IsItemHovered() then
            imgui.BeginTooltip()
            imgui.Text(u8"Pritiskom na tipku F5 bot se momentalno gasi.")
            imgui.EndTooltip()
        end
        imgui.Columns(1)

        imgui.Spacing()
        imgui.PopItemWidth()

        local btn_w, btn_h = 120, 35
        local total_w = btn_w * 2 + 20
        imgui.SetCursorPosX((windowWidth - total_w) / 2)

        local skipStartLogic = false
        if imgui.Button(u8"START", imgui.ImVec2(btn_w, btn_h)) then
            if isNavigating then
                sampAddChatMessage("{e2abff}(ARCANE AI BOT): {ffd391}Navigacija je vec pokrenuta.", -1)
                skipStartLogic = true
            end
            if not skipStartLogic then
                routePoints = load_points()
                build_spatial_index()

                isEnabled = true
                activeMarkers = {}
                currentMarkerIndex = 1
                update_markers()

                local tick = os.clock() * 1000
                jumpCooldown = tick + math.random(0, jumpIntervalMax)
                jumpCount = 0
                ctrlCooldown = tick + math.random(0, ctrlIntervalMax)
                ctrlCount = 0

                if #activeMarkers == 0 then
                    sampAddChatMessage("{e2abff}(ARCANE AI BOT): {ff564a}Nema validnih markera na koje BOT moze doci.", -1)
                    skipStartLogic = true
                end

                if not skipStartLogic then
                    local px, py, pz = getCharCoordinates(PLAYER_PED)
                    destination = activeMarkers[currentMarkerIndex]
                    activePath = find_path({x = px, y = py, z = pz}, destination)

                    if #activePath > 0 then
                        isNavigating = true
                        navigationStartTime = os.clock()
                        sampAddChatMessage("{e2abff}(ARCANE AI BOT): {5e5e5e}Navigacija pokrenuta.", -1)
                    else
                        sampAddChatMessage("{e2abff}(ARCANE AI BOT): {ff564a}Ne mogu pronaci put do prvog markera.", -1)
                    end
                end
            end
        end

        imgui.SameLine()

        local skipStopLogic = false
        if imgui.Button(u8"STOP", imgui.ImVec2(btn_w, btn_h)) then
            if not isNavigating then
                sampAddChatMessage("{e2abff}(ARCANE AI BOT): {ffd391}Navigacija nije pokrenuta.", -1)
                skipStopLogic = true
            end

            if not skipStopLogic then
                isEnabled = false
                isNavigating = false
                activePath = {}
                sampAddChatMessage("{e2abff}(ARCANE AI BOT): {ff564a}Navigacija zaustavljena.", -1)
            end
        end

        imgui.Spacing()
        imgui.SetWindowFontScale(0.85)

        local cursor_pos = imgui.GetCursorPos()
        local footer = u8"bigbangcommunity"
        local footer_size = imgui.CalcTextSize(footer)
        imgui.SetCursorPos(imgui.ImVec2((windowWidth - footer_size.x) / 2, cursor_pos.y))
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.7, 0.4, 0.75, 1.0))
        imgui.Text(footer)
        imgui.PopStyleColor()

        imgui.End()
    end
end


function GUI_STYLE_LIGHT()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col

    colors[clr.WindowBg]             = imgui.ImVec4(0.90, 0.85, 0.95, 0.95)
    colors[clr.Text]                 = imgui.ImVec4(0.15, 0.10, 0.25, 1.00)
    colors[clr.TextDisabled]        = imgui.ImVec4(0.5, 0.4, 0.6, 1.0)
    colors[clr.FrameBg]             = imgui.ImVec4(0.85, 0.65, 0.90, 0.85)
    colors[clr.FrameBgHovered]      = imgui.ImVec4(0.95, 0.75, 1.00, 1.00)
    colors[clr.FrameBgActive]       = imgui.ImVec4(0.90, 0.60, 0.95, 1.00)
    colors[clr.Button]              = imgui.ImVec4(0.88, 0.55, 0.92, 1.00)
    colors[clr.ButtonHovered]       = imgui.ImVec4(1.00, 0.70, 1.00, 1.00)
    colors[clr.ButtonActive]        = imgui.ImVec4(0.78, 0.45, 0.85, 1.00)
    colors[clr.CheckMark]           = imgui.ImVec4(0.30, 0.10, 0.40, 1.00)
    colors[clr.Separator]           = imgui.ImVec4(0.75, 0.50, 0.85, 0.8)
    colors[clr.TitleBg]             = imgui.ImVec4(0.70, 0.50, 0.85, 1.00)
    colors[clr.TitleBgActive]       = imgui.ImVec4(0.85, 0.60, 1.00, 1.00)
    colors[clr.TitleBgCollapsed]    = imgui.ImVec4(0.65, 0.45, 0.80, 0.90)
    colors[clr.ScrollbarBg]         = imgui.ImVec4(0.85, 0.80, 0.95, 0.85)
    colors[clr.ScrollbarGrab]       = imgui.ImVec4(0.85, 0.55, 0.90, 1.00)
    colors[clr.ScrollbarGrabHovered]= imgui.ImVec4(0.95, 0.65, 1.00, 1.00)
    colors[clr.ScrollbarGrabActive] = imgui.ImVec4(1.00, 0.75, 1.00, 1.00)
    colors[clr.Border]              = imgui.ImVec4(0.60, 0.30, 0.75, 0.8)
    colors[clr.PopupBg]             = imgui.ImVec4(0.95, 0.85, 1.00, 0.9)

    style.WindowRounding = 10.0
    style.FrameRounding = 6.0
    style.GrabRounding = 6.0
    style.ItemSpacing = imgui.ImVec2(16, 12)
    style.ItemInnerSpacing = imgui.ImVec2(12, 6)
end


GUI_STYLE_LIGHT()


function onScriptTerminate(script, quitGame)
    saveSettings()
end  