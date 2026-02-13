-- [[ ⚡ WEX HUB | v1.1 - TEAM CHECK REMOVED ]] --
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ 1. BAŞLATMA VE TEMİZLİK ]] --
if game.CoreGui:FindFirstChild("Rayfield") then
    game.CoreGui.Rayfield:Destroy()
end

-- [[ 2. GLOBAL DEĞİŞKENLER ]] --
_G.AimbotEnabled = false
_G.AimbotSmoothness = 0.5
_G.AimbotFOV = 150
_G.ShowFOV = false
_G.AimPart = "Head"

_G.ESP_Enabled = false
_G.Tracers_Enabled = false
_G.ShowHP = false

_G.SpinBot = false
_G.SpinSpeed = 50
_G.InfJump = false
_G.ClickTP = false

-- FOV Dairesi Çizimi
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(0, 255, 255)
FOVCircle.Transparency = 0.7
FOVCircle.Visible = false

-- [[ 3. MENÜ KURULUMU ]] --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "⚡ Wex Hub | v1.1",
   LoadingTitle = "Wex Hub",
   LoadingSubtitle = "İyi oyunlar...legit oyna!",
   ConfigurationSaving = {Enabled = false}
})

local Tab_Aim = Window:CreateTab("🎯 Combat")
local Tab_Vis = Window:CreateTab("👁️ Visual")
local Tab_Knix = Window:CreateTab("🌪️ Knix")

-- [[ 🎯 COMBAT SEKMESİ ]] --
Tab_Aim:CreateSection("Aimbot Kontrolleri")
Tab_Aim:CreateToggle({Name = "Aimbot Aktif (Sağ Tık)", CurrentValue = false, Callback = function(v) _G.AimbotEnabled = v end})
Tab_Aim:CreateToggle({Name = "FOV Dairesini Göster", CurrentValue = false, Callback = function(v) _G.ShowFOV = v end})
Tab_Aim:CreateSlider({Name = "Aimbot Menzili (FOV)", Range = {50, 800}, Increment = 10, CurrentValue = 150, Callback = function(v) _G.AimbotFOV = v end})
Tab_Aim:CreateSlider({Name = "Yumuşaklık (Smoothness)", Range = {0, 10}, Increment = 1, CurrentValue = 5, Callback = function(v) _G.AimbotSmoothness = v / 10 end})

-- [[ 👁️ VISUAL SEKMESİ ]] --
Tab_Vis:CreateSection("Görünürlük")
Tab_Vis:CreateToggle({Name = "Player ESP (Highlight)", CurrentValue = false, Callback = function(v) _G.ESP_Enabled = v end})
Tab_Vis:CreateToggle({Name = "Tracers (Çizgiler)", CurrentValue = false, Callback = function(v) _G.Tracers_Enabled = v end})
Tab_Vis:CreateToggle({Name = "Oyuncu HP", CurrentValue = false, Callback = function(v) _G.ShowHP = v end})

-- [[ 🌪️ KNIX SEKMESİ ]] --
Tab_Knix:CreateSection("Hareket ve Spin")
Tab_Knix:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Callback = function(v) _G.InfJump = v end})
Tab_Knix:CreateToggle({Name = "Click TP (Ctrl + Sol Tık)", CurrentValue = false, Callback = function(v) _G.ClickTP = v end})
Tab_Knix:CreateToggle({Name = "Spin Bot", CurrentValue = false, Callback = function(v) _G.SpinBot = v end})
Tab_Knix:CreateSlider({Name = "Spin Hızı", Range = {10, 300}, Increment = 5, CurrentValue = 50, Callback = function(v) _G.SpinSpeed = v end})

-- [[ 🛠️ YARDIMCI SİSTEMLER ]] --

-- Click TP
UserInputService.InputBegan:Connect(function(input)
    if _G.ClickTP and input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        local mouse = LP:GetMouse()
        if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            LP.Character.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.p + Vector3.new(0, 3, 0))
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if _G.InfJump and LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid:ChangeState("Jumping")
    end
end)

local function GetClosestPlayer()
    local target = nil
    local dist = _G.AimbotFOV
    for _, v in pairs(Players:GetPlayers()) do
        -- isEnemy kontrolü kaldırıldı, herkes taranıyor
        if v ~= LP and v.Character and v.Character:FindFirstChild(_G.AimPart) then
            local hum = v.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(v.Character[_G.AimPart].Position)
                if onScreen then
                    local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if magnitude < dist then
                        target = v
                        dist = magnitude
                    end
                end
            end
        end
    end
    return target
end

-- [[ 🔄 ANA DÖNGÜ ]] --
local tracers = {}

RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = _G.ShowFOV
    FOVCircle.Radius = _G.AimbotFOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- SpinBot
    if _G.SpinBot and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.CFrame = LP.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(_G.SpinSpeed), 0)
    end

    -- Aimbot
    if _G.AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestPlayer()
        if target then
            local targetPos = Camera:WorldToViewportPoint(target.Character[_G.AimPart].Position)
            local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            mousemoverel((targetPos.X - mousePos.X) * _G.AimbotSmoothness, (targetPos.Y - mousePos.Y) * _G.AimbotSmoothness)
        end
    end

    -- Visuals (ESP, HP, Tracers)
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LP then
            local char = v.Character
            if char then
                -- 1. ESP Highlight
                local hl = char:FindFirstChild("WexHL")
                if _G.ESP_Enabled then
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = "WexHL"
                        hl.Parent = char
                        hl.FillColor = Color3.fromRGB(255, 0, 0)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.5
                    end
                else
                    if hl then hl:Destroy() end
                end

                -- 2. HP Tag
                local head = char:FindFirstChild("Head")
                if head then
                    local tag = head:FindFirstChild("WexHP")
                    if _G.ShowHP then
                        if not tag then
                            tag = Instance.new("BillboardGui", head)
                            tag.Name = "WexHP"
                            tag.Size = UDim2.new(0, 50, 0, 20)
                            tag.AlwaysOnTop = true
                            tag.ExtentsOffset = Vector3.new(0, 3, 0)
                            local l = Instance.new("TextLabel", tag)
                            l.Name = "Label"
                            l.BackgroundTransparency = 1
                            l.Size = UDim2.new(1, 0, 1, 0)
                            l.Font = Enum.Font.GothamBold
                            l.TextSize = 14
                            l.TextColor3 = Color3.new(0, 1, 0)
                        end
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        tag.Label.Text = hum and "HP: " .. math.floor(hum.Health) or "HP: 0"
                    else
                        if tag then tag:Destroy() end
                    end
                end

                -- 3. Tracers
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if _G.Tracers_Enabled and onScreen then
                        local tr = tracers[v] or Drawing.new("Line")
                        tracers[v] = tr
                        tr.Visible = true
                        tr.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        tr.To = Vector2.new(pos.X, pos.Y)
                        tr.Color = Color3.fromRGB(255, 255, 255)
                        tr.Thickness = 1
                    else
                        if tracers[v] then tracers[v].Visible = false end
                    end
                end
            end
        end
    end
end)

Rayfield:Notify({Title="⚡ Wex Hub", Content="Team Check Devre Dışı Bırakıldı!", Duration=3})
