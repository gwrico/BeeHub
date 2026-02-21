-- ==============================================
-- 🛍️ SHOP AUTO-BUY - MUTATION SEEDS
-- ==============================================

local ShopAutoBuy = {}

function ShopAutoBuy.Init(Dependencies)
    local Tab = Dependencies.Tab
    local Shared = Dependencies.Shared
    local Bdev = Dependencies.Bdev
    local GUI = Dependencies.GUI or Shared.GUI
    
    --print("🛍️ Initializing Shop Auto-Buy module...")
    
    -- ===== CONFIGURASI REMOTE =====
    local REMOTE_PATH = "ReplicatedStorage.RemoteEvent.ServerRemoteEvent"
    local FUNCTION_NAME = "Buy_ArrayBool_Item"
    
    -- ===== DAFTAR BIBIT MUTASI =====
    local mutationSeeds = {
        {
            chineseName = "种子-冰霜突变肥料",  -- Ice Mutation
            displayName = "Ice Mutation",
            emoji = "🧊"
        },
        {
            chineseName = "种子-火焰突变肥料",  -- Fire Mutation
            displayName = "Fire Mutation",
            emoji = "🔥"
        },
        {
            chineseName = "种子-毒液突变肥料",  -- Poison Mutation
            displayName = "Poison Mutation",
            emoji = "☠️"
        },
        {
            chineseName = "种子-黑暗突变肥料",  -- Dark Mutation
            displayName = "Dark Mutation",
            emoji = "🌑"
        },
        {
            chineseName = "种子-爆炸突变肥料",  -- Bomb Mutation
            displayName = "Bomb Mutation",
            emoji = "💣"
        }
    }
    
    -- ===== STATE VARIABLES =====
    local selectedSeedIndex = 1
    local autoBuyEnabled = false
    local autoBuyConnection = nil
    local buyDelay = 2
    local buyQuantity = 1
    
    -- ===== FUNGSI UTAMA =====
    local function buySeed(chineseName, quantity)
        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvent")
        if not remote then 
            Bdev:Notify({
                Title = "Error",
                Content = "RemoteEvent not found!",
                Duration = 3
            })
            return false 
        end
        
        local serverRemote = remote:FindFirstChild("ServerRemoteEvent")
        if not serverRemote then 
            Bdev:Notify({
                Title = "Error",
                Content = "ServerRemoteEvent not found!",
                Duration = 3
            })
            return false 
        end
        
        --print("🛒 Buying: " .. chineseName .. " x" .. quantity)
        
        local success, result = pcall(function()
            serverRemote:FireServer(FUNCTION_NAME, chineseName, quantity)
            return true
        end)
        
        if success then
            --print("✅ Purchase successful")
        else
            --print("❌ Purchase failed:", result)
            Bdev:Notify({
                Title = "Purchase Failed",
                Content = tostring(result),
                Duration = 3
            })
        end
        
        return success
    end
    
    -- ===== FUNGSI AUTO-BUY LOOP =====
    local function startAutoBuy()
        if autoBuyConnection then
            autoBuyConnection:Disconnect()
            autoBuyConnection = nil
        end
        
        autoBuyEnabled = true
        local selectedSeed = mutationSeeds[selectedSeedIndex]
        
        Bdev:Notify({
            Title = "Auto-Buy ON",
            Content = "Buying " .. selectedSeed.displayName .. " every " .. buyDelay .. "s",
            Duration = 4
        })
        
        --print("🤖 Auto-Buy STARTED: " .. selectedSeed.displayName)
        
        local lastBuyTime = 0
        autoBuyConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not autoBuyEnabled then return end
            
            if tick() - lastBuyTime >= buyDelay then
                buySeed(selectedSeed.chineseName, buyQuantity)
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
            Title = "Auto-Buy OFF",
            Content = "Auto-buy stopped",
            Duration = 2
        })
        
        --print("⏹️ Auto-Buy STOPPED")
    end
    
    -- ===== UI ELEMENTS =====
    
    -- Header
    Tab:CreateLabel({
        Name = "Header",
        Text = "🌱 MUTATION SEEDS AUTO-BUY",
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- Pilih Seed
    Tab:CreateLabel({
        Name = "SelectLabel",
        Text = "Select Seed for Auto-Buy:",
        Alignment = Enum.TextXAlignment.Left
    })
    
    -- Buat tombol pilihan seed
    local selectionButtons = {}
    for i, seed in ipairs(mutationSeeds) do
        local btn = Tab:CreateButton({
            Name = "Select_" .. i,
            Text = (selectedSeedIndex == i and "✅ " or "   ") .. seed.emoji .. " " .. seed.displayName,
            Callback = function()
                selectedSeedIndex = i
                
                -- Update semua tombol untuk menampilkan selection yang benar
                for j, btn in ipairs(selectionButtons) do
                    if j == i then
                        btn.Text = "✅ " .. mutationSeeds[j].emoji .. " " .. mutationSeeds[j].displayName
                    else
                        btn.Text = "   " .. mutationSeeds[j].emoji .. " " .. mutationSeeds[j].displayName
                    end
                end
                
                Bdev:Notify({
                    Title = "Selection",
                    Content = "Selected: " .. seed.displayName,
                    Duration = 2
                })
                
                --print("📌 Selected: " .. seed.displayName)
            end
        })
        
        table.insert(selectionButtons, btn)
    end
    
    -- Spacer
    Tab:CreateLabel({
        Name = "Spacer1",
        Text = "",
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- Delay Setting
    Tab:CreateSlider({
        Name = "DelaySlider",
        Text = "Delay: " .. buyDelay .. " seconds",
        Range = {0.5, 5},
        Increment = 0.5,
        CurrentValue = buyDelay,
        Callback = function(value)
            buyDelay = value
            --print("⏱️ Delay set to: " .. buyDelay .. "s")
        end
    })
    
    -- Quantity Setting
    Tab:CreateSlider({
        Name = "QtySlider",
        Text = "Quantity per buy: " .. buyQuantity,
        Range = {1, 10},
        Increment = 1,
        CurrentValue = buyQuantity,
        Callback = function(value)
            buyQuantity = math.floor(value)
            --print("📦 Quantity set to: " .. buyQuantity)
        end
    })
    
    -- Spacer
    Tab:CreateLabel({
        Name = "Spacer2",
        Text = "",
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- Auto-Buy Toggle
    local toggleObj = Tab:CreateToggle({
        Name = "AutoBuyToggle",
        Text = "🤖 ENABLE AUTO-BUY",
        CurrentValue = false,
        Callback = function(value)
            if value then
                startAutoBuy()
            else
                stopAutoBuy()
            end
        end
    })
    
    -- Emergency Stop Button
    Tab:CreateButton({
        Name = "EmergencyStop",
        Text = "🛑 EMERGENCY STOP",
        Callback = function()
            if toggleObj and toggleObj.SetValue then
                toggleObj:SetValue(false)
            else
                stopAutoBuy()
            end
            --print("🛑 EMERGENCY STOP activated")
        end
    })
    
    -- Test Buy Button
    Tab:CreateButton({
        Name = "TestBuy",
        Text = "🧪 TEST BUY (Current Selection)",
        Callback = function()
            local selectedSeed = mutationSeeds[selectedSeedIndex]
            Bdev:Notify({
                Title = "Test Purchase",
                Content = "Trying to buy " .. selectedSeed.displayName,
                Duration = 3
            })
            
            local success = buySeed(selectedSeed.chineseName, 1)
            
            if success then
                Bdev:Notify({
                    Title = "Success!",
                    Content = "Bought " .. selectedSeed.displayName,
                    Duration = 3
                })
            end
        end
    })
    
    -- Info section
    Tab:CreateLabel({
        Name = "InfoLabel1",
        Text = "⚠️ IMPORTANT INFORMATION",
        Alignment = Enum.TextXAlignment.Center
    })
    
    Tab:CreateLabel({
        Name = "InfoLabel2",
        Text = "• 10% mutation chance",
        Alignment = Enum.TextXAlignment.Left
    })
    
    Tab:CreateLabel({
        Name = "InfoLabel3",
        Text = "• +0.5kg plant size if failed",
        Alignment = Enum.TextXAlignment.Left
    })
    
    Tab:CreateLabel({
        Name = "InfoLabel4",
        Text = "• Use at your own risk!",
        Alignment = Enum.TextXAlignment.Center
    })
    
    Tab:CreateLabel({
        Name = "InfoLabel5",
        Text = "• Minimum delay: 0.5s",
        Alignment = Enum.TextXAlignment.Left
    })
    
    Tab:CreateLabel({
        Name = "InfoLabel6",
        Text = "• Recommended quantity: 1",
        Alignment = Enum.TextXAlignment.Left
    })
    
    -- Store module reference in Shared
    Shared.Modules.ShopAutoBuy = {
        StartAutoBuy = startAutoBuy,
        StopAutoBuy = stopAutoBuy,
        BuySeed = function(seedIndex, quantity)
            if seedIndex and mutationSeeds[seedIndex] then
                return buySeed(mutationSeeds[seedIndex].chineseName, quantity or 1)
            end
            return false
        end,
        GetStatus = function()
            return {
                Enabled = autoBuyEnabled,
                SelectedSeed = selectedSeedIndex,
                SelectedSeedName = mutationSeeds[selectedSeedIndex].displayName,
                Delay = buyDelay,
                Quantity = buyQuantity
            }
        end
    }
    
    --print("✅ Shop Auto-Buy module ready!")
    --print("🎯 Available mutation seeds: " .. #mutationSeeds)
end

return ShopAutoBuy