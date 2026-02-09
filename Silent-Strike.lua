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
local isDragging = false

-- Performance optimizations
local lastRenderTime = 0
local renderInterval = 0.1 -- Update every 0.1 seconds instead of every frame
local lastStatUpdate = 0
local statUpdateInterval = 2 -- Update stats every 2 seconds

--------------------------------------------------------------------------------
-- 1. LIGHTWEIGHT UI CREATION (No expensive effects)
--------------------------------------------------------------------------------

-- Simple colors
local ColorPalette = {
    Primary = Color3.fromRGB(0, 150, 255),
    Danger = Color3.fromRGB(220, 60, 60),
    Success = Color3.fromRGB(76, 175, 80),
    Text = Color3.fromRGB(245, 245, 245),
    Background = Color3.fromRGB(30, 30, 35, 0.95)
}

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SystemControl_Optimized"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

-- ============================================
-- MINIMIZED BUTTON (Simple circle)
-- ============================================
local minimizedButton = Instance.new("TextButton") -- Use TextButton for better performance
minimizedButton.Name = "MinimizedButton"
minimizedButton.Size = UDim2.new(0, 45, 0, 45)
minimizedButton.Position = UDim2.new(0.95, -22.5, 0.05, 0)
minimizedButton.BackgroundColor3 = ColorPalette.Primary
minimizedButton.BackgroundTransparency = 0.1
minimizedButton.Text = "⚙"
minimizedButton.TextColor3 = ColorPalette.Text
minimizedButton.Font = Enum.Font.GothamBold
minimizedButton.TextSize = 18
minimizedButton.AutoButtonColor = false
minimizedButton.Parent = screenGui

-- Make it circular
minimizedButton.ClipsDescendants = true

-- Status dot
local statusDot = Instance.new("Frame")
statusDot.Name = "StatusDot"
statusDot.Size = UDim2.new(0, 8, 0, 8)
statusDot.Position = UDim2.new(1, -4, 0, -4)
statusDot.BackgroundColor3 = ColorPalette.Danger
statusDot.BorderSizePixel = 0
statusDot.Parent = minimizedButton

-- ============================================
-- EXPANDED PANEL (Simple and efficient)
-- ============================================
local expandedPanel = Instance.new("Frame")
expandedPanel.Name = "ExpandedPanel"
expandedPanel.Size = UDim2.new(0, 280, 0, 340) -- Smaller size
expandedPanel.Position = UDim2.new(0.7, 0, 0.05, 0)
expandedPanel.BackgroundColor3 = ColorPalette.Background
expandedPanel.BackgroundTransparency = 0.05
expandedPanel.Visible = false
expandedPanel.Parent = screenGui

-- Simple header
local panelHeader = Instance.new("Frame")
panelHeader.Size = UDim2.new(1, 0, 0, 35)
panelHeader.BackgroundColor3 = ColorPalette.Primary
panelHeader.Parent = expandedPanel

local panelTitle = Instance.new("TextLabel")
panelTitle.Size = UDim2.new(1, -40, 1, 0)
panelTitle.Position = UDim2.new(0, 8, 0, 0)
panelTitle.BackgroundTransparency = 1
panelTitle.Text = "CONTROL PANEL"
panelTitle.TextColor3 = ColorPalette.Text
panelTitle.Font = Enum.Font.GothamBold
panelTitle.TextSize = 14
panelTitle.TextXAlignment = Enum.TextXAlignment.Left
panelTitle.Parent = panelHeader

-- Simple close button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -30, 0.5, -12.5)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
closeButton.BackgroundTransparency = 0.8
closeButton.Text = "×"
closeButton.TextColor3 = ColorPalette.Text
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 16
closeButton.AutoButtonColor = false
closeButton.Parent = panelHeader

-- Content area (no scrolling to save performance)
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -35)
contentFrame.Position = UDim2.new(0, 0, 0, 35)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = expandedPanel

-- Simple layout
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = contentFrame

-- Function to create simple sections
local function createSection(title, height)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(0.92, 0, 0, height)
    section.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    section.Parent = contentFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -12, 0, 20)
    titleLabel.Position = UDim2.new(0, 6, 0, 4)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = ColorPalette.Primary
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = section
    
    return section
end

-- Status section
local statusSection = createSection("STATUS", 90)
local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -12, 0, 20)
statusText.Position = UDim2.new(0, 6, 0, 28)
statusText.BackgroundTransparency = 1
statusText.Text = "INACTIVE"
statusText.TextColor3 = ColorPalette.Danger
statusText.Font = Enum.Font.GothamSemibold
statusText.TextSize = 16
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.Parent = statusSection

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 32)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 52)
toggleBtn.BackgroundColor3 = ColorPalette.Danger
toggleBtn.Text = "ACTIVATE"
toggleBtn.TextColor3 = ColorPalette.Text
toggleBtn.Font = Enum.Font.GothamSemibold
toggleBtn.TextSize = 13
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = statusSection

-- Opacity section
local opacitySection = createSection("OPACITY", 80)
local opacityLabel = Instance.new("TextLabel")
opacityLabel.Size = UDim2.new(1, -12, 0, 20)
opacityLabel.Position = UDim2.new(0, 6, 0, 28)
opacityLabel.BackgroundTransparency = 1
opacityLabel.Text = "Value: 0.1"
opacityLabel.TextColor3 = ColorPalette.Text
opacityLabel.Font = Enum.Font.Gotham
opacityLabel.TextSize = 12
opacityLabel.TextXAlignment = Enum.TextXAlignment.Left
opacityLabel.Parent = opacitySection

local opacityControls = Instance.new("Frame")
opacityControls.Size = UDim2.new(1, -12, 0, 28)
opacityControls.Position = UDim2.new(0, 6, 0, 48)
opacityControls.BackgroundTransparency = 1
opacityControls.Parent = opacitySection

local decreaseBtn = Instance.new("TextButton")
decreaseBtn.Size = UDim2.new(0, 36, 1, 0)
decreaseBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
decreaseBtn.Text = "-"
decreaseBtn.TextColor3 = ColorPalette.Text
decreaseBtn.Font = Enum.Font.GothamBold
decreaseBtn.TextSize = 18
decreaseBtn.AutoButtonColor = false
decreaseBtn.Parent = opacityControls

local opacityValue = Instance.new("TextLabel")
opacityValue.Size = UDim2.new(1, -72, 1, 0)
opacityValue.Position = UDim2.new(0, 36, 0, 0)
opacityValue.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
opacityValue.Text = "0.1"
opacityValue.TextColor3 = ColorPalette.Text
opacityValue.Font = Enum.Font.GothamSemibold
opacityValue.TextSize = 14
opacityValue.Parent = opacityControls

local increaseBtn = Instance.new("TextButton")
increaseBtn.Size = UDim2.new(0, 36, 1, 0)
increaseBtn.Position = UDim2.new(1, -36, 0, 0)
increaseBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
increaseBtn.Text = "+"
increaseBtn.TextColor3 = ColorPalette.Text
increaseBtn.Font = Enum.Font.GothamBold
increaseBtn.TextSize = 18
increaseBtn.AutoButtonColor = false
increaseBtn.Parent = opacityControls

-- Info section
local infoSection = createSection("INFO", 70)
local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1, -12, 1, -10)
infoText.Position = UDim2.new(0, 6, 0, 24)
infoText.BackgroundTransparency = 1
infoText.Text = "Click gear to open\nClose with × button"
infoText.TextColor3 = Color3.fromRGB(180, 180, 180)
infoText.Font = Enum.Font.Gotham
infoText.TextSize = 11
infoText.TextXAlignment = Enum.TextXAlignment.Left
infoText.TextYAlignment = Enum.TextYAlignment.Top
infoText.Parent = infoSection

-- Stats section
local statsSection = createSection("STATS", 50)
local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, -12, 1, -10)
statsLabel.Position = UDim2.new(0, 6, 0, 24)
statsLabel.BackgroundTransparency = 1
statsLabel.Text = "Parts: 0 | Bricks: 0"
statsLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statsLabel.Font = Enum.Font.GothamMedium
statsLabel.TextSize = 12
statsLabel.TextXAlignment = Enum.TextXAlignment.Left
statsLabel.Name = "StatsLabel"
statsLabel.Parent = statsSection

--------------------------------------------------------------------------------
-- 2. OPTIMIZED UI INTERACTIONS (No expensive tweens)
--------------------------------------------------------------------------------

-- Simple toggle with minimal animations
minimizedButton.MouseButton1Click:Connect(function()
    if not isDragging then
        minimizedButton.Visible = false
        expandedPanel.Visible = true
        expandedPanel.Position = UDim2.new(
            minimizedButton.Position.X.Scale - 0.1,
            minimizedButton.Position.X.Offset,
            minimizedButton.Position.Y.Scale,
            minimizedButton.Position.Y.Offset
        )
    end
end)

closeButton.MouseButton1Click:Connect(function()
    expandedPanel.Visible = false
    minimizedButton.Visible = true
end)

-- Simple dragging for circle
local dragStart, startPos
minimizedButton.MouseButton1Down:Connect(function()
    isDragging = true
    dragStart = UserInputService:GetMouseLocation()
    startPos = minimizedButton.Position
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local currentMouse = UserInputService:GetMouseLocation()
        local delta = currentMouse - dragStart
        minimizedButton.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- Simple dragging for panel
panelHeader.MouseButton1Down:Connect(function()
    local dragStart = UserInputService:GetMouseLocation()
    local startPos = expandedPanel.Position
    
    local connection
    connection = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local currentMouse = UserInputService:GetMouseLocation()
            local delta = currentMouse - dragStart
            expandedPanel.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            connection:Disconnect()
        end
    end)
end)

--------------------------------------------------------------------------------
-- 3. OPTIMIZED CORE LOGIC (FIXED LAG ISSUES)
--------------------------------------------------------------------------------

-- Cache for performance
local topBrickCache = {}
local targetPartsCache = {}

local function updateStats()
    local currentTime = tick()
    if currentTime - lastStatUpdate < statUpdateInterval then
        return
    end
    lastStatUpdate = currentTime
    
    -- Use cached values when possible
    local topBricksCount = #CollectionService:GetTagged(CREATED_BRICK_TAG)
    
    -- Only count parts if cache is empty or system is active
    local partsDetected = #targetPartsCache
    if partsDetected == 0 or active then
        partsDetected = 0
        targetPartsCache = {} -- Clear cache
        
        -- Only scan workspace when needed
        for _, obj in ipairs(game.Workspace:GetChildren()) do
            if obj:IsA("BasePart") and obj.Name == TARGET_PART_NAME then
                partsDetected = partsDetected + 1
                table.insert(targetPartsCache, obj)
            end
        end
    end
    
    statsLabel.Text = string.format("Parts: %d | Bricks: %d", partsDetected, topBricksCount)
end

-- Optimized function to spawn top bricks
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
    
    -- Simple placement (no complex calculations)
    local offset = target.Position + Vector3.new(0, target.Size.Y/2 + TOP_HEIGHT/2, 0)
    topBrick.Position = offset
    topBrick.CFrame = CFrame.new(offset) * target.CFrame.Rotation
    
    topBrick.Parent = game.Workspace
    
    CollectionService:AddTag(target, TAG_NAME)
    CollectionService:AddTag(topBrick, CREATED_BRICK_TAG)
    
    -- Cache the brick
    table.insert(topBrickCache, topBrick)
end

-- Optimized opacity update
local function updateOpacity(value)
    currentTransparency = math.clamp(value, 0, 1)
    local displayValue = math.floor(currentTransparency * 10 + 0.5) / 10
    
    opacityLabel.Text = "Value: " .. displayValue
    opacityValue.Text = tostring(displayValue)
    
    -- Update status dot
    statusDot.BackgroundColor3 = currentTransparency > 0.5 and Color3.fromRGB(255, 193, 7) or ColorPalette.Success
    
    -- Batch update bricks (more efficient)
    local bricks = CollectionService:GetTagged(CREATED_BRICK_TAG)
    for i = 1, #bricks do
        bricks[i].Transparency = currentTransparency
    end
end

-- Opacity controls
decreaseBtn.MouseButton1Click:Connect(function()
    updateOpacity(currentTransparency - 0.1)
end)

increaseBtn.MouseButton1Click:Connect(function()
    updateOpacity(currentTransparency + 0.1)
end)

-- Main toggle (optimized)
toggleBtn.MouseButton1Click:Connect(function()
    active = not active
    
    if active then
        -- Update UI
        statusText.Text = "ACTIVE"
        statusText.TextColor3 = ColorPalette.Success
        toggleBtn.Text = "DEACTIVATE"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 193, 7) -- Warning color
        statusDot.BackgroundColor3 = ColorPalette.Success
        
        -- Activate system with delay to prevent lag
        task.spawn(function()
            local parts = {}
            
            -- First pass: collect all target parts
            for _, obj in ipairs(game.Workspace:GetChildren()) do
                if obj:IsA("BasePart") and obj.Name == TARGET_PART_NAME then
                    table.insert(parts, obj)
                end
            end
            
            -- Second pass: spawn bricks with delay
            for i, part in ipairs(parts) do
                spawnTopBrick(part)
                if i % 10 == 0 then -- Process 10 parts, then wait
                    task.wait()
                end
            end
            
            updateStats()
        end)
    else
        -- Update UI
        statusText.Text = "INACTIVE"
        statusText.TextColor3 = ColorPalette.Danger
        toggleBtn.Text = "ACTIVATE"
        toggleBtn.BackgroundColor3 = ColorPalette.Danger
        statusDot.BackgroundColor3 = ColorPalette.Danger
        
        -- Batch destroy bricks (more efficient)
        local bricks = CollectionService:GetTagged(CREATED_BRICK_TAG)
        for i = 1, #bricks do
            bricks[i]:Destroy()
        end
        
        -- Clear tags
        local tagged = CollectionService:GetTagged(TAG_NAME)
        for i = 1, #tagged do
            CollectionService:RemoveTag(tagged[i], TAG_NAME)
        end
        
        -- Clear caches
        topBrickCache = {}
        updateStats()
    end
end)

-- Optimized auto-detection (less frequent checks)
local lastScanTime = 0
local scanInterval = 1 -- Scan every 1 second

game.Workspace.ChildAdded:Connect(function(child)
    if active and child:IsA("BasePart") and child.Name == TARGET_PART_NAME then
        spawnTopBrick(child)
        updateStats()
    end
end)

-- Optimized player visibility system (FIXED LAG)
local lastVisibilityUpdate = 0
local visibilityUpdateInterval = 0.3 -- Update every 0.3 seconds instead of every frame

RunService.Heartbeat:Connect(function() -- Use Heartbeat instead of RenderStepped
    local currentTime = tick()
    
    -- Update visibility less frequently
    if active and currentTime - lastVisibilityUpdate > visibilityUpdateInterval then
        lastVisibilityUpdate = currentTime
        
        -- Only process local player for performance
        local character = localPlayer.Character
        if character then
            -- Only make specific parts visible, not everything
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                humanoidRootPart.Transparency = 0
                
                -- Only process a few key parts
                local partsToCheck = {
                    character:FindFirstChild("Head"),
                    character:FindFirstChild("UpperTorso"),
                    character:FindFirstChild("LowerTorso")
                }
                
                for _, part in ipairs(partsToCheck) do
                    if part and part.Transparency > 0 then
                        part.Transparency = 0
                    end
                end
            end
        end
    end
    
    -- Update stats less frequently
    if currentTime - lastStatUpdate > statUpdateInterval then
        updateStats()
    end
end)

-- Initialize
updateStats()

-- Simple startup
task.spawn(function()
    task.wait(1)
    -- Just make button visible, no fancy animations
    minimizedButton.BackgroundTransparency = 0.1
end)

-- Cleanup on script end
game:GetService("UserInputService").WindowFocused:Connect(function()
    if not screenGui:IsDescendantOf(game) then
        -- Clean up if script is destroyed
        for _, brick in ipairs(CollectionService:GetTagged(CREATED_BRICK_TAG)) do
            brick:Destroy()
        end
    end
end)
