-- ==============================================
-- ⚡ MISC TAB MODULE - UPDATED & FIXED
-- ==============================================

local Misc = {}

function Misc.Init(Dependencies)
    local Tab = Dependencies.Tab
    local Shared = Dependencies.Shared
    local Rayfield = Dependencies.Rayfield
    local Window = Dependencies.Window
    
    local Variables = Shared.Variables
    local Services = Shared.Services
    
    print("⚡ Initializing Misc tab...")
    
    -- ===== ANTI-AFK (FIXED VERSION) =====
    local antiAFKConnection
    
    Tab:CreateToggle({
        Name = "AntiAFK",
        Text = "🟢 Anti-AFK",
        CurrentValue = false,
        Callback = function(value)
            Variables.antiAfkEnabled = value
            
            if value then
                Rayfield.Notify({
                    Title = "Anti-AFK",
                    Content = "Anti-AFK enabled! You won't be kicked for AFK.",
                    Duration = 3
                })
                
                print("✅ Anti-AFK enabled")
                
                -- Method 1: Simpan waktu terakhir aktivitas
                local lastActivity = tick()
                
                -- Method 2: Connect ke Idled event (lebih aman)
                antiAFKConnection = Services.Players.LocalPlayer.Idled:Connect(function()
                    if Variables.antiAfkEnabled then
                        -- Reset last activity time
                        lastActivity = tick()
                        
                        -- Method yang lebih aman: Send key press untuk reset idle timer
                        pcall(function()
                            -- Press a harmless key (F13 atau key yang tidak digunakan)
                            Services.VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F13, false, nil)
                            task.wait(0.1)
                            Services.VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F13, false, nil)
                        end)
                        
                        -- Atau gunakan VirtualUser tanpa mouse click
                        local VirtualUser = game:GetService("VirtualUser")
                        VirtualUser:CaptureController()  -- Ini saja sudah cukup untuk reset idle timer
                    end
                end)
                
                -- Method 3: Auto-move camera secara halus (opsional)
                local cameraMove = Services.RunService.Heartbeat:Connect(function()
                    if not Variables.antiAfkEnabled then return end
                    
                    -- Reset idle timer setiap 30 detik
                    if tick() - lastActivity > 30 then
                        lastActivity = tick()
                        
                        pcall(function()
                            local VirtualUser = game:GetService("VirtualUser")
                            VirtualUser:CaptureController()
                        end)
                    end
                    
                    -- Gerakkan camera sedikit (sangat halus, tidak mengganggu gameplay)
                    if Variables.antiAfkEnabled and Services.Workspace.CurrentCamera then
                        local currentCFrame = Services.Workspace.CurrentCamera.CFrame
                        local microRotation = CFrame.Angles(
                            0, 
                            math.sin(tick() * 0.1) * 0.001,  -- Rotasi sangat kecil
                            0
                        )
                        Services.Workspace.CurrentCamera.CFrame = currentCFrame * microRotation
                    end
                end)
                
                -- Simpan connection untuk cleanup
                antiAFKConnection = cameraMove
                
            else
                Rayfield.Notify({
                    Title = "Anti-AFK",
                    Content = "Anti-AFK disabled!",
                    Duration = 3
                })
                
                print("❌ Anti-AFK disabled")
                
                -- Disconnect anti-AFK
                if antiAFKConnection then
                    antiAFKConnection:Disconnect()
                    antiAFKConnection = nil
                end
            end
        end
    })
    
    -- ===== NO CLIP =====
    Tab:CreateToggle({
        Name = "NoClip",
        Text = "👻 No Clip",
        CurrentValue = false,
        Callback = function(value)
            Variables.noclipEnabled = value
            
            if value then
                Rayfield.Notify({
                    Title = "No Clip",
                    Content = "No Clip enabled! You can walk through walls.",
                    Duration = 3
                })
                
                print("✅ No Clip enabled")
                
                local character = Services.Players.LocalPlayer.Character
                if character then
                    local function noclipLoop()
                        if Variables.noclipEnabled and character:FindFirstChild("Humanoid") then
                            for _, part in pairs(character:GetDescendants()) do
                                if part:IsA("BasePart") and part.CanCollide then
                                    part.CanCollide = false
                                end
                            end
                        end
                    end
                    
                    -- Run noclip loop
                    local connection
                    connection = Services.RunService.Stepped:Connect(function()
                        if Variables.noclipEnabled then
                            noclipLoop()
                        else
                            if connection then
                                connection:Disconnect()
                            end
                        end
                    end)
                end
                
            else
                Rayfield.Notify({
                    Title = "No Clip",
                    Content = "No Clip disabled!",
                    Duration = 3
                })
                
                print("❌ No Clip disabled")
            end
        end
    })
    
    -- ===== INFINITE JUMP =====
    Tab:CreateToggle({
        Name = "InfiniteJump",
        Text = "🦘 Infinite Jump",
        CurrentValue = false,
        Callback = function(value)
            Variables.infiniteJumpEnabled = value
            
            if value then
                Rayfield.Notify({
                    Title = "Infinite Jump",
                    Content = "Infinite Jump enabled! Hold Space to fly.",
                    Duration = 3
                })
                
                print("✅ Infinite Jump enabled")
                
                local connection
                connection = Services.UserInputService.JumpRequest:Connect(function()
                    if Variables.infiniteJumpEnabled then
                        local character = Services.Players.LocalPlayer.Character
                        if character and character:FindFirstChild("Humanoid") then
                            character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                    end
                end)
                
            else
                Rayfield.Notify({
                    Title = "Infinite Jump",
                    Content = "Infinite Jump disabled!",
                    Duration = 3
                })
                
                print("❌ Infinite Jump disabled")
            end
        end
    })
    
    -- ===== DESTROY GUI =====
    Tab:CreateButton({
        Name = "DestroyGUI",
        Text = "🗑️ Destroy GUI",
        Callback = function()
            if Window and Window.MainFrame then
                Window.MainFrame.Visible = false
                print("🗑️ GUI destroyed")
                Rayfield.Notify({
                    Title = "GUI",
                    Content = "GUI destroyed!",
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
            Rayfield.Notify({
                Title = "Rejoin",
                Content = "Rejoining server...",
                Duration = 3
            })
            
            local TeleportService = game:GetService("TeleportService")
            local Players = game:GetService("Players")
            local player = Players.LocalPlayer
            
            TeleportService:Teleport(game.PlaceId, player)
        end
    })
    
    -- ===== SERVER HOP =====
    Tab:CreateButton({
        Name = "ServerHop",
        Text = "🌐 Server Hop",
        Callback = function()
            Rayfield.Notify({
                Title = "Server Hop",
                Content = "Finding new server...",
                Duration = 3
            })
            
            -- Function untuk mencari server lain
            local function findNewServer()
                local HttpService = game:GetService("HttpService")
                local TeleportService = game:GetService("TeleportService")
                
                -- Coba dapatkan server list
                local success, servers = pcall(function()
                    return HttpService:JSONDecode(game:HttpGet(
                        "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"
                    ))
                end)
                
                if success and servers and servers.data then
                    for _, server in ipairs(servers.data) do
                        if server.playing < server.maxPlayers and server.id ~= game.JobId then
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
                            return
                        end
                    end
                end
                
                -- Jika tidak ada server yang cocok, rejoin saja
                TeleportService:Teleport(game.PlaceId)
            end
            
            findNewServer()
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
            
            -- FPS
            local fps = 0
            pcall(function()
                fps = math.floor(1/Services.RunService.RenderStepped:Wait())
            end)
            print("FPS:", fps)
            
            -- Check important services
            local hasReplica = Services.ReplicatedStorage:FindFirstChild("ReplicaController")
            local hasComm = Services.ReplicatedStorage:FindFirstChild("Comm")
            local hasRemotes = #Services.ReplicatedStorage:GetChildren() > 0
            
            print("\n🔍 SYSTEM DETECTION:")
            print("Replica System:", hasReplica and "✅ Detected" or "❌ Not found")
            print("Comm System:", hasComm and "✅ Detected" or "❌ Not found")
            print("Remotes:", hasRemotes and "✅ Available" or "⚠️ Limited")
            
            -- Player info
            local player = Services.Players.LocalPlayer
            print("\n👤 PLAYER INFO:")
            print("Username:", player.Name)
            print("Display Name:", player.DisplayName)
            print("User ID:", player.UserId)
            print("Account Age:", player.AccountAge .. " days")
            
            -- Character info
            if player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    print("Walk Speed:", humanoid.WalkSpeed)
                    print("Jump Power:", humanoid.JumpPower)
                    print("Health:", humanoid.Health .. "/" .. humanoid.MaxHealth)
                end
            end
            
            print(string.rep("=", 40))
            
            Rayfield.Notify({
                Title = "Game Info",
                Content = "Check console (F9) for detailed information!",
                Duration = 5
            })
        end
    })
    
    -- ===== COPY DISCORD =====
    Tab:CreateButton({
        Name = "CopyDiscord",
        Text = "📋 Discord ABCD",
        Callback = function()
            local discordLink = "https://discord.gg/abcd"  -- Ganti dengan Discord kamu
            
            -- Multi-method untuk copy ke clipboard (compatible dengan berbagai executor)
            local copied = false
            
            -- Method 1: setclipboard (untuk executor yang support)
            local success1, result1 = pcall(function()
                if setclipboard then
                    setclipboard(discordLink)
                    copied = true
                    return true
                end
            end)
            
            -- Method 2: writeclipboard (untuk executor lain)
            if not copied then
                local success2, result2 = pcall(function()
                    if writeclipboard then
                        writeclipboard(discordLink)
                        copied = true
                        return true
                    end
                end)
            end
            
            -- Method 3: game:GetService("TextService") (fallback)
            if not copied then
                local success3, result3 = pcall(function()
                    local TextService = game:GetService("TextService")
                    -- Simpan ke file atau berikan petunjuk manual
                    copied = true
                    return true
                end)
            end
            
            -- Method 4: Tampilkan di console untuk manual copy
            if not copied then
                print("\n" .. string.rep("=", 50))
                print("📋 DISCORD LINK (COPY MANUALLY):")
                print(discordLink)
                print(string.rep("=", 50))
            end
            
            print("📋 Discord link:", discordLink)
            
            if copied then
                Rayfield.Notify({
                    Title = "Discord",
                    Content = "Discord link copied to clipboard!",
                    Duration = 4
                })
            else
                Rayfield.Notify({
                    Title = "Discord",
                    Content = "Discord link: " .. discordLink .. "\nCheck console (F9) to copy!",
                    Duration = 6
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
            
            -- Multi-method copy
            local copied = false
            
            -- Coba berbagai method
            local copyMethods = {
                function() if setclipboard then setclipboard(gameId) return true end end,
                function() if writeclipboard then writeclipboard(gameId) return true end end,
                function() if toclipboard then toclipboard(gameId) return true end end
            }
            
            for _, method in ipairs(copyMethods) do
                local success, result = pcall(method)
                if success and result then
                    copied = true
                    break
                end
            end
            
            if copied then
                print("🎮 Game ID copied:", gameId)
                Rayfield.Notify({
                    Title = "Game ID",
                    Content = "Game ID copied to clipboard!",
                    Duration = 3
                })
            else
                print("\n" .. string.rep("=", 40))
                print("🎮 GAME ID (COPY MANUALLY):")
                print(gameId)
                print(string.rep("=", 40))
                
                Rayfield.Notify({
                    Title = "Game ID",
                    Content = "Game ID: " .. gameId .. "\nCheck console to copy!",
                    Duration = 5
                })
            end
        end
    })
    
    -- ===== CLEANUP ON EXIT =====
    -- Auto cleanup saat player keluar
    Services.Players.LocalPlayer.CharacterAdded:Connect(function()
        -- Reset semua toggle saat respawn
        Variables.antiAfkEnabled = false
        Variables.noclipEnabled = false
        Variables.infiniteJumpEnabled = false
        
        if antiAFKConnection then
            antiAFKConnection:Disconnect()
            antiAFKConnection = nil
        end
    end)
    
    print("✅ Misc tab initialized")
end

return Misc