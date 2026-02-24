-- ==============================================
-- 👁️ VISUALS TAB MODULE - COMPATIBLE WITH SIMPLEGUI v6.3
-- ==============================================

local Visuals = {}

function Visuals.Init(Dependencies)
    local Tab = Dependencies.Tab
    local Shared = Dependencies.Shared
    local Bdev = Dependencies.Bdev
    
    local Variables = Shared.Variables
    local Functions = Shared.Functions or {}
    
    --print("👁️ Initializing Visuals tab for SimpleGUI v6.3...")
    
    -- ===== X-RAY VISION =====
    local xrayParts = {}
    local xrayConnection = nil
    
    Tab:CreateToggle({
        Name = "XRay",
        Text = "🔍 X-Ray Vision",
        CurrentValue = false,
        Callback = function(value)
            Variables.xrayEnabled = value
            
            if value then
                Bdev:Notify({  -- ✅ FIXED: Colon syntax
                    Title = "X-Ray",
                    Content = "X-Ray enabled! See through walls",
                    Duration = 3
                })
                
                --print("✅ X-Ray enabled")
                
                local function processPart(part)
                    if part:IsA("BasePart") then
                        -- Check if part belongs to a player
                        local isPlayerPart = false
                        for _, player in pairs(Shared.Services.Players:GetPlayers()) do
                            if player.Character and part:IsDescendantOf(player.Character) then
                                isPlayerPart = true
                                break
                            end
                        end
                        
                        if not isPlayerPart then
                            -- Save original properties
                            xrayParts[part] = {
                                Transparency = part.Transparency,
                                CastShadow = part.CastShadow
                            }
                            
                            -- Make transparent
                            part.Transparency = 0.7
                            part.CastShadow = false
                        end
                    end
                end
                
                -- Process existing parts
                for _, part in pairs(Shared.Services.Workspace:GetDescendants()) do
                    processPart(part)
                end
                
                -- Connect to new parts
                if xrayConnection then
                    xrayConnection:Disconnect()
                end
                
                xrayConnection = Shared.Services.Workspace.DescendantAdded:Connect(function(descendant)
                    if Variables.xrayEnabled then
                        processPart(descendant)
                    end
                end)
                
            else
                Bdev:Notify({  -- ✅ FIXED: Colon syntax
                    Title = "X-Ray",
                    Content = "X-Ray disabled!",
                    Duration = 3
                })
                
                --print("❌ X-Ray disabled")
                
                -- Restore original properties
                for part, props in pairs(xrayParts) do
                    if part and part.Parent then
                        pcall(function()
                            part.Transparency = props.Transparency
                            part.CastShadow = props.CastShadow
                        end)
                    end
                end
                
                xrayParts = {}
                
                if xrayConnection then
                    xrayConnection:Disconnect()
                    xrayConnection = nil
                end
            end
        end
    })
    
    -- ===== PLAYER ESP =====
    local playerHighlights = {}
    
    Tab:CreateToggle({
        Name = "PlayerESP",
        Text = "👤 Player ESP",
        CurrentValue = false,
        Callback = function(value)
            Variables.playerESPEnabled = value
            
            if value then
                Bdev:Notify({  -- ✅ FIXED: Colon syntax
                    Title = "Player ESP",
                    Content = "Player ESP enabled!",
                    Duration = 3
                })
                
                --print("✅ Player ESP enabled")
                
                local function highlightPlayer(player, character)
                    if not character or player == game.Players.LocalPlayer then
                        return
                    end
                    
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "PlayerESP_" .. player.Name
                    highlight.Adornee = character
                    highlight.FillColor = Color3.new(0, 0.5, 1)  -- Blue
                    highlight.FillTransparency = 0.7
                    highlight.OutlineColor = Color3.new(1, 1, 1)
                    highlight.OutlineTransparency = 0
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.Parent = game:GetService("CoreGui")
                    
                    playerHighlights[player] = highlight
                end
                
                -- Highlight existing players
                for _, player in pairs(Shared.Services.Players:GetPlayers()) do
                    if player.Character then
                        highlightPlayer(player, player.Character)
                    end
                    
                    -- Connect to character added
                    player.CharacterAdded:Connect(function(character)
                        if Variables.playerESPEnabled then
                            task.wait(1)  -- Wait for character to load
                            highlightPlayer(player, character)
                        end
                    end)
                end
                
            else
                Bdev:Notify({  -- ✅ FIXED: Colon syntax
                    Title = "Player ESP",
                    Content = "Player ESP disabled!",
                    Duration = 3
                })
                
                --print("❌ Player ESP disabled")
                
                -- Remove highlights
                for _, highlight in pairs(playerHighlights) do
                    if highlight and highlight.Parent then
                        pcall(function()
                            highlight:Destroy()
                        end)
                    end
                end
                playerHighlights = {}
                
                -- Also clean from CoreGui
                local CoreGui = game:GetService("CoreGui")
                for _, obj in pairs(CoreGui:GetChildren()) do
                    if obj.Name:find("PlayerESP_") then
                        pcall(function()
                            obj:Destroy()
                        end)
                    end
                end
            end
        end
    })
    
    -- ===== AUTO REFRESH ESP =====
    Tab:CreateButton({
        Name = "RefreshESP",
        Text = "🔄 Refresh ESP",
        Callback = function()
            if Variables.playerESPEnabled then
                -- Turn off then on to refresh
                Variables.playerESPEnabled = false
                task.wait(0.1)
                Variables.playerESPEnabled = true
                
                Bdev:Notify({
                    Title = "ESP",
                    Content = "ESP refreshed!",
                    Duration = 3
                })
                --print("🔄 ESP refreshed")
            else
                Bdev:Notify({
                    Title = "ESP",
                    Content = "Turn on ESP first!",
                    Duration = 3
                })
            end
        end
    })
    
    -- ===== CLEAR ALL VISUALS =====
    Tab:CreateButton({
        Name = "ClearVisuals",
        Text = "🧹 Clear All Visuals",
        Callback = function()
            -- Disable all toggles
            Variables.xrayEnabled = false
            Variables.playerESPEnabled = false
            
            -- Clean X-Ray
            for part, props in pairs(xrayParts) do
                if part and part.Parent then
                    pcall(function()
                        part.Transparency = props.Transparency
                        part.CastShadow = props.CastShadow
                    end)
                end
            end
            xrayParts = {}
            
            if xrayConnection then
                xrayConnection:Disconnect()
                xrayConnection = nil
            end
            
            -- Clean Player ESP highlights
            for _, hl in pairs(playerHighlights) do
                if hl and hl.Parent then
                    pcall(function()
                        hl:Destroy()
                    end)
                end
            end
            playerHighlights = {}
            
            -- Clean CoreGui
            local CoreGui = game:GetService("CoreGui")
            for _, obj in pairs(CoreGui:GetChildren()) do
                if obj.Name:find("PlayerESP_") then
                    pcall(function()
                        obj:Destroy()
                    end)
                end
            end
            
            Bdev:Notify({
                Title = "Visuals",
                Content = "All visuals cleared!",
                Duration = 3
            })
            
            --print("🧹 All visuals cleared")
        end
    })
    
    -- ===== VISUALS SETTINGS =====
    Tab:CreateLabel({
        Name = "SettingsLabel",
        Text = "⚙️ ESP Settings:",
        Alignment = Enum.TextXAlignment.Center
    })
    
    local espTransparency = 0.7
    local espColor = Color3.new(0, 0.5, 1)
    
    Tab:CreateSlider({
        Name = "ESPTransparency",
        Text = "Transparency: " .. espTransparency,
        Range = {0.1, 0.9},
        Increment = 0.1,
        CurrentValue = 0.7,
        Callback = function(value)
            espTransparency = value
            --print("📊 ESP Transparency set to:", value)
            
            -- Apply to existing ESP if enabled
            if Variables.playerESPEnabled then
                Bdev:Notify({
                    Title = "Settings",
                    Content = "Change will apply after ESP refresh",
                    Duration = 3
                })
            end
        end
    })
    
    --print("✅ Visuals tab initialized")
end

return Visuals