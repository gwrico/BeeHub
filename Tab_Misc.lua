-- ==============================================
-- ⚡ MISC TAB MODULE - COMPATIBLE WITH SIMPLEGUI v6.3 (FIXED SYNTAX)
-- ==============================================

local Misc = {}

function Misc.Init(Dependencies)
    local Tab = Dependencies.Tab
    local Shared = Dependencies.Shared
    local Bdev = Dependencies.Bdev
    local Window = Dependencies.Window
    local GUI = Dependencies.GUI  -- ✅ ADDED: Access to SimpleGUI
    
    local Variables = Shared.Variables
    local Services = Shared.Services
    
    print("⚡ Initializing Misc tab for SimpleGUI v6.3...")
    
    -- ===== ANTI-AFK (FIXED VERSION) =====
    local antiAFKConnection
    
    Tab:CreateToggle({
        Name = "AntiAFK",
        Text = "⏰ Anti-AFK",
        CurrentValue = false,
        Callback = function(value)
            Variables.antiAfkEnabled = value
            
            if value then
                Bdev:Notify({
                    Title = "Anti-AFK",
                    Content = "Anti-AFK enabled! You won't be kicked.",
                    Duration = 3
                })
                
                print("✅ Anti-AFK enabled")
                
                -- Method yang lebih aman
                local lastActivity = tick()
                
                antiAFKConnection = Services.RunService.Heartbeat:Connect(function()
                    if not Variables.antiAfkEnabled then
                        return
                    end
                    
                    -- Reset idle timer setiap 30 detik
                    if tick() - lastActivity > 30 then
                        lastActivity = tick()
                        
                        pcall(function()
                            local VirtualUser = game:GetService("VirtualUser")
                            VirtualUser:CaptureController()
                            VirtualUser:ClickButton2(Vector2.new(0, 0))
                        end)
                    end
                end)
                
            else
                Bdev:Notify({
                    Title = "Anti-AFK",
                    Content = "Anti-AFK disabled!",
                    Duration = 3
                })
                
                print("❌ Anti-AFK disabled")
                
                if antiAFKConnection then
                    antiAFKConnection:Disconnect()
                    antiAFKConnection = nil
                end
            end
        end
    })
    
    -- ===== NO CLIP (SIMPLIFIED) =====
    local noclipConnection
    
    Tab:CreateToggle({
        Name = "NoClip",
        Text = "👻 No Clip",
        CurrentValue = false,
        Callback = function(value)
            Variables.noclipEnabled = value
            
            if value then
                Bdev:Notify({
                    Title = "No Clip",
                    Content = "No Clip enabled! Walk through walls.",
                    Duration = 3
                })
                
                print("✅ No Clip enabled")
                
                if noclipConnection then
                    noclipConnection:Disconnect()
                end
                
                noclipConnection = Services.RunService.Stepped:Connect(function()
                    if not Variables.noclipEnabled then 
                        return 
                    end
                    
                    local character = Services.Players.LocalPlayer.Character
                    if character then
                        for _, part in pairs(character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end)
                
            else
                Bdev:Notify({
                    Title = "No Clip",
                    Content = "No Clip disabled!",
                    Duration = 3
                })
                
                print("❌ No Clip disabled")
                
                if noclipConnection then
                    noclipConnection:Disconnect()
                    noclipConnection = nil
                end
                
                -- Restore collision
                local character = Services.Players.LocalPlayer.Character
                if character then
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = true
                        end
                    end
                end
            end
        end
    })
    
    -- ===== INFINITE JUMP =====
    local infiniteJumpConnection
    
    Tab:CreateToggle({
        Name = "InfiniteJump",
        Text = "🦘 Infinite Jump",
        CurrentValue = false,
        Callback = function(value)
            Variables.infiniteJumpEnabled = value
            
            if value then
                Bdev:Notify({
                    Title = "Infinite Jump",
                    Content = "Infinite Jump enabled!",
                    Duration = 3
                })
                
                print("✅ Infinite Jump enabled")
                
                if infiniteJumpConnection then
                    infiniteJumpConnection:Disconnect()
                end
                
                infiniteJumpConnection = Services.UserInputService.JumpRequest:Connect(function()
                    if Variables.infiniteJumpEnabled then
                        local character = Services.Players.LocalPlayer.Character
                        if character and character:FindFirstChild("Humanoid") then
                            character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                    end
                end)
                
            else
                Bdev:Notify({
                    Title = "Infinite Jump",
                    Content = "Infinite Jump disabled!",
                    Duration = 3
                })
                
                print("❌ Infinite Jump disabled")
                
                if infiniteJumpConnection then
                    infiniteJumpConnection:Disconnect()
                    infiniteJumpConnection = nil
                end
            end
        end
    })
    
    -- ===== UTILITIES SECTION =====
    Tab:CreateLabel({
        Name = "UtilitiesLabel",
        Text = "🔧 Utilities:",
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- ===== DESTROY GUI =====
    Tab:CreateButton({
        Name = "DestroyGUI",
        Text = "🗑️ Destroy GUI",
        Callback = function()
            if Window and Window.MainFrame then
                Window.MainFrame.Visible = false
                print("🗑️ GUI destroyed")
                Bdev:Notify({
                    Title = "GUI",
                    Content = "GUI destroyed!",
                    Duration = 3
                })
            else
                Bdev:Notify({
                    Title = "Error",
                    Content = "Could not find GUI window!",
                    Duration = 3
                })
            end
        end
    })
    
    -- ===== REJOIN SERVER =====
    Tab:CreateButton({
        Name = "RejoinServer",
        Text = "🔄 Rejoin Server",
        Callback = function()
            Bdev:Notify({
                Title = "Rejoin",
                Content = "Rejoining server...",
                Duration = 3
            })
            
            local TeleportService = game:GetService("TeleportService")
            local Players = game:GetService("Players")
            local player = Players.LocalPlayer
            
            local success, err = pcall(function()
                TeleportService:Teleport(game.PlaceId, player)
            end)
            
            if not success then
                Bdev:Notify({
                    Title = "Error",
                    Content = "Failed to rejoin: " .. tostring(err),
                    Duration = 5
                })
            end
        end
    })
    
    -- ===== SERVER HOP =====
    Tab:CreateButton({
        Name = "ServerHop",
        Text = "🌐 Server Hop",
        Callback = function()
            Bdev:Notify({
                Title = "Server Hop",
                Content = "Finding new server...",
                Duration = 3
            })
            
            local function findNewServer()
                local HttpService = game:GetService("HttpService")
                local TeleportService = game:GetService("TeleportService")
                
                local success, servers = pcall(function()
                    local response = game:HttpGet(
                        "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"
                    )
                    return HttpService:JSONDecode(response)
                end)
                
                if success and servers and servers.data then
                    for _, server in ipairs(servers.data) do
                        if server.playing < server.maxPlayers and server.id ~= game.JobId then
                            pcall(function()
                                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
                            end)
                            return true
                        end
                    end
                end
                
                return false
            end
            
            local found = findNewServer()
            if not found then
                Bdev:Notify({
                    Title = "Server Hop",
                    Content = "No servers found, rejoining...",
                    Duration = 3
                })
                
                pcall(function()
                    game:GetService("TeleportService"):Teleport(game.PlaceId)
                end)
            end
        end
    })
    
    -- ===== GAME INFO =====
    Tab:CreateButton({
        Name = "GameInfo",
        Text = "📊 Game Info",
        Callback = function()
            print("\n" .. string.rep("=", 40))
            print("📊 GAME INFORMATION")
            print(string.rep("=", 40))
            
            -- Basic info
            print("Place ID:", game.PlaceId)
            
            local productInfo = {Name = "Unknown"}
            pcall(function()
                productInfo = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
            end)
            print("Game Name:", productInfo.Name)
            
            print("Players:", #Services.Players:GetPlayers() .. "/" .. game.Players.MaxPlayers)
            
            -- Player info
            local player = Services.Players.LocalPlayer
            print("\n👤 PLAYER INFO:")
            print("Username:", player.Name)
            print("Display Name:", player.DisplayName)
            print("User ID:", player.UserId)
            
            -- Character info
            if player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    print("Walk Speed:", humanoid.WalkSpeed)
                    print("Jump Power:", humanoid.JumpPower)
                end
            end
            
            -- Check BeeHub system
            print("\n🐝 BEEHUB SYSTEM:")
            print("Version: v4.0")
            print("SimpleGUI: v6.3")
            print("Loaded Tabs:", #Shared.Tabs)
            
            print(string.rep("=", 40))
            
            Bdev:Notify({
                Title = "Game Info",
                Content = "Check console (F9) for details!",
                Duration = 5
            })
        end
    })
    
    -- ===== COPY DISCORD =====
    Tab:CreateButton({
        Name = "CopyDiscord",
        Text = "💬 Copy Discord",
        Callback = function()
            local discordLink = "https://discord.gg/example"
            
            local copied = false
            
            -- Try multiple copy methods
            local methods = {
                function() 
                    if setclipboard then 
                        setclipboard(discordLink) 
                        return true 
                    end 
                end,
                function() 
                    if writeclipboard then 
                        writeclipboard(discordLink) 
                        return true 
                    end 
                end,
                function() 
                    if toclipboard then 
                        toclipboard(discordLink) 
                        return true 
                    end 
                end
            }
            
            for _, method in ipairs(methods) do
                local success = pcall(method)
                if success then
                    copied = true
                    break
                end
            end
            
            if copied then
                Bdev:Notify({
                    Title = "Discord",
                    Content = "Discord link copied!",
                    Duration = 3
                })
                print("📋 Discord link copied:", discordLink)
            else
                print("\n" .. string.rep("=", 50))
                print("📋 DISCORD LINK (COPY MANUALLY):")
                print(discordLink)
                print(string.rep("=", 50))
                
                Bdev:Notify({
                    Title = "Discord",
                    Content = "Check console (F9) to copy link!",
                    Duration = 5
                })
            end
        end
    })
    
    -- ===== COPY GAME ID =====
    Tab:CreateButton({
        Name = "CopyGameID",
        Text = "🎮 Copy Game ID",
        Callback = function()
            local gameId = tostring(game.PlaceId)
            local copied = false
            
            local methods = {
                function() 
                    if setclipboard then 
                        setclipboard(gameId) 
                        return true 
                    end 
                end,
                function() 
                    if writeclipboard then 
                        writeclipboard(gameId) 
                        return true 
                    end 
                end
            }
            
            for _, method in ipairs(methods) do
                local success = pcall(method)
                if success then
                    copied = true
                    break
                end
            end
            
            if copied then
                Bdev:Notify({
                    Title = "Game ID",
                    Content = "Game ID copied!",
                    Duration = 3
                })
                print("🎮 Game ID copied:", gameId)
            else
                print("\n" .. string.rep("=", 40))
                print("🎮 GAME ID:", gameId)
                print(string.rep("=", 40))
                
                Bdev:Notify({
                    Title = "Game ID",
                    Content = "Game ID: " .. gameId,
                    Duration = 4
                })
            end
        end
    })
    
    -- ===== CHANGE THEME =====
    Tab:CreateLabel({
        Name = "ThemeLabel",
        Text = "🎨 Quick Theme:",
        Alignment = Enum.TextXAlignment.Center
    })
    
    Tab:CreateButton({
        Name = "DarkTheme",
        Text = "🌙 Dark Theme",
        Callback = function()
            GUI:SetTheme("DARK")
            Bdev:Notify({
                Title = "Theme",
                Content = "Dark theme applied!",
                Duration = 3
            })
        end
    })
    
    Tab:CreateButton({
        Name = "LightTheme",
        Text = "☀️ Light Theme",
        Callback = function()
            GUI:SetTheme("LIGHT")
            Bdev:Notify({
                Title = "Theme",
                Content = "Light theme applied!",
                Duration = 3
            })
        end
    })
    
    Tab:CreateButton({
        Name = "PurpleTheme",
        Text = "💜 Purple Theme",
        Callback = function()
            GUI:SetTheme("PURPLE")
            Bdev:Notify({
                Title = "Theme",
                Content = "Purple theme applied!",
                Duration = 3
            })
        end
    })
    
    -- ===== CLEANUP ON EXIT =====
    Services.Players.LocalPlayer.CharacterAdded:Connect(function()
        Variables.antiAfkEnabled = false
        Variables.noclipEnabled = false
        Variables.infiniteJumpEnabled = false
        
        if antiAFKConnection then
            antiAFKConnection:Disconnect()
            antiAFKConnection = nil
        end
        
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        
        if infiniteJumpConnection then
            infiniteJumpConnection:Disconnect()
            infiniteJumpConnection = nil
        end
    end)
    
    print("✅ Misc tab initialized")
end

return Misc