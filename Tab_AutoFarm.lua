-- ==============================================
-- 💰 AUTO FARM TAB MODULE - PLANT CROP ONLY
-- ==============================================

local AutoFarm = {}

function AutoFarm.Init(Dependencies)
    local Tab = Dependencies.Tab
    local Shared = Dependencies.Shared
    local Bdev = Dependencies.Bdev
    local GUI = Dependencies.GUI
    
    local Variables = Shared.Variables or {}
    
    -- Get services
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    
    -- Auto-plant variables
    local plantConnection = nil
    
    -- Dapatkan remote PlantCrop
    local function getPlantRemote()
        local success, remote = pcall(function()
            return ReplicatedStorage.Remotes.TutorialRemotes.PlantCrop
        end)
        
        if success and remote then
            return remote
        end
        
        -- Coba cari dengan aman
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            local tutorial = remotes:FindFirstChild("TutorialRemotes")
            if tutorial then
                return tutorial:FindFirstChild("PlantCrop")
            end
        end
        
        return nil
    end
    
    -- ===== CEK KETERSEDIAAN REMOTE =====
    local plantRemote = getPlantRemote()
    if plantRemote then
        -- Tampilkan notifikasi bahwa remote ditemukan
        Bdev:Notify({
            Title = "PlantCrop Ready",
            Content = "✅ Remote PlantCrop ditemukan!",
            Duration = 3
        })
    else
        -- Peringatan jika remote tidak ditemukan
        Bdev:Notify({
            Title = "Warning",
            Content = "⚠️ Remote PlantCrop tidak ditemukan!",
            Duration = 4
        })
    end
    
    -- ===== AUTO PLANT CROPS =====
    Tab:CreateToggle({
        Name = "AutoPlant",
        Text = "🌱 Auto Plant Crops",
        CurrentValue = false,
        Callback = function(value)
            Variables.autoPlantEnabled = value
            
            if value then
                -- Cek apakah remote tersedia
                local plantRemote = getPlantRemote()
                if not plantRemote then
                    Bdev:Notify({
                        Title = "Error",
                        Content = "❌ PlantCrop remote tidak ditemukan!",
                        Duration = 4
                    })
                    Variables.autoPlantEnabled = false
                    return
                end
                
                Bdev:Notify({
                    Title = "Auto Plant",
                    Content = "🌱 Auto planting ENABLED",
                    Duration = 2
                })
                
                -- Koordinat default
                local plantPosition = Vector3.new(37.042457580566406, 39.296875, -265.78594970703125)
                
                -- Start planting loop
                if plantConnection then
                    plantConnection:Disconnect()
                end
                
                plantConnection = RunService.Heartbeat:Connect(function()
                    if not Variables.autoPlantEnabled then return end
                    
                    local remote = getPlantRemote()
                    if remote then
                        pcall(function()
                            remote:FireServer(plantPosition)
                        end)
                        
                        -- Gunakan plantDelay dari slider
                        task.wait(plantDelay or 1.0)
                    end
                end)
                
            else
                Bdev:Notify({
                    Title = "Auto Plant",
                    Content = "🌱 Auto planting DISABLED",
                    Duration = 2
                })
                
                if plantConnection then
                    plantConnection:Disconnect()
                    plantConnection = nil
                end
            end
        end
    })
    
    -- ===== MANUAL PLANT =====
    Tab:CreateButton({
        Name = "ManualPlant",
        Text = "🌿 Plant Now (1x)",
        Callback = function()
            local plantRemote = getPlantRemote()
            if not plantRemote then
                Bdev:Notify({
                    Title = "Error",
                    Content = "❌ Remote tidak ditemukan!",
                    Duration = 3
                })
                return
            end
            
            local plantPosition = Vector3.new(37.042457580566406, 39.296875, -265.78594970703125)
            
            local success = pcall(function()
                plantRemote:FireServer(plantPosition)
            end)
            
            if success then
                Bdev:Notify({
                    Title = "Success",
                    Content = "✅ Tanam berhasil!",
                    Duration = 2
                })
            else
                Bdev:Notify({
                    Title = "Error",
                    Content = "❌ Gagal menanam",
                    Duration = 2
                })
            end
        end
    })
    
    -- ===== PLANT DI POSISI PLAYER =====
    Tab:CreateButton({
        Name = "PlantAtPlayer",
        Text = "📍 Plant at My Position",
        Callback = function()
            local plantRemote = getPlantRemote()
            if not plantRemote then
                Bdev:Notify({
                    Title = "Error",
                    Content = "❌ Remote tidak ditemukan!",
                    Duration = 3
                })
                return
            end
            
            local player = Players.LocalPlayer
            local character = player.Character
            if not character then
                Bdev:Notify({
                    Title = "Error",
                    Content = "❌ Tidak ada karakter!",
                    Duration = 2
                })
                return
            end
            
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then 
                Bdev:Notify({
                    Title = "Error",
                    Content = "❌ HumanoidRootPart tidak ditemukan",
                    Duration = 2
                })
                return 
            end
            
            -- Gunakan posisi player
            local plantPosition = humanoidRootPart.Position
            
            local success = pcall(function()
                plantRemote:FireServer(plantPosition)
            end)
            
            if success then
                Bdev:Notify({
                    Title = "Success",
                    Content = string.format("📍 Tanam di posisi Anda"),
                    Duration = 2
                })
            end
        end
    })
    
    -- ===== PLANT 5x BERTURUT-TURUT =====
    Tab:CreateButton({
        Name = "PlantMultiple",
        Text = "🔁 Plant 5x (Burst)",
        Callback = function()
            local plantRemote = getPlantRemote()
            if not plantRemote then
                Bdev:Notify({
                    Title = "Error",
                    Content = "❌ Remote tidak ditemukan!",
                    Duration = 3
                })
                return
            end
            
            local plantPosition = Vector3.new(37.042457580566406, 39.296875, -265.78594970703125)
            local count = 0
            
            Bdev:Notify({
                Title = "Planting",
                Content = "⏳ Menanam 5x...",
                Duration = 3
            })
            
            -- Plant 5x dengan jeda 0.3 detik
            for i = 1, 5 do
                local success = pcall(function()
                    plantRemote:FireServer(plantPosition)
                end)
                
                if success then
                    count = count + 1
                end
                
                task.wait(0.3)
            end
            
            Bdev:Notify({
                Title = "Complete",
                Content = string.format("✅ %d/5 tanaman berhasil", count),
                Duration = 3
            })
        end
    })
    
    -- ===== CUSTOM POSITION =====
    Tab:CreateLabel({
        Name = "PositionLabel",
        Text = "📌 CUSTOM PLANT POSITION",
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- Default position
    local customX = 37.042
    local customY = 39.297
    local customZ = -265.786
    
    -- Slider X
    Tab:CreateSlider({
        Name = "PosX",
        Text = "X: " .. string.format("%.1f", customX),
        Range = {-500, 500},
        Increment = 0.1,
        CurrentValue = customX,
        Callback = function(value)
            customX = value
        end
    })
    
    -- Slider Y
    Tab:CreateSlider({
        Name = "PosY",
        Text = "Y: " .. string.format("%.1f", customY),
        Range = {0, 500},
        Increment = 0.1,
        CurrentValue = customY,
        Callback = function(value)
            customY = value
        end
    })
    
    -- Slider Z
    Tab:CreateSlider({
        Name = "PosZ",
        Text = "Z: " .. string.format("%.1f", customZ),
        Range = {-500, 500},
        Increment = 0.1,
        CurrentValue = customZ,
        Callback = function(value)
            customZ = value
        end
    })
    
    -- Button untuk custom position
    Tab:CreateButton({
        Name = "PlantCustom",
        Text = "🎯 Plant at Custom Position",
        Callback = function()
            local plantRemote = getPlantRemote()
            if not plantRemote then
                Bdev:Notify({
                    Title = "Error",
                    Content = "❌ Remote tidak ditemukan!",
                    Duration = 3
                })
                return
            end
            
            local customPos = Vector3.new(customX, customY, customZ)
            
            local success = pcall(function()
                plantRemote:FireServer(customPos)
            end)
            
            if success then
                Bdev:Notify({
                    Title = "Success",
                    Content = string.format("🎯 Tanam di (%.1f, %.1f, %.1f)", customX, customY, customZ),
                    Duration = 3
                })
            end
        end
    })
    
    -- ===== PLANT DELAY =====
    local plantDelay = 1.0
    
    Tab:CreateSlider({
        Name = "PlantDelay",
        Text = "⏱️ Auto Plant Delay: " .. string.format("%.1fs", plantDelay),
        Range = {0.2, 3.0},
        Increment = 0.1,
        CurrentValue = 1.0,
        Callback = function(value)
            plantDelay = value
        end
    })
    
    -- ===== TEST REMOTE =====
    Tab:CreateButton({
        Name = "TestRemote",
        Text = "🔍 Test Remote Connection",
        Callback = function()
            local remote = getPlantRemote()
            
            if remote then
                Bdev:Notify({
                    Title = "Remote OK",
                    Content = "✅ PlantCrop tersedia!",
                    Duration = 3
                })
                
                -- Tampilkan info di console
                print("\n=== PLANT CROP REMOTE INFO ===")
                print("Status: ✅ TERSEDIA")
                print("Path: " .. remote:GetFullName())
                print("Class: " .. remote.ClassName)
                print("Parent: " .. (remote.Parent and remote.Parent.Name or "None"))
                print("===============================\n")
            else
                Bdev:Notify({
                    Title = "Remote Error",
                    Content = "❌ PlantCrop TIDAK ditemukan!",
                    Duration = 4
                })
                
                -- Debug info
                print("\n=== DEBUG INFO ===")
                local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                if remotes then
                    print("Folder Remotes ditemukan. Isinya:")
                    for _, child in pairs(remotes:GetChildren()) do
                        print("  - " .. child.Name)
                        
                        -- Cek TutorialRemotes
                        if child.Name == "TutorialRemotes" then
                            for _, sub in pairs(child:GetChildren()) do
                                print("    • " .. sub.Name)
                            end
                        end
                    end
                else
                    print("Folder Remotes TIDAK ditemukan di ReplicatedStorage!")
                    
                    -- List isi ReplicatedStorage
                    print("\nIsi ReplicatedStorage:")
                    for _, child in pairs(ReplicatedStorage:GetChildren()) do
                        print("  - " .. child.Name)
                    end
                end
                print("==================\n")
            end
        end
    })
    
    -- ===== STOP AUTO PLANT =====
    Tab:CreateButton({
        Name = "StopPlanting",
        Text = "⏹️ STOP Auto Plant",
        Callback = function()
            Variables.autoPlantEnabled = false
            
            if plantConnection then
                plantConnection:Disconnect()
                plantConnection = nil
            end
            
            Bdev:Notify({
                Title = "Stopped",
                Content = "⏹️ Auto planting dihentikan",
                Duration = 2
            })
        end
    })
    
    print("✅ AutoFarm Plant module loaded")
end

return AutoFarm