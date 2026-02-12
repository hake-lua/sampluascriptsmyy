-- BIGBANG MENU V2 OUTDATED
-- Uzasno napisan kod, mislim sto je i uredu. Ucio sam se ovde.
-- Vecina skripti je patchano na novijim serverima.


script_author("Hake")
require "lib.moonloader"
sampev = require "samp.events"

imgui = require 'imgui' 
mimgui = require('mimgui')
res, encoding = pcall(require, 'encoding')
memory = require 'memory'
samem = require 'SAMemory'
samem.require 'CTrain'
sampfuncs = require 'sampfuncs'
raknet = require 'samp.raknet'
require 'samp.synchronization'
ffi = require 'ffi'
key = require 'vkeys'
getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)
font_flag = require('moonloader').font_flag
request = require("luajit-request")
dlstatus = require('moonloader').download_status
bit = require("bit")
addons = require "imgui_addons"
Matrix3X3 = require "matrix3x3"
Vector3D = require "vector3d"

local discordLib_rpc = "moonloader\\lib\\discord-rpc.dll"

encoding.default = 'CP1251'
u8 = encoding.UTF8

blacklisted = false
verzija_moda = '2.0'

Monitor_GUI = imgui.ImBool(false)
Bigbang_GUI = imgui.ImBool(false)
statusbar_GUI = imgui.ImBool(true)

rVankaEnabled = imgui.ImBool(false)
crasherEnabled = imgui.ImBool(false)
njDestroyerEnabled = imgui.ImBool(false)
angleShotEnabled = imgui.ImBool(false)
carThrowerEnabled = imgui.ImBool(false)
streamLaggerEnabled = imgui.ImBool(false)
spinCrusherEnabled = imgui.ImBool(false)

local rVankaSafeMode = imgui.ImBool(true)
local rVankaSpeed = imgui.ImFloat(0.5)
local rVankaIntensity = imgui.ImFloat(0.05)

local crasherRange = imgui.ImFloat(20.0)
local crasherDepth = imgui.ImFloat(15.0)

local njDestroyerMinRange = imgui.ImFloat(1.0)
local njDestroyerMaxRange = imgui.ImFloat(250.0)

local angleshot_intensity = imgui.ImFloat(0.0)
local angleshot_speed = imgui.ImFloat(0.65)

local throwIntensity = imgui.ImFloat(3.5)
local throwRange = imgui.ImFloat(100.0)

laggerDelay = imgui.ImFloat(150.0)
laggerRange = imgui.ImFloat(200.0)
local lagger_found, lagger_veh
local slagger_act = false

scrusherSpeedVertical = imgui.ImFloat(1.0)
scrusherSpeedHorizontal = imgui.ImFloat(1.0)

local godModeEnabled = imgui.ImBool(false)

local shaddowbladeEnabled = imgui.ImBool(false)
local InfinityRunEnabled = imgui.ImBool(false)
local showNamesEnabled = imgui.ImBool(false)
local derbyModeEnabled = imgui.ImBool(false)
local airbrakeEnabled = imgui.ImBool(false)
local terminatorEnabled = imgui.ImBool(false)

local InfinityFuelEnabled = imgui.ImBool(false)
local turboHackEnabled = imgui.ImBool(false)
local entercrasherEnabled = imgui.ImBool(false)
local roofFlipEnabled = imgui.ImBool(false)

local espEnabled = imgui.ImBool(false)
local vehRenderEnabled = imgui.ImBool(false)
local camhackEnabled = imgui.ImBool(false)
local ncolPlayersEnabled = imgui.ImBool(false)
local trailersnapEnabled = imgui.ImBool(false)
local clickwarpEnabled = imgui.ImBool(false)
local fisheyeEnabled = imgui.ImBool(false)

local methodslagger = imgui.ImBool(false)
local quaternionEnabled = imgui.ImBool(true)
local reloadanytimeEnabled = imgui.ImBool(false)

local playerMonitorEnabled = imgui.ImBool(false)
local nostunEnabled = imgui.ImBool(false)

local resyncEnabled = imgui.ImBool(false)
local wphackbypEnabled = imgui.ImBool(false)


local PlayerRPCsEnabled = imgui.ImBool(false)
local VehicleRPCsEnabled = imgui.ImBool(false)
local WorldRPCsEnabled = imgui.ImBool(false)
local SessionRPCsEnabled = imgui.ImBool(false)
local EventRPCsEnabled = imgui.ImBool(false)
local wphackbypEnabled = imgui.ImBool(false)
OtherRPCsEnabled = imgui.ImBool(false) 

local settingsVisible = imgui.ImBool(false)
local subscriptionVisible = imgui.ImBool(false)


local weaponID = imgui.ImFloat(24)  
local vvehicleID = imgui.ImFloat(411)  

local posxStatusBar = imgui.ImFloat(1746.0)
local posyStatusBar = imgui.ImFloat(386.0)

local activeMode = imgui.ImInt(0)
local tabNames = { "Basic", "Rvanka InCar", "Trailer Crasher", "NJ Destroyer", "Angle Shot", "Car Thrower", "Stream Lagger", "Spin Crusher"}


local lastGivenWeaponID = nil
local weaponIDValue
local resync_packet = 0

local vcar_carCreated = false 


last_time = os.clock()
frame_count = 0
fps_total = 0

rangle_scrusher = 0 

local spincrusher_VEHICLETARGET
local spincrusher_SEARCHTARGET 
local spincrusher_STATE = false
local spincrusher_ATTACHED = false
local spincrusher_GUICIRCLE = mimgui.new.bool(false)



font_clickwarp = nil
font2_clickwarp = nil
cursorEnabled_clickwarp = false
pointMarker_clickwarp = nil



local ScreenSize = {getScreenResolution()}

local var = {
    ['playermonitor'] = {}
}

local players = {}
local Fontimgui = imgui.ImBuffer('', 1000)
local reasons = {
    [0] = 'kick/ban',
    [1] = '/q',
    [2] = 'crash'
}

local ChangePos = false

if not doesDirectoryExist(getWorkingDirectory()..'\\BIGBANG2') then
    createDirectory(getWorkingDirectory()..'\\BIGBANG2')
end

if not doesFileExist(getWorkingDirectory()..'/BIGBANG2/playermonitor.json') then                                   
    local File = io.open(getWorkingDirectory()..'/BIGBANG2/playermonitor.json',"r");
    if File == nil then 
        local table = {}
        local encodetable = encodeJson(table)
        File = io.open(getWorkingDirectory()..'/BIGBANG2/playermonitor.json',"w"); 
        File:write(encodetable)
        File:flush()
        File:close()
    end
end

local json = io.open(getWorkingDirectory()..'/BIGBANG2/playermonitor.json',"r")
local file = json:read("*a")
var['playermonitor'] = decodeJson(file)
json:close() 

function load_nill_value_in_json()
    if var['playermonitor']['align'] == nil then
        var['playermonitor'] = {
            ['posX'] = 1903,
            ['posY'] = 796,
            ['size'] = 10,
            ['sizeList'] = 14,
            ['my_font'] = 'Arial',
            ['align'] = 3,
        }
    end
    if var['playermonitor']['screen'] == nil then
        var['playermonitor']['screen'] = false
        SaveJSON('playermonitor', var['playermonitor'])  
    end
end

local nameTagActive = false

local rvnk_speed = 0
local rvnk_targetId = -1
local rvanka_nop = false

local stun_anims = {'DAM_armL_frmBK', 'DAM_armL_frmFT', 'DAM_armL_frmLT', 'DAM_armR_frmBK', 'DAM_armR_frmFT', 'DAM_armR_frmRT', 'DAM_LegL_frmBK', 'DAM_LegL_frmFT', 'DAM_LegL_frmLT', 'DAM_LegR_frmBK', 'DAM_LegR_frmFT', 'DAM_LegR_frmRT', 'DAM_stomach_frmBK', 'DAM_stomach_frmFT', 'DAM_stomach_frmLT', 'DAM_stomach_frmRT'}

local smooth = 60.0
local radius = 5.0

local arbrk_speed_player = 1.1
local arbrk_speed_vehicle = 1.1
local arbrk_speed_passenger = arbrk_speed_vehicle

local arbrk_speed_player_sync = 0.2
local arbrk_speed_vehicle_sync = 0.2
local arbrk_speed_passenger_sync = 0.2

local arbrk_active = false
local arbrk_coords = {0.0, 0.0, 0.0}

local trgcX, trgcY, trgcZ = 1, 1, 1

local tp_active = false
local tp_distance = 175
local tp_waiting = 1
local tp_percent = 0
local tp_incar = false

local crasher_vehid = -1
local crasher_lastSync = 0
local crasher_syncCooldown = 1500

local njdestroy_bool, njdestroy_nop, njdestroy_altDown,njdestroy_target_vehicle = false, false, false,nil

local angleshot_act = false
local angleshot_cspeed = 0
local angleshot_lastspeed = 0

local player_vehicle_sph = samem.cast('CVehicle **', samem.player_vehicle)
local prev_time_sph = 0


ffi.cdef[[
    typedef struct DiscordRichPresence {
        const char* state;
        const char* details;
        int64_t startTimestamp;
        int64_t endTimestamp;
        const char* largeImageKey;
        const char* largeImageText;
        const char* smallImageKey;
        const char* smallImageText;
        const char* partyId;
        const char *button1_label, *button1_url;
        const char *button2_label, *button2_url;
        int partySize;
        int partyMax;
        int partyPrivacy;
        const char* matchSecret;
        const char* joinSecret;
        const char* spectateSecret;
        int8_t instance;
    } DiscordRichPresence;

    typedef struct DiscordEventHandlers {
        void* ready;
        void* disconnected;
        void* errored;
        void* joinGame;
        void* spectateGame;
        void* joinRequest;
    } DiscordEventHandlers;

    void Discord_Initialize(const char* applicationId, DiscordEventHandlers* handlers, int autoRegister, const char* optionalSteamId);
    void Discord_UpdatePresence(const DiscordRichPresence* presence);
    void Discord_ClearPresence(void);
    void Discord_Shutdown(void);
]]


discord_rpc = ffi.load(discordLib_rpc)

handlers_rpc = ffi.new("DiscordEventHandlers")
presence_rpc = ffi.new("DiscordRichPresence")


ffi.cdef[[
    typedef struct {
        float x;
        float y;
        float z;
    } CVector;
]]
local getPositionToOpenCarDoor = ffi.cast('CVector*(__cdecl*)(CVector* out, void* vehicle, int doorId)', 0x64E740)


local my_font = renderCreateFont('Arial', 11, font_flag.BORDER + font_flag.SHADOW + font_flag.BOLD)
local dkill_procces = false
local dkill_victimid = nil
local dkill_victimcarid = nil
local dkill_victimkilled = false


local blacklistovaniServeri = {}
whitelistovaniServeri = {}
local RPC = {}



font_render = renderCreateFont('Arial', 11, font_flag.SHADOW + font_flag.BOLD)
cars_render = {
"Landstalker", "Bravura", "Buffalo", "Linerunner", "Pereniel", "Sentinel", "Dumper", "Firetruck", "Trashmaster", "Stretch", "Manana", "Infernus", "Voodoo", "Pony",
"Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam", "Esperanto", "Taxi", "Washington", "Bobcat", "Mr Whoopee", "BF Injection", "Hunter", "Premier", "Enforcer",
"Securicar", "Banshee", "Predator", "Bus", "Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach", "Cabbie", "Stallion", "Rumpo", "RC Bandit",
"Romero", "Packer", "Monster Truck", "Admiral", "Squalo", "Seasparrow", "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder", "Reefer", "Tropic", "Flatbed", "Yankee",
"Caddy", "Solair", "Berkley's RC Van", "Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron", "RC Raider", "Glendale", "Oceanic", "Sanchez", "Sparrow", "Patriot",
"Quad", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR-350", "Walton", "Regina", "Comet", "BMX", "Burrito", "Camper", "Marquis", "Baggage", "Dozer",
"Maverick", "News Chopper", "Rancher", "FBI Rancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking", "Blista Compact", "Police Maverick", "Boxville",
"Benson", "Mesa", "RC Goblin", "Hotring Racer", "Hotring Racer", "Bloodring Banger", "Rancher", "Super GT", "Elegant", "Journey", "Bike", "Mountain Bike", "Beagle",
"Cropdust", "Stunt", "Tanker", "RoadTrain", "Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra", "FCR-900", "NRG-500", "HPV1000", "Cement Truck", "Tow Truck",
"Fortune", "Cadrona", "FBI Truck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer", "Remington", "Slamvan", "Blade", "Freight", "Streak", "Vortex",
"Vincent", "Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder", "Primo", "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada",
"Yosemite", "Windsor", "Monster Truck", "Monster Truck", "Uranus", "Jester", "Sultan", "Stratum", "Elegy", "Raindance", "RC Tiger", "Flash", "Tahoma",
"Savanna", "Bandito", "Freight", "Trailer", "Kart", "Mower", "Duneride", "Sweeper", "Broadway", "CarShot", "AT-400", "DFT-30", "Huntley", "Stafford", "BF-400",
"Newsvan", "Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club", "Trailer", "Trailer", "Andromada", "Dodo", "RC Cam", "Launch", "Police Car (LS)",
"Police Car (SF)", "Police Car (LV)", "Police Ranger", "Picador", "S.W.A.T. Van", "Alpha", "Phoenix", "Glendale", "Sadler", "Luggage Trailer", "Luggage Trailer",
"Stair Trailer", "Boxville", "Farm Plow", "Utility Trailer"
}
render_colors = {
0x000000FF, 0xF5F5F5FF, 0x2A77A1FF, 0x840410FF, 0x263739FF, 0x86446EFF, 0xD78E10FF, 0x4C75B7FF, 0xBDBEC6FF, 0x5E7072FF,
0x46597AFF, 0x656A79FF, 0x5D7E8DFF, 0x58595AFF, 0xD6DAD6FF, 0x9CA1A3FF, 0x335F3FFF, 0x730E1AFF, 0x7B0A2AFF, 0x9F9D94FF,
0x3B4E78FF, 0x732E3EFF, 0x691E3BFF, 0x96918CFF, 0x515459FF, 0x3F3E45FF, 0xA5A9A7FF, 0x635C5AFF, 0x3D4A68FF, 0x979592FF,
0x421F21FF, 0x5F272BFF, 0x8494ABFF, 0x767B7CFF, 0x646464FF, 0x5A5752FF, 0x252527FF, 0x2D3A35FF, 0x93A396FF, 0x6D7A88FF,
0x221918FF, 0x6F675FFF, 0x7C1C2AFF, 0x5F0A15FF, 0x193826FF, 0x5D1B20FF, 0x9D9872FF, 0x7A7560FF, 0x989586FF, 0xADB0B0FF,
0x848988FF, 0x304F45FF, 0x4D6268FF, 0x162248FF, 0x272F4BFF, 0x7D6256FF, 0x9EA4ABFF, 0x9C8D71FF, 0x6D1822FF, 0x4E6881FF,
0x9C9C98FF, 0x917347FF, 0x661C26FF, 0x949D9FFF, 0xA4A7A5FF, 0x8E8C46FF, 0x341A1EFF, 0x6A7A8CFF, 0xAAAD8EFF, 0xAB988FFF,
0x851F2EFF, 0x6F8297FF, 0x585853FF, 0x9AA790FF, 0x601A23FF, 0x20202CFF, 0xA4A096FF, 0xAA9D84FF, 0x78222BFF, 0x0E316DFF,
0x722A3FFF, 0x7B715EFF, 0x741D28FF, 0x1E2E32FF, 0x4D322FFF, 0x7C1B44FF, 0x2E5B20FF, 0x395A83FF, 0x6D2837FF, 0xA7A28FFF,
0xAFB1B1FF, 0x364155FF, 0x6D6C6EFF, 0x0F6A89FF, 0x204B6BFF, 0x2B3E57FF, 0x9B9F9DFF, 0x6C8495FF, 0x4D8495FF, 0xAE9B7FFF,
0x406C8FFF, 0x1F253BFF, 0xAB9276FF, 0x134573FF, 0x96816CFF, 0x64686AFF, 0x105082FF, 0xA19983FF, 0x385694FF, 0x525661FF,
0x7F6956FF, 0x8C929AFF, 0x596E87FF, 0x473532FF, 0x44624FFF, 0x730A27FF, 0x223457FF, 0x640D1BFF, 0xA3ADC6FF, 0x695853FF,
0x9B8B80FF, 0x620B1CFF, 0x5B5D5EFF, 0x624428FF, 0x731827FF, 0x1B376DFF, 0xEC6AAEFF, 0x000000FF,
0x177517FF, 0x210606FF, 0x125478FF, 0x452A0DFF, 0x571E1EFF, 0x010701FF, 0x25225AFF, 0x2C89AAFF, 0x8A4DBDFF, 0x35963AFF,
0xB7B7B7FF, 0x464C8DFF, 0x84888CFF, 0x817867FF, 0x817A26FF, 0x6A506FFF, 0x583E6FFF, 0x8CB972FF, 0x824F78FF, 0x6D276AFF,
0x1E1D13FF, 0x1E1306FF, 0x1F2518FF, 0x2C4531FF, 0x1E4C99FF, 0x2E5F43FF, 0x1E9948FF, 0x1E9999FF, 0x999976FF, 0x7C8499FF,
0x992E1EFF, 0x2C1E08FF, 0x142407FF, 0x993E4DFF, 0x1E4C99FF, 0x198181FF, 0x1A292AFF, 0x16616FFF, 0x1B6687FF, 0x6C3F99FF,
0x481A0EFF, 0x7A7399FF, 0x746D99FF, 0x53387EFF, 0x222407FF, 0x3E190CFF, 0x46210EFF, 0x991E1EFF, 0x8D4C8DFF, 0x805B80FF,
0x7B3E7EFF, 0x3C1737FF, 0x733517FF, 0x781818FF, 0x83341AFF, 0x8E2F1CFF, 0x7E3E53FF, 0x7C6D7CFF, 0x020C02FF, 0x072407FF,
0x163012FF, 0x16301BFF, 0x642B4FFF, 0x368452FF, 0x999590FF, 0x818D96FF, 0x99991EFF, 0x7F994CFF, 0x839292FF, 0x788222FF,
0x2B3C99FF, 0x3A3A0BFF, 0x8A794EFF, 0x0E1F49FF, 0x15371CFF, 0x15273AFF, 0x375775FF, 0x060820FF, 0x071326FF, 0x20394BFF,
0x2C5089FF, 0x15426CFF, 0x103250FF, 0x241663FF, 0x692015FF, 0x8C8D94FF, 0x516013FF, 0x090F02FF, 0x8C573AFF, 0x52888EFF,
0x995C52FF, 0x99581EFF, 0x993A63FF, 0x998F4EFF, 0x99311EFF, 0x0D1842FF, 0x521E1EFF, 0x42420DFF, 0x4C991EFF, 0x082A1DFF,
0x96821DFF, 0x197F19FF, 0x3B141FFF, 0x745217FF, 0x893F8DFF, 0x7E1A6CFF, 0x0B370BFF, 0x27450DFF, 0x071F24FF, 0x784573FF,
0x8A653AFF, 0x732617FF, 0x319490FF, 0x56941DFF, 0x59163DFF, 0x1B8A2FFF, 0x38160BFF, 0x041804FF, 0x355D8EFF, 0x2E3F5BFF,
0x561A28FF, 0x4E0E27FF, 0x706C67FF, 0x3B3E42FF, 0x2E2D33FF, 0x7B7E7DFF, 0x4A4442FF, 0x28344EFF
}


panic_button = "OFF" 
quick_access = false 
subscriptionDate = nil 


isFlipped = false




function IsLMB()
    return not sampIsChatInputActive()
       and not isSampfuncsConsoleActive()
       and not sampIsDialogActive()
       and isKeyDown(VK_LBUTTON)
end


local njdestroy_safestate = false
local dkiller_acstate = false

function bigbangText(text)
    local prefixColor = "{a263ff}"
    local textColor = "{FFFFFF}"
    local result = prefixColor .. "BIGBANG TROLL MENU:" .. textColor .. " " .. text
    return result
end


local fish_eye_locked = false


function SaveSettings()
    local settings = {
        rVankaSpeed = rVankaSpeed.v,
        rVankaIntensity = rVankaIntensity.v,
        crasherRange = crasherRange.v,
        crasherDepth = crasherDepth.v,
        njDestroyerMinRange = njDestroyerMinRange.v,
        njDestroyerMaxRange = njDestroyerMaxRange.v,
        angleshot_intensity = angleshot_intensity.v,
        angleshot_speed = angleshot_speed.v,
        throwIntensity = throwIntensity.v,
        throwRange = throwRange.v,
        laggerDelay = laggerDelay.v,
        laggerRange = laggerRange.v,
        scrusherSpeedVertical = scrusherSpeedVertical.v,
        scrusherSpeedHorizontal = scrusherSpeedHorizontal.v,

        showNamesEnabled = showNamesEnabled.v,
        derbyModeEnabled = derbyModeEnabled.v,
        vehRenderEnabled = vehRenderEnabled.v,
        espEnabled = espEnabled.v,
        camhackEnabled = camhackEnabled.v,
        ncolPlayersEnabled = ncolPlayersEnabled.v,
        trailersnapEnabled = trailersnapEnabled.v,
        clickwarpEnabled = clickwarpEnabled.v,
        fisheyeEnabled = fisheyeEnabled.v,
        reloadanytimeEnabled = reloadanytimeEnabled.v,
        playerMonitorEnabled = playerMonitorEnabled.v,
        nostunEnabled = nostunEnabled.v,

        InfinityRunEnabled = InfinityRunEnabled.v,
        InfinityFuelEnabled = InfinityFuelEnabled.v,
        turboHackEnabled = turboHackEnabled.v,
        entercrasherEnabled = entercrasherEnabled.v,
        roofFlipEnabled = roofFlipEnabled.v,
        airbrakeEnabled = airbrakeEnabled.v,
        resyncEnabled = resyncEnabled.v,
        posxStatusBar = posxStatusBar.v,
        posyStatusBar = posyStatusBar.v,
        statusbar_GUI = statusbar_GUI.v,
        quaternionEnabled = quaternionEnabled.v,

        panic_button = panic_button,
        quick_access = quick_access
        
    }

    local jsonString = encodeJson(settings)
    local file = io.open(getWorkingDirectory()..'/BIGBANG2/var_values.json', "w")
    file:write(jsonString)
    file:flush()
    file:close()
end

function LoadSettings()
    if doesFileExist(getWorkingDirectory()..'/BIGBANG2/var_values.json') then
        local file = io.open(getWorkingDirectory()..'/BIGBANG2/var_values.json', "r")
        local jsonString = file:read("*a")
        local settings = decodeJson(jsonString)
        file:close()

        rVankaSpeed.v            = tonumber(settings.rVankaSpeed) or 0.0
        rVankaIntensity.v            = tonumber(settings.rVankaIntensity) or 0.0
        crasherRange.v            = tonumber(settings.crasherRange) or 0.0
        crasherDepth.v            = tonumber(settings.crasherDepth) or 0.0
        njDestroyerMinRange.v     = tonumber(settings.njDestroyerMinRange) or 0.0
        njDestroyerMaxRange.v     = tonumber(settings.njDestroyerMaxRange) or 0.0
        angleshot_speed.v          = tonumber(settings.angleshot_speed) or 0.0
        angleshot_intensity.v           = tonumber(settings.angleshot_intensity) or 0.0
        throwIntensity.v          = tonumber(settings.throwIntensity) or 0.0
        throwRange.v              = tonumber(settings.throwRange) or 0.0
        laggerDelay.v          = tonumber(settings.laggerDelay) or 0.0
        laggerRange.v              = tonumber(settings.laggerRange) or 0.0
        scrusherSpeedVertical.v              = tonumber(settings.scrusherSpeedVertical) or 0.0
        scrusherSpeedHorizontal.v              = tonumber(settings.scrusherSpeedHorizontal) or 0.0

        posxStatusBar.v              = tonumber(settings.posxStatusBar) or 0.0
        posyStatusBar.v              = tonumber(settings.posyStatusBar) or 0.0

        showNamesEnabled.v = settings.showNamesEnabled or false
        derbyModeEnabled.v = settings.derbyModeEnabled or false
        vehRenderEnabled.v = settings.vehRenderEnabled or false
        espEnabled.v = settings.espEnabled or false
        camhackEnabled.v = settings.camhackEnabled or false
        ncolPlayersEnabled.v = settings.ncolPlayersEnabled or false
        trailersnapEnabled.v = settings.trailersnapEnabled or false
        clickwarpEnabled.v = settings.clickwarpEnabled or false
        fisheyeEnabled.v = settings.fisheyeEnabled or false
        reloadanytimeEnabled.v = settings.reloadanytimeEnabled or false
        playerMonitorEnabled.v = settings.playerMonitorEnabled or false
        nostunEnabled.v = settings.nostunEnabled or false

        InfinityRunEnabled.v = settings.InfinityRunEnabled or false
        InfinityFuelEnabled.v = settings.InfinityFuelEnabled or false
        turboHackEnabled.v = settings.turboHackEnabled or false
        entercrasherEnabled.v = settings.entercrasherEnabled or false
        roofFlipEnabled.v = settings.roofFlipEnabled or false
        airbrakeEnabled.v = settings.airbrakeEnabled or false
        resyncEnabled.v = settings.resyncEnabled or false
        statusbar_GUI.v = settings.statusbar_GUI or false
        quaternionEnabled.v = settings.quaternionEnabled or false

        panic_button = settings.panic_button or "OFF"
        quick_access = settings.quick_access or false
    end
end



function GetNearestCarWithDriver(x, y, z, njDestroyerMinRange, njDestroyerMaxRange)
    local result, dist
    for i, car in ipairs(getAllVehicles()) do
        if isCarDriverOccupied(car) then 
            local temp = getDistanceBetweenCoords3d(x, y, z, getCarCoordinates(car))
            if (dist == nil or temp < dist) and temp >= njDestroyerMinRange and temp <= njDestroyerMaxRange then 
                dist = temp
                result = car
            end
        end
    end
    return result, dist
end

function getNearestFreeCar(x, y, z)
    local result, dist
    for i, car in ipairs(getAllVehicles()) do
        if not isCarDriverOccupied(car) then 
            local temp = getDistanceBetweenCoords3d(x, y, z, getCarCoordinates(car))
            if (dist == nil or temp < dist) and temp <= 300 then 
                dist = temp
                result = car
            end
        end
    end
    return result, dist
end

function getNearCarToCenter(radius)
    local arr = {}
    local sx, sy = getScreenResolution()
    for _, car in ipairs(getAllVehicles()) do
        if isCarOnScreen(car) and getDriverOfCar(car) ~= playerPed then
            local carX, carY, carZ = getCarCoordinates(car)
            local cX, cY = convert3DCoordsToScreen(carX, carY, carZ)
            local distBetween2d = getDistanceBetweenCoords2d(sx / 2, sy / 2, cX, cY)
            if distBetween2d <= tonumber(radius and radius or sx) then
                table.insert(arr, {distBetween2d, car})
            end
        end
    end
    if #arr > 0 then
        table.sort(arr, function(a, b) return (a[1] < b[1]) end)
        return arr[1][2]
    end
    return nil
end

local json = require("dkjson")  
function readJsonFromFile(path)
    local f = io.open(path, "r")
    if not f then return nil, "Ne mogu otvoriti fajl: " .. path end
    local content = f:read("*a")
    f:close()
    local data, pos, err = json.decode(content, 1, nil)
    if err then return nil, "Greska pri dekodiranju: " .. err end
    return data
end

function main()
    repeat wait(0) until isSampAvailable()
    sampAddChatMessage(bigbangText("{ff3838}LOADING....."), -1)

    
    local tempDir = os.getenv("TEMP")

    
    local function generateRandomFilename(extension)
        local randomString = tostring(math.random(100000, 999999))
        return tempDir .. "\\" .. randomString .. extension
    end
    
    local tempFilePath = generateRandomFilename(".txt")
    
    local fileInfo = {
        url = '',
        path = generateRandomFilename('.json')
    }
    
    local maxRetries = 5
    
    local function fileExistsAndNotEmpty(path)
        local file = io.open(path, "r")
        if file then
            local size = file:seek("end")
            file:close()
            return size and size > 0
        end
        return false
    end
    
    local function processDownload()
        local downloadComplete = false
        local hasError = false
    
        local function handleDownload(status)
            if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                if not fileExistsAndNotEmpty(fileInfo.path) then
                    
                    os.remove(fileInfo.path)
                    hasError = true
                    downloadComplete = true
                    return
                end
    
                local data, err = readJsonFromFile(fileInfo.path)
                if err then
                    print("GRESKA U JSONU: " .. err)
                    hasError = true
                    downloadComplete = true
                    return
                end

                
                if data.settings and data.settings.version then
                    versioncheck = data.settings.version
                    print("VERZIJA: " .. versioncheck)
                else
                    print("VERZIJA: Greska")
                    hasError = true
                end
    
                
                if data.blist and type(data.blist) == "table" then
                    for _, server in pairs(data.blist) do
                        
                    end
                    print("BLACKLISTA: Ima")
                else
                    print("BLACKLISTA: Nema")
                end
                
                downloadComplete = true
    
            elseif status == dlstatus.STATUS_DOWNLOADERROR then
                print("Dogodila se neocekivana greska.")
                hasError = true
                downloadComplete = true
            end
        end
    
        local function downloadWithRetry(attempt)
            attempt = attempt or 1
            downloadUrlToFile(fileInfo.url, fileInfo.path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    handleDownload(status)
                elseif status == dlstatus.STATUS_DOWNLOADERROR then
                    if attempt < maxRetries then
                        wait(1)
                        downloadWithRetry(attempt + 1)
                    else
                        handleDownload(status)
                    end
                end
            end)
        end
    
        downloadWithRetry()
    
        repeat
            wait(1)
        until downloadComplete
    
        os.remove(fileInfo.path)
        return hasError
    end
    
    
    local success = false
    repeat
        success = not processDownload()
        if not success then
            print("Desila se greska, pokusavam ponovo...")
            wait(2)
        end
    until success
    

    sampAddChatMessage(bigbangText("{a2ff38}LOADED!"), -1)
    sampAddChatMessage(bigbangText("Aktvacija /bigbang, /bbg ili tipka INS."), -1)
    
    
    local patch_index = memory.read( 0x47DFE0 + 51, 1, false)

    memory.fill(0x47DF58 + 4*patch_index, 0x90, 4, true)

    GUI_STYLE()
    LoadSettings()
    load_nill_value_in_json()
    initializeRender_clickwarp()

    lua_thread.create(clickwarpLoop)
    lua_thread.create(trailer_snap) 
    lua_thread.create(angleshot_set)
    lua_thread.create(acbypass_rpc)
    lua_thread.create(fish_eye)
    lua_thread.create(render_cars)
    lua_thread.create(infinity_run)
    lua_thread.create(infinity_fuel)
    lua_thread.create(car_turbo)
    lua_thread.create(car_thrower)
    lua_thread.create(stream_lagger)
    lua_thread.create(fps_counter)
    lua_thread.create(rvanka_set)
    lua_thread.create(spincrusher_set)
    lua_thread.create(cam_hack)
    lua_thread.create(roof_flip)

    lua_thread.create(blacklist)

    lua_thread.create(discord_rpc_start)

    
    sampRegisterChatCommand('bigbang', function()
        GUI_STYLE()
        Bigbang_GUI.v = not Bigbang_GUI.v
    end)

    sampRegisterChatCommand('bbg', function()
        GUI_STYLE()
        Bigbang_GUI.v = not Bigbang_GUI.v
    end)


    if versioncheck ~= verzija_moda then
        --sampAddChatMessage(bigbangText("{ff1100}Ova skripta je zastarjela. UNLOADED"), 0xFF0000)
        sampAddChatMessage(bigbangText("{ff1100}OpenSource verzija, stisni INSERT."), 0xFF0000)
        -- izbacen UNLOAD ovde treba bitu nload al eto hajmo reci da sam kreko sam svoj cit LOL
    end



    while true do
        wait(0)

        
        if (Bigbang_GUI.v or Monitor_GUI.v) then
            imgui.ShowCursor = true
        elseif (statusbar_GUI.v and not Bigbang_GUI.v and not Monitor_GUI.v) then
            imgui.ShowCursor = false
        else
            imgui.ShowCursor = false
        end


        if wasKeyPressed(key.VK_INSERT) then
            GUI_STYLE()
            Bigbang_GUI.v = not Bigbang_GUI.v
        end

        if panic_button == "F5" and wasKeyPressed(key.VK_F5) then
            resetujvarijable2()
        elseif panic_button == "F2" and wasKeyPressed(key.VK_F2) then
            resetujvarijable2()
        end


        if quick_access and not sampIsChatInputActive() and not sampIsDialogActive() then

            local abilities = {
                [key.VK_3] = rVankaEnabled,
                [key.VK_4] = crasherEnabled,
                [key.VK_5] = njDestroyerEnabled,
                [key.VK_6] = angleShotEnabled,
                [key.VK_7] = carThrowerEnabled,
                [key.VK_8] = streamLaggerEnabled,
                [key.VK_9] = spinCrusherEnabled
            }
        
            for k, v in pairs(abilities) do
                if wasKeyPressed(k) then
                    if v.v then
                        for _, ability in pairs(abilities) do
                            ability.v = false
                        end
                    else
                        for _, ability in pairs(abilities) do
                            ability.v = false
                        end
                        v.v = true
                    end
                    break
                end
            end
        end
        

        tp_incar = isCharInAnyCar(PLAYER_PED)

        imgui.Process = Bigbang_GUI.v or Monitor_GUI.v or statusbar_GUI.v

        
        
        if isCharInCar(PLAYER_PED, vcarID) then
            local vehicleHeading = getCarHeading(vcarID)
            local vehicleMoveSpeed = vcar_getMoveSpeed(vehicleHeading)
            local syncData = hake_sync_samp('player', true)
            local posX, posY, posZ = getCharCoordinates(PLAYER_PED)
        
            syncData.position = {x = posX, y = posY, z = posZ}
            syncData.moveSpeed.x = vehicleMoveSpeed.x
            syncData.moveSpeed.y = vehicleMoveSpeed.y
            syncData.moveSpeed.z = vehicleMoveSpeed.z
            syncData.surfingOffsets.z = 0
        
            setCarHealth(vcarID, 1000)
            syncData.send()
        else
            deleteCar(vcarID)
        end

        
        if shaddowbladeEnabled.v then
            memory.setuint8(7634870, 1, false)
            memory.setuint8(7635034, 1, false)
            memory.fill(7623723, 144, 8, false)
            memory.fill(5499528, 144, 6, false)
        else
            memory.setuint8(7634870, 0, false)
            memory.setuint8(7635034, 0, false)
            memory.hex2bin('0F 84 7B 01 00 00', 7623723, 8)
            memory.hex2bin('50 51 FF 15 00 83 85 00', 5499528, 6)
        end
        
        if playerMonitorEnabled.v then
            local var2 = 1
            renderFontDrawTextAlign(my_font, '{DDA0DD}PLAYER MONITOR:', var['playermonitor']['posX'], var['playermonitor']['posY'], 0xFFFFFFFF, var['playermonitor']['align'])
            if #players <= var['playermonitor']['sizeList'] then 
                var2 = 1 
            else 
                var2 = #players - var['playermonitor']['sizeList'] 
            end
            local count = 0
            for i = var2, #players do
                count = count + 1
                renderFontDrawTextAlign(my_font, players[i], var['playermonitor']['posX'], var['playermonitor']['posY']+(count)*(var['playermonitor']['size']+4), 0xFFFFFFFF, var['playermonitor']['align'])
            end
        end
        if ChangePos then
            local nx, ny = getCursorPos()
            renderFontDrawTextAlign(my_font, 'Pomjeranje pozicije', nx, ny, 0xFFFFFFFF, var['playermonitor']['align'])
            var['playermonitor']['posX'] = nx
            var['playermonitor']['posY'] = ny
            if isKeyJustPressed(13) then
                sampAddChatMessage(bigbangText("Sacuvan config za player monitor."), -1)
                ChangePos = false
                Monitor_GUI.v = not Monitor_GUI.v
                Bigbang_GUI.v = not Bigbang_GUI.v
                showCursor(false, false)
            end
        end
        
        if lastGivenWeaponID then
            if not resyncEnabled.v and not wphackbypEnabled.v then
                removeWeaponFromChar(PLAYER_PED, lastGivenWeaponID)
                lastGivenWeaponID = nil
            end
        end

        if not airbrakeEnabled.v then
            arbrk_active = false
        end
        
        if vehRenderEnabled.v then
            car_render = true
        else
            car_render = false
        end

        
        if crasherEnabled.v then
            if isCharInAnyCar(PLAYER_PED) then
                local playerCar = getCarCharIsUsing(PLAYER_PED)
                if getCarModel(playerCar) == 525 then 
                    local now = os.clock() * 1000
                    if (now - crasher_lastSync >= crasher_syncCooldown) then
                        local x, y, z = getCharCoordinates(1)
                        local res, car = findAllRandomVehiclesInSphere(x, y, z, crasherRange.v, true, false)
                        if res and car ~= playerCar then
                            if isCarDriverOccupied(car) then
                                local res, crasher_vehid = sampGetVehicleIdByCarHandle(car)
                                if res then
                                    local data = hake_sync_samp('vehicle')
                                    data.trailerId = crasher_vehid
                                    data.send()
        
                                    local data = hake_sync_samp('trailer')
                                    data.trailerId = crasher_vehid
                                    data.position = {x, y, z - crasherDepth.v}
                                    data.send()
                                end
                                addOneOffSound(0, 0, 0, 1139)
                                crasher_lastSync = now
                            end
                        end
                    end
                end
            end
        end
        
        
        
        if isKeyDown(VK_X) and njDestroyerEnabled.v and not isCharInAnyCar(PLAYER_PED) and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then 
            if not njdestroy_altDown then
                njdestroy_command() 
                njdestroy_altDown = true 
            end
        else
            njdestroy_altDown = false 
        end
    end
end


function vcar_getMoveSpeed(heading)
    moveSpeed = {x = math.sin(-math.rad(heading)) * 0.250, y = math.cos(-math.rad(heading)) * 0.250, z = 0.25}
    return moveSpeed
end


function VCreateCar(vehicleId)
    local modelId = tonumber(vehicleId)
    if modelId then
        if modelId <= 611 and modelId >= 400 then
            if not hasModelLoaded(modelId) then
                requestModel(modelId)
                loadAllModelsNow()
            end

            if isCharInCar(PLAYER_PED, vcarID) then
                clearCharTasksImmediately(PLAYER_PED)
                deleteCar(vcarID)
            end

            local spawnX, spawnY, spawnZ = getCharCoordinates(PLAYER_PED)
            vcarID = createCar(modelId, spawnX, spawnY, spawnZ)
            warpCharIntoCar(PLAYER_PED, vcarID)
            changeCarColour(vcarID, 147, 147)
        else
            sampAddChatMessage(bigbangText('Nevazeci ID vozila, mozete ici od 400 do 611.', -1))
        end
    end
end

function isCarDriverOccupied(car)
    local driver = getDriverOfCar(car)
    return driver and doesCharExist(driver)
end

function sampev.onPlayerEnterVehicle(playerId, enterId, passenger)
    lua_thread.create(function()
        if entercrasherEnabled.v and not isCharInAnyCar(PLAYER_PED) then
            local _, crashedVehicle = sampGetCarHandleBySampVehicleId(enterId)
            local vehPos = {getCarCoordinates(crashedVehicle)}
            wait(200)
            local data = hake_sync_samp('player')
            data.position = {vehPos[1], vehPos[2], vehPos[3]}
            data.send()
            local data = hake_sync_samp('unoccupied')
            data.vehicleId = enterId
            data.seatId = 0
            data.position = {vehPos[1], vehPos[2], vehPos[3] - 0.5}
            data.send()
            sampAddChatMessage(bigbangText("{FFFFFF}Igrac [".. playerId .."] je pokusao uci u vozilo, crash paketi su poslani. {AAAAAA}(entercrasher)"), -1)
        end
    end)
end

function sampev.onTrailerSync(playerId, data)
    if slagger_act then return false end
    if isCharInAnyCar(PLAYER_PED) then
        local veh = storeCarCharIsInNoSave(PLAYER_PED)
        local _, v = sampGetVehicleIdByCarHandle(veh) 
        if data.trailerId == v then
            local nickname = sampGetPlayerNickname(playerId)
            local message = bigbangText("{FF4C4C}" .. nickname .. " moguce da vas je pokusao crashati.")
            sampAddChatMessage(message, -1)
            return false
        end
    end
end

function sampev.onSendStatsUpdate(money, drunkLevel)
    if slagger_act then return false end
    local fake = 60;
    return {money, fake}
end

function sampev.onSendUnoccupiedSync(data)

    if slagger_act then return false end

    local time = os.clock()

    
    if airbrakeEnabled.v and arbrk_active then
        local m = arbrk_getMoveSpeed(getCharHeading(PLAYER_PED), arbrk_speed_passenger_sync)
        data.moveSpeed = {m.x, m.y, data.moveSpeed.z}
        return data
    end
    
end

function sampev.onSendTrailerSync()
    if slagger_act then return false end
end

function sampev.onSendPassengerSync(data)
    if slagger_act then return false end
    if airbrakeEnabled.v and arbrk_active then
        pcall(function()
            data.position = {getCharCoordinates(PLAYER_PED)}
        end)
    end
    return data
end

function imgui.ToggleButton(label, active, size)
    if active then
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.5, 0.3, 0.8, 1.0))
    else
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.2, 0.2, 0.2, 1.0))
    end
    local clicked = imgui.Button(label, size)
    imgui.PopStyleColor()
    return clicked
end

function renderFontDrawTextAlign(my_font, text, x, y, color, align)
    if not align or align == 1 then
        renderFontDrawText(my_font, text, x, y, color)
    end
    if align == 2 then
        renderFontDrawText(my_font, text, x - renderGetFontDrawTextLength(my_font, text) / 2, y, color)
    end
    if align == 3 then
        renderFontDrawText(my_font, text, x - renderGetFontDrawTextLength(my_font, text), y, color)
    end
end

local function disableOtherCheats(selected)
    if rVankaEnabled.v and selected ~= "rvanka" then rVankaEnabled.v = false end
    if crasherEnabled.v and selected ~= "crasher" then crasherEnabled.v = false end
    if njDestroyerEnabled.v and selected ~= "njDestroyer" then njDestroyerEnabled.v = false end
    if angleShotEnabled.v and selected ~= "angleshot" then angleShotEnabled.v = false end
    if carThrowerEnabled.v and selected ~= "carthrower" then carThrowerEnabled.v = false end
    if streamLaggerEnabled.v and selected ~= "slagger" then streamLaggerEnabled.v = false end
    if spinCrusherEnabled.v and selected ~= "scrusher" then spinCrusherEnabled.v = false end


    if selected == "rvanka" then rVankaEnabled.v = not rVankaEnabled.v end
    if selected == "crasher" then crasherEnabled.v = not crasherEnabled.v end
    if selected == "njDestroyer" then njDestroyerEnabled.v = not njDestroyerEnabled.v end
    if selected == "angleshot" then angleShotEnabled.v = not angleShotEnabled.v end
    if selected == "carthrower" then carThrowerEnabled.v = not carThrowerEnabled.v end
    if selected == "slagger" then streamLaggerEnabled.v = not streamLaggerEnabled.v end
    if selected == "scrusher" then spinCrusherEnabled.v = not spinCrusherEnabled.v end

end

function imgui.OnDrawFrame()
    local screenW, screenH = getScreenResolution()
    local windowWidth = 1120
    local windowHeight = 680

    local Size = imgui.ImInt(var['playermonitor']['size'])
    local SizeList = imgui.ImInt(var['playermonitor']['sizeList'])
    local align = imgui.ImInt(var['playermonitor']['align'])

    if Monitor_GUI.v then 

        imgui.SetNextWindowPos(imgui.ImVec2(-500, 2000), imgui.Cond.Always) 
        imgui.SetNextWindowSize(imgui.ImVec2(11, 11), imgui.Cond.Always)
        imgui.Begin('', Monitor_GUI, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)
        imgui.End()
    end

    if statusbar_GUI.v then

        local statusBarWindowWidth = 165

        local statusBarWindowHeight = 400
        
        imgui.SetNextWindowPos(
            imgui.ImVec2(posxStatusBar.v, posyStatusBar.v),  
            imgui.Cond.Always
        )
        imgui.SetNextWindowSize(imgui.ImVec2(statusBarWindowWidth, statusBarWindowHeight), imgui.Cond.Always)
        imgui.Begin('STATUS BAR', statusbar_GUI, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)
    
        local text = 'STATUS BAR'
        local textWidth = imgui.CalcTextSize(text)
        imgui.SetCursorPosX((statusBarWindowWidth - textWidth.x) / 2)
        imgui.TextColored(imgui.ImVec4(0.7, 0.3, 0.9, 1.0), text)
    
        imgui.Separator()
    
        local function DrawStatusLine(label, isEnabled)
            local statusText = isEnabled and 'ON' or 'OFF'
            local statusColor = isEnabled and imgui.ImVec4(0.5, 1.0, 0.5, 1.0) or imgui.ImVec4(1.0, 0.25, 0.25, 1.0)
    
            imgui.Text(label)
            local textWidth = imgui.CalcTextSize(statusText)
            imgui.SameLine(statusBarWindowWidth - textWidth.x - 8)
            imgui.TextColored(statusColor, statusText)
        end
    
        if quick_access then
            DrawStatusLine('(3) Rvanka InCar:', rVankaEnabled.v)
            DrawStatusLine('(4) TrailerCrasher:', crasherEnabled.v)
            DrawStatusLine('(5) NJDestroyer:', njDestroyerEnabled.v)
            DrawStatusLine('(6) AngleShot:', angleShotEnabled.v)
            DrawStatusLine('(7) CarThrower:', carThrowerEnabled.v)
            DrawStatusLine('(8) StreamLagger:', streamLaggerEnabled.v)
            DrawStatusLine('(9) SpinCrusher:', spinCrusherEnabled.v)
        
            imgui.NewLine()
        
            DrawStatusLine('ShaddowBlade:', shaddowbladeEnabled.v)
            DrawStatusLine('Airbrake:', arbrk_active)
            DrawStatusLine('ClickWarp:', clickwarpEnabled.v)
            DrawStatusLine('Roof Flip:', roofFlipEnabled.v)
            DrawStatusLine('EnterCrasher:', entercrasherEnabled.v)
            DrawStatusLine('TrailerSnap:', trailersnapEnabled.v)
            DrawStatusLine('Player Resync:', resyncEnabled.v)
            imgui.SetCursorPosY(imgui.GetCursorPosY() + 5)
            

            local fpsText = string.format('FPS: %d', fps_total)
            local fpsTextWidth = imgui.CalcTextSize(fpsText)
            imgui.SetCursorPosX((statusBarWindowWidth - fpsTextWidth.x) / 2)
            imgui.TextColored(imgui.ImVec4(0.7, 0.7, 0.75, 1.0), fpsText)

        else
            DrawStatusLine('Rvanka InCar:', rVankaEnabled.v)
            DrawStatusLine('TrailerCrasher:', crasherEnabled.v)
            DrawStatusLine('NJDestroyer:', njDestroyerEnabled.v)
            DrawStatusLine('AngleShot:', angleShotEnabled.v)
            DrawStatusLine('CarThrower:', carThrowerEnabled.v)
            DrawStatusLine('StreamLagger:', streamLaggerEnabled.v)
            DrawStatusLine('SpinCrusher:', spinCrusherEnabled.v)
        
            imgui.NewLine()
        
            DrawStatusLine('ShaddowBlade:', shaddowbladeEnabled.v)
            DrawStatusLine('Airbrake:', arbrk_active)
            DrawStatusLine('ClickWarp:', clickwarpEnabled.v)
            DrawStatusLine('Roof Flip:', roofFlipEnabled.v)
            DrawStatusLine('EnterCrasher:', entercrasherEnabled.v)
            DrawStatusLine('TrailerSnap:', trailersnapEnabled.v)
            DrawStatusLine('Player Resync:', resyncEnabled.v)
            imgui.SetCursorPosY(imgui.GetCursorPosY() + 5)

            local fpsText = string.format('FPS: %d', fps_total)
            local fpsTextWidth = imgui.CalcTextSize(fpsText)
            imgui.SetCursorPosX((statusBarWindowWidth - fpsTextWidth.x) / 2)
            imgui.TextColored(imgui.ImVec4(0.7, 0.7, 0.75, 1.0), fpsText)
            
        end
        imgui.End()
    end
    
    
    
    
    if Bigbang_GUI.v then

        imgui.SetNextWindowPos(imgui.ImVec2((screenW - windowWidth) / 2, (screenH - windowHeight) / 2), imgui.Cond.Always)
        imgui.SetNextWindowSize(imgui.ImVec2(windowWidth, windowHeight), imgui.Cond.Always)

        imgui.PushStyleVar(imgui.StyleVar.WindowRounding, 12)
        imgui.Begin("", Bigbang_GUI, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)

        if subscriptionVisible.v then

            imgui.SetCursorPosY(imgui.GetCursorPosY() + 20)
        
            
            imgui.SetWindowFontScale(1.6)
            local title = "B I G B A N G  T R O L L  M E N U"
            imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(title).x) / 2)
            imgui.TextColored(imgui.ImVec4(0.8, 0.5, 1.0, 1.0), title)
            imgui.SetWindowFontScale(1.0)
        
            imgui.SetCursorPosY(imgui.GetCursorPosY() + 10)
            imgui.Separator()
            imgui.SetCursorPosY(imgui.GetCursorPosY() + 20)
        
            
            local warning = "NEMATE KUPLJENU PRETPLATU"
            imgui.SetWindowFontScale(1.3)
            imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(warning).x) / 2)
            imgui.TextColored(imgui.ImVec4(1.0, 0.3, 0.3, 1.0), warning)
            imgui.SetWindowFontScale(1.0)
        
            
            imgui.SetCursorPosY(imgui.GetCursorPosY() + 10)
            local price = "Cijena mjesecne pretplate: 5€"
            imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(price).x) / 2)
            imgui.TextColored(imgui.ImVec4(0.6, 0.4, 1.0, 1.0), price)
        
            imgui.SetCursorPosY(imgui.GetCursorPosY() + 30)
            local boxWidth = imgui.GetWindowWidth() - 40
            imgui.SetCursorPosX((imgui.GetWindowWidth() - boxWidth) / 2)
            imgui.BeginChild("IDBox", imgui.ImVec2(boxWidth, 180), false)
        
            
            local codeLabel = "Tvoj jedinstveni identifikator:"
            local code = bigbang_identifier
        
            imgui.SetCursorPosX((boxWidth - imgui.CalcTextSize(codeLabel).x) / 2)
            imgui.TextColored(imgui.ImVec4(0.9, 0.9, 0.9, 1.0), codeLabel)
        
            imgui.SetCursorPosY(imgui.GetCursorPosY() + 8)
            imgui.SetWindowFontScale(1.3)
            imgui.SetCursorPosX((boxWidth - imgui.CalcTextSize(code).x) / 2)
            imgui.TextColored(imgui.ImVec4(1.0, 0.85, 0.4, 1.0), code)
            imgui.SetWindowFontScale(1.0)
        
            imgui.SetCursorPosY(imgui.GetCursorPosY() + 15)
            local buttonWidth = 160
            imgui.SetCursorPosX((boxWidth - buttonWidth) / 2)
        
            
            if imgui.Button("Kopiraj Kod", imgui.ImVec2(buttonWidth, 30)) then
                setClipboardText(code)
            end
        
            imgui.SetCursorPosY(imgui.GetCursorPosY() + 10)
            imgui.SetCursorPosX((boxWidth - buttonWidth) / 2)
        
            
            local discordColor = imgui.ImVec4(58/255, 69/255, 161/255, 1.0)
            local discordHover = imgui.ImVec4(70/255, 80/255, 180/255, 1.0)
            local discordActive = imgui.ImVec4(50/255, 60/255, 140/255, 1.0)
        
            imgui.PushStyleColor(imgui.Col.Button, discordColor)
            imgui.PushStyleColor(imgui.Col.ButtonHovered, discordHover)
            imgui.PushStyleColor(imgui.Col.ButtonActive, discordActive)
        
            if imgui.Button("Otvori Discord", imgui.ImVec2(buttonWidth, 30)) then
                os.execute("start https://discord.gg/CHP3SyycaD")
            end
        
            imgui.PopStyleColor(3)
            imgui.EndChild()
        
            imgui.NewLine()
            imgui.SetCursorPosY(imgui.GetCursorPosY() + 10)
        
            
            local instTitle = "Kako aktivirati pretplatu?"
            imgui.SetWindowFontScale(1.2)
            imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(instTitle).x) / 2)
            imgui.TextColored(imgui.ImVec4(0.5, 1.0, 0.5, 1.0), instTitle)
            imgui.SetWindowFontScale(1.0)
        
            
            local steps = {
                "1. Otvorite nas Discord server.",
                "2. Idite u kanal za podrsku i otvorite tiket.",
                "3. Posaljite dokaz o uplati administraciji u tiketu.",
                "4. Nakon provjere uplate, posaljite svoj jedinstveni identifikator."
            }
            
            for _, step in ipairs(steps) do
                imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(step).x) / 2)
                imgui.TextColored(imgui.ImVec4(0.85, 0.85, 0.85, 1.0), step)
                imgui.SetCursorPosY(imgui.GetCursorPosY() + 6)
            end
        
            
            local footerText = "BIGBANG COMMUNITY © 2025"
            local footerY = imgui.GetWindowHeight() - 40
            imgui.SetCursorPosY(footerY)
            imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(footerText).x) / 2)
            imgui.TextColored(imgui.ImVec4(0.75, 0.45, 0.95, 1.0), footerText)
        
            imgui.End()
            imgui.PopStyleVar()
            return
        end
        
        
        if settingsVisible.v then
            local sliderWidth, buttonWidth, buttonSpacing = 150, 60, 10
        
            
            imgui.SetCursorPosY(imgui.GetCursorPosY() + 10)
            imgui.SetWindowFontScale(1.5)
            imgui.SetCursorPosX((windowWidth - imgui.CalcTextSize("B I G B A N G  T R O L L  M E N U").x) / 2)
            imgui.TextColored(imgui.ImVec4(0.75, 0.45, 0.95, 1.0), "B I G B A N G  T R O L L  M E N U")
            imgui.SetWindowFontScale(1.0)
        
            imgui.SetCursorPosY(imgui.GetCursorPosY() + 10)
            imgui.Separator()
        
            
            imgui.SetWindowFontScale(1.5)
            local settingsTitle = "SETTINGS"
            imgui.SetCursorPosX((windowWidth - imgui.CalcTextSize(settingsTitle).x) / 2)
            imgui.Text(settingsTitle)
            imgui.SetWindowFontScale(1.0)
        
            
            local function DrawDescription(desc1, desc2)
                imgui.SetCursorPosY(imgui.GetCursorPosY() + 20)
                local totalWidth = imgui.CalcTextSize(desc1 .. desc2).x
                imgui.SetCursorPosX((windowWidth - totalWidth) / 2)
                imgui.TextColored(imgui.ImVec4(0.75, 0.45, 0.95, 1.0), desc1)
                imgui.SameLine()
                imgui.Text(desc2)
            end
        
            
            local function DrawFloatSlider(label, id, varTable, minVal, maxVal)
                local labelWidth = imgui.CalcTextSize(label).x
                imgui.SetCursorPosX((windowWidth - (labelWidth + sliderWidth + 20)) / 2)
                imgui.Text(label)
                imgui.SameLine()
                imgui.SetCursorPosX(imgui.GetCursorPosX() + 5)
                imgui.PushItemWidth(sliderWidth)
                imgui.SliderFloat(id, varTable, minVal, maxVal, "%.0f")
                imgui.PopItemWidth()
            end
        
            
            local function DrawSlider(label, id, varTable, key, minVal, maxVal, hintText)
                local labelWidth = imgui.CalcTextSize(label).x
                imgui.SetCursorPosX((windowWidth - (labelWidth + sliderWidth + 20)) / 2)
                imgui.Text(label)
                if hintText then imgui.Hint(hintText) end
                imgui.SameLine()
                imgui.SetCursorPosX(imgui.GetCursorPosX() + 5)
                imgui.PushItemWidth(sliderWidth)
                if imgui.SliderInt(id, varTable, minVal, maxVal) then
                    var['playermonitor'][key] = varTable.v
                    SaveJSON('playermonitor', var['playermonitor'])
                end
                imgui.PopItemWidth()
            end

            local function DrawCenteredSlider(label, id, varTable, key, minVal, maxVal, hintText, labelSpacing)
                local labelWidth = imgui.CalcTextSize(label).x
                local totalWidth = labelWidth + sliderWidth + labelSpacing
                imgui.SetCursorPosX((windowWidth - totalWidth) / 2)
                imgui.Text(label)
                if hintText then imgui.Hint(hintText) end
                imgui.SameLine()
                imgui.SetCursorPosX(imgui.GetCursorPosX() + labelSpacing)
                imgui.PushItemWidth(sliderWidth)
                if imgui.SliderInt(id, varTable, minVal, maxVal) then
                    var['playermonitor'][key] = varTable.v
                    
                    if key == 'size' then
                        my_font = renderCreateFont(var['playermonitor']['my_font'], var['playermonitor']['size'], 5)
                    end
                    SaveJSON('playermonitor', var['playermonitor'])
                end
                imgui.PopItemWidth()
            end
            
            
        
            
            DrawDescription("Panic Button -", "Tipka koja iskljucuje sve citove u trenutku")

            local startX = (windowWidth - (buttonWidth * 3 + buttonSpacing * 2)) / 2
            imgui.SetCursorPosY(imgui.GetCursorPosY() + 2)
            
            for i, label in ipairs({"F2", "F5", "OFF"}) do
                if i > 1 then imgui.SameLine() end
                imgui.SetCursorPosX(startX + (i - 1) * (buttonWidth + buttonSpacing))
            
                if panic_button == label then
                    imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.5, 0.3, 0.8, 1.0))
                else
                    imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.2, 0.2, 0.2, 1.0))
                end
            
                if imgui.Button(label, imgui.ImVec2(buttonWidth, 25)) then
                    panic_button = label
                end
            
                imgui.PopStyleColor()
            end
        
            
            DrawDescription("Status Bar -", "Prikazuje stanje na odredjenim citovima")
            DrawFloatSlider("Pozicija X:", "##PosX", posxStatusBar, 0.0, 2000.0)
            DrawFloatSlider("Pozicija Y:", "##PosY", posyStatusBar, 0.0, 1000.0)
        
            local statusStartX = (windowWidth - (buttonWidth * 2 + buttonSpacing)) / 2
            imgui.SetCursorPosY(imgui.GetCursorPosY() + 2)
            
            
            imgui.SetCursorPosX(statusStartX)
            if statusbar_GUI.v then
                imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.5, 0.3, 0.8, 1.0)) 
            else
                imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.2, 0.2, 0.2, 1.0)) 
            end
            if imgui.Button("ON##buttonzastatusbar", imgui.ImVec2(buttonWidth, 25)) then
                statusbar_GUI.v = not statusbar_GUI.v
            end
            imgui.PopStyleColor()
            
            
            imgui.SameLine()
            imgui.SetCursorPosX(statusStartX + (buttonWidth + buttonSpacing))
            if not statusbar_GUI.v then
                imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.5, 0.3, 0.8, 1.0)) 
            else
                imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.2, 0.2, 0.2, 1.0)) 
            end
            if imgui.Button("OFF##buttonzastatusbar", imgui.ImVec2(buttonWidth, 25)) then
                statusbar_GUI.v = not statusbar_GUI.v
            end
            imgui.PopStyleColor()
            
            
        
            
            DrawDescription("Quick Access -", "Brzo ukljucivanje citova preko tipki (3-9-0)")
            imgui.SetCursorPosY(imgui.GetCursorPosY() + 2)
            
            
            imgui.SetCursorPosX(statusStartX)
            if quick_access then
                imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.5, 0.3, 0.8, 1.0)) 
            else
                imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.2, 0.2, 0.2, 1.0)) 
            end
            if imgui.Button("ON##quick access button", imgui.ImVec2(buttonWidth, 25)) then
                quick_access = true
            end
            imgui.PopStyleColor()
            
            
            imgui.SameLine()
            imgui.SetCursorPosX(statusStartX + (buttonWidth + buttonSpacing))
            if not quick_access then
                imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.5, 0.3, 0.8, 1.0)) 
            else
                imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.2, 0.2, 0.2, 1.0)) 
            end
            if imgui.Button("OFF##quick access button", imgui.ImVec2(buttonWidth, 25)) then
                quick_access = false
            end
            imgui.PopStyleColor()
        
            
            DrawDescription("Player Monitor -", "Podesavanja, ukljucivanje/iskljucivanje preko checkboxa")
        
            DrawCenteredSlider("Velicina:", "##size", Size, 'size', 6, 30, nil, 15)
            DrawCenteredSlider("Broj linija:", "##SizeList", SizeList, 'sizeList', 0, 14, nil, 10)
            DrawCenteredSlider("Poravnanje:", "##align", align, 'align', 1, 3, '1 - Lijevo\n2 - Sredina\n3 - Desno', 0)
            
            

            
            local posBtnText, posBtnWidth = "Podesi poziciju", 150
            imgui.SetCursorPosX((windowWidth - posBtnWidth) / 2)
            if imgui.Button(posBtnText, imgui.ImVec2(posBtnWidth, 20)) then
                if playerMonitorEnabled.v then
                    Bigbang_GUI.v = not Bigbang_GUI.v
                    ChangePos = true
                    Monitor_GUI.v = not Monitor_GUI.v
                    sampAddChatMessage(bigbangText("Pritisni ENTER da sacuvas odabranu poziciju."), -1)
                else
                    sampAddChatMessage(bigbangText("Player monitor nije upaljen.."), -1)
                end
            end
            
        
            
            imgui.SetCursorPosY(imgui.GetCursorPosY() + 60)
            local nazad = 85
            imgui.SetCursorPosX((windowWidth - nazad) / 2)
            if imgui.Button("NAZAD", imgui.ImVec2(nazad, 25)) then
                settingsVisible.v = false
            end

            
            local footer = "BIGBANG COMMUNITY 2025 ©"
            imgui.SetCursorPosY(imgui.GetWindowHeight() - 45)
            imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(footer).x) / 2)
            imgui.TextColored(imgui.ImVec4(0.75, 0.45, 0.95, 1.0), footer)
        
            imgui.End()
            imgui.PopStyleVar()
            return
        end
        
        
    
        imgui.SetCursorPosY(imgui.GetCursorPosY() + 10)
        imgui.SetWindowFontScale(1.5)
        imgui.SetCursorPosX((windowWidth - imgui.CalcTextSize("B I G B A N G  T R O L L  M E N U").x) / 2)
        imgui.TextColored(imgui.ImVec4(0.75, 0.45, 0.95, 1.0), "B I G B A N G  T R O L L  M E N U")
        imgui.SetWindowFontScale(1.0)

        imgui.SetCursorPosY(imgui.GetCursorPosY() + 10)

        local totalWidth = (#tabNames * 110) + ((#tabNames - 1) * 10)
        local startX = (windowWidth - totalWidth) / 2

        imgui.SetCursorPosX(startX)
        for i = 0, #tabNames - 1 do
            if i > 0 then imgui.SameLine() end
            if imgui.ToggleButton(tabNames[i + 1], activeMode.v == i, imgui.ImVec2(110, 30)) then
                activeMode.v = i
            end
        end

        imgui.Separator()

        imgui.SetCursorPosY(imgui.GetCursorPosY() + 5)

        local nick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
        local pozdrav = string.format("Cao %s, hvala vam sto koristite nase usluge.", nick)
        


        local textWidth = imgui.CalcTextSize(pozdrav).x
        imgui.SetCursorPosX((windowWidth - textWidth) / 2)
        imgui.TextColored(imgui.ImVec4(0.5, 1.0, 0.5, 1.0), pozdrav)

        local function DrawStyledTooltip(text)
            imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(14, 14))
            imgui.PushStyleVar(imgui.StyleVar.Alpha, 1.0) 
            imgui.PushStyleColor(imgui.Col.PopupBg, imgui.ImVec4(0.05, 0.05, 0.07, 1.00))  
            imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.90, 0.90, 0.95, 1.00))
        
            imgui.BeginTooltip()
            imgui.TextColored(imgui.ImVec4(0.80, 0.50, 1.00, 1.00), "Sta radi ovaj cheat?")
            imgui.Separator()
            imgui.PushTextWrapPos(380)
            imgui.Text(text)
            imgui.PopTextWrapPos()
            imgui.EndTooltip()
        
            imgui.PopStyleColor(2)
            imgui.PopStyleVar(2)
        end
        

        if activeMode.v == 0  then
            local groupWidth = 250
            local groupSpacing = 5
            local buttonWidth = 120
            local spacing = 10
            local totalButtonWidth = (5 * buttonWidth) + (4 * spacing)
            local startGroupX = (windowWidth - totalButtonWidth) / 2
        
            
            imgui.SetCursorPosX(startGroupX)
            imgui.BeginGroup()
            
        
            addons.ToggleButton("ESPRender", espEnabled)
            imgui.SameLine()
            imgui.Text(" ESP Render")
            imgui.SameLine()
            imgui.TextDisabled("(?)")
            if imgui.IsItemHovered() then
                DrawStyledTooltip("Renderuje skelete igraca na visokim udaljenostima.")
            end

            addons.ToggleButton("VehicleRender", vehRenderEnabled)
            imgui.SameLine()
            imgui.Text(" Vehcile Render")
            imgui.SameLine()
            imgui.TextDisabled("(?)")
            if imgui.IsItemHovered() then
                DrawStyledTooltip("Renderuje informacije o vozilima na visokim udaljenostima.")
            end

            addons.ToggleButton("ShowNames", showNamesEnabled)
            imgui.SameLine()
            imgui.Text(" Show Names")
            imgui.SameLine()
            imgui.TextDisabled("(?)")
            if imgui.IsItemHovered() then
                DrawStyledTooltip("Renderuje nickove igraca na visokim udaljenostima.")
            end

            addons.ToggleButton("PlayerMonitor", playerMonitorEnabled)
            imgui.SameLine()
            imgui.Text(" Player Monitor")
            imgui.SameLine()
            imgui.TextDisabled("(?)")
            if imgui.IsItemHovered() then
                DrawStyledTooltip("Renderuje i prati stanje ulaska/izlaska igraca na serveru.")
            end

            addons.ToggleButton("FishEye", fisheyeEnabled)
            imgui.SameLine()
            imgui.Text(" Fish Eye")
            imgui.SameLine()
            imgui.TextDisabled("(?)")
            if imgui.IsItemHovered() then
                DrawStyledTooltip("Veci FOV, dalja kamera od igraca, veci pogled.")
            end

            addons.ToggleButton("InfinityRun", InfinityRunEnabled)
            imgui.SameLine()
            imgui.Text(" InfinityRun")
            imgui.SameLine()
            imgui.TextDisabled("(?)")
            if imgui.IsItemHovered() then
                DrawStyledTooltip("Trcanje bez umora, brze trcanje.")
            end

            addons.ToggleButton("InfinityFuel", InfinityFuelEnabled)
            imgui.SameLine()
            imgui.Text(" InfinityFuel")
            imgui.SameLine()
            imgui.TextDisabled("(?)")
            if imgui.IsItemHovered() then
                DrawStyledTooltip("Ne treba vam kljuc i gorivo, vozite bilo koje auto.")
            end

            addons.ToggleButton("CamHack", camhackEnabled)
            imgui.SameLine()
            imgui.Text(" CamHack")
            imgui.SameLine()
            imgui.TextDisabled("(?)")
            if imgui.IsItemHovered() then
                DrawStyledTooltip("Klasicni CamHack, palite ga na tipku C+1 a gasi na tipku C+2. Za povecanje brzine koristite + i - tipke.")
            end

            
            imgui.EndGroup()
        
            
            imgui.SameLine()
            imgui.SetCursorPosX(startGroupX + groupWidth + groupSpacing)
            imgui.BeginGroup()
            
        
            addons.ToggleButton("ShaddowBlade", shaddowbladeEnabled)
            imgui.SameLine()
            imgui.Text(" ShaddowBlade")
            imgui.SameLine()
            imgui.TextDisabled("(?)")
            if imgui.IsItemHovered() then
                DrawStyledTooltip("Igrac postaje ne vidljiv samo na nogama. [!NE RADI NA SVIM SERVERIMA!]")
            end
            
            addons.ToggleButton("TankMode", derbyModeEnabled)
            imgui.SameLine()
            imgui.Text(" Tank Mode")
            imgui.SameLine()
            imgui.TextDisabled("(?)")
            if imgui.IsItemHovered() then
                DrawStyledTooltip("Vozilo koje vozite postaje otporno na sve.")
            end

            addons.ToggleButton("EnterCrasher", entercrasherEnabled)
            imgui.SameLine()
            imgui.Text(" EnterCrasher")
            imgui.SameLine()
            imgui.TextDisabled("(?)")
            if imgui.IsItemHovered() then
                DrawStyledTooltip("Cheat koji automatski salje crash pakete igracima koji u vasoj blizini pokusavaju uci u vozilo. Morate biti onfoot kako bi se paketi uspijesno poslali. Ne radi na svim serverima.")
            end
            
            addons.ToggleButton("Roof Flip", roofFlipEnabled)
            imgui.SameLine()
            imgui.Text(" Roof Flip [K]")
            imgui.SameLine()
            imgui.TextDisabled("(?)")
            if imgui.IsItemHovered() then
                DrawStyledTooltip("Prvrce auto na krov jednim klikom na tipku K. Morate biti na mjestu vozaca.")
            end
            
            addons.ToggleButton("TurboHack", turboHackEnabled)
            imgui.SameLine()
            imgui.Text(" TurboHack [ALT]")
            imgui.SameLine()
            imgui.TextDisabled("(?)")
            if imgui.IsItemHovered() then
                DrawStyledTooltip("Boosta brzinu svakog auta, bez detekcije i bez prelaska limita.")
            end
        
            addons.ToggleButton("AirBrake", airbrakeEnabled)
            imgui.SameLine()
            imgui.Text(" AirBrake [RSHIFT]")
            imgui.SameLine()
            imgui.TextDisabled("(?)")
            if imgui.IsItemHovered() then
                DrawStyledTooltip("Letenje onfoot i sa autom, sporo, ali sigurno.")
            end
            
            addons.ToggleButton("ClickWarp", clickwarpEnabled)
            imgui.SameLine()
            imgui.Text(" ClickWarp[MMOUSE]")
            imgui.SameLine()
            imgui.TextDisabled("(?)")
            if imgui.IsItemHovered() then
                DrawStyledTooltip("Brzi Teleport do neke lokacije u dva klika (u vasem streamu!) \nPali se na tockic na misu (MIDDLE MOUSE) a lijevim klikom vas teleporta do lokacije.")
            end
            
            addons.ToggleButton("TrailerSnap", trailersnapEnabled)
            imgui.SameLine()
            imgui.Text(" TrailerSnap [C]")
            imgui.SameLine()
            imgui.TextDisabled("(?)")
            if imgui.IsItemHovered() then
                DrawStyledTooltip("Zakacite prazno vozilo za vase vozilo jednostavno!\nUdjite u auto, drzite C, nanisanite na drugo auto i pustite C – to vozilo ce se zakaciti za vase.\nMozete ga prevesti bilo gdje,koristeci bilo koje auto, drugi igraci mozda nece vidjeti da je zakaceno,\nali ce vidjeti novu poziciju vozila.\nZa otkacenje ponovo nanisanite na zakaceno vozilo i pustite C – vozilo ce se otkaciti.")
            end
            
            imgui.EndGroup()
        
            
            imgui.SameLine()
            imgui.SetCursorPosX(startGroupX + groupWidth * 2 + groupSpacing * 2)
            imgui.BeginGroup()
            
        
            addons.ToggleButton("PlayerResync", resyncEnabled)
            imgui.SameLine()
            imgui.Text(" Player Resync")
            imgui.SameLine()
            imgui.TextDisabled("(!)")
            if imgui.IsItemHovered() then
                DrawStyledTooltip("Resynca, i bypassa odredjene stvari na serveru, testirajte.")
            end
            
            addons.ToggleButton("BlockWeaponRPCs", wphackbypEnabled)
            imgui.SameLine()
            imgui.Text(" Block WeaponRPCs")
            imgui.SameLine()
            imgui.TextDisabled("(!)")
            if imgui.IsItemHovered() then
                DrawStyledTooltip("Blokira WeaponRPC-ove, ne preporucujem koristenje ukoliko ne znate sta radite.")
            end
            
            addons.ToggleButton("BlockPlayerRPCs", PlayerRPCsEnabled)
            imgui.SameLine()
            imgui.Text(" Block PlayerRPCs")
            imgui.SameLine()
            imgui.TextDisabled("(!)")
            if imgui.IsItemHovered() then
                DrawStyledTooltip("Blokira PlayerRPC-ove, ne preporucujem koristenje ukoliko ne znate sta radite.")
            end
            
            addons.ToggleButton("BlockVehicleRPCs", VehicleRPCsEnabled)
            imgui.SameLine()
            imgui.Text(" Block VehicleRPCs")
            imgui.SameLine()
            imgui.TextDisabled("(!)")
            if imgui.IsItemHovered() then
                DrawStyledTooltip("Blokira VehicleRPC-ove, ne preporucujem koristenje ukoliko ne znate sta radite.")
            end
            
            addons.ToggleButton("BlockWorldRPCs", WorldRPCsEnabled)
            imgui.SameLine()
            imgui.Text(" Block WorldRPCs")
            imgui.SameLine()
            imgui.TextDisabled("(!)")
            if imgui.IsItemHovered() then
                DrawStyledTooltip("Blokira WorldRPC-ove, ne preporucujem koristenje ukoliko ne znate sta radite.")
            end
            
            addons.ToggleButton("BlockSessionRPCs", SessionRPCsEnabled)
            imgui.SameLine()
            imgui.Text(" Block SessionRPCs")
            imgui.SameLine()
            imgui.TextDisabled("(!)")
            if imgui.IsItemHovered() then
                DrawStyledTooltip("Blokira SessionRPC-ove, ne preporucujem koristenje ukoliko ne znate sta radite.")
            end
            
            addons.ToggleButton("BlockEventRPCs", EventRPCsEnabled)
            imgui.SameLine()
            imgui.Text(" Block EventRPCs")
            imgui.SameLine()
            imgui.TextDisabled("(!)")
            if imgui.IsItemHovered() then
                DrawStyledTooltip("Blokira EventRPC-ove, ne preporucujem koristenje ukoliko ne znate sta radite.")
            end
            
            addons.ToggleButton("BlockOtherRPCs", OtherRPCsEnabled)
            imgui.SameLine()
            imgui.Text(" Block OtherRPCs")
            imgui.SameLine()
            imgui.TextDisabled("(!)")
            if imgui.IsItemHovered() then
                DrawStyledTooltip("Blokira ostale RPC-ove.")
            end
            
            
            imgui.EndGroup()
            
            imgui.NewLine()  

            local weapon_inputBoxXPosition = 385  
            local inputWidth_w = 105
            local buttonWidth_w = 50
            local spacing = -10 
            local additionalSpacing = 50 
            
            imgui.SetCursorPosX(weapon_inputBoxXPosition)

            
            imgui.TextColored(imgui.ImVec4(0.70, 0.40, 1.00, 1.00), "WeaponHack") 
            imgui.SameLine()
            imgui.TextDisabled("(?)")

            if imgui.IsItemHovered() then
                imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(14, 14))
                imgui.PushStyleVar(imgui.StyleVar.Alpha, 0.98)
                imgui.PushStyleColor(imgui.Col.PopupBg, imgui.ImVec4(0.05, 0.05, 0.07, 1.00)) 
                imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.90, 0.90, 0.95, 1.00))    

                imgui.BeginTooltip()

                
                imgui.TextColored(imgui.ImVec4(0.80, 0.50, 1.00, 1.00), "Kako koristiti ovaj cheat?")

                imgui.Separator()  

                imgui.PushTextWrapPos(360)
                imgui.Text("Omogucava spawnanje oruzja, kompatibilno s Resync ili WeaponRPC blokerom.\nNa nekim serverima Resync bolje radi, na drugima RPC — na tebi je da testiras.")
                imgui.PopTextWrapPos()

                imgui.EndTooltip()

                imgui.PopStyleColor(2)
                imgui.PopStyleVar(2)
            end

            
            imgui.SameLine()
            imgui.SetCursorPosX(weapon_inputBoxXPosition + inputWidth_w + buttonWidth_w + spacing * 2 + additionalSpacing)
            imgui.TextColored(imgui.ImVec4(0.70, 0.40, 1.00, 1.00), "VirtualVehicle")
            imgui.SameLine()
            imgui.TextDisabled("(!)")

            if imgui.IsItemHovered() then
                imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(14, 14))
                imgui.PushStyleVar(imgui.StyleVar.Alpha, 0.98)
                imgui.PushStyleColor(imgui.Col.PopupBg, imgui.ImVec4(0.05, 0.05, 0.07, 1.00))
                imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.90, 0.90, 0.95, 1.00))

                imgui.BeginTooltip()

                imgui.TextColored(imgui.ImVec4(0.80, 0.50, 1.00, 1.00), "Kako koristiti ovaj cheat?")
                imgui.Separator()

                imgui.PushTextWrapPos(380)
                imgui.Text("Privatno spawnano vozilo vidljivo samo tebi.\nKorisno za brzo kretanje.\nNe preporucuje se jer blokira ucitavanje streama dok vozis.\nVecina citova NECE raditi na ovim vozilima jer nisu registrirana kod servera.")
                imgui.PopTextWrapPos()

                imgui.EndTooltip()

                imgui.PopStyleColor(2)
                imgui.PopStyleVar(2)
            end

            imgui.PushItemWidth(inputWidth_w)  
            imgui.SetCursorPosX(weapon_inputBoxXPosition) 
            imgui.InputFloat("##WeaponID1", weaponID)  
            imgui.PopItemWidth() 
            
            imgui.SameLine()

            imgui.SetCursorPosX(weapon_inputBoxXPosition + inputWidth_w + spacing)  
            if imgui.Button(" Get it##weapon", imgui.ImVec2(buttonWidth_w, 20)) then  
                if not (resyncEnabled.v or wphackbypEnabled.v) then
                    sampAddChatMessage(bigbangText("Resync ili WeaponRPC Blocker mora biti upaljen!"), -1)
                else
                    local weaponIDValue = weaponID.v  
                    if weaponIDValue and (weaponIDValue < 1 or weaponIDValue > 46) then 
                        sampAddChatMessage(bigbangText("Nevazeci ID oruzja!"), -1)
                    else
                        givePlayerGun(weaponIDValue)
                    end
                end
            end
        
            imgui.SameLine()
            imgui.PushItemWidth(inputWidth_w)  
            imgui.SetCursorPosX(weapon_inputBoxXPosition + inputWidth_w + buttonWidth_w + spacing * 2 + additionalSpacing)  
            imgui.InputFloat("##VVehicle", vvehicleID)  
            imgui.PopItemWidth() 
            
            imgui.SameLine()
            imgui.SetCursorPosX(weapon_inputBoxXPosition + inputWidth_w + buttonWidth_w + spacing * 2 + additionalSpacing + inputWidth_w + spacing)  
            if imgui.Button(" Get it##vehicle", imgui.ImVec2(buttonWidth_w, 20)) then  
                VCreateCar(tostring(vvehicleID.v))
            end
        
            imgui.SetCursorPosY(imgui.GetCursorPosY() + 20)
            local total = (4 * buttonWidth) + (4 * 10)
            local posX = (windowWidth - total) / 2
        
            imgui.SetCursorPosX(posX)
            if imgui.Button("SPAWN", imgui.ImVec2(buttonWidth, 30)) then
                sampSpawnPlayer()
            end
        
            imgui.SameLine()
            if imgui.Button("UNFREEZE", imgui.ImVec2(buttonWidth, 30)) then
                freezeCharPosition(PLAYER_PED, true)
                freezeCharPosition(PLAYER_PED, false)
                setPlayerControl(PLAYER_HANDLE, true)
                restoreCameraJumpcut()
                clearCharTasksImmediately(PLAYER_PED)
            end
        
            imgui.SameLine()
            if imgui.Button("DIE", imgui.ImVec2(buttonWidth, 30)) then
                local positionX, positionY, positionZ = getCharCoordinates(PLAYER_PED)
                addExplosion(positionX, positionY, positionZ, 5)
                sampSendTakeDamage(65535, 100, 51, 3)
                setCharHealth(PLAYER_PED, -1000)
                taskDie(PLAYER_PED)
            end
        
            imgui.SameLine()
            if imgui.Button("TP Checkpoint", imgui.ImVec2(buttonWidth, 30)) then
                lua_thread.create(teleportPlayer)
            end

            imgui.SetCursorPosY(imgui.GetCursorPosY() + 35)

            local subText = "Ovo je zadnja verzija skripte."
            local subTextWidth = imgui.CalcTextSize(subText).x
            imgui.SetCursorPosX((windowWidth - subTextWidth) / 2)
            imgui.TextColored(imgui.ImVec4(1.0, 0.25, 0.25, 1.0), subText)

        end
        
        local function CenteredText(text, color)
            local textWidth = imgui.CalcTextSize(text).x
            local textPosX = (windowWidth - textWidth) / 2
            imgui.SetCursorPosX(textPosX)
        
            if color then
                imgui.TextColored(color, text)
            else
                imgui.Text(text)
            end
        end
        
        local function DrawCheatUI(title, enabled, cheatId, settings, instructions)
            local titleWidth = imgui.CalcTextSize(title).x
            imgui.SetCursorPosX((windowWidth - titleWidth) / 2)
            imgui.Text(title)
        
            local label = enabled.v and "Ukljuceno" or "Iskljuceno"
            local buttonSize = imgui.ImVec2(100, 30)
            local buttonPosX = (windowWidth - buttonSize.x) / 2
            imgui.SetCursorPosX(buttonPosX)
        
            if imgui.ToggleButton(label, enabled.v, buttonSize) then
                disableOtherCheats(cheatId)
            end
        
            if enabled.v then
                local itemWidth = 300
                imgui.SetCursorPosX((windowWidth - itemWidth) / 2)
                imgui.BeginGroup()
                imgui.PushItemWidth(itemWidth)
        
                for _, setting in ipairs(settings) do
                    imgui.Text(setting.label)
                
                    changed1, newValue1 = imgui.SliderFloat(setting.id, setting.value, setting.min, setting.max, "%.3f")

                
                    changed2, newValue2 = imgui.InputFloat("##" .. setting.id .. "_input", setting.value, 0.01, 0.5, 1)

                

                    if changed1 or changed2 then
                        setting.value = changed1 and newValue1 or newValue2
                    end
                end
                
        
                imgui.NewLine()
                for _, instruction in ipairs(instructions) do
                    CenteredText(instruction.text, instruction.color)
                end
        
                imgui.PopItemWidth()
                imgui.EndGroup()
            end
        end

        local function DrawCheatUI2(title, enabled, cheatId, settings, instructions, addonList, shiftRight)
            shiftRight = shiftRight or 75
        
            
            local titleWidth = imgui.CalcTextSize(title).x
            imgui.SetCursorPosX((windowWidth - titleWidth) / 2)
            imgui.Text(title)
        
            
            local label = enabled.v and "Ukljuceno" or "Iskljuceno"
            local toggleSize = imgui.ImVec2(100, 30)
            local togglePosX = (windowWidth - toggleSize.x) / 2
            imgui.SetCursorPosX(togglePosX)
        
            if imgui.ToggleButton(label, enabled.v, toggleSize) then
                disableOtherCheats(cheatId)
            end
        
            if enabled.v then
                local itemWidth = 300
                imgui.SetCursorPosX((windowWidth - itemWidth) / 2)
                imgui.BeginGroup()
                imgui.PushItemWidth(itemWidth)
        
                
                if settings ~= nil and #settings > 0 and addonList ~= nil and #addonList > 0 then
                    local buttonHeight = 30
                    local spacing = 20
                    local buttonWidth = 100
                    local totalWidth = (#addonList * (buttonWidth + spacing))
                    
                    imgui.NewLine()
                    local startPosX = ((windowWidth - totalWidth) / 2) + shiftRight
                    imgui.SetCursorPosX(startPosX)
                    
                    for i, addon in ipairs(addonList) do
                        if i > 1 then
                            imgui.SameLine(nil, spacing)
                        end

                        imgui.BeginGroup()
                        imgui.Text(addon.label)
                        imgui.SameLine()
                        addons.ToggleButton("##" .. addon.label, addon.var, imgui.ImVec2(buttonWidth, buttonHeight))
                        imgui.EndGroup()
                    end

                end

                
                for _, setting in ipairs(settings or {}) do
                    imgui.Text(setting.label)
        
                    local changed1, newValue1 = imgui.SliderFloat(setting.id, setting.value, setting.min, setting.max, "%.3f")
                    local changed2, newValue2 = imgui.InputFloat("##" .. setting.id .. "_input", setting.value, 0.01, 0.5, 1)
        
                    if changed1 or changed2 then
                        setting.value = changed1 and newValue1 or newValue2
                    end
                end
        
                imgui.NewLine()
                for _, instruction in ipairs(instructions or {}) do
                    CenteredText(instruction.text, instruction.color)
                end
        
                imgui.PopItemWidth()
                imgui.EndGroup()
            end
        end
        
        
        
        if activeMode.v == 1 then
            DrawCheatUI(
                "Rvanka InCar - Bacanje igraca koristeci vozila - vehicle sync.",
                rVankaEnabled,
                "rvanka",
                {
                    {label = "Brzina bacanja", id = "##Brzina", value = rVankaSpeed, min = 0.1, max = 10.0},
                    {label = "Povecanje brzine", id = "##Intenzitet", value = rVankaIntensity, min = 0.01, max = 0.1}
                },
                {
                    {text = "Kako koristiti ovaj cheat?", color = imgui.ImVec4(1.0, 0.55, 0.0, 1.0)},
                    {text = "Morate biti u vozilu, a vasa meta takodje mora biti u vozilu i u radijusu od 50 metara."},
                    {text = "Drzanjem tipke X na tastaturi aktivirate cheat koji putem vehicle synca udara metu."},
                    {text = "Meta ce biti bacena u raznim nasumicnim pravcima oko vaseg vozila."},
                    {text = "Postavke mozete prilagoditi u zavisnosti od anticheata na serveru."},
                    {text = "Default vrijednosti rade na vecini servera, oko 90%."}
                }
            )
        end
        
        
        
        
        if activeMode.v == 2 then
            DrawCheatUI(
                "Trailer Crasher - Kresovanje igraca u vozilu sa Towtruck-om.",
                crasherEnabled,
                "crasher",
                {
                    {label = "Radni domet (metri)", id = "##CrasherRange", value = crasherRange, min = 10.0, max = 40.0},
                    {label = "Dubina bacanja zrtve", id = "##CrasherDepth", value = crasherDepth, min = 10.0, max = 200.0}
                },
                {
                    {text = "Kako koristiti ovaj cheat?", color = imgui.ImVec4(1.0, 0.55, 0.0, 1.0)},
                    {text = "Morate biti u vozilu Towtruck, mehanickom vozilu koje ima mogucnosti kacati druga auta."},
                    {text = "Prolazeci pored igraca u vozilu, automatski ih crashate bez potrebe za aktivacijom."},
                    {text = "Podesavanja se razlikuju od servera do servera i zavise od dometa i dubine."},
                    {text = "Veci domet povecava rizik da budete primeceni, dok veca dubina povecava efikasnost."}
                }
            )
        end
        
        if activeMode.v == 3 then
            DrawCheatUI(
                "NJ Destroyer - Portanje i zatim unistavanje bilo kojeg vozila u kojem je igrac.",
                njDestroyerEnabled,
                "njDestroyer",
                {
                    {label = "Minimalni Radni domet (metri)", id = "##VehMin", value = njDestroyerMinRange, min = 1.0, max = 100.0},
                    {label = "Maksimalni Radni domet (metri)", id = "##VehMax", value = njDestroyerMaxRange, min = 150.0, max = 300.0}
                },
                {
                    {text = "Kako koristiti ovaj cheat?", color = imgui.ImVec4(1.0, 0.55, 0.0, 1.0)},
                    {text = "Aktivira se pritiskom tipke X na tastaturi, samo dok ste onfoot."},
                    {text = "Ako se u dometu nalazi vozilo sa vozacem, cheat pokusava"},
                    {text = "Izbaciti vozaca i unistiti vozilo bez vaseg pomijeranja."},
                    {text = "Problemeticno je detektovanje RPC poziva i obavestenja u chatu."},
                    {text = "Ali vazno je napomenuti da vas zrtva nece primjetiti."}
                }
            )
        end
        
        
        if activeMode.v == 4 then
            local shiftRight = 15 
        
            DrawCheatUI2(
                "Angle Shot - Lansiranje igraca koji su ispred ili iza vas.",
                angleShotEnabled,
                "angleshot",
                {
                    {label = "Brzina bacanja", id = "##WorkingRange", value = angleshot_speed, min = 0.1, max = 10.0},
                    {label = "Povecanje brzine", id = "##Delay", value = angleshot_intensity, min = 0.01, max = 0.1}
                },
                {
                    {text = "Kako koristiti ovaj cheat?", color = imgui.ImVec4(1.0, 0.55, 0.0, 1.0)},
                    {text = "Morate biti u vozilu i drzati lijevu tipku misa da aktivirate cheat."},
                    {text = "Brzina bacanja ce se povecavati u skladu sa podesavanjima."},
                    {text = "Drugi igraci ce vidjeti blago skakutanje vaseg vozila gore-dole."},
                    {text = "Pokusajte se zabijati u igrace da izazovete guranje i bacanje."},
                    {text = "Default vrijednosti rade na vecini servera, oko 90%."}
                },
                {
                    { label = "Quaternion", var = quaternionEnabled }
                },
                shiftRight 
            )
        end




        
         
        if activeMode.v == 5 then
            DrawCheatUI(
                "Car Thrower - Bacanje praznih vozila po serveru.",
                carThrowerEnabled,
                "carthrower",
                {
                    {label = "Intenzitet bacanja", id = "##ThrowIntensity", value = throwIntensity, min = 3.0, max = 10.0},
                    {label = "Radni domet (metri)", id = "##ThrowRange", value = throwRange, min = 5.0, max = 100.0}
                },
                {
                    {text = "Kako koristiti ovaj cheat?", color = imgui.ImVec4(1.0, 0.55, 0.0, 1.0)},
                    {text = "Morate biti onfoot i drzati tipku X na tastaturi za aktivaciju cheata."},
                    {text = "Ako se u radnom dometu nalazi prazno vozilo, pokusace ga baciti bez vaseg pomeranja."},
                    {text = "Zbog velike brzine i kolicine paketa, vozila mogu postati desyncovana sa serverom."},
                    {text = "Preporucuje se lagano pritiskanje i otpustanje klika radi syncanja sa serverom."},
                    {text = "U protivnom, efekat moze izostati i drugi igraci to nece vidjeti."}
                }
            )
        end
        
        
        if activeMode.v == 6 then
            local shiftRight = 15 
        
            DrawCheatUI2(
                "Stream Lagger - Bagovanje vozila u vasem streamu.",
                streamLaggerEnabled,
                "slagger",
                {
                    {label = "Odgoda akcije (ms)", id = "##LaggerDelay", value = laggerDelay, min = 120.0, max = 500.0},
                    {label = "Radni domet (metri)", id = "##LaggerRange", value = laggerRange, min = 50.0, max = 400.0}
                },
                {
                    {text = "Kako koristiti ovaj cheat?", color = imgui.ImVec4(1.0, 0.55, 0.0, 1.0)},
                    {text = "Morate biti u vozilu i drzati tipku X na tastaturi da aktivirate cheat."},
                    {text = "Ako se u radnom dometu nalaze prazna vozila, pokusace ih zbugati jedno u drugo."},
                    {text = "Sva vozila se pomijeraju u jednu tacku, sto izaziva veliki FPS pad."},
                    {text = "Ostali igraci nece vidjeti bag odmah, sve dok ne resetuju stream (odmaknu se i pridju ponovo)."},
                    {text = "AC Bypass koristi alternativne metode da zaobidje anticheat i osigura efekat."},
                    {text = "Ako sa AC Bypass-om ne vidite bag odmah, to znaci da efekat radi u pozadini."}
                },
                {
                    { label = "AC Bypass", var = methodslagger }
                },
                shiftRight 
            )
        end
        
        
        if activeMode.v == 7 then
            DrawCheatUI(
                "Spin Crusher - Bacanje igraca koristeci sync i prazno vozilo.",
                spinCrusherEnabled,
                "scrusher",
                {
                    {label = "Vertikalna brzina", id = "##crusherSpeed", value = scrusherSpeedVertical, min = 0.1, max = 100.0},
                    {label = "Horizontalna brzina", id = "##crusherRange", value = scrusherSpeedHorizontal, min = 0.1, max = 100.0}
                },
                {
                    {text = "Kako koristiti ovaj cheat?", color = imgui.ImVec4(1.0, 0.55, 0.0, 1.0)},
                    {text = "Morate biti onfoot i u blizini mora biti jedno prazno vozilo."},
                    {text = "Pritiskom tipke X na tastaturi vozilo se nakaci na vasu glavu (vi to ne vidite, drugi da)."},
                    {text = "Kada hodate oko igraca, vozilo rotira i baca ih u raznim pravcima kao propeler."},
                    {text = "Efekat se prekida lijevom tipkom misa — time se vozilo otkaci sa vas."},
                    {text = "Preporucuje se povremeno otkaciti i ponovo zakaciti vozilo radi boljeg synca."},
                    {text = "Ovaj cheat ne radi na svim serverima zbog naprednih sync filtera (raknet/pawn)."},
                    {text = "Ako vas anticheat detektuje, prilagodite vertikalnu i horizontalnu brzinu."}
                }
            )
        end
        

        local function CenteredText(text, color)
            local textWidth = imgui.CalcTextSize(text).x
            local textPosX = (windowWidth - textWidth) / 2
            imgui.SetCursorPosX(textPosX)
        
            if color then
                imgui.TextColored(color, text)
            else
                imgui.Text(text)
            end
        end
        
        local function DrawCheatUI(title, enabled, cheatId, settings, instructions)
            local titleWidth = imgui.CalcTextSize(title).x
            imgui.SetCursorPosX((windowWidth - titleWidth) / 2)
            imgui.Text(title)
        
            local label = enabled.v and "Ukljuceno" or "Iskljuceno"
            local buttonSize = imgui.ImVec2(100, 30)
            local buttonPosX = (windowWidth - buttonSize.x) / 2
            imgui.SetCursorPosX(buttonPosX)
        
            if imgui.ToggleButton(label, enabled.v, buttonSize) then
                disableOtherCheats(cheatId)
            end
        
            if enabled.v then
                local itemWidth = 300
                imgui.SetCursorPosX((windowWidth - itemWidth) / 2)
                imgui.BeginGroup()
                imgui.PushItemWidth(itemWidth)
        
                for _, setting in ipairs(settings) do
                    imgui.Text(setting.label)
                    imgui.SliderFloat(setting.id, setting.value, setting.min, setting.max, "%.0f")
                end
        
                imgui.NewLine()
                for _, instruction in ipairs(instructions) do
                    CenteredText(instruction.text, instruction.color)
                end
        
                imgui.PopItemWidth()
                imgui.EndGroup()
            end
        end
        
        
        imgui.SetCursorPosY(windowHeight - 85)
        
        local setWidth = 85
        imgui.SetCursorPosX((windowWidth - setWidth) / 2)
        if imgui.Button("SETTINGS", imgui.ImVec2(setWidth, 25)) then
            settingsVisible.v = not settingsVisible.v
        end
        
        local footerText = "BIGBANG COMMUNITY 2025 ©"
        local footerY = windowHeight - 45
        imgui.SetCursorPosY(footerY)
        local footerTextWidth = imgui.CalcTextSize(footerText).x
        imgui.SetCursorPosX((windowWidth - footerTextWidth) / 2)
        imgui.TextColored(imgui.ImVec4(0.75, 0.45, 0.95, 1.0), footerText)
        
        imgui.End()
        imgui.PopStyleVar()
    end
end
function imgui.Hint(text, delay)
    if imgui.IsItemHovered() then
        if go_hint == nil then go_hint = os.clock() + (delay and delay or 0.0) end
        local alpha = (os.clock() - go_hint) * 5 
        if os.clock() >= go_hint then
            imgui.BeginTooltip()
            imgui.PushTextWrapPos(450)
            imgui.TextUnformatted(text)
            if not imgui.IsItemVisible() and imgui.GetStyle().Alpha == 1.0 then go_hint = nil end
            imgui.PopTextWrapPos()
            imgui.EndTooltip()
        end
    end
end

function GUI_STYLE()

    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col

    colors[clr.Text] = imgui.ImVec4(0.95, 0.96, 0.98, 1.00)
    colors[clr.WindowBg] = imgui.ImVec4(0.03, 0.035, 0.04, 1.00)     
    colors[clr.FrameBg]   = imgui.ImVec4(0.05, 0.055, 0.06, 1.00)    

    
    colors[clr.FrameBgHovered] = imgui.ImVec4(0.88, 0.90, 0.94, 1.00) 
    colors[clr.FrameBgActive] = imgui.ImVec4(0.95, 0.96, 0.98, 1.00) 
    colors[clr.Button] = imgui.ImVec4(0.12, 0.13, 0.14, 1.00) 
    colors[clr.ButtonHovered] = imgui.ImVec4(0.09, 0.095, 0.10, 1.00)
    colors[clr.ButtonActive] = imgui.ImVec4(0.82, 0.60, 1.00, 1.00) 



    colors[clr.CheckMark] = imgui.ImVec4(0.80, 0.40, 0.95, 1.00)
    colors[clr.Separator] = imgui.ImVec4(0.50, 0.40, 0.60, 1.00)

    style.WindowRounding = 12.0
    style.FrameRounding = 6.0
    style.GrabRounding = 6.0
    style.ScrollbarSize = 14.0
    style.ItemSpacing = imgui.ImVec2(10, 8)
    style.ItemInnerSpacing = imgui.ImVec2(8, 6)
end

function onExitScript()
    SaveSettings()
    SaveJSON('playermonitor', var['playermonitor'])
    restoreOriginalWeaponData()
end


function SaveJSON(name, table)                                                                                        
    encodedTable = encodeJson(table)                                                                                
    local file = io.open(getWorkingDirectory()..'/BIGBANG2/'..name..'.json', "w")
    file:write(encodedTable)                                                                                      
    file:flush()                                                                                                      
    file:close()                                                                                                  
end



function onScriptTerminate(script, quitGame)
    SaveSettings()
    SaveJSON('playermonitor', var['playermonitor'])  
end  

function sampev.onPlayerJoin(id, color, npc, nick)
    if npc == false then
        table.insert(players, '{FFFFFF}'..nick..' ({4dff4d}Konektovan{FFFFFF})')
    end
end
function sampev.onPlayerQuit(id, reason)
    table.insert(players, '{FFFFFF}'..sampGetPlayerNickname(id)..' ({ff3838}Diskonektovan{FFFFFF} [{696969}'..reasons[reason]..'{FFFFFF}])')
end

function sampev.onPlayerDeath(playerid)
	if dkill_victimid == playerid then 
		dkill_victimkilled = true	
	end
end



function sampev.onSetPlayerPos(pos)
    if rvanka_nop then return false end
    if shaddowbladeEnabled.v then 
        local PLAYER_POS = {getCharCoordinates(PLAYER_PED)}
        local DISTANCE = getDistanceBetweenCoords3d(pos.x, pos.y, pos.z, PLAYER_POS[1], PLAYER_POS[2], PLAYER_POS[3])
        if DISTANCE <= 5 then 
            return false 
        end
    end
end


function sampev.onSendVehicleSync(data)
    if slagger_act then return false end
    if tp_active then return false end
    if rvanka_nop then return false end
    if not isCharInAnyCar(PLAYER_PED) then return end

    local car = storeCarCharIsInNoSave(PLAYER_PED)
    local enable = derbyModeEnabled.v

    setCarCanBeDamaged(car, not enable)
    setCarCanBeVisiblyDamaged(car, not enable)
    setCanBurstCarTires(car, not enable)

    if enable then
        setCarHeavy(car, true)
    else
        setCarHeavy(car, false)
    end
    
    if crasherEnabled.v then
        data.trailerId = 0
    end
    
    if angleshot_act then
        local camX, camY = getActiveCameraCoordinates()
        local px, py, pz = getCharCoordinates(PLAYER_PED)
        local heading = getHeadingFromVector2d(px - camX, py - camY)

        data.position.x = px
        data.position.y = py - 0.5
        data.position.z = pz - 0.5

        if quaternionEnabled.v then

            data.quaternion[0] = 1
            data.quaternion[1] = 1
            data.quaternion[2] = 0
            data.quaternion[3] = 0
        end
        data.moveSpeed = angleshot_getMoveSpeed(heading, angleshot_cspeed)

    end
    
    
    if airbrakeEnabled.v and arbrk_active then
        local m = arbrk_getMoveSpeed(getCharHeading(PLAYER_PED), arbrk_speed_vehicle_sync)
        data.moveSpeed = {m.x, m.y, data.moveSpeed.z}
        return data
    end    
end

function onSendPacket(id, bitStream, priority, reliability, orderingChannel)
    if resyncEnabled.v then
        if id == 204 then 
            return false 
        end
    end
    if wphackbypEnabled.v and id == 204 then
        wph_bit(weaponIDValue or 24) 
        return false
    end

    if dkill_procces then return false end

end

function onReceiveRpc(id, bitStream)
    if wphackbypEnabled.v or PlayerRPCsEnabled.v or VehicleRPCsEnabled.v or WorldRPCsEnabled.v or SessionRPCsEnabled.v or EventRPCsEnabled.v or OtherRPCsEnabled.v then
        if RPC[id] then
            return false
        end
    end
end

function sampev.onRemovePlayerFromVehicle()
    if rvanka_nop then return false end
end

function sampev.onSetVehiclePosition()
    if rvanka_nop then return false end
    if spincrusher_STATE then 
        if vehicleId == spincrusher_VEHICLETARGET then 
            spincrusher_STATE = false;
            spincrusher_ATTACHED = false;
            spincrusher_GUICIRCLE[0] = false
            spincrusher_SEARCHTARGET = nil
            spincrusher_VEHICLETARGET = -1;
        end
    end
end

function sampev.onSendPlayerSync(data)

    if rvanka_nop then return false end


    if isFlipped then
        data.quaternion[0] = 0
        data.quaternion[1] = 1
        data.quaternion[2] = 0
        data.quaternion[3] = 0
        isFlipped = false 
    end

    if showNamesEnabled.v then
        if not nameTagActive then
            nameTagOn()  
            nameTagActive = true 
        end
    else
        if nameTagActive then
            nameTagOff()  
            nameTagActive = false  
        end
    end
    
    if tp_active then return false end
    
    if shaddowbladeEnabled.v then
        data.surfingVehicleId = 2005
        data.surfingOffsets.z = data.surfingOffsets.z 
    end
    

    if slagger_act then return false end
    
    if resyncEnabled.v then
        if resync_packet < 3 then 
            sampSendTakeDamage(0, 1.3, 0, 3)
            resync_packet = resync_packet + 1
            data.position.z = tonumber('NaN')
            data.moveSpeed.z = 0
            sampSendTakeDamage(0, 1.3, 0, 3)
        else
            resync_packet = 0
            data.weapon = 0
        end
    end

    if njdestroy_nop then 
        return false
    end

    
    if airbrakeEnabled.v and arbrk_active then
        local m = arbrk_getMoveSpeed(getCharHeading(PLAYER_PED), arbrk_speed_player_sync)
        data.moveSpeed = {m.x, m.y, data.moveSpeed.z}
        return data
    end
end


function givePlayerGun(id)
    local model = getWeapontypeModel(id)
    requestModel(model)
    loadAllModelsNow()

    if lastGivenWeaponID then
        removeWeaponFromChar(PLAYER_PED, lastGivenWeaponID)  
    end

    giveWeaponToChar(PLAYER_PED, id, 999)
    lastGivenWeaponID = id  
end

function cam_hack()
	flymode = 0  
	speed = 1.0
	radarHud = 0
	time = 0
	keyPressed = 0
	while true do
		wait(0)
        if camhackEnabled.v then

            time = time + 1
            if isKeyDown(VK_C) and isKeyDown(VK_1) and camhackEnabled.v then
                if flymode == 0 then
                    displayRadar(false)
                    displayHud(false)	    
                    posX, posY, posZ = getCharCoordinates(playerPed)
                    angZ = getCharHeading(playerPed)
                    angZ = angZ * -1.0
                    setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
                    angY = 0.0
                    lockPlayerControl(true)
                    flymode = 1
                end
            end
            if flymode == 1 and not sampIsChatInputActive() and not isSampfuncsConsoleActive() then
                offMouX, offMouY = getPcMouseMovement()  
                
                offMouX = offMouX / 4.0
                offMouY = offMouY / 4.0
                angZ = angZ + offMouX
                angY = angY + offMouY

                if angZ > 360.0 then angZ = angZ - 360.0 end
                if angZ < 0.0 then angZ = angZ + 360.0 end

                if angY > 89.0 then angY = 89.0 end
                if angY < -89.0 then angY = -89.0 end   

                radZ = math.rad(angZ) 
                radY = math.rad(angY)             
                sinZ = math.sin(radZ)
                cosZ = math.cos(radZ)      
                sinY = math.sin(radY)
                cosY = math.cos(radY)       
                sinZ = sinZ * cosY      
                cosZ = cosZ * cosY 
                sinZ = sinZ * 1.0      
                cosZ = cosZ * 1.0     
                sinY = sinY * 1.0        
                poiX = posX
                poiY = posY
                poiZ = posZ      
                poiX = poiX + sinZ 
                poiY = poiY + cosZ 
                poiZ = poiZ + sinY      
                pointCameraAtPoint(poiX, poiY, poiZ, 2)

                curZ = angZ + 180.0
                curY = angY * -1.0      
                radZ = math.rad(curZ) 
                radY = math.rad(curY)                   
                sinZ = math.sin(radZ)
                cosZ = math.cos(radZ)      
                sinY = math.sin(radY)
                cosY = math.cos(radY)       
                sinZ = sinZ * cosY      
                cosZ = cosZ * cosY 
                sinZ = sinZ * 10.0     
                cosZ = cosZ * 10.0       
                sinY = sinY * 10.0                       
                posPlX = posX + sinZ 
                posPlY = posY + cosZ 
                posPlZ = posZ + sinY              
                angPlZ = angZ * -1.0
                

                radZ = math.rad(angZ) 
                radY = math.rad(angY)             
                sinZ = math.sin(radZ)
                cosZ = math.cos(radZ)      
                sinY = math.sin(radY)
                cosY = math.cos(radY)       
                sinZ = sinZ * cosY      
                cosZ = cosZ * cosY 
                sinZ = sinZ * 1.0      
                cosZ = cosZ * 1.0     
                sinY = sinY * 1.0        
                poiX = posX
                poiY = posY
                poiZ = posZ      
                poiX = poiX + sinZ 
                poiY = poiY + cosZ 
                poiZ = poiZ + sinY      
                pointCameraAtPoint(poiX, poiY, poiZ, 2)

                if isKeyDown(VK_W) then      
                    radZ = math.rad(angZ) 
                    radY = math.rad(angY)                   
                    sinZ = math.sin(radZ)
                    cosZ = math.cos(radZ)      
                    sinY = math.sin(radY)
                    cosY = math.cos(radY)       
                    sinZ = sinZ * cosY      
                    cosZ = cosZ * cosY 
                    sinZ = sinZ * speed      
                    cosZ = cosZ * speed       
                    sinY = sinY * speed  
                    posX = posX + sinZ 
                    posY = posY + cosZ 
                    posZ = posZ + sinY      
                    setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)      
                end 

                radZ = math.rad(angZ) 
                radY = math.rad(angY)             
                sinZ = math.sin(radZ)
                cosZ = math.cos(radZ)      
                sinY = math.sin(radY)
                cosY = math.cos(radY)       
                sinZ = sinZ * cosY      
                cosZ = cosZ * cosY 
                sinZ = sinZ * 1.0      
                cosZ = cosZ * 1.0     
                sinY = sinY * 1.0         
                poiX = posX
                poiY = posY
                poiZ = posZ      
                poiX = poiX + sinZ 
                poiY = poiY + cosZ 
                poiZ = poiZ + sinY      
                pointCameraAtPoint(poiX, poiY, poiZ, 2)

                if isKeyDown(VK_S) then  
                    curZ = angZ + 180.0
                    curY = angY * -1.0      
                    radZ = math.rad(curZ) 
                    radY = math.rad(curY)                   
                    sinZ = math.sin(radZ)
                    cosZ = math.cos(radZ)      
                    sinY = math.sin(radY)
                    cosY = math.cos(radY)       
                    sinZ = sinZ * cosY      
                    cosZ = cosZ * cosY 
                    sinZ = sinZ * speed      
                    cosZ = cosZ * speed       
                    sinY = sinY * speed                       
                    posX = posX + sinZ 
                    posY = posY + cosZ 
                    posZ = posZ + sinY      
                    setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
                end 

                radZ = math.rad(angZ) 
                radY = math.rad(angY)             
                sinZ = math.sin(radZ)
                cosZ = math.cos(radZ)      
                sinY = math.sin(radY)
                cosY = math.cos(radY)       
                sinZ = sinZ * cosY      
                cosZ = cosZ * cosY 
                sinZ = sinZ * 1.0      
                cosZ = cosZ * 1.0     
                sinY = sinY * 1.0        
                poiX = posX
                poiY = posY
                poiZ = posZ      
                poiX = poiX + sinZ 
                poiY = poiY + cosZ 
                poiZ = poiZ + sinY      
                pointCameraAtPoint(poiX, poiY, poiZ, 2)
                
                if isKeyDown(VK_A) then  
                    curZ = angZ - 90.0
                    radZ = math.rad(curZ)
                    radY = math.rad(angY)
                    sinZ = math.sin(radZ)
                    cosZ = math.cos(radZ)
                    sinZ = sinZ * speed
                    cosZ = cosZ * speed
                    posX = posX + sinZ
                    posY = posY + cosZ
                    setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
                end 

                radZ = math.rad(angZ) 
                radY = math.rad(angY)             
                sinZ = math.sin(radZ)
                cosZ = math.cos(radZ)      
                sinY = math.sin(radY)
                cosY = math.cos(radY)       
                sinZ = sinZ * cosY      
                cosZ = cosZ * cosY 
                sinZ = sinZ * 1.0      
                cosZ = cosZ * 1.0     
                sinY = sinY * 1.0        
                poiX = posX
                poiY = posY
                poiZ = posZ      
                poiX = poiX + sinZ 
                poiY = poiY + cosZ 
                poiZ = poiZ + sinY
                pointCameraAtPoint(poiX, poiY, poiZ, 2)       

                if isKeyDown(VK_D) then  
                    curZ = angZ + 90.0
                    radZ = math.rad(curZ)
                    radY = math.rad(angY)
                    sinZ = math.sin(radZ)
                    cosZ = math.cos(radZ)       
                    sinZ = sinZ * speed
                    cosZ = cosZ * speed
                    posX = posX + sinZ
                    posY = posY + cosZ      
                    setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
                end 

                radZ = math.rad(angZ) 
                radY = math.rad(angY)             
                sinZ = math.sin(radZ)
                cosZ = math.cos(radZ)      
                sinY = math.sin(radY)
                cosY = math.cos(radY)       
                sinZ = sinZ * cosY      
                cosZ = cosZ * cosY 
                sinZ = sinZ * 1.0      
                cosZ = cosZ * 1.0     
                sinY = sinY * 1.0        
                poiX = posX
                poiY = posY
                poiZ = posZ      
                poiX = poiX + sinZ 
                poiY = poiY + cosZ 
                poiZ = poiZ + sinY      
                pointCameraAtPoint(poiX, poiY, poiZ, 2)   

                if isKeyDown(VK_SPACE) then  
                    posZ = posZ + speed
                    setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
                end 

                radZ = math.rad(angZ) 
                radY = math.rad(angY)             
                sinZ = math.sin(radZ)
                cosZ = math.cos(radZ)      
                sinY = math.sin(radY)
                cosY = math.cos(radY)       
                sinZ = sinZ * cosY      
                cosZ = cosZ * cosY 
                sinZ = sinZ * 1.0      
                cosZ = cosZ * 1.0     
                sinY = sinY * 1.0       
                poiX = posX
                poiY = posY
                poiZ = posZ      
                poiX = poiX + sinZ 
                poiY = poiY + cosZ 
                poiZ = poiZ + sinY      
                pointCameraAtPoint(poiX, poiY, poiZ, 2) 

                if isKeyDown(VK_SHIFT) then  
                    posZ = posZ - speed
                    setFixedCameraPosition(posX, posY, posZ, 0.0, 0.0, 0.0)
                end 

                radZ = math.rad(angZ) 
                radY = math.rad(angY)             
                sinZ = math.sin(radZ)
                cosZ = math.cos(radZ)      
                sinY = math.sin(radY)
                cosY = math.cos(radY)       
                sinZ = sinZ * cosY      
                cosZ = cosZ * cosY 
                sinZ = sinZ * 1.0      
                cosZ = cosZ * 1.0     
                sinY = sinY * 1.0       
                poiX = posX
                poiY = posY
                poiZ = posZ      
                poiX = poiX + sinZ 
                poiY = poiY + cosZ 
                poiZ = poiZ + sinY      
                pointCameraAtPoint(poiX, poiY, poiZ, 2) 

                if keyPressed == 0 and isKeyDown(VK_F10) then
                    keyPressed = 1
                    if radarHud == 0 then
                        displayRadar(true)
                        displayHud(true)
                        radarHud = 1
                    else
                        displayRadar(false)
                        displayHud(false)
                        radarHud = 0
                    end
                end


                if isKeyDown(187) then 
                    speed = speed + 0.01
                    printStringNow(speed, 1000)
                end 
                            
                if isKeyDown(189) then 
                    speed = speed - 0.01 
                    if speed < 0.01 then speed = 0.01 end
                    printStringNow(speed, 1000)
                end   

                if isKeyDown(VK_C) and isKeyDown(VK_2) and camhackEnabled.v then
                    displayRadar(true)
                    displayHud(true)
                    radarHud = 0	    
                    angPlZ = angZ * -1.0
                    lockPlayerControl(false)
                    restoreCameraJumpcut()
                    setCameraBehindPlayer()
                    flymode = 0     
                end
            end
	    end
        if flymode == 1 and not camhackEnabled.v then
            displayRadar(true)
            displayHud(true)
            radarHud = 0	    
            angPlZ = angZ * -1.0
            lockPlayerControl(false)
            restoreCameraJumpcut()
            setCameraBehindPlayer()
            flymode = 0 
        end
    end
end


local esp_lines = mimgui.OnFrame(
    function()
        return espEnabled.v and isSampAvailable() and not isPauseMenuActive()
    end,
    function(draw)
        draw.HideCursor = true

        local drawList = mimgui.GetBackgroundDrawList()

        
        local colPurple = mimgui.ColorConvertFloat4ToU32(mimgui.ImVec4(0.64, 0.33, 0.94, 1.00))

        for i = 0, sampGetMaxPlayerId() do
            if sampIsPlayerConnected(i) then
                local result, cped = sampGetCharHandleBySampPlayerId(i)
                if result and doesCharExist(cped) and isCharOnScreen(cped) then
                    local bones = {3, 4, 5, 51, 52, 41, 42, 31, 32, 33, 21, 22, 23, 2}

                    for v = 1, #bones do
                        local bp1 = bones[v]
                        local bp2 = bones[v] + 1

                        local x1, y1, z1 = getBodyPartCoordinates(bp1, cped)
                        local x2, y2, z2 = getBodyPartCoordinates(bp2, cped)

                        local sx1, sy1 = convert3DCoordsToScreen(x1, y1, z1)
                        local sx2, sy2 = convert3DCoordsToScreen(x2, y2, z2)

                        if sx1 and sx2 then
                            drawList:AddLine(mimgui.ImVec2(sx1, sy1), mimgui.ImVec2(sx2, sy2), colPurple, 3.5)
                        end
                    end

                    
                    for v = 4, 5 do
                        local x2, y2, z2 = getBodyPartCoordinates(v * 10 + 1, cped)
                        local sx2, sy2 = convert3DCoordsToScreen(x2, y2, z2)

                        local x1, y1, z1 = getBodyPartCoordinates(2, cped)
                        local sx1, sy1 = convert3DCoordsToScreen(x1, y1, z1)

                        if sx1 and sx2 then
                            drawList:AddLine(mimgui.ImVec2(sx1, sy1), mimgui.ImVec2(sx2, sy2), colPurple, 3.5)
                        end
                    end
                end
            end
        end
    end
)

function infinity_run()
    while true do
        wait(1)
        if sampIsLocalPlayerSpawned() then
            if InfinityRunEnabled.v and isCharOnFoot(playerPed) and not isCharInAnyCar(playerPed) and isKeyDown(16) and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then
                setGameKeyState(16, 256)
                wait(10)
                setGameKeyState(16, 0)
            end
        end
        if isSampAvailable() then
            memory.setint8(0xB7CEE4, 1)
        end
    end
end

function infinity_fuel()
    while true do
        wait(0)
        if InfinityFuelEnabled.v then
            if isCharInAnyCar(PLAYER_PED) then
                if not isKeyDown(87) then 
                    if isKeyDown(83) then 
                    end
                end

                local veh = storeCarCharIsInNoSave(PLAYER_PED)
                if veh and not sampIsChatInputActive() then
                    setCarEngineOn(veh, true)
                end
            end
        end
    end
end

function render_cars()
	while true do
		wait(0)
		if car_render then
			veh = getAllVehicles()
			for k, v in ipairs(veh) do
				if isCarOnScreen(v) then
					model = cars_render[getCarModel(v) - 399] .. ' (' .. tostring(select(2, sampGetVehicleIdByCarHandle(v))) .. ')'
					clr, _ = getCarColours(v)
					cx, cy, cz = getCarCoordinates(v)
					x, y = convert3DCoordsToScreen(cx, cy, cz)
					lenght = renderGetFontDrawTextLength(font_render, model, true)
					height = renderGetFontDrawHeight(font_render)
					textcolor = 0xFFFF00FF
					if getCarDoorLockStatus(v) == 2 then
						textcolor = 0xFFFF00FF
					end
					renderFontDrawText(font_render, model, x - (lenght + 5 + 18) / 2, y - (height + 7 + 14) / 2, textcolor, true)
					renderDrawBox(x + (lenght + 5 - 18) / 2, y - (7 + 14) / 2 - 9, 18, 18, 0xFFFFFFFF)
					renderDrawBox(x + (lenght + 5 - 18) / 2 + 2, y - (7 + 14) / 2 - 7, 14, 14, 0xFF000000 + render_colors[clr + 1] / 0x100)
					healthbox = lenght + 5 + 18 + 8
					healthbox2 = healthbox * (getCarHealth(v) / 1000)
					renderDrawBox(x - healthbox / 2 - 1, y + (height + 7 - 14) / 2, healthbox + 2, 14, 0xFF000000)
					renderDrawBox(x - healthbox / 2, y + (height + 7 - 14) / 2 + 1, healthbox, 12, 0xFF6A0DAD)
					renderDrawBox(x - healthbox / 2, y + (height + 7 - 14) / 2 + 1, healthbox2, 12, 0xFFA74AC7)
					
				end
			end
		end
	end
end

function sph_update()
    local curr_time = os.clock()
    if (curr_time - prev_time_sph) >= 0.02 then
        prev_time_sph = curr_time
        return true
    end
    return false
end

function car_turbo()
    while true do
        wait(1)
        if turboHackEnabled.v and isKeyDown(87) and isKeyDown(key.name_to_id('Left Alt', false)) then
            local veh = player_vehicle_sph[0]
            if veh ~= samem.nullptr and sph_update() then

                if veh.nVehicleClass == 6 then
                    local train = samem.cast('CTrain *', veh)

                    while train ~= samem.nullptr do
                        local new_speed = train.fTrainSpeed * 1.02
                        if new_speed >= 0.99 then new_speed = 0.9 end
                        if new_speed <= 1.0 then train.fTrainSpeed = new_speed end
                        train = train.pNextCarriage
                    end
                else
                    while veh ~= samem.nullptr do
                        local new_speed = veh.vMoveSpeed * 1.02
                        if new_speed:magnitude() <= 1.0 then
                            veh.vMoveSpeed = new_speed
                        end
                        veh = veh.pTrailer
                    end
                end
            end
        end
    end
end

function getBodyPartCoordinates(id, handle) 
    local pedptr = getCharPointer(handle)
    local vec = ffi.new("float[3]")
    getBonePosition(ffi.cast("void*", pedptr), vec, id, true)
    return vec[0], vec[1], vec[2]
end

function join_argb(a, r, g, b)
    local argb = b  
    argb = bit.bor(argb, bit.lshift(g, 8))  
    argb = bit.bor(argb, bit.lshift(r, 16)) 
    argb = bit.bor(argb , bit.lshift(a, 24)) 
    return argb
end

function explode_argb(argb)
    local a = bit.band(bit.rshift(argb, 24), 0xFF)
    local r = bit.band(bit.rshift(argb, 16), 0xFF)
    local g = bit.band(bit.rshift(argb, 8), 0xFF)
    local b = bit.band(argb, 0xFF)
    return a, r, g, b
end

function nameTagOn()
    local pStSet = sampGetServerSettingsPtr()
    NTdist = memory.getfloat(pStSet + 39) 
    NTwalls = memory.getint8(pStSet + 47) 
    NTshow = memory.getint8(pStSet + 56) 
    memory.setfloat(pStSet + 39, 1488.0)
    memory.setint8(pStSet + 47, 0)
    memory.setint8(pStSet + 56, 1)
end

function nameTagOff()
    local pStSet = sampGetServerSettingsPtr()
    memory.setfloat(pStSet + 39, NTdist)
    memory.setint8(pStSet + 47, NTwalls)
    memory.setint8(pStSet + 56, NTshow)
end



function renderCircle_trailersanp(cx, cy, r, seg, color)
    local theta = (2 * math.pi) / seg
    local cos_theta = math.cos(theta)
    local sin_theta = math.sin(theta)
    local x, y = r, 0

    for _ = 1, seg do
        local x1, y1 = cx + x, cy + y
        local x2 = cx + (cos_theta * x - sin_theta * y)
        local y2 = cy + (sin_theta * x + cos_theta * y)

        renderDrawLine(x1, y1, x2, y2, 2, color)
        x, y = x2 - cx, y2 - cy
    end
end

function trailer_snap()

    local radius_trailersanp = 35
    local range_trailersanp = 40
    local active_trailersanp = true
    local trailer_trailersanp = nil

    while true do
        wait(0)

        if trailersnapEnabled.v and isKeyDown(VK_C) and not sampIsCursorActive()
            and isCharInAnyCar(1) and getDriverOfCar(getCarCharIsUsing(1)) == 1 then

            local screenW, screenH = getScreenResolution()
            local centerX, centerY = screenW / 2, screenH / 2.15

            renderCircle_trailersanp(centerX, centerY, radius_trailersanp, 32, 0xFFB266FF)

            trailer_trailersanp = nil
            local px, py, pz = getCharCoordinates(1)
            local closestVeh_trailersanp, closestDist_trailersanp = nil, range_trailersanp + 1

            for _, veh in ipairs(getAllVehicles()) do
                if veh ~= getCarCharIsUsing(1) and doesVehicleExist(veh) then
                    local vx, vy, vz = getCarCoordinates(veh)
                    local sx, sy = convert3DCoordsToScreen(vx, vy, vz)

                    if sx and sy and
                        sx >= centerX - radius_trailersanp and sx <= centerX + radius_trailersanp and
                        sy >= centerY - radius_trailersanp and sy <= centerY + radius_trailersanp and
                        isCarOnScreen(veh) then

                        local dist = getDistanceBetweenCoords3d(px, py, pz, vx, vy, vz)
                        if dist <= range_trailersanp and dist < closestDist_trailersanp then
                            closestVeh_trailersanp = veh
                            closestDist_trailersanp = dist
                        end
                    end
                end
            end

            if closestVeh_trailersanp then
                local vx, vy, vz = getCarCoordinates(closestVeh_trailersanp)
                local sx, sy = convert3DCoordsToScreen(vx, vy, vz)

                local dx, dy = centerX - sx, centerY - sy
                local d = math.sqrt(dx * dx + dy * dy)
                local extX = centerX + (dx / d) * 20
                local extY = centerY + (dy / d) * 20

                renderDrawLine(sx, sy, extX, extY, 8, 0xFFFF66CC)
                trailer_trailersanp = closestVeh_trailersanp
            end
        end

        if not isKeyDown(VK_C) and trailer_trailersanp then
            local car = getCarCharIsUsing(1)
            if isCharInAnyCar(1) and doesVehicleExist(trailer_trailersanp) then
                if isTrailerAttachedToCab(trailer_trailersanp, car) then
                    detachTrailerFromCab(trailer_trailersanp, car)
                    addOneOffSound(0, 0, 0, 1083)
                else
                    attachTrailerToCab(trailer_trailersanp, car)
                    addOneOffSound(0, 0, 0, 1084)
                end
            end
            trailer_trailersanp = nil
        end
    end
end


function restoreOriginalWeaponData()
	if weaponOrigData ~= nil then
		for skill, weaponsOrig in pairs(weaponOrigData) do
			for id, orig in pairs(weaponsOrig) do
				local weap = gameGetWeaponInfo(id, skill - 1)
				weap.m_fAccuracy 			 = orig.accuracy
				weap.m_fAnimLoopStart  = orig.animLoopStart
				weap.m_fAnimLoopFire   = orig.animLoopFire
				weap.m_fAnimLoopEnd    = orig.animLoopEnd
				weap.m_fAnimLoop2Start = orig.animLoopStart2
				weap.m_fAnimLoop2Fire  = orig.animLoopFire2
				weap.m_fAnimLoop2End   = orig.animLoopEnd2
			end
		end
	end
end
ffi.cdef([[
struct CVector { float x, y, z; };
// from plugin-sdk: https://github.com/DK22Pac/plugin-sdk/blob/master/plugin_sa/game_sa/CWeaponInfo.h
struct CWeaponInfo
{
	int m_iWeaponFire; // 0
	float m_fTargetRange; // 4
	float m_fWeaponRange; // 8
	__int32 m_dwModelId1; // 12
	__int32 m_dwModelId2; // 16
	unsigned __int32 m_dwSlot; // 20
	union {
		int m_iWeaponFlags; // 24
		struct {
			unsigned __int32 m_bCanAim : 1;
			unsigned __int32 m_bAimWithArm : 1;
			unsigned __int32 m_b1stPerson : 1;
			unsigned __int32 m_bOnlyFreeAim : 1;
			unsigned __int32 m_bMoveAim : 1;
			unsigned __int32 m_bMoveFire : 1;
			unsigned __int32 _weaponFlag6 : 1;
			unsigned __int32 _weaponFlag7 : 1;
			unsigned __int32 m_bThrow : 1;
			unsigned __int32 m_bHeavy : 1;
			unsigned __int32 m_bContinuosFire : 1;
			unsigned __int32 m_bTwinPistol : 1;
			unsigned __int32 m_bReload : 1;
			unsigned __int32 m_bCrouchFire : 1;
			unsigned __int32 m_bReload2Start : 1;
			unsigned __int32 m_bLongReload : 1;
			unsigned __int32 m_bSlowdown : 1;
			unsigned __int32 m_bRandSpeed : 1;
			unsigned __int32 m_bExpands : 1;
		};
	};
	unsigned __int32 m_dwAnimGroup; // 28
	unsigned __int16 m_wAmmoClip; // 32
	unsigned __int16 m_wDamage; // 34
	struct CVector m_vFireOffset; // 36
	unsigned __int32 m_dwSkillLevel; // 48
	unsigned __int32 m_dwReqStatLevel; // 52
	float m_fAccuracy; // 56
	float m_fMoveSpeed;
	float m_fAnimLoopStart;
	float m_fAnimLoopEnd;
	float m_fAnimLoopFire;
	float m_fAnimLoop2Start;
	float m_fAnimLoop2End;
	float m_fAnimLoop2Fire;
	float m_fBreakoutTime;
	float m_fSpeed;
	float m_fRadius;
	float m_fLifespan;
	float m_fSpread;
	unsigned __int16 m_wAimOffsetIndex;
	unsigned __int8 m_nBaseCombo;
	unsigned __int8 m_nNumCombos;
} __attribute__ ((aligned (4)));
]])




function teleportPlayer(args)
    local bool, tp_bx, tp_by, tp_bz = getTargetBlipCoordinatesFixed()
    if tp_active then
        sampAddChatMessage(bigbangText("Teleport u toku, molimo sacekajte..."), -1)
        return
    end

    bool, tp_bx, tp_by, tp_bz = getTargetBlipCoordinatesFixed()

    if bool then
        tp_percent = 0
        tp_active = true
        if tp_incar then
            freezeCarPosition(storeCarCharIsInNoSave(PLAYER_PED), true)
        else
            freezeCharPosition(PLAYER_PED, true)
        end
        local x, y, z = getCharCoordinates(PLAYER_PED)
        local nx, ny, nz = x, y, z
        local dist = getDistanceBetweenCoords2d(x, y, tp_bx, tp_by)
        local angle = -math.rad(getHeadingFromVector2d(tp_bx - x, tp_by - y))
        local data = hake_sync_samp(tp_incar and "vehicle" or "player")
        setCharCoordinates(PLAYER_PED, tp_bx, tp_by, tp_bz)
        if dist > tp_distance then
            for ds = dist - tp_distance, 0, -tp_distance do
                data.moveSpeed = {0, 0, tp_incar and -0.1 or -0.7}
                for i = nz, -135, -25 do
                    data.position = {nx, ny, i}
                    data.send()
                    wait(50) 
                end
                data.moveSpeed = {0, 0, 0}
                nx, ny, nz = nx + math.sin(angle) * tp_distance, ny + math.cos(angle) * tp_distance, -60
                data.position = {nx, ny, nz}
                data.send()
                tp_percent = math.calculate_tp(0, 100, dist, 0, ds)
                wait(tp_waiting)
            end
        end
        data.moveSpeed = {0, 0, tp_incar and -0.1 or -0.7}
        for i = nz, -135, -25 do
            data.position = {nx, ny, i}
            data.send()
            wait(50)
        end
        data.position = {tp_bx, tp_by, tp_bz}
        data.send()
        setCharCoordinates(PLAYER_PED, tp_bx, tp_by, tp_bz)
        if tp_incar then
            freezeCarPosition(storeCarCharIsInNoSave(PLAYER_PED), false)
        else
            freezeCharPosition(PLAYER_PED, false)
        end
        sampAddChatMessage(bigbangText("Teleport zavrsen, stigli ste."), -1)
        tp_active = false
    end
end

function getTargetBlipCoordinatesFixed()
    local bool, x, y, z = getTargetBlipCoordinates(); if not bool then return false end
    requestCollision(x, y); loadScene(x, y, z)
    local bool, x, y, z = getTargetBlipCoordinates()
    return bool, x, y, z
end

function math.calculate_tp(MinInt, MaxInt, MinFloat, MaxFloat, CurrentFloat)
    local res = CurrentFloat - MinFloat
    local res2 = MaxFloat - MinFloat
    local res3 = res / res2
    local res4 = res3 * (MaxInt - MinInt)
    return res4 + MinInt
end

local njdestroy_active = false


function njdestroy_command()
    if njdestroy_active then return end  

    njdestroy_active = true

    lua_thread.create(function()
        wait(1)

        local x, y, z = getCharCoordinates(PLAYER_PED)
        local car = GetNearestCarWithDriver(x, y, z, njDestroyerMinRange.v, njDestroyerMaxRange.v)
        if not car then
            njdestroy_active = false
            return
        end

        local success, id = sampGetVehicleIdByCarHandle(car)
        if not success then 
            njdestroy_active = false
            return 
        end

        local data = hake_sync_samp("player")
        if not isCharInAnyCar(PLAYER_PED) then
            njdestroy_nop = true
            sampSendEnterVehicle(id, true)
            wait(500)

            if not isCharInAnyCar(PLAYER_PED) then
                data.specialAction = 3
                data.position = {x, y, z}
            end

            local vdata = hake_sync_samp("vehicle")
            vdata.keysData = 32
            vdata.position = {x, y, z}
            vdata.vehicleId = id
            vdata.vehicleHealth = -100
            vdata.moveSpeed.z = 1.3
            vdata.send()

            addOneOffSound(0, 0, 0, 1149) 
        end

        njdestroy_nop = false
        njdestroy_active = false
    end)
end


local njdestroyer_render = mimgui.OnFrame(
    function()
        return njdestroy_active and isSampAvailable() and not isPauseMenuActive()
    end,
    function(draw)
        draw.HideCursor = true
        local drawList = mimgui.GetBackgroundDrawList()
        local screenX, screenY = getScreenResolution()

        local px, py, pz = getCharCoordinates(PLAYER_PED)
        local car = GetNearestCarWithDriver(px, py, pz, njDestroyerMinRange.v, njDestroyerMaxRange.v)
        if not car or not doesVehicleExist(car) then return end

        local cx, cy, cz = getCarCoordinates(car)
        local dist = getDistanceBetweenCoords3d(px, py, pz, cx, cy, cz)
        if dist > njDestroyerMaxRange.v then return end

        
        local sx, sy = convert3DCoordsToScreen(cx, cy, cz + 1.0)
        if not sx or sx < 0 or sx > screenX or sy < 0 or sy > screenY then return end

        
        local time = os.clock()
        local pulse = 0.5 + 0.5 * math.sin(time * 2)
        local radius = 30 + pulse * 8
        local alpha = 0.5 + pulse * 0.4
        local color = mimgui.ColorConvertFloat4ToU32(mimgui.ImVec4(0.9, 0.3, 1.0, alpha))

        drawList:AddCircle(mimgui.ImVec2(sx, sy), radius, color, 64, 2.5)

        
        for i = 0, 3 do
            local angle = time * 2 + i * (math.pi / 2)
            local x1 = sx + math.cos(angle) * (radius + 3)
            local y1 = sy + math.sin(angle) * (radius + 3)
            local x2 = sx + math.cos(angle) * (radius + 10)
            local y2 = sy + math.sin(angle) * (radius + 10)
            drawList:AddLine(mimgui.ImVec2(x1, y1), mimgui.ImVec2(x2, y2), color, 2.0)
        end

        
        drawList:AddLine(mimgui.ImVec2(sx - 6, sy), mimgui.ImVec2(sx + 6, sy), 0xFFFFFFFF, 1.5)
        drawList:AddLine(mimgui.ImVec2(sx, sy - 6), mimgui.ImVec2(sx, sy + 6), 0xFFFFFFFF, 1.5)

        
        local psx, psy = convert3DCoordsToScreen(px, py, pz + 1.0)
        if psx and psx >= 0 and psx <= screenX and psy >= 0 and psy <= screenY then
            drawList:AddLine(mimgui.ImVec2(psx, psy), mimgui.ImVec2(sx, sy), color, 1.8)
        else
            drawList:AddLine(mimgui.ImVec2(screenX / 2, screenY), mimgui.ImVec2(sx, sy), color, 1.8)
        end

        
        local text = string.format("(%.1f m)", dist)
        local textSize = mimgui.CalcTextSize(text)
        drawList:AddText(mimgui.ImVec2(sx - textSize.x / 2, sy + radius + 12), 0xFFFFFFFF, text)
    end
)


function stream_lagger()
    while true do
        wait(1)
        if isKeyDown(VK_X) and streamLaggerEnabled.v and not isCharInCar(PLAYER_PED, vcarID) and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then
            if isCharInAnyCar(PLAYER_PED) then
                local x, y, z = getCharCoordinates(PLAYER_PED)
                lagger_found, lagger_veh = findAllRandomVehiclesInSphere(x, y, z, laggerRange.v, true, true)
                if lagger_found and lagger_veh ~= storeCarCharIsInNoSave(PLAYER_PED) then
                    local result, lagger_vehId = sampGetVehicleIdByCarHandle(lagger_veh)
                    if result then
                        slagger_act = true
                        for i = 0, 2 do
                            synclagger(x, y, z, lagger_vehId, true)
                        end
                        wait(laggerDelay.v)
                        synclagger(x, y, z, 0, false)
                    end
                else
                    slagger_act = false

                end
            else
                slagger_act = false

            end
        else
            slagger_act = false
        end
    end
end


function synclagger(x, y, z, lagger_vehId, attach)
    local px, py, pz = getCharCoordinates(PLAYER_PED)
  
    local trailer = hake_sync_samp('trailer')
    trailer.trailerId = lagger_vehId
    trailer.position = {x, y, z}
    trailer.turnSpeed = { 0.2, 0.2, 0.2 }
    
    trailer.send()
  
    local lagger_vehicle = hake_sync_samp('vehicle')
    lagger_vehicle.trailerId = lagger_vehId
    lagger_vehicle.position = {px, py, pz}
    lagger_vehicle.send()
  
    if attach then
        sampForceTrailerSync(lagger_vehId)
        if not methodslagger.v then
            sampForceUnoccupiedSyncSeatId(lagger_vehId, 0)
            setCarCoordinates(lagger_veh, px - 10, py, pz)
        end
        addOneOffSound(0, 0, 0, 1149)
    end
end

function angleshot_set()
    while true do
        wait(0)
        if angleShotEnabled.v and isCharInAnyCar(PLAYER_PED) and isKeyDown(key.VK_LBUTTON) and not sampIsDialogActive() and not sampIsChatInputActive() then
            local car = storeCarCharIsInNoSave(PLAYER_PED)
            if doesVehicleExist(car) and isCarDriverOccupied(car) then
                local driver = getDriverOfCar(car)
                if driver == PLAYER_PED then
                    if not angleshot_act then
                        angleshot_act = true
                        angleshot_cspeed = 0
                        angleshot_lastspeed = os.clock()
                    end

                    
                    local camX, camY, camZ = getActiveCameraCoordinates()
                    local targetX, targetY, targetZ = getActiveCameraPointAt()
                    setCarHeading(car, getHeadingFromVector2d(targetX - camX, targetY - camY))

                    local now = os.clock()
                    if now - angleshot_lastspeed >= 0.1 then 
                        angleshot_cspeed = math.min(angleshot_cspeed + angleshot_intensity.v, angleshot_speed.v)
                        angleshot_lastspeed = now
                        addOneOffSound(0, 0, 0, 1149)
                    end
                else
                    angleshot_act = false
                    angleshot_cspeed = 0
                end
            else
                angleshot_act = false
                angleshot_cspeed = 0
            end
        else
            angleshot_act = false
            angleshot_cspeed = 0
        end
    end
end



function angleshot_getMoveSpeed(heading, speed)
    return {
        x = math.sin(-math.rad(heading)) * speed,
        y = math.cos(-math.rad(heading)) * speed,
        z = 0.1
    }
end

function fish_eye()
    while true do
        wait(0) 
        if fisheyeEnabled.v then
			if isCurrentCharWeapon(PLAYER_PED, 34) and isKeyDown(2) then
				if not fish_eye_locked then 
					cameraSetLerpFov(70.0, 70.0, 1000, 1)
					fish_eye_locked = true
				end
			else
				cameraSetLerpFov(101.0, 101.0, 1000, 1)
				fish_eye_locked = false
			end
        end
    end
end

function acbypass_rpc()
    RPC = {}
    while true do
        wait(0)

        
        if wphackbypEnabled.v then
            for id, name in pairs({
                [21] = 'ResetPlayerWeapons',
                [22] = 'GivePlayerWeapon',
                [67] = 'SetArmedWeapon',
            }) do
                RPC[id] = name
            end
        end

        if PlayerRPCsEnabled.v then
            for id, name in pairs({
                [12] = 'SetPlayerPos',
                [13] = 'SetPlayerPosFindZ',
                [14] = 'SetPlayerHealth',
                [15] = 'TogglePlayerControllable',
                [19] = 'SetPlayerFacingAngle',
                [20] = 'ResetPlayerMoney',
                [34] = 'SetPlayerSkillLevel',
                [35] = 'SetPlayerDrunkLevel',
                [70] = 'PutPlayerInVehicle',
                [71] = 'RemovePlayerFromVehicle',
                [74] = 'ForceClassSelection',
                [86] = 'ApplyPlayerAnimation',
                [87] = 'ClearPlayerAnimation',
                [88] = 'SetPlayerSpecialAction',
                [89] = 'SetPlayerFightingStyle',
                [90] = 'SetPlayerVelocity',
            }) do
                RPC[id] = name
            end
        end


        if VehicleRPCsEnabled.v then
            for id, name in pairs({
                [24] = 'SetVehicleParamsEx',
                [26] = 'EnterVehicle',
                [98] = 'SetVehicleTireStatus',
                [147] = 'SetVehicleHealth',
                [148] = 'AttachTrailerToVehicle',
                [149] = 'DetachTrailerFromVehicle',
                [159] = 'SetVehiclePos',
                [160] = 'SetVehicleZAngle',
                [161] = 'SetVehicleParams',
                [123] = 'SetVehicleNumberPlate',
                [167] = 'DisableVehicleCollisions',
            }) do
                RPC[id] = name
            end
        end


        if WorldRPCsEnabled.v then
            for id, name in pairs({
                [17] = 'SetWorldBounds',
                [32] = 'WorldPlayerAdd',
                [163] = 'WorldPlayerRemove',
                [164] = 'WorldVehicleAdd',
                [165] = 'WorldVehicleRemove',
                [79] = 'CreateExplosion',
                [152] = 'SetWeather',
                [157] = 'SetCameraPos',
                [158] = 'SetCameraLookAt',
                [162] = 'SetCameraBehind',
                [168] = 'CameraTarget',
                [170] = 'ToggleCameraTarget',
            }) do
                RPC[id] = name
            end
        end


        if SessionRPCsEnabled.v then
            for id, name in pairs({
                [25] = 'ClientJoin',
                [54] = 'NPCJoin',
                [137] = 'ServerJoin',
                [138] = 'ServerQuit',
                [130] = 'ConnectionRejected',
                [166] = 'DeathBroadcast',
                [139] = 'InitGame',
                [140] = 'MenuQuit',
            }) do
                RPC[id] = name
            end
        end

        if EventRPCsEnabled.v then
            for id, name in pairs({
                [53] = 'DeathNotification',
                [55] = 'SendDeathMessage',
                [60] = 'SendGameTimeUpdate',
                [96] = 'ScmEvent',
                [115] = 'GiveTakeDamage',
                [136] = 'VehicleDestroyed',
                [112] = 'PlayCrimeReport',
                [128] = 'RequestClass',
                [129] = 'RequestSpawn',
            }) do
                RPC[id] = name
            end
        end


        if OtherRPCsEnabled.v then
            for id, name in pairs({
                [146] = 'SetGravity',
                [65] = 'LinkVehicleToInterior',
                [68] = 'SetSpawnInfo',
                [57] = 'RemoveVehicleComponent',
                [58] = 'Delete3DTextLabel',
                [118] = 'InteriorChangeNotification',
                [119] = 'MapMarker',
                [124] = 'TogglePlayerSpectating',
                [126] = 'SpectatePlayer',
                [127] = 'SpectateVehicle',
                [116] = 'EditAttachedObject',
                [117] = 'EditObject',
            }) do
                RPC[id] = name
            end
        end
    end
end

function airbrake()
    arbrk_active = not arbrk_active

    if not arbrk_active then return end

    while arbrk_active do
        wait(0)

        if isCharInAnyCar(PLAYER_PED) then
            setCarHeading(getCarCharIsUsing(PLAYER_PED),
                getHeadingFromVector2d(
                    select(1, getActiveCameraPointAt()) - select(1, getActiveCameraCoordinates()),
                    select(2, getActiveCameraPointAt()) - select(2, getActiveCameraCoordinates())
                )
            )
        else
            setCharHeading(PLAYER_PED,
                getHeadingFromVector2d(
                    select(1, getActiveCameraPointAt()) - select(1, getActiveCameraCoordinates()),
                    select(2, getActiveCameraPointAt()) - select(2, getActiveCameraCoordinates())
                )
            )
        end

        
        if not sampIsCursorActive() then
            if isKeyDown(VK_SPACE) then
                arbrk_coords[3] = arbrk_coords[3] + arbrk_speed_player / 2
            elseif isKeyDown(VK_LSHIFT) and arbrk_coords[3] > -95.0 then
                arbrk_coords[3] = arbrk_coords[3] - arbrk_speed_player / 2
            end

            if isKeyDown(VK_W) then
                arbrk_coords[1] = arbrk_coords[1] + arbrk_speed_player * math.sin(-math.rad(getCharHeading(PLAYER_PED)))
                arbrk_coords[2] = arbrk_coords[2] + arbrk_speed_player * math.cos(-math.rad(getCharHeading(PLAYER_PED)))
            elseif isKeyDown(VK_S) then
                arbrk_coords[1] = arbrk_coords[1] - arbrk_speed_player * math.sin(-math.rad(getCharHeading(PLAYER_PED)))
                arbrk_coords[2] = arbrk_coords[2] - arbrk_speed_player * math.cos(-math.rad(getCharHeading(PLAYER_PED)))
            end

            if isKeyDown(VK_A) then
                arbrk_coords[1] = arbrk_coords[1] - arbrk_speed_player * math.sin(-math.rad(getCharHeading(PLAYER_PED) - 90))
                arbrk_coords[2] = arbrk_coords[2] - arbrk_speed_player * math.cos(-math.rad(getCharHeading(PLAYER_PED) - 90))
            elseif isKeyDown(VK_D) then
                arbrk_coords[1] = arbrk_coords[1] + arbrk_speed_player * math.sin(-math.rad(getCharHeading(PLAYER_PED) - 90))
                arbrk_coords[2] = arbrk_coords[2] + arbrk_speed_player * math.cos(-math.rad(getCharHeading(PLAYER_PED) - 90))
            end
        end

        setCharCoordinates(PLAYER_PED, arbrk_coords[1], arbrk_coords[2], arbrk_coords[3])
    end
end


function arbrk_getMoveSpeed(heading, speed)
    return {
        x = math.sin(-math.rad(heading)) * speed,
        y = math.cos(-math.rad(heading)) * speed,
        z = 0
    }
end

function onWindowMessage(msg, wparam, lparam)
    if not airbrakeEnabled.v then return end 

    if (msg == 0x100 or msg == 0x101) and lparam == 3538945 and not sampIsChatInputActive() and not sampIsDialogActive() and not sampIsCursorActive() then
        arbrk_coords = {getCharCoordinates(PLAYER_PED)}
        if not isCharInAnyCar(PLAYER_PED) then
            arbrk_coords[3] = arbrk_coords[3] - 1
        end
        lua_thread.create(airbrake)
    end
end

function roof_flip()
    while true do
        wait(0)

        if isKeyJustPressed(VK_K) and roofFlipEnabled.v and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then
            if isCharInAnyCar(PLAYER_PED) then
                local veh = storeCarCharIsInNoSave(PLAYER_PED)
                if doesVehicleExist(veh) and isCarDriverOccupied(veh) then
                    
                    local driver = getDriverOfCar(veh)
                    if driver == PLAYER_PED then
                        local success, health = pcall(getCarHealth, veh)
                        if success and health > 250.0 then
                            setVehicleQuaternion(veh, 0, 1, 0, 0)
                            isFlipped = true
                        end
                    end
                end
            end
        end
    end
end


local lastXKeyState = false
local errorSoundPlayed = false

function rvanka_set()
    while true do
        wait(0)

        local isXDown = isKeyDown(VK_X)
        
        
        if isXDown and not lastXKeyState then
            errorSoundPlayed = false
        end

        if isXDown and rVankaEnabled.v and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then
            if not isCharInAnyCar(PLAYER_PED) then
                
                if not errorSoundPlayed then
                    errorSoundPlayed = true
                end
                resetRvanka()
            else
                local car = storeCarCharIsInNoSave(PLAYER_PED)
                if not (doesVehicleExist(car) and isCarDriverOccupied(car) and getDriverOfCar(car) == PLAYER_PED) then
                    if not errorSoundPlayed then
                        errorSoundPlayed = true
                    end
                    resetRvanka()
                else
                    
                    if rvnk_targetId == -1 then
                        local closestId, dist = rvnk_findClosestPlayer()
                        if not closestId then
                            if not errorSoundPlayed then
                                errorSoundPlayed = true
                            end
                            resetRvanka()
                        else
                            rvnk_targetId = closestId
                            rvnk_speed = 0
                        end
                    end

                    if rvnk_targetId ~= -1 then
                        local result, handle = sampGetCharHandleBySampPlayerId(rvnk_targetId)
                        if result and not sampIsPlayerPaused(rvnk_targetId) and isCharInAnyCar(handle) then
                            local tX, tY, tZ = getCharCoordinates(handle)
                            local pX, pY, pZ = getCharCoordinates(PLAYER_PED)
                            local dist = getDistanceBetweenCoords3d(pX, pY, pZ, tX, tY, tZ)

                            if dist < 50 then
                                rvanka_nop = true
                                if rvnk_speed < rVankaSpeed.v then
                                    rvnk_speed = math.min(rvnk_speed + rVankaIntensity.v, rVankaSpeed.v)
                                end
                                local isInVehicle = isCharInAnyCar(handle)
                                rvankaSync(tX, tY, tZ, isInVehicle)
                                addOneOffSound(0, 0, 0, 1149)
                            else
                                resetRvanka()
                            end
                        else
                            resetRvanka()
                        end
                    end
                end
            end
        else
            resetRvanka()
        end

        lastXKeyState = isXDown
    end
end


function resetRvanka()
    rvnk_targetId = -1
    rvnk_speed = 0
    rvanka_nop = false
end

function rvnk_findClosestPlayer()
    local myX, myY, myZ = getCharCoordinates(PLAYER_PED)
    local myVehicle = isCharInAnyCar(PLAYER_PED) and storeCarCharIsInNoSave(PLAYER_PED) or nil
    local closestId = nil
    local minDist = 9999.0

    for i = 0, sampGetMaxPlayerId(false) do
        if sampIsPlayerConnected(i) and not sampIsPlayerPaused(i) then
            local result, handle = sampGetCharHandleBySampPlayerId(i)
            if result then
                
                if isCharInAnyCar(handle) then
                    local skip = false

                    
                    if myVehicle ~= nil then
                        local targetVeh = storeCarCharIsInNoSave(handle)
                        if targetVeh == myVehicle then
                            skip = true
                        end
                    end

                    if not skip then
                        local x, y, z = getCharCoordinates(handle)
                        local dist = getDistanceBetweenCoords3d(myX, myY, myZ, x, y, z)
                        if dist < minDist and dist < 100 then
                            minDist = dist
                            closestId = i
                        end
                    end
                end
            end
        end
    end

    return closestId, minDist
end

function rvankaSync(x, y, z)
    local data = hake_sync_samp("vehicle")
    
    
    math.randomseed(os.clock() * 100000)

    
    local offsetX = (math.random() - 0.5) * 0.3 
    local offsetY = (math.random() - 0.5) * 0.3
    local offsetZ = (math.random() - 0.5) * 0.5

    
    data.position = {
        x + offsetX,
        y + offsetY,
        z + offsetZ
    }

    
    data.moveSpeed = {
        rvnk_speed,
        rvnk_speed,
        rvnk_speed
    }

    
    data.send()
    wait(100)
end



local rvanka_render = mimgui.OnFrame(
    function()
        return rvnk_targetId ~= -1 and isSampAvailable() and not isPauseMenuActive()
    end,
    function(draw)
        draw.HideCursor = true
        local drawList = mimgui.GetBackgroundDrawList()
        local screenX, screenY = getScreenResolution()

        local result, targetPed = sampGetCharHandleBySampPlayerId(rvnk_targetId)
        if not result or not doesCharExist(targetPed) then return end

        local px, py, pz = getCharCoordinates(PLAYER_PED)
        local tx, ty, tz = getCharCoordinates(targetPed)

        local dist = getDistanceBetweenCoords3d(px, py, pz, tx, ty, tz)
        if dist > 70 then return end

        local sx, sy = convert3DCoordsToScreen(tx, ty, tz + 1.0)
        if not sx or sx < 0 or sx > screenX or sy < 0 or sy > screenY then return end

        
        

        local time = os.clock()
        local pulse = 0.5 + 0.5 * math.sin(time * 2)
        local radius = 30 + pulse * 8
        local alpha = 0.5 + pulse * 0.4
        local color = mimgui.ColorConvertFloat4ToU32(mimgui.ImVec4(0.9, 0.3, 1.0, alpha))

        
        drawList:AddCircle(mimgui.ImVec2(sx, sy), radius, color, 64, 2.5)

        
        for i = 0, 3 do
            local angle = time * 2 + i * math.pi / 2
            local x1 = sx + math.cos(angle) * (radius + 3)
            local y1 = sy + math.sin(angle) * (radius + 3)
            local x2 = sx + math.cos(angle) * (radius + 10)
            local y2 = sy + math.sin(angle) * (radius + 10)
            drawList:AddLine(mimgui.ImVec2(x1, y1), mimgui.ImVec2(x2, y2), color, 2.0)
        end

        
        drawList:AddLine(mimgui.ImVec2(sx - 6, sy), mimgui.ImVec2(sx + 6, sy), 0xFFFFFFFF, 1.5)
        drawList:AddLine(mimgui.ImVec2(sx, sy - 6), mimgui.ImVec2(sx, sy + 6), 0xFFFFFFFF, 1.5)

        
        local psx, psy = convert3DCoordsToScreen(px, py, pz + 1.0)
        if psx and psx >= 0 and psx <= screenX and psy >= 0 and psy <= screenY then
            drawList:AddLine(mimgui.ImVec2(psx, psy), mimgui.ImVec2(sx, sy), color, 1.8)
        else
            drawList:AddLine(mimgui.ImVec2(screenX / 2, screenY), mimgui.ImVec2(sx, sy), color, 1.8)
        end

        
        local text = string.format("(%.1f m)", dist)
        local textSize = mimgui.CalcTextSize(text)
        drawList:AddText(mimgui.ImVec2(sx - textSize.x / 2, sy + radius + 12), 0xFFFFFFFF, text)
    end
)


local spincrusher_lastToggleTime = 0
local lastSyncTime = 0

function spincrusher_set()
    while true do wait(0)

        
        if not spinCrusherEnabled.v and spincrusher_STATE then
            spincrusher_STATE = false
            spincrusher_ATTACHED = false
            spincrusher_GUICIRCLE[0] = false
            spincrusher_SEARCHTARGET = nil
            spincrusher_VEHICLETARGET = -1
        end

        if spincrusher_STATE and spinCrusherEnabled.v then 
            local result, handle = sampGetCarHandleBySampVehicleId(spincrusher_VEHICLETARGET)
            if result then 
                if isKeyDown(key.VK_LBUTTON) then
                    local now = os.clock()
                    spincrusher_lastToggleTime = now 
                    local PLAYER_POS = {getCharCoordinates(PLAYER_PED)}
                    setCarCoordinates(handle, PLAYER_POS[1] + 2, PLAYER_POS[2] + 2, PLAYER_POS[3] + 1)
                    spincrusher_STATE = false
                    spincrusher_ATTACHED = false
                    spincrusher_GUICIRCLE[0] = false
                    spincrusher_SEARCHTARGET = nil
                    spincrusher_VEHICLETARGET = -1
                end
            
            else
                spincrusher_STATE = false;
                spincrusher_ATTACHED = false;
                spincrusher_GUICIRCLE[0] = false
                spincrusher_SEARCHTARGET = nil
                spincrusher_VEHICLETARGET = -1;
            end
            if isCharInAnyCar(PLAYER_PED) then 
                spincrusher_STATE = false;
                spincrusher_ATTACHED = false;
                spincrusher_GUICIRCLE[0] = false
                spincrusher_SEARCHTARGET = nil
                spincrusher_VEHICLETARGET = -1;
            end
        end

        if spincrusher_STATE and spinCrusherEnabled.v then 
            local result, handle = sampGetCarHandleBySampVehicleId(spincrusher_VEHICLETARGET)
            if result then 
                local now = os.clock()
                if now - lastSyncTime >= 0.12 then 
                    local PLAYER_POS = {getCharCoordinates(PLAYER_PED)}
                    SPINCRUSHER_SYNC(spincrusher_VEHICLETARGET, PLAYER_POS[1], PLAYER_POS[2], PLAYER_POS[3], scrusherSpeedVertical.v, scrusherSpeedVertical.v, scrusherSpeedHorizontal.v, 0)
                    lastSyncTime = now
                end
            end
        end
        
    end
end

function spincrusher_carmatrix(handle) 
	local entity = getCarPointer(handle)
	if entity ~= 0 then
		local carMatrix = memory.getuint32(entity + 0x14, true)
		if carMatrix ~= 0 then
			local rx = memory.getfloat(carMatrix + 0 * 4, true)
			local ry = memory.getfloat(carMatrix + 1 * 4, true)
			local rz = memory.getfloat(carMatrix + 2 * 4, true)

			local dx = memory.getfloat(carMatrix + 4 * 4, true)
			local dy = memory.getfloat(carMatrix + 5 * 4, true)
			local dz = memory.getfloat(carMatrix + 6 * 4, true)
			return rx, ry, rz, dx, dy, dz
		end
	end
end

lua_thread.create(function()
    function SPINCRUSHER_SYNC(vehicleId, x, y, z, moveSpeedX, moveSpeedY, moveSpeedZ, seat)
        local vehicleHandle = select(2, sampGetCarHandleBySampVehicleId(vehicleId))
        local rx, ry, rz, dx, dy, dz = spincrusher_carmatrix(vehicleHandle)

        local data = hake_sync_samp('unoccupied')
        data.roll = {rx, ry, rz}
        data.direction = {dx, dy, dz}
        data.vehicleId = tonumber(vehicleId)
        data.moveSpeed = {moveSpeedX, moveSpeedY, moveSpeedZ}
        data.vehicleHealth = getCarHealth(vehicleHandle)
        data.turnSpeed = {-0.7, -0.7, 0.7}
        data.seatId = tonumber(seat)
        data.position = {x, y, z}
        data.send()
    end
end)

local spincrusher_render = mimgui.OnFrame(
    function()
        return spinCrusherEnabled.v and isSampAvailable() and not isPauseMenuActive()
    end,
    function(draw)
        draw.HideCursor = true
        local drawList = mimgui.GetBackgroundDrawList()
        local screenX, screenY = getScreenResolution()

        if isCharOnFoot(PLAYER_PED) and not isCharInAnyCar(PLAYER_PED) then
            local px, py, pz = getCharCoordinates(PLAYER_PED)
            local nearestCar = nil
            local nearestDist = 9999
            local vehs = getAllVehicles()

            for i = 1, #vehs do
                local car = vehs[i]
                if doesVehicleExist(car) then
                    local cx, cy, cz = getCarCoordinates(car)
                    local dist = getDistanceBetweenCoords3d(px, py, pz, cx, cy, cz)

                    if dist <= 15 then
                        local sx, sy = convert3DCoordsToScreen(cx, cy, cz + 1.0)
                        if sx and sx >= 0 and sx <= screenX and sy >= 0 and sy <= screenY then
                            local dX, dY = sx - screenX / 2, sy - screenY / 2.5
                            local distFromCenter = math.sqrt(dX * dX + dY * dY)
                            if distFromCenter <= 190 and dist < nearestDist then
                                nearestDist = dist
                                nearestCar = car
                            end
                        end
                    end
                end
            end

            if nearestCar and not spincrusher_ATTACHED then
                spincrusher_SEARCHTARGET = nearestCar
                local cx, cy, cz = getCarCoordinates(nearestCar)
                local sx, sy = convert3DCoordsToScreen(cx, cy, cz + 1.0)

                if sx and sx >= 0 and sx <= screenX and sy >= 0 and sy <= screenY then
                    local time = os.clock()
                    local pulse = 0.5 + 0.5 * math.sin(time * 2)
                    local radius = 30 + pulse * 8
                    local alpha = 0.5 + pulse * 0.4
                    local color = mimgui.ColorConvertFloat4ToU32(mimgui.ImVec4(0.9, 0.3, 1.0, alpha))

                    
                    drawList:AddCircle(mimgui.ImVec2(sx, sy), radius, color, 64, 2.5)

                    
                    for i = 0, 3 do
                        local angle = time * 2 + i * (math.pi / 2)
                        local x1 = sx + math.cos(angle) * (radius + 3)
                        local y1 = sy + math.sin(angle) * (radius + 3)
                        local x2 = sx + math.cos(angle) * (radius + 10)
                        local y2 = sy + math.sin(angle) * (radius + 10)
                        drawList:AddLine(mimgui.ImVec2(x1, y1), mimgui.ImVec2(x2, y2), color, 2.0)
                    end

                    
                    drawList:AddLine(mimgui.ImVec2(sx - 6, sy), mimgui.ImVec2(sx + 6, sy), 0xFFFFFFFF, 1.5)
                    drawList:AddLine(mimgui.ImVec2(sx, sy - 6), mimgui.ImVec2(sx, sy + 6), 0xFFFFFFFF, 1.5)

                    
                    local psx, psy = convert3DCoordsToScreen(px, py, pz + 1.0)
                    if psx and psx >= 0 and psx <= screenX and psy >= 0 and psy <= screenY then
                        drawList:AddLine(mimgui.ImVec2(psx, psy), mimgui.ImVec2(sx, sy), color, 1.8)
                    else
                        drawList:AddLine(mimgui.ImVec2(screenX / 2, screenY), mimgui.ImVec2(sx, sy), color, 1.8)
                    end

                    
                    local text = "X za SpinCrusher"
                    local textSize = mimgui.CalcTextSize(text)
                    drawList:AddText(mimgui.ImVec2(sx - textSize.x / 2, sy + radius + 12), 0xFFFFFFFF, text)

                    
                    if isKeyDown(key.VK_X)
                        and not sampIsDialogActive()
                        and not sampIsChatInputActive()
                        and os.clock() - spincrusher_lastToggleTime > 0.3
                    then
                        if doesVehicleExist(spincrusher_SEARCHTARGET) then
                            spincrusher_VEHICLETARGET = select(2, sampGetVehicleIdByCarHandle(spincrusher_SEARCHTARGET))
                            spincrusher_ATTACHED = true
                            spincrusher_STATE = true
                            spincrusher_GUICIRCLE[0] = true
                            addOneOffSound(0, 0, 0, 1149)
                        end
                        spincrusher_SEARCHTARGET = nil
                    end
                end
            else
                spincrusher_SEARCHTARGET = nil
            end
        end
    end
)




local rangle_scrusher = 0
local spincrusher_circleZOffset = -0.5

local function draw3DCircle(drawList, centerX, centerY, centerZ, radius, segments, color, thickness, rotation)
    local points2D = {}

    for i = 0, segments - 1 do
        local angle = (2 * math.pi / segments) * i + rotation
        local x = centerX + radius * math.cos(angle)
        local y = centerY + radius * math.sin(angle)
        local z = centerZ

        local sx, sy = convert3DCoordsToScreen(x, y, z)
        if sx and sy then
            table.insert(points2D, { x = sx, y = sy })
        end
    end

    for i = 1, #points2D do
        local p1 = points2D[i]
        local p2 = points2D[(i % #points2D) + 1]
        drawList:AddLine(mimgui.ImVec2(p1.x, p1.y), mimgui.ImVec2(p2.x, p2.y), color, thickness)
    end
end

local spincrusher_circle_3d = mimgui.OnFrame(
    function() return spincrusher_GUICIRCLE[0] end,
    function(draw)
        draw.HideCursor = true
        if spincrusher_STATE then
            local PLAYER_POS = { getCharCoordinates(PLAYER_PED) }
            local drawList = mimgui.GetBackgroundDrawList()

            
            rangle_scrusher = (rangle_scrusher + 0.01) % (2 * math.pi)

            local time = os.clock()
            local pulse = math.abs(math.sin(time * 2.5))
            local radius = 0.28 + (pulse * 0.08)

            local segments = 60
            local thickness = 2.4
            local circleZ = PLAYER_POS[3] + spincrusher_circleZOffset

            local alpha = 0.55 + pulse * 0.4
            local col = mimgui.ColorConvertFloat4ToU32(mimgui.ImVec4(0.9, 0.3, 1.0, alpha))

            draw3DCircle(drawList, PLAYER_POS[1], PLAYER_POS[2], circleZ, radius, segments, col, thickness, rangle_scrusher)

            
            local numArrows = 4
            for i = 0, numArrows - 1 do
                local angle = rangle_scrusher + i * ((2 * math.pi) / numArrows)
                local startX = PLAYER_POS[1] + (radius + 0.07) * math.cos(angle)
                local startY = PLAYER_POS[2] + (radius + 0.07) * math.sin(angle)
                local startZ = circleZ

                local endX = PLAYER_POS[1] + (radius + 0.15) * math.cos(angle)
                local endY = PLAYER_POS[2] + (radius + 0.15) * math.sin(angle)
                local endZ = circleZ

                local sx1, sy1 = convert3DCoordsToScreen(startX, startY, startZ)
                local sx2, sy2 = convert3DCoordsToScreen(endX, endY, endZ)

                if sx1 and sy1 and sx2 and sy2 then
                    drawList:AddLine(mimgui.ImVec2(sx1, sy1), mimgui.ImVec2(sx2, sy2), col, thickness)
                end
            end
        end
    end
)

function wph_bit(weapon)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt8(bs, 204)
    raknetBitStreamWriteInt16(bs, 65535)
    raknetBitStreamWriteInt16(bs, 65535)
    raknetBitStreamWriteInt8(bs, getWeapontypeSlot(weapon))
    raknetBitStreamWriteInt8(bs, weapon)
    raknetBitStreamWriteInt16(bs, 1/0)
    raknetSendBitStream(bs)
    raknetDeleteBitStream(bs)
end

carThrowerRenderVehicle = nil
function car_thrower()
    while true do 
        wait(0)

        if carThrowerEnabled.v 
            and isKeyDown(VK_X) and not isCharInAnyCar(PLAYER_PED) and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then
            
            local px, py, pz = getCharCoordinates(PLAYER_PED)
            local car, dist = getNearestFreeCar(px, py, pz)

            if car and doesVehicleExist(car) and dist <= throwRange.v then
                carThrowerRenderVehicle = car

                local result, carId = sampGetVehicleIdByCarHandle(car)
                if result then
                    local vx, vy, vz = getCarCoordinates(car)

                    addOneOffSound(vx, vy, vz, 1139)

                    
                    local baseForce = throwIntensity.v * 0.1
                    local randomFactor = 0.9 + math.random() * 0.2  
                    local force = baseForce * randomFactor

                    local heading = getCharHeading(PLAYER_PED)
                    local rad = math.rad(heading)
                    local forceX = math.cos(rad) * force
                    local forceY = math.sin(rad) * force
                    local forceZ = force * (0.7 + (math.random() * 0.3)) 

                    sampForceTrailerSync(car)
                    applyForceToCar(car, forceX, forceY, forceZ, 1, 2, 3)
                    sampForceUnoccupiedSyncSeatId(car, 0)


                    
                    local baseWait = math.random(100, 150)
                    local waitVar = math.random(-20, 20)
                    wait(baseWait + waitVar)
                end
            else
                carThrowerRenderVehicle = nil
            end
        else
            carThrowerRenderVehicle = nil
        end
    end
end

local car_thrower_render = mimgui.OnFrame(function()
    if not isSampAvailable() or not carThrowerEnabled.v then
        carThrowerRenderVehicle = nil
        return false
    end

    if not isKeyDown(VK_X) and not isCharInAnyCar(PLAYER_PED) and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then
        carThrowerRenderVehicle = nil
        return false
    end

    if carThrowerRenderVehicle and doesVehicleExist(carThrowerRenderVehicle) then
        local px, py, pz = getCharCoordinates(PLAYER_PED)
        local cx, cy, cz = getCarCoordinates(carThrowerRenderVehicle)
        local dist = getDistanceBetweenCoords3d(px, py, pz, cx, cy, cz)

        if dist <= throwRange.v then
            return true
        end
    end

    carThrowerRenderVehicle = nil
    return false
end, function(draw)
    if not carThrowerRenderVehicle or not doesVehicleExist(carThrowerRenderVehicle) then return end

    draw.HideCursor = true
    local drawList = mimgui.GetBackgroundDrawList()
    local screenX, screenY = getScreenResolution()

    local px, py, pz = getCharCoordinates(PLAYER_PED)
    local cx, cy, cz = getCarCoordinates(carThrowerRenderVehicle)
    local dist = getDistanceBetweenCoords3d(px, py, pz, cx, cy, cz)

    local sx, sy = convert3DCoordsToScreen(cx, cy, cz + 1.0)
    if not sx or sx < 0 or sx > screenX or sy < 0 or sy > screenY then return end

    local time = os.clock()
    local pulse = 0.5 + 0.5 * math.sin(time * 2)
    local radius = 30 + pulse * 8
    local alpha = 0.5 + pulse * 0.4
    local color = mimgui.ColorConvertFloat4ToU32(mimgui.ImVec4(0.9, 0.3, 1.0, alpha))

    
    drawList:AddCircle(mimgui.ImVec2(sx, sy), radius, color, 64, 2.5)

    
    for i = 0, 3 do
        local angle = time * 2 + i * (math.pi / 2)
        local x1 = sx + math.cos(angle) * (radius + 3)
        local y1 = sy + math.sin(angle) * (radius + 3)
        local x2 = sx + math.cos(angle) * (radius + 10)
        local y2 = sy + math.sin(angle) * (radius + 10)
        drawList:AddLine(mimgui.ImVec2(x1, y1), mimgui.ImVec2(x2, y2), color, 2.0)
    end

    
    drawList:AddLine(mimgui.ImVec2(sx - 6, sy), mimgui.ImVec2(sx + 6, sy), 0xFFFFFFFF, 1.5)
    drawList:AddLine(mimgui.ImVec2(sx, sy - 6), mimgui.ImVec2(sx, sy + 6), 0xFFFFFFFF, 1.5)

    
    local psx, psy = convert3DCoordsToScreen(px, py, pz + 1.0)
    if psx and psx >= 0 and psx <= screenX and psy >= 0 and psy <= screenY then
        drawList:AddLine(mimgui.ImVec2(psx, psy), mimgui.ImVec2(sx, sy), color, 1.8)
    else
        drawList:AddLine(mimgui.ImVec2(screenX / 2, screenY), mimgui.ImVec2(sx, sy), color, 1.8)
    end

    local txt = string.format("(%.1f m)", dist)
    local textSize = mimgui.CalcTextSize(txt)
    drawList:AddText(mimgui.ImVec2(sx - textSize.x / 2, sy + radius + 12), 0xFFFFFFFF, txt)
end)


function clickwarpLoop()
    while true do
        while isPauseMenuActive() do
            if cursorEnabled_clickwarp then
                showCursor_clickwarp(false)
            end
            wait(100)
        end

        if clickwarpEnabled.v then
            if isKeyDown(VK_MBUTTON) then
                cursorEnabled_clickwarp = not cursorEnabled_clickwarp
                showCursor_clickwarp(cursorEnabled_clickwarp)
                while isKeyDown(VK_MBUTTON) do wait(80) end
            end

            if cursorEnabled_clickwarp then
                local mode = sampGetCursorMode()
                if mode == 0 then showCursor_clickwarp(true) end
                local sx, sy = getCursorPos()
                local sw, sh = getScreenResolution()

                if sx >= 0 and sy >= 0 and sx < sw and sy < sh then
                    local posX, posY, posZ = convertScreenCoordsToWorld3D(sx, sy, 700.0)
                    local camX, camY, camZ = getActiveCameraCoordinates()
                    local result, colpoint = processLineOfSight(camX, camY, camZ, posX, posY, posZ, true, true, false, true, false, false, false)

                    if result and colpoint.entity ~= 0 then
                        local normal = colpoint.normal
                        local pos = Vector3D(colpoint.pos[1], colpoint.pos[2], colpoint.pos[3]) - (Vector3D(normal[1], normal[2], normal[3]) * 0.1)
                        local zOffset = 300
                        if normal[3] >= 0.5 then zOffset = 1 end

                        local result, colpoint2 = processLineOfSight(pos.x, pos.y, pos.z + zOffset, pos.x, pos.y, pos.z - 0.3, true, true, false, true, false, false, false)
                        if result then
                            pos = Vector3D(colpoint2.pos[1], colpoint2.pos[2], colpoint2.pos[3] + 1)

                            local curX, curY, curZ = getCharCoordinates(playerPed)
                            local dist = getDistanceBetweenCoords3d(curX, curY, curZ, pos.x, pos.y, pos.z)
                            local hoffs = renderGetFontDrawHeight(font_clickwarp)

                            sy = sy - 2
                            sx = sx - 2

                            renderFontDrawText(font_clickwarp, "{9b30ff}ClickWarp", sx, sy - hoffs * 2, 0xEEEEEEEE)
                            renderFontDrawText(font_clickwarp, string.format("[%0.2fm]", dist), sx, sy - hoffs, 0xEEEEEEEE)

                            if colpoint.entityType == 2 then
                                local car = getVehiclePointerHandle(colpoint.entity)
                                if doesVehicleExist(car) and (not isCharInAnyCar(playerPed) or storeCarCharIsInNoSave(playerPed) ~= car) then
                                    displayVehicleName_clickwarp(sx, sy - hoffs * 3, getNameOfVehicleModel(getCarModel(car)))
                                end
                            end

                            createPointMarker_clickwarp(pos.x, pos.y, pos.z)

                            if isKeyDown(VK_LBUTTON) then
                                if isCharInAnyCar(playerPed) then
                                    local norm2 = Vector3D(colpoint2.normal[1], colpoint2.normal[2], colpoint2.normal[3])
                                    local norm = Vector3D(colpoint.normal[1], colpoint.normal[2], 0)
                                    rotateCarAroundUpAxis_clickwarp(storeCarCharIsInNoSave(playerPed), norm2)
                                    pos = pos - norm * 1.8
                                    pos.z = pos.z - 0.8
                                end
                                teleportPlayer_clickwarp(pos.x, pos.y, pos.z)
                                removePointMarker_clickwarp()
                                while isKeyDown(VK_LBUTTON) do wait(0) end
                                showCursor_clickwarp(false)
                            end
                        end
                    end
                end
            end
        end

        wait(0)
        removePointMarker_clickwarp()
    end
end

function initializeRender_clickwarp()
    font_clickwarp = renderCreateFont("Tahoma", 10, FCR_BOLD + FCR_BORDER)
    font2_clickwarp = renderCreateFont("Arial", 8, FCR_ITALICS + FCR_BORDER)
end

function rotateCarAroundUpAxis_clickwarp(car, vec)
    local mat = Matrix3X3(getVehicleRotationMatrix_clickwarp(car))
    local rotAxis = Vector3D(mat.up:get())
    vec:normalize()
    rotAxis:normalize()
    local theta = math.acos(rotAxis:dotProduct(vec))
    if theta ~= 0 then
        rotAxis:crossProduct(vec)
        rotAxis:normalize()
        rotAxis:zeroNearZero()
        mat = mat:rotate(rotAxis, -theta)
    end
    setVehicleRotationMatrix_clickwarp(car, mat:get())
end

function readFloatArray_clickwarp(ptr, idx)
    return representIntAsFloat(readMemory(ptr + idx * 4, 4, false))
end

function writeFloatArray_clickwarp(ptr, idx, value)
    writeMemory(ptr + idx * 4, 4, representFloatAsInt(value), false)
end

function getVehicleRotationMatrix_clickwarp(car)
    local entityPtr = getCarPointer(car)
    if entityPtr ~= 0 then
        local mat = readMemory(entityPtr + 0x14, 4, false)
        if mat ~= 0 then
            local rx, ry, rz, fx, fy, fz, ux, uy, uz
            rx = readFloatArray_clickwarp(mat, 0)
            ry = readFloatArray_clickwarp(mat, 1)
            rz = readFloatArray_clickwarp(mat, 2)

            fx = readFloatArray_clickwarp(mat, 4)
            fy = readFloatArray_clickwarp(mat, 5)
            fz = readFloatArray_clickwarp(mat, 6)

            ux = readFloatArray_clickwarp(mat, 8)
            uy = readFloatArray_clickwarp(mat, 9)
            uz = readFloatArray_clickwarp(mat, 10)
            return rx, ry, rz, fx, fy, fz, ux, uy, uz
        end
    end
end

function setVehicleRotationMatrix_clickwarp(car, rx, ry, rz, fx, fy, fz, ux, uy, uz)
    local entityPtr = getCarPointer(car)
    if entityPtr ~= 0 then
        local mat = readMemory(entityPtr + 0x14, 4, false)
        if mat ~= 0 then
            writeFloatArray_clickwarp(mat, 0, rx)
            writeFloatArray_clickwarp(mat, 1, ry)
            writeFloatArray_clickwarp(mat, 2, rz)

            writeFloatArray_clickwarp(mat, 4, fx)
            writeFloatArray_clickwarp(mat, 5, fy)
            writeFloatArray_clickwarp(mat, 6, fz)

            writeFloatArray_clickwarp(mat, 8, ux)
            writeFloatArray_clickwarp(mat, 9, uy)
            writeFloatArray_clickwarp(mat, 10, uz)
        end
    end
end

function displayVehicleName_clickwarp(x, y, gxt)
    x, y = convertWindowScreenCoordsToGameScreenCoords(x, y)
    useRenderCommands(true)
    setTextWrapx(640.0)
    setTextProportional(true)
    setTextJustify(false)
    setTextScale(0.33, 0.8)
    setTextDropshadow(0, 0, 0, 0, 0)
    setTextColour(255, 255, 255, 230)
    setTextEdge(1, 0, 0, 0, 100)
    setTextFont(1)
    displayText(x, y, gxt)
end

function createPointMarker_clickwarp(x, y, z)
    pointMarker_clickwarp = createUser3dMarker(x, y, z + 0.3, 4)
end

function removePointMarker_clickwarp()
    if pointMarker_clickwarp then
        removeUser3dMarker(pointMarker_clickwarp)
        pointMarker_clickwarp = nil
    end
end

function teleportPlayer_clickwarp(x, y, z)
    if isCharInAnyCar(playerPed) then
        setCharCoordinates(playerPed, x, y, z)
    end
    setCharCoordinatesDontResetAnim_clickwarp(playerPed, x, y, z)
end

function setCharCoordinatesDontResetAnim_clickwarp(char, x, y, z)
    if doesCharExist(char) then
        local ptr = getCharPointer(char)
        setEntityCoordinates_clickwarp(ptr, x, y, z)
    end
end

function setEntityCoordinates_clickwarp(entityPtr, x, y, z)
    if entityPtr ~= 0 then
        local matrixPtr = readMemory(entityPtr + 0x14, 4, false)
        if matrixPtr ~= 0 then
            local posPtr = matrixPtr + 0x30
            writeMemory(posPtr + 0, 4, representFloatAsInt(x), false)
            writeMemory(posPtr + 4, 4, representFloatAsInt(y), false)
            writeMemory(posPtr + 8, 4, representFloatAsInt(z), false)
        end
    end
end

function showCursor_clickwarp(toggle)
    if toggle then
        sampSetCursorMode(CMODE_LOCKCAM)
    else
        sampToggleCursor(false)
    end
    cursorEnabled_clickwarp = toggle
end


function fps_counter()
    while true do
        wait(0)
        frame_count = frame_count + 1
        local current_time = os.clock()
        if current_time - last_time >= 1.0 then
            fps_total = frame_count
            frame_count = 0
            last_time = current_time
        end
    end
end

function blacklist()
    while true do
        wait(0)
        local ip, port = sampGetCurrentServerAddress()
        if ip then
            for i, server in ipairs(blacklistovaniServeri) do
                if server.ip == ip and server.port == tostring(port) then
                    sampAddChatMessage(bigbangText("{ff1100}Ovaj server je blacklistovan. UNLOADED"), 0xFF0000)
                    --thisScript():unload()
                    break
                end
            end
        end
    end
end

function discord_rpc_start()
    discord_rpc.Discord_Initialize("2343241431342432242", handlers_rpc, 1, nil)
    wait(2000)

    presence_rpc.details = u8"Trenutno koristi na nekom SAMP Serveru."
    presence_rpc.state = u8"by Hake | V2.0"
    presence_rpc.startTimestamp = os.time()
    presence_rpc.largeImageKey = "velika_slika"
    presence_rpc.largeImageText = u8"BIGBANG CHEAT MENU"
    presence_rpc.smallImageKey = "mala_slika"
    presence_rpc.smallImageText = u8"Najbolji cheat menu za unistavanje SAMP Servera!"

    
    presence_rpc.button1_label = u8"Pridruzi se"
    presence_rpc.button1_url = "https://discord.com/invite/CHP3SyycaD"

    presence_rpc.instance = 1

    discord_rpc.Discord_UpdatePresence(presence_rpc)
end

function resetujvarijable2()
    shaddowbladeEnabled.v = false
    derbyModeEnabled.v = false
    InfinityFuelEnabled.v = false
    turboHackEnabled.v = false
    entercrasherEnabled.v = false
    roofFlipEnabled.v = false
    trailersnapEnabled.v = false
    airbrakeEnabled.v = false
    resyncEnabled.v = false
    wphackbypEnabled.v = false
    PlayerRPCsEnabled.v = false
    VehicleRPCsEnabled.v = false
    WorldRPCsEnabled.v = false
    SessionRPCsEnabled.v = false
    EventRPCsEnabled.v = false
    OtherRPCsEnabled.v = false

    rVankaEnabled.v = false
    crasherEnabled.v = false
    njDestroyerEnabled.v = false
    angleShotEnabled.v = false
    carThrowerEnabled.v = false
    streamLaggerEnabled.v = false
    spinCrusherEnabled.v = false
end

function hake_sync_samp(sync_type, copy_from_player)
    local ffi = require 'ffi'
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
            copy_func(player_id, raw_data_ptr)
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
    return setmetatable({
        send = func_send
    }, mt)
end