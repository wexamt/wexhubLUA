-- [[ ⚡ WEX HUB | v1.2 - RAGE & FLY UPDATE ]] --
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
_G.AimbotSmoothness = 0 -- 0 = Anında Kilitlenme (Rage)
_G.AimbotFOV = 150
_G.ShowFOV = false
_G.AimPart = "Head"

_G.ESP_Enabled = false
_G.Tracers_Enabled = false
_G.ShowHP = false

_G.SpinBot = false
_G.SpinSpeed = 100
_G.InfJump = false
_G.ClickTP = false

-- Fly Değişkenleri
local Flying = false
local FlySpeed = 50
local BV, BG

-- FOV Dairesi
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Transparency = 0.7
FOVCircle.Visible = false

-- [[ 3. MENÜ KURULUMU ]] --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "⚡ Wex Hub | v1.2 RAGE",
   LoadingTitle = "Wex Hub Loading...",
   LoadingSubtitle = "Hazırlanıyor, ortalığı dağıtmaya hazır ol!",
   ConfigurationSaving = {Enabled = false}
})

local Tab_Aim = Window:CreateTab("🎯 Combat")
local Tab_Fly = Window:CreateTab("🚀 Movement")
local Tab_Vis = Window:CreateTab("👁️ Visual")

-- [[ 🎯 COMBAT SEKMESİ ]] --
Tab_Aim:CreateSection("Aimbot (Anında Kilitlenme)")
Tab_Aim:CreateToggle({Name = "Aimbot Aktif (Sağ Tık)", CurrentValue = false, Callback = function(v) _G.AimbotEnabled = v end})
Tab_Aim:CreateToggle({Name = "FOV Dairesini Göster", CurrentValue = false, Callback = function(v) _G.ShowFOV = v end})
Tab_Aim:CreateSlider({Name = "Aimbot Menzili", Range = {50, 1000}, Increment = 10, CurrentValue = 150, Callback = function(v) _G.AimbotFOV = v end})
Tab_Aim:CreateSlider({Name = "Smoothness (0 = Rage)", Range = {0, 10}, Increment = 1, CurrentValue = 0, Callback = function(v) _G.AimbotSmoothness = v / 10 end})

-- [[ 🚀 MOVEMENT SEKMESİ ]] --
Tab_Fly:CreateSection("Uçuş ve Hız")
Tab_Fly:CreateToggle({Name = "Fly (Uçma)", CurrentValue = false, Callback = function(v) 
    Flying = v 
    if v then
        local Root = LP.Character:FindFirstChild("HumanoidRootPart")
        if Root then
            BG = Instance.new("BodyGyro", Root)
            BG.P = 9e4
            BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            BG.cframe = Root.CFrame
            BV = Instance.new("BodyVelocity", Root)
            BV.velocity = Vector3.new(0, 0.1, 0)
            BV.maxForce = Vector3.new(9e9, 9e9, 9e9)
            
            task.spawn(function()
                while Flying do
                    LP.Character.Humanoid.PlatformStand = true
                    local v = Vector3.new(0, 0.1, 0)
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then v = v + (Camera.CFrame.LookVector * FlySpeed) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then v = v - (Camera.CFrame.LookVector * FlySpeed) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then v = v - (Camera.CFrame.RightVector * FlySpeed) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then v = v + (Camera.CFrame.RightVector * FlySpeed) end
                    BV.velocity = v
                    BG.cframe = Camera.CFrame
                    task.wait()
                end
                if BG then BG:Destroy() end
                if BV then BV:Destroy() end
                LP.Character.Humanoid.PlatformStand = false
            end)
        end
    end
end})
Tab_Fly:CreateSlider({Name = "Fly Hızı", Range = {10, 500}, Increment = 10, CurrentValue = 50, Callback = function(v) FlySpeed = v end})
Tab_Fly:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Callback = function(v) _G.InfJump = v end})
Tab_Fly:CreateToggle({Name = "Spin Bot", CurrentValue = false, Callback = function(v) _G.SpinBot = v end})

-- [[ 👁️ VISUAL SEKMESİ ]] --
Tab_Vis:CreateSection("ESP Ayarları")
Tab_Vis:CreateToggle({Name = "ESP Highlight", CurrentValue = false, Callback = function(v) _G.ESP_Enabled = v end})
Tab_Vis:CreateToggle({Name = "Tracers", CurrentValue = false, Callback = function(v) _G.Tracers_Enabled = v end})

-- [[ SİSTEM DÖNGÜSÜ ]] --
local function GetClosest()
    local target, dist = nil, _G.AimbotFOV
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild(_G.AimPart) then
            local pos, onScreen = Camera:WorldToViewportPoint(v.Character[_G.AimPart].Position)
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if mag < dist then
                    target = v
                    dist = mag
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = _G.ShowFOV
    FOVCircle.Radius = _G.AimbotFOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    if _G.SpinBot and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.CFrame *= CFrame.Angles(0, math.rad(_G.SpinSpeed), 0)
    end

    if _G.AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosest()
        if target then
            local tPos = Camera:WorldToViewportPoint(target.Character[_G.AimPart].Position)
            local mPos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
            mousemoverel((tPos.X - mPos.X) * (1 - _G.AimbotSmoothness), (tPos.Y - mPos.Y) * (1 - _G.AimbotSmoothness))
        end
    end
    
    -- ESP Loop
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LP and v.Character then
            local hl = v.Character:FindFirstChild("WexHL")
            if _G.ESP_Enabled then
                if not hl then
                    hl = Instance.new("Highlight", v.Character)
                    hl.Name = "WexHL"
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                end
            elseif hl then hl:Destroy() end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if _G.InfJump then LP.Character.Humanoid:ChangeState("Jumping") end
end)

Rayfield:Notify({Title="⚡ Wex Hub", Content="Rage Mode Aktif! Fly için Movement sekmesini kullan.", Duration=5})
