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

-- Wait for player to load
while not localPlayer.Character do
    task.wait(0.5)
end

--------------------------------------------------------------------------------
-- 1. CREATE SIMPLE WORKING UI
--------------------------------------------------------------------------------

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SystemControl_Working"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 100
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

print("ScreenGui created")

-- ============================================
-- MINIMIZED BUTTON (Always visible)
-- ============================================
local minimizedButton = Instance.new("TextButton")
minimizedButton.Name = "MinimizedButton"
minimizedButton.Size = UDim2.new(0, 50, 0, 50)
minimizedButton.Position = UDim2.new(0.95, -25, 0.05, 0)
minimizedButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
minimizedButton.Text = "⚙"
minimizedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizedButton.Font = Enum.Font.GothamBold
minimizedButton.TextSize = 24
minimizedButton.AutoButtonColor = false
minimizedButton.Parent = screenGui

-- Make it circular
local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(1, 0)
circleCorner.Parent = minimizedButton

-- Status dot
local statusDot = Instance.new("Frame")
statusDot.Name = "StatusDot"
statusDot.Size = UDim2.new(0, 10, 0, 10)
statusDot.Position = UDim2.new(1, -5, 0, -5)
statusDot.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
statusDot.BorderSizePixel = 0
statusDot.Parent = minimizedButton

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = statusDot

print("Minimized button created")

-- ============================================
-- EXPANDED PANEL (Hidden initially)
-- ============================================
local expandedPanel = Instance.new("Frame")
expandedPanel.Name = "ExpandedPanel"
expandedPanel.Size = UDim2.new(0, 280, 0, 340)
expandedPanel.Position = UDim2.new(0.5, -140, 0.5, -170)
expandedPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
expandedPanel.BackgroundTransparency = 0.05
expandedPanel.Visible = false
expandedPanel.Parent = screenGui

-- Add a border so we can see it
local panelBorder = Instance.new("UIStroke")
panelBorder.Thickness = 2
panelBorder.Color = Color3.fromRGB(0, 150, 255)
panelBorder.Parent = expandedPanel

-- Header
local panelHeader = Instance.new("Frame")
panelHeader.Size = UDim2.new(1, 0, 0, 40)
panelHeader.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
panelHeader.Parent = expandedPanel

local panelTitle = Instance.new("TextLabel")
panelTitle.Size = UDim2.new(1, -50, 1, 0)
panelTitle.Position = UDim2.new(0, 10, 0, 0)
panelTitle.BackgroundTransparency = 1
panelTitle.Text = "SYSTEM CONTROL"
panelTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
panelTitle.Font = Enum.Font.GothamBold
panelTitle.TextSize = 16
panelTitle.TextXAlignment = Enum.TextXAlignment.Left
panelTitle.Parent = panelHeader

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0.5, -15)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
closeButton.BackgroundTransparency = 0.8
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(0, 0, 0)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 14
closeButton.AutoButtonColor = false
closeButton.Parent = panelHeader

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

-- Content area
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -40)
contentFrame.Position = UDim2.new(0, 0, 0, 40)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = expandedPanel

-- Create sections with clear borders so we can see them
local function createSection(title, height, yPosition)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(0.9, 0, 0, height)
    section.Position = UDim2.new(0.05, 0, 0, yPosition)
    section.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    section.Parent = contentFrame
    
    -- Add border so we can see it
    local sectionBorder = Instance.new("UIStroke")
    sectionBorder.Thickness = 1
    sectionBorder.Color = Color3.fromRGB(60, 60, 65)
    sectionBorder.Parent = section
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -10, 0, 25)
    titleLabel.Position = UDim2.new(0, 5, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = section
    
    return section
end

-- Status section (at y = 10)
local statusSection = createSection("SYSTEM STATUS", 90, 10)

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -10, 0, 25)
statusText.Position = UDim2.new(0, 5, 0, 30)
statusText.BackgroundTransparency = 1
statusText.Text = "INACTIVE"
statusText.TextColor3 = Color3.fromRGB(220, 60, 60)
statusText.Font = Enum.Font.GothamBold
statusText.TextSize = 18
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.Parent = statusSection

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Size = UDim2.new(0.9, 0, 0, 35)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 55)
toggleBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
toggleBtn.Text = "ACTIVATE SYSTEM"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamSemibold
toggleBtn.TextSize = 14
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = statusSection

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 6)
toggleCorner.Parent = toggleBtn

-- Opacity section (at y = 110)
local opacitySection = createSection("BRICK OPACITY", 80, 110)

local opacityLabel = Instance.new("TextLabel")
opacityLabel.Size = UDim2.new(1, -10, 0, 20)
opacityLabel.Position = UDim2.new(0, 5, 0, 30)
opacityLabel.BackgroundTransparency = 1
opacityLabel.Text = "Current: 0.1"
opacityLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
opacityLabel.Font = Enum.Font.Gotham
opacityLabel.TextSize = 13
opacityLabel.TextXAlignment = Enum.TextXAlignment.Left
opacityLabel.Parent = opacitySection

-- Opacity controls
local opacityControls = Instance.new("Frame")
opacityControls.Size = UDim2.new(1, -10, 0, 30)
opacityControls.Position = UDim2.new(0, 5, 0, 50)
opacityControls.BackgroundTransparency = 1
opacityControls.Parent = opacitySection

local decreaseBtn = Instance.new("TextButton")
decreaseBtn.Name = "DecreaseOpacity"
decreaseBtn.Size = UDim2.new(0, 35, 1, 0)
decreaseBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
decreaseBtn.Text = "-"
decreaseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
decreaseBtn.Font = Enum.Font.GothamBold
decreaseBtn.TextSize = 18
decreaseBtn.AutoButtonColor = false
decreaseBtn.Parent = opacityControls

local opacityValue = Instance.new("TextLabel")
opacityValue.Name = "OpacityValue"
opacityValue.Size = UDim2.new(1, -70, 1, 0)
opacityValue.Position = UDim2.new(0, 35, 0, 0)
opacityValue.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
opacityValue.Text = "0.1"
opacityValue.TextColor3 = Color3.fromRGB(255, 255, 255)
opacityValue.Font = Enum.Font.GothamSemibold
opacityValue.TextSize = 16
opacityValue.Parent = opacityControls

local increaseBtn = Instance.new("TextButton")
increaseBtn.Name = "IncreaseOpacity"
increaseBtn.Size = UDim2.new(0, 35, 1, 0)
increaseBtn.Position = UDim2.new(1, -35, 0, 0)
increaseBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
increaseBtn.Text = "+"
increaseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
increaseBtn.Font = Enum.Font.GothamBold
increaseBtn.TextSize = 18
increaseBtn.AutoButtonColor = false
increaseBtn.Parent = opacityControls

-- Stats section (at y = 200)
local statsSection = createSection("STATISTICS", 60, 200)

local statsLabel = Instance.new("TextLabel")
statsLabel.Name = "StatsLabel"
statsLabel.Size = UDim2.new(1, -10, 1, -10)
statsLabel.Position = UDim2.new(0, 5, 0, 5)
statsLabel.BackgroundTransparency = 1
statsLabel.Text = "Parts: 0 | Bricks: 0"
statsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statsLabel.Font = Enum.Font.GothamMedium
statsLabel.TextSize = 13
statsLabel.TextXAlignment = Enum.TextXAlignment.Left
statsLabel.Parent = statsSection

-- Info section (at y = 270)
local infoSection = createSection("INFORMATION", 50, 270)

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -10, 1, -10)
infoLabel.Position = UDim2.new(0, 5, 0, 5)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Click gear to open/close"
infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 12
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.Parent = infoSection

print("All UI elements created")

--------------------------------------------------------------------------------
-- 2. SIMPLE UI INTERACTIONS (DEBUGGED)
--------------------------------------------------------------------------------

-- Debug print
print("Setting up button events...")

-- Click gear to open panel
minimizedButton.MouseButton1Click:Connect(function()
    print("Gear button clicked!")
    minimizedButton.Visible = false
    expandedPanel.Visible = true
    expandedPanel.Position = UDim2.new(0.5, -140, 0.5, -170) -- Center on screen
    print("Panel should be visible now")
end)

-- Click X to close panel
closeButton.MouseButton1Click:Connect(function()
    print("Close button clicked!")
    expandedPanel.Visible = false
    minimizedButton.Visible = true
    print("Panel hidden, gear visible")
end)

-- Make panel draggable
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

print("Button events setup complete")

--------------------------------------------------------------------------------
-- 3. CORE SYSTEM FUNCTIONS
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
    
    statsLabel.Text = string.format("Parts: %d | Bricks: %d", partsDetected, topBricksCount)
    print("Stats updated:", partsDetected, "parts,", topBricksCount, "bricks")
end

local function spawnTopBrick(target)
    if CollectionService:HasTag(target, TAG_NAME) then
        print("Part already has top brick:", target.Name)
        return 
    end
    
    print("Spawning top brick for:", target.Name)
    
    local topBrick = Instance.new("Part")
    topBrick.Name = "TopBrick"
    topBrick.Size = Vector3.new(target.Size.X, TOP_HEIGHT, target.Size.Z)
    topBrick.Anchored = true
    topBrick.CanCollide = false
    topBrick.BrickColor = BrickColor.new("Bright red")
    topBrick.Material = Enum.Material.Neon
    topBrick.Transparency = currentTransparency
    
    -- Simple placement
    local offset = target.Position + Vector3.new(0, target.Size.Y/2 + TOP_HEIGHT/2, 0)
    topBrick.Position = offset
    topBrick.CFrame = CFrame.new(offset) * target.CFrame.Rotation
    
    topBrick.Parent = game.Workspace
    
    CollectionService:AddTag(target, TAG_NAME)
    CollectionService:AddTag(topBrick, CREATED_BRICK_TAG)
    
    print("Top brick created at position:", offset)
end

local function updateOpacity(value)
    currentTransparency = math.clamp(value, 0, 1)
    local displayValue = math.floor(currentTransparency * 10 + 0.5) / 10
    
    opacityLabel.Text = "Current: " .. displayValue
    opacityValue.Text = tostring(displayValue)
    
    -- Update status dot color
    if currentTransparency > 0.5 then
        statusDot.BackgroundColor3 = Color3.fromRGB(255, 193, 7) -- Yellow
    else
        statusDot.BackgroundColor3 = Color3.fromRGB(76, 175, 80) -- Green
    end
    
    -- Update all bricks
    local bricks = CollectionService:GetTagged(CREATED_BRICK_TAG)
    print("Updating opacity for", #bricks, "bricks to", displayValue)
    
    for i = 1, #bricks do
        bricks[i].Transparency = currentTransparency
    end
end

-- Opacity controls
decreaseBtn.MouseButton1Click:Connect(function()
    print("Decrease opacity clicked")
    updateOpacity(currentTransparency - 0.1)
end)

increaseBtn.MouseButton1Click:Connect(function()
    print("Increase opacity clicked")
    updateOpacity(currentTransparency + 0.1)
end)

-- Main toggle button
toggleBtn.MouseButton1Click:Connect(function()
    print("Toggle button clicked. Current state:", active)
    active = not active
    
    if active then
        -- Update UI
        print("Activating system...")
        statusText.Text = "ACTIVE"
        statusText.TextColor3 = Color3.fromRGB(76, 175, 80)
        toggleBtn.Text = "DEACTIVATE SYSTEM"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 193, 7)
        statusDot.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
        
        -- Activate system
        task.spawn(function()
            local parts = {}
            
            -- Find all target parts
            for _, obj in ipairs(game.Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name == TARGET_PART_NAME then
                    table.insert(parts, obj)
                end
            end
            
            print("Found", #parts, "target parts")
            
            -- Create top bricks
            for i, part in ipairs(parts) do
                spawnTopBrick(part)
                if i % 5 == 0 then -- Small delay every 5 parts
                    task.wait()
                end
            end
            
            updateStats()
        end)
    else
        -- Update UI
        print("Deactivating system...")
        statusText.Text = "INACTIVE"
        statusText.TextColor3 = Color3.fromRGB(220, 60, 60)
        toggleBtn.Text = "ACTIVATE SYSTEM"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        statusDot.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        
        -- Remove all top bricks
        local bricks = CollectionService:GetTagged(CREATED_BRICK_TAG)
        print("Removing", #bricks, "top bricks")
        
        for i = 1, #bricks do
            bricks[i]:Destroy()
        end
        
        -- Remove tags
        local tagged = CollectionService:GetTagged(TAG_NAME)
        for i = 1, #tagged do
            CollectionService:RemoveTag(tagged[i], TAG_NAME)
        end
        
        updateStats()
    end
end)

-- Auto-detection for new parts
game.Workspace.DescendantAdded:Connect(function(descendant)
    if active and descendant:IsA("BasePart") and descendant.Name == TARGET_PART_NAME then
        print("New part detected:", descendant.Name)
        spawnTopBrick(descendant)
        updateStats()
    end
end)

-- Update stats periodically
task.spawn(function()
    while true do
        updateStats()
        task.wait(3) -- Update every 3 seconds
    end
end)

-- Player visibility (simple version)
RunService.Heartbeat:Connect(function()
    if active and localPlayer.Character then
        local humanoidRootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.Transparency = 0
            
            -- Make sure player is visible
            local head = localPlayer.Character:FindFirstChild("Head")
            if head then
                head.Transparency = 0
            end
        end
    end
end)

-- Initial setup
print("System Control initialized!")
print("Look for the blue gear icon in the top-right corner")
print("Click it to open the control panel")

-- Make sure gear is visible
minimizedButton.Visible = true

-- Test print to confirm script is running
task.spawn(function()
    task.wait(1)
    print("=== SYSTEM CONTROL V8 READY ===")
    print("Click the blue gear icon (⚙) to open controls")
    print("Target part name:", TARGET_PART_NAME)
end)
