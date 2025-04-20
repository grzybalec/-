local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

-- Tworzy GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESP_GUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ESPButton"
toggleButton.Size = UDim2.new(0, 120, 0, 40)
toggleButton.Position = UDim2.new(1, -130, 0, 10) -- prawy górny róg
toggleButton.Text = "ESP: OFF"
toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.BorderColor3 = Color3.fromRGB(255, 0, 0)  -- Czerwona obwódka
toggleButton.BorderSizePixel = 3  -- Grubość obwódki
toggleButton.Parent = screenGui

local espEnabled = false

-- Funkcja dodająca ESP do gracza
local function createESP(player)
	if player == localPlayer then return end
	if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
	if player.Character:FindFirstChild("ESP_Highlight") then return end
	
	local highlight = Instance.new("Highlight")
	highlight.Name = "ESP_Highlight"
	highlight.Adornee = player.Character
	highlight.FillColor = Color3.fromRGB(255, 0, 0)  -- Czerwony kolor podświetlenia
	highlight.FillTransparency = 0.5
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.OutlineTransparency = 0
	highlight.Parent = player.Character
	
	-- Dodaje etykietę z odległością pod graczem
	local distanceLabel = Instance.new("TextLabel")
	distanceLabel.Name = "DistanceLabel"
	distanceLabel.Size = UDim2.new(0, 100, 0, 20)
	distanceLabel.Position = UDim2.new(0, 0, 0, 20)
	distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	distanceLabel.BackgroundTransparency = 1
	distanceLabel.TextSize = 14
	distanceLabel.Text = string.format("Distance: %.2f", (player.Character.HumanoidRootPart.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude)
	distanceLabel.Parent = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
	
	-- Aktualizuje odległość w czasie rzeczywistym
	game:GetService("RunService").Heartbeat:Connect(function()
		if player.Character and player.Character:FindFirstChild("DistanceLabel") then
			local distance = (player.Character.HumanoidRootPart.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude
			player.Character.DistanceLabel.Text = string.format("Distance: %.2f", distance)
		end
	end)
end

-- Funkcja usuwająca ESP
local function removeESP(player)
	if player.Character then
		local esp = player.Character:FindFirstChild("ESP_Highlight")
		local label = player.Character:FindFirstChild("DistanceLabel")
		if esp then
			esp:Destroy()
		end
		if label then
			label:Destroy()
		end
	end
end

-- Przełączanie ESP
local function toggleESP()
	espEnabled = not espEnabled
	toggleButton.Text = espEnabled and "ESP: ON" or "ESP: OFF"

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer then
			if espEnabled then
				createESP(player)
			else
				removeESP(player)
			end
		end
	end
end

-- Obsługa przycisku
toggleButton.MouseButton1Click:Connect(toggleESP)

-- Auto-ESP przy respawnie
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		wait(1)
		if espEnabled then
			createESP(player)
		end
	end)
end)

-- Auto-ESP dla graczy już w grze przy dołączeniu
for _, player in ipairs(Players:GetPlayers()) do
	if player ~= localPlayer then
		player.CharacterAdded:Connect(function()
			wait(1)
			if espEnabled then
				createESP(player)
			end
		end)
	end
end
