local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ESP_Enabled = true
local ESP_Objects = {}

local function getRainbowColor()
    return Color3.fromHSV(tick() % 5 / 5, 1, 1)
end

local function createESP(player)
    if player == LocalPlayer then return end
    if not player.Character then return end
    
    local char = player.Character
    local head = char:FindFirstChild("Head")
    if not head then return end
    
    local tracer = Drawing.new("Line")
    tracer.Thickness = 2
    tracer.Transparency = 1

    local nameTag = Drawing.new("Text")
    nameTag.Size = 18
    nameTag.Center = true
    nameTag.Outline = true

    local distanceText = Drawing.new("Text")
    distanceText.Size = 16
    distanceText.Center = true
    distanceText.Outline = true

    local hitbox = Drawing.new("Square")
    hitbox.Thickness = 2
    hitbox.Filled = false

    ESP_Objects[player] = {tracer, nameTag, distanceText, hitbox}

    RunService.RenderStepped:Connect(function()
        if not player or not player.Character or not player.Character:FindFirstChild("Head") then
            for _, obj in pairs(ESP_Objects[player] or {}) do
                obj:Remove()
            end
            ESP_Objects[player] = nil
            return
        end

        local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
        local torsoPos, torsoOnScreen = Camera:WorldToViewportPoint(char.PrimaryPart.Position)

        if onScreen and ESP_Enabled then
            local color = getRainbowColor()

            tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            tracer.To = Vector2.new(headPos.X, headPos.Y)
            tracer.Color = color
            tracer.Visible = true

            nameTag.Text = player.Name
            nameTag.Position = Vector2.new(headPos.X, headPos.Y - 20)
            nameTag.Color = color
            nameTag.Visible = true

            local dist = (Camera.CFrame.Position - head.Position).Magnitude
            distanceText.Text = string.format("[%d Studs]", math.floor(dist))
            distanceText.Position = Vector2.new(headPos.X, headPos.Y + 20)
            distanceText.Color = color
            distanceText.Visible = true

            local size = Vector2.new(50 / headPos.Z, 70 / headPos.Z)
            hitbox.Position = Vector2.new(torsoPos.X - size.X / 2, torsoPos.Y - size.Y / 2)
            hitbox.Size = size
            hitbox.Color = color
            hitbox.Visible = true
        else
            tracer.Visible = false
            nameTag.Visible = false
            distanceText.Visible = false
            hitbox.Visible = false
        end
    end)
end

local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if not ESP_Objects[player] then
            createESP(player)
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.P then
        ESP_Enabled = not ESP_Enabled
    end
end)

while true do
    updateESP()
    wait(1)
end


-- P to enable / disable esp!
