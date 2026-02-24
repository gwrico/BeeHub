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
        "🌾 Padi",
        "🌽 Jagung", 
        "🍅 Tomat",
        "🍆 Terong",
        "🍓 Strawberry"
    }
    
    -- Mapping display ke nama asli
    local seedNameMap = {
        ["🌾 Padi"] = "Bibit Padi",
        ["🌽 Jagung"] = "Bibit Jagung",
        ["🍅 Tomat"] = "Bibit Tomat",
        ["🍆 Terong"] = "Bibit Terong",
        ["🍓 Strawberry"] = "Bibit Strawberry"
    }
    
    -- ===== STATE VARIABLES =====
    local selectedSeed = seedNameMap[seedsList[1]]
    local autoBuyEnabled = false
    local autoBuyConnection = nil
    local buyDelay = 2
    local buyQuantity = 1
    
    -- Variable untuk menyimpan references
    local dropdownRef = nil
    local qtySliderRef = nil
    local delaySliderRef = nil
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
        Options = seedsList,
        Default = seedsList[1],
        Callback = function(value)
            selectedSeed = seedNameMap[value]
            Bdev:Notify({
                Title = "Bibit Dipilih",
                Content = value,
                Duration = 1
            })
            
            -- Jika auto buy sedang aktif, restart dengan bibit baru
            if autoBuyEnabled then
                stopAutoBuy()
                startAutoBuy()
            end
        end
    })
    
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
    qtySliderRef = Tab:CreateSlider({
        Name = "QtySlider",
        Text = "Jumlah: " .. buyQuantity,
        Range = {1, 10},
        Increment = 1,
        CurrentValue = 1,
        Callback = function(value)
            buyQuantity = value
            -- Update text slider
            if qtySliderRef and qtySliderRef.Frame then
                local label = qtySliderRef.Frame:FindFirstChild("SliderLabel")
                if label then
                    label.Text = "Jumlah: " .. value
                end
            end
        end
    })
    
    -- Slider Delay
    delaySliderRef = Tab:CreateSlider({
        Name = "DelaySlider",
        Text = "Delay: " .. buyDelay .. " detik",
        Range = {0.5, 5},
        Increment = 0.5,
        CurrentValue = 2,
        Callback = function(value)
            buyDelay = value
            -- Update text slider
            if delaySliderRef and delaySliderRef.Frame then
                local label = delaySliderRef.Frame:FindFirstChild("SliderLabel")
                if label then
                    label.Text = "Delay: " .. value .. " detik"
                end
            end
            
            -- Update auto buy loop jika sedang aktif
            if autoBuyEnabled then
                stopAutoBuy()
                startAutoBuy()
            end
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
    autoBuyToggleRef = Tab:CreateToggle({
        Name = "AutoBuyToggle",
        Text = "AKTIFKAN AUTO BUY",
        CurrentValue = false,
        Callback = function(value)
            if value then
                if not checkRemote() then
                    if autoBuyToggleRef and autoBuyToggleRef.SetValue then
                        autoBuyToggleRef:SetValue(false)
                    end
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
            if autoBuyToggleRef and autoBuyToggleRef.SetValue then
                autoBuyToggleRef:SetValue(false)
            end
        end
    })
    
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
                SelectedSeed = selectedSeed,
                AutoBuyEnabled = autoBuyEnabled,
                Delay = buyDelay,
                Quantity = buyQuantity
            }
        end,
        StopAutoBuy = stopAutoBuy,
        StartAutoBuy = startAutoBuy,
        SetSeed = function(seedDisplay)
            if dropdownRef and dropdownRef.SetValue then
                dropdownRef:SetValue(seedDisplay)
            end
        end,
        SetQuantity = function(value)
            if value >= 1 and value <= 10 then
                buyQuantity = value
                if qtySliderRef and qtySliderRef.SetValue then
                    qtySliderRef:SetValue(value)
                end
            end
        end,
        SetDelay = function(value)
            if value >= 0.5 and value <= 5 then
                buyDelay = value
                if delaySliderRef and delaySliderRef.SetValue then
                    delaySliderRef:SetValue(value)
                end
            end
        end,
        GetDropdownRef = function()
            return dropdownRef
        end
    }
    
    print("✅ Shop module loaded - dengan Dropdown!")
    
    -- Return cleanup function
    return cleanup
end

return ShopAutoBuy