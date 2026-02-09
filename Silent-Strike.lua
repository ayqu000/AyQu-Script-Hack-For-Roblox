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
local originalSize = UDim2.new(0, 350, 0, 450)
local minimizedSize = UDim2.new(0, 350, 0, 50)

--------------------------------------------------------------------------------
-- 1. MODERN UI CREATION
--------------------------------------------------------------------------------

-- Colors
local ColorPalette = {
    Primary = Color3.fromRGB(0, 120, 215),
    Secondary = Color3.fromRGB(40, 40, 45),
    Tertiary = Color3.fromRGB(30, 30, 35),
    Success = Color3.fromRGB(76, 175, 80),
    Danger = Color3.fromRGB(220, 60, 60),
    Warning = Color3.fromRGB(255, 193, 7),
    Text = Color3.fromRGB(240, 240, 240),
    SubText = Color3.fromRGB(180, 180, 180),
    Background = Color3.fromRGB(25, 25, 28),
    Card = Color3.fromRGB(35, 35, 40)
}

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SystemControlV8"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

-- Main Container
local mainContainer = Instance.new("Frame")
mainContainer.Size = originalSize
mainContainer.Position = UDim2.new(0.02, 0, 0.3, 0)
mainContainer.BackgroundColor3 = ColorPalette.Background
mainContainer.BackgroundTransparency = 0.05
mainContainer.ClipsDescendants = true
mainContainer.Active = true
mainContainer.Parent = screenGui

local containerCorner = Instance.new("UICorner")
containerCorner.CornerRadius = UDim.new(0, 16)
containerCorner.Parent = mainContainer

local containerShadow = Instance.new("ImageLabel")
containerShadow.Name = "Shadow"
containerShadow.Size = UDim2.new(1, 20, 1, 20)
containerShadow.Position = UDim2.new(0, -10, 0, -10)
containerShadow.BackgroundTransparency = 1
containerShadow.Image = "rbxassetid://1316045217"
containerShadow.ImageColor3 = Color3.new(0, 0, 0)
containerShadow.ImageTransparency = 0.8
containerShadow.ScaleType = Enum.ScaleType.Slice
containerShadow.SliceCenter = Rect.new(10, 10, 118, 118)
containerShadow.Parent = mainContainer

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = ColorPalette.Secondary
titleBar.Parent = mainContainer

local titleBarCorner = Instance.new("UICorner")
titleBarCorner.CornerRadius = UDim.new(0, 16)
titleBarCorner.Parent = titleBar

-- Title with Icon
local titleContainer = Instance.new("Frame")
titleContainer.Size = UDim2.new(1, -40, 1, 0)
titleContainer.BackgroundTransparency = 1
titleContainer.Parent = titleBar

local icon = Instance.new("ImageLabel")
icon.Size = UDim2.new(0, 24, 0, 24)
icon.Position = UDim2.new(0, 12, 0.5, -12)
icon.BackgroundTransparency = 1
icon.Image = "rbxassetid://10723385059" -- Cube icon
icon.ImageColor3 = ColorPalette.Primary
icon.Parent = titleContainer

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 40, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "SYSTEM CONTROL V8"
titleLabel.TextColor3 = ColorPalette.Text
titleLabel.Font = Enum.Font.GothamSemibold
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleContainer

local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Size = UDim2.new(1, -40, 0, 14)
subtitleLabel.Position = UDim2.new(0, 40, 0, 20)
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Text = "Top Brick Generator"
subtitleLabel.TextColor3 = ColorPalette.SubText
subtitleLabel.Font = Enum.Font.Gotham
subtitleLabel.TextSize = 12
subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
subtitleLabel.Parent = titleContainer

-- Control Buttons
local minimizeButton = Instance.new("ImageButton")
minimizeButton.Size = UDim2.new(0, 24, 0, 24)
minimizeButton.Position = UDim2.new(1, -60, 0.5, -12)
minimizeButton.BackgroundTransparency = 1
minimizeButton.Image = "rbxassetid://10734924325" -- Dash icon
minimizeButton.ImageColor3 = ColorPalette.SubText
minimizeButton.Parent = titleBar

local closeButton = Instance.new("ImageButton")
closeButton.Size = UDim2.new(0, 24, 0, 24)
closeButton.Position = UDim2.new(1, -28, 0.5, -12)
closeButton.BackgroundTransparency = 1
closeButton.Image = "rbxassetid://10734922006" -- X icon
closeButton.ImageColor3 = ColorPalette.Danger
closeButton.Parent = titleBar

-- Content Area
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -50)
contentFrame.Position = UDim2.new(0, 0, 0, 50)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainContainer

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, 0)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = ColorPalette.Primary
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
scrollFrame.Parent = contentFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 12)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = scrollFrame

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
end)

-- Function to create modern card
local function createCard(title, height)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0.9, 0, 0, height)
    card.BackgroundColor3 = ColorPalette.Card
    card.Parent = scrollFrame
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 12)
    cardCorner.Parent = card
    
    local cardStroke = Instance.new("UIStroke")
    cardStroke.Thickness = 1
    cardStroke.Color = Color3.fromRGB(50, 50, 55)
    cardStroke.Parent = card
    
    local cardTitle = Instance.new("TextLabel")
    cardTitle.Size = UDim2.new(1, 0, 0, 24)
    cardTitle.Position = UDim2.new(0, 12, 0, 8)
    cardTitle.BackgroundTransparency = 1
    cardTitle.Text = title
    cardTitle.TextColor3 = ColorPalette.Text
    cardTitle.Font = Enum.Font.GothamSemibold
    cardTitle.TextSize = 14
    cardTitle.TextXAlignment = Enum.TextXAlignment.Left
    cardTitle.Parent = card
    
    return card
end

-- Status Card
local statusCard = createCard("SYSTEM STATUS", 120)
local statusIndicator = Instance.new("Frame")
statusIndicator.Size = UDim2.new(0, 12, 0, 12)
statusIndicator.Position = UDim2.new(0, 12, 0, 36)
statusIndicator.BackgroundColor3 = ColorPalette.Danger
statusIndicator.Parent = statusCard

local statusIndicatorCorner = Instance.new("UICorner")
statusIndicatorCorner.CornerRadius = UDim.new(1, 0)
statusIndicatorCorner.Parent = statusIndicator

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -40, 0, 20)
statusText.Position = UDim2.new(0, 32, 0, 32)
statusText.BackgroundTransparency = 1
statusText.Text = "INACTIVE"
statusText.TextColor3 = ColorPalette.Danger
statusText.Font = Enum.Font.GothamSemibold
statusText.TextSize = 18
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.Parent = statusCard

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.85, 0, 0, 42)
toggleButton.Position = UDim2.new(0.075, 0, 0, 60)
toggleButton.BackgroundColor3 = ColorPalette.Danger
toggleButton.Text = "ACTIVATE SYSTEM"
toggleButton.TextColor3 = ColorPalette.Text
toggleButton.Font = Enum.Font.GothamSemibold
toggleButton.TextSize = 14
toggleButton.Parent = statusCard

local toggleButtonCorner = Instance.new("UICorner")
toggleButtonCorner.CornerRadius = UDim.new(0, 8)
toggleButtonCorner.Parent = toggleButton

-- Settings Card
local settingsCard = createCard("VISUAL SETTINGS", 160)
local opacityLabel = Instance.new("TextLabel")
opacityLabel.Size = UDim2.new(1, -24, 0, 20)
opacityLabel.Position = UDim2.new(0, 12, 0, 32)
opacityLabel.BackgroundTransparency = 1
opacityLabel.Text = "Top Brick Opacity: 0.1"
opacityLabel.TextColor3 = ColorPalette.SubText
opacityLabel.Font = Enum.Font.Gotham
opacityLabel.TextSize = 14
opacityLabel.TextXAlignment = Enum.TextXAlignment.Left
opacityLabel.Parent = settingsCard

-- Opacity Slider
local opacitySlider = Instance.new("Frame")
opacitySlider.Size = UDim2.new(0.85, 0, 0, 32)
opacitySlider.Position = UDim2.new(0.075, 0, 0, 60)
opacitySlider.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
opacitySlider.Parent = settingsCard

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(0, 8)
sliderCorner.Parent = opacitySlider

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(currentTransparency, 0, 1, 0)
sliderFill.BackgroundColor3 = ColorPalette.Primary
sliderFill.Parent = opacitySlider

local sliderFillCorner = Instance.new("UICorner")
sliderFillCorner.CornerRadius = UDim.new(0, 8)
sliderFillCorner.Parent = sliderFill

local sliderButton = Instance.new("TextButton")
sliderButton.Size = UDim2.new(0, 20, 0, 20)
sliderButton.Position = UDim2.new(currentTransparency, -10, 0.5, -10)
sliderButton.BackgroundColor3 = ColorPalette.Text
sliderButton.Text = ""
sliderButton.ZIndex = 2
sliderButton.Parent = opacitySlider

local sliderButtonCorner = Instance.new("UICorner")
sliderButtonCorner.CornerRadius = UDim.new(1, 0)
sliderButtonCorner.Parent = sliderButton

-- Buttons for opacity
local opacityButtons = Instance.new("Frame")
opacityButtons.Size = UDim2.new(0.85, 0, 0, 32)
opacityButtons.Position = UDim2.new(0.075, 0, 0, 100)
opacityButtons.BackgroundTransparency = 1
opacityButtons.Parent = settingsCard

local decreaseOpacity = Instance.new("TextButton")
decreaseOpacity.Size = UDim2.new(0, 32, 1, 0)
decreaseOpacity.BackgroundColor3 = ColorPalette.Secondary
decreaseOpacity.Text = "-"
decreaseOpacity.TextColor3 = ColorPalette.Text
decreaseOpacity.Font = Enum.Font.GothamBold
decreaseOpacity.TextSize = 16
decreaseOpacity.Parent = opacityButtons

local opacityValue = Instance.new("TextLabel")
opacityValue.Size = UDim2.new(1, -64, 1, 0)
opacityValue.Position = UDim2.new(0, 32, 0, 0)
opacityValue.BackgroundColor3 = ColorPalette.Tertiary
opacityValue.Text = "0.1"
opacityValue.TextColor3 = ColorPalette.Text
opacityValue.Font = Enum.Font.GothamSemibold
opacityValue.TextSize = 14
opacityValue.Parent = opacityButtons

local increaseOpacity = Instance.new("TextButton")
increaseOpacity.Size = UDim2.new(0, 32, 1, 0)
increaseOpacity.Position = UDim2.new(1, -32, 0, 0)
increaseOpacity.BackgroundColor3 = ColorPalette.Secondary
increaseOpacity.Text = "+"
increaseOpacity.TextColor3 = ColorPalette.Text
increaseOpacity.Font = Enum.Font.GothamBold
increaseOpacity.TextSize = 16
increaseOpacity.Parent = opacityButtons

-- Info Card
local infoCard = createCard("INFORMATION", 120)
local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1, -24, 1, -16)
infoText.Position = UDim2.new(0, 12, 0, 8)
infoText.BackgroundTransparency = 1
infoText.Text = "• Detects parts named '"..TARGET_PART_NAME.."'\n• Places red glass bricks on top\n• Makes players fully visible\n• Toggle with Activate button"
infoText.TextColor3 = ColorPalette.SubText
infoText.Font = Enum.Font.Gotham
infoText.TextSize = 12
infoText.TextXAlignment = Enum.TextXAlignment.Left
infoText.TextYAlignment = Enum.TextYAlignment.Top
infoText.Parent = infoCard

-- Stats Card
local statsCard = createCard("STATISTICS", 100)
local statsText = Instance.new("TextLabel")
statsText.Size = UDim2.new(1, -24, 1, -16)
statsText.Position = UDim2.new(0, 12, 0, 8)
statsText.BackgroundTransparency = 1
statsText.Text = "Parts detected: 0\nTop bricks: 0"
statsText.TextColor3 = ColorPalette.SubText
statsText.Font = Enum.Font.GothamMedium
statsText.TextSize = 12
statsText.TextXAlignment = Enum.TextXAlignment.Left
statsText.TextYAlignment = Enum.TextYAlignment.Top
statsText.Name = "StatsText"
statsText.Parent = statsCard

--------------------------------------------------------------------------------
-- 2. ENHANCED DRAGGING SYSTEM
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

-- Minimize/Maximize
minimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    
    if isMinimized then
        TweenService:Create(mainContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = minimizedSize
        }):Play()
        
        TweenService:Create(minimizeButton, TweenInfo.new(0.3), {
            Rotation = 180,
            ImageColor3 = ColorPalette.Primary
        }):Play()
    else
        TweenService:Create(mainContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = originalSize
        }):Play()
        
        TweenService:Create(minimizeButton, TweenInfo.new(0.3), {
            Rotation = 0,
            ImageColor3 = ColorPalette.SubText
        }):Play()
    end
end)

-- Close button (just minimizes for safety)
closeButton.MouseButton1Click:Connect(function()
    TweenService:Create(mainContainer, TweenInfo.new(0.3), {
        Size = UDim2.new(0, 0, 0, 0)
    }):Play()
    
    task.wait(0.3)
    screenGui:Destroy()
end)

-- Button hover effects
local function setupButtonHover(button)
    local originalColor = button.BackgroundColor3
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(
                math.floor(originalColor.R * 255 * 1.2),
                math.floor(originalColor.G * 255 * 1.2),
                math.floor(originalColor.B * 255 * 1.2)
            )
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = originalColor
        }):Play()
    end)
end

setupButtonHover(toggleButton)
setupButtonHover(decreaseOpacity)
setupButtonHover(increaseOpacity)

--------------------------------------------------------------------------------
-- 4. CORE LOGIC ENHANCEMENTS
--------------------------------------------------------------------------------

local function updateStats()
    local partsDetected = 0
    local topBricksCount = #CollectionService:GetTagged(CREATED_BRICK_TAG)
    
    for _, obj in ipairs(game.Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == TARGET_PART_NAME then
            partsDetected = partsDetected + 1
        end
    end
    
    statsText.Text = string.format("Parts detected: %d\nTop bricks: %d", partsDetected, topBricksCount)
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
    
    -- Add subtle glow effect
    local pointLight = Instance.new("PointLight")
    pointLight.Brightness = 0.3
    pointLight.Range = 8
    pointLight.Color = Color3.new(1, 0, 0)
    pointLight.Enabled = currentTransparency < 0.7
    pointLight.Parent = topBrick
    
    -- Better placement with rotation consideration
    local targetCFrame = target.CFrame
    local offset = CFrame.new(0, (target.Size.Y/2) + (TOP_HEIGHT/2), 0)
    topBrick.CFrame = targetCFrame * offset
    
    topBrick.Parent = game.Workspace
    
    CollectionService:AddTag(target, TAG_NAME)
    CollectionService:AddTag(topBrick, CREATED_BRICK_TAG)
    
    updateStats()
end

-- Opacity Controls
local function updateOpacity(value)
    currentTransparency = math.clamp(value, 0, 1)
    local displayValue = math.floor(currentTransparency * 10 + 0.5) / 10
    
    opacityLabel.Text = "Top Brick Opacity: " .. displayValue
    opacityValue.Text = tostring(displayValue)
    sliderFill.Size = UDim2.new(currentTransparency, 0, 1, 0)
    sliderButton.Position = UDim2.new(currentTransparency, -10, 0.5, -10)
    
    -- Update all top bricks
    for _, brick in ipairs(CollectionService:GetTagged(CREATED_BRICK_TAG)) do
        brick.Transparency = currentTransparency
        -- Toggle point light based on transparency
        local light = brick:FindFirstChildOfClass("PointLight")
        if light then
            light.Enabled = currentTransparency < 0.7
        end
    end
end

-- Slider functionality
local isSliding = false
sliderButton.MouseButton1Down:Connect(function()
    isSliding = true
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isSliding = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isSliding and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = UserInputService:GetMouseLocation()
        local sliderAbsPos = opacitySlider.AbsolutePosition
        local sliderAbsSize = opacitySlider.AbsoluteSize
        
        local relativeX = (mousePos.X - sliderAbsPos.X) / sliderAbsSize.X
        local newValue = math.clamp(relativeX, 0, 1)
        
        updateOpacity(newValue)
    end
end)

-- Button controls
decreaseOpacity.MouseButton1Click:Connect(function()
    updateOpacity(currentTransparency - 0.1)
end)

increaseOpacity.MouseButton1Click:Connect(function()
    updateOpacity(currentTransparency + 0.1)
end)

-- Main Toggle System
toggleButton.MouseButton1Click:Connect(function()
    active = not active
    
    if active then
        -- Visual feedback
        statusIndicator.BackgroundColor3 = ColorPalette.Success
        statusText.Text = "ACTIVE"
        statusText.TextColor3 = ColorPalette.Success
        toggleButton.Text = "DEACTIVATE SYSTEM"
        toggleButton.BackgroundColor3 = ColorPalette.Warning
        
        -- Animate activation
        TweenService:Create(toggleButton, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0.88, 0, 0, 42)
        }):Play()
        
        task.wait(0.15)
        TweenService:Create(toggleButton, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0.85, 0, 0, 42)
        }):Play()
        
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
        -- Visual feedback
        statusIndicator.BackgroundColor3 = ColorPalette.Danger
        statusText.Text = "INACTIVE"
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

-- Auto-update stats
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
                local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    -- Add glow effect to players when system is active
                    for _, part in ipairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Transparency = 0
                            if part:FindFirstChildOfClass("SurfaceAppearance") then
                                part:FindFirstChildOfClass("SurfaceAppearance"):Destroy()
                            end
                        elseif part:IsA("Decal") then
                            part.Transparency = 0
                        end
                    end
                end
            end
        end
    end
end)

-- Initialize stats
updateStats()

-- Welcome message
task.spawn(function()
    task.wait(1)
    local notification = Instance.new("TextLabel")
    notification.Size = UDim2.new(0, 200, 0, 40)
    notification.Position = UDim2.new(0.5, -100, 0.2, 0)
    notification.BackgroundColor3 = ColorPalette.Primary
    notification.TextColor3 = ColorPalette.Text
    notification.Text = "System Control V8 Loaded"
    notification.Font = Enum.Font.GothamSemibold
    notification.TextSize = 14
    notification.Parent = screenGui
    
    Instance.new("UICorner", notification)
    
    TweenService:Create(notification, TweenInfo.new(0.5), {
        Position = UDim2.new(0.5, -100, 0.15, 0)
    }):Play()
    
    task.wait(2)
    
    TweenService:Create(notification, TweenInfo.new(0.5), {
        Position = UDim2.new(0.5, -100, 0.1, 0),
        BackgroundTransparency = 1,
        TextTransparency = 1
    }):Play()
    
    task.wait(0.5)
    notification:Destroy()
end)
