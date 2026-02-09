-- Configuration
local TOP_HEIGHT = 0.5
local TARGET_PART_NAME = "Part"
local TAG_NAME = "TopBrickApplied"
local CREATED_BRICK_TAG = "GeneratedTopBrick"

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")

local localPlayer = Players.LocalPlayer
local active = false
local currentTransparency = 0.1
local isMinimized = false

--------------------------------------------------------------------------------
-- 1. OPTIMIZED UI CREATION
--------------------------------------------------------------------------------

-- Colors
local ColorPalette = {
    Primary = Color3.fromRGB(0, 150, 255),
    Secondary = Color3.fromRGB(45, 45, 50),
    Tertiary = Color3.fromRGB(35, 35, 40),
    Success = Color3.fromRGB(76, 175, 80),
    Danger = Color3.fromRGB(220, 60, 60),
    Warning = Color3.fromRGB(255, 193, 7),
    Text = Color3.fromRGB(245, 245, 245),
    SubText = Color3.fromRGB(180, 180, 180),
    Background = Color3.fromRGB(30, 30, 35),
    Card = Color3.fromRGB(40, 40, 45)
}

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SystemControlV8_Fixed"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

-- Main Container (Smaller and more compact)
local mainContainer = Instance.new("Frame")
mainContainer.Size = UDim2.new(0, 320, 0, 400) -- Reduced width
mainContainer.Position = UDim2.new(0.02, 0, 0.3, 0)
mainContainer.BackgroundColor3 = ColorPalette.Background
mainContainer.BackgroundTransparency = 0.05
mainContainer.ClipsDescendants = true
mainContainer.Active = true
mainContainer.Parent = screenGui

local containerCorner = Instance.new("UICorner")
containerCorner.CornerRadius = UDim.new(0, 14)
containerCorner.Parent = mainContainer

-- Title Bar (Compact)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40) -- Smaller height
titleBar.BackgroundColor3 = ColorPalette.Primary
titleBar.Parent = mainContainer

local titleBarCorner = Instance.new("UICorner")
titleBarCorner.CornerRadius = UDim.new(0, 14)
titleBarCorner.Parent = titleBar

-- Title with smaller text
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -80, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "SYSTEM CONTROL V8"
titleLabel.TextColor3 = ColorPalette.Text
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 15 -- Smaller
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Control buttons
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 24, 0, 24)
minimizeButton.Position = UDim2.new(1, -60, 0.5, -12)
minimizeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.BackgroundTransparency = 0.9
minimizeButton.Text = "_"
minimizeButton.TextColor3 = ColorPalette.Text
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextSize = 18
minimizeButton.Parent = titleBar

local minimizeButtonCorner = Instance.new("UICorner")
minimizeButtonCorner.CornerRadius = UDim.new(0, 4)
minimizeButtonCorner.Parent = minimizeButton

-- Content Area
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -40)
contentFrame.Position = UDim2.new(0, 0, 0, 40)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainContainer

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, 0)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 3
scrollFrame.ScrollBarImageColor3 = ColorPalette.Primary
scrollFrame.ScrollBarImageTransparency = 0.5
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 450)
scrollFrame.Parent = contentFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8) -- Smaller padding
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = scrollFrame

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
end)

-- Function to create compact card
local function createCard(title, height)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0.92, 0, 0, height) -- Slightly narrower
    card.BackgroundColor3 = ColorPalette.Card
    card.Parent = scrollFrame
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 10)
    cardCorner.Parent = card
    
    local cardTitle = Instance.new("TextLabel")
    cardTitle.Size = UDim2.new(1, -16, 0, 24)
    cardTitle.Position = UDim2.new(0, 8, 0, 4)
    cardTitle.BackgroundTransparency = 1
    cardTitle.Text = title
    cardTitle.TextColor3 = ColorPalette.Primary
    cardTitle.Font = Enum.Font.GothamSemibold
    cardTitle.TextSize = 13 -- Smaller
    cardTitle.TextXAlignment = Enum.TextXAlignment.Left
    cardTitle.Parent = card
    
    local titleDivider = Instance.new("Frame")
    titleDivider.Size = UDim2.new(1, -16, 0, 1)
    titleDivider.Position = UDim2.new(0, 8, 0, 28)
    titleDivider.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    titleDivider.BorderSizePixel = 0
    titleDivider.Parent = card
    
    return card
end

-- Status Card (Compact)
local statusCard = createCard("STATUS", 90) -- Smaller height
local statusIndicator = Instance.new("Frame")
statusIndicator.Size = UDim2.new(0, 10, 0, 10)
statusIndicator.Position = UDim2.new(0, 8, 0, 34)
statusIndicator.BackgroundColor3 = ColorPalette.Danger
statusIndicator.Parent = statusCard

local statusIndicatorCorner = Instance.new("UICorner")
statusIndicatorCorner.CornerRadius = UDim.new(1, 0)
statusIndicatorCorner.Parent = statusIndicator

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -24, 0, 18)
statusText.Position = UDim2.new(0, 22, 0, 32)
statusText.BackgroundTransparency = 1
statusText.Text = "SYSTEM INACTIVE"
statusText.TextColor3 = ColorPalette.Danger
statusText.Font = Enum.Font.GothamSemibold
statusText.TextSize = 14
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.Parent = statusCard

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.9, 0, 0, 36)
toggleButton.Position = UDim2.new(0.05, 0, 0, 50)
toggleButton.BackgroundColor3 = ColorPalette.Danger
toggleButton.Text = "ACTIVATE SYSTEM"
toggleButton.TextColor3 = ColorPalette.Text
toggleButton.Font = Enum.Font.GothamSemibold
toggleButton.TextSize = 13
toggleButton.Parent = statusCard

local toggleButtonCorner = Instance.new("UICorner")
toggleButtonCorner.CornerRadius = UDim.new(0, 6)
toggleButtonCorner.Parent = toggleButton

-- Opacity Card
local opacityCard = createCard("OPACITY SETTINGS", 110)
local opacityValueDisplay = Instance.new("TextLabel")
opacityValueDisplay.Size = UDim2.new(1, -16, 0, 20)
opacityValueDisplay.Position = UDim2.new(0, 8, 0, 32)
opacityValueDisplay.BackgroundTransparency = 1
opacityValueDisplay.Text = "Current: 0.1"
opacityValueDisplay.TextColor3 = ColorPalette.SubText
opacityValueDisplay.Font = Enum.Font.Gotham
opacityValueDisplay.TextSize = 12
opacityValueDisplay.TextXAlignment = Enum.TextXAlignment.Left
opacityValueDisplay.Parent = opacityCard

-- Simple opacity buttons (no complex slider)
local opacityControls = Instance.new("Frame")
opacityControls.Size = UDim2.new(1, -16, 0, 32)
opacityControls.Position = UDim2.new(0, 8, 0, 56)
opacityControls.BackgroundTransparency = 1
opacityControls.Parent = opacityCard

local decreaseBtn = Instance.new("TextButton")
decreaseBtn.Size = UDim2.new(0, 40, 1, 0)
decreaseBtn.BackgroundColor3 = ColorPalette.Secondary
decreaseBtn.Text = "-"
decreaseBtn.TextColor3 = ColorPalette.Text
decreaseBtn.Font = Enum.Font.GothamBold
decreaseBtn.TextSize = 16
decreaseBtn.Parent = opacityControls

local decreaseBtnCorner = Instance.new("UICorner")
decreaseBtnCorner.CornerRadius = UDim.new(0, 4)
decreaseBtnCorner.Parent = decreaseBtn

local opacityText = Instance.new("TextLabel")
opacityText.Size = UDim2.new(1, -80, 1, 0)
opacityText.Position = UDim2.new(0, 40, 0, 0)
opacityText.BackgroundColor3 = ColorPalette.Tertiary
opacityText.Text = "0.1"
opacityText.TextColor3 = ColorPalette.Text
opacityText.Font = Enum.Font.GothamSemibold
opacityText.TextSize = 14
opacityText.Parent = opacityControls

local opacityTextCorner = Instance.new("UICorner")
opacityTextCorner.CornerRadius = UDim.new(0, 4)
opacityTextCorner.Parent = opacityText

local increaseBtn = Instance.new("TextButton")
increaseBtn.Size = UDim2.new(0, 40, 1, 0)
increaseBtn.Position = UDim2.new(1, -40, 0, 0)
increaseBtn.BackgroundColor3 = ColorPalette.Secondary
increaseBtn.Text = "+"
increaseBtn.TextColor3 = ColorPalette.Text
increaseBtn.Font = Enum.Font.GothamBold
increaseBtn.TextSize = 16
increaseBtn.Parent = opacityControls

local increaseBtnCorner = Instance.new("UICorner")
increaseBtnCorner.CornerRadius = UDim.new(0, 4)
increaseBtnCorner.Parent = increaseBtn

-- Info Card with proper text wrapping
local infoCard = createCard("INFORMATION", 120)
local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1, -16, 1, -12)
infoText.Position = UDim2.new(0, 8, 0, 32)
infoText.BackgroundTransparency = 1
infoText.Text = "• Places glass bricks on top\n• Makes players fully visible\n• Toggle with Activate button\n• Auto-detects new parts"
infoText.TextColor3 = ColorPalette.SubText
infoText.Font = Enum.Font.Gotham
infoText.TextSize = 11 -- Smaller for better fit
infoText.TextXAlignment = Enum.TextXAlignment.Left
infoText.TextYAlignment = Enum.TextYAlignment.Top
infoText.TextWrapped = true -- Important for wrapping
infoText.Parent = infoCard

-- Stats Card (Compact)
local statsCard = createCard("STATISTICS", 80)
local statsContainer = Instance.new("Frame")
statsContainer.Size = UDim2.new(1, -16, 1, -36)
statsContainer.Position = UDim2.new(0, 8, 0, 32)
statsContainer.BackgroundTransparency = 1
statsContainer.Parent = statsCard

local statsLayout = Instance.new("UIListLayout")
statsLayout.Padding = UDim.new(0, 4)
statsLayout.Parent = statsContainer

local partsStat = Instance.new("TextLabel")
partsStat.Size = UDim2.new(1, 0, 0, 18)
partsStat.BackgroundTransparency = 1
partsStat.Text = "Parts detected: 0"
partsStat.TextColor3 = ColorPalette.SubText
partsStat.Font = Enum.Font.GothamMedium
partsStat.TextSize = 12
partsStat.TextXAlignment = Enum.TextXAlignment.Left
partsStat.Name = "PartsStat"
partsStat.Parent = statsContainer

local bricksStat = Instance.new("TextLabel")
bricksStat.Size = UDim2.new(1, 0, 0, 18)
bricksStat.BackgroundTransparency = 1
bricksStat.Text = "Top bricks: 0"
bricksStat.TextColor3 = ColorPalette.SubText
bricksStat.Font = Enum.Font.GothamMedium
partsStat.TextSize = 12
bricksStat.TextXAlignment = Enum.TextXAlignment.Left
bricksStat.Name = "BricksStat"
bricksStat.Parent = statsContainer

--------------------------------------------------------------------------------
-- 2. DRAGGING SYSTEM
--------------------------------------------------------------------------------

local dragToggle = nil
local dragSpeed = 0.1
local dragStart = nil
local startPos = nil

local function updateInput(input)
    local delta = input.Position - dragStart
    local newPosition = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
    
    TweenService:Create(mainContainer, TweenInfo.new(dragSpeed), {
        Position = newPosition
    }):Play()
end

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragToggle = true
        dragStart = input.Position
        startPos = mainContainer.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragToggle = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragToggle and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateInput(input)
    end
end)

--------------------------------------------------------------------------------
-- 3. UI INTERACTIONS
--------------------------------------------------------------------------------

-- Minimize functionality
minimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    
    if isMinimized then
        TweenService:Create(contentFrame, TweenInfo.new(0.3), {
            Size = UDim2.new(1, 0, 0, 0)
        }):Play()
        minimizeButton.Text = "□"
    else
        TweenService:Create(contentFrame, TweenInfo.new(0.3), {
            Size = UDim2.new(1, 0, 1, -40)
        }):Play()
        minimizeButton.Text = "_"
    end
end)

-- Button hover effects
local function setupButtonHover(button)
    local originalColor = button.BackgroundColor3
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = originalColor * 1.2
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = originalColor
        }):Play()
    end)
end

setupButtonHover(toggleButton)
setupButtonHover(decreaseBtn)
setupButtonHover(increaseBtn)

--------------------------------------------------------------------------------
-- 4. CORE LOGIC
--------------------------------------------------------------------------------

local function updateStats()
    local partsDetected = 0
    local topBricksCount = #CollectionService:GetTagged(CREATED_BRICK_TAG)
    
    -- Count target parts
    for _, obj in ipairs(game.Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == TARGET_PART_NAME then
            partsDetected = partsDetected + 1
        end
    end
    
    partsStat.Text = "Parts detected: " .. partsDetected
    bricksStat.Text = "Top bricks: " .. topBricksCount
end

local function spawnTopBrick(target)
    if CollectionService:HasTag(target, TAG_NAME) then return end
    
    local topBrick = Instance.new("Part")
    topBrick.Name = "TopBrick"
    topBrick.Size = Vector3.new(target.Size.X, TOP_HEIGHT, target.Size.Z)
    topBrick.Anchored = true
    topBrick.CanCollide = false
    topBrick.BrickColor = BrickColor.new("Bright red")
    topBrick.Material = Enum.Material.Neon
    topBrick.Transparency = currentTransparency
    
    -- Calculate position
    local offset = CFrame.new(0, (target.Size.Y/2) + (TOP_HEIGHT/2), 0)
    topBrick.CFrame = target.CFrame * offset
    
    topBrick.Parent = game.Workspace
    
    CollectionService:AddTag(target, TAG_NAME)
    CollectionService:AddTag(topBrick, CREATED_BRICK_TAG)
    
    updateStats()
end

-- Opacity Controls
local function updateOpacity(value)
    currentTransparency = math.clamp(value, 0, 1)
    local displayValue = math.floor(currentTransparency * 10 + 0.5) / 10
    
    opacityValueDisplay.Text = "Current: " .. displayValue
    opacityText.Text = tostring(displayValue)
    
    -- Update all top bricks
    for _, brick in ipairs(CollectionService:GetTagged(CREATED_BRICK_TAG)) do
        brick.Transparency = currentTransparency
    end
end

-- Button controls
decreaseBtn.MouseButton1Click:Connect(function()
    updateOpacity(currentTransparency - 0.1)
end)

increaseBtn.MouseButton1Click:Connect(function()
    updateOpacity(currentTransparency + 0.1)
end)

-- Main Toggle System
toggleButton.MouseButton1Click:Connect(function()
    active = not active
    
    if active then
        -- Update UI
        statusIndicator.BackgroundColor3 = ColorPalette.Success
        statusText.Text = "SYSTEM ACTIVE"
        statusText.TextColor3 = ColorPalette.Success
        toggleButton.Text = "DEACTIVATE SYSTEM"
        toggleButton.BackgroundColor3 = ColorPalette.Warning
        
        -- Activate system
        task.spawn(function()
            for _, obj in ipairs(game.Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name == TARGET_PART_NAME then
                    spawnTopBrick(obj)
                    task.wait() -- Prevent lag
                end
            end
        end)
    else
        -- Update UI
        statusIndicator.BackgroundColor3 = ColorPalette.Danger
        statusText.Text = "SYSTEM INACTIVE"
        statusText.TextColor3 = ColorPalette.Danger
        toggleButton.Text = "ACTIVATE SYSTEM"
        toggleButton.BackgroundColor3 = ColorPalette.Danger
        
        -- Cleanup
        for _, brick in ipairs(CollectionService:GetTagged(CREATED_BRICK_TAG)) do
            brick:Destroy()
        end
        
        for _, target in ipairs(CollectionService:GetTagged(TAG_NAME)) do
            CollectionService:RemoveTag(target, TAG_NAME)
        end
        
        updateStats()
    end
end)

-- Auto-update when parts are added/removed
game.Workspace.DescendantAdded:Connect(function(descendant)
    if active and descendant:IsA("BasePart") and descendant.Name == TARGET_PART_NAME then
        spawnTopBrick(descendant)
    end
    updateStats()
end)

game.Workspace.DescendantRemoving:Connect(function(descendant)
    if descendant:IsA("Part") and descendant.Name == "TopBrick" then
        updateStats()
    end
end)

-- Player visibility system
RunService.RenderStepped:Connect(function()
    if active then
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") or part:IsA("Decal") then
                        part.Transparency = 0
                    end
                end
            end
        end
    end
end)

-- Initialize
updateStats()

-- Welcome effect
task.spawn(function()
    task.wait(0.5)
    TweenService:Create(mainContainer, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.02, 0, 0.25, 0)
    }):Play()
end)
