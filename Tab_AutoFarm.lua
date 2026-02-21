-- ==============================================
-- 💰 AUTO FARM TAB MODULE - COMPATIBLE WITH SIMPLEGUI v6.3
-- ==============================================

local AutoFarm = {}

function AutoFarm.Init(Dependencies)
    local Tab = Dependencies.Tab
    local Shared = Dependencies.Shared
    local Bdev = Dependencies.Bdev
    
    local Variables = Shared.Variables or {}
    local EggData = Shared.EggData or {}
    local Functions = Shared.Functions or {}
    
    --print("💰 Initializing AutoFarm tab for SimpleGUI v6.3...")
    
    -- Get services
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local ProximityPromptService = game:GetService("ProximityPromptService")
    
    -- Auto-farm variables
    local collectConnection = nil
    
    -- ===== AUTO COLLECT EGGS =====
    Tab:CreateToggle({
        Name = "AutoCollect",
        Text = "🥚 Auto Collect Eggs",
        CurrentValue = false,
        Callback = function(value)
            Variables.autoCollectEnabled = value
            
            if value then
                Bdev:Notify({
                    Title = "Auto Collect",
                    Content = "Auto collecting enabled!",
                    Duration = 3
                })
                
                --print("✅ Auto Collect enabled")
                
                -- Start collection loop
                if collectConnection then
                    collectConnection:Disconnect()
                end
                
                collectConnection = RunService.Heartbeat:Connect(function()
                    if not Variables.autoCollectEnabled then 
                        return 
                    end
                    
                    local player = Players.LocalPlayer
                    local character = player.Character
                    if not character then return end
                    
                    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                    if not humanoidRootPart then return end
                    
                    local playerPos = humanoidRootPart.Position
                    local closestEgg = nil
                    local closestDistance = 1000
                    
                    -- Find closest egg using Functions if available
                    if Functions.findClosestEgg then
                        local egg, distance = Functions.findClosestEgg(500)
                        if egg and distance < closestDistance then
                            closestEgg = egg
                            closestDistance = distance
                        end
                    else
                        -- Manual search
                        for _, obj in pairs(game.Workspace:GetDescendants()) do
                            if obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("Model") then
                                local objName = obj.Name:lower()
                                
                                for eggName, _ in pairs(EggData) do
                                    if objName:find(eggName:lower(), 1, true) then
                                        local objPos
                                        if obj:IsA("Model") then
                                            local primaryPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                                            objPos = primaryPart and primaryPart.Position or obj:GetPivot().Position
                                        else
                                            objPos = obj.Position
                                        end
                                        
                                        local distance = (playerPos - objPos).Magnitude
                                        if distance < closestDistance and distance < 500 then
                                            closestEgg = obj
                                            closestDistance = distance
                                        end
                                        break
                                    end
                                end
                            end
                        end
                    end
                    
                    -- Teleport to egg if found
                    if closestEgg and closestDistance < 100 then
                        local eggPos
                        if closestEgg:IsA("Model") then
                            local primaryPart = closestEgg.PrimaryPart or closestEgg:FindFirstChildWhichIsA("BasePart")
                            eggPos = primaryPart and primaryPart.Position or closestEgg:GetPivot().Position
                        else
                            eggPos = closestEgg.Position
                        end
                        
                        -- Teleport with Functions or manual
                        if Functions.teleportToPosition then
                            Functions.teleportToPosition(eggPos + Vector3.new(0, 3, 0))
                        else
                            humanoidRootPart.CFrame = CFrame.new(eggPos + Vector3.new(0, 3, 0))
                        end
                        
                        -- Wait a bit
                        task.wait(0.3)
                        
                        -- Try to find and trigger proximity prompt
                        local prompt = closestEgg:FindFirstChildOfClass("ProximityPrompt") or
                                      closestEgg.Parent:FindFirstChildOfClass("ProximityPrompt")
                        
                        if prompt then
                            pcall(function()
                                ProximityPromptService:PromptTriggered(prompt, player)
                            end)
                            
                            -- Wait between collections
                            task.wait(1)
                        end
                    elseif closestEgg and closestDistance >= 100 then
                        -- Egg is too far, move towards it
                        local eggPos
                        if closestEgg:IsA("Model") then
                            local primaryPart = closestEgg.PrimaryPart or closestEgg:FindFirstChildWhichIsA("BasePart")
                            eggPos = primaryPart and primaryPart.Position or closestEgg:GetPivot().Position
                        else
                            eggPos = closestEgg.Position
                        end
                        
                        local direction = (eggPos - playerPos).Unit
                        humanoidRootPart.CFrame = CFrame.new(playerPos + (direction * 50))
                    end
                end)
                
            else
                Bdev:Notify({
                    Title = "Auto Collect",
                    Content = "Auto collecting disabled!",
                    Duration = 3
                })
                
                --print("❌ Auto Collect disabled")
                
                if collectConnection then
                    collectConnection:Disconnect()
                    collectConnection = nil
                end
            end
        end
    })
    
    -- ===== COLLECT NEARBY EGGS =====
    Tab:CreateButton({
        Name = "CollectNearby",
        Text = "🌀 Collect Nearby Eggs",
        Callback = function()
            --print("🌀 Collecting nearby eggs...")
            
            local player = Players.LocalPlayer
            local character = player.Character
            if not character then 
                Bdev:Notify({
                    Title = "Error",
                    Content = "No character found!",
                    Duration = 3
                })
                return 
            end
            
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then return end
            
            local playerPos = humanoidRootPart.Position
            local collected = 0
            local foundEggs = {}
            
            -- Find all nearby eggs
            for _, obj in pairs(game.Workspace:GetDescendants()) do
                if obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("Model") then
                    -- Get position
                    local objPos
                    if obj:IsA("Model") then
                        local primaryPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                        objPos = primaryPart and primaryPart.Position or obj:GetPivot().Position
                    else
                        objPos = obj.Position
                    end
                    
                    local distance = (playerPos - objPos).Magnitude
                    
                    if distance < 200 then
                        for eggName, _ in pairs(EggData) do
                            if obj.Name:lower():find(eggName:lower(), 1, true) then
                                table.insert(foundEggs, {
                                    Object = obj,
                                    Position = objPos,
                                    Name = obj.Name
                                })
                                break
                            end
                        end
                    end
                end
            end
            
            if #foundEggs == 0 then
                Bdev:Notify({
                    Title = "No Eggs",
                    Content = "No eggs found nearby!",
                    Duration = 3
                })
                return
            end
            
            -- Sort by distance
            table.sort(foundEggs, function(a, b)
                local distA = (playerPos - a.Position).Magnitude
                local distB = (playerPos - b.Position).Magnitude
                return distA < distB
            end)
            
            -- Collect eggs
            for _, eggInfo in ipairs(foundEggs) do
                if collected >= 10 then break end  -- Limit collection
                
                -- Teleport to egg
                if Functions.teleportToPosition then
                    Functions.teleportToPosition(eggInfo.Position + Vector3.new(0, 3, 0))
                else
                    humanoidRootPart.CFrame = CFrame.new(eggInfo.Position + Vector3.new(0, 3, 0))
                end
                
                task.wait(0.2)
                
                -- Try to collect
                local prompt = eggInfo.Object:FindFirstChildOfClass("ProximityPrompt") or
                              eggInfo.Object.Parent:FindFirstChildOfClass("ProximityPrompt")
                
                if prompt then
                    pcall(function()
                        ProximityPromptService:PromptTriggered(prompt, player)
                    end)
                    collected = collected + 1
                    --print("✅ Collected:", eggInfo.Name)
                    task.wait(0.5)
                end
            end
            
            Bdev:Notify({
                Title = "Collection Complete",
                Content = "Collected " .. collected .. " eggs!",
                Duration = 5
            })
            
            --print("🎉 Total collected:", collected, "eggs")
        end
    })
    
    -- ===== AUTO HATCH EGGS =====
    local autoHatchConnection = nil
    
    Tab:CreateToggle({
        Name = "AutoHatch",
        Text = "🐣 Auto Hatch Eggs",
        CurrentValue = false,
        Callback = function(value)
            Variables.autoHatchEnabled = value
            
            if value then
                Bdev:Notify({
                    Title = "Auto Hatch",
                    Content = "Auto hatch enabled!",
                    Duration = 3
                })
                
                --print("✅ Auto Hatch enabled")
                
                if autoHatchConnection then
                    autoHatchConnection:Disconnect()
                end
                
                autoHatchConnection = RunService.Heartbeat:Connect(function()
                    if not Variables.autoHatchEnabled then return end
                    
                    local player = Players.LocalPlayer
                    
                    -- Try to find hatch-related prompts
                    for _, prompt in pairs(ProximityPromptService:GetPrompts()) do
                        if prompt and prompt:IsA("ProximityPrompt") then
                            local promptName = prompt.Name:lower()
                            local parentName = prompt.Parent and prompt.Parent.Name:lower() or ""
                            
                            -- Check if it's a hatch-related prompt
                            if promptName:find("hatch") or promptName:find("open") or 
                               parentName:find("hatch") or parentName:find("egg") then
                                
                                pcall(function()
                                    ProximityPromptService:PromptTriggered(prompt, player)
                                end)
                                
                                task.wait(1)  -- Wait between hatches
                                break
                            end
                        end
                    end
                end)
                
            else
                Bdev:Notify({
                    Title = "Auto Hatch",
                    Content = "Auto hatch disabled!",
                    Duration = 3
                })
                
                --print("❌ Auto Hatch disabled")
                
                if autoHatchConnection then
                    autoHatchConnection:Disconnect()
                    autoHatchConnection = nil
                end
            end
        end
    })
    
    -- ===== FARMING SETTINGS =====
    Tab:CreateLabel({
        Name = "SettingsLabel",
        Text = "⚙️ Farming Settings:",
        Alignment = Enum.TextXAlignment.Center
    })
    
    local collectRange = 200
    local collectSpeed = 1.0
    
    local rangeSlider = Tab:CreateSlider({
        Name = "CollectRange",
        Text = "Range: " .. collectRange .. " studs",
        Range = {50, 1000},
        Increment = 10,
        CurrentValue = 200,
        Callback = function(value)
            collectRange = value
            --print("📊 Collection range set to:", value)
        end
    })
    
    local speedSlider = Tab:CreateSlider({
        Name = "CollectSpeed",
        Text = "Speed: " .. collectSpeed .. "x",
        Range = {0.5, 3.0},
        Increment = 0.1,
        CurrentValue = 1.0,
        Callback = function(value)
            collectSpeed = value
            --print("📊 Collection speed set to:", value)
        end
    })
    
    -- ===== DISABLE ALL FARMING =====
    Tab:CreateButton({
        Name = "DisableFarming",
        Text = "🔴 Disable All Farming",
        Callback = function()
            --print("\n🔴 DISABLING ALL FARMING...")
            
            -- Disable all toggles
            Variables.autoCollectEnabled = false
            Variables.autoHatchEnabled = false
            
            -- Disconnect connections
            if collectConnection then
                collectConnection:Disconnect()
                collectConnection = nil
            end
            
            if autoHatchConnection then
                autoHatchConnection:Disconnect()
                autoHatchConnection = nil
            end
            
            Bdev:Notify({
                Title = "Farming",
                Content = "All farming features disabled!",
                Duration = 4
            })
            
            --print("✅ All farming disabled")
        end
    })
    
    --print("✅ AutoFarm tab initialized for SimpleGUI v6.3")
end

return AutoFarm