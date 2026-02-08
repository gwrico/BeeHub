-- ==============================================
-- 👁️ VISUALS TAB MODULE
-- ==============================================

local Visuals = {}

function Visuals.Init(Dependencies)
    local Tab = Dependencies.Tab
    local Shared = Dependencies.Shared
    local Rayfield = Dependencies.Rayfield
    
    local Variables = Shared.Variables
    local Functions = Shared.Functions
    
    print("👁️ Initializing Visuals tab...")
    
    -- ===== ORE ESP =====
    local oreHighlights = {}
    Tab:CreateToggle({
        Name = "OreESP",
        Text = "👁️ Ore ESP",
        CurrentValue = false,
        Callback = function(value)
            Variables.oreESPEnabled = value
            
            if value then
                Rayfield.Notify({
                    Title = "Ore ESP",
                    Content = "Ore ESP enabled!",
                    Duration = 3
                })
                
                print("✅ Ore ESP enabled")
                
                local rarityColors = {
                    [1] = Color3.fromRGB(200, 200, 200),
                    [2] = Color3.fromRGB(0, 200, 0),
                    [3] = Color3.fromRGB(0, 150, 255),
                    [4] = Color3.fromRGB(255, 0, 255),
                    [5] = Color3.fromRGB(255, 165, 0),
                    [6] = Color3.fromRGB(255, 255, 0),
                    [7] = Color3.fromRGB(255, 0, 0),
                    [8] = Color3.new(1, 0.5, 1)
                }
                
                -- Clear existing highlights
                for _, hl in pairs(oreHighlights) do
                    Functions.safeDestroy(hl)
                end
                oreHighlights = {}
                
                local highlighted = 0
                for _, obj in pairs(Shared.Services.Workspace:GetChildren()) do
                    if obj:IsA("BasePart") then
                        for oreName, oreData in pairs(Shared.OreData) do
                            if string.find(obj.Name, oreName) then
                                local highlight = Functions.createHighlight(
                                    obj, 
                                    rarityColors[oreData.rarityId] or Color3.new(1, 1, 1),
                                    0.7
                                )
                                highlight.Name = "OreESP_" .. oreName
                                table.insert(oreHighlights, highlight)
                                highlighted = highlighted + 1
                                break
                            end
                        end
                    end
                end
                
                print("📊 Highlighted", highlighted, "ores")
                
            else
                Rayfield.Notify({
                    Title = "Ore ESP",
                    Content = "Ore ESP disabled!",
                    Duration = 3
                })
                
                print("❌ Ore ESP disabled")
                
                for _, hl in pairs(oreHighlights) do
                    Functions.safeDestroy(hl)
                end
                oreHighlights = {}
            end
        end
    })
    
    -- ===== SIMPLE XRAY =====
    local xrayProcessed = {}
    Tab:CreateToggle({
        Name = "SimpleXRay",
        Text = "🔍 Simple X-Ray",
        CurrentValue = false,
        Callback = function(value)
            Variables.xrayEnabled = value
            
            if value then
                Rayfield.Notify({
                    Title = "Simple X-Ray",
                    Content = "X-Ray enabled! Non-player objects are transparent",
                    Duration = 3
                })
                
                print("✅ Simple X-Ray enabled")
                
                local function makePartTransparent(part)
                    if part:IsA("BasePart") then
                        local isPlayerPart = false
                        
                        for _, player in pairs(Shared.Services.Players:GetPlayers()) do
                            if player.Character and part:IsDescendantOf(player.Character) then
                                isPlayerPart = true
                                break
                            end
                        end
                        
                        if not isPlayerPart then
                            local parent = part.Parent
                            if parent and (parent:IsA("Tool") or parent.Name == "Tool") then
                                isPlayerPart = true
                            end
                        end
                        
                        if not isPlayerPart then
                            local originalProps = {
                                Transparency = part.Transparency,
                                CastShadow = part.CastShadow
                            }
                            
                            part.Transparency = 0.7
                            part.CastShadow = false
                            
                            xrayProcessed[part] = originalProps
                        end
                    end
                end
                
                -- Process existing objects
                for _, obj in pairs(Shared.Services.Workspace:GetDescendants()) do
                    makePartTransparent(obj)
                end
                
                -- Process new objects
                local connection
                connection = Shared.Services.Workspace.DescendantAdded:Connect(function(obj)
                    makePartTransparent(obj)
                end)
                
            else
                Rayfield.Notify({
                    Title = "Simple X-Ray",
                    Content = "X-Ray disabled!",
                    Duration = 3
                })
                
                print("❌ Simple X-Ray disabled")
                
                -- Restore parts
                for part, originalProps in pairs(xrayProcessed) do
                    if part and part.Parent then
                        pcall(function()
                            part.Transparency = originalProps.Transparency
                            part.CastShadow = originalProps.CastShadow
                        end)
                    end
                end
                
                xrayProcessed = {}
            end
        end
    })
    
    -- ===== PLAYER ESP =====
    Tab:CreateToggle({
        Name = "PlayerESP",
        Text = "👤 Player ESP",
        CurrentValue = false,
        Callback = function(value)
            Variables.playerESPEnabled = value
            
            if value then
                Rayfield.Notify({
                    Title = "Player ESP",
                    Content = "Player ESP enabled!",
                    Duration = 3
                })
                
                print("✅ Player ESP enabled")
                
                for _, player in pairs(Shared.Services.Players:GetPlayers()) do
                    if player ~= game.Players.LocalPlayer and player.Character then
                        local highlight = Functions.createHighlight(
                            player.Character,
                            Color3.new(1, 0, 0),
                            0.7
                        )
                        highlight.Name = "PlayerESP_" .. player.Name
                        
                        player.CharacterAdded:Connect(function(char)
                            if Variables.playerESPEnabled then
                                task.wait(1)
                                local newHighlight = Functions.createHighlight(
                                    char,
                                    Color3.new(1, 0, 0),
                                    0.7
                                )
                                newHighlight.Name = "PlayerESP_" .. player.Name
                            end
                        end)
                    end
                end
                
            else
                Rayfield.Notify({
                    Title = "Player ESP",
                    Content = "Player ESP disabled!",
                    Duration = 3
                })
                
                print("❌ Player ESP disabled")
                
                for _, obj in pairs(game.CoreGui:GetChildren()) do
                    if string.find(obj.Name, "PlayerESP_") then
                        Functions.safeDestroy(obj)
                    end
                end
            end
        end
    })
    
    print("✅ Visuals tab initialized")
end

return Visuals
