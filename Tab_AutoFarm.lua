-- ==============================================
-- 💰 AUTO FARM TAB MODULE (PET GAME VERSION)
-- ==============================================

local AutoFarm = {}

function AutoFarm.Init(Dependencies)
    local Tab = Dependencies.Tab
    local Shared = Dependencies.Shared
    local Rayfield = Dependencies.Rayfield
    
    local Variables = Shared.Variables
    local Functions = Shared.Functions or {}
    
    print("💰 Initializing AutoFarm tab (Pets Edition)...")
    
    -- ===== AUTO COLLECT EGGS (TELEPORT VERSION) =====
    local collectConnection = nil
    Tab:CreateToggle({
        Name = "AutoCollect",
        Text = "🥚 Auto Collect Eggs",
        CurrentValue = false,
        Callback = function(value)
            Variables.autoCollectEnabled = value
            
            if value then
                Rayfield.Notify({
                    Title = "Auto Collect",
                    Content = "Auto collecting eggs enabled!",
                    Duration = 3
                })
                
                print("✅ Auto Collect enabled")
                
                -- Start auto collect loop
                collectConnection = Shared.Services.RunService.Heartbeat:Connect(function()
                    if not Variables.autoCollectEnabled then return end
                    
                    local player = game.Players.LocalPlayer
                    local character = player.Character
                    if not character then return end
                    
                    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                    if not humanoidRootPart then return end
                    
                    local playerPos = humanoidRootPart.Position
                    local closestEgg = nil
                    local closestDistance = math.huge
                    local maxDistance = 500  -- Jarak maksimal pencarian
                    
                    -- Cari semua eggs di workspace
                    for _, obj in pairs(Shared.Services.Workspace:GetDescendants()) do
                        -- Cek jika obj adalah egg
                        if obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("Model") then
                            local objName = obj.Name:lower()
                            
                            -- Cek untuk setiap egg dalam EggData
                            for eggName, eggData in pairs(Shared.EggData) do
                                local eggNameLower = eggName:lower()
                                
                                -- Pattern matching yang lebih fleksibel
                                if objName:find(eggNameLower, 1, true) or
                                   objName:find(eggNameLower:gsub(" egg", ""), 1, true) or
                                   objName:find(eggNameLower:gsub(" lucky block", ""), 1, true) then
                                    
                                    -- Dapatkan posisi objek
                                    local objPos
                                    if obj:IsA("Model") then
                                        local primaryPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                                        if primaryPart then
                                            objPos = primaryPart.Position
                                        else
                                            objPos = obj:GetPivot().Position
                                        end
                                    else
                                        objPos = obj.Position
                                    end
                                    
                                    -- Hitung distance
                                    local distance = (playerPos - objPos).Magnitude
                                    
                                    if distance < closestDistance and distance < maxDistance then
                                        closestEgg = obj
                                        closestDistance = distance
                                    end
                                    break
                                end
                            end
                        end
                    end
                    
                    -- Jika ketemu egg terdekat
                    if closestEgg then
                        -- Dapatkan posisi egg
                        local eggPos
                        if closestEgg:IsA("Model") then
                            local primaryPart = closestEgg.PrimaryPart or closestEgg:FindFirstChildWhichIsA("BasePart")
                            eggPos = primaryPart and primaryPart.Position or closestEgg:GetPivot().Position
                        else
                            eggPos = closestEgg.Position
                        end
                        
                        -- Teleport ke posisi egg (sedikit di atas)
                        local targetPos = eggPos + Vector3.new(0, 3, 0)
                        humanoidRootPart.CFrame = CFrame.new(targetPos)
                        
                        -- Cari ProximityPrompt untuk collect
                        task.wait(0.2)  -- Tunggu sebentar setelah teleport
                        
                        local prompt = closestEgg:FindFirstChildOfClass("ProximityPrompt") or
                                      closestEgg.Parent:FindFirstChildOfClass("ProximityPrompt") or
                                      closestEgg:FindFirstAncestorOfClass("ProximityPrompt")
                        
                        if prompt then
                            fireproximityprompt(prompt)
                            print("📦 Collected:", closestEgg.Name, "| Distance:", math.floor(closestDistance))
                            
                            -- Tunggu sebentar setelah collect
                            task.wait(0.5)
                        else
                            print("⚠️ No ProximityPrompt found for:", closestEgg.Name)
                        end
                    else
                        -- Jika tidak ada egg dalam range, coba gerakkan random
                        if math.random(1, 100) > 80 then  -- 20% chance
                            local randomPos = playerPos + Vector3.new(
                                math.random(-50, 50),
                                0,
                                math.random(-50, 50)
                            )
                            humanoidRootPart.CFrame = CFrame.new(randomPos)
                            print("🔍 Searching for eggs...")
                        end
                    end
                end)
                
            else
                Rayfield.Notify({
                    Title = "Auto Collect",
                    Content = "Auto collecting disabled!",
                    Duration = 3
                })
                
                print("❌ Auto Collect disabled")
                
                -- Stop connection
                if collectConnection then
                    collectConnection:Disconnect()
                    collectConnection = nil
                end
            end
        end
    })
    
    -- ===== AUTO HATCH EGGS =====
    Tab:CreateToggle({
        Name = "AutoHatch",
        Text = "🐣 Auto Hatch Eggs",
        CurrentValue = false,
        Callback = function(value)
            Variables.autoHatchEnabled = value
            
            if value then
                Rayfield.Notify({
                    Title = "Auto Hatch",
                    Content = "Auto hatching enabled!",
                    Duration = 3
                })
                
                print("✅ Auto Hatch enabled")
                
                -- Simple auto hatch (sesuaikan dengan UI game)
                spawn(function()
                    while Variables.autoHatchEnabled do
                        -- Cari hatch button di ScreenGui
                        local gui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
                        if gui then
                            -- Cari button "Hatch", "Open", "Buy", etc
                            local hatchButtons = {
                                "HatchButton", "Hatch", "OpenButton", "Open",
                                "BuyButton", "Purchase", "EggButton"
                            }
                            
                            for _, btnName in pairs(hatchButtons) do
                                local button = findButtonRecursive(gui, btnName)
                                if button and button:IsA("TextButton") or button:IsA("ImageButton") then
                                    -- Click button
                                    fireclickdetector(button:FindFirstChildOfClass("ClickDetector"))
                                    or button:Fire("Activated")
                                    or (button:FindFirstChild("MouseClick") and button.MouseClick:Fire())
                                    
                                    print("🥚 Clicked hatch button:", btnName)
                                    break
                                end
                            end
                        end
                        
                        task.wait(5)  -- Delay 5 detik antar hatch
                    end
                end)
                
            else
                Rayfield.Notify({
                    Title = "Auto Hatch",
                    Content = "Auto hatching disabled!",
                    Duration = 3
                })
                
                print("❌ Auto Hatch disabled")
            end
        end
    })
    
    -- ===== FAST TELEPORT (UNTUK EXPLORASI CEPAT) =====
    Tab:CreateToggle({
        Name = "FastTeleport",
        Text = "⚡ Fast Teleport Mode",
        CurrentValue = false,
        Callback = function(value)
            Variables.fastTeleportEnabled = value
            
            if value then
                Rayfield.Notify({
                    Title = "Fast Teleport",
                    Content = "Fast teleport enabled! Move 2x faster",
                    Duration = 3
                })
                
                print("✅ Fast Teleport enabled")
                
                -- Modifikasi WalkSpeed untuk teleport lebih cepat
                local character = game.Players.LocalPlayer.Character
                if character then
                    local humanoid = character:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid.WalkSpeed = 50  -- 2-3x lebih cepat dari normal
                    end
                end
                
            else
                Rayfield.Notify({
                    Title = "Fast Teleport",
                    Content = "Fast teleport disabled!",
                    Duration = 3
                })
                
                print("❌ Fast Teleport disabled")
                
                -- Reset WalkSpeed
                local character = game.Players.LocalPlayer.Character
                if character then
                    local humanoid = character:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid.WalkSpeed = 16  -- Default speed
                    end
                end
            end
        end
    })
    
    -- ===== COLLECT ALL NEARBY EGGS (ONE-TIME) =====
    Tab:CreateButton({
        Name = "Collect Nearby Eggs",
        Text = "🌀 Collect Nearby Eggs",
        Callback = function()
            print("🌀 Collecting all nearby eggs...")
            
            local collected = 0
            local player = game.Players.LocalPlayer
            local character = player.Character
            if not character then return end
            
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then return end
            
            local playerPos = humanoidRootPart.Position
            
            -- Kumpulkan semua eggs dalam radius
            for _, obj in pairs(Shared.Services.Workspace:GetDescendants()) do
                if obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("Model") then
                    for eggName, _ in pairs(Shared.EggData) do
                        if obj.Name:lower():find(eggName:lower(), 1, true) then
                            -- Dapatkan posisi objek
                            local objPos
                            if obj:IsA("Model") then
                                local primaryPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                                objPos = primaryPart and primaryPart.Position or obj:GetPivot().Position
                            else
                                objPos = obj.Position
                            end
                            
                            -- Cek jika dalam radius 100 studs
                            local distance = (playerPos - objPos).Magnitude
                            if distance < 100 then
                                -- Teleport ke egg
                                humanoidRootPart.CFrame = CFrame.new(objPos + Vector3.new(0, 3, 0))
                                task.wait(0.1)
                                
                                -- Coba collect
                                local prompt = obj:FindFirstChildOfClass("ProximityPrompt") or
                                              obj.Parent:FindFirstChildOfClass("ProximityPrompt")
                                
                                if prompt then
                                    fireproximityprompt(prompt)
                                    collected = collected + 1
                                    print("📦 Collected nearby:", obj.Name)
                                    task.wait(0.2)
                                end
                            end
                            break
                        end
                    end
                end
            end
            
            Rayfield.Notify({
                Title = "Collection Complete",
                Content = "Collected " .. collected .. " nearby eggs!",
                Duration = 5
            })
            
            print("🎉 Total collected:", collected, "eggs")
        end
    })
    
    -- Helper function untuk mencari button
    local function findButtonRecursive(parent, buttonName)
        for _, child in pairs(parent:GetChildren()) do
            if (child.Name:lower():find(buttonName:lower(), 1, true) or 
                (child:IsA("TextButton") and child.Text:lower():find(buttonName:lower(), 1, true))) then
                return child
            end
            
            if #child:GetChildren() > 0 then
                local found = findButtonRecursive(child, buttonName)
                if found then return found end
            end
        end
        return nil
    end
    
    print("✅ AutoFarm tab initialized (Pets Edition)")
end

return AutoFarm