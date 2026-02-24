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
    
    -- ===== FUNGSI CEK SHOP LIST =====
    local function checkShopList()
        if not checkRemote() then return end
        
        local arguments = {
            [1] = "GET_LIST"
        }
        
        local success, result = pcall(function()
            return RequestShop:InvokeServer(unpack(arguments))
        end)
        
        if success and result then
            Bdev:Notify({
                Title = "📋 Shop List",
                Content = "Cek console untuk detail",
                Duration = 3
            })
            print("===== SHOP ITEMS =====")
            print(result)
            print("======================")
        else
            Bdev:Notify({
                Title = "Error",
                Content = "Gagal mendapatkan shop list",
                Duration = 3
            })
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
    
    -- ===== MEMBUAT UI =====
    
    -- SECTION 1: PILIH BIBIT
    Tab:CreateSection("🌱 PILIH BIBIT")
    
    -- Buat label untuk menampilkan bibit yang dipilih (dibuat pertama)
    selectedInfoLabel = Tab:CreateLabel({
        Name = "SelectedInfo",
        Text = "Bibit terpilih: " .. seedsList[1].Display,
        Color = Color3.fromRGB(255, 185, 0) -- Kuning BeeHub
    })
    
    -- Buat tombol-tombol untuk setiap bibit dalam grid 2 kolom? 
    -- Tapi karena SimpleGUI mungkin tidak support grid, kita buat berurutan
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
    
    -- SECTION 2: PENGATURAN
    Tab:CreateSection("⚙️ PENGATURAN")
    
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
    
    -- SECTION 3: TOMBOL MANUAL
    Tab:CreateSection("🖱️ MANUAL")
    
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
    
    -- SECTION 4: AUTO BUY
    Tab:CreateSection("🤖 AUTO BUY")
    
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
    
    -- SECTION 5: FITUR TAMBAHAN
    Tab:CreateSection("📋 FITUR TAMBAHAN")
    
    -- Tombol Cek Shop List
    Tab:CreateButton({
        Name = "CheckShop",
        Text = "📋 CEK DAFTAR SHOP",
        Callback = function()
            checkShopList()
        end
    })
    
    -- Tombol Beli Semua Bibit
    Tab:CreateButton({
        Name = "BuyAll",
        Text = "💰 BELI SEMUA BIBIT",
        Callback = function()
            local totalSuccess = 0
            
            for i, seed in ipairs(seedsList) do
                Bdev:Notify({
                    Title = "Membeli",
                    Content = seed.Display,
                    Duration = 1
                })
                
                local success = buySeed(seed.Name, 1)
                if success then
                    totalSuccess = totalSuccess + 1
                end
                
                task.wait(0.5)
            end
            
            Bdev:Notify({
                Title = "Selesai",
                Content = string.format("Berhasil: %d/%d", totalSuccess, #seedsList),
                Duration = 3
            })
        end
    })
    
    -- SECTION 6: INFORMASI
    Tab:CreateSection("ℹ️ INFORMASI")
    
    Tab:CreateLabel({
        Name = "Info1",
        Text = "• Remote: RequestShop",
        Color = Color3.fromRGB(150, 150, 160)
    })
    
    Tab:CreateLabel({
        Name = "Info2",
        Text = "• Format: BUY [nama] [jumlah]",
        Color = Color3.fromRGB(150, 150, 160)
    })
    
    Tab:CreateLabel({
        Name = "Info3",
        Text = "• Delay minimum: 0.5 detik",
        Color = Color3.fromRGB(150, 150, 160)
    })
    
    Tab:CreateLabel({
        Name = "Info4",
        Text = "• Pastikan uang cukup",
        Color = Color3.fromRGB(150, 150, 160)
    })
    
    -- ===== SHARE FUNCTIONS =====
    Shared.Modules = Shared.Modules or {}
    Shared.Modules.ShopAutoBuy = {
        BuySeed = function(seedName, amount)
            return buySeed(seedName, amount or 1)
        end,
        GetShopList = checkShopList,
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