-- [[ ⚡ WEX HUB | v1.5.1 - SMOOTHNESS FIXED ]] --
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LP:GetMouse()

-- [[ 1. GLOBAL DEĞİŞKENLER ]] --
_G.AimbotEnabled = false
_G.AimbotSmoothness = 1 -- (0.1 ile 1 arası değer alacak)
_G.AimbotFOV = 150
_G.ShowFOV = false
_G.AimPart = "Head"

_G.ESP_Enabled = false
_G.Tracers_Enabled = false
_G.ShowHP = false
_G.ClickTP = false
_G.InfJump = false
_G.FlySpeed = 50
local Flying = false

-- FOV Dairesi
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(0, 255, 255)
FOVCircle.Transparency = 0.7
FOVCircle.Visible = false

-- Tracers Tablosu
local TracerLines = {}
local function CreateTracer(plr)
    if plr == LP then return end
    local line = Drawing.new("Line")
    line.Thickness = 1
    line.Color = Color3.fromRGB(255, 255, 255)
    line.Visible = false
    TracerLines[plr] = line
end
for _, v in pairs(Players:GetPlayers()) do CreateTracer(v) end
Players.PlayerAdded:Connect(CreateTracer)

-- [[ 2. MENÜ KURULUMU ]] --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "⚡ Wex Hub | v1.3.2",
   LoadingTitle = "Wex Hub v1.3.2",
   LoadingSubtitle = "Smoothness Hassasiyeti Düzeltildi!",
   ConfigurationSaving = {Enabled = false}
})

local Tab_Aim = Window:CreateTab("🎯 Combat")
local Tab_Fly = Window:CreateTab("🚀 Movement")
local Tab_Vis = Window:CreateTab("👁️ Visual")

-- Combat
Tab_Aim:CreateToggle({Name = "Aimbot Aktif", CurrentValue = false, Callback = function(v) _G.AimbotEnabled = v end})
Tab_Aim:CreateToggle({Name = "FOV Dairesini Göster", CurrentValue = false, Callback = function(v) _G.ShowFOV = v end})

-- DÜZELTİLEN SMOOTHNESS SLIDER
Tab_Aim:CreateSlider({
    Name = "Smoothness (10=Anında / 1=Çok Yumuşak)", 
    Range = {1, 10}, 
    Increment = 1, 
    CurrentValue = 10, 
    Callback = function(v) 
        _G.AimbotSmoothness = v / 10 -- 1/10 ile 10/10 arası hassas ayar
    end
})

Tab_Aim:CreateSlider({Name = "Aimbot Menzili (FOV)", Range = {50, 800}, Increment = 10, CurrentValue = 150, Callback = function(v) _G.AimbotFOV = v end})

-- Movement
Tab_Fly:CreateToggle({Name = "Fly (Uçma)", CurrentValue = false, Callback = function(v) 
    Flying = v 
    if v then
        task.spawn(function()
            local Root = LP.Character:WaitForChild("HumanoidRootPart")
            local BG = Instance.new("BodyGyro", Root); BG.P = 9e4; BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            local BV = Instance.new("BodyVelocity", Root); BV.maxForce = Vector3.new(9e9, 9e9, 9e9)
            while Flying do
                LP.Character.Humanoid.PlatformStand = true
                local move = Vector3.new(0, 0.1, 0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector * _G.FlySpeed end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector * _G.FlySpeed end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector * _G.FlySpeed end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector * _G.FlySpeed end
                BV.velocity = move; BG.cframe = Camera.CFrame; task.wait()
            end
            BG:Destroy(); BV:Destroy()
            LP.Character.Humanoid.PlatformStand = false
        end)
    end
end})
Tab_Fly:CreateSlider({Name = "Fly Hızı", Range = {10, 500}, Increment = 10, CurrentValue = 50, Callback = function(v) _G.FlySpeed = v end})
Tab_Fly:CreateToggle({Name = "Click TP (Ctrl + Sol Tık)", CurrentValue = false, Callback = function(v) _G.ClickTP = v end})
Tab_Fly:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Callback = function(v) _G.InfJump = v end})

-- Visual
Tab_Vis:CreateToggle({Name = "Player Highlight (ESP)", CurrentValue = false, Callback = function(v) _G.ESP_Enabled = v end})
Tab_Vis:CreateToggle({Name = "Tracers (Çizgiler)", CurrentValue = false, Callback = function(v) _G.Tracers_Enabled = v end})
Tab_Vis:CreateToggle({Name = "Oyuncu HP", CurrentValue = false, Callback = function(v) _G.ShowHP = v end})

-- [[ 3. ANA DÖNGÜ ]] --
RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = _G.ShowFOV
    FOVCircle.Radius = _G.AimbotFOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    -- GELİŞTİRİLMİŞ SMOOTH AIM LOGIC
    if _G.AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = nil
        local dist = _G.AimbotFOV
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LP and v.Character and v.Character:FindFirstChild(_G.AimPart) then
                local pos, onScreen = Camera:WorldToViewportPoint(v.Character[_G.AimPart].Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if mag < dist then target = v; dist = mag end
                end
            end
        end
        
        if target then
            local tPos = Camera:WorldToViewportPoint(target.Character[_G.AimPart].Position)
            local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
            local targetVec = Vector2.new(tPos.X, tPos.Y)
            
            -- Smoothness 1 (Slider 10) ise doğrudan çarpan 1 olur (Anında kilit).
            -- Smoothness daha küçükse mesafe ile çarpılarak yumuşatılır.
            local moveX = (targetVec.X - screenCenter.X) * _G.AimbotSmoothness
            local moveY = (targetVec.Y - screenCenter.Y) * _G.AimbotSmoothness
            
            mousemoverel(moveX, moveY)
        end
    end

    -- Visuals (ESP, Tracers, HP)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local line = TracerLines[plr]
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if _G.Tracers_Enabled and line and hrp then
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    line.Visible = true
                    line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    line.To = Vector2.new(pos.X, pos.Y)
                else line.Visible = false end
            elseif line then line.Visible = false end

            local hl = plr.Character:FindFirstChild("WexHL")
            if _G.ESP_Enabled then
                if not hl then
                    hl = Instance.new("Highlight", plr.Character); hl.Name = "WexHL"; hl.FillColor = Color3.fromRGB(255,0,0)
                end
            elseif hl then hl:Destroy() end
        end
    end
end)

-- Click TP & Inf Jump
UserInputService.InputBegan:Connect(function(input)
    if _G.ClickTP and input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            LP.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.p + Vector3.new(0, 3, 0))
        end
    end
end)
UserInputService.JumpRequest:Connect(function() if _G.InfJump then LP.Character.Humanoid:ChangeState("Jumping") end end)

Rayfield:Notify({Title="⚡ Wex Hub v1.3.2", Content="Her şey fix, ortalık dağılsın", Duration=3})
