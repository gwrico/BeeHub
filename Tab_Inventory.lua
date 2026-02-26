-- ==============================================
-- 💰 AUTO SELL - INVENTORY MODULE
-- ==============================================

local AutoSell = {}

function AutoSell.Init(Dependencies)
    local Tab = Dependencies.Tab
    local Shared = Dependencies.Shared
    local Bdev = Dependencies.Bdev
    local GUI = Dependencies.GUI
    
    local Variables = Shared.Variables or {}
    
    -- Get services
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    
    -- Dapatkan remote RequestSell
    local RequestSell = ReplicatedStorage:FindFirstChild("Remotes")
    if RequestSell then
        RequestSell = RequestSell:FindFirstChild("TutorialRemotes")
        if RequestSell then
            RequestSell = RequestSell:FindFirstChild("RequestSell")
        end
    end
    
    -- Daftar tanaman
    local crops = {
        {Display = "🌾 Padi", Name = "Padi"},
        {Display = "🌽 Jagung", Name = "Jagung"},
        {Display = "🍅 Tomat", Name = "Tomat"},
        {Display = "🍆 Terong", Name = "Terong"},
        {Display = "🍓 Strawberry", Name = "Strawberry"},
        {Display = "None", Name = "None"},
    }
    
    local cropOptions = {}
    for i, crop in ipairs(crops) do
        cropOptions[i] = crop.Display
    end
    
    -- Variables
    local selectedCrop = crops[1].Name
    local sellAmount = 1
    local isActive = false
    local sellConnection = nil
    
    -- Fungsi jual
    local function sell()
        if not RequestSell then 
            Bdev:Notify({
                Title = "Error",
                Content = "❌ Remote RequestSell tidak ditemukan!",
                Duration = 3
            })
            return false
        end
        
        local arguments = {
            [1] = "SELL",
            [2] = selectedCrop,
            [3] = sellAmount
        }
        
        local success, result = pcall(function()
            return RequestSell:InvokeServer(unpack(arguments))
        end)
        
        if success then
            return true
        else
            return false
        end
    end
    
    -- ===== UI =====
    Tab:CreateLabel({
        Name = "Title",
        Text = "───── 💰 AUTO SELL ─────",
        Color = Color3.fromRGB(255, 185, 0),
        Bold = true,
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- Dropdown pilih tanaman
    local cropDropdown = Tab:CreateDropdown({
        Name = "CropDropdown",
        Text = "Pilih Tanaman:",
        Options = cropOptions,
        Default = cropOptions[1],
        Callback = function(value)
            for i, crop in ipairs(crops) do
                if crop.Display == value then
                    selectedCrop = crop.Name
                    break
                end
            end
            Bdev:Notify({
                Title = "Dipilih",
                Content = selectedCrop,
                Duration = 1
            })
        end
    })
    
    -- Input jumlah
    Tab:CreateLabel({
        Name = "AmountLabel",
        Text = "Jumlah:",
        Alignment = Enum.TextXAlignment.Left
    })
    
    local amountInput = Instance.new("TextBox")
    amountInput.Name = "AmountInput"
    amountInput.Size = UDim2.new(0.95, 0, 0, 36)
    amountInput.Position = UDim2.new(0, 0, 0, 0)
    amountInput.Text = "1"
    amountInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    amountInput.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    amountInput.BackgroundTransparency = 0
    amountInput.TextSize = 14
    amountInput.Font = Enum.Font.Gotham
    amountInput.ClearTextOnFocus = false
    amountInput.LayoutOrder = #Tab.Elements + 1
    amountInput.Parent = Tab.Content
    
    local amountCorner = Instance.new("UICorner")
    amountCorner.CornerRadius = UDim.new(0, 6)
    amountCorner.Parent = amountInput
    
    amountInput.FocusLost:Connect(function()
        local value = tonumber(amountInput.Text)
        if value and value >= 1 then
            sellAmount = math.floor(value)
            amountInput.Text = tostring(sellAmount)
        else
            sellAmount = 1
            amountInput.Text = "1"
        end
    end)
    
    -- Status counter
    local statusLabel = Tab:CreateLabel({
        Name = "Status",
        Text = "⚪ SIAP",
        Color = Color3.fromRGB(150, 150, 160),
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- Tombol SELL MANUAL
    Tab:CreateButton({
        Name = "ManualSell",
        Text = "💰 SELL MANUAL",
        Callback = function()
            statusLabel.Text = "🟡 MENJUAL..."
            statusLabel.TextColor3 = Color3.fromRGB(255, 185, 0)
            
            local success = sell()
            
            if success then
                statusLabel.Text = "✅ BERHASIL"
                statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                Bdev:Notify({
                    Title = "Success",
                    Content = string.format("Menjual %d %s", sellAmount, selectedCrop),
                    Duration = 2
                })
            else
                statusLabel.Text = "❌ GAGAL"
                statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                Bdev:Notify({
                    Title = "Error",
                    Content = "Gagal menjual",
                    Duration = 2
                })
            end
            
            task.wait(1)
            statusLabel.Text = "⚪ SIAP"
            statusLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
        end
    })
    
    -- Tombol AUTO SELL
    Tab:CreateToggle({
        Name = "AutoSell",
        Text = "🤖 AUTO SELL (2 detik)",
        CurrentValue = false,
        Callback = function(val)
            isActive = val
            
            if val then
                statusLabel.Text = "🟢 AUTO ON"
                statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                
                if sellConnection then sellConnection:Disconnect() end
                
                sellConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    if not isActive then return end
                    
                    sell()
                    task.wait(2)
                end)
                
            else
                statusLabel.Text = "⚪ SIAP"
                statusLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
                
                if sellConnection then
                    sellConnection:Disconnect()
                    sellConnection = nil
                end
            end
        end
    })
    
    -- Tombol STOP
    Tab:CreateButton({
        Name = "StopSell",
        Text = "⏹️ STOP SELL",
        Callback = function()
            isActive = false
            if sellConnection then
                sellConnection:Disconnect()
                sellConnection = nil
            end
            statusLabel.Text = "⏹️ STOPPED"
            statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            task.wait(1)
            statusLabel.Text = "⚪ SIAP"
            statusLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
        end
    })
end

return AutoSell