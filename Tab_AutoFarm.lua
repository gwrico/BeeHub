-- ==============================================
-- 💰 AUTO FARM TAB MODULE - DENGAN AUTO RECORD POSISI & BATCH SYSTEM
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
    local isPlanting = false -- Untuk tracking proses batch planting
    
    -- Default position (dari script Anda)
    local defaultPos = Vector3.new(37.042457580566406, 39.296875, -265.78594970703125)
    
    -- Custom position (akan diupdate dari posisi player)
    local customX = defaultPos.X
    local customY = defaultPos.Y
    local customZ = defaultPos.Z
    
    -- Batch settings (BARU)
    local totalSeeds = 50      -- Total bibit yang akan ditanam
    local batchSize = 50        -- Jumlah per batch
    local batchDelay = 2.0      -- Jeda setelah setiap batch (detik)
    
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
    
    -- ===== FUNGSI BARU: PLANT WITH BATCH =====
    local function plantWithBatch(amount, perBatch, delayAfterBatch)
        local plantRemote = getPlantRemote()
        if not plantRemote then
            Bdev:Notify({
                Title = "Error",
                Content = "❌ Remote PlantCrop tidak ditemukan!",
                Duration = 3
            })
            return 0
        end
        
        if amount <= 0 then
            Bdev:Notify({
                Title = "Info",
                Content = "⚠️ Jumlah bibit harus lebih dari 0",
                Duration = 2
            })
            return 0
        end
        
        if perBatch <= 0 then
            perBatch = amount
        end
        
        isPlanting = true
        local successCount = 0
        local batchCount = 0
        local totalBatches = math.ceil(amount / perBatch)
        
        Bdev:Notify({
            Title = "Mulai Menanam",
            Content = string.format("🌱 %d bibit (%d batch)", amount, totalBatches),
            Duration = 3
        })
        
        for i = 1, amount do
            if not isPlanting then break end
            
            -- Gunakan posisi dari slider
            local plantPos = Vector3.new(customX, customY, customZ)
            
            local success = pcall(function()
                plantRemote:FireServer(plantPos)
            end)
            
            if success then
                successCount = successCount + 1
                batchCount = batchCount + 1
            end
            
            -- Update progress
            if i % 5 == 0 or i == amount then
                Bdev:Notify({
                    Title = "Progress",
                    Content = string.format("📊 %d/%d bibit ditanam", i, amount),
                    Duration = 1
                })
            end
            
            -- Cek apakah sudah mencapai 1 batch DAN masih ada bibit tersisa
            if batchCount >= perBatch and i < amount then
                local batchNum = math.ceil(i / perBatch)
                Bdev:Notify({
                    Title = "Batch " .. batchNum .. " Selesai",
                    Content = string.format("⏳ Jeda %d detik...", delayAfterBatch),
                    Duration = math.min(delayAfterBatch, 3)
                })
                
                -- Tunggu sesuai delay
                local waitStart = tick()
                while isPlanting and (tick() - waitStart) < delayAfterBatch do
                    task.wait(0.1)
                end
                
                batchCount = 0
            end
            
            -- Jeda kecil antar tanam
            if i < amount then
                task.wait(0.1)
            end
        end
        
        isPlanting = false
        
        Bdev:Notify({
            Title = "Selesai",
            Content = string.format("✅ %d/%d bibit berhasil ditanam", successCount, amount),
            Duration = 4
        })
        
        return successCount
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
    
    -- ===== AUTO PLANT CROPS (ORIGINAL) =====
    Tab:CreateToggle({
        Name = "AutoPlant",
        Text = "🌱 Auto Plant Crops (Loop)",
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
    
    -- ===== MANUAL PLANT (ORIGINAL) =====
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
    
    -- ===== PLANT DI POSISI PLAYER (ORIGINAL) =====
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
            
            updatePositionSliders(playerPos)
            
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
    
    -- ===== RECORD POSISI SAJA (ORIGINAL) =====
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
    
    -- ===== PLANT 5x (ORIGINAL - TETAP DIPERTAHANKAN) =====
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
            
            local plantPos = Vector3.new(customX, customY, customZ)
            local count = 0
            
            Bdev:Notify({
                Title = "Planting",
                Content = "⏳ Menanam 5x...",
                Duration = 3
            })
            
            for i = 1, 5 do
                local success = pcall(function()
                    plantRemote:FireServer(plantPos)
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
    
    -- ===== CUSTOM POSITION (ORIGINAL) =====
    Tab:CreateLabel({
        Name = "PositionLabel",
        Text = "📌 CUSTOM PLANT POSITION",
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- Tombol record cepat (ORIGINAL)
    Tab:CreateButton({
        Name = "QuickRecord",
        Text = "🎯 RECORD MY CURRENT POSITION",
        Callback = function()
            local playerPos = getPlayerPosition()
            if playerPos then
                updatePositionSliders(playerPos)
            else
                Bdev:Notify({
                    Title = "Error",
                    Content = "❌ Tidak bisa dapatkan posisi!",
                    Duration = 2
                })
            end
        end
    })
    
    -- Slider X (ORIGINAL)
    xSlider = Tab:CreateSlider({
        Name = "PosX",
        Text = "X: " .. string.format("%.2f", customX),
        Range = {-1000, 1000},
        Increment = 0.1,
        CurrentValue = customX,
        Callback = function(value)
            customX = value
        end
    })
    
    -- Slider Y (ORIGINAL)
    ySlider = Tab:CreateSlider({
        Name = "PosY",
        Text = "Y: " .. string.format("%.2f", customY),
        Range = {0, 1000},
        Increment = 0.1,
        CurrentValue = customY,
        Callback = function(value)
            customY = value
        end
    })
    
    -- Slider Z (ORIGINAL)
    zSlider = Tab:CreateSlider({
        Name = "PosZ",
        Text = "Z: " .. string.format("%.2f", customZ),
        Range = {-1000, 1000},
        Increment = 0.1,
        CurrentValue = customZ,
        Callback = function(value)
            customZ = value
        end
    })
    
    -- Info posisi real-time (ORIGINAL)
    Tab:CreateLabel({
        Name = "CurrentPosInfo",
        Text = "📍 Posisi Anda saat ini: (gerak untuk update)",
        Alignment = Enum.TextXAlignment.Center
    })
    
    local posLabel = Tab:CreateLabel({
        Name = "LivePosition",
        Text = "X: 0, Y: 0, Z: 0",
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- Update posisi real-time (ORIGINAL)
    RunService.Heartbeat:Connect(function()
        local pos = getPlayerPosition()
        if pos and posLabel then
            posLabel:SetText(string.format("📍 X: %.1f, Y: %.1f, Z: %.1f", pos.X, pos.Y, pos.Z))
        end
    end)
    
    -- Button Plant at Custom (ORIGINAL)
    Tab:CreateButton({
        Name = "PlantCustom",
        Text = "🌱 Plant at Custom Position",
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
                    Content = string.format("✅ Tanam di (%.1f, %.1f, %.1f)", customX, customY, customZ),
                    Duration = 3
                })
            end
        end
    })
    
    -- ===== PLANT DELAY (ORIGINAL) =====
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
    
    -- ===== FITUR BARU: BATCH PLANTING =====
    Tab:CreateLabel({
        Name = "BatchSeparator",
        Text = "══════════════════════════════",
        Alignment = Enum.TextXAlignment.Center
    })
    
    Tab:CreateLabel({
        Name = "BatchTitle",
        Text = "🌾 BATCH PLANTING (Jumlah & Jeda)",
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- TOTAL BIBIT
    Tab:CreateLabel({
        Name = "TotalSeedLabel",
        Text = "📦 TOTAL BIBIT:",
        Alignment = Enum.TextXAlignment.Left
    })
    
    local totalSeedSlider = Tab:CreateSlider({
        Name = "TotalSeedCount",
        Text = "Total: " .. totalSeeds .. " bibit",
        Range = {1, 1000},
        Increment = 1,
        CurrentValue = totalSeeds,
        Callback = function(value)
            totalSeeds = value
            totalSeedSlider:SetText("Total: " .. value .. " bibit")
        end
    })
    
    Tab:CreateTextBox({
        Name = "TotalSeedInput",
        Text = "Input total:",
        PlaceholderText = "Contoh: 100",
        Callback = function(text)
            local num = tonumber(text)
            if num and num > 0 then
                if num > 10000 then num = 10000 end
                totalSeeds = math.floor(num)
                totalSeedSlider:SetValue(totalSeeds)
                totalSeedSlider:SetText("Total: " .. totalSeeds .. " bibit")
                Bdev:Notify({
                    Title = "Total diatur",
                    Content = "🌱 " .. totalSeeds .. " bibit",
                    Duration = 2
                })
            else
                Bdev:Notify({
                    Title = "Error",
                    Content = "❌ Masukkan angka valid",
                    Duration = 2
                })
            end
        end
    })
    
    -- JUMLAH PER BATCH
    Tab:CreateLabel({
        Name = "BatchSizeLabel",
        Text = "📦 PER BATCH:",
        Alignment = Enum.TextXAlignment.Left
    })
    
    local batchSizeSlider = Tab:CreateSlider({
        Name = "BatchSize",
        Text = "Per Batch: " .. batchSize .. " bibit",
        Range = {1, 200},
        Increment = 1,
        CurrentValue = batchSize,
        Callback = function(value)
            batchSize = value
            batchSizeSlider:SetText("Per Batch: " .. value .. " bibit")
        end
    })
    
    Tab:CreateTextBox({
        Name = "BatchInput",
        Text = "Input per batch:",
        PlaceholderText = "Contoh: 25",
        Callback = function(text)
            local num = tonumber(text)
            if num and num > 0 then
                if num > 500 then num = 500 end
                batchSize = math.floor(num)
                batchSizeSlider:SetValue(batchSize)
                batchSizeSlider:SetText("Per Batch: " .. batchSize .. " bibit")
                Bdev:Notify({
                    Title = "Batch diatur",
                    Content = "📦 " .. batchSize .. " per batch",
                    Duration = 2
                })
            else
                Bdev:Notify({
                    Title = "Error",
                    Content = "❌ Masukkan angka valid",
                    Duration = 2
                })
            end
        end
    })
    
    -- JEDA PER BATCH
    Tab:CreateLabel({
        Name = "DelayBatchLabel",
        Text = "⏱️ JEDA PER BATCH (detik):",
        Alignment = Enum.TextXAlignment.Left
    })
    
    local batchDelaySlider = Tab:CreateSlider({
        Name = "BatchDelay",
        Text = "Jeda: " .. string.format("%.1f detik", batchDelay),
        Range = {0.5, 60.0},
        Increment = 0.5,
        CurrentValue = batchDelay,
        Callback = function(value)
            batchDelay = value
            batchDelaySlider:SetText("Jeda: " .. string.format("%.1f detik", value))
        end
    })
    
    Tab:CreateTextBox({
        Name = "DelayBatchInput",
        Text = "Input jeda:",
        PlaceholderText = "Contoh: 5",
        Callback = function(text)
            local num = tonumber(text)
            if num and num > 0 then
                if num > 300 then num = 300 end
                batchDelay = num
                batchDelaySlider:SetValue(batchDelay)
                batchDelaySlider:SetText("Jeda: " .. string.format("%.1f detik", batchDelay))
                Bdev:Notify({
                    Title = "Jeda diatur",
                    Content = "⏱️ " .. string.format("%.1f detik", batchDelay),
                    Duration = 2
                })
            else
                Bdev:Notify({
                    Title = "Error",
                    Content = "❌ Masukkan angka valid",
                    Duration = 2
                })
            end
        end
    })
    
    -- INFO BATCH
    local batchInfoLabel = Tab:CreateLabel({
        Name = "BatchInfo",
        Text = string.format("📊 %d bibit ÷ %d = %d batch", totalSeeds, batchSize, math.ceil(totalSeeds / batchSize)),
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- Update info setiap slider berubah
    local function updateBatchInfo()
        batchInfoLabel:SetText(string.format("📊 %d bibit ÷ %d = %d batch, jeda %.1f detik", 
            totalSeeds, batchSize, math.ceil(totalSeeds / batchSize), batchDelay))
    end
    
    totalSeedSlider.Callback = function(value)
        totalSeeds = value
        totalSeedSlider:SetText("Total: " .. value .. " bibit")
        updateBatchInfo()
    end
    
    batchSizeSlider.Callback = function(value)
        batchSize = value
        batchSizeSlider:SetText("Per Batch: " .. value .. " bibit")
        updateBatchInfo()
    end
    
    batchDelaySlider.Callback = function(value)
        batchDelay = value
        batchDelaySlider:SetText("Jeda: " .. string.format("%.1f detik", value))
        updateBatchInfo()
    end
    
    -- TOMBOL MULAI BATCH
    Tab:CreateButton({
        Name = "StartBatchPlant",
        Text = "▶️ MULAI BATCH PLANTING",
        Callback = function()
            if isPlanting then
                Bdev:Notify({
                    Title = "Info",
                    Content = "⏳ Masih ada proses batch",
                    Duration = 2
                })
                return
            end
            
            local remote = getPlantRemote()
            if not remote then
                Bdev:Notify({
                    Title = "Error",
                    Content = "❌ Remote tidak ditemukan!",
                    Duration = 3
                })
                return
            end
            
            local batches = math.ceil(totalSeeds / batchSize)
            Bdev:Notify({
                Title = "Mulai Batch",
                Content = string.format("🌾 %d bibit, %d batch, jeda %.1f detik", 
                    totalSeeds, batches, batchDelay),
                Duration = 4
            })
            
            task.spawn(function()
                plantWithBatch(totalSeeds, batchSize, batchDelay)
            end)
        end
    })
    
    -- TOMBOL HENTIKAN BATCH
    Tab:CreateButton({
        Name = "StopBatchPlant",
        Text = "⏹️ HENTIKAN BATCH",
        Callback = function()
            if isPlanting then
                isPlanting = false
                Bdev:Notify({
                    Title = "Dihentikan",
                    Content = "⏹️ Batch planting dihentikan",
                    Duration = 2
                })
            else
                Bdev:Notify({
                    Title = "Info",
                    Content = "⚠️ Tidak ada proses batch",
                    Duration = 2
                })
            end
        end
    })
    
    -- ===== KEYBIND RECORD (ORIGINAL) =====
    Tab:CreateLabel({
        Name = "KeybindInfo",
        Text = "⌨️ Tekan R untuk record posisi",
        Alignment = Enum.TextXAlignment.Center
    })
    
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
    
    -- ===== TEST REMOTE (ORIGINAL) =====
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
    
    -- ===== STOP AUTO PLANT (ORIGINAL) =====
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
    
    print("✅ AutoFarm Plant module loaded dengan AUTO RECORD POSISI + BATCH SYSTEM")
end

return AutoFarm