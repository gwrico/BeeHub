-- ==============================================
-- 🛒 SHOP MODULE - BELI BIBIT (SIMPLEGUI v7.1)
-- ==============================================

local ShopAutoBuy = {}

function ShopAutoBuy.Init(Dependencies)
    local Tab = Dependencies.Tab
    local Shared = Dependencies.Shared
    local Bdev = Dependencies.Bdev
    local GUI = Dependencies.GUI or Shared.GUI
    
    -- Get services
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    
    -- ===== REMOTE SHOP =====
    local RequestShop = ReplicatedStorage:FindFirstChild("Remotes")
    if RequestShop then
        RequestShop = RequestShop:FindFirstChild("TutorialRemotes")
        if RequestShop then
            RequestShop = RequestShop:FindFirstChild("RequestShop")
        end
    end
    
    -- ===== DAFTAR BIBIT =====
    local seedsList = {
        {Display = "🌾 Padi", Name = "Bibit Padi"},
        {Display = "🌽 Jagung", Name = "Bibit Jagung"},
        {Display = "🍅 Tomat", Name = "Bibit Tomat"},
        {Display = "🍆 Terong", Name = "Bibit Terong"},
        {Display = "🍓 Strawberry", Name = "Bibit Strawberry"},
        {Display = "None", Name = "None"}
    }
    
    -- Buat array terpisah untuk dropdown options (hanya display names)
    local seedDisplayOptions = {}
    for i, seed in ipairs(seedsList) do
        seedDisplayOptions[i] = seed.Display
    end
    
    -- Mapping untuk konversi Display -> Name
    local displayToName = {}
    for i, seed in ipairs(seedsList) do
        displayToName[seed.Display] = seed.Name
    end
    
    -- ===== STATE VARIABLES =====
    local selectedDisplay = seedDisplayOptions[1]
    local selectedSeed = displayToName[selectedDisplay]
    local autoBuyEnabled = false
    local autoBuyConnection = nil
    local buyDelay = 2
    local buyQuantity = 1
    
    -- Variable untuk menyimpan references
    local dropdownRef = nil
    local infoLabelRef = nil
    local qtyInputRef = nil
    local delayInputRef = nil
    local autoBuyToggleRef = nil
    
    -- ===== FUNGSI CEK REMOTE =====
    local function checkRemote()
        if not RequestShop then
            Bdev:Notify({
                Title = "Error",
                Content = "❌ Remote RequestShop tidak ditemukan!",
                Duration = 4
            })
            return false
        end
        return true
    end
    
    -- ===== FUNGSI BELI BIBIT =====
    local function buySeed(seedName, amount)
        if not checkRemote() then return false end
        
        amount = amount or 1
        
        local arguments = {
            [1] = "BUY",
            [2] = seedName,
            [3] = amount
        }
        
        local success, result = pcall(function()
            return RequestShop:InvokeServer(unpack(arguments))
        end)
        
        if success then
            Bdev:Notify({
                Title = "✅ Berhasil",
                Content = string.format("%s x%d", seedName, amount),
                Duration = 2
            })
            return true
        else
            Bdev:Notify({
                Title = "❌ Gagal",
                Content = "Mungkin uang tidak cukup?",
                Duration = 3
            })
            return false
        end
    end
    
    -- ===== AUTO BUY LOOP =====
    local function startAutoBuy()
        if autoBuyConnection then
            autoBuyConnection:Disconnect()
        end
        
        autoBuyEnabled = true
        
        Bdev:Notify({
            Title = "🤖 Auto Buy ON",
            Content = string.format("%s setiap %d detik", selectedDisplay, buyDelay),
            Duration = 3
        })
        
        local lastBuyTime = 0
        autoBuyConnection = RunService.Heartbeat:Connect(function()
            if not autoBuyEnabled then return end
            
            if tick() - lastBuyTime >= buyDelay then
                buySeed(selectedSeed, buyQuantity)
                lastBuyTime = tick()
            end
        end)
    end
    
    local function stopAutoBuy()
        autoBuyEnabled = false
        if autoBuyConnection then
            autoBuyConnection:Disconnect()
            autoBuyConnection = nil
        end
        
        Bdev:Notify({
            Title = "⏹️ Auto Buy OFF",
            Content = "Dihentikan",
            Duration = 2
        })
    end
    
    -- ===== FUNGSI UPDATE INFO LABEL =====
    local function updateInfoLabel()
        if infoLabelRef then
            infoLabelRef.Text = "➤ Bibit aktif: " .. selectedDisplay
        end
    end
    
    -- ===== MEMBUAT UI DENGAN DROPDOWN =====
    
    -- 1. PILIH BIBIT SECTION
    local header1 = Tab:CreateLabel({
        Name = "Header_PilihBibit",
        Text = "───── 🌱 PILIH BIBIT ─────",
        Color = Color3.fromRGB(255, 185, 0),
        Bold = true,
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- DROPDOWN untuk memilih bibit
    dropdownRef = Tab:CreateDropdown({
        Name = "SeedDropdown",
        Text = "Pilih Bibit:",
        Options = seedDisplayOptions,
        Default = seedDisplayOptions[1],
        Callback = function(value)
            selectedDisplay = value
            selectedSeed = displayToName[value]
            updateInfoLabel()
            
            Bdev:Notify({
                Title = "Bibit Dipilih",
                Content = value,
                Duration = 1
            })
            
            print("✅ Dipilih:", value, "->", selectedSeed)
            
            if autoBuyEnabled then
                stopAutoBuy()
                startAutoBuy()
            end
        end
    })
    
    -- Label info untuk menampilkan bibit yang dipilih
    infoLabelRef = Tab:CreateLabel({
        Name = "InfoLabel",
        Text = "➤ Bibit aktif: " .. selectedDisplay,
        Color = Color3.fromRGB(255, 255, 255),
        Alignment = Enum.TextXAlignment.Left
    })
    
    -- Spacer
    Tab:CreateLabel({
        Name = "Spacer1",
        Text = "",
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- 2. PENGATURAN & AUTO BUY SECTION (DIGABUNG)
    local header2 = Tab:CreateLabel({
        Name = "Header_PengaturanAuto",
        Text = "───── ⚙️ PENGATURAN & AUTO BUY ─────",
        Color = Color3.fromRGB(255, 185, 0),
        Bold = true,
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- Frame untuk pengaturan dalam satu baris (jumlah & delay)
    local SettingsFrame = Instance.new("Frame")
    SettingsFrame.Name = "SettingsFrame"
    SettingsFrame.Size = UDim2.new(0.95, 0, 0, 40)
    SettingsFrame.BackgroundTransparency = 1
    SettingsFrame.LayoutOrder = #Tab.Elements + 1
    SettingsFrame.Parent = Tab.Content
    
    -- Layout horizontal untuk settings
    local SettingsLayout = Instance.new("UIListLayout")
    SettingsLayout.FillDirection = Enum.FillDirection.Horizontal
    SettingsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SettingsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    SettingsLayout.Padding = UDim.new(0, 10)
    SettingsLayout.Parent = SettingsFrame
    
    -- TextBox untuk Jumlah (modern)
    local QtyFrame = Instance.new("Frame")
    QtyFrame.Name = "QtyFrame"
    QtyFrame.Size = UDim2.new(0, 80, 0, 36)
    QtyFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    QtyFrame.BackgroundTransparency = 0
    QtyFrame.Parent = SettingsFrame
    
    local QtyCorner = Instance.new("UICorner")
    QtyCorner.CornerRadius = UDim.new(0, 6)
    QtyCorner.Parent = QtyFrame
    
    local QtyLabel = Instance.new("TextLabel")
    QtyLabel.Name = "QtyLabel"
    QtyLabel.Size = UDim2.new(0, 30, 1, 0)
    QtyLabel.Text = "x"
    QtyLabel.TextColor3 = Color3.fromRGB(255, 185, 0)
    QtyLabel.BackgroundTransparency = 1
    QtyLabel.TextSize = 16
    QtyLabel.Font = Enum.Font.GothamBold
    QtyLabel.Parent = QtyFrame
    
    local QtyBox = Instance.new("TextBox")
    QtyBox.Name = "QtyBox"
    QtyBox.Size = UDim2.new(1, -30, 1, 0)
    QtyBox.Position = UDim2.new(0, 30, 0, 0)
    QtyBox.Text = tostring(buyQuantity)
    QtyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    QtyBox.BackgroundTransparency = 1
    QtyBox.TextSize = 14
    QtyBox.Font = Enum.Font.Gotham
    QtyBox.ClearTextOnFocus = false
    QtyBox.Parent = QtyFrame
    
    -- TextBox untuk Delay (modern)
    local DelayFrame = Instance.new("Frame")
    DelayFrame.Name = "DelayFrame"
    DelayFrame.Size = UDim2.new(0, 100, 0, 36)
    DelayFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    DelayFrame.BackgroundTransparency = 0
    DelayFrame.Parent = SettingsFrame
    
    local DelayCorner = Instance.new("UICorner")
    DelayCorner.CornerRadius = UDim.new(0, 6)
    DelayCorner.Parent = DelayFrame
    
    local DelayLabel = Instance.new("TextLabel")
    DelayLabel.Name = "DelayLabel"
    DelayLabel.Size = UDim2.new(0, 40, 1, 0)
    DelayLabel.Text = "⏱️"
    DelayLabel.TextColor3 = Color3.fromRGB(255, 185, 0)
    DelayLabel.BackgroundTransparency = 1
    DelayLabel.TextSize = 16
    DelayLabel.Font = Enum.Font.GothamBold
    DelayLabel.Parent = DelayFrame
    
    local DelayBox = Instance.new("TextBox")
    DelayBox.Name = "DelayBox"
    DelayBox.Size = UDim2.new(1, -40, 1, 0)
    DelayBox.Position = UDim2.new(0, 40, 0, 0)
    DelayBox.Text = tostring(buyDelay) .. "s"
    DelayBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    DelayBox.BackgroundTransparency = 1
    DelayBox.TextSize = 14
    DelayBox.Font = Enum.Font.Gotham
    DelayBox.ClearTextOnFocus = false
    DelayBox.Parent = DelayFrame
    
    -- Fungsi untuk validasi input
    QtyBox.FocusLost:Connect(function()
        local value = tonumber(QtyBox.Text)
        if value and value >= 1 and value <= 10 then
            buyQuantity = math.floor(value)
            QtyBox.Text = tostring(buyQuantity)
        else
            QtyBox.Text = tostring(buyQuantity)
            Bdev:Notify({
                Title = "❌ Invalid",
                Content = "Jumlah harus 1-10",
                Duration = 2
            })
        end
    end)
    
    DelayBox.FocusLost:Connect(function()
        local text = DelayBox.Text:gsub("s", "")
        local value = tonumber(text)
        if value and value >= 0.5 and value <= 5 then
            buyDelay = value
            DelayBox.Text = tostring(buyDelay) .. "s"
            
            if autoBuyEnabled then
                stopAutoBuy()
                startAutoBuy()
            end
        else
            DelayBox.Text = tostring(buyDelay) .. "s"
            Bdev:Notify({
                Title = "❌ Invalid",
                Content = "Delay harus 0.5-5 detik",
                Duration = 2
            })
        end
    end)
    
    -- Tombol Aksi Cepat
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
    
    -- Tombol Beli Sekarang
    local BuyNowBtn = Instance.new("TextButton")
    BuyNowBtn.Name = "BuyNowBtn"
    BuyNowBtn.Size = UDim2.new(0, 120, 0, 36)
    BuyNowBtn.Text = "🛒 BELI"
    BuyNowBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    BuyNowBtn.BackgroundColor3 = Color3.fromRGB(255, 185, 0)
    BuyNowBtn.BackgroundTransparency = 0
    BuyNowBtn.TextSize = 14
    BuyNowBtn.Font = Enum.Font.GothamBold
    BuyNowBtn.AutoButtonColor = false
    BuyNowBtn.Parent = ActionFrame
    
    local BuyCorner = Instance.new("UICorner")
    BuyCorner.CornerRadius = UDim.new(0, 6)
    BuyCorner.Parent = BuyNowBtn
    
    BuyNowBtn.MouseButton1Click:Connect(function()
        buySeed(selectedSeed, buyQuantity)
    end)
    
    -- Toggle Auto Buy (dalam bentuk tombol modern)
    local AutoToggleBtn = Instance.new("TextButton")
    AutoToggleBtn.Name = "AutoToggleBtn"
    AutoToggleBtn.Size = UDim2.new(0, 120, 0, 36)
    AutoToggleBtn.Text = "🤖 AUTO OFF"
    AutoToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    AutoToggleBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
    AutoToggleBtn.BackgroundTransparency = 0
    AutoToggleBtn.TextSize = 14
    AutoToggleBtn.Font = Enum.Font.GothamBold
    AutoToggleBtn.AutoButtonColor = false
    AutoToggleBtn.Parent = ActionFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    ToggleCorner.Parent = AutoToggleBtn
    
    -- Fungsi untuk update tampilan tombol auto
    local function updateAutoButton()
        if autoBuyEnabled then
            AutoToggleBtn.Text = "🤖 AUTO ON"
            AutoToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 185, 0)
        else
            AutoToggleBtn.Text = "🤖 AUTO OFF"
            AutoToggleBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
        end
    end
    
    AutoToggleBtn.MouseButton1Click:Connect(function()
        if not autoBuyEnabled then
            if checkRemote() then
                startAutoBuy()
            end
        else
            stopAutoBuy()
        end
        updateAutoButton()
    end)
    
    -- Tombol Stop (X)
    local StopBtn = Instance.new("TextButton")
    StopBtn.Name = "StopBtn"
    StopBtn.Size = UDim2.new(0, 40, 0, 36)
    StopBtn.Text = "✕"
    StopBtn.TextColor3 = Color3.fromRGB(255, 70, 70)
    StopBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
    StopBtn.BackgroundTransparency = 0
    StopBtn.TextSize = 16
    StopBtn.Font = Enum.Font.GothamBold
    StopBtn.AutoButtonColor = false
    StopBtn.Parent = ActionFrame
    
    local StopCorner = Instance.new("UICorner")
    StopCorner.CornerRadius = UDim.new(0, 6)
    StopCorner.Parent = StopBtn
    
    StopBtn.MouseButton1Click:Connect(function()
        if autoBuyEnabled then
            stopAutoBuy()
            updateAutoButton()
        end
    end)
    
    -- Hover effects
    local function setupHover(btn, normalColor, hoverColor)
        btn.MouseEnter:Connect(function()
            tween(btn, {BackgroundColor3 = hoverColor}, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            tween(btn, {BackgroundColor3 = normalColor}, 0.15)
        end)
    end
    
    setupHover(BuyNowBtn, Color3.fromRGB(255, 185, 0), Color3.fromRGB(255, 215, 100))
    setupHover(StopBtn, Color3.fromRGB(40, 40, 52), Color3.fromRGB(55, 55, 70))
    
    -- ===== CLEANUP FUNCTION =====
    local function cleanup()
        if autoBuyConnection then
            autoBuyConnection:Disconnect()
            autoBuyConnection = nil
        end
        autoBuyEnabled = false
    end
    
    -- ===== SHARE FUNCTIONS =====
    Shared.Modules = Shared.Modules or {}
    Shared.Modules.ShopAutoBuy = {
        BuySeed = function(seedName, amount)
            return buySeed(seedName, amount or 1)
        end,
        GetStatus = function()
            return {
                SelectedDisplay = selectedDisplay,
                SelectedSeed = selectedSeed,
                AutoBuyEnabled = autoBuyEnabled,
                Delay = buyDelay,
                Quantity = buyQuantity
            }
        end,
        StopAutoBuy = stopAutoBuy,
        StartAutoBuy = function()
            if checkRemote() then
                startAutoBuy()
                updateAutoButton()
            end
        end,
        SetSeed = function(seedDisplay)
            if displayToName[seedDisplay] then
                selectedDisplay = seedDisplay
                selectedSeed = displayToName[seedDisplay]
                if dropdownRef and dropdownRef.SetValue then
                    dropdownRef:SetValue(seedDisplay)
                end
                updateInfoLabel()
            end
        end,
        SetQuantity = function(value)
            if value >= 1 and value <= 10 then
                buyQuantity = value
                QtyBox.Text = tostring(value)
            end
        end,
        SetDelay = function(value)
            if value >= 0.5 and value <= 5 then
                buyDelay = value
                DelayBox.Text = tostring(value) .. "s"
            end
        end
    }
    
    print("✅ Shop module loaded - Modern Edition")
    
    return cleanup
end

return ShopAutoBuy