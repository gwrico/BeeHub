-- ==============================================
-- 💰 AUTO FARM TAB MODULE - DENGAN AUTO RECORD POSISI + AUTO HARVEST
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
    local VirtualInputManager = game:GetService("VirtualInputManager")
    
    -- Auto-plant variables
    local plantConnection = nil
    
    -- Default position
    local defaultPos = Vector3.new(37.042457580566406, 39.296875, -265.78594970703125)
    
    -- Custom position
    local customX = defaultPos.X
    local customY = defaultPos.Y
    local customZ = defaultPos.Z
    
    -- References untuk slider
    local xSlider, ySlider, zSlider
    
    -- Auto harvest variables
    local harvestActive = false
    local harvestConnection = nil
    local HOLD_DURATION = 1.0
    local DELAY_BETWEEN = 0.5
    
    -- Dapatkan remote PlantCrop
    local function getPlantRemote()
        local success, remote = pcall(function()
            return ReplicatedStorage.Remotes.TutorialRemotes.PlantCrop
        end)
        
        if success and remote then
            return remote
        end
        
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
        
        if xSlider then
            xSlider:SetValue(customX)
        end
        if ySlider then
            ySlider:SetValue(customY)
        end
        if zSlider then
            zSlider:SetValue(customZ)
        end
        
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
                        local plantPos = Vector3.new(customX, customY, customZ)
                        
                        pcall(function()
                            remote:FireServer(plantPos)
                        end)
                        
                        task.wait(1.0)
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
    
    -- ===== PLANT DI POSISI PLAYER =====
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
            
            updatePositionSliders(playerPos)
            
            Bdev:Notify({
                Title = "Position Recorded",
                Content = "✅ Posisi tersimpan di slider!",
                Duration = 2
            })
        end
    })
    
    -- ===== KEYBIND RECORD (tekan R) =====
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
    
    -- ===== AUTO HARVEST =====
    local function pressAndHoldE()
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(HOLD_DURATION)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end)
    end
    
    local function harvest()
        local activeCrops = workspace:FindFirstChild("ActiveCrops")
        if not activeCrops then return end
        
        local player = Players.LocalPlayer
        local character = player.Character
        if not character then return end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        for _, crop in ipairs(activeCrops:GetChildren()) do
            local root = crop:FindFirstChild("Root")
            if root and root:IsA("BasePart") then
                local dist = (root.Position - hrp.Position).Magnitude
                if dist <= 10 then
                    pressAndHoldE()
                    break
                end
            end
        end
    end
    
    -- ===== UI AUTO HARVEST =====
    Tab:CreateLabel({
        Name = "HarvestSpacer",
        Text = "",
        Alignment = Enum.TextXAlignment.Center
    })
    
    Tab:CreateLabel({
        Name = "HarvestTitle",
        Text = "───── 🌾 AUTO HARVEST ─────",
        Color = Color3.fromRGB(255, 185, 0),
        Bold = true,
        Alignment = Enum.TextXAlignment.Center
    })
    
    Tab:CreateToggle({
        Name = "AutoHarvest",
        Text = "🤖 AUTO HARVEST",
        CurrentValue = false,
        Callback = function(val)
            harvestActive = val
            
            if val then
                if harvestConnection then
                    harvestConnection:Disconnect()
                end
                
                harvestConnection = RunService.Heartbeat:Connect(function()
                    if not harvestActive then return end
                    
                    harvest()
                    
                    local waitTime = DELAY_BETWEEN
                    while waitTime > 0 and harvestActive do
                        task.wait(0.1)
                        waitTime = waitTime - 0.1
                    end
                end)
            else
                if harvestConnection then
                    harvestConnection:Disconnect()
                    harvestConnection = nil
                end
            end
        end
    })
    
    Tab:CreateButton({
        Name = "StopHarvest",
        Text = "⏹️ STOP HARVEST",
        Callback = function()
            harvestActive = false
            if harvestConnection then
                harvestConnection:Disconnect()
                harvestConnection = nil
            end
        end
    })
    
    print("✅ AutoFarm Plants module loaded")
end

return AutoFarm