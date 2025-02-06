-- Configurações iniciais
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Variáveis de controle
local flingEnabled = false
local superRingEnabled = false

-- Função do Fling
local function fling(target)
    if flingEnabled and target and target.Character then
        local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            local bodyVelocity = Instance.new("BodyVelocity", targetRoot)
            bodyVelocity.Velocity = Vector3.new(0, 100, 0) -- Ajuste a força aqui
            wait(0.5)
            bodyVelocity:Destroy()
        end
    end
end

-- Função do Super Ring
local function createSuperRing()
    if superRingEnabled then
        local ringParts = {}
        for i = 1, 10 do
            local part = Instance.new("Part")
            part.Size = Vector3.new(1, 1, 1)
            part.Anchored = true
            part.CanCollide = false
            part.Parent = workspace
            table.insert(ringParts, part)
        end

        while superRingEnabled do
            for i, part in ipairs(ringParts) do
                local angle = math.rad((i / #ringParts) * 360)
                local offset = Vector3.new(math.cos(angle) * 5, 0, math.sin(angle) * 5)
                part.CFrame = humanoidRootPart.CFrame + offset
            end
            wait()
        end

        -- Limpeza
        for _, part in ipairs(ringParts) do
            part:Destroy()
        end
    end
end

-- Interface Gráfica (GUI)
local screenGui = Instance.new("ScreenGui", player.PlayerGui)

-- Bolha Flutuante
local bubble = Instance.new("Frame", screenGui)
bubble.Size = UDim2.new(0, 50, 0, 50)
bubble.Position = UDim2.new(0.8, 0, 0.8, 0)
bubble.BackgroundColor3 = Color3.new(0.1, 0.5, 1)
bubble.BorderSizePixel = 0
bubble.AnchorPoint = Vector2.new(0.5, 0.5)
bubble.Draggable = true -- Permite arrastar a bolha

-- Ícone da Bolha
local icon = Instance.new("TextLabel", bubble)
icon.Size = UDim2.new(1, 0, 1, 0)
icon.Text = "⚙️"
icon.TextScaled = true
icon.BackgroundTransparency = 1

-- Frame Principal (GUI)
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 200, 0, 100)
mainFrame.Position = UDim2.new(0.5, -100, 0.5, -50)
mainFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
mainFrame.Visible = true

-- Botão do Fling
local flingButton = Instance.new("TextButton", mainFrame)
flingButton.Size = UDim2.new(0.8, 0, 0.3, 0)
flingButton.Position = UDim2.new(0.1, 0, 0.1, 0)
flingButton.Text = "Ativar/Desativar Fling"
flingButton.MouseButton1Click:Connect(function()
    flingEnabled = not flingEnabled
    flingButton.Text = flingEnabled and "Fling: Ativo" or "Fling: Inativo"
end)

-- Botão do Super Ring
local superRingButton = Instance.new("TextButton", mainFrame)
superRingButton.Size = UDim2.new(0.8, 0, 0.3, 0)
superRingButton.Position = UDim2.new(0.1, 0, 0.6, 0)
superRingButton.Text = "Ativar/Desativar Super Ring"
superRingButton.MouseButton1Click:Connect(function()
    superRingEnabled = not superRingEnabled
    superRingButton.Text = superRingEnabled and "Super Ring: Ativo" or "Super Ring: Inativo"
    if superRingEnabled then
        createSuperRing()
    end
end)

-- Função para minimizar/restaurar a GUI principal
bubble.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)
