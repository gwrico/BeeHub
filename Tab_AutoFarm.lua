-- ==============================================
-- 💰 AUTO FARM TAB MODULE - DENGAN AUTO RECORD POSISI
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
    local UserInputService = game:GetService("UserInputService")
    
    -- Auto-plant variables
    local plantConnection = nil
    
    -- Default position (dari script Anda)
    local defaultPos = Vector3.new(37.042457580566406, 39.296875, -265.78594970703125)
    
    -- Custom position (akan diupdate dari posisi player)
    local customX = defaultPos.X
    local customY = defaultPos.Y
    local customZ = defaultPos.Z
    
    -- References untuk slider (agar bisa diupdate nilainya)
    local xSlider, ySlider, zSlider
    
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
    
    -- Fungsi untuk mendapatkan posisi player
    local function getPlayerPosition()
        local player = Players.LocalPlayer
        local character = player.Character
        if not character then return nil end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return nil end
        
        return humanoidRootPart.Position
    end
    
    -- Fungsi untuk update slider dengan nilai baru
    local function updatePositionSliders(newPos)
        if not newPos then return end
        
        customX = newPos.X
        customY = newPos.Y
        customZ = newPos.Z
        
        -- Update slider jika reference tersedia
        if xSlider then
            xSlider:SetValue(customX)
        end
        if ySlider then
            ySlider:SetValue(customY)
        end
        if zSlider then
            zSlider:SetValue(customZ)
        end
        
        -- Tampilkan notifikasi
        Bdev:Notify({
            Title = "Position Recorded",
            Content = string.format("📍 X: %.1f, Y: %.1f, Z: %.1f", customX, customY, customZ),
            Duration = 3
        })
    end
    
    -- ===== CEK KETERSEDIAAN REMOTE =====
    local plantRemote = getPlantRemote()
    if plantRemote then
        Bdev:Notify({
            Title = "PlantCrop Ready",
            Content = "✅ Remote PlantCrop ditemukan!",
            Duration = 3
        })
    else
        Bdev:Notify({
            Title = "Warning",
            Content = "⚠️ Remote PlantCrop tidak ditemukan!",
            Duration = 4
        })
    end
    
    -- ===== BATCH SETTINGS =====
    Tab:CreateLabel({
        Name = "BatchSettingsLabel",
        Text = "⚙️ BATCH SETTINGS",
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- Jumlah tanaman per batch
    local batchSize = 5
    
    Tab:CreateSlider({
        Name = "BatchSize",
        Text = "🌾 Jumlah per batch: " .. batchSize,
        Range = {1, 50},
        Increment = 1,
        CurrentValue = 5,
        Callback = function(value)
            batchSize = value
        end
    })
    
    -- Delay antar tanaman dalam batch
    local batchDelay = 0.3
    
    Tab:CreateSlider({
        Name = "BatchDelay",
        Text = "⏱️ Delay antar tanaman: " .. string.format("%.1fs", batchDelay),
        Range = {0.1, 2.0},
        Increment = 0.1,
        CurrentValue = 0.3,
        Callback = function(value)
            batchDelay = value
        end
    })
    
    -- ===== AUTO PLANT CROPS =====
    Tab:CreateToggle({
        Name = "AutoPlant",
        Text = "🌱 Auto Plant Crops",
        CurrentValue = false,
        Callback = function(value)
            Variables.autoPlantEnabled = value
            
            if value then
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
                
                if plantConnection then
                    plantConnection:Disconnect()
                end
                
                plantConnection = RunService.Heartbeat:Connect(function()
                    if not Variables.autoPlantEnabled then return end
                    
                    local remote = getPlantRemote()
                    if remote then
                        -- Gunakan custom position yang sudah direkam
                        local plantPos = Vector3.new(customX, customY, customZ)
                        
                        pcall(function()
                            remote:FireServer(plantPos)
                        end)
                        
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
            
            -- Gunakan custom position
            local plantPos = Vector3.new(customX, customY, customZ)
            
            local success = pcall(function()
                plantRemote:FireServer(plantPos)
            end)
            
            if success then
                Bdev:Notify({
                    Title = "Success",
                    Content = "✅ Tanam berhasil!",
                    Duration = 2
                })
            end
        end
    })
    
    -- ===== PLANT DI POSISI PLAYER (SEKALIGUS RECORD) =====
    Tab:CreateButton({
        Name = "PlantAndRecord",
        Text = "📍 Plant & Record My Position",
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
            
            local playerPos = getPlayerPosition()
            if not playerPos then
                Bdev:Notify({
                    Title = "Error",
                    Content = "❌ Tidak bisa dapatkan posisi!",
                    Duration = 2
                })
                return
            end
            
            -- Record posisi ke slider
            updatePositionSliders(playerPos)
            
            -- Tanam di posisi tersebut
            local success = pcall(function()
                plantRemote:FireServer(playerPos)
            end)
            
            if success then
                Bdev:Notify({
                    Title = "Success",
                    Content = "✅ Posisi direkam & tanaman ditanam!",
                    Duration = 3
                })
            end
        end
    })
    
    -- ===== RECORD POSISI SAJA (TANPA MENANAM) =====
    Tab:CreateButton({
        Name = "RecordOnly",
        Text = "📝 Record My Position Only",
        Callback = function()
            local playerPos = getPlayerPosition()
            if not playerPos then
                Bdev:Notify({
                    Title = "Error",
                    Content = "❌ Tidak bisa dapatkan posisi!",
                    Duration = 2
                })
                return
            end
            
            updatePositionSliders(playerPos)
            
            Bdev:Notify({
                Title = "Position Recorded",
                Content = "✅ Posisi tersimpan di slider!",
                Duration = 2
            })
        end
    })
    
    -- ===== PLANT BATCH (sesuai jumlah & delay yang diatur) =====
    Tab:CreateButton({
        Name = "PlantBatch",
        Text = "🔁 Plant Batch",
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
            
            local plantPos = Vector3.new(customX, customY, customZ)
            local count = 0
            
            Bdev:Notify({
                Title = "Planting",
                Content = string.format("⏳ Menanam %dx dengan delay %.1fs...", batchSize, batchDelay),
                Duration = 3
            })
            
            for i = 1, batchSize do
                local success = pcall(function()
                    plantRemote:FireServer(plantPos)
                end)
                
                if success then
                    count = count + 1
                end
                
                task.wait(batchDelay)
            end
            
            Bdev:Notify({
                Title = "Complete",
                Content = string.format("✅ %d/%d tanaman berhasil", count, batchSize),
                Duration = 3
            })
        end
    })
    
    -- ===== PLANT DELAY (untuk AutoPlant) =====
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
    
    -- ===== KEYBIND INSTANT RECORD (tekan R untuk record) =====
    Tab:CreateLabel({
        Name = "KeybindInfo",
        Text = "⌨️ Tekan R untuk record posisi",
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- Keybind R untuk record cepat
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.R then
            local playerPos = getPlayerPosition()
            if playerPos then
                updatePositionSliders(playerPos)
                Bdev:Notify({
                    Title = "Quick Record",
                    Content = "✅ Posisi direkam (tekan R)",
                    Duration = 1
                })
            end
        end
    end)
    
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
                
                print("\n=== PLANT CROP REMOTE INFO ===")
                print("Status: ✅ TERSEDIA")
                print("Path: " .. remote:GetFullName())
                print("Class: " .. remote.ClassName)
                print("===============================\n")
            else
                Bdev:Notify({
                    Title = "Remote Error",
                    Content = "❌ PlantCrop TIDAK ditemukan!",
                    Duration = 4
                })
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
    
    print("✅ AutoFarm Plants module loaded dengan AUTO RECORD POSISI")
end

return AutoFarm