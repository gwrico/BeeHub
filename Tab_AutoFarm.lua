-- ==============================================
-- 💰 AUTO FARM TAB MODULE - MINIMALIS
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
    
    -- Default position
    local defaultPos = Vector3.new(67.13851165771484, 39.296875, -263.7070617675781)
    
    -- Custom position
    local customX = defaultPos.X
    local customY = defaultPos.Y
    local customZ = defaultPos.Z
    
    -- References
    local xInput, yInput, zInput
    local plantCount = 0
    local delay = 1.0
    
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
    
    -- Fungsi untuk update input dengan nilai baru
    local function updatePositionInputs(newPos)
        if not newPos then return end
        
        customX = newPos.X
        customY = newPos.Y
        customZ = newPos.Z
        
        if xInput then xInput.Text = string.format("%.1f", customX) end
        if yInput then yInput.Text = string.format("%.1f", customY) end
        if zInput then zInput.Text = string.format("%.1f", customZ) end
    end
    
    -- ===== AUTO PLANT TOGGLE =====
    autoPlantToggleRef = Tab:CreateToggle({
        Name = "AutoPlant",
        Text = "🌱 AUTO PLANT",
        CurrentValue = false,
        Callback = function(value)
            Variables.autoPlantEnabled = value
            
            if value then
                local plantRemote = getPlantRemote()
                if not plantRemote then
                    Bdev:Notify({Title = "❌ Error", Content = "Remote tidak ditemukan!", Duration = 3})
                    if autoPlantToggleRef and autoPlantToggleRef.SetValue then
                        autoPlantToggleRef:SetValue(false)
                    end
                    Variables.autoPlantEnabled = false
                    return
                end
                
                plantCount = 0
                
                if plantConnection then plantConnection:Disconnect() end
                
                plantConnection = RunService.Heartbeat:Connect(function()
                    if not Variables.autoPlantEnabled then return end
                    
                    local remote = getPlantRemote()
                    if remote then
                        local plantPos = Vector3.new(customX, customY, customZ)
                        pcall(function() remote:FireServer(plantPos) end)
                        plantCount = plantCount + 1
                        task.wait(delay)
                    end
                end)
                
            else
                if plantConnection then
                    plantConnection:Disconnect()
                    plantConnection = nil
                end
            end
        end
    })
    
    -- ===== POSISI SECTION =====
    -- Frame untuk input koordinat (X Y Z dalam satu baris)
    local CoordFrame = Instance.new("Frame")
    CoordFrame.Name = "CoordFrame"
    CoordFrame.Size = UDim2.new(0.95, 0, 0, 50)
    CoordFrame.BackgroundTransparency = 1
    CoordFrame.LayoutOrder = #Tab.Elements + 1
    CoordFrame.Parent = Tab.Content
    
    local CoordLayout = Instance.new("UIListLayout")
    CoordLayout.FillDirection = Enum.FillDirection.Horizontal
    CoordLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    CoordLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    CoordLayout.Padding = UDim.new(0, 5)
    CoordLayout.Parent = CoordFrame
    
    -- Fungsi buat textbox koordinat
    local function createCoordBox(parent, label, default, posIndex)
        local frame = Instance.new("Frame")
        frame.Name = label .. "Frame"
        frame.Size = UDim2.new(0, 90, 0, 36)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        frame.BackgroundTransparency = 0
        frame.Parent = parent
        
        local inputCorner = Instance.new("UICorner")
        inputCorner.CornerRadius = UDim.new(0, 6)
        inputCorner.Parent = frame
        
        local labelObj = Instance.new("TextLabel")
        labelObj.Name = "Label"
        labelObj.Size = UDim2.new(0, 20, 1, 0)
        labelObj.Text = label
        labelObj.TextColor3 = Color3.fromRGB(255, 185, 0)
        labelObj.BackgroundTransparency = 1
        labelObj.TextSize = 14
        labelObj.Font = Enum.Font.GothamBold
        labelObj.Parent = frame
        
        local textBox = Instance.new("TextBox")
        textBox.Name = "Value"
        textBox.Size = UDim2.new(1, -25, 1, 0)
        textBox.Position = UDim2.new(0, 20, 0, 0)
        textBox.Text = string.format("%.1f", default)
        textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        textBox.BackgroundTransparency = 1
        textBox.TextSize = 14
        textBox.Font = Enum.Font.Gotham
        textBox.ClearTextOnFocus = false
        textBox.Parent = frame
        
        textBox.FocusLost:Connect(function()
            local value = tonumber(textBox.Text)
            if value then
                if posIndex == "X" then customX = value
                elseif posIndex == "Y" then customY = value
                elseif posIndex == "Z" then customZ = value end
                textBox.Text = string.format("%.1f", value)
            else
                if posIndex == "X" then textBox.Text = string.format("%.1f", customX)
                elseif posIndex == "Y" then textBox.Text = string.format("%.1f", customY)
                elseif posIndex == "Z" then textBox.Text = string.format("%.1f", customZ) end
            end
        end)
        
        return textBox
    end
    
    -- Buat 3 textbox untuk X, Y, Z
    xInput = createCoordBox(CoordFrame, "X", customX, "X")
    yInput = createCoordBox(CoordFrame, "Y", customY, "Y")
    zInput = createCoordBox(CoordFrame, "Z", customZ, "Z")
    
    -- ===== TOMBOL AKSI =====
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
    ActionLayout.Padding = UDim.new(0, 5)
    ActionLayout.Parent = ActionFrame
    
    -- Tombol Record
    local RecordBtn = Instance.new("TextButton")
    RecordBtn.Size = UDim2.new(0, 70, 0, 36)
    RecordBtn.Text = "📝"
    RecordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    RecordBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
    RecordBtn.BackgroundTransparency = 0
    RecordBtn.TextSize = 16
    RecordBtn.Font = Enum.Font.GothamBold
    RecordBtn.AutoButtonColor = false
    RecordBtn.Parent = ActionFrame
    
    local RecordCorner = Instance.new("UICorner")
    RecordCorner.CornerRadius = UDim.new(0, 6)
    RecordCorner.Parent = RecordBtn
    
    RecordBtn.MouseButton1Click:Connect(function()
        local playerPos = getPlayerPosition()
        if playerPos then updatePositionInputs(playerPos) end
    end)
    
    -- Tombol Reset
    local ResetBtn = Instance.new("TextButton")
    ResetBtn.Size = UDim2.new(0, 70, 0, 36)
    ResetBtn.Text = "🔄"
    ResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ResetBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
    ResetBtn.BackgroundTransparency = 0
    ResetBtn.TextSize = 16
    ResetBtn.Font = Enum.Font.GothamBold
    ResetBtn.AutoButtonColor = false
    ResetBtn.Parent = ActionFrame
    
    local ResetCorner = Instance.new("UICorner")
    ResetCorner.CornerRadius = UDim.new(0, 6)
    ResetCorner.Parent = ResetBtn
    
    ResetBtn.MouseButton1Click:Connect(function()
        updatePositionInputs(defaultPos)
    end)
    
    -- Tombol Plant
    local PlantBtn = Instance.new("TextButton")
    PlantBtn.Size = UDim2.new(0, 70, 0, 36)
    PlantBtn.Text = "🌿"
    PlantBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    PlantBtn.BackgroundColor3 = Color3.fromRGB(255, 185, 0)
    PlantBtn.BackgroundTransparency = 0
    PlantBtn.TextSize = 16
    PlantBtn.Font = Enum.Font.GothamBold
    PlantBtn.AutoButtonColor = false
    PlantBtn.Parent = ActionFrame
    
    local PlantCorner = Instance.new("UICorner")
    PlantCorner.CornerRadius = UDim.new(0, 6)
    PlantCorner.Parent = PlantBtn
    
    PlantBtn.MouseButton1Click:Connect(function()
        local plantRemote = getPlantRemote()
        if plantRemote then
            local plantPos = Vector3.new(customX, customY, customZ)
            pcall(function() plantRemote:FireServer(plantPos) end)
        end
    end)
    
    -- Tombol Stop
    local StopBtn = Instance.new("TextButton")
    StopBtn.Size = UDim2.new(0, 70, 0, 36)
    StopBtn.Text = "⏹️"
    StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    StopBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    StopBtn.BackgroundTransparency = 0
    StopBtn.TextSize = 16
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
        btn.MouseEnter:Connect(function() tween(btn, {BackgroundColor3 = hoverColor}, 0.15) end)
        btn.MouseLeave:Connect(function() tween(btn, {BackgroundColor3 = normalColor}, 0.15) end)
    end
    
    setupHover(RecordBtn, Color3.fromRGB(70, 70, 85), Color3.fromRGB(90, 90, 105))
    setupHover(ResetBtn, Color3.fromRGB(70, 70, 85), Color3.fromRGB(90, 90, 105))
    setupHover(PlantBtn, Color3.fromRGB(255, 185, 0), Color3.fromRGB(255, 215, 100))
    setupHover(StopBtn, Color3.fromRGB(200, 50, 50), Color3.fromRGB(220, 80, 80))
    
    -- ===== CLEANUP =====
    local function cleanup()
        if plantConnection then
            plantConnection:Disconnect()
            plantConnection = nil
        end
        Variables.autoPlantEnabled = false
    end
    
    print("✅ AutoFarm module loaded - Minimalis")
    
    return cleanup
end

return AutoFarm