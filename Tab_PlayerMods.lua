-- ==============================================
-- 👤 PLAYER MODS TAB MODULE
-- ==============================================

local PlayerMods = {}

function PlayerMods.Init(Dependencies)
    local Tab = Dependencies.Tab
    local Shared = Dependencies.Shared
    local Rayfield = Dependencies.Rayfield
    
    local Services = Shared.Services
    local Variables = Shared.Variables
    local Functions = Shared.Functions
    
    print("👤 Initializing PlayerMods tab...")
    
    -- ===== SPEED HACK =====
    local customSpeed = 100
    local speedToggle = Tab:CreateToggle({
        Name = "SpeedHack",
        Text = "🏃 Speed Hack",
        CurrentValue = false,
        Callback = function(value)
            Variables.speedHackEnabled = value
            
            if value then
                Rayfield.Notify({
                    Title = "Speed Hack",
                    Content = "Speed hack enabled! (" .. customSpeed .. " walk speed)",
                    Duration = 3
                })
                
                print("✅ Speed hack enabled:", customSpeed)
                
                local connection
                connection = Services.RunService.Heartbeat:Connect(function()
                    if not Variables.speedHackEnabled then
                        connection:Disconnect()
                        return
                    end
                    
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") then
                        char.Humanoid.WalkSpeed = customSpeed
                    end
                end)
                
            else
                Rayfield.Notify({
                    Title = "Speed Hack",
                    Content = "Speed hack disabled!",
                    Duration = 3
                })
                
                print("❌ Speed hack disabled")
                
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.WalkSpeed = 16
                end
            end
        end
    })
    
    Tab:CreateSlider({
        Name = "Speed Value",
        Range = {16, 500},
        Increment = 1,
        CurrentValue = 100,
        Callback = function(value)
            customSpeed = value
            if Variables.speedHackEnabled then
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.WalkSpeed = value
                end
            end
            print("📊 Speed set to:", value)
        end
    })
    
    -- ===== JUMP HACK =====
    local customJump = 150
    local jumpToggle = Tab:CreateToggle({
        Name = "JumpHack",
        Text = "🦘 Jump Hack",
        CurrentValue = false,
        Callback = function(value)
            Variables.jumpHackEnabled = value
            
            if value then
                Rayfield.Notify({
                    Title = "Jump Hack",
                    Content = "Jump hack enabled! (" .. customJump .. " jump power)",
                    Duration = 3
                })
                
                print("✅ Jump hack enabled:", customJump)
                
                local connection
                connection = Services.RunService.Heartbeat:Connect(function()
                    if not Variables.jumpHackEnabled then
                        connection:Disconnect()
                        return
                    end
                    
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") then
                        char.Humanoid.JumpPower = customJump
                    end
                end)
                
            else
                Rayfield.Notify({
                    Title = "Jump Hack",
                    Content = "Jump hack disabled!",
                    Duration = 3
                })
                
                print("❌ Jump hack disabled")
                
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.JumpPower = 50
                end
            end
        end
    })
    
    Tab:CreateSlider({
        Name = "Jump Value",
        Range = {50, 500},
        Increment = 5,
        CurrentValue = 150,
        Callback = function(value)
            customJump = value
            if Variables.jumpHackEnabled then
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.JumpPower = value
                end
            end
            print("📊 Jump power set to:", value)
        end
    })
    
    -- ===== NOCLIP =====
    Tab:CreateToggle({
        Name = "Noclip",
        Text = "👻 Noclip",
        CurrentValue = false,
        Callback = function(value)
            Variables.noclipEnabled = value
            
            if value then
                Rayfield.Notify({
                    Title = "Noclip",
                    Content = "Noclip enabled!",
                    Duration = 3
                })
                
                print("✅ Noclip enabled")
                
                local connection
                connection = Services.RunService.Stepped:Connect(function()
                    if not Variables.noclipEnabled then
                        connection:Disconnect()
                        return
                    end
                    
                    local char = game.Players.LocalPlayer.Character
                    if char then
                        for _, part in pairs(char:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end)
                
            else
                Rayfield.Notify({
                    Title = "Noclip",
                    Content = "Noclip disabled!",
                    Duration = 3
                })
                
                print("❌ Noclip disabled")
                
                local char = game.Players.LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = true
                        end
                    end
                end
            end
        end
    })
    
    -- ===== INFINITE JUMP =====
    Tab:CreateToggle({
        Name = "InfiniteJump",
        Text = "∞ Infinite Jump",
        CurrentValue = false,
        Callback = function(value)
            Variables.infiniteJumpEnabled = value
            
            if value then
                Rayfield.Notify({
                    Title = "Infinite Jump",
                    Content = "Infinite jump enabled!",
                    Duration = 3
                })
                
                print("✅ Infinite jump enabled")
                
                local connection
                connection = Services.UserInputService.JumpRequest:Connect(function()
                    if not Variables.infiniteJumpEnabled then
                        connection:Disconnect()
                        return
                    end
                    
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") then
                        char.Humanoid:ChangeState("Jumping")
                    end
                end)
                
            else
                Rayfield.Notify({
                    Title = "Infinite Jump",
                    Content = "Infinite jump disabled!",
                    Duration = 3
                })
                
                print("❌ Infinite jump disabled")
            end
        end
    })
    
    -- ===== DISABLE ALL HACKS =====
    Tab:CreateButton({
        Name = "DisableAll",
        Text = "🔴 Disable All Hacks",
        Callback = function()
            print("\n🔴 DISABLING ALL HACKS...")
            
            -- Disable all toggles
            Variables.speedHackEnabled = false
            Variables.jumpHackEnabled = false
            Variables.noclipEnabled = false
            Variables.infiniteJumpEnabled = false
            Variables.flyEnabled = false
            Variables.autoMineEnabled = false
            Variables.autoPunchEnabled = false
            
            -- Reset character stats
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = 16
                char.Humanoid.JumpPower = 50
            end
            
            Rayfield.Notify({
                Title = "All Hacks",
                Content = "All hacks have been disabled!",
                Duration = 4
            })
            
            print("✅ All hacks disabled")
        end
    })
    
    print("✅ PlayerMods tab initialized")
end

return PlayerMods
