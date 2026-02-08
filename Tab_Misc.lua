-- ==============================================
-- ⚡ MISC TAB MODULE
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
    
    -- ===== GET ALL TOOLS =====
    Tab:CreateButton({
        Name = "GetAllTools",
        Text = "🛠️ Get All Tools",
        Callback = function()
            local toolsFound = 0
            for _, obj in pairs(game:GetDescendants()) do
                if obj:IsA("Tool") then
                    local clone = obj:Clone()
                    clone.Parent = game.Players.LocalPlayer.Backpack
                    toolsFound = toolsFound + 1
                end
            end
            print("🛠️ Cloned", toolsFound, "tools to backpack")
            Rayfield.Notify({
                Title = "Tools",
                Content = "Cloned " .. toolsFound .. " tools!",
                Duration = 4
            })
        end
    })
    
    -- ===== ANTI-AFK =====
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
                
                local connection
                connection = Services.RunService.Heartbeat:Connect(function()
                    if not Variables.antiAfkEnabled then return end
                    
                    pcall(function()
                        local VirtualUser = game:GetService("VirtualUser")
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton2(Vector2.new(math.random(0, 100), math.random(0, 100)))
                    end)
                end)
                
                Services.Players.LocalPlayer.Idled:Connect(function()
                    if Variables.antiAfkEnabled then
                        local VirtualUser = game:GetService("VirtualUser")
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton2(Vector2.new(0, 0))
                    end
                end)
                
            else
                Rayfield.Notify({
                    Title = "Anti-AFK",
                    Content = "Anti-AFK disabled!",
                    Duration = 3
                })
                
                print("❌ Anti-AFK disabled")
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
    
    -- ===== GAME INFO =====
    Tab:CreateButton({
        Name = "GameInfo",
        Text = "📊 Game Info",
        Callback = function()
            print("\n=== GAME INFORMATION ===")
            print("Place ID:", game.PlaceId)
            print("Game Name:", game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
            print("Players:", #Services.Players:GetPlayers())
            print("FPS:", math.floor(1/Services.RunService.RenderStepped:Wait()))
            
            local hasReplica = Services.ReplicatedStorage:FindFirstChild("ReplicaController")
            local hasComm = Services.ReplicatedStorage:FindFirstChild("Comm")
            
            print("Replica System:", hasReplica and "✅" or "❌")
            print("Comm System:", hasComm and "✅" or "❌")
            
            Rayfield.Notify({
                Title = "Game Info",
                Content = "Check console for game information!",
                Duration = 4
            })
        end
    })
    
    print("✅ Misc tab initialized")
end

return Misc
