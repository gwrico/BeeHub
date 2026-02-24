-- ==============================================
-- 💰 AUTO FARM TAB MODULE - DENGAN AUTO RECORD POSISI & BATCH PLANTING
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
    
    -- Position yang akan digunakan
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
    
    -- Fungsi untuk update posisi target
    local function updateTargetPosition(newPos)
        if not newPos then return end
        targetPosition = newPos
        
        -- Tampilkan notifikasi
        Bdev:Notify({
            Title = "Position Recorded",
            Content = string.format("📍 X: %.1f, Y: %.1f, Z: %.1f", 
                targetPosition.X, targetPosition.Y, targetPosition.Z),
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
                        pcall(function()
                            remote:FireServer(targetPosition)
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
            
            local success = pcall(function()
                plantRemote:FireServer(targetPosition)
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
            
            -- Record posisi
            updateTargetPosition(playerPos)
            
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
    
    -- ===== RECORD POSISI SAJA =====
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
            
            updateTargetPosition(playerPos)
            
            Bdev:Notify({
                Title = "Position Recorded",
                Content = "✅ Posisi tersimpan!",
                Duration = 2
            })
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
            
            local count = 0
            
            Bdev:Notify({
                Title = "Planting",
                Content = "⏳ Menanam 5x...",
                Duration = 3
            })
            
            for i = 1, 5 do
                local success = pcall(function()
                    plantRemote:FireServer(targetPosition)
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
    
    -- ===== TAMPILAN POSISI TARGET =====
    Tab:CreateLabel({
        Name = "TargetPosLabel",
        Text = string.format("🎯 Target: X: %.1f, Y: %.1f, Z: %.1f", 
            targetPosition.X, targetPosition.Y, targetPosition.Z),
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- Tombol record cepat
    Tab:CreateButton({
        Name = "QuickRecord",
        Text = "🎯 REKAM POSISI SAYA",
        Callback = function()
            local playerPos = getPlayerPosition()
            if playerPos then
                updateTargetPosition(playerPos)
            else
                Bdev:Notify({
                    Title = "Error",
                    Content = "❌ Tidak bisa dapatkan posisi!",
                    Duration = 2
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
        CurrentValue = plantDelay,
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
                updateTargetPosition(playerPos)
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
    
    -- ============================================================
    -- ===== FITUR BARU: BATCH PLANTING (VERSI AMAN) =====
    -- ============================================================
    
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
    
    -- Variable untuk batch
    local totalSeeds = 50
    local batchSize = 50
    local batchDelay = 2.0
    local isBatchPlanting = false
    
    -- ===== TOTAL BIBIT =====
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
    
    -- ===== JUMLAH PER BATCH =====
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
    
    -- ===== JEDA PER BATCH =====
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
    
    -- ===== INFO BATCH =====
    local batchInfoLabel = Tab:CreateLabel({
        Name = "BatchInfo",
        Text = string.format("📊 %d bibit ÷ %d = %d batch", totalSeeds, batchSize, math.ceil(totalSeeds / batchSize)),
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- ===== FUNGSI BATCH PLANTING =====
    local function startBatchPlanting()
        if isBatchPlanting then
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
        
        if totalSeeds <= 0 then
            Bdev:Notify({
                Title = "Error",
                Content = "❌ Total bibit harus lebih dari 0",
                Duration = 2
            })
            return
        end
        
        isBatchPlanting = true
        local planted = 0
        local batchCounter = 0
        local totalBatches = math.ceil(totalSeeds / batchSize)
        
        Bdev:Notify({
            Title = "Mulai Batch",
            Content = string.format("🌾 %d bibit, %d batch", totalSeeds, totalBatches),
            Duration = 3
        })
        
        -- Jalankan di thread terpisah
        task.spawn(function()
            for i = 1, totalSeeds do
                if not isBatchPlanting then break end
                
                local success = pcall(function()
                    remote:FireServer(targetPosition)
                end)
                
                if success then
                    planted = planted + 1
                    batchCounter = batchCounter + 1
                end
                
                -- Update progress setiap 5 bibit
                if i % 5 == 0 or i == totalSeeds then
                    Bdev:Notify({
                        Title = "Progress",
                        Content = string.format("📊 %d/%d bibit", i, totalSeeds),
                        Duration = 1
                    })
                end
                
                -- Cek apakah sudah mencapai 1 batch DAN masih ada bibit tersisa
                if batchCounter >= batchSize and i < totalSeeds then
                    local currentBatch = math.ceil(i / batchSize)
                    Bdev:Notify({
                        Title = "Batch " .. currentBatch .. " Selesai",
                        Content = string.format("⏳ Jeda %d detik...", batchDelay),
                        Duration = math.min(batchDelay, 3)
                    })
                    
                    -- Tunggu sesuai delay
                    local waitStart = tick()
                    while isBatchPlanting and (tick() - waitStart) < batchDelay do
                        task.wait(0.1)
                    end
                    
                    batchCounter = 0
                end
                
                -- Jeda kecil antar tanam
                if i < totalSeeds then
                    task.wait(0.1)
                end
            end
            
            isBatchPlanting = false
            Bdev:Notify({
                Title = "Selesai",
                Content = string.format("✅ %d/%d bibit ditanam", planted, totalSeeds),
                Duration = 4
            })
        end)
    end
    
    -- ===== TOMBOL MULAI BATCH =====
    Tab:CreateButton({
        Name = "StartBatchPlant",
        Text = "▶️ MULAI BATCH PLANTING",
        Callback = startBatchPlanting
    })
    
    -- ===== TOMBOL HENTIKAN BATCH =====
    Tab:CreateButton({
        Name = "StopBatchPlant",
        Text = "⏹️ HENTIKAN BATCH",
        Callback = function()
            if isBatchPlanting then
                isBatchPlanting = false
                Bdev:Notify({
                    Title = "Info",
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
    
    print("✅ AutoFarm Plant module loaded dengan AUTO RECORD POSISI + BATCH PLANTING")
end

return AutoFarm