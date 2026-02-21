-- ==============================================
-- 🔧 UTILITIES TAB MODULE
-- ==============================================

local Utilities = {}

function Utilities.Init(Dependencies)
    local Tab = Dependencies.Tab
    local Shared = Dependencies.Shared
    local Bdev = Dependencies.Bdev
    local Window = Dependencies.Window
    local GUI = Dependencies.GUI
    
    local Services = Shared.Services
    
    --print("🔧 Initializing Utilities tab...")
    
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
                --print("🗑️ GUI destroyed")
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
            --print("\n" .. string.rep("=", 40))
            --print("📊 GAME INFORMATION")
            --print(string.rep("=", 40))
            
            -- Basic info
            --print("Place ID:", game.PlaceId)
            
            local productInfo = {Name = "Unknown"}
            pcall(function()
                productInfo = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
            end)
            --print("Game Name:", productInfo.Name)
            
            --print("Players:", #Services.Players:GetPlayers() .. "/" .. game.Players.MaxPlayers)
            
            -- Player info
            local player = Services.Players.LocalPlayer
            --print("\n👤 PLAYER INFO:")
            --print("Username:", player.Name)
            --print("Display Name:", player.DisplayName)
            --print("User ID:", player.UserId)
            
            -- Character info
            if player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    --print("Walk Speed:", humanoid.WalkSpeed)
                    --print("Jump Power:", humanoid.JumpPower)
                end
            end
            
            -- Check BeeHub system
            --print("\n🐝 BEEHUB SYSTEM:")
            --print("Version: v4.0")
            --print("SimpleGUI: v6.3")
            --print("Loaded Tabs:", #Shared.Tabs)
            
            --print(string.rep("=", 40))
            
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
            local discordLink = "https://discord.gg/abcd"
            
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
                --print("📋 Discord link copied:", discordLink)
            else
                --print("\n" .. string.rep("=", 50))
                --print("📋 DISCORD LINK (COPY MANUALLY):")
                --print(discordLink)
                --print(string.rep("=", 50))
                
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
                --print("🎮 Game ID copied:", gameId)
            else
                --print("\n" .. string.rep("=", 40))
                --print("🎮 GAME ID:", gameId)
                --print(string.rep("=", 40))
                
                Bdev:Notify({
                    Title = "Game ID",
                    Content = "Game ID: " .. gameId,
                    Duration = 4
                })
            end
        end
    })
    
    --print("✅ Utilities tab initialized")
end

return Utilities