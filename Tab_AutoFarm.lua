-- ==============================================
-- 💰 AUTO FARM TAB MODULE (CLEAN NO-WARNINGS VERSION)
-- ==============================================

local AutoFarm = {}

function AutoFarm.Init(Dependencies)
    local Tab = Dependencies.Tab
    local Shared = Dependencies.Shared
    local Rayfield = Dependencies.Rayfield
    
    local Variables = Shared.Variables or {}
    local EggData = Shared.EggData or {}
    
    print("💰 Initializing AutoFarm tab...")
    
    -- Get services
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local ProximityPromptService = game:GetService("ProximityPromptService")
    
    -- Helper function to trigger prompt (NO fireproximityprompt)
    local function triggerPrompt(prompt, player)
        if not prompt or not prompt:IsA("ProximityPrompt") then
            return false
        end
        
        local playerObj = player or Players.LocalPlayer
        
        -- Try ProximityPromptService method
        local success, err = pcall(function()
            ProximityPromptService:PromptTriggered(prompt, playerObj)
        end)
        
        if success then
            return true
        end
        
        -- Alternative: Simulate click
        success, err = pcall(function()
            -- Activate the prompt
            prompt:InputHoldBegin()
            task.wait(0.1)
            prompt:InputHoldEnd()
        end)
        
        return success
    end
    
    -- ===== AUTO COLLECT EGGS =====
    local collectConnection = nil
    Tab:CreateToggle({
        Name = "AutoCollect",
        Text = "🥚 Auto Collect Eggs",
        CurrentValue = false,
        Callback = function(value)
            Variables.autoCollectEnabled = value
            
            if value then
                Rayfield.Notify({
                    Title = "Auto Collect",
                    Content = "Auto collecting enabled!",
                    Duration = 3
                })
                
                print("✅ Auto Collect enabled")
                
                -- Start collection loop
                collectConnection = RunService.Heartbeat:Connect(function()
                    if not Variables.autoCollectEnabled then 
                        if collectConnection then
                            collectConnection:Disconnect()
                            collectConnection = nil
                        end
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
                    
                    -- Find closest egg
                    for _, obj in pairs(game.Workspace:GetDescendants()) do
                        if obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("Model") then
                            local objName = obj.Name:lower()
                            
                            for eggName, _ in pairs(EggData) do
                                if objName:find(eggName:lower(), 1, true) then
                                    -- Get object position
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
                    
                    -- Teleport to egg and collect
                    if closestEgg then
                        -- Get egg position
                        local eggPos
                        if closestEgg:IsA("Model") then
                            local primaryPart = closestEgg.PrimaryPart or closestEgg:FindFirstChildWhichIsA("BasePart")
                            eggPos = primaryPart and primaryPart.Position or closestEgg:GetPivot().Position
                        else
                            eggPos = closestEgg.Position
                        end
                        
                        -- Teleport
                        humanoidRootPart.CFrame = CFrame.new(eggPos + Vector3.new(0, 5, 0))
                        task.wait(0.2)
                        
                        -- Find and trigger prompt
                        local prompt = closestEgg:FindFirstChildOfClass("ProximityPrompt") or
                                      closestEgg.Parent:FindFirstChildOfClass("ProximityPrompt")
                        
                        if prompt then
                            triggerPrompt(prompt, player)
                            print("📦 Collected:", closestEgg.Name, "| Distance:", math.floor(closestDistance))
                        end
                        
                        task.wait(0.5)
                    end
                end)
                
            else
                Rayfield.Notify({
                    Title = "Auto Collect",
                    Content = "Auto collecting disabled!",
                    Duration = 3
                })
                
                print("❌ Auto Collect disabled")
                
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
            print("🌀 Collecting nearby eggs...")
            
            local player = Players.LocalPlayer
            local character = player.Character
            if not character then 
                Rayfield.Notify({
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
                                -- Teleport
                                humanoidRootPart.CFrame = CFrame.new(objPos + Vector3.new(0, 5, 0))
                                task.wait(0.1)
                                
                                -- Find prompt
                                local prompt = obj:FindFirstChildOfClass("ProximityPrompt") or
                                              obj.Parent:FindFirstChildOfClass("ProximityPrompt")
                                
                                if prompt then
                                    triggerPrompt(prompt, player)
                                    collected = collected + 1
                                    print("✅ Collected:", obj.Name)
                                    task.wait(0.2)
                                end
                                break
                            end
                        end
                    end
                end
            end
            
            Rayfield.Notify({
                Title = "Collection Complete",
                Content = "Collected " .. collected .. " eggs nearby!",
                Duration = 5
            })
            
            print("🎉 Total collected:", collected, "eggs")
        end
    })
    
    -- ===== FAST MOVE =====
    Tab:CreateToggle({
        Name = "FastMove",
        Text = "⚡ Fast Move (Speed 50)",
        CurrentValue = false,
        Callback = function(value)
            Variables.fastMoveEnabled = value
            
            local player = Players.LocalPlayer
            local character = player.Character
            
            if value then
                Rayfield.Notify({
                    Title = "Fast Move",
                    Content = "Fast move enabled!",
                    Duration = 3
                })
                
                print("✅ Fast Move enabled")
                
                -- Set speed
                if character then
                    local humanoid = character:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid.WalkSpeed = 50
                    end
                end
                
            else
                Rayfield.Notify({
                    Title = "Fast Move",
                    Content = "Fast move disabled!",
                    Duration = 3
                })
                
                print("❌ Fast Move disabled")
                
                -- Reset speed
                if character then
                    local humanoid = character:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid.WalkSpeed = 16
                    end
                end
            end
        end
    })
    
    print("✅ AutoFarm tab initialized successfully")
end

return AutoFarm