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

local localPlayer = Players.LocalPlayer
local active = false
local currentTransparency = 0.1
local isMinimized = false
local isDragging = false

--------------------------------------------------------------------------------
-- 1. CREATE COMPACT CIRCULAR UI
--------------------------------------------------------------------------------

-- Colors
local ColorPalette = {
    Primary = Color3.fromRGB(0, 150, 255),
    Secondary = Color3.fromRGB(45, 45, 50),
    Success = Color3.fromRGB(76, 175, 80),
    Danger = Color3.fromRGB(220, 60, 60),
    Text = Color3.fromRGB(245, 245, 245),
    SubText = Color3.fromRGB(180, 180, 180),
    Background = Color3.fromRGB(30, 30, 35, 0.9)
}

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SystemControlV8.2_Compact"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

-- ============================================
-- MINIMIZED CIRCLE BUTTON (Default state)
-- ============================================
local minimizedButton = Instance.new("Frame")
minimizedButton.Name = "MinimizedButton"
minimizedButton.Size = UDim2.new(0, 50, 0, 50)
minimizedButton.Position = UDim2.new(0.95, -25, 0.05, 0) -- Top right corner
minimizedButton.BackgroundColor3 = ColorPalette.Primary
minimizedButton.BackgroundTransparency = 0.1
minimizedButton.Active = true
minimizedButton.Draggable = true
minimizedButton.Parent = screenGui

-- Make it circular
local minimizedCorner = Instance.new("UICorner")
minimizedCorner.CornerRadius = UDim.new(1, 0)
minimizedCorner.Parent = minimizedButton

-- Add shadow effect
local minimizedShadow = Instance.new("ImageLabel")
minimizedShadow.Name = "Shadow"
minimizedShadow.Size = UDim2.new(1, 10, 1, 10)
minimizedShadow.Position = UDim2.new(0, -5, 0, -5)
minimizedShadow.BackgroundTransparency = 1
minimizedShadow.Image = "rbxassetid://1316045217"
minimizedShadow.ImageColor3 = Color3.new(0, 0, 0)
minimizedShadow.ImageTransparency = 0.7
minimizedShadow.ScaleType = Enum.ScaleType.Slice
minimizedShadow.SliceCenter = Rect.new(10, 10, 118, 118)
minimizedShadow.Parent = minimizedButton

-- Icon/Text inside circle
local minimizedIcon = Instance.new("TextLabel")
minimizedIcon.Name = "Icon"
minimizedIcon.Size = UDim2.new(1, 0, 1, 0)
minimizedIcon.BackgroundTransparency = 1
minimizedIcon.Text = "⚙️" -- Gear emoji
minimizedIcon.TextColor3 = ColorPalette.Text
minimizedIcon.Font = Enum.Font.GothamBold
minimizedIcon.TextSize = 20
minimizedIcon.Parent = minimizedButton

-- Status indicator dot
local statusDot = Instance.new("Frame")
statusDot.Name = "StatusDot"
statusDot.Size = UDim2.new(0, 10, 0, 10)
statusDot.Position = UDim2.new(1, -5, 0, -5)
statusDot.BackgroundColor3 = ColorPalette.Danger
statusDot.BorderSizePixel = 0
statusDot.Parent = minimizedButton

local statusDotCorner = Instance.new("UICorner")
statusDotCorner.CornerRadius = UDim.new(1, 0)
statusDotCorner.Parent = statusDot

-- ============================================
-- EXPANDED PANEL (Hidden by default)
-- ============================================
local expandedPanel = Instance.new("Frame")
expandedPanel.Name = "ExpandedPanel"
expandedPanel.Size = UDim2.new(0, 300, 0, 380)
expandedPanel.Position = UDim2.new(0.7, 0, 0.05, 0) -- Appears near the circle
expandedPanel.BackgroundColor3 = ColorPalette.Background
expandedPanel.BackgroundTransparency = 0.1
expandedPanel.Visible = false
expandedPanel.Active = true
expandedPanel.Parent = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 12)
panelCorner.Parent = expandedPanel

local panelShadow = Instance.new("ImageLabel")
panelShadow.Name = "PanelShadow"
panelShadow.Size = UDim2.new(1, 20, 1, 20)
panelShadow.Position = UDim2.new(0, -10, 0, -10)
panelShadow.BackgroundTransparency = 1
panelShadow.Image = "rbxassetid://1316045217"
panelShadow.ImageColor3 = Color3.new(0, 0, 0)
panelShadow.ImageTransparency = 0.8
panelShadow.ScaleType = Enum.ScaleType.Slice
panelShadow.SliceCenter = Rect.new(10, 10, 118, 118)
panelShadow.Parent = expandedPanel

-- Panel Header
local panelHeader = Instance.new("Frame")
panelHeader.Size = UDim2.new(1, 0, 0, 40)
panelHeader.BackgroundColor3 = ColorPalette.Primary
panelHeader.Parent = expandedPanel

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = panelHeader

local panelTitle = Instance.new("TextLabel")
panelTitle.Size = UDim2.new(1, -50, 1, 0)
panelTitle.Position = UDim2.new(0, 12, 0, 0)
panelTitle.BackgroundTransparency = 1
panelTitle.Text = "SYSTEM CONTROL"
panelTitle.TextColor3 = ColorPalette.Text
panelTitle.Font = Enum.Font.GothamBold
panelTitle.TextSize = 16
panelTitle.TextXAlignment = Enum.TextXAlignment.Left
panelTitle.Parent = panelHeader

-- Close button (minimize back to circle)
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0.5, -15)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
closeButton.BackgroundTransparency = 0.9
closeButton.Text = "●" -- Circle/dot symbol
closeButton.TextColor3 = ColorPalette.Text
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 14
closeButton.Parent = panelHeader

local closeButtonCorner = Instance.new("UICorner")
closeButtonCorner.CornerRadius = UDim.new(0, 6)
closeButtonCorner.Parent = closeButton

-- Panel Content
local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Size = UDim2.new(1, 0, 1, -40)
contentFrame.Position = UDim2.new(0, 0, 0, 40)
contentFrame.BackgroundTransparency = 1
contentFrame.ScrollBarThickness = 3
contentFrame.ScrollBarImageColor3 = ColorPalette.Primary
contentFrame.ScrollBarImageTransparency = 0.5
contentFrame.CanvasSize = UDim2.new(0, 0, 0, 400)
contentFrame.Parent = expandedPanel

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 10)
contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
contentLayout.Parent = contentFrame

contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
end)

-- Function to create panel sections
local function createSection(title, height)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(0.92, 0, 0, height)
    section.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    section.Parent = contentFrame
    
    local sectionCorner = Instance.new("UICorner")
    sectionCorner.CornerRadius = UDim.new(0, 8)
    sectionCorner.Parent = section
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -16, 0, 24)
    titleLabel.Position = UDim2.new(0, 8, 0, 4)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = ColorPalette.Primary
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = section
    
    return section
end

-- Status Section
local statusSection = createSection("SYSTEM STATUS", 100)
local statusIndicator = Instance.new("Frame")
statusIndicator.Size = UDim2.new(0, 12, 0, 12)
statusIndicator.Position = UDim2.new(0, 8, 0, 32)
statusIndicator.BackgroundColor3 = ColorPalette.Danger
statusIndicator.Parent = statusSection

local statusIndicatorCorner = Instance.new("UICorner")
statusIndicatorCorner.CornerRadius = UDim.new(1, 0)
statusIndicatorCorner.Parent = statusIndicator

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -28, 0, 20)
statusText.Position = UDim2.new(0, 26, 0, 30)
statusText.BackgroundTransparency = 1
statusText.Text = "INACTIVE"
statusText.TextColor3 = ColorPalette.Danger
statusText.Font = Enum.Font.GothamSemibold
statusText.TextSize = 16
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.Parent = statusSection

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 36)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 56)
toggleBtn.BackgroundColor3 = ColorPalette.Danger
toggleBtn.Text = "ACTIVATE SYSTEM"
toggleBtn.TextColor3 = ColorPalette.Text
toggleBtn.Font = Enum.Font.GothamSemibold
toggleBtn.TextSize = 14
toggleBtn.Parent = statusSection

local toggleBtnCorner = Instance.new("UICorner")
toggleBtnCorner.CornerRadius = UDim.new(0, 6)
toggleBtnCorner.Parent = toggleBtn

-- Opacity Section
local opacitySection = createSection("BRICK OPACITY", 90)
local opacityLabel = Instance.new("TextLabel")
opacityLabel.Size = UDim2.new(1, -16, 0, 20)
opacityLabel.Position = UDim2.new(0, 8, 0, 32)
opacityLabel.BackgroundTransparency = 1
opacityLabel.Text = "Current: 0.1"
opacityLabel.TextColor3 = ColorPalette.SubText
opacityLabel.Font = Enum.Font.Gotham
opacityLabel.TextSize = 13
opacityLabel.TextXAlignment = Enum.TextXAlignment.Left
opacityLabel.Parent = opacitySection

local opacityControls = Instance.new("Frame")
opacityControls.Size = UDim2.new(1, -16, 0, 32)
opacityControls.Position = UDim2.new(0, 8, 0, 56)
opacityControls.BackgroundTransparency = 1
opacityControls.Parent = opacitySection

local decreaseOpacity = Instance.new("TextButton")
decreaseOpacity.Size = UDim2.new(0, 40, 1, 0)
decreaseOpacity.BackgroundColor3 = ColorPalette.Secondary
decreaseOpacity.Text = "−" -- Longer dash
decreaseOpacity.TextColor3 = ColorPalette.Text
decreaseOpacity.Font = Enum.Font.GothamBold
decreaseOpacity.TextSize = 20
decreaseOpacity.Parent = opacityControls

local decreaseCorner = Instance.new("UICorner")
decreaseCorner.CornerRadius = UDim.new(0, 4)
decreaseCorner.Parent = decreaseOpacity

local opacityValue = Instance.new("TextLabel")
opacityValue.Size = UDim2.new(1, -80, 1, 0)
opacityValue.Position = UDim2.new(0, 40, 0, 0)
opacityValue.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
opacityValue.Text = "0.1"
opacityValue.TextColor3 = ColorPalette.Text
opacityValue.Font = Enum.Font.GothamSemibold
opacityValue.TextSize = 15
opacityValue.Parent = opacityControls

local valueCorner = Instance.new("UICorner")
valueCorner.CornerRadius = UDim.new(0, 4)
valueCorner.Parent = opacityValue

local increaseOpacity = Instance.new("TextButton")
increaseOpacity.Size = UDim2.new(0, 40, 1, 0)
increaseOpacity.Position = UDim2.new(1, -40, 0, 0)
increaseOpacity.BackgroundColor3 = ColorPalette.Secondary
increaseOpacity.Text = "+"
increaseOpacity.TextColor3 = ColorPalette.Text
increaseOpacity.Font = Enum.Font.GothamBold
increaseOpacity.TextSize = 20
increaseOpacity.Parent = opacityControls

local increaseCorner = Instance.new("UICorner")
increaseCorner.CornerRadius = UDim.new(0, 4)
increaseCorner.Parent = increaseOpacity

-- Info Section
local infoSection = createSection("INFORMATION", 120)
local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1, -16, 1, -12)
infoText.Position = UDim2.new(0, 8, 0, 32)
infoText.BackgroundTransparency = 1
infoText.Text = "• Detects '"..TARGET_PART_NAME.."' parts\n• Places red glass on top\n• Makes players visible\n• Click gear icon to open"
infoText.TextColor3 = ColorPalette.SubText
infoText.Font = Enum.Font.Gotham
infoText.TextSize = 12
infoText.TextXAlignment = Enum.TextXAlignment.Left
infoText.TextYAlignment = Enum.TextYAlignment.Top
infoText.TextWrapped = true
infoText.Parent = infoSection

-- Stats Section
local statsSection = createSection("STATISTICS", 80)
local statsText = Instance.new("TextLabel")
statsText.Size = UDim2.new(1, -16, 1, -12)
statsText.Position = UDim2.new(0, 8, 0, 32)
statsText.BackgroundTransparency = 1
statsText.Text = "Parts: 0\nBricks: 0"
statsText.TextColor3 = ColorPalette.SubText
statsText.Font = Enum.Font.GothamMedium
statsText.TextSize = 13
statsText.TextXAlignment = Enum.TextXAlignment.Left
statsText.TextYAlignment = Enum.TextYAlignment.Top
statsText.Name = "StatsText"
statsText.Parent = statsSection

--------------------------------------------------------------------------------
-- 2. UI INTERACTIONS - CIRCLE TO PANEL TOGGLE
--------------------------------------------------------------------------------

-- Click circle to expand
minimizedButton.MouseButton1Click:Connect(function()
    if not isDragging then
        -- Hide circle with animation
        TweenService:Create(minimizedButton, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = minimizedButton.Position + UDim2.new(0, 25, 0, 25)
        }):Play()
        
        task.wait(0.15)
        
        -- Show panel with animation
        expandedPanel.Visible = true
        expandedPanel.Size = UDim2.new(0, 0, 0, 0)
        expandedPanel.Position = minimizedButton.Position + UDim2.new(0, -12.5, 0, -12.5)
        
        TweenService:Create(expandedPanel, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 300, 0, 380),
            Position = UDim2.new(minimizedButton.Position.X.Scale, minimizedButton.Position.X.Offset - 150, 
                               minimizedButton.Position.Y.Scale, minimizedButton.Position.Y.Offset)
        }):Play()
        
        minimizedButton.Visible = false
    end
end)

-- Click close button to minimize
closeButton.MouseButton1Click:Connect(function()
    -- Store panel position for circle placement
    local panelPos = expandedPanel.Position
    
    -- Hide panel with animation
    TweenService:Create(expandedPanel, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = panelPos + UDim2.new(0, 150, 0, 190)
    }):Play()
    
    task.wait(0.2)
    
    -- Show circle at panel position
    minimizedButton.Visible = true
    minimizedButton.Size = UDim2.new(0, 0, 0, 0)
    minimizedButton.Position = panelPos + UDim2.new(0, 150, 0, 190)
    
    TweenService:Create(minimizedButton, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 50, 0, 50),
        Position = panelPos + UDim2.new(0, 125, 0, 165)
    }):Play()
    
    task.wait(0.3)
    expandedPanel.Visible = false
end)

-- Dragging for circle
minimizedButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        local dragStart = input.Position
        local startPos = minimizedButton.Position
        
        local connection
        connection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                isDragging = false
                connection:Disconnect()
            end
        end)
        
        local dragConnection
        dragConnection = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and isDragging then
                local delta = input.Position - dragStart
                minimizedButton.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)
        
        -- Disconnect when done
        connection:Disconnect()
        dragConnection:Disconnect()
    end
end)

-- Dragging for panel
panelHeader.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local dragStart = input.Position
        local startPos = expandedPanel.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                return
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                expandedPanel.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)
    end
end)

--------------------------------------------------------------------------------
-- 3. CORE LOGIC FUNCTIONS
--------------------------------------------------------------------------------

local function updateStats()
    local partsDetected = 0
    local topBricksCount = #CollectionService:GetTagged(CREATED_BRICK_TAG)
    
    for _, obj in ipairs(game.Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == TARGET_PART_NAME then
            partsDetected = partsDetected + 1
        end
    end
    
    statsText.Text = string.format("Parts: %d\nBricks: %d", partsDetected, topBricksCount)
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
    
    local offset = CFrame.new(0, (target.Size.Y/2) + (TOP_HEIGHT/2), 0)
    topBrick.CFrame = target.CFrame * offset
    topBrick.Parent = game.Workspace
    
    CollectionService:AddTag(target, TAG_NAME)
    CollectionService:AddTag(topBrick, CREATED_BRICK_TAG)
    
    updateStats()
end

local function updateOpacity(value)
    currentTransparency = math.clamp(value, 0, 1)
    local displayValue = math.floor(currentTransparency * 10 + 0.5) / 10
    
    opacityLabel.Text = "Current: " .. displayValue
    opacityValue.Text = tostring(displayValue)
    
    -- Update status dot color based on transparency
    if expandedPanel.Visible then
        local color = currentTransparency > 0.5 and ColorPalette.Warning or ColorPalette.Success
        TweenService:Create(statusDot, TweenInfo.new(0.3), {BackgroundColor3 = color}):Play()
    end
    
    for _, brick in ipairs(CollectionService:GetTagged(CREATED_BRICK_TAG)) do
        brick.Transparency = currentTransparency
    end
end

-- Opacity controls
decreaseOpacity.MouseButton1Click:Connect(function()
    updateOpacity(currentTransparency - 0.1)
end)

increaseOpacity.MouseButton1Click:Connect(function()
    updateOpacity(currentTransparency + 0.1)
end)

-- Main toggle
toggleBtn.MouseButton1Click:Connect(function()
    active = not active
    
    if active then
        -- Update UI
        statusIndicator.BackgroundColor3 = ColorPalette.Success
        statusText.Text = "ACTIVE"
        statusText.TextColor3 = ColorPalette.Success
        toggleBtn.Text = "DEACTIVATE"
        toggleBtn.BackgroundColor3 = ColorPalette.Warning
        
        -- Update circle status dot
        statusDot.BackgroundColor3 = ColorPalette.Success
        
        -- Activate system
        task.spawn(function()
            for _, obj in ipairs(game.Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name == TARGET_PART_NAME then
                    spawnTopBrick(obj)
                    task.wait()
                end
            end
        end)
    else
        -- Update UI
        statusIndicator.BackgroundColor3 = ColorPalette.Danger
        statusText.Text = "INACTIVE"
        statusText.TextColor3 = ColorPalette.Danger
        toggleBtn.Text = "ACTIVATE"
        toggleBtn.BackgroundColor3 = ColorPalette.Danger
        
        -- Update circle status dot
        statusDot.BackgroundColor3 = ColorPalette.Danger
        
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

-- Auto-update
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

-- Player visibility
RunService.RenderStepped:Connect(function()
    if active then
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if (part:IsA("BasePart") or part:IsA("Decal")) and part.Transparency > 0 then
                        part.Transparency = 0
                    end
                end
            end
        end
    end
end)

-- Initialize
updateStats()

-- Welcome animation for circle
task.spawn(function()
    minimizedButton.Size = UDim2.new(0, 0, 0, 0)
    task.wait(0.5)
    
    TweenService:Create(minimizedButton, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 50, 0, 50)
    }):Play()
    
    -- Pulse effect
    for i = 1, 2 do
        task.wait(0.3)
        TweenService:Create(minimizedButton, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.05
        }):Play()
        
        task.wait(0.2)
        TweenService:Create(minimizedButton, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.15
        }):Play()
    end
end)
