-- ==============================================
-- 👤 PLAYER MODS TAB MODULE (SimpleGUI v4.0 Compatible)
-- ==============================================

local PlayerMods = {}

function PlayerMods.Init(Dependencies)
    local Window = Dependencies.Window
    local SimpleGUI = Dependencies.SimpleGUI
    local Services = Dependencies.Services
    local Variables = Dependencies.Variables
    local Functions = Dependencies.Functions
    
    print("👤 Initializing PlayerMods tab for SimpleGUI v4.0...")
    
    -- Create PlayerMods Tab
    local PlayerTab = Window:CreateTab("Player Mods")
    
    -- ===== SPEED HACK =====
    local customSpeed = 100
    local speedHackEnabled = false
    
    PlayerTab:CreateLabel({Text = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"})
    PlayerTab:CreateLabel({Text = "🏃 SPEED HACK", TextSize = 16})
    PlayerTab:CreateLabel({Text = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"})
    
    local speedToggle = PlayerTab:CreateToggle({
        Name = "SpeedHack",
        CurrentValue = false,
        Callback = function(value)
            speedHackEnabled = value
            
            if value then
                SimpleGUI:ShowNotification({
                    Message = "Speed hack enabled! (" .. customSpeed .. " walk speed)",
                    Type = "Success",
                    Duration = 3
                })
                
                print("✅ Speed hack enabled:", customSpeed)
                
                local connection
                connection = Services.RunService.Heartbeat:Connect(function()
                    if not speedHackEnabled then
                        connection:Disconnect()
                        return
                    end
                    
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") then
                        char.Humanoid.WalkSpeed = customSpeed
                    end
                end)
                
            else
                SimpleGUI:ShowNotification({
                    Message = "Speed hack disabled!",
                    Type = "Warning",
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
    
    local speedSlider = PlayerTab:CreateSlider({
        Name = "Speed Value",
        Range = {16, 500},
        CurrentValue = 100,
        Callback = function(value)
            customSpeed = value
            if speedHackEnabled then
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
    local jumpHackEnabled = false
    
    PlayerTab:CreateLabel({Text = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"})
    PlayerTab:CreateLabel({Text = "🦘 JUMP HACK", TextSize = 16})
    PlayerTab:CreateLabel({Text = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"})
    
    local jumpToggle = PlayerTab:CreateToggle({
        Name = "JumpHack",
        CurrentValue = false,
        Callback = function(value)
            jumpHackEnabled = value
            
            if value then
                SimpleGUI:ShowNotification({
                    Message = "Jump hack enabled! (" .. customJump .. " jump power)",
                    Type = "Success",
                    Duration = 3
                })
                
                print("✅ Jump hack enabled:", customJump)
                
                local connection
                connection = Services.RunService.Heartbeat:Connect(function()
                    if not jumpHackEnabled then
                        connection:Disconnect()
                        return
                    end
                    
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") then
                        char.Humanoid.JumpPower = customJump
                    end
                end)
                
            else
                SimpleGUI:ShowNotification({
                    Message = "Jump hack disabled!",
                    Type = "Warning",
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
    
    local jumpSlider = PlayerTab:CreateSlider({
        Name = "Jump Value",
        Range = {50, 500},
        CurrentValue = 150,
        Callback = function(value)
            customJump = value
            if jumpHackEnabled then
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.JumpPower = value
                end
            end
            print("📊 Jump power set to:", value)
        end
    })
    
    -- ===== FLY HACK =====
    local flySpeed = 50
    local flyEnabled = false
    local flyBodyVelocity = nil
    local flyConnection = nil
    
    PlayerTab:CreateLabel({Text = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"})
    PlayerTab:CreateLabel({Text = "✈️ FLY HACK", TextSize = 16})
    PlayerTab:CreateLabel({Text = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"})
    
    local flyToggle = PlayerTab:CreateToggle({
        Name = "FlyHack",
        CurrentValue = false,
        Callback = function(value)
            flyEnabled = value
            
            if value then
                SimpleGUI:ShowNotification({
                    Message = "Fly hack enabled! (" .. flySpeed .. " speed)",
                    Type = "Success",
                    Duration = 3
                })
                
                print("✅ Fly hack enabled:", flySpeed)
                
                -- Initialize fly
                local player = game.Players.LocalPlayer
                local character = player.Character or player.CharacterAdded:Wait()
                
                -- Create fly body velocity
                flyBodyVelocity = Instance.new("BodyVelocity")
                flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
                flyBodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
                flyBodyVelocity.P = 1000
                flyBodyVelocity.Name = "FlyHackBodyVelocity"
                flyBodyVelocity.Parent = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
                
                -- Fly control function
                flyConnection = Services.RunService.Heartbeat:Connect(function()
                    if not flyEnabled or not character or not character:FindFirstChild("HumanoidRootPart") then
                        if flyConnection then
                            flyConnection:Disconnect()
                            flyConnection = nil
                        end
                        if flyBodyVelocity then
                            flyBodyVelocity:Destroy()
                            flyBodyVelocity = nil
                        end
                        return
                    end
                    
                    local root = character.HumanoidRootPart
                    if not flyBodyVelocity or not flyBodyVelocity.Parent then
                        flyBodyVelocity = Instance.new("BodyVelocity")
                        flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
                        flyBodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
                        flyBodyVelocity.P = 1000
                        flyBodyVelocity.Name = "FlyHackBodyVelocity"
                        flyBodyVelocity.Parent = root
                    end
                    
                    -- Get input for flying
                    local camera = workspace.CurrentCamera
                    local forward = camera.CFrame.LookVector
                    local right = camera.CFrame.RightVector
                    local up = Vector3.new(0, 1, 0)
                    
                    local direction = Vector3.new(0, 0, 0)
                    
                    -- W (forward)
                    if Services.UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        direction = direction + forward
                    end
                    -- S (backward)
                    if Services.UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        direction = direction - forward
                    end
                    -- A (left)
                    if Services.UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        direction = direction - right
                    end
                    -- D (right)
                    if Services.UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        direction = direction + right
                    end
                    -- Space (up)
                    if Services.UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        direction = direction + up
                    end
                    -- LeftShift (down)
                    if Services.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        direction = direction - up
                    end
                    
                    -- Normalize and apply speed
                    if direction.Magnitude > 0 then
                        direction = direction.Unit * flySpeed
                    end
                    
                    -- Apply velocity
                    flyBodyVelocity.Velocity = direction
                    
                    -- Zero out gravity while flying
                    if character:FindFirstChild("Humanoid") then
                        character.Humanoid.PlatformStand = true
                    end
                end)
                
                -- Handle character respawn
                player.CharacterAdded:Connect(function(newChar)
                    character = newChar
                    if flyEnabled then
                        task.wait(1)
                        if flyBodyVelocity then flyBodyVelocity:Destroy() end
                        flyBodyVelocity = Instance.new("BodyVelocity")
                        flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
                        flyBodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
                        flyBodyVelocity.P = 1000
                        flyBodyVelocity.Name = "FlyHackBodyVelocity"
                        flyBodyVelocity.Parent = newChar.PrimaryPart or newChar:FindFirstChild("HumanoidRootPart")
                    end
                end)
                
            else
                SimpleGUI:ShowNotification({
                    Message = "Fly hack disabled!",
                    Type = "Warning",
                    Duration = 3
                })
                
                print("❌ Fly hack disabled")
                
                -- Clean up
                if flyConnection then
                    flyConnection:Disconnect()
                    flyConnection = nil
                end
                
                if flyBodyVelocity then
                    flyBodyVelocity:Destroy()
                    flyBodyVelocity = nil
                end
                
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.PlatformStand = false
                end
            end
        end
    })
    
    local flySpeedSlider = PlayerTab:CreateSlider({
        Name = "Fly Speed",
        Range = {10, 200},
        CurrentValue = 50,
        Callback = function(value)
            flySpeed = value
            print("📊 Fly speed set to:", value)
        end
    })
    
    -- ===== CHARACTER MODIFIER =====
    local characterSize = 1
    local invisibleEnabled = false
    
    PlayerTab:CreateLabel({Text = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"})
    PlayerTab:CreateLabel({Text = "⚡ CHARACTER MODIFIER", TextSize = 16})
    PlayerTab:CreateLabel({Text = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"})
    
    local sizeSlider = PlayerTab:CreateSlider({
        Name = "Character Size",
        Range = {0.1, 10},
        CurrentValue = 1,
        Callback = function(value)
            characterSize = value
            
            local player = game.Players.LocalPlayer
            local character = player.Character
            if not character then return end
            
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                -- Scale character parts
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Size = part.Size * (value / characterSize)
                    end
                end
                
                -- Scale humanoid if it's a Scale instance
                if humanoid:FindFirstChild("BodyDepthScale") then
                    humanoid.BodyDepthScale.Value = value
                    humanoid.BodyWidthScale.Value = value
                    humanoid.BodyHeightScale.Value = value
                    humanoid.HeadScale.Value = value
                end
                
                print("📏 Character size set to:", value)
            end
        end
    })
    
    PlayerTab:CreateButton({
        Text = "🔄 Reset Size",
        Callback = function()
            characterSize = 1
            sizeSlider.Set(1)
            
            local player = game.Players.LocalPlayer
            local character = player.Character
            if not character then return end
            
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                if humanoid:FindFirstChild("BodyDepthScale") then
                    humanoid.BodyDepthScale.Value = 1
                    humanoid.BodyWidthScale.Value = 1
                    humanoid.BodyHeightScale.Value = 1
                    humanoid.HeadScale.Value = 1
                end
            end
            
            SimpleGUI:ShowNotification({
                Message = "Character size reset to normal!",
                Type = "Info",
                Duration = 3
            })
            
            print("✅ Character size reset")
        end
    })
    
    local invisibleToggle = PlayerTab:CreateToggle({
        Name = "Invisible Character",
        CurrentValue = false,
        Callback = function(value)
            invisibleEnabled = value
            
            if value then
                SimpleGUI:ShowNotification({
                    Message = "Character is now invisible!",
                    Type = "Success",
                    Duration = 3
                })
                
                print("✅ Invisible mode enabled")
                
                local connection
                connection = Services.RunService.Heartbeat:Connect(function()
                    if not invisibleEnabled then
                        connection:Disconnect()
                        return
                    end
                    
                    local char = game.Players.LocalPlayer.Character
                    if char then
                        -- Make all parts transparent
                        for _, part in pairs(char:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.Transparency = 1
                                if part:FindFirstChildOfClass("Decal") then
                                    part:FindFirstChildOfClass("Decal").Transparency = 1
                                end
                            elseif part:IsA("Accessory") then
                                local handle = part:FindFirstChild("Handle")
                                if handle and handle:IsA("BasePart") then
                                    handle.Transparency = 1
                                end
                            end
                        end
                    end
                end)
                
            else
                SimpleGUI:ShowNotification({
                    Message = "Character is now visible!",
                    Type = "Info",
                    Duration = 3
                })
                
                print("❌ Invisible mode disabled")
                
                local char = game.Players.LocalPlayer.Character
                if char then
                    -- Reset transparency
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Transparency = 0
                            if part:FindFirstChildOfClass("Decal") then
                                part:FindFirstChildOfClass("Decal").Transparency = 0
                            end
                        elseif part:IsA("Accessory") then
                            local handle = part:FindFirstChild("Handle")
                            if handle and handle:IsA("BasePart") then
                                handle.Transparency = 0
                            end
                        end
                    end
                end
            end
        end
    })
    
    -- ===== RAINBOW CHARACTER =====
    local rainbowSpeed = 1
    local rainbowEnabled = false
    
    PlayerTab:CreateLabel({Text = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"})
    PlayerTab:CreateLabel({Text = "🌈 RAINBOW EFFECTS", TextSize = 16})
    PlayerTab:CreateLabel({Text = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"})
    
    local rainbowToggle = PlayerTab:CreateToggle({
        Name = "Rainbow Character",
        CurrentValue = false,
        Callback = function(value)
            rainbowEnabled = value
            
            if value then
                SimpleGUI:ShowNotification({
                    Message = "Rainbow mode enabled!",
                    Type = "Success",
                    Duration = 3
                })
                
                print("✅ Rainbow character enabled")
                
                local hue = 0
                local connection
                connection = Services.RunService.Heartbeat:Connect(function(deltaTime)
                    if not rainbowEnabled then
                        connection:Disconnect()
                        -- Reset colors
                        local char = game.Players.LocalPlayer.Character
                        if char then
                            for _, part in pairs(char:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.Color = Color3.fromRGB(255, 255, 255)
                                end
                            end
                        end
                        return
                    end
                    
                    -- Update hue
                    hue = (hue + (deltaTime * rainbowSpeed)) % 1
                    
                    -- Calculate rainbow color
                    local color = Color3.fromHSV(hue, 1, 1)
                    
                    -- Apply to character
                    local char = game.Players.LocalPlayer.Character
                    if char then
                        for _, part in pairs(char:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.Color = color
                                
                                -- Also change particle colors if they exist
                                for _, particle in pairs(part:GetChildren()) do
                                    if particle:IsA("ParticleEmitter") then
                                        particle.Color = ColorSequence.new(color)
                                    end
                                end
                            end
                        end
                    end
                end)
                
            else
                SimpleGUI:ShowNotification({
                    Message = "Rainbow mode disabled!",
                    Type = "Info",
                    Duration = 3
                })
                
                print("❌ Rainbow character disabled")
                
                -- Reset character colors
                local char = game.Players.LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Color = Color3.fromRGB(255, 255, 255)
                        end
                    end
                end
            end
        end
    })
    
    local rainbowSlider = PlayerTab:CreateSlider({
        Name = "Rainbow Speed",
        Range = {0.1, 10},
        CurrentValue = 1,
        Callback = function(value)
            rainbowSpeed = value
            print("🌈 Rainbow speed set to:", value)
        end
    })
    
    PlayerTab:CreateButton({
        Text = "🎨 Reset Colors",
        Callback = function()
            rainbowEnabled = false
            
            local char = game.Players.LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Color = Color3.fromRGB(255, 255, 255)
                    end
                end
            end
            
            SimpleGUI:ShowNotification({
                Message = "Character colors reset to default!",
                Type = "Info",
                Duration = 3
            })
            
            print("✅ Character colors reset")
        end
    })
    
    -- ===== NOCLIP =====
    local noclipEnabled = false
    
    PlayerTab:CreateLabel({Text = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"})
    PlayerTab:CreateLabel({Text = "👻 NOCLIP", TextSize = 16})
    PlayerTab:CreateLabel({Text = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"})
    
    local noclipToggle = PlayerTab:CreateToggle({
        Name = "Noclip",
        CurrentValue = false,
        Callback = function(value)
            noclipEnabled = value
            
            if value then
                SimpleGUI:ShowNotification({
                    Message = "Noclip enabled!",
                    Type = "Success",
                    Duration = 3
                })
                
                print("✅ Noclip enabled")
                
                local connection
                connection = Services.RunService.Stepped:Connect(function()
                    if not noclipEnabled then
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
                SimpleGUI:ShowNotification({
                    Message = "Noclip disabled!",
                    Type = "Warning",
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
    local infiniteJumpEnabled = false
    
    PlayerTab:CreateLabel({Text = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"})
    PlayerTab:CreateLabel({Text = "∞ INFINITE JUMP", TextSize = 16})
    PlayerTab:CreateLabel({Text = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"})
    
    local infiniteJumpToggle = PlayerTab:CreateToggle({
        Name = "Infinite Jump",
        CurrentValue = false,
        Callback = function(value)
            infiniteJumpEnabled = value
            
            if value then
                SimpleGUI:ShowNotification({
                    Message = "Infinite jump enabled!",
                    Type = "Success",
                    Duration = 3
                })
                
                print("✅ Infinite jump enabled")
                
                local connection
                connection = Services.UserInputService.JumpRequest:Connect(function()
                    if not infiniteJumpEnabled then
                        connection:Disconnect()
                        return
                    end
                    
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") then
                        char.Humanoid:ChangeState("Jumping")
                    end
                end)
                
            else
                SimpleGUI:ShowNotification({
                    Message = "Infinite jump disabled!",
                    Type = "Warning",
                    Duration = 3
                })
                
                print("❌ Infinite jump disabled")
            end
        end
    })
    
    -- ===== DISABLE ALL HACKS =====
    PlayerTab:CreateLabel({Text = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"})
    PlayerTab:CreateLabel({Text = "⚠️ SYSTEM", TextSize = 16})
    PlayerTab:CreateLabel({Text = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"})
    
    PlayerTab:CreateButton({
        Text = "🔴 Disable All Hacks",
        Callback = function()
            print("\n🔴 DISABLING ALL HACKS...")
            
            -- Disable all toggles
            speedHackEnabled = false
            speedToggle.Set(false)
            
            jumpHackEnabled = false
            jumpToggle.Set(false)
            
            noclipEnabled = false
            noclipToggle.Set(false)
            
            infiniteJumpEnabled = false
            infiniteJumpToggle.Set(false)
            
            flyEnabled = false
            flyToggle.Set(false)
            
            rainbowEnabled = false
            rainbowToggle.Set(false)
            
            invisibleEnabled = false
            invisibleToggle.Set(false)
            
            -- Reset character stats
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = 16
                char.Humanoid.JumpPower = 50
                
                -- Remove fly body velocity
                local bodyVelocity = char:FindFirstChild("FlyHackBodyVelocity")
                if bodyVelocity then
                    bodyVelocity:Destroy()
                end
                
                -- Reset platform stand
                char.Humanoid.PlatformStand = false
                
                -- Reset size and colors
                if char.Humanoid:FindFirstChild("BodyDepthScale") then
                    char.Humanoid.BodyDepthScale.Value = 1
                    char.Humanoid.BodyWidthScale.Value = 1
                    char.Humanoid.BodyHeightScale.Value = 1
                    char.Humanoid.HeadScale.Value = 1
                end
                
                -- Reset colors
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Color = Color3.fromRGB(255, 255, 255)
                        part.Transparency = 0
                    end
                end
            end
            
            SimpleGUI:ShowNotification({
                Message = "All hacks have been disabled!",
                Type = "Info",
                Duration = 4
            })
            
            print("✅ All hacks disabled")
        end
    })
    
    print("✅ PlayerMods tab initialized for SimpleGUI v4.0")
    
    -- Return the PlayerTab for external access if needed
    return {
        Tab = PlayerTab,
        Variables = {
            speedHackEnabled = speedHackEnabled,
            jumpHackEnabled = jumpHackEnabled,
            noclipEnabled = noclipEnabled,
            infiniteJumpEnabled = infiniteJumpEnabled,
            flyEnabled = flyEnabled,
            rainbowEnabled = rainbowEnabled,
            invisibleEnabled = invisibleEnabled
        }
    }
end

return PlayerMods