-- ∞ Void UI | Визуалы и HUD (Без читов)
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Stats = game:GetService("Stats")

-- НАСТРОЙКИ
local Config = {
    ToggleKey = Enum.KeyCode.RightShift,
    FOV = 70,
    Fullbright = false,
    Bloom = false,
    Blur = false,
    Saturation = 0,
    Vignette = false,
}

-- ===== ЭФФЕКТЫ LIGHTING =====
local function applyEffects()
    Lighting.Ambient = Config.Fullbright and Color3.fromRGB(255,255,255) or Color3.fromRGB(128,128,128)
    Lighting.OutdoorAmbient = Config.Fullbright and Color3.fromRGB(255,255,255) or Color3.fromRGB(128,128,128)
    
    -- Bloom
    local bloom = Lighting:FindFirstChild("VoidBloom")
    if Config.Bloom then
        if not bloom then
            bloom = Instance.new("BloomEffect", Lighting)
            bloom.Name = "VoidBloom"
            bloom.Intensity = 0.5
            bloom.Size = 24
            bloom.Threshold = 0.8
        end
    else
        if bloom then bloom:Destroy() end
    end

    -- Blur
    local blur = Lighting:FindFirstChild("VoidBlur")
    if Config.Blur then
        if not blur then
            blur = Instance.new("BlurEffect", Lighting)
            blur.Name = "VoidBlur"
            blur.Size = 10
        end
    else
        if blur then blur:Destroy() end
    end

    -- Saturation
    local sat = Lighting:FindFirstChild("VoidSat")
    if Config.Saturation ~= 0 then
        if not sat then
            sat = Instance.new("ColorCorrectionEffect", Lighting)
            sat.Name = "VoidSat"
        end
        sat.Saturation = Config.Saturation
    else
        if sat then sat:Destroy() end
    end

    -- Vignette
    local vig = Lighting:FindFirstChild("VoidVignette")
    if Config.Vignette then
        if not vig then
            vig = Instance.new("ColorCorrectionEffect", Lighting)
            vig.Name = "VoidVignette"
            vig.Contrast = 0.2
            vig.TintColor = Color3.fromRGB(200, 200, 200)
        end
    else
        if vig then vig:Destroy() end
    end
end

-- ===== СОЗДАНИЕ GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VoidUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = game.CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 600, 0, 420)
mainFrame.Position = UDim2.new(0.5, -300, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(130, 80, 255)
stroke.Thickness = 2

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -70, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "∞ Void UI | v1.0"
titleText.TextColor3 = Color3.fromRGB(180, 140, 255)
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 16
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
closeBtn.MouseButton1Click:Connect(function() mainFrame.Visible = false end)

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 140, 1, -35)
sidebar.Position = UDim2.new(0, 0, 0, 35)
sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame

local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -140, 1, -35)
contentArea.Position = UDim2.new(0, 140, 0, 35)
contentArea.BackgroundTransparency = 1
contentArea.Parent = mainFrame

local function createTab(name, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.Position = UDim2.new(0, 5, 0, 5 + (order * 45))
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local tabVisuals = createTab("Визуалы", 0)
local tabCamera = createTab("Камера", 1)
local tabHUD = createTab("HUD", 2)
local tabSettings = createTab("Настройки", 3)

local function clearContent()
    for _, child in ipairs(contentArea:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextButton") then
            child:Destroy()
        end
    end
end

-- ===== ВКЛАДКА ВИЗУАЛЫ =====
local function showVisualsTab()
    clearContent()
    local y = 10

    local function createToggle(name, key)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 200, 0, 35)
        btn.Position = UDim2.new(0, 20, 0, y)
        btn.BackgroundColor3 = Config[key] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
        btn.Text = name .. ": " .. (Config[key] and "ВКЛ" or "ВЫКЛ")
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamBold
        btn.Parent = contentArea
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        
        btn.MouseButton1Click:Connect(function()
            Config[key] = not Config[key]
            btn.Text = name .. ": " .. (Config[key] and "ВКЛ" or "ВЫКЛ")
            btn.BackgroundColor3 = Config[key] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
            applyEffects()
        end)
        y = y + 45
    end

    createToggle("Fullbright", "Fullbright")
    createToggle("Bloom", "Bloom")
    createToggle("Blur", "Blur")
    createToggle("Vignette", "Vignette")

    local satLabel = Instance.new("TextLabel")
    satLabel.Size = UDim2.new(1, -40, 0, 30)
    satLabel.Position = UDim2.new(0, 20, 0, y)
    satLabel.BackgroundTransparency = 1
    satLabel.Text = "Насыщенность: " .. Config.Saturation
    satLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    satLabel.TextXAlignment = Enum.TextXAlignment.Left
    satLabel.Font = Enum.Font.Gotham
    satLabel.Parent = contentArea

    local satSliderBg = Instance.new("Frame")
    satSliderBg.Size = UDim2.new(0, 200, 0, 10)
    satSliderBg.Position = UDim2.new(0, 20, 0, y + 35)
    satSliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    satSliderBg.Parent = contentArea
    Instance.new("UICorner", satSliderBg).CornerRadius = UDim.new(1, 0)

    local satSliderFill = Instance.new("Frame")
    satSliderFill.Size = UDim2.new((Config.Saturation + 1) / 2, 0, 1, 0)
    satSliderFill.BackgroundColor3 = Color3.fromRGB(130, 80, 255)
    satSliderFill.Parent = satSliderBg
    Instance.new("UICorner", satSliderFill).CornerRadius = UDim.new(1, 0)

    local satSliderBtn = Instance.new("TextButton")
    satSliderBtn.Size = UDim2.new(0, 20, 0, 20)
    satSliderBtn.Position = UDim2.new((Config.Saturation + 1) / 2, -10, 0.5, -10)
    satSliderBtn.BackgroundColor3 = Color3.new(1,1,1)
    satSliderBtn.Text = ""
    satSliderBtn.Parent = satSliderBg
    Instance.new("UICorner", satSliderBtn).CornerRadius = UDim.new(1, 0)

    local dragging = false
    satSliderBtn.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local percent = math.clamp((input.Position.X - satSliderBg.AbsolutePosition.X) / satSliderBg.AbsoluteSize.X, 0, 1)
            satSliderFill.Size = UDim2.new(percent, 0, 1, 0)
            satSliderBtn.Position = UDim2.new(percent, -10, 0.5, -10)
            
            Config.Saturation = (percent * 2) - 1
            satLabel.Text = "Насыщенность: " .. string.format("%.2f", Config.Saturation)
            applyEffects()
        end
    end)
end

-- ===== ВКЛАДКА КАМЕРА =====
local function showCameraTab()
    clearContent()
    local y = 10

    local fovLabel = Instance.new("TextLabel")
    fovLabel.Size = UDim2.new(1, -40, 0, 30)
    fovLabel.Position = UDim2.new(0, 20, 0, y)
    fovLabel.BackgroundTransparency = 1
    fovLabel.Text = "FOV (Поле зрения): " .. Config.FOV
    fovLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    fovLabel.TextXAlignment = Enum.TextXAlignment.Left
    fovLabel.Font = Enum.Font.Gotham
    fovLabel.Parent = contentArea

    local fovSliderBg = Instance.new("Frame")
    fovSliderBg.Size = UDim2.new(0, 200, 0, 10)
    fovSliderBg.Position = UDim2.new(0, 20, 0, y + 35)
    fovSliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    fovSliderBg.Parent = contentArea
    Instance.new("UICorner", fovSliderBg).CornerRadius = UDim.new(1, 0)

    local fovSliderFill = Instance.new("Frame")
    fovSliderFill.Size = UDim2.new((Config.FOV - 30) / 90, 0, 1, 0)
    fovSliderFill.BackgroundColor3 = Color3.fromRGB(130, 80, 255)
    fovSliderFill.Parent = fovSliderBg
    Instance.new("UICorner", fovSliderFill).CornerRadius = UDim.new(1, 0)

    local fovSliderBtn = Instance.new("TextButton")
    fovSliderBtn.Size = UDim2.new(0, 20, 0, 20)
    fovSliderBtn.Position = UDim2.new((Config.FOV - 30) / 90, -10, 0.5, -10)
    fovSliderBtn.BackgroundColor3 = Color3.new(1,1,1)
    fovSliderBtn.Text = ""
    fovSliderBtn.Parent = fovSliderBg
    Instance.new("UICorner", fovSliderBtn).CornerRadius = UDim.new(1, 0)

    local dragging = false
    fovSliderBtn.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local percent = math.clamp((input.Position.X - fovSliderBg.AbsolutePosition.X) / fovSliderBg.AbsoluteSize.X, 0, 1)
            fovSliderFill.Size = UDim2.new(percent, 0, 1, 0)
            fovSliderBtn.Position = UDim2.new(percent, -10, 0.5, -10)
            
            Config.FOV = math.floor(30 + (percent * 90))
            fovLabel.Text = "FOV (Поле зрения): " .. Config.FOV
            workspace.CurrentCamera.FieldOfView = Config.FOV
        end
    end)
end

-- ===== ВКЛАДКА HUD =====
local function showHUDTab()
    clearContent()
    
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.new(1, -40, 0, 40)
    fpsLabel.Position = UDim2.new(0, 20, 0, 20)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "FPS: 60"
    fpsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
    fpsLabel.Font = Enum.Font.GothamBold
    fpsLabel.TextSize = 18
    fpsLabel.Parent = contentArea

    task.spawn(function()
        while fpsLabel.Parent do
            fpsLabel.Text = "FPS: " .. math.floor(1 / RunService.RenderStepped:Wait())
        end
    end)

    local pingLabel = Instance.new("TextLabel")
    pingLabel.Size = UDim2.new(1, -40, 0, 40)
    pingLabel.Position = UDim2.new(0, 20, 0, 70)
    pingLabel.BackgroundTransparency = 1
    pingLabel.Text = "Ping: " .. math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) .. " ms"
    pingLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    pingLabel.TextXAlignment = Enum.TextXAlignment.Left
    pingLabel.Font = Enum.Font.GothamBold
    pingLabel.TextSize = 18
    pingLabel.Parent = contentArea
end

-- ===== ВКЛАДКА НАСТРОЙКИ =====
local function showSettingsTab()
    clearContent()
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -40, 0, 30)
    label.Position = UDim2.new(0, 20, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = "Кнопка открытия меню: " .. tostring(Config.ToggleKey):gsub("Enum.KeyCode.", "")
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamBold
    label.Parent = contentArea
    
    local bindBtn = Instance.new("TextButton")
    bindBtn.Size = UDim2.new(0, 200, 0, 40)
    bindBtn.Position = UDim2.new(0, 20, 0, 60)
    bindBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    bindBtn.Text = "Сменить кнопку"
    bindBtn.TextColor3 = Color3.new(1,1,1)
    bindBtn.Font = Enum.Font.Gotham
    bindBtn.Parent = contentArea
    Instance.new("UICorner", bindBtn).CornerRadius = UDim.new(0, 6)
    
    local waitingForBind = false
    bindBtn.MouseButton1Click:Connect(function()
        waitingForBind = true
        bindBtn.Text = "Нажми клавишу..."
    end)
    
    UserInputService.InputBegan:Connect(function(input, gp)
        if waitingForBind and not gp then
            Config.ToggleKey = input.KeyCode
            bindBtn.Text = "Сменить кнопку"
            label.Text = "Кнопка открытия меню: " .. tostring(Config.ToggleKey):gsub("Enum.KeyCode.", "")
            waitingForBind = false
        end
    end)

    local resetBtn = Instance.new("TextButton")
    resetBtn.Size = UDim2.new(0, 200, 0, 40)
    resetBtn.Position = UDim2.new(0, 20, 0, 120)
    resetBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    resetBtn.Text = "Сбросить всё"
    resetBtn.TextColor3 = Color3.new(1,1,1)
    resetBtn.Font = Enum.Font.GothamBold
    resetBtn.Parent = contentArea
    Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 6)
    
    resetBtn.MouseButton1Click:Connect(function()
        Config.Fullbright = false
        Config.Bloom = false
        Config.Blur = false
        Config.Vignette = false
        Config.Saturation = 0
        Config.FOV = 70
        workspace.CurrentCamera.FieldOfView = 70
        applyEffects()
        showVisualsTab()
    end)
end

-- Привязка вкладок
tabVisuals.MouseButton1Click:Connect(showVisualsTab)
tabCamera.MouseButton1Click:Connect(showCameraTab)
tabHUD.MouseButton1Click:Connect(showHUDTab)
tabSettings.MouseButton1Click:Connect(showSettingsTab)

-- Открытие меню
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Config.ToggleKey then
        mainFrame.Visible = not mainFrame.Visible
        if mainFrame.Visible then
            showVisualsTab()
        end
    end
end)

-- Перетаскивание окна
local dragging = false
local dragStart, startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

print("∞ Void UI загружен. Нажми RShift для открытия.")
