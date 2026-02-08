-- ==============================================
-- 💰 AUTO FARM TAB MODULE
-- ==============================================

local AutoFarm = {}

function AutoFarm.Init(Dependencies)
    local Tab = Dependencies.Tab
    local Shared = Dependencies.Shared
    local Rayfield = Dependencies.Rayfield
    
    local Functions = Shared.Functions
    local Variables = Shared.Variables
    
    print("💰 Initializing AutoFarm tab...")
    
    -- ===== AUTO MINE TOGGLE =====
    Tab:CreateToggle({
        Name = "AutoMine",
        Text = "⛏️ Hold-to-Mine",
        CurrentValue = false,
        Callback = function(value)
            Variables.autoMineEnabled = value
            
            if value then
                Rayfield.Notify({
                    Title = "Hold-to-Mine",
                    Content = "Click and hold to auto mine!",
                    Duration = 3
                })
                
                print("✅ Hold-to-Mine activated")
                
                local isMining = false
                local mouse = game.Players.LocalPlayer:GetMouse()
                
                -- Mouse button down
                mouse.Button1Down:Connect(function()
                    if not Variables.autoMineEnabled then return end
                    
                    isMining = true
                    print("🖱️ Mining started")
                    
                    -- Clear existing connection
                    Variables.mineConnection = Shared.Functions.safeDisconnect(Variables.mineConnection)
                    
                    -- Start mining loop
                    Variables.mineConnection = Shared.Services.RunService.Heartbeat:Connect(function()
                        if not Variables.autoMineEnabled or not isMining then 
                            Variables.mineConnection = Shared.Functions.safeDisconnect(Variables.mineConnection)
                            return 
                        end
                        
                        local closestOre, distance = Functions.findClosestOre(100)
                        
                        if closestOre then
                            -- Auto equip tool
                            if not Variables.toolEquipped then
                                Functions.autoEquipTool()
                            end
                            
                            -- Teleport to ore
                            Functions.teleportToPosition(closestOre.Position + Vector3.new(0, 3, 0))
                            
                            -- Punch
                            Functions.performPunch()
                            
                            -- Touch ore
                            local char = game.Players.LocalPlayer.Character
                            if char then
                                local hrp = char:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    firetouchinterest(hrp, closestOre, 0)
                                    task.wait(0.05)
                                    firetouchinterest(hrp, closestOre, 1)
                                end
                            end
                            
                            task.wait(0.3)
                        else
                            Functions.performPunch()
                            task.wait(0.5)
                        end
                    end)
                end)
                
                -- Mouse button up
                mouse.Button1Up:Connect(function()
                    isMining = false
                    Variables.mineConnection = Shared.Functions.safeDisconnect(Variables.mineConnection)
                    print("🖱️ Mining stopped")
                end)
                
            else
                Rayfield.Notify({
                    Title = "Hold-to-Mine",
                    Content = "Hold-to-Mine disabled",
                    Duration = 3
                })
                
                print("❌ Hold-to-Mine disabled")
                Variables.mineConnection = Shared.Functions.safeDisconnect(Variables.mineConnection)
            end
        end
    })
    
    -- ===== AUTO PUNCH TOGGLE =====
    Tab:CreateToggle({
        Name = "AutoPunch",
        Text = "👊 Auto Punch/Swing",
        CurrentValue = false,
        Callback = function(value)
            Variables.autoPunchEnabled = value
            
            if value then
                Rayfield.Notify({
                    Title = "Auto Punch",
                    Content = "Auto punching enabled!",
                    Duration = 3
                })
                
                print("✅ Auto Punch enabled")
                
                -- Auto equip tool
                if not Functions.checkToolEquipped() then
                    Functions.autoEquipTool()
                end
                
                -- Start punch loop
                Variables.punchConnection = Shared.Functions.safeDisconnect(Variables.punchConnection)
                Variables.punchConnection = Shared.Services.RunService.Heartbeat:Connect(function()
                    if not Variables.autoPunchEnabled then 
                        Variables.punchConnection = Shared.Functions.safeDisconnect(Variables.punchConnection)
                        return 
                    end
                    
                    Functions.performPunch()
                    task.wait(0.2)
                end)
                
            else
                Rayfield.Notify({
                    Title = "Auto Punch",
                    Content = "Auto punching disabled!",
                    Duration = 3
                })
                
                print("❌ Auto Punch disabled")
                Variables.punchConnection = Shared.Functions.safeDisconnect(Variables.punchConnection)
            end
        end
    })
    
    -- ===== EQUIP BEST TOOL =====
    Tab:CreateButton({
        Name = "EquipBestTool",
        Text = "🛠️ Equip Best Tool",
        Callback = function()
            local player = game.Players.LocalPlayer
            local character = player.Character
            if not character then return end
            
            local humanoid = character:FindFirstChild("Humanoid")
            if not humanoid then return end
            
            local bestTool = nil
            local bestValue = 0
            
            for _, tool in pairs(player.Backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    local toolName = tool.Name:lower()
                    local value = 0
                    
                    if toolName:find("rainbow") or toolName:find("diamond") then
                        value = 100
                    elseif toolName:find("gold") or toolName:find("emerald") then
                        value = 80
                    elseif toolName:find("iron") or toolName:find("silver") then
                        value = 60
                    elseif toolName:find("bronze") or toolName:find("stone") then
                        value = 40
                    elseif toolName:find("pick") or toolName:find("axe") or toolName:find("hammer") then
                        value = 30
                    else
                        value = 10
                    end
                    
                    if tool:FindFirstChild("Handle") then
                        value = value + 20
                    end
                    
                    if value > bestValue then
                        bestTool = tool
                        bestValue = value
                    end
                end
            end
            
            if bestTool then
                humanoid:EquipTool(bestTool)
                Variables.toolEquipped = true
                print("🛠️ Equipped best tool:", bestTool.Name)
                Rayfield.Notify({
                    Title = "Tool Equipped",
                    Content = "Equipped: " .. bestTool.Name,
                    Duration = 3
                })
            else
                Rayfield.Notify({
                    Title = "Error",
                    Content = "No tools found in backpack!",
                    Duration = 3
                })
            end
        end
    })
    
    -- ===== TP TO BEST ORE =====
    Tab:CreateButton({
        Name = "TPBestOre",
        Text = "📍 TP to Best Ore",
        Callback = function()
            local player = game.Players.LocalPlayer
            local character = player.Character
            if not character then return end
            
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then return end
            
            local playerPos = humanoidRootPart.Position
            local bestOre = nil
            local bestValue = 0
            local bestDistance = math.huge
            
            for _, obj in pairs(Shared.Services.Workspace:GetChildren()) do
                if obj:IsA("BasePart") then
                    local distance = (playerPos - obj.Position).Magnitude
                    if distance < 200 then
                        for oreName, oreData in pairs(Shared.OreData) do
                            if obj.Name:find(oreName) then
                                local score = oreData.value / (distance + 1)
                                if score > bestValue then
                                    bestOre = obj
                                    bestValue = score
                                    bestDistance = distance
                                end
                            end
                        end
                    end
                end
            end
            
            if bestOre then
                Functions.teleportToPosition(bestOre.Position + Vector3.new(0, 5, 0))
                
                task.wait(0.5)
                if not Variables.toolEquipped then
                    Functions.autoEquipTool()
                end
                
                print("📍 Teleported to:", bestOre.Name, "Distance:", math.floor(bestDistance))
                Rayfield.Notify({
                    Title = "Teleport",
                    Content = "Teleported to " .. bestOre.Name .. "!",
                    Duration = 3
                })
            else
                Rayfield.Notify({
                    Title = "Error",
                    Content = "No ores found nearby!",
                    Duration = 3
                })
            end
        end
    })
    
    -- ===== COLLECT NEARBY ORES =====
    Tab:CreateButton({
        Name = "CollectNearby",
        Text = "💰 Collect Nearby",
        Callback = function()
            local player = game.Players.LocalPlayer
            local character = player.Character
            if not character then return end
            
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then return end
            
            local playerPos = humanoidRootPart.Position
            local collected = 0
            
            -- Auto equip tool
            if not Variables.toolEquipped then
                Functions.autoEquipTool()
            end
            
            for _, obj in pairs(Shared.Services.Workspace:GetChildren()) do
                if obj:IsA("BasePart") then
                    local distance = (playerPos - obj.Position).Magnitude
                    if distance < 50 then
                        for oreName, _ in pairs(Shared.OreData) do
                            if obj.Name:find(oreName) then
                                Functions.teleportToPosition(obj.Position + Vector3.new(0, 3, 0))
                                task.wait(0.2)
                                
                                Functions.performPunch()
                                
                                firetouchinterest(humanoidRootPart, obj, 0)
                                task.wait(0.1)
                                firetouchinterest(humanoidRootPart, obj, 1)
                                
                                collected = collected + 1
                                task.wait(0.3)
                                break
                            end
                        end
                    end
                end
            end
            
            print("💰 Collected", collected, "ores")
            Rayfield.Notify({
                Title = "Collection",
                Content = "Collected " .. collected .. " ores!",
                Duration = 4
            })
        end
    })
    
    print("✅ AutoFarm tab initialized")
end

return AutoFarm
