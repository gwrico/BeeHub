-- ==============================================
-- 💰 AUTO FARM TAB MODULE (PET GAME VERSION)
-- ==============================================

local AutoFarm = {}

function AutoFarm.Init(Dependencies)
    local Tab = Dependencies.Tab
    local Shared = Dependencies.Shared
    local Rayfield = Dependencies.Rayfield
    
    local Variables = Shared.Variables
    local Functions = Shared.Functions or {}
    
    print("💰 Initializing AutoFarm tab (Pets Edition)...")
    
    -- ===== AUTO COLLECT EGGS (GANTI DARI AUTO MINE) =====
    Tab:CreateToggle({
        Name = "AutoCollect",
        Text = "🥚 Auto Collect Eggs",
        CurrentValue = false,
        Callback = function(value)
            Variables.autoCollectEnabled = value
            
            if value then
                Rayfield.Notify({
                    Title = "Auto Collect",
                    Content = "Auto collecting eggs enabled!",
                    Duration = 3
                })
                
                print("✅ Auto Collect enabled")
                
                -- Start auto collect loop
                spawn(function()
                    while Variables.autoCollectEnabled do
                        -- Cari egg terdekat
                        local closestEgg = nil
                        local closestDistance = math.huge
                        local player = game.Players.LocalPlayer
                        local character = player.Character
                        
                        if character then
                            local root = character:FindFirstChild("HumanoidRootPart")
                            if root then
                                local playerPos = root.Position
                                
                                -- Cari semua eggs
                                for _, obj in pairs(Shared.Services.Workspace:GetDescendants()) do
                                    if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                                        for eggName, _ in pairs(Shared.EggData) do
                                            if obj.Name:lower():find(eggName:lower(), 1, true) then
                                                local distance = (playerPos - obj.Position).Magnitude
                                                if distance < closestDistance and distance < 50 then
                                                    closestEgg = obj
                                                    closestDistance = distance
                                                end
                                                break
                                            end
                                        end
                                    end
                                end
                                
                                -- Jika ketemu egg, collect
                                if closestEgg then
                                    print("🎯 Found egg:", closestEgg.Name, "Distance:", math.floor(closestDistance))
                                    
                                    -- Teleport ke egg
                                    if Functions.teleportToPosition then
                                        Functions.teleportToPosition(closestEgg.Position + Vector3.new(0, 3, 0))
                                    end
                                    
                                    -- Cari ProximityPrompt untuk collect
                                    task.wait(0.5)
                                    local prompt = closestEgg:FindFirstChildOfClass("ProximityPrompt") or
                                                  closestEgg.Parent:FindFirstChildOfClass("ProximityPrompt")
                                    
                                    if prompt then
                                        fireproximityprompt(prompt)
                                        print("📦 Collected:", closestEgg.Name)
                                    end
                                end
                            end
                        end
                        
                        task.wait(1) -- Delay antar pencarian
                    end
                end)
                
            else
                Rayfield.Notify({
                    Title = "Auto Collect",
                    Content = "Auto collecting disabled!",
                    Duration = 3
                })
                
                print("❌ Auto Collect disabled")
            end
        end
    })
    
    -- ===== AUTO HATCH EGGS (TAMBAHAN) =====
    Tab:CreateToggle({
        Name = "AutoHatch",
        Text = "🐣 Auto Hatch Eggs",
        CurrentValue = false,
        Callback = function(value)
            Variables.autoHatchEnabled = value
            
            if value then
                Rayfield.Notify({
                    Title = "Auto Hatch",
                    Content = "Auto hatching enabled!",
                    Duration = 3
                })
                
                print("✅ Auto Hatch enabled")
                
                -- Hatching logic bisa ditambahkan nanti
                -- Bergantung pada UI game untuk hatching
                
            else
                Rayfield.Notify({
                    Title = "Auto Hatch",
                    Content = "Auto hatching disabled!",
                    Duration = 3
                })
                
                print("❌ Auto Hatch disabled")
            end
        end
    })
    
    -- ===== AUTO PUNCH (MASIH BISA DIPAKAI UNTUK BREAK OBJECT) =====
    Tab:CreateToggle({
        Name = "AutoPunch",
        Text = "👊 Auto Punch",
        CurrentValue = false,
        Callback = function(value)
            Variables.autoPunchEnabled = value
            
            if value then
                Rayfield.Notify({
                    Title = "Auto Punch",
                    Content = "Auto punch enabled!",
                    Duration = 3
                })
                
                print("✅ Auto Punch enabled")
                
                if Functions.performPunch then
                    Variables.punchConnection = Shared.Services.RunService.Heartbeat:Connect(function()
                        if Variables.autoPunchEnabled then
                            Functions.performPunch()
                        end
                    end)
                end
                
            else
                Rayfield.Notify({
                    Title = "Auto Punch",
                    Content = "Auto punch disabled!",
                    Duration = 3
                })
                
                print("❌ Auto Punch disabled")
                
                if Variables.punchConnection then
                    Variables.punchConnection:Disconnect()
                    Variables.punchConnection = nil
                end
            end
        end
    })
    
    print("✅ AutoFarm tab initialized (Pets Edition)")
end

return AutoFarm