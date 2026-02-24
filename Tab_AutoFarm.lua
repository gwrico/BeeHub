-- ==============================================
-- 💰 AUTO FARM TAB MODULE - DENGAN PILIHAN BIBIT
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
    local TweenService = game:GetService("TweenService")
    
    -- ===== FUNGSI TWEEN LOKAL =====
    local function tween(object, properties, duration, easingStyle)
        if not object then return nil end
        
        local tweenInfo = TweenInfo.new(
            duration or 0.2, 
            easingStyle or Enum.EasingStyle.Quint, 
            Enum.EasingDirection.Out
        )
        local tween = TweenService:Create(object, tweenInfo, properties)
        tween:Play()
        return tween
    end
    
    -- Auto-plant variables
    local plantConnection = nil
    local autoPlantToggleRef = nil
    local statusLabelRef = nil
    local seedDropdownRef = nil
    
    -- Default position (dari script Anda)
    local defaultPos = Vector3.new(37.042457580566406, 39.296875, -265.78594970703125)
    
    -- Custom position (akan diupdate dari posisi player)
    local customX = defaultPos.X
    local customY = defaultPos.Y
    local customZ = defaultPos.Z
    
    -- Selected seed
    local selectedSeed = "Bibit Padi"  -- Default
    
    -- References untuk slider (agar bisa diupdate nilainya)
    local xSlider, ySlider, zSlider
    local delaySliderRef = nil
    local plantCount = 0
    
    -- ===== DAFTAR BIBIT =====
    local seedsList = {
        {Display = "🌾 Padi", Name = "Bibit Padi"},
        {Display = "🌽 Jagung", Name = "Bibit Jagung"},
        {Display = "🍅 Tomat", Name = "Bibit Tomat"},
        {Display = "🍆 Terong", Name = "Bibit Terong"},
        {Display = "🍓 Strawberry", Name = "Bibit Strawberry"}
    }
    
    -- Buat array untuk dropdown
    local seedDisplayOptions = {}
    for i, seed in ipairs(seedsList) do
        seedDisplayOptions[i] = seed.Display
    end
    
    -- Mapping Display -> Name
    local displayToName = {}
    for i, seed in ipairs(seedsList) do
        displayToName[seed.Display] = seed.Name
    end
    
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
    
    -- Fungsi untuk update status label
    local function updateStatusLabel()
        if statusLabelRef then
            if Variables.autoPlantEnabled then
                statusLabelRef.Text = "🟢 Status: ACTIVE (Auto Plant ON)"
                statusLabelRef.TextColor3 = Color3.fromRGB(0, 255, 0)
            else
                statusLabelRef.Text = "🔴 Status: INACTIVE (Auto Plant OFF)"
                statusLabelRef.TextColor3 = Color3.fromRGB(255, 70, 70)
            end
        end
    end
    
    -- Fungsi untuk update slider dengan nilai baru
    local function updatePositionSliders(newPos)
        if not newPos then return end
        
        customX = newPos.X
        customY = newPos.Y
        customZ = newPos.Z
        
        -- Update slider jika reference tersedia
        if xSlider and xSlider.SetValue then
            xSlider:SetValue(customX)
        end
        if ySlider and ySlider.SetValue then
            ySlider:SetValue(customY)
        end
        if zSlider and zSlider.SetValue then
            zSlider:SetValue(customZ)
        end
        
        -- Tampilkan notifikasi
        Bdev:Notify({
            Title = "📍 Position Recorded",
            Content = string.format("X: %.1f, Y: %.1f, Z: %.1f", customX, customY, customZ),
            Duration = 2
        })
    end
    
    -- ===== CEK KETERSEDIAAN REMOTE =====
    local plantRemote = getPlantRemote()
    if plantRemote then
        Bdev:Notify({
            Title = "✅ PlantCrop Ready",
            Content = "Remote PlantCrop ditemukan!",
            Duration = 3
        })
    else
        Bdev:Notify({
            Title = "⚠️ Warning",
            Content = "Remote PlantCrop tidak ditemukan!",
            Duration = 4
        })
    end
    
    -- ===== HEADER =====
    local header = Tab:CreateLabel({
        Name = "Header_AutoFarm",
        Text = "───── 🌾 AUTO FARM ─────",
        Color = Color3.fromRGB(255, 185, 0),
        Bold = true,
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- ===== STATUS LABEL =====
    statusLabelRef = Tab:CreateLabel({
        Name = "StatusLabel",
        Text = "🔴 Status: INACTIVE (Auto Plant OFF)",
        Color = Color3.fromRGB(255, 70, 70),
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- ===== PILIHAN BIBIT SECTION =====
    local seedHeader = Tab:CreateLabel({
        Name = "Header_Bibit",
        Text = "───── 🌱 PILIH BIBIT ─────",
        Color = Color3.fromRGB(255, 185, 0),
        Bold = true,
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- Dropdown untuk memilih bibit
    seedDropdownRef = Tab:CreateDropdown({
        Name = "SeedDropdown",
        Text = "Jenis Bibit:",
        Options = seedDisplayOptions,
        Default = seedDisplayOptions[1],
        Callback = function(value)
            selectedSeed = displayToName[value]
            Bdev:Notify({
                Title = "✅ Bibit Dipilih",
                Content = value,
                Duration = 1
            })
            print("🌱 Selected seed:", selectedSeed)
        end
    })
    
    -- Label info bibit terpilih
    local seedInfoLabel = Tab:CreateLabel({
        Name = "SeedInfo",
        Text = "➤ Bibit aktif: " .. seedsList[1].Display,
        Color = Color3.fromRGB(255, 255, 255),
        Alignment = Enum.TextXAlignment.Left
    })
    
    -- Update seed info saat bibit berubah
    if seedDropdownRef then
        -- Update di callback sudah ada
    end
    
    -- ===== POSISI SECTION =====
    local posHeader = Tab:CreateLabel({
        Name = "Header_Posisi",
        Text = "───── 📍 POSISI TANAM ─────",
        Color = Color3.fromRGB(255, 185, 0),
        Bold = true,
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- Info posisi default
    Tab:CreateLabel({
        Name = "DefaultPosInfo",
        Text = string.format("Default: X=%.1f, Y=%.1f, Z=%.1f", defaultPos.X, defaultPos.Y, defaultPos.Z),
        Color = Color3.fromRGB(150, 150, 160),
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- Slider untuk X
    xSlider = Tab:CreateSlider({
        Name = "PosX",
        Text = "📍 X Position",
        Range = {-500, 500},
        Increment = 0.1,
        CurrentValue = customX,
        Callback = function(value)
            customX = value
        end
    })
    
    -- Slider untuk Y
    ySlider = Tab:CreateSlider({
        Name = "PosY",
        Text = "📍 Y Position",
        Range = {-500, 500},
        Increment = 0.1,
        CurrentValue = customY,
        Callback = function(value)
            customY = value
        end
    })
    
    -- Slider untuk Z
    zSlider = Tab:CreateSlider({
        Name = "PosZ",
        Text = "📍 Z Position",
        Range = {-500, 500},
        Increment = 0.1,
        CurrentValue = customZ,
        Callback = function(value)
            customZ = value
        end
    })
    
    -- ===== TOMBOL POSISI =====
    local PosButtonFrame = Instance.new("Frame")
    PosButtonFrame.Name = "PosButtonFrame"
    PosButtonFrame.Size = UDim2.new(0.95, 0, 0, 45)
    PosButtonFrame.BackgroundTransparency = 1
    PosButtonFrame.LayoutOrder = #Tab.Elements + 1
    PosButtonFrame.Parent = Tab.Content
    
    local PosButtonLayout = Instance.new("UIListLayout")
    PosButtonLayout.FillDirection = Enum.FillDirection.Horizontal
    PosButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    PosButtonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    PosButtonLayout.Padding = UDim.new(0, 10)
    PosButtonLayout.Parent = PosButtonFrame
    
    -- Tombol Record Posisi
    local RecordBtn = Instance.new("TextButton")
    RecordBtn.Name = "RecordBtn"
    RecordBtn.Size = UDim2.new(0, 140, 0, 40)
    RecordBtn.Text = "📝 RECORD POSISI"
    RecordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    RecordBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
    RecordBtn.BackgroundTransparency = 0
    RecordBtn.TextSize = 12
    RecordBtn.Font = Enum.Font.GothamBold
    RecordBtn.AutoButtonColor = false
    RecordBtn.Parent = PosButtonFrame
    
    local RecordCorner = Instance.new("UICorner")
    RecordCorner.CornerRadius = UDim.new(0, 6)
    RecordCorner.Parent = RecordBtn
    
    RecordBtn.MouseButton1Click:Connect(function()
        local playerPos = getPlayerPosition()
        if playerPos then
            updatePositionSliders(playerPos)
            Bdev:Notify({
                Title = "✅ Recorded",
                Content = "Posisi player disimpan!",
                Duration = 2
            })
        else
            Bdev:Notify({
                Title = "❌ Error",
                Content = "Tidak bisa dapatkan posisi!",
                Duration = 2
            })
        end
    end)
    
    -- Tombol Reset ke Default
    local ResetBtn = Instance.new("TextButton")
    ResetBtn.Name = "ResetBtn"
    ResetBtn.Size = UDim2.new(0, 140, 0, 40)
    ResetBtn.Text = "🔄 RESET DEFAULT"
    ResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ResetBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
    ResetBtn.BackgroundTransparency = 0
    ResetBtn.TextSize = 12
    ResetBtn.Font = Enum.Font.GothamBold
    ResetBtn.AutoButtonColor = false
    ResetBtn.Parent = PosButtonFrame
    
    local ResetCorner = Instance.new("UICorner")
    ResetCorner.CornerRadius = UDim.new(0, 6)
    ResetCorner.Parent = ResetBtn
    
    ResetBtn.MouseButton1Click:Connect(function()
        updatePositionSliders(defaultPos)
        Bdev:Notify({
            Title = "🔄 Reset",
            Content = "Kembali ke posisi default",
            Duration = 2
        })
    end)
    
    -- Spacer
    Tab:CreateLabel({
        Name = "Spacer1",
        Text = "",
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- ===== PENGATURAN DELAY =====
    local delayHeader = Tab:CreateLabel({
        Name = "Header_Delay",
        Text = "───── ⏱️ PENGATURAN ─────",
        Color = Color3.fromRGB(255, 185, 0),
        Bold = true,
        Alignment = Enum.TextXAlignment.Center
    })
    
    delaySliderRef = Tab:CreateSlider({
        Name = "DelaySlider",
        Text = "Delay: 1.0 detik",
        Range = {0.1, 3},
        Increment = 0.1,
        CurrentValue = 1.0,
        Callback = function(value)
            -- Update text slider
            if delaySliderRef and delaySliderRef.Frame then
                local label = delaySliderRef.Frame:FindFirstChild("SliderLabel")
                if label then
                    label.Text = "Delay: " .. string.format("%.1f", value) .. " detik"
                end
            end
        end
    })
    
    -- ===== AUTO PLANT SECTION =====
    local autoHeader = Tab:CreateLabel({
        Name = "Header_Auto",
        Text = "───── 🤖 AUTO PLANT ─────",
        Color = Color3.fromRGB(255, 185, 0),
        Bold = true,
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- Auto Plant Toggle
    autoPlantToggleRef = Tab:CreateToggle({
        Name = "AutoPlant",
        Text = "🌱 AUTO PLANT CROPS",
        CurrentValue = false,
        Callback = function(value)
            Variables.autoPlantEnabled = value
            updateStatusLabel()
            
            if value then
                local plantRemote = getPlantRemote()
                if not plantRemote then
                    Bdev:Notify({
                        Title = "❌ Error",
                        Content = "PlantCrop remote tidak ditemukan!",
                        Duration = 4
                    })
                    if autoPlantToggleRef and autoPlantToggleRef.SetValue then
                        autoPlantToggleRef:SetValue(false)
                    end
                    Variables.autoPlantEnabled = false
                    updateStatusLabel()
                    return
                end
                
                plantCount = 0
                Bdev:Notify({
                    Title = "🤖 Auto Plant ON",
                    Content = string.format("Menanam %s...", selectedSeed),
                    Duration = 2
                })
                
                if plantConnection then
                    plantConnection:Disconnect()
                end
                
                plantConnection = RunService.Heartbeat:Connect(function()
                    if not Variables.autoPlantEnabled then return end
                    
                    local remote = getPlantRemote()
                    if remote then
                        local delay = delaySliderRef and delaySliderRef.GetValue and delaySliderRef:GetValue() or 1.0
                        local plantPos = Vector3.new(customX, customY, customZ)
                        
                        -- Kirim dengan parameter yang benar (sesuaikan dengan kebutuhan remote)
                        local success = pcall(function()
                            -- Format umum: remote:FireServer(seedName, position)
                            -- atau remote:FireServer(position, seedName)
                            -- Sesuaikan dengan format remote game Anda
                            remote:FireServer(selectedSeed, plantPos)
                        end)
                        
                        if success then
                            plantCount = plantCount + 1
                        end
                        
                        task.wait(delay)
                    end
                end)
                
            else
                Bdev:Notify({
                    Title = "🤖 Auto Plant OFF",
                    Content = string.format("Total tanam: %d kali (%s)", plantCount, selectedSeed),
                    Duration = 3
                })
                
                if plantConnection then
                    plantConnection:Disconnect()
                    plantConnection = nil
                end
            end
        end
    })
    
    -- ===== TOMBOL AKSI CEPAT =====
    local ActionFrame = Instance.new("Frame")
    ActionFrame.Name = "ActionFrame"
    ActionFrame.Size = UDim2.new(0.95, 0, 0, 45)
    ActionFrame.BackgroundTransparency = 1
    ActionFrame.LayoutOrder = #Tab.Elements + 1
    ActionFrame.Parent = Tab.Content
    
    local ActionLayout = Instance.new("UIListLayout")
    ActionLayout.FillDirection = Enum.FillDirection.Horizontal
    ActionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ActionLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ActionLayout.Padding = UDim.new(0, 10)
    ActionLayout.Parent = ActionFrame
    
    -- Tombol Plant Now
    local PlantNowBtn = Instance.new("TextButton")
    PlantNowBtn.Name = "PlantNowBtn"
    PlantNowBtn.Size = UDim2.new(0, 120, 0, 40)
    PlantNowBtn.Text = "🌿 PLANT NOW"
    PlantNowBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    PlantNowBtn.BackgroundColor3 = Color3.fromRGB(255, 185, 0)
    PlantNowBtn.BackgroundTransparency = 0
    PlantNowBtn.TextSize = 12
    PlantNowBtn.Font = Enum.Font.GothamBold
    PlantNowBtn.AutoButtonColor = false
    PlantNowBtn.Parent = ActionFrame
    
    local PlantCorner = Instance.new("UICorner")
    PlantCorner.CornerRadius = UDim.new(0, 6)
    PlantCorner.Parent = PlantNowBtn
    
    PlantNowBtn.MouseButton1Click:Connect(function()
        local plantRemote = getPlantRemote()
        if not plantRemote then
            Bdev:Notify({
                Title = "❌ Error",
                Content = "Remote tidak ditemukan!",
                Duration = 2
            })
            return
        end
        
        local plantPos = Vector3.new(customX, customY, customZ)
        
        local success = pcall(function()
            -- Sesuaikan format dengan remote game Anda
            remote:FireServer(selectedSeed, plantPos)
        end)
        
        if success then
            Bdev:Notify({
                Title = "✅ Success",
                Content = string.format("Menanam %s", selectedSeed),
                Duration = 1
            })
        end
    end)
    
    -- Tombol Stop
    local StopBtn = Instance.new("TextButton")
    StopBtn.Name = "StopBtn"
    StopBtn.Size = UDim2.new(0, 100, 0, 40)
    StopBtn.Text = "⏹️ STOP"
    StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    StopBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
    StopBtn.BackgroundTransparency = 0
    StopBtn.TextSize = 12
    StopBtn.Font = Enum.Font.GothamBold
    StopBtn.AutoButtonColor = false
    StopBtn.Parent = ActionFrame
    
    local StopCorner = Instance.new("UICorner")
    StopCorner.CornerRadius = UDim.new(0, 6)
    StopCorner.Parent = StopBtn
    
    StopBtn.MouseButton1Click:Connect(function()
        if autoPlantToggleRef and autoPlantToggleRef.SetValue then
            autoPlantToggleRef:SetValue(false)
        end
    end)
    
    -- ===== KEYBIND INFO =====
    Tab:CreateLabel({
        Name = "KeybindInfo",
        Text = "⌨️ Tekan R untuk record posisi player",
        Color = Color3.fromRGB(150, 150, 160),
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- ===== HOVER EFFECTS =====
    local function setupHover(btn, normalColor, hoverColor)
        btn.MouseEnter:Connect(function()
            tween(btn, {BackgroundColor3 = hoverColor}, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            tween(btn, {BackgroundColor3 = normalColor}, 0.15)
        end)
    end
    
    setupHover(RecordBtn, Color3.fromRGB(70, 70, 85), Color3.fromRGB(90, 90, 105))
    setupHover(ResetBtn, Color3.fromRGB(70, 70, 85), Color3.fromRGB(90, 90, 105))
    setupHover(PlantNowBtn, Color3.fromRGB(255, 185, 0), Color3.fromRGB(255, 215, 100))
    setupHover(StopBtn, Color3.fromRGB(70, 70, 85), Color3.fromRGB(90, 90, 105))
    
    -- ===== KEYBIND R UNTUK RECORD =====
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.R then
            local playerPos = getPlayerPosition()
            if playerPos then
                updatePositionSliders(playerPos)
                Bdev:Notify({
                    Title = "⌨️ Quick Record",
                    Content = "Posisi direkam (tekan R)",
                    Duration = 1
                })
            end
        end
    end)
    
    -- ===== CLEANUP =====
    local function cleanup()
        if plantConnection then
            plantConnection:Disconnect()
            plantConnection = nil
        end
        Variables.autoPlantEnabled = false
    end
    
    -- ===== SHARE FUNCTIONS =====
    Shared.Modules = Shared.Modules or {}
    Shared.Modules.AutoFarm = {
        GetPosition = function() return Vector3.new(customX, customY, customZ) end,
        SetPosition = function(x, y, z)
            updatePositionSliders(Vector3.new(x, y, z))
        end,
        GetStatus = function() return Variables.autoPlantEnabled end,
        GetSelectedSeed = function() return selectedSeed end,
        SetSeed = function(seedDisplay)
            if seedDropdownRef and seedDropdownRef.SetValue then
                seedDropdownRef:SetValue(seedDisplay)
            end
        end,
        StopAuto = function()
            if autoPlantToggleRef and autoPlantToggleRef.SetValue then
                autoPlantToggleRef:SetValue(false)
            end
        end,
        PlantOnce = function()
            local remote = getPlantRemote()
            if remote then
                local pos = Vector3.new(customX, customY, customZ)
                pcall(function() remote:FireServer(selectedSeed, pos) end)
            end
        end
    }
    
    print("✅ AutoFarm module loaded - dengan Pilihan Bibit")
    
    return cleanup
end

return AutoFarm