-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- Estados
local isUp = false
local isMoving = false
local platform = nil
local espEnabled = true
local wallBypass = false
local speedEnabled = false
local espLoop = true

-- TELEPORT UP/DOWN
local function teleportUpDown()
    if isMoving then return end
    isMoving = true
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not root or not hum or hum.Health <= 0 then
        isMoving = false
        return
    end
    if not isUp then
        platform = Instance.new("Part", workspace)
        platform.Size = Vector3.new(6,1,6)
        platform.Anchored = true
        platform.Transparency = 1
        platform.CanCollide = true
        platform.Position = root.Position + Vector3.new(0,55,0)
        root.Anchored = true
        root.CFrame = platform.CFrame + Vector3.new(0,3,0)
        task.wait(0.5)
        root.Anchored = false
        isUp = true
    else
        root.Anchored = true
        root.CFrame = platform.CFrame - Vector3.new(0,52,0)
        task.wait(0.5)
        root.Anchored = false
        platform:Destroy()
        platform = nil
        isUp = false
    end
    isMoving = false
end

-- WALL CLIMB
local wallClimbConnection
wallClimbConnection = RunService.RenderStepped:Connect(function()
    if wallBypass then
        local char = player.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if root and hum and hum.MoveDirection.Magnitude > 0 then
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Blacklist
            params.FilterDescendantsInstances = {char}
            local result = workspace:Raycast(root.Position, root.CFrame.LookVector * 2 + Vector3.new(0, 2, 0), params)
            if result and result.Instance and result.Normal.Y < 0.5 then
                root.Velocity = Vector3.new(0, 50, 0)
            end
        end
    end
end)

-- ESP
local function addESP(plr)
    if not espEnabled or not plr.Character then return end
    local head = plr.Character:FindFirstChild("Head")
    if not head or head:FindFirstChild("ESPTag") then return end

    local gui = Instance.new("BillboardGui", head)
    gui.Name = "ESPTag"
    gui.Adornee = head
    gui.Size = UDim2.new(0, 100, 0, 20)
    gui.StudsOffset = Vector3.new(0, 2.5, 0)
    gui.AlwaysOnTop = true

    local label = Instance.new("TextLabel", gui)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = plr.Name
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.TextColor3 = Color3.new(1, 0, 0)
    label.TextStrokeTransparency = 0.5

    for _, partName in pairs({"Head", "HumanoidRootPart"}) do
        local part = plr.Character:FindFirstChild(partName)
        if part and not part:FindFirstChild("Highlight") then
            local hl = Instance.new("Highlight", part)
            hl.Name = "Highlight"
            hl.FillColor = Color3.fromRGB(255, 0, 0)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0
        end
    end
end

local function clearESP()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            if head and head:FindFirstChild("ESPTag") then
                head.ESPTag:Destroy()
            end
            for _, part in pairs(plr.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    local h = part:FindFirstChild("Highlight")
                    if h then h:Destroy() end
                end
            end
        end
    end
end

task.spawn(function()
    while espLoop do
        if espEnabled then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player then
                    addESP(plr)
                end
            end
        end
        task.wait(1)
    end
end)

-- SPEED HACK CORRIGIDO
local speedConnection
local function toggleSpeed()
    speedEnabled = not speedEnabled
    
    if speedEnabled then
        -- Iniciar o loop de velocidade
        speedConnection = RunService.Heartbeat:Connect(function()
            local char = player.Character
            if not char then return end
            
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                -- Definir a velocidade para 50
                humanoid.WalkSpeed = 50
            end
        end)
    else
        -- Parar o loop de velocidade
        if speedConnection then
            speedConnection:Disconnect()
            speedConnection = nil
        end
        
        -- Restaurar velocidade normal
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 16
            end
        end
    end
end

-- Criação da UI
local gui = Instance.new("ScreenGui", PlayerGui)
gui.Name = "Vixz Hub 👁️"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Frame principal
local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 350, 0, 300)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0

local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 12)

-- Efeito de vidro
local glass = Instance.new("Frame", mainFrame)
glass.Size = UDim2.new(1, 0, 1, 0)
glass.BackgroundTransparency = 0.9
glass.BackgroundColor3 = Color3.fromRGB(150, 150, 255)
glass.BorderSizePixel = 0
glass.ZIndex = -1

local glassCorner = Instance.new("UICorner", glass)
glassCorner.CornerRadius = UDim.new(0, 12)

-- Barra de título com efeito gradiente
local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundTransparency = 0.5
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
titleBar.BorderSizePixel = 0

local titleCorner = Instance.new("UICorner", titleBar)
titleCorner.CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1, 0, 1, 0)
title.Text = "⚡ Vixz Hub  ⚡"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.TextSize = 18

-- Botões de controle
local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0.5, -15)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.AutoButtonColor = false

local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0, 8)

local minimizeBtn = Instance.new("TextButton", titleBar)
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -70, 0.5, -15)
minimizeBtn.Text = "-"
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
minimizeBtn.AutoButtonColor = false

local minimizeCorner = Instance.new("UICorner", minimizeBtn)
minimizeCorner.CornerRadius = UDim.new(0, 8)

-- Área de botões principais
local buttonsFrame = Instance.new("Frame", mainFrame)
buttonsFrame.Size = UDim2.new(1, -20, 1, -60)
buttonsFrame.Position = UDim2.new(0, 10, 0, 50)
buttonsFrame.BackgroundTransparency = 1

-- Lista de botões
local gridLayout = Instance.new("UIGridLayout", buttonsFrame)
gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
gridLayout.CellSize = UDim2.new(0.5, -5, 0, 50)
gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Função para criar botões estilizados
local function createButton(text, callback, color)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BackgroundColor3 = color
    btn.AutoButtonColor = false
    btn.ZIndex = 2
    
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(200, 200, 255)
    stroke.Thickness = 1
    
    -- Animação de hover
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundTransparency = 0,
            Size = UDim2.new(0.52, 0, 0, 52)
        }):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.2,
            Size = UDim2.new(0.5, 0, 0, 50)
        }):Play()
    end)
    
    -- Animação de clique
    btn.MouseButton1Down:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {
            BackgroundTransparency = 0.4,
            Size = UDim2.new(0.48, 0, 0, 48)
        }):Play()
    end)
    
    btn.MouseButton1Up:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {
            BackgroundTransparency = 0.2,
            Size = UDim2.new(0.5, 0, 0, 50)
        }):Play()
        callback()
    end)
    
    return btn
end

-- Criar botões
local teleportBtn = createButton("▲/▼ TELEPORT", teleportUpDown, Color3.fromRGB(0, 120, 215))
teleportBtn.Parent = buttonsFrame

local espBtn = createButton("👁️ ESP", function() 
    espEnabled = not espEnabled
    if not espEnabled then clearESP() end
end, Color3.fromRGB(215, 50, 50))
espBtn.Parent = buttonsFrame

local wallBtn = createButton("🧱 WALL CLIMB", function() 
    wallBypass = not wallBypass
end, Color3.fromRGB(50, 180, 80))
wallBtn.Parent = buttonsFrame

local speedBtn = createButton("⚡ SPEED HACK", toggleSpeed, Color3.fromRGB(215, 180, 0))
speedBtn.Parent = buttonsFrame

-- Barra de status
local statusBar = Instance.new("Frame", mainFrame)
statusBar.Size = UDim2.new(1, -20, 0, 25)
statusBar.Position = UDim2.new(0, 10, 1, -35)
statusBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
statusBar.BackgroundTransparency = 0.5

local statusCorner = Instance.new("UICorner", statusBar)
statusCorner.CornerRadius = UDim.new(0, 8)

local statusLayout = Instance.new("UIListLayout", statusBar)
statusLayout.FillDirection = Enum.FillDirection.Horizontal
statusLayout.Padding = UDim.new(0, 10)

local statusPadding = Instance.new("UIPadding", statusBar)
statusPadding.PaddingLeft = UDim.new(0, 10)
statusPadding.PaddingRight = UDim.new(0, 10)

-- Função para criar indicadores de status
local function createStatusIndicator(name, color)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 70, 1, 0)
    frame.BackgroundTransparency = 1
    
    local dot = Instance.new("Frame", frame)
    dot.Size = UDim2.new(0, 10, 0, 10)
    dot.Position = UDim2.new(0, 0, 0.5, -5)
    dot.BackgroundColor3 = color
    dot.BorderSizePixel = 0
    
    local dotCorner = Instance.new("UICorner", dot)
    dotCorner.CornerRadius = UDim.new(1, 0)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -15, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.Text = name
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    
    return frame
end

-- Criar indicadores
local speedStatus = createStatusIndicator("SPEED", Color3.fromRGB(255, 200, 50))
speedStatus.Parent = statusBar

local espStatus = createStatusIndicator("ESP", Color3.fromRGB(255, 50, 50))
espStatus.Parent = statusBar

local wallStatus = createStatusIndicator("WALL", Color3.fromRGB(100, 200, 100))
wallStatus.Parent = statusBar

-- Atualizar status
local function updateStatus()
    speedStatus:FindFirstChildOfClass("Frame").BackgroundColor3 = speedEnabled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
    espStatus:FindFirstChildOfClass("Frame").BackgroundColor3 = espEnabled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
    wallStatus:FindFirstChildOfClass("Frame").BackgroundColor3 = wallBypass and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
end

-- Atualizar periodicamente
task.spawn(function()
    while true do
        updateStatus()
        task.wait(0.5)
    end
end)

-- Sistema de arrastar com toque
local dragging
local dragInput
local dragStart
local startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateInput(input)
    end
end)

-- Botão flutuante para reabrir
local floatingBtn = Instance.new("TextButton", gui)
floatingBtn.Size = UDim2.new(0, 50, 0, 50)
floatingBtn.Position = UDim2.new(0, 20, 1, -80)
floatingBtn.Text = "⚡"
floatingBtn.Font = Enum.Font.GothamBold
floatingBtn.TextSize = 24
floatingBtn.TextColor3 = Color3.new(1, 1, 1)
floatingBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
floatingBtn.Visible = false
floatingBtn.AutoButtonColor = false

local floatingCorner = Instance.new("UICorner", floatingBtn)
floatingCorner.CornerRadius = UDim.new(1, 0)

-- Funcionalidade dos botões de controle
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
    espLoop = false
    clearESP()
    if speedConnection then
        speedConnection:Disconnect()
    end
    if wallClimbConnection then
        wallClimbConnection:Disconnect()
    end
end)

minimizeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    floatingBtn.Visible = true
end)

floatingBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    floatingBtn.Visible = false
end)

-- Efeito de sombra
local shadow = Instance.new("ImageLabel", mainFrame)
shadow.Image = "rbxassetid://1316045217"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.8
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.Position = UDim2.new(0, -10, 0, -10)
shadow.BackgroundTransparency = 1
shadow.ZIndex = -1

-- Efeito de brilho
local glow = Instance.new("ImageLabel", mainFrame)
glow.Image = "rbxassetid://8992230671"
glow.ImageColor3 = Color3.fromRGB(0, 100, 255)
glow.BackgroundTransparency = 1
glow.Size = UDim2.new(1, 30, 1, 30)
glow.Position = UDim2.new(0, -15, 0, -15)
glow.ZIndex = -1

-- Notificação inicial
task.spawn(function()
    local notify = Instance.new("Frame", gui)
    notify.Size = UDim2.new(0, 300, 0, 50)
    notify.Position = UDim2.new(0.5, -150, 0, 20)
    notify.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    notify.BackgroundTransparency = 0.3
    
    local notifyCorner = Instance.new("UICorner", notify)
    notifyCorner.CornerRadius = UDim.new(0, 12)
    
    local notifyStroke = Instance.new("UIStroke", notify)
    notifyStroke.Color = Color3.fromRGB(0, 200, 255)
    notifyStroke.Thickness = 2
    
    local label = Instance.new("TextLabel", notify)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = "⚡ Vixz Hub - Menu Ativado!"
    label.Font = Enum.Font.GothamBold
    label.TextColor3 = Color3.fromRGB(200, 230, 255)
    label.BackgroundTransparency = 1
    label.TextSize = 16
    
    TweenService:Create(notify, TweenInfo.new(0.5), {
        Position = UDim2.new(0.5, -150, 0, 30)
    }):Play()
    
    wait(3)
    
    TweenService:Create(notify, TweenInfo.new(0.5), {
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, -150, 0, 10)
    }):Play()
    
    TweenService:Create(notifyStroke, TweenInfo.new(0.5), {
        Transparency = 1
    }):Play()
    
    wait(0.5)
    notify:Destroy()
end)

-- Inicializar status
espEnabled = true
wallBypass = false
speedEnabled = false
updateStatus()
