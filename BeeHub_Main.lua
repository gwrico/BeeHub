-- ==============================================
-- 🎮 BEEHUB v4.0 - MODULAR SYSTEM (MAIN)
-- ==============================================
print("🔧 Loading BeeHub Modular System v4.0...")

-- Configuration
local CONFIG = {
    SIMPLEGUI_URL = "https://gist.githubusercontent.com/gwrico/5dd484edcedcca018eb3f86887ad60d6/raw/ac73bcdb545b3ee888a5657359d9fdb3a2e19bde/SimpleGUI_Final%2520v5.1.lua",
    MODULES_URL = "https://raw.githubusercontent.com/gwrico/BeeHub/main/",
    LOAD_TIMEOUT = 10 -- seconds
}

-- Load SimpleGUI
print("🖼️ Loading SimpleGUI...")
local SimpleGUI = loadstring(game:HttpGet(CONFIG.SIMPLEGUI_URL))()
local GUI = SimpleGUI.new()

-- Create main window
local Window = GUI:CreateWindow({
    Name = "⚡ BeeHub v4.0 - PETS EDITION",
    Size = UDim2.new(0, 600, 0, 500),
    TitleBarHeight = 28,
    MinimizeHeight = 25,
    Resizable = true,
    ShowThemeTab = true
})

-- Notification system
local Rayfield = {
    Notify = function(notification)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = notification.Title,
            Text = notification.Content,
            Duration = notification.Duration or 3
        })
    end
}

-- 🥚 EGG DATA (GANTI DARI ORE DATA) 🥚
local EggData = {
    ["Copper Egg"] = {value = 10, rarityId = 1},
    ["Silver Egg"] = {value = 25, rarityId = 2},
    ["Gold Egg"] = {value = 100, rarityId = 3},
    ["Emerald Egg"] = {value = 250, rarityId = 4},
    ["Ruby Egg"] = {value = 1000, rarityId = 5},
    ["Diamond Egg"] = {value = 10000, rarityId = 6},
    ["Obsidian Egg"] = {value = 50000, rarityId = 7},
    ["Mystery Egg"] = {value = 250000, rarityId = 8},
    ["Lava Egg"] = {value = 250000, rarityId = 8},
    ["Galaxy Egg"] = {value = 250000, rarityId = 8},
    ["Gold Lucky Block"] = {value = 250000, rarityId = 8},
    ["Diamond Lucky Block"] = {value = 250000, rarityId = 8}
}

-- Shared state container
local Shared = {
    -- GUI
    Window = Window,
    GUI = GUI,
    Rayfield = Rayfield,
    
    -- Data (GANTI OreData -> EggData)
    EggData = EggData,
    
    -- Services
    Services = {
        VirtualInputManager = game:GetService("VirtualInputManager"),
        UserInputService = game:GetService("UserInputService"),
        RunService = game:GetService("RunService"),
        Players = game:GetService("Players"),
        Workspace = game:GetService("Workspace"),
        TeleportService = game:GetService("TeleportService"),
        ReplicatedStorage = game:GetService("ReplicatedStorage"),
        MarketplaceService = game:GetService("MarketplaceService")
    },
    
    -- Shared variables (update nama variable)
    Variables = {
        autoCollectEnabled = false,      -- Ganti: autoMineEnabled
        autoPunchEnabled = false,
        eggESPEnabled = false,           -- Ganti: oreESPEnabled
        xrayEnabled = false,
        playerESPEnabled = false,
        antiAfkEnabled = false,
        speedHackEnabled = false,
        jumpHackEnabled = false,
        noclipEnabled = false,
        infiniteJumpEnabled = false,
        flyEnabled = false,
        autoHatchEnabled = false         -- TAMBAH: untuk auto hatch
    },
    
    -- Tab references (will be filled by modules)
    Tabs = {},
    
    -- Module system
    Modules = {
        Loaded = {},
        Errors = {}
    }
}

-- Function to load modules safely
function Shared.LoadModule(moduleName, urlSuffix)
    local moduleUrl = CONFIG.MODULES_URL .. urlSuffix
    print("📦 Loading module: " .. moduleName .. " from " .. moduleUrl)
    
    local success, result = pcall(function()
        return loadstring(game:HttpGet(moduleUrl, true))()
    end)
    
    if success then
        Shared.Modules.Loaded[moduleName] = result
        print("✅ Module loaded: " .. moduleName)
        return result
    else
        local errMsg = "❌ Failed to load " .. moduleName .. ": " .. tostring(result)
        print(errMsg)
        Shared.Modules.Errors[moduleName] = errMsg
        Rayfield.Notify({
            Title = "Module Error",
            Content = "Failed to load " .. moduleName,
            Duration = 5
        })
        return nil
    end
end

-- Function to initialize all modules
function Shared.InitializeModules()
    print("\n🚀 Initializing all modules...")
    
    -- Load Core Shared functions first
    local CoreModule = Shared.LoadModule("Core_Shared", "Core_Shared.lua")
    if CoreModule and CoreModule.Init then
        CoreModule.Init(Shared)
    end
    
    -- Load and initialize tabs in order
    local tabModules = {
        {Name = "AutoFarm", File = "Tab_AutoFarm.lua", TabName = "💰 Auto Farm"},
        {Name = "PlayerMods", File = "Tab_PlayerMods.lua", TabName = "👤 Player Mods"},
        {Name = "Teleport", File = "Tab_Teleport.lua", TabName = "📍 Teleport"},
        {Name = "Visuals", File = "Tab_Visuals.lua", TabName = "👁️ Visuals"},
        {Name = "Misc", File = "Tab_Misc.lua", TabName = "⚡ Misc"}
    }
    
    for _, moduleInfo in ipairs(tabModules) do
        local module = Shared.LoadModule(moduleInfo.Name, moduleInfo.File)
        if module and module.Init then
            -- Create tab first
            local tab = Window:CreateTab(moduleInfo.TabName)
            Shared.Tabs[moduleInfo.Name] = tab
            
            -- Initialize module with the tab
            module.Init({
                Tab = tab,
                Shared = Shared,
                Window = Window,
                Rayfield = Rayfield
            })
            
            print("✅ Tab initialized: " .. moduleInfo.TabName)
        end
    end
    
    -- Show load summary
    local loadedCount = 0
    for _ in pairs(Shared.Modules.Loaded) do
        loadedCount = loadedCount + 1
    end
    
    print("\n" .. string.rep("=", 50))
    print("📊 LOAD SUMMARY:")
    print("✅ Modules loaded: " .. loadedCount .. "/" .. (#tabModules + 1))
    print("❌ Errors: " .. #Shared.Modules.Errors)
    
    if next(Shared.Modules.Errors) then
        print("\n⚠️ ERRORS:")
        for module, errorMsg in pairs(Shared.Modules.Errors) do
            print("  • " .. module .. ": " .. errorMsg)
        end
    end
    
    print(string.rep("=", 50))
end

-- Start loading modules
task.spawn(function()
    local startTime = tick()
    Shared.InitializeModules()
    local loadTime = tick() - startTime
    
    print("\n🎉 BeeHub Modular System v4.0 fully loaded!")
    print("⏱️ Load time: " .. string.format("%.2f", loadTime) .. " seconds")
    
    Rayfield.Notify({
        Title = "BeeHub v4.0",
        Content = "Modular system loaded successfully!\n" .. 
                  "Tabs: " .. #Shared.Tabs .. " | Time: " .. string.format("%.1f", loadTime) .. "s",
        Duration = 6
    })
end)

-- Auto-cleanup on exit
game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    
    -- Restore any modified stats
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        if Shared.Variables.speedHackEnabled then
            char.Humanoid.WalkSpeed = 16
        end
        if Shared.Variables.jumpHackEnabled then
            char.Humanoid.JumpPower = 50
        end
    end
end)

-- Return shared for debugging
return Shared


