-- ==============================================
-- 💰 AUTO FARM TAB MODULE - DENGAN JUMLAH BIBIT & JEDA PER BATCH
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
    local isPlanting = false
    local plantCount = 0
    local maxPlants = 50  -- Default jumlah bibit
    local batchSize = 50   -- Default jumlah per batch (setelah ini akan jeda)
    local batchDelay = 2.0 -- Default jeda setelah 1 batch (detik)
    
    -- Default position (dari script Anda)
    local defaultPos = Vector3.new(37.042457580566406, 39.296875, -265.78594970703125)
    
    -- Position yang akan digunakan (bisa direkam)
    local targetPosition = defaultPos
    
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
    
    -- Fungsi untuk menanam bibit (dengan batch & jeda)
    local function plantSeeds(amount, perBatch, delayAfterBatch)
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
            perBatch = amount -- Kalau 0, berarti 1 batch saja
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
            if not isPlanting then break end -- Berhenti jika di-cancel
            
            -- Tanam 1 bibit
            local success = pcall(function()
                plantRemote:FireServer(targetPosition)
            end)
            
            if success then
                successCount = successCount + 1
                batchCount = batchCount + 1
            end
            
            -- Update progress setiap 5 bibit
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
                    Content = string.format("⏳ Jeda %d detik sebelum batch berikutnya...", delayAfterBatch),
                    Duration = math.min(delayAfterBatch, 3) -- Notifikasi maksimal 3 detik
                })
                
                -- Tunggu sesuai delay
                local waitStart = tick()
                while isPlanting and (tick() - waitStart) < delayAfterBatch do
                    task.wait(0.1)
                end
                
                batchCount = 0 -- Reset counter batch
            end
            
            -- Jeda kecil antar tanam (biar tidak spam)
            if i < amount then
                task.wait(0.1) -- 0.1 detik antar tanam (tetap ada jeda kecil)
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
    
    -- ===== REKAM POSISI =====
    Tab:CreateButton({
        Name = "RecordPosition",
        Text = "📍 REKAM POSISI SAYA",
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
            
            targetPosition = playerPos
            
            Bdev:Notify({
                Title = "Posisi Terekam",
                Content = string.format("📍 X: %.1f, Y: %.1f, Z: %.1f", 
                    targetPosition.X, targetPosition.Y, targetPosition.Z),
                Duration = 3
            })
        end
    })
    
    -- Tampilkan posisi saat ini
    Tab:CreateLabel({
        Name = "CurrentPosLabel",
        Text = "📍 Posisi Anda: (bergerak untuk update)",
        Alignment = Enum.TextXAlignment.Center
    })
    
    local livePosLabel = Tab:CreateLabel({
        Name = "LivePosition",
        Text = "X: 0, Y: 0, Z: 0",
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- Tampilkan posisi target
    local targetPosLabel = Tab:CreateLabel({
        Name = "TargetPosition",
        Text = string.format("🎯 Target: X: %.1f, Y: %.1f, Z: %.1f", 
            targetPosition.X, targetPosition.Y, targetPosition.Z),
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- Update posisi live
    RunService.Heartbeat:Connect(function()
        local pos = getPlayerPosition()
        if pos and livePosLabel then
            livePosLabel:SetText(string.format("📍 X: %.1f, Y: %.1f, Z: %.1f", pos.X, pos.Y, pos.Z))
        end
    end)
    
    -- Update target position display jika berubah
    local function updateTargetDisplay()
        if targetPosLabel then
            targetPosLabel:SetText(string.format("🎯 Target: X: %.1f, Y: %.1f, Z: %.1f", 
                targetPosition.X, targetPosition.Y, targetPosition.Z))
        end
    end
    
    -- ===== JUMLAH BIBIT TOTAL =====
    Tab:CreateLabel({
        Name = "TotalSeedLabel",
        Text = "🌱 TOTAL BIBIT YANG DITANAM",
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- Slider untuk jumlah bibit total
    local totalSeedSlider = Tab:CreateSlider({
        Name = "TotalSeedCount",
        Text = "Total: " .. maxPlants .. " bibit",
        Range = {1, 1000},
        Increment = 1,
        CurrentValue = maxPlants,
        Callback = function(value)
            maxPlants = value
            totalSeedSlider:SetText("Total: " .. value .. " bibit")
            updateInfoLabel()
        end
    })
    
    -- Input manual untuk jumlah bibit total
    Tab:CreateTextBox({
        Name = "TotalSeedInput",
        Text = "Atau masukkan total:",
        PlaceholderText = "Contoh: 500",
        Callback = function(text)
            local num = tonumber(text)
            if num and num > 0 then
                if num > 10000 then num = 10000 end -- Batasi maksimal
                maxPlants = math.floor(num)
                totalSeedSlider:SetValue(maxPlants)
                totalSeedSlider:SetText("Total: " .. maxPlants .. " bibit")
                updateInfoLabel()
                Bdev:Notify({
                    Title = "Total diatur",
                    Content = "🌱 " .. maxPlants .. " bibit",
                    Duration = 2
                })
            else
                Bdev:Notify({
                    Title = "Error",
                    Content = "❌ Masukkan angka yang valid",
                    Duration = 2
                })
            end
        end
    })
    
    -- ===== JUMLAH PER BATCH =====
    Tab:CreateLabel({
        Name = "BatchLabel",
        Text = "📦 JUMLAH PER BATCH",
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- Slider untuk jumlah per batch
    local batchSizeSlider = Tab:CreateSlider({
        Name = "BatchSize",
        Text = "Per Batch: " .. batchSize .. " bibit",
        Range = {1, 200},
        Increment = 1,
        CurrentValue = batchSize,
        Callback = function(value)
            batchSize = value
            batchSizeSlider:SetText("Per Batch: " .. value .. " bibit")
            updateInfoLabel()
        end
    })
    
    -- Input manual untuk jumlah per batch
    Tab:CreateTextBox({
        Name = "BatchInput",
        Text = "Atau masukkan per batch:",
        PlaceholderText = "Contoh: 25",
        Callback = function(text)
            local num = tonumber(text)
            if num and num > 0 then
                if num > 500 then num = 500 end
                batchSize = math.floor(num)
                batchSizeSlider:SetValue(batchSize)
                batchSizeSlider:SetText("Per Batch: " .. batchSize .. " bibit")
                updateInfoLabel()
                Bdev:Notify({
                    Title = "Batch diatur",
                    Content = "📦 " .. batchSize .. " per batch",
                    Duration = 2
                })
            else
                Bdev:Notify({
                    Title = "Error",
                    Content = "❌ Masukkan angka yang valid",
                    Duration = 2
                })
            end
        end
    })
    
    -- ===== JEDA SETIAP BATCH =====
    Tab:CreateLabel({
        Name = "DelayLabel",
        Text = "⏱️ JEDA SETIAP BATCH",
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- Slider untuk jeda batch
    local batchDelaySlider = Tab:CreateSlider({
        Name = "BatchDelay",
        Text = "Jeda: " .. string.format("%.1f detik", batchDelay),
        Range = {0.5, 30.0},
        Increment = 0.5,
        CurrentValue = batchDelay,
        Callback = function(value)
            batchDelay = value
            batchDelaySlider:SetText("Jeda: " .. string.format("%.1f detik", value))
            updateInfoLabel()
        end
    })
    
    -- Input manual untuk jeda batch
    Tab:CreateTextBox({
        Name = "DelayInput",
        Text = "Atau masukkan jeda:",
        PlaceholderText = "Contoh: 5",
        Callback = function(text)
            local num = tonumber(text)
            if num and num > 0 then
                if num > 120 then num = 120 end -- Maks 2 menit
                batchDelay = num
                batchDelaySlider:SetValue(batchDelay)
                batchDelaySlider:SetText("Jeda: " .. string.format("%.1f detik", batchDelay))
                updateInfoLabel()
                Bdev:Notify({
                    Title = "Jeda diatur",
                    Content = "⏱️ " .. string.format("%.1f detik", batchDelay),
                    Duration = 2
                })
            else
                Bdev:Notify({
                    Title = "Error",
                    Content = "❌ Masukkan angka yang valid",
                    Duration = 2
                })
            end
        end
    })
    
    -- Info kombinasi
    local infoLabel = Tab:CreateLabel({
        Name = "InfoLabel",
        Text = string.format("📊 %d bibit ÷ %d per batch = %d batch, jeda %d detik", 
            maxPlants, batchSize, math.ceil(maxPlants / batchSize), batchDelay),
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- Update info label
    local function updateInfoLabel()
        local batches = math.ceil(maxPlants / batchSize)
        infoLabel:SetText(string.format("📊 %d bibit ÷ %d per batch = %d batch, jeda %.1f detik", 
            maxPlants, batchSize, batches, batchDelay))
    end
    
    -- ===== TOMBOL MULAI TANAM =====
    Tab:CreateButton({
        Name = "StartPlanting",
        Text = "▶️ MULAI TANAM",
        Callback = function()
            if isPlanting then
                Bdev:Notify({
                    Title = "Info",
                    Content = "⏳ Masih menanam, tunggu selesai",
                    Duration = 2
                })
                return
            end
            
            -- Cek remote
            local remote = getPlantRemote()
            if not remote then
                Bdev:Notify({
                    Title = "Error",
                    Content = "❌ Remote PlantCrop tidak ditemukan!",
                    Duration = 3
                })
                return
            end
            
            local batches = math.ceil(maxPlants / batchSize)
            local totalTime = (maxPlants * 0.1) + ((batches - 1) * batchDelay)
            
            -- Konfirmasi
            Bdev:Notify({
                Title = "Mulai Menanam",
                Content = string.format("🌱 %d bibit, %d batch, jeda %.1f detik", 
                    maxPlants, batches, batchDelay),
                Duration = 4
            })
            
            -- Mulai menanam di thread terpisah
            task.spawn(function()
                plantSeeds(maxPlants, batchSize, batchDelay)
            end)
        end
    })
    
    -- ===== TOMBOL HENTIKAN =====
    Tab:CreateButton({
        Name = "StopPlanting",
        Text = "⏹️ HENTIKAN",
        Callback = function()
            if isPlanting then
                isPlanting = false
                Bdev:Notify({
                    Title = "Dihentikan",
                    Content = "⏹️ Proses menanam dihentikan",
                    Duration = 2
                })
            else
                Bdev:Notify({
                    Title = "Info",
                    Content = "⚠️ Tidak ada proses menanam",
                    Duration = 2
                })
            end
        end
    })
    
    -- ===== PRESET CEPAT =====
    Tab:CreateLabel({
        Name = "QuickLabel",
        Text = "⚡ PRESET CEPAT",
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- Preset 1: 50 bibit, batch 50, jeda 2 detik
    Tab:CreateButton({
        Name = "Preset1",
        Text = "📦 50 bibit (1×50) - Jeda 2 detik",
        Callback = function()
            maxPlants = 50
            batchSize = 50
            batchDelay = 2
            
            totalSeedSlider:SetValue(50)
            batchSizeSlider:SetValue(50)
            batchDelaySlider:SetValue(2)
            
            updateInfoLabel()
            Bdev:Notify({
                Title = "Preset 1",
                Content = "✅ 50 bibit, 1 batch, jeda 2 detik",
                Duration = 2
            })
        end
    })
    
    -- Preset 2: 100 bibit, batch 50, jeda 3 detik
    Tab:CreateButton({
        Name = "Preset2",
        Text = "📦 100 bibit (2×50) - Jeda 3 detik",
        Callback = function()
            maxPlants = 100
            batchSize = 50
            batchDelay = 3
            
            totalSeedSlider:SetValue(100)
            batchSizeSlider:SetValue(50)
            batchDelaySlider:SetValue(3)
            
            updateInfoLabel()
            Bdev:Notify({
                Title = "Preset 2",
                Content = "✅ 100 bibit, 2 batch, jeda 3 detik",
                Duration = 2
            })
        end
    })
    
    -- Preset 3: 200 bibit, batch 40, jeda 5 detik
    Tab:CreateButton({
        Name = "Preset3",
        Text = "📦 200 bibit (5×40) - Jeda 5 detik",
        Callback = function()
            maxPlants = 200
            batchSize = 40
            batchDelay = 5
            
            totalSeedSlider:SetValue(200)
            batchSizeSlider:SetValue(40)
            batchDelaySlider:SetValue(5)
            
            updateInfoLabel()
            Bdev:Notify({
                Title = "Preset 3",
                Content = "✅ 200 bibit, 5 batch, jeda 5 detik",
                Duration = 2
            })
        end
    })
    
    -- ===== KEYBIND REKAM (R) =====
    Tab:CreateLabel({
        Name = "KeybindInfo",
        Text = "⌨️ Tekan R untuk rekam posisi",
        Alignment = Enum.TextXAlignment.Center
    })
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.R then
            local playerPos = getPlayerPosition()
            if playerPos then
                targetPosition = playerPos
                updateTargetDisplay()
                Bdev:Notify({
                    Title = "Posisi Terekam",
                    Content = "✅ Tekan R",
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
    
    print("✅ AutoFarm Plant module loaded dengan BATCH SYSTEM")
end

return AutoFarm