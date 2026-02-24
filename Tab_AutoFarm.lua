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
    
    -- Variabel untuk jenis bibit
    local selectedSeed = "Bibit Padi" -- Default
    
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
    
    -- Dapatkan remote RequestShop
    local function getShopRemote()
        local success, remote = pcall(function()
            return ReplicatedStorage.Remotes.TutorialRemotes.RequestShop
        end)
        
        if success and remote then
            return remote
        end
        
        -- Coba cari dengan aman
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            local tutorial = remotes:FindFirstChild("TutorialRemotes")
            if tutorial then
                return tutorial:FindFirstChild("RequestShop")
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
            xSlider.SetValue(customX)
        end
        if ySlider then
            ySlider.SetValue(customY)
        end
        if zSlider then
            zSlider.SetValue(customZ)
        end
        
        -- Tampilkan notifikasi
        Bdev:Notify({
            Title = "Position Recorded",
            Content = string.format("📍 X: %.1f, Y: %.1f, Z: %.1f", customX, customY, customZ),
            Duration = 3
        })
    end
    
    -- Fungsi untuk membeli bibit
    local function buySeed(seedName, amount)
        local shopRemote = getShopRemote()
        if not shopRemote then
            Bdev:Notify({
                Title = "Error",
                Content = "❌ Remote shop tidak ditemukan!",
                Duration = 3
            })
            return false
        end
        
        local arguments = {
            [1] = "BUY",
            [2] = seedName,
            [3] = amount
        }
        
        local success, result = pcall(function()
            return shopRemote:InvokeServer(unpack(arguments))
        end)
        
        if success then
            Bdev:Notify({
                Title = "Purchase Success",
                Content = string.format("✅ Membeli %s x%d", seedName, amount),
                Duration = 2
            })
            return true
        else
            Bdev:Notify({
                Title = "Purchase Failed",
                Content = string.format("❌ Gagal membeli %s", seedName),
                Duration = 2
            })
            return false
        end
    end
    
    -- Fungsi untuk mendapatkan daftar bibit dari shop
    local function getSeedList()
        local shopRemote = getShopRemote()
        if not shopRemote then return {} end
        
        local arguments = {
            [1] = "GET_LIST"
        }
        
        local success, result = pcall(function()
            return shopRemote:InvokeServer(unpack(arguments))
        end)
        
        if success and result then
            return result
        end
        return {}
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
    
    -- ===== SEED SELECTION =====
    Tab:CreateLabel({
        Name = "SeedLabel",
        Text = "🌾 PILIH JENIS BIBIT",
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- Dropdown untuk memilih bibit
    -- Karena SimpleGUI tidak memiliki CreateDropdown bawaan, kita buat manual dengan button
    local SeedFrame = Instance.new("Frame")
    SeedFrame.Name = "SeedSelector"
    SeedFrame.Size = UDim2.new(0.95, 0, 0, 40)
    SeedFrame.BackgroundTransparency = 1
    SeedFrame.LayoutOrder = #Tab.Elements + 1
    SeedFrame.Parent = Tab.Content
    
    local SeedButton = Instance.new("TextButton")
    SeedButton.Name = "SeedButton"
    SeedButton.Size = UDim2.new(1, 0, 1, 0)
    SeedButton.Text = "🔽 " .. selectedSeed
    SeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SeedButton.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
    SeedButton.TextSize = 13
    SeedButton.Font = Enum.Font.Gotham
    SeedButton.AutoButtonColor = false
    SeedButton.Parent = SeedFrame
    
    local SeedCorner = Instance.new("UICorner")
    SeedCorner.CornerRadius = UDim.new(0, 6)
    SeedCorner.Parent = SeedButton
    
    -- Dropdown menu (akan muncul saat button diklik)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Name = "DropdownMenu"
    DropdownFrame.Size = UDim2.new(1, 0, 0, 0)
    DropdownFrame.Position = UDim2.new(0, 0, 1, 5)
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    DropdownFrame.BackgroundTransparency = 0
    DropdownFrame.Visible = false
    DropdownFrame.Parent = SeedFrame
    
    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 6)
    DropdownCorner.Parent = DropdownFrame
    
    local DropdownLayout = Instance.new("UIListLayout")
    DropdownLayout.Padding = UDim.new(0, 2)
    DropdownLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    DropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
    DropdownLayout.Parent = DropdownFrame
    
    local DropdownPadding = Instance.new("UIPadding")
    DropdownPadding.PaddingTop = UDim.new(0, 5)
    DropdownPadding.PaddingBottom = UDim.new(0, 5)
    DropdownPadding.PaddingLeft = UDim.new(0, 5)
    DropdownPadding.PaddingRight = UDim.new(0, 5)
    DropdownPadding.Parent = DropdownFrame
    
    -- Daftar bibit
    local seedList = {
        "Bibit Padi",
        "Bibit Jagung",
        "Bibit Tomat", 
        "Bibit Terong",
        "Bibit Strawberry"
    }
    
    -- Buat button untuk setiap bibit
    local seedButtons = {}
    for _, seedName in ipairs(seedList) do
        local seedOption = Instance.new("TextButton")
        seedOption.Name = seedName .. "_Option"
        seedOption.Size = UDim2.new(1, -10, 0, 30)
        seedOption.Text = seedName
        seedOption.TextColor3 = Color3.fromRGB(255, 255, 255)
        seedOption.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
        seedOption.TextSize = 13
        seedOption.Font = Enum.Font.Gotham
        seedOption.AutoButtonColor = false
        seedOption.Parent = DropdownFrame
        
        local optionCorner = Instance.new("UICorner")
        optionCorner.CornerRadius = UDim.new(0, 4)
        optionCorner.Parent = seedOption
        
        seedOption.MouseButton1Click:Connect(function()
            selectedSeed = seedName
            SeedButton.Text = "🔽 " .. selectedSeed
            DropdownFrame.Visible = false
            
            Bdev:Notify({
                Title = "Seed Selected",
                Content = string.format("✅ Bibit: %s", seedName),
                Duration = 1
            })
        end)
        
        seedOption.MouseEnter:Connect(function()
            if not UserInputService.TouchEnabled then
                seedOption.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
            end
        end)
        
        seedOption.MouseLeave:Connect(function()
            if not UserInputService.TouchEnabled then
                seedOption.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
            end
        end)
        
        table.insert(seedButtons, seedOption)
    end
    
    -- Update dropdown size
    DropdownLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        DropdownFrame.Size = UDim2.new(1, 0, 0, DropdownLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Toggle dropdown saat button diklik
    SeedButton.MouseButton1Click:Connect(function()
        DropdownFrame.Visible = not DropdownFrame.Visible
    end)
    
    -- Sembunyikan dropdown saat klik di luar
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            local dropdownAbs = DropdownFrame.AbsolutePosition
            local dropdownSize = DropdownFrame.AbsoluteSize
            
            if DropdownFrame.Visible then
                if mousePos.X < dropdownAbs.X or mousePos.X > dropdownAbs.X + dropdownSize.X or
                   mousePos.Y < dropdownAbs.Y or mousePos.Y > dropdownAbs.Y + dropdownSize.Y then
                    DropdownFrame.Visible = false
                end
            end
        end
    end)
    
    table.insert(Tab.Elements, SeedFrame)
    
    -- Tombol untuk membeli bibit
    Tab:CreateButton({
        Name = "BuySeed",
        Text = "💰 Beli Bibit Terpilih (1x)",
        Callback = function()
            buySeed(selectedSeed, 1)
        end
    })
    
    -- Tombol untuk membeli bibit dalam jumlah banyak
    Tab:CreateButton({
        Name = "BuySeed10",
        Text = "💰💰 Beli Bibit 10x",
        Callback = function()
            buySeed(selectedSeed, 10)
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
                    Content = string.format("🌱 Auto planting %s ENABLED", selectedSeed),
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
                        
                        task.wait(1.0) -- Default delay 1 detik
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
                    Content = string.format("✅ %s ditanam!", selectedSeed),
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
                    Content = string.format("✅ Posisi direkam & %s ditanam!", selectedSeed),
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
    
    -- ===== SLIDER UNTUK POSISI =====
    Tab:CreateLabel({
        Name = "PositionLabel",
        Text = "📌 PLANT POSITION",
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- Slider X
    xSlider = Tab:CreateSlider({
        Name = "PosX",
        Range = {-1000, 1000},
        Increment = 0.1,
        CurrentValue = customX,
        Callback = function(value)
            customX = value
        end
    })
    
    -- Slider Y
    ySlider = Tab:CreateSlider({
        Name = "PosY",
        Range = {0, 1000},
        Increment = 0.1,
        CurrentValue = customY,
        Callback = function(value)
            customY = value
        end
    })
    
    -- Slider Z
    zSlider = Tab:CreateSlider({
        Name = "PosZ",
        Range = {-1000, 1000},
        Increment = 0.1,
        CurrentValue = customZ,
        Callback = function(value)
            customZ = value
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
    
    print("✅ AutoFarm Plants module loaded dengan AUTO RECORD POSISI & SEED SELECTOR")
end

return AutoFarm