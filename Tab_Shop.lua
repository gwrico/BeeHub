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
        {Name = "Bibit Padi", Display = "🌾 Padi"},
        {Name = "Bibit Jagung", Display = "🌽 Jagung"},
        {Name = "Bibit Tomat", Display = "🍅 Tomat"},
        {Name = "Bibit Terong", Display = "🍆 Terong"},
        {Name = "Bibit Strawberry", Display = "🍓 Strawberry"}
    }
    
    -- ===== STATE VARIABLES =====
    local selectedSeed = seedsList[1].Name
    local autoBuyEnabled = false
    local autoBuyConnection = nil
    local buyDelay = 2
    local buyQuantity = 1
    local selectedIndex = 1
    
    -- Variable untuk menyimpan references
    local selectedInfoLabel = nil
    local seedButtons = {}
    
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
            Title = "Auto Buy ON",
            Content = string.format("Membeli setiap %d detik", buyDelay),
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
            Title = "Auto Buy OFF",
            Content = "Dihentikan",
            Duration = 2
        })
    end
    
    -- ===== FUNGSI UPDATE SELECTION =====
    local function updateSeedSelection(index)
        selectedIndex = index
        selectedSeed = seedsList[index].Name
        
        -- Update semua tombol
        for i, btn in ipairs(seedButtons) do
            if i == index then
                btn.Text = "✅ " .. seedsList[i].Display
            else
                btn.Text = "   " .. seedsList[i].Display
            end
        end
        
        -- Update label info
        if selectedInfoLabel then
            selectedInfoLabel.Text = "Bibit terpilih: " .. seedsList[index].Display
        end
        
        Bdev:Notify({
            Title = "Dipilih",
            Content = seedsList[index].Display,
            Duration = 1
        })
    end
    
    -- ===== MEMBUAT UI DENGAN URUTAN VERTIKAL =====
    
    -- 1. PILIH BIBIT SECTION
    local header1 = Tab:CreateLabel({
        Name = "Header_PilihBibit",
        Text = "───── 🌱 PILIH BIBIT ─────",
        Color = Color3.fromRGB(255, 185, 0),
        Bold = true,
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- Label untuk menampilkan bibit yang dipilih
    selectedInfoLabel = Tab:CreateLabel({
        Name = "SelectedInfo",
        Text = "➤ Bibit terpilih: " .. seedsList[1].Display,
        Color = Color3.fromRGB(255, 255, 255),
        Alignment = Enum.TextXAlignment.Left
    })
    
    -- Buat tombol-tombol untuk setiap bibit
    for i, seed in ipairs(seedsList) do
        local isSelected = (i == 1)
        local btn = Tab:CreateButton({
            Name = "SeedBtn_" .. i,
            Text = (isSelected and "✅ " or "   ") .. seed.Display,
            Callback = function()
                updateSeedSelection(i)
            end
        })
        table.insert(seedButtons, btn)
    end
    
    -- Spacer
    Tab:CreateLabel({
        Name = "Spacer1",
        Text = "",
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- 2. PENGATURAN SECTION
    local header2 = Tab:CreateLabel({
        Name = "Header_Pengaturan",
        Text = "───── ⚙️ PENGATURAN ─────",
        Color = Color3.fromRGB(255, 185, 0),
        Bold = true,
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- Slider Jumlah
    local qtySlider = Tab:CreateSlider({
        Name = "QtySlider",
        Text = "Jumlah: " .. buyQuantity,
        Range = {1, 10},
        Increment = 1,
        CurrentValue = 1,
        Callback = function(value)
            buyQuantity = value
        end
    })
    
    -- Slider Delay
    local delaySlider = Tab:CreateSlider({
        Name = "DelaySlider",
        Text = "Delay: " .. buyDelay .. " detik",
        Range = {0.5, 5},
        Increment = 0.5,
        CurrentValue = 2,
        Callback = function(value)
            buyDelay = value
        end
    })
    
    -- Spacer
    Tab:CreateLabel({
        Name = "Spacer2",
        Text = "",
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- 3. MANUAL SECTION
    local header3 = Tab:CreateLabel({
        Name = "Header_Manual",
        Text = "───── 🖱️ MANUAL ─────",
        Color = Color3.fromRGB(255, 185, 0),
        Bold = true,
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- Tombol Beli Manual
    Tab:CreateButton({
        Name = "ManualBuy",
        Text = "🛒 BELI MANUAL",
        Callback = function()
            buySeed(selectedSeed, buyQuantity)
        end
    })
    
    -- Tombol Test Beli 1
    Tab:CreateButton({
        Name = "TestBuy",
        Text = "🧪 TEST BELI (1x)",
        Callback = function()
            buySeed(selectedSeed, 1)
        end
    })
    
    -- Spacer
    Tab:CreateLabel({
        Name = "Spacer3",
        Text = "",
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- 4. AUTO BUY SECTION
    local header4 = Tab:CreateLabel({
        Name = "Header_AutoBuy",
        Text = "───── 🤖 AUTO BUY ─────",
        Color = Color3.fromRGB(255, 185, 0),
        Bold = true,
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- Toggle Auto Buy
    local autoBuyToggle = Tab:CreateToggle({
        Name = "AutoBuyToggle",
        Text = "AKTIFKAN AUTO BUY",
        CurrentValue = false,
        Callback = function(value)
            if value then
                if not checkRemote() then
                    autoBuyToggle:SetValue(false)
                    return
                end
                startAutoBuy()
            else
                stopAutoBuy()
            end
        end
    })
    
    -- Tombol Stop
    Tab:CreateButton({
        Name = "StopButton",
        Text = "⏹️ STOP AUTO BUY",
        Callback = function()
            if autoBuyToggle and autoBuyToggle.SetValue then
                autoBuyToggle:SetValue(false)
            end
        end
    })
    
    -- ===== SHARE FUNCTIONS =====
    Shared.Modules = Shared.Modules or {}
    Shared.Modules.ShopAutoBuy = {
        BuySeed = function(seedName, amount)
            return buySeed(seedName, amount or 1)
        end,
        GetStatus = function()
            return {
                SelectedSeed = selectedSeed,
                AutoBuyEnabled = autoBuyEnabled,
                Delay = buyDelay,
                Quantity = buyQuantity
            }
        end
    }
    
    print("✅ Shop module loaded - SimpleGUI v7.1 compatible")
end

return ShopAutoBuy