-- ==============================================
-- 🛒 SHOP MODULE - BELI BIBIT BIASA
-- ==============================================

local ShopAutoBuy = {}

function ShopAutoBuy.Init(Dependencies)
    local Tab = Dependencies.Tab
    local Shared = Dependencies.Shared
    local Bdev = Dependencies.Bdev
    local GUI = Dependencies.GUI or Shared.GUI
    
    -- ===== KONFIGURASI REMOTE =====
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    
    -- Remote RequestShop
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
    local selectedDisplay = seedsList[1].Display
    local autoBuyEnabled = false
    local autoBuyConnection = nil
    local buyDelay = 2
    local buyQuantity = 1
    
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
        
        -- Ini adalah format dari script Anda
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
                Title = "✅ Pembelian Berhasil",
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
    
    -- ===== FUNGSI CEK SHOP =====
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
    
    -- ===== UI ELEMENTS =====
    
    -- Header
    Tab:CreateLabel({
        Name = "Header",
        Text = "🌱 SHOP - BIBIT BIASA",
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- Pilih Bibit
    Tab:CreateLabel({
        Name = "SelectLabel",
        Text = "Pilih Bibit:",
        Alignment = Enum.TextXAlignment.Left
    })
    
    -- Dropdown untuk memilih bibit
    local seedOptions = {}
    for i, seed in ipairs(seedsList) do
        table.insert(seedOptions, seed.Display)
    end
    
    Tab:CreateDropdown({
        Name = "SeedSelector",
        Text = "🌱 Pilih Jenis Bibit",
        List = seedOptions,
        Callback = function(selectedDisplay)
            for i, seed in ipairs(seedsList) do
                if seed.Display == selectedDisplay then
                    selectedSeed = seed.Name
                    selectedDisplay = seed.Display
                    Bdev:Notify({
                        Title = "Dipilih",
                        Content = selectedDisplay,
                        Duration = 1
                    })
                    break
                end
            end
        end
    })
    
    -- Separator
    Tab:CreateLabel({
        Name = "Spacer1",
        Text = "",
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- Pengaturan Jumlah
    Tab:CreateSlider({
        Name = "QtySlider",
        Text = "🔢 Jumlah: " .. buyQuantity,
        Min = 1,
        Max = 10,
        Default = 1,
        Callback = function(value)
            buyQuantity = math.floor(value)
        end
    })
    
    -- Pengaturan Delay
    Tab:CreateSlider({
        Name = "DelaySlider",
        Text = "⏱️ Delay: " .. buyDelay .. " detik",
        Min = 0.5,
        Max = 5,
        Default = 2,
        Increment = 0.5,
        Callback = function(value)
            buyDelay = value
        end
    })
    
    -- Separator
    Tab:CreateLabel({
        Name = "Spacer2",
        Text = "",
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
    
    -- Tombol Test (Beli 1)
    Tab:CreateButton({
        Name = "TestBuy",
        Text = "🧪 TEST BELI (1x)",
        Callback = function()
            buySeed(selectedSeed, 1)
        end
    })
    
    -- Separator
    Tab:CreateLabel({
        Name = "Spacer3",
        Text = "",
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- ===== AUTO BUY =====
    local autoBuyToggle = Tab:CreateToggle({
        Name = "AutoBuyToggle",
        Text = "🤖 AUTO BUY",
        CurrentValue = false,
        Callback = function(value)
            autoBuyEnabled = value
            
            if value then
                if not checkRemote() then
                    autoBuyToggle:SetValue(false)
                    return
                end
                
                Bdev:Notify({
                    Title = "Auto Buy ON",
                    Content = string.format("Membeli %s setiap %ds", selectedDisplay, buyDelay),
                    Duration = 3
                })
                
                if autoBuyConnection then
                    autoBuyConnection:Disconnect()
                end
                
                local lastBuyTime = 0
                autoBuyConnection = RunService.Heartbeat:Connect(function()
                    if not autoBuyEnabled then return end
                    
                    if tick() - lastBuyTime >= buyDelay then
                        buySeed(selectedSeed, buyQuantity)
                        lastBuyTime = tick()
                    end
                end)
                
            else
                Bdev:Notify({
                    Title = "Auto Buy OFF",
                    Content = "Dihentikan",
                    Duration = 2
                })
                
                if autoBuyConnection then
                    autoBuyConnection:Disconnect()
                    autoBuyConnection = nil
                end
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
    
    -- Separator
    Tab:CreateLabel({
        Name = "Spacer4",
        Text = "",
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- Tombol Cek Shop
    Tab:CreateButton({
        Name = "CheckShop",
        Text = "📋 CEK DAFTAR SHOP",
        Callback = function()
            checkShopList()
        end
    })
    
    -- Tombol Beli Semua (Masing-masing 1)
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
                
                task.wait(0.5) -- Jeda antar pembelian
            end
            
            Bdev:Notify({
                Title = "Selesai",
                Content = string.format("Berhasil: %d/%d", totalSuccess, #seedsList),
                Duration = 3
            })
        end
    })
    
    -- Info
    Tab:CreateLabel({
        Name = "InfoHeader",
        Text = "ℹ️ INFORMASI",
        Alignment = Enum.TextXAlignment.Center
    })
    
    Tab:CreateLabel({
        Name = "Info1",
        Text = "• Gunakan 'GET_LIST' untuk cek shop",
        Alignment = Enum.TextXAlignment.Left
    })
    
    Tab:CreateLabel({
        Name = "Info2",
        Text = "• Delay minimum: 0.5 detik",
        Alignment = Enum.TextXAlignment.Left
    })
    
    Tab:CreateLabel({
        Name = "Info3",
        Text = "• Pastikan uang cukup",
        Alignment = Enum.TextXAlignment.Left
    })
    
    -- ===== EXPOSE FUNCTIONS =====
    Shared.Modules.ShopAutoBuy = {
        BuySeed = function(seedName, amount)
            return buySeed(seedName, amount or 1)
        end,
        GetShopList = checkShopList,
        GetStatus = function()
            return {
                SelectedSeed = selectedSeed,
                SelectedDisplay = selectedDisplay,
                AutoBuyEnabled = autoBuyEnabled,
                Delay = buyDelay,
                Quantity = buyQuantity
            }
        end
    }
    
    print("✅ Shop module loaded - Bibit biasa")
end

return ShopAutoBuy