local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Variables
local headlockEnabled = false
local highlights = {}

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0.5, -100, 0.5, -50)
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
frame.Parent = screenGui

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 180, 0, 50)
toggleButton.Position = UDim2.new(0.5, -90, 0.5, -25)
toggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
toggleButton.Text = "Enable Headlock"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Parent = frame

-- Function to get closest player to mouse
local function getClosestPlayer()
    local closest = nil
    local shortestDistance = math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closest = head
                end
            end
        end
    end
    return closest
end

-- Function to toggle headlock
local function toggleHeadlock()
    headlockEnabled = not headlockEnabled
    if headlockEnabled then
        toggleButton.Text = "Disable Headlock"
    else
        toggleButton.Text = "Enable Headlock"
    end
end

toggleButton.MouseButton1Click:Connect(toggleHeadlock)

-- Apply headlock functionality
RunService.RenderStepped:Connect(function()
    if headlockEnabled then
        local targetHead = getClosestPlayer()
        if targetHead then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
        end
    end
end)

-- Function to create a highlight for players
local function createHighlight(player)
    if player and player.Character then
        local character = player.Character
        local highlight = Instance.new("Highlight")
        highlight.FillColor = Color3.fromRGB(0, 255, 0) -- Green fill
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- White outline
        highlight.Adornee = character
        highlight.Parent = character
        highlights[player.Name] = highlight
    end
end

-- Function to remove highlight
local function removeHighlight(player)
    if highlights[player.Name] then
        highlights[player.Name]:Destroy()
        highlights[player.Name] = nil
    end
end

-- Add highlights to all players except LocalPlayer
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createHighlight(player)
    end
end

-- Add highlight for new players joining the game
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        createHighlight(player)
    end)
end)

-- Remove highlight when players leave
Players.PlayerRemoving:Connect(removeHighlight)

-- Optional: Ensure highlights are dynamic
RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if not highlights[player.Name] then
                createHighlight(player)
            end
        end
    end
end)
