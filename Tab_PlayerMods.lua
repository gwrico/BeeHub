-- ==============================================
-- 👤 PLAYER MODS TAB MODULE - SIMPLE VERSION FOR SIMPLEGUI v6.3
-- ==============================================

local PlayerMods = {}

function PlayerMods.Init(Dependencies)
    local Tab = Dependencies.Tab
    local Shared = Dependencies.Shared
    local Bdev = Dependencies.Bdev
    
    local Services = Shared.Services
    local Variables = Shared.Variables
    
    print("👤 Initializing PlayerMods tab for SimpleGUI v6.3...")
    
    -- State variables
    local speedEnabled = false
    local jumpEnabled = false
    local noclipEnabled = false
    local infiniteJumpEnabled = false
    local flyEnabled = false
    
    local currentSpeed = 100
    local currentJump = 150
    local currentFlySpeed = 50
    
    -- Connections
    local speedConnection = nil
    local jumpConnection = nil
    local noclipConnection = nil
    local infiniteJumpConnection = nil
    local flyConnection = nil
    
    -- ===== SPEED HACK =====
    Tab:CreateLabel({
        Name = "SpeedLabel",
        Text = "🏃 Speed Hack:",
        Alignment = Enum.TextXAlignment.Left
    })
    
    -- Speed toggle button (ON/OFF)
    local speedToggleBtn = Tab:CreateButton({
        Name = "SpeedToggle",
        Text = speedEnabled and "✅ Speed ON" or "❌ Speed OFF",
        Callback = function()
            speedEnabled = not speedEnabled
            Variables.speedHackEnabled = speedEnabled
            
            if speedEnabled then
                speedToggleBtn.Text = "✅ Speed ON"
                Bdev:Notify({
                    Title = "Speed Hack",
                    Content = "Speed hack enabled! (" .. currentSpeed .. " walk speed)",
                    Duration = 3
                })
                
                print("✅ Speed hack enabled:", currentSpeed)
                
                if speedConnection then
                    speedConnection:Disconnect()
                end
                
                speedConnection = Services.RunService.Heartbeat:Connect(function()
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") then
                        char.Humanoid.WalkSpeed = currentSpeed
                    end
                end)
            else
                speedToggleBtn.Text = "❌ Speed OFF"
                Bdev:Notify({
                    Title = "Speed Hack",
                    Content = "Speed hack disabled!",
                    Duration = 3
                })
                
                print("❌ Speed hack disabled")
                
                if speedConnection then
                    speedConnection:Disconnect()
                    speedConnection = nil
                end
                
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.WalkSpeed = 16
                end
            end
        end
    })
    
    -- Speed value buttons (instead of slider)
    Tab:CreateLabel({
        Name = "SpeedValueLabel",
        Text = "Speed Value: " .. currentSpeed,
        Alignment = Enum.TextXAlignment.Left
    })
    
    -- Quick speed buttons
    local speedButtons = {
        {"16 (Normal)", 16},
        {"50 (Fast)", 50},
        {"100 (Very Fast)", 100},
        {"200 (Extreme)", 200}
    }
    
    for i, speedInfo in ipairs(speedButtons) do
        local text, value = speedInfo[1], speedInfo[2]
        
        Tab:CreateButton({
            Name = "SpeedBtn" .. i,
            Text = text,
            Callback = function()
                currentSpeed = value
                
                -- Update label
                for _, element in pairs(Tab.Elements) do
                    if element.Name == "SpeedValueLabel" then
                        element.Text = "Speed Value: " .. currentSpeed
                        break
                    end
                end
                
                -- Apply if enabled
                if speedEnabled then
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") then
                        char.Humanoid.WalkSpeed = currentSpeed
                    end
                end
                
                print("📊 Speed set to:", value)
            end
        })
    end
    
    -- ===== JUMP HACK =====
    Tab:CreateLabel({
        Name = "JumpLabel",
        Text = "🦘 Jump Hack:",
        Alignment = Enum.TextXAlignment.Left
    })
    
    -- Jump toggle button
    local jumpToggleBtn = Tab:CreateButton({
        Name = "JumpToggle",
        Text = jumpEnabled and "✅ Jump ON" or "❌ Jump OFF",
        Callback = function()
            jumpEnabled = not jumpEnabled
            Variables.jumpHackEnabled = jumpEnabled
            
            if jumpEnabled then
                jumpToggleBtn.Text = "✅ Jump ON"
                Bdev:Notify({
                    Title = "Jump Hack",
                    Content = "Jump hack enabled! (" .. currentJump .. " jump power)",
                    Duration = 3
                })
                
                print("✅ Jump hack enabled:", currentJump)
                
                if jumpConnection then
                    jumpConnection:Disconnect()
                end
                
                jumpConnection = Services.RunService.Heartbeat:Connect(function()
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") then
                        char.Humanoid.JumpPower = currentJump
                    end
                end)
            else
                jumpToggleBtn.Text = "❌ Jump OFF"
                Bdev:Notify({
                    Title = "Jump Hack",
                    Content = "Jump hack disabled!",
                    Duration = 3
                })
                
                print("❌ Jump hack disabled")
                
                if jumpConnection then
                    jumpConnection:Disconnect()
                    jumpConnection = nil
                end
                
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.JumpPower = 50
                end
            end
        end
    })
    
    -- Jump value label
    Tab:CreateLabel({
        Name = "JumpValueLabel",
        Text = "Jump Value: " .. currentJump,
        Alignment = Enum.TextXAlignment.Left
    })
    
    -- Quick jump buttons
    local jumpButtons = {
        {"50 (Normal)", 50},
        {"100 (High)", 100},
        {"150 (Very High)", 150},
        {"300 (Extreme)", 300}
    }
    
    for i, jumpInfo in ipairs(jumpButtons) do
        local text, value = jumpInfo[1], jumpInfo[2]
        
        Tab:CreateButton({
            Name = "JumpBtn" .. i,
            Text = text,
            Callback = function()
                currentJump = value
                
                -- Update label
                for _, element in pairs(Tab.Elements) do
                    if element.Name == "JumpValueLabel" then
                        element.Text = "Jump Value: " .. currentJump
                        break
                    end
                end
                
                -- Apply if enabled
                if jumpEnabled then
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") then
                        char.Humanoid.JumpPower = currentJump
                    end
                end
                
                print("📊 Jump set to:", value)
            end
        })
    end
    
    -- ===== NOCLIP =====
    Tab:CreateLabel({
        Name = "NoclipLabel",
        Text = "👻 Noclip:",
        Alignment = Enum.TextXAlignment.Left
    })
    
    local noclipToggleBtn = Tab:CreateButton({
        Name = "NoclipToggle",
        Text = noclipEnabled and "✅ Noclip ON" or "❌ Noclip OFF",
        Callback = function()
            noclipEnabled = not noclipEnabled
            Variables.noclipEnabled = noclipEnabled
            
            if noclipEnabled then
                noclipToggleBtn.Text = "✅ Noclip ON"
                Bdev:Notify({
                    Title = "Noclip",
                    Content = "Noclip enabled!",
                    Duration = 3
                })
                
                print("✅ Noclip enabled")
                
                if noclipConnection then
                    noclipConnection:Disconnect()
                end
                
                noclipConnection = Services.RunService.Stepped:Connect(function()
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
                noclipToggleBtn.Text = "❌ Noclip OFF"
                Bdev:Notify({
                    Title = "Noclip",
                    Content = "Noclip disabled!",
                    Duration = 3
                })
                
                print("❌ Noclip disabled")
                
                if noclipConnection then
                    noclipConnection:Disconnect()
                    noclipConnection = nil
                end
                
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
    Tab:CreateLabel({
        Name = "InfJumpLabel",
        Text = "∞ Infinite Jump:",
        Alignment = Enum.TextXAlignment.Left
    })
    
    local infiniteJumpToggleBtn = Tab:CreateButton({
        Name = "InfJumpToggle",
        Text = infiniteJumpEnabled and "✅ Inf Jump ON" or "❌ Inf Jump OFF",
        Callback = function()
            infiniteJumpEnabled = not infiniteJumpEnabled
            Variables.infiniteJumpEnabled = infiniteJumpEnabled
            
            if infiniteJumpEnabled then
                infiniteJumpToggleBtn.Text = "✅ Inf Jump ON"
                Bdev:Notify({
                    Title = "Infinite Jump",
                    Content = "Infinite jump enabled!",
                    Duration = 3
                })
                
                print("✅ Infinite jump enabled")
                
                if infiniteJumpConnection then
                    infiniteJumpConnection:Disconnect()
                end
                
                infiniteJumpConnection = Services.UserInputService.JumpRequest:Connect(function()
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") then
                        char.Humanoid:ChangeState("Jumping")
                    end
                end)
            else
                infiniteJumpToggleBtn.Text = "❌ Inf Jump OFF"
                Bdev:Notify({
                    Title = "Infinite Jump",
                    Content = "Infinite jump disabled!",
                    Duration = 3
                })
                
                print("❌ Infinite jump disabled")
                
                if infiniteJumpConnection then
                    infiniteJumpConnection:Disconnect()
                    infiniteJumpConnection = nil
                end
            end
        end
    })
    
    -- ===== DISABLE ALL =====
    Tab:CreateButton({
        Name = "DisableAll",
        Text = "🔴 Disable All Hacks",
        Callback = function()
            print("\n🔴 DISABLING ALL HACKS...")
            
            -- Disable all
            speedEnabled = false
            jumpEnabled = false
            noclipEnabled = false
            infiniteJumpEnabled = false
            flyEnabled = false
            
            Variables.speedHackEnabled = false
            Variables.jumpHackEnabled = false
            Variables.noclipEnabled = false
            Variables.infiniteJumpEnabled = false
            Variables.flyEnabled = false
            
            -- Update button texts
            speedToggleBtn.Text = "❌ Speed OFF"
            jumpToggleBtn.Text = "❌ Jump OFF"
            noclipToggleBtn.Text = "❌ Noclip OFF"
            infiniteJumpToggleBtn.Text = "❌ Inf Jump OFF"
            
            -- Disconnect connections
            if speedConnection then
                speedConnection:Disconnect()
                speedConnection = nil
            end
            
            if jumpConnection then
                jumpConnection:Disconnect()
                jumpConnection = nil
            end
            
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
            
            if infiniteJumpConnection then
                infiniteJumpConnection:Disconnect()
                infiniteJumpConnection = nil
            end
            
            if flyConnection then
                flyConnection:Disconnect()
                flyConnection = nil
            end
            
            -- Reset character
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = 16
                char.Humanoid.JumpPower = 50
                char.Humanoid.PlatformStand = false
            end
            
            Bdev:Notify({
                Title = "All Hacks",
                Content = "All hacks have been disabled!",
                Duration = 4
            })
            
            print("✅ All hacks disabled")
        end
    })
    
    print("✅ PlayerMods tab initialized for SimpleGUI v6.3")
end

return PlayerMods