-- ==============================================
-- 🔧 CORE SHARED FUNCTIONS & UTILITIES - UPDATED
-- ==============================================

local Core = {}

-- Initialize shared functions
function Core.Init(Shared)
    --print("🔧 Initializing core functions...")
    
    -- Make functions available in Shared
    Shared.Functions = {
        -- Tool management
        checkToolEquipped = function()
            local player = game.Players.LocalPlayer
            local character = player.Character
            if not character then return false end
            
            local tool = character:FindFirstChildOfClass("Tool")
            if tool then
                Shared.Variables.toolEquipped = true
                return true
            end
            
            for _, item in pairs(player.Backpack:GetChildren()) do
                if item:IsA("Tool") then
                    Shared.Variables.toolEquipped = true
                    return true
                end
            end
            
            Shared.Variables.toolEquipped = false
            return false
        end,
        
        autoEquipTool = function()
            local player = game.Players.LocalPlayer
            local character = player.Character
            if not character then return false end
            
            local humanoid = character:FindFirstChild("Humanoid")
            if not humanoid then return false end
            
            for _, tool in pairs(player.Backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    humanoid:EquipTool(tool)
                    Shared.Variables.toolEquipped = true
                    --print("🛠️ Auto-equipped tool:", tool.Name)
                    return true
                end
            end
            
            return false
        end,
        
        -- Punch/Mine functions
        performPunch = function()
            local player = game.Players.LocalPlayer
            local character = player.Character
            if not character then return false end
            
            -- Method 1: Tool activation
            local tool = character:FindFirstChildOfClass("Tool")
            if tool then
                local success, err = pcall(function()
                    tool:Activate()
                end)
                if success then
                    return true
                else
                    --print("⚠️ Tool activation failed:", err)
                end
            end
            
            -- Method 2: Virtual mouse click
            local vim = Shared.Services.VirtualInputManager
            local success, err = pcall(function()
                vim:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                task.wait(0.05)
                vim:SendMouseButtonEvent(0, 0, 0, false, game, 1)
            end)
            
            if success then
                return true
            else
                --print("⚠️ Virtual mouse click failed:", err)
                
                -- Method 3: Alternative - E key
                pcall(function()
                    vim:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(0.05)
                    vim:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                end)
                
                return true
            end
        end,
        
        -- Teleport functions
        teleportToPosition = function(position)
            local player = game.Players.LocalPlayer
            local character = player.Character
            if not character then return false end
            
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then return false end
            
            humanoidRootPart.CFrame = CFrame.new(position)
            return true
        end,
        
        -- ✅ UPDATED: findClosestEgg (bukan Ore)
        findClosestEgg = function(maxDistance)
            local player = game.Players.LocalPlayer
            local character = player.Character
            if not character then return nil, math.huge end
            
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then return nil, math.huge end
            
            local playerPos = humanoidRootPart.Position
            local closestEgg = nil
            local closestDistance = math.huge
            
            -- Search in workspace
            for _, obj in pairs(Shared.Services.Workspace:GetChildren()) do
                if obj:IsA("Model") or obj:IsA("BasePart") then
                    local distance = (playerPos - obj.Position).Magnitude
                    if distance < maxDistance then
                        -- Check if it's an egg
                        for eggName, _ in pairs(Shared.EggData) do
                            if obj.Name:find(eggName) then
                                if distance < closestDistance then
                                    closestEgg = obj
                                    closestDistance = distance
                                    break
                                end
                            end
                        end
                    end
                end
            end
            
            return closestEgg, closestDistance
        end,
        
        -- ✅ NEW: findClosestBlock
        findClosestBlock = function(maxDistance)
            local player = game.Players.LocalPlayer
            local character = player.Character
            if not character then return nil, math.huge end
            
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then return nil, math.huge end
            
            local playerPos = humanoidRootPart.Position
            local closestBlock = nil
            local closestDistance = math.huge
            
            for _, obj in pairs(Shared.Services.Workspace:GetChildren()) do
                if obj:IsA("Model") or obj:IsA("BasePart") then
                    local distance = (playerPos - obj.Position).Magnitude
                    if distance < maxDistance then
                        -- Check if it's a block (lucky block, etc)
                        if obj.Name:find("Block") or obj.Name:find("Lucky") then
                            if distance < closestDistance then
                                closestBlock = obj
                                closestDistance = distance
                            end
                        end
                    end
                end
            end
            
            return closestBlock, closestDistance
        end,
        
        -- Utility functions
        formatNumber = function(num)
            if num >= 1000000 then
                return string.format("%.1fM", num / 1000000)
            elseif num >= 1000 then
                return string.format("%.1fK", num / 1000)
            else
                return tostring(math.floor(num))
            end
        end,
        
        createHighlight = function(object, color, transparency)
            local highlight = Instance.new("Highlight")
            highlight.Name = "BeeHub_Highlight"
            highlight.FillColor = color or Color3.new(1, 0, 0)
            highlight.OutlineColor = Color3.new(1, 1, 1)
            highlight.FillTransparency = transparency or 0.7
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Adornee = object
            highlight.Parent = game.CoreGui
            return highlight
        end,
        
        -- Connection management
        safeDisconnect = function(connection)
            if connection and typeof(connection) == "RBXScriptConnection" then
                connection:Disconnect()
            end
            return nil
        end,
        
        safeDestroy = function(object)
            if object and object.Parent then
                pcall(function()
                    object:Destroy()
                end)
            end
        end,
        
        -- ✅ NEW: Auto-hatch function (placeholder)
        performHatch = function()
            local player = game.Players.LocalPlayer
            local character = player.Character
            if not character then return false end
            
            -- This would need game-specific implementation
            --print("🥚 Hatching function called - needs game-specific code")
            
            -- Try common hatch methods
            local vim = Shared.Services.VirtualInputManager
            
            -- Method 1: Press H key (common for hatch)
            pcall(function()
                vim:SendKeyEvent(true, Enum.KeyCode.H, false, game)
                task.wait(0.1)
                vim:SendKeyEvent(false, Enum.KeyCode.H, false, game)
            end)
            
            -- Method 2: Click hatch button
            pcall(function()
                vim:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                task.wait(0.05)
                vim:SendMouseButtonEvent(0, 0, 0, false, game, 1)
            end)
            
            return true
        end
    }
    
    --print("✅ Core functions initialized (Egg Edition)")
end

return Core