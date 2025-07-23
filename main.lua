-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
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
RunService.RenderStepped:Connect(function()
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

-- SPEED HACK
local function toggleSpeed()
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if speedEnabled then
            hum.WalkSpeed = 16
        else
            hum.WalkSpeed = 35
        end
    end
    speedEnabled = not speedEnabled
end

-- GUI
local gui = Instance.new("ScreenGui", PlayerGui)
gui.Name = "VixzDivo Hub"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 320, 0, 150)
frame.Position = UDim2.new(0.5, -160, 0.7, 0)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "📦 @VixzDivo Hub"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.TextSize = 18

-- Botões
local btns = {
    {"▲/▼", teleportUpDown},
    {"ESP", function() espEnabled = not espEnabled; if not espEnabled then clearESP() end end},
    {"WALL", function() wallBypass = not wallBypass end},
    {"SPEED", toggleSpeed},
}

for i, data in ipairs(btns) do
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 140, 0, 35)
    btn.Position = UDim2.new(0, 20 + ((i - 1) % 2) * 150, 0, 40 + math.floor((i - 1)/2) * 45)
    btn.Text = data[1]
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextSize = 16
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(data[2])
end

-- Minimizar / Reabrir
local miniBtn = Instance.new("TextButton", gui)
miniBtn.Text = "🛠️"
miniBtn.Size = UDim2.new(0, 35, 0, 35)
miniBtn.Position = UDim2.new(0, 15, 1, -60)
miniBtn.Visible = false
miniBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
Instance.new("UICorner", miniBtn)

local close = Instance.new("TextButton", frame)
close.Text = "X"
close.Size = UDim2.new(0, 25, 0, 25)
close.Position = UDim2.new(1, -30, 0, 5)
close.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Instance.new("UICorner", close)
close.MouseButton1Click:Connect(function()
    gui:Destroy()
    espLoop = false
    clearESP()
end)

local minimize = Instance.new("TextButton", frame)
minimize.Text = "-"
minimize.Size = UDim2.new(0, 25, 0, 25)
minimize.Position = UDim2.new(1, -60, 0, 5)
minimize.BackgroundColor3 = Color3.fromRGB(90,90,90)
Instance.new("UICorner", minimize)
minimize.MouseButton1Click:Connect(function()
    frame.Visible = false
    miniBtn.Visible = true
end)
miniBtn.MouseButton1Click:Connect(function()
    frame.Visible = true
    miniBtn.Visible = false
end)

-- TOQUE / MOVER
local dragging = false
local dragInput, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch and dragging then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
