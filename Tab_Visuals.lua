-- ==============================================
-- 🌾 AUTO HARVEST TANAMAN
-- ==============================================

local AutoHarvest = {}

function AutoHarvest.Init(Dependencies)
    local Tab = Dependencies.Tab
    local Shared = Dependencies.Shared
    local Bdev = Dependencies.Bdev
    local GUI = Dependencies.GUI
    
    local Variables = Shared.Variables or {}
    
    -- Get services
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    
    -- ===== FUNGSI TWEEN =====
    local function tween(object, properties, duration, easingStyle)
        if not object then return nil end
        local tweenInfo = TweenInfo.new(duration or 0.2, easingStyle or Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        local tween = TweenService:Create(object, tweenInfo, properties)
        tween:Play()
        return tween
    end
    
    -- Variables
    local harvestConnection = nil
    local autoHarvestToggleRef = nil
    local player = Players.LocalPlayer
    local harvestedCount = 0
    local lastHarvestTime = 0
    
    -- Dapatkan posisi player
    local function getPlayerPosition()
        local character = player.Character
        if not character then return nil end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end
        return hrp.Position
    end
    
    -- Cari tanaman siap panen di sekitar
    local function findReadyCrops()
        local crops = {}
        local playerPos = getPlayerPosition()
        if not playerPos then return crops end
        
        -- Cari di folder ActiveCrops
        local activeCrops = workspace:FindFirstChild("ActiveCrops")
        if not activeCrops then return crops end
        
        for _, crop in ipairs(activeCrops:GetDescendants()) do
            -- Cari ProximityPrompt dengan ActionText "Harvest"
            if crop:IsA("ProximityPrompt") and crop.ActionText == "Harvest" then
                if crop.Parent and crop.Parent:IsA("BasePart") then
                    local dist = (crop.Parent.Position - playerPos).Magnitude
                    if dist <= crop.MaxActivationDistance then
                        -- Catat jenis tanaman dari ObjectText
                        local cropType = "Unknown"
                        if crop.ObjectText then
                            if crop.ObjectText:find("Eggplant") then
                                cropType = "🍆 Terong"
                            elseif crop.ObjectText:find("Corn") then
                                cropType = "🌽 Jagung"
                            elseif crop.ObjectText:find("Padi") or crop.ObjectText:find("Rice") then
                                cropType = "🌾 Padi"
                            elseif crop.ObjectText:find("Strawberry") then
                                cropType = "🍓 Stroberi"
                            elseif crop.ObjectText:find("Tomat") or crop.ObjectText:find("Tomato") then
                                cropType = "🍅 Tomat"
                            end
                        end
                        
                        table.insert(crops, {
                            prompt = crop,
                            type = cropType,
                            dist = dist
                        })
                    end
                end
            end
        end
        
        -- Urutkan berdasarkan jarak (terdekat dulu)
        table.sort(crops, function(a, b) return a.dist < b.dist end)
        
        return crops
    end
    
    -- Fungsi untuk harvest
    local function harvestCrop(cropData)
        if not cropData or not cropData.prompt then return false end
        
        local prompt = cropData.prompt
        
        -- Trigger prompt (tekan E)
        local success = pcall(function()
            prompt:InputHoldBegin()
            task.wait(0.5) -- HoldDuration 0.5 detik
            prompt:InputHoldEnd()
        end)
        
        if success then
            harvestedCount = harvestedCount + 1
            return true
        end
        
        return false
    end
    
    -- ===== UI =====
    local header = Tab:CreateLabel({
        Name = "Header_AutoHarvest",
        Text = "───── 🌾 AUTO HARVEST ─────",
        Color = Color3.fromRGB(255, 185, 0),
        Bold = true,
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- Auto Harvest Toggle
    autoHarvestToggleRef = Tab:CreateToggle({
        Name = "AutoHarvest",
        Text = "🌾 AUTO HARVEST TANAMAN",
        CurrentValue = false,
        Callback = function(value)
            Variables.autoHarvestEnabled = value
            
            if value then
                harvestedCount = 0
                Bdev:Notify({Title = "🌾 Auto Harvest ON", Content = "Mencari tanaman siap panen...", Duration = 2})
                
                if harvestConnection then harvestConnection:Disconnect() end
                
                harvestConnection = RunService.Heartbeat:Connect(function()
                    if not Variables.autoHarvestEnabled then return end
                    
                    local crops = findReadyCrops()
                    
                    for _, crop in ipairs(crops) do
                        -- Cek jeda antar harvest (biar gak spam)
                        local now = tick()
                        if now - lastHarvestTime >= 1 then
                            local success = harvestCrop(crop)
                            if success then
                                lastHarvestTime = now
                                -- Notifikasi setiap 5 kali harvest
                                if harvestedCount % 5 == 0 then
                                    Bdev:Notify({
                                        Title = "🌾 Harvest",
                                        Content = string.format("%s - Total: %d", crop.type, harvestedCount),
                                        Duration = 1
                                    })
                                end
                            end
                            task.wait(0.2) -- Jeda antar tanaman
                        end
                    end
                    
                    task.wait(0.5) -- Jeda siklus
                end)
                
            else
                if harvestConnection then
                    harvestConnection:Disconnect()
                    harvestConnection = nil
                end
                Bdev:Notify({
                    Title = "🌾 Auto Harvest OFF",
                    Content = string.format("Total panen: %d tanaman", harvestedCount),
                    Duration = 3
                })
            end
        end
    })
    
    -- Info jenis tanaman
    local cropInfoLabel = Tab:CreateLabel({
        Name = "CropInfo",
        Text = "🍆 Terong | 🌽 Jagung | 🌾 Padi | 🍓 Stroberi | 🍅 Tomat",
        Color = Color3.fromRGB(150, 150, 160),
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- Tombol Test Harvest
    local ActionFrame = Instance.new("Frame")
    ActionFrame.Name = "ActionFrame"
    ActionFrame.Size = UDim2.new(0.95, 0, 0, 40)
    ActionFrame.BackgroundTransparency = 1
    ActionFrame.LayoutOrder = #Tab.Elements + 1
    ActionFrame.Parent = Tab.Content
    
    local ActionLayout = Instance.new("UIListLayout")
    ActionLayout.FillDirection = Enum.FillDirection.Horizontal
    ActionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ActionLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ActionLayout.Padding = UDim.new(0, 10)
    ActionLayout.Parent = ActionFrame
    
    -- Tombol Test Harvest
    local TestBtn = Instance.new("TextButton")
    TestBtn.Size = UDim2.new(0, 120, 0, 36)
    TestBtn.Text = "🌾 TEST HARVEST"
    TestBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TestBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
    TestBtn.BackgroundTransparency = 0
    TestBtn.TextSize = 12
    TestBtn.Font = Enum.Font.GothamBold
    TestBtn.AutoButtonColor = false
    TestBtn.Parent = ActionFrame
    
    local TestCorner = Instance.new("UICorner")
    TestCorner.CornerRadius = UDim.new(0, 6)
    TestCorner.Parent = TestBtn
    
    TestBtn.MouseButton1Click:Connect(function()
        local crops = findReadyCrops()
        if #crops > 0 then
            local success = harvestCrop(crops[1])
            if success then
                Bdev:Notify({Title = "✅ Test Berhasil", Content = crops[1].type, Duration = 2})
            else
                Bdev:Notify({Title = "❌ Test Gagal", Duration = 2})
            end
        else
            Bdev:Notify({Title = "❌ Tidak ada", Content = "Tidak ada tanaman siap panen", Duration = 2})
        end
    end)
    
    -- Tombol Stop
    local StopBtn = Instance.new("TextButton")
    StopBtn.Size = UDim2.new(0, 100, 0, 36)
    StopBtn.Text = "⏹️ STOP"
    StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    StopBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    StopBtn.BackgroundTransparency = 0
    StopBtn.TextSize = 12
    StopBtn.Font = Enum.Font.GothamBold
    StopBtn.AutoButtonColor = false
    StopBtn.Parent = ActionFrame
    
    local StopCorner = Instance.new("UICorner")
    StopCorner.CornerRadius = UDim.new(0, 6)
    StopCorner.Parent = StopBtn
    
    StopBtn.MouseButton1Click:Connect(function()
        if autoHarvestToggleRef and autoHarvestToggleRef.SetValue then
            autoHarvestToggleRef:SetValue(false)
        end
    end)
    
    -- ===== HOVER EFFECTS =====
    local function setupHover(btn, normalColor, hoverColor)
        btn.MouseEnter:Connect(function() tween(btn, {BackgroundColor3 = hoverColor}, 0.15) end)
        btn.MouseLeave:Connect(function() tween(btn, {BackgroundColor3 = normalColor}, 0.15) end)
    end
    
    setupHover(TestBtn, Color3.fromRGB(70, 70, 85), Color3.fromRGB(90, 90, 105))
    setupHover(StopBtn, Color3.fromRGB(200, 50, 50), Color3.fromRGB(220, 80, 80))
    
    -- ===== CLEANUP =====
    local function cleanup()
        if harvestConnection then
            harvestConnection:Disconnect()
            harvestConnection = nil
        end
        Variables.autoHarvestEnabled = false
    end
    
    print("✅ Auto Harvest module loaded - Tanaman siap panen")
    
    return cleanup
end

return AutoHarvest