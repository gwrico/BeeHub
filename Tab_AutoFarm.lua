-- ==============================================
-- 💰 AUTO FARM TAB MODULE - UNTUK PLANT CROP
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
    
    -- Default position
    local defaultPos = Vector3.new(67.13851165771484, 39.296875, -263.7070617675781)
    
    -- Custom position
    local customX = defaultPos.X
    local customY = defaultPos.Y
    local customZ = defaultPos.Z
    
    -- References
    local xInput, yInput, zInput
    local plantCount = 0
    
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
    
    -- Fungsi untuk update input dengan nilai baru
    local function updatePositionInputs(newPos)
        if not newPos then return end
        
        customX = newPos.X
        customY = newPos.Y
        customZ = newPos.Z
        
        -- Update input jika reference tersedia
        if xInput then
            xInput.Text = string.format("%.1f", customX)
        end
        if yInput then
            yInput.Text = string.format("%.1f", customY)
        end
        if zInput then
            zInput.Text = string.format("%.1f", customZ)
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
    
    -- Frame untuk input koordinat
    local CoordFrame = Instance.new("Frame")
    CoordFrame.Name = "CoordFrame"
    CoordFrame.Size = UDim2.new(0.95, 0, 0, 80)
    CoordFrame.BackgroundTransparency = 1
    CoordFrame.LayoutOrder = #Tab.Elements + 1
    CoordFrame.Parent = Tab.Content
    
    local CoordLayout = Instance.new("UIListLayout")
    CoordLayout.FillDirection = Enum.FillDirection.Horizontal
    CoordLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    CoordLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    CoordLayout.Padding = UDim.new(0, 10)
    CoordLayout.Parent = CoordFrame
    
    -- Fungsi buat textbox koordinat
    local function createCoordBox(parent, label, default, posIndex)
        local frame = Instance.new("Frame")
        frame.Name = label .. "Frame"
        frame.Size = UDim2.new(0, 100, 0, 50)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local labelObj = Instance.new("TextLabel")
        labelObj.Name = "Label"
        labelObj.Size = UDim2.new(1, 0, 0, 20)
        labelObj.Text = label
        labelObj.TextColor3 = Color3.fromRGB(255, 185, 0)
        labelObj.BackgroundTransparency = 1
        labelObj.TextSize = 14
        labelObj.Font = Enum.Font.GothamBold
        labelObj.Parent = frame
        
        local inputFrame = Instance.new("Frame")
        inputFrame.Name = "InputFrame"
        inputFrame.Size = UDim2.new(1, 0, 0, 30)
        inputFrame.Position = UDim2.new(0, 0, 0, 20)
        inputFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        inputFrame.BackgroundTransparency = 0
        inputFrame.Parent = frame
        
        local inputCorner = Instance.new("UICorner")
        inputCorner.CornerRadius = UDim.new(0, 6)
        inputCorner.Parent = inputFrame
        
        local textBox = Instance.new("TextBox")
        textBox.Name = "Value"
        textBox.Size = UDim2.new(1, -10, 1, 0)
        textBox.Position = UDim2.new(0, 5, 0, 0)
        textBox.Text = string.format("%.1f", default)
        textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        textBox.BackgroundTransparency = 1
        textBox.TextSize = 14
        textBox.Font = Enum.Font.Gotham
        textBox.ClearTextOnFocus = false
        textBox.Parent = inputFrame
        
        -- Event untuk validasi
        textBox.FocusLost:Connect(function()
            local value = tonumber(textBox.Text)
            if value then
                if posIndex == "X" then
                    customX = value
                elseif posIndex == "Y" then
                    customY = value
                elseif posIndex == "Z" then
                    customZ = value
                end
                textBox.Text = string.format("%.1f", value)
            else
                -- Kembalikan ke nilai sebelumnya
                if posIndex == "X" then
                    textBox.Text = string.format("%.1f", customX)
                elseif posIndex == "Y" then
                    textBox.Text = string.format("%.1f", customY)
                elseif posIndex == "Z" then
                    textBox.Text = string.format("%.1f", customZ)
                end
            end
        end)
        
        return textBox
    end
    
    -- Buat 3 textbox untuk X, Y, Z
    xInput = createCoordBox(CoordFrame, "X", customX, "X")
    yInput = createCoordBox(CoordFrame, "Y", customY, "Y")
    zInput = createCoordBox(CoordFrame, "Z", customZ, "Z")
    
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
            updatePositionInputs(playerPos)
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
        updatePositionInputs(defaultPos)
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
        Text = "───── ⏱️ PENGATURAN DELAY ─────",
        Color = Color3.fromRGB(255, 185, 0),
        Bold = true,
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- Frame untuk input delay
    local DelayFrame = Instance.new("Frame")
    DelayFrame.Name = "DelayFrame"
    DelayFrame.Size = UDim2.new(0.95, 0, 0, 50)
    DelayFrame.BackgroundTransparency = 1
    DelayFrame.LayoutOrder = #Tab.Elements + 1
    DelayFrame.Parent = Tab.Content
    
    local DelayInputFrame = Instance.new("Frame")
    DelayInputFrame.Name = "DelayInputFrame"
    DelayInputFrame.Size = UDim2.new(0.5, 0, 0, 36)
    DelayInputFrame.Position = UDim2.new(0.25, 0, 0, 0)
    DelayInputFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    DelayInputFrame.BackgroundTransparency = 0
    DelayInputFrame.Parent = DelayFrame
    
    local DelayCorner = Instance.new("UICorner")
    DelayCorner.CornerRadius = UDim.new(0, 6)
    DelayCorner.Parent = DelayInputFrame
    
    local DelayLabel = Instance.new("TextLabel")
    DelayLabel.Name = "DelayLabel"
    DelayLabel.Size = UDim2.new(0, 50, 1, 0)
    DelayLabel.Text = "⏱️"
    DelayLabel.TextColor3 = Color3.fromRGB(255, 185, 0)
    DelayLabel.BackgroundTransparency = 1
    DelayLabel.TextSize = 16
    DelayLabel.Font = Enum.Font.GothamBold
    DelayLabel.Parent = DelayInputFrame
    
    local DelayBox = Instance.new("TextBox")
    DelayBox.Name = "DelayBox"
    DelayBox.Size = UDim2.new(1, -80, 1, 0)
    DelayBox.Position = UDim2.new(0, 50, 0, 0)
    DelayBox.Text = "1.0"
    DelayBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    DelayBox.BackgroundTransparency = 1
    DelayBox.TextSize = 14
    DelayBox.Font = Enum.Font.Gotham
    DelayBox.ClearTextOnFocus = false
    DelayBox.Parent = DelayInputFrame
    
    local DelayUnit = Instance.new("TextLabel")
    DelayUnit.Name = "DelayUnit"
    DelayUnit.Size = UDim2.new(0, 30, 1, 0)
    DelayUnit.Position = UDim2.new(1, -30, 0, 0)
    DelayUnit.Text = "dtk"
    DelayUnit.TextColor3 = Color3.fromRGB(150, 150, 160)
    DelayUnit.BackgroundTransparency = 1
    DelayUnit.TextSize = 12
    DelayUnit.Font = Enum.Font.Gotham
    DelayUnit.Parent = DelayInputFrame
    
    DelayBox.FocusLost:Connect(function()
        local value = tonumber(DelayBox.Text)
        if value and value >= 0.1 and value <= 5 then
            DelayBox.Text = string.format("%.1f", value)
        else
            DelayBox.Text = "1.0"
            Bdev:Notify({
                Title = "❌ Invalid",
                Content = "Delay harus 0.1 - 5 detik",
                Duration = 2
            })
        end
    end)
    
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
                    Content = "Mulai menanam...",
                    Duration = 2
                })
                
                if plantConnection then
                    plantConnection:Disconnect()
                end
                
                plantConnection = RunService.Heartbeat:Connect(function()
                    if not Variables.autoPlantEnabled then return end
                    
                    local remote = getPlantRemote()
                    if remote then
                        local delay = tonumber(DelayBox.Text) or 1.0
                        local plantPos = Vector3.new(customX, customY, customZ)
                        
                        -- FIRESERVER SESUAI FORMAT: hanya 1 argument (Vector3)
                        local success = pcall(function()
                            remote:FireServer(plantPos)
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
                    Content = string.format("Total tanam: %d kali", plantCount),
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
            plantRemote:FireServer(plantPos)
        end)
        
        if success then
            Bdev:Notify({
                Title = "✅ Success",
                Content = "Menanam berhasil!",
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
            updatePositionInputs(Vector3.new(x, y, z))
        end,
        GetStatus = function() return Variables.autoPlantEnabled end,
        StopAuto = function()
            if autoPlantToggleRef and autoPlantToggleRef.SetValue then
                autoPlantToggleRef:SetValue(false)
            end
        end,
        PlantOnce = function()
            local remote = getPlantRemote()
            if remote then
                local pos = Vector3.new(customX, customY, customZ)
                pcall(function() remote:FireServer(pos) end)
            end
        end
    }
    
    print("✅ AutoFarm module loaded - Sesuai format PlantCrop")
    
    return cleanup
end

return AutoFarm