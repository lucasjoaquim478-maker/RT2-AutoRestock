--[[
  Retail Tycoon 2 - Auto Restock Bot
  Uso: Copie e cole no seu executor (Medium)
  Configure os produtos e quantidades pela UI que aparece no jogo
]]

-- ─── Services ───
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- ─── Config ───
local config = {
  enabled = true,
  checkInterval = 3,
  defaultMinStock = 15,
  autoBuy = true,
  instantDelivery = false,
  restockDelay = 1,
  products = {},
  ignoredProducts = {},
}

-- ─── UI ───
local gui = Instance.new("ScreenGui")
gui.Name = "RT2Restock"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 500)
frame.Position = UDim2.new(0.5, -200, 0.5, -250)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BackgroundTransparency = 0.08
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local uc = Instance.new("UICorner")
uc.CornerRadius = UDim.new(0, 8)
uc.Parent = frame

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
titleBar.BorderSizePixel = 0
titleBar.Parent = frame

local titleUc = Instance.new("UICorner")
titleUc.CornerRadius = UDim.new(0, 8)
titleUc.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -40, 1, 0)
titleText.BackgroundTransparent = true
titleText.Text = "🛒 Auto Restock - Retail Tycoon 2"
titleText.TextColor3 = Color3.fromRGB(200, 200, 220)
titleText.TextSize = 14
titleText.Font = Enum.Font.GothamSemibold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Position = UDim2.new(0, 12, 0, 0)
titleText.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -34, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar
local closeUc = Instance.new("UICorner")
closeUc.CornerRadius = UDim.new(0, 6)
closeUc.Parent = closeBtn
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Scrollable product list
local productList = Instance.new("ScrollingFrame")
productList.Size = UDim2.new(1, -16, 1, -110)
productList.Position = UDim2.new(0, 8, 0, 44)
productList.BackgroundTransparent = true
productList.BorderSizePixel = 0
productList.ScrollBarThickness = 6
productList.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 80)
productList.Parent = frame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.SortOrder = Enum.SortOrder.Name
listLayout.Parent = productList

-- Bottom bar
local bottomBar = Instance.new("Frame")
bottomBar.Size = UDim2.new(1, 0, 0, 52)
bottomBar.Position = UDim2.new(0, 0, 1, -52)
bottomBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
bottomBar.BorderSizePixel = 0
bottomBar.Parent = frame

local bottomUc = Instance.new("UICorner")
bottomUc.CornerRadius = UDim.new(0, 8)
bottomUc.Parent = bottomBar

local scanBtn = Instance.new("TextButton")
scanBtn.Size = UDim2.new(0, 120, 0, 32)
scanBtn.Position = UDim2.new(0, 10, 0, 10)
scanBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
scanBtn.BorderSizePixel = 0
scanBtn.Text = "🔍 Scan Products"
scanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
scanBtn.TextSize = 13
scanBtn.Font = Enum.Font.GothamSemibold
scanBtn.Parent = bottomBar
local scanUc = Instance.new("UICorner")
scanUc.CornerRadius = UDim.new(0, 6)
scanUc.Parent = scanBtn

local autoToggle = Instance.new("TextButton")
autoToggle.Size = UDim2.new(0, 130, 0, 32)
autoToggle.Position = UDim2.new(1, -140, 0, 10)
autoToggle.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
autoToggle.BorderSizePixel = 0
autoToggle.Text = "✅ Auto ON"
autoToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
autoToggle.TextSize = 13
autoToggle.Font = Enum.Font.GothamSemibold
autoToggle.Parent = bottomBar
local autoUc = Instance.new("UICorner")
autoUc.CornerRadius = UDim.new(0, 6)
autoUc.Parent = autoToggle

-- Status bar
local statusBar = Instance.new("TextLabel")
statusBar.Size = UDim2.new(1, -16, 0, 24)
statusBar.Position = UDim2.new(0, 8, 1, -100)
statusBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
statusBar.BackgroundTransparency = 0.3
statusBar.Text = "Status: Idle"
statusBar.TextColor3 = Color3.fromRGB(160, 160, 180)
statusBar.TextSize = 12
statusBar.Font = Enum.Font.Gotham
statusBar.Parent = frame
local statusUc = Instance.new("UICorner")
statusUc.CornerRadius = UDim.new(0, 4)
statusUc.Parent = statusBar

-- ─── UI Helpers ───

local function setStatus(text, color)
  statusBar.Text = text
  if color then statusBar.TextColor3 = color end
end

local function updateToggleBtn()
  autoToggle.Text = config.enabled and "✅ Auto ON" or "❌ Auto OFF"
  autoToggle.BackgroundColor3 = config.enabled and Color3.fromRGB(50, 180, 80) or Color3.fromRGB(180, 50, 50)
end

local function createProductRow(productName, currentStock, minStock)
  local row = Instance.new("Frame")
  row.Size = UDim2.new(1, -10, 0, 40)
  row.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
  row.BackgroundTransparency = 0.3
  row.BorderSizePixel = 0
  row.Parent = productList

  local rowUc = Instance.new("UICorner")
  rowUc.CornerRadius = UDim.new(0, 6)
  rowUc.Parent = row

  local nameLbl = Instance.new("TextLabel")
  nameLbl.Size = UDim2.new(0, 160, 1, 0)
  nameLbl.Position = UDim2.new(0, 8, 0, 0)
  nameLbl.BackgroundTransparent = true
  nameLbl.Text = productName
  nameLbl.TextColor3 = Color3.fromRGB(200, 200, 220)
  nameLbl.TextSize = 12
  nameLbl.Font = Enum.Font.Gotham
  nameLbl.TextXAlignment = Enum.TextXAlignment.Left
  nameLbl.Parent = row

  local stockLbl = Instance.new("TextLabel")
  stockLbl.Size = UDim2.new(0, 50, 1, 0)
  stockLbl.Position = UDim2.new(0, 172, 0, 0)
  stockLbl.BackgroundTransparent = true
  stockLbl.Text = tostring(currentStock or 0)
  stockLbl.TextColor3 = (currentStock or 0) <= minStock and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(140, 200, 140)
  stockLbl.TextSize = 13
  stockLbl.Font = Enum.Font.GothamSemibold
  stockLbl.Parent = row

  local spacer = Instance.new("TextLabel")
  spacer.Size = UDim2.new(0, 8, 1, 0)
  spacer.Position = UDim2.new(0, 228, 0, 0)
  spacer.BackgroundTransparent = true
  spacer.Text = "|"
  spacer.TextColor3 = Color3.fromRGB(60, 60, 80)
  spacer.TextSize = 14
  spacer.Parent = row

  local minBox = Instance.new("TextBox")
  minBox.Size = UDim2.new(0, 50, 0, 26)
  minBox.Position = UDim2.new(0, 240, 0, 7)
  minBox.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
  minBox.BorderSizePixel = 0
  minBox.Text = tostring(minStock)
  minBox.TextColor3 = Color3.fromRGB(220, 220, 240)
  minBox.TextSize = 12
  minBox.Font = Enum.Font.Gotham
  minBox.ClearTextOnFocus = true
  minBox.Parent = row

  local minUc = Instance.new("UICorner")
  minUc.CornerRadius = UDim.new(0, 4)
  minUc.Parent = minBox

  local minLbl = Instance.new("TextLabel")
  minLbl.Size = UDim2.new(0, 50, 1, 0)
  minLbl.Position = UDim2.new(0, 295, 0, 0)
  minLbl.BackgroundTransparent = true
  minLbl.Text = "min"
  minLbl.TextColor3 = Color3.fromRGB(130, 130, 150)
  minLbl.TextSize = 11
  minLbl.Font = Enum.Font.Gotham
  minLbl.TextXAlignment = Enum.TextXAlignment.Left
  minLbl.Parent = row

  minBox.FocusLost:Connect(function(enter)
    local val = tonumber(minBox.Text)
    if val and val >= 0 then
      config.products[productName] = { min = val }
      setStatus("Saved: " .. productName .. " min = " .. val, Color3.fromRGB(100, 200, 100))
    else
      minBox.Text = tostring(minStock)
    end
  end)

  return row
end

-- ─── Product Detection ───
-- AJUSTE: Aqui você precisa identificar como o Retail Tycoon 2 armazena
-- os produtos nas prateleiras. Abaixo estão algumas abordagens comuns.
-- Teste qual funciona no seu jogo.

local function findShelfProducts()
  local detected = {}

  -- Método 1: Procurar por partes chamadas "Shelf" ou "Display" no Workspace
  -- AJUSTE: mude "Shelf" para o nome real usado no jogo
  for _, v in ipairs(workspace:GetDescendants()) do
    if v:IsA("Part") or v:IsA("Model") then
      local name = v.Name:lower()
      if name:find("shelf") or name:find("display") or name:find("prateleira") or name:find("rack") then
        -- Tenta ler atributos de produto
        local prodName = v:GetAttribute("ProductName") or v:GetAttribute("product") or v:GetAttribute("ItemName")
        local quantity = v:GetAttribute("Quantity") or v:GetAttribute("stock") or v:GetAttribute("amount")
        if prodName then
          detected[prodName] = (detected[prodName] or 0) + (tonumber(quantity) or 0)
        end
      end
    end
  end

  -- Método 2: Ler de um módulo/folder de dados do jogador
  -- AJUSTE: mude o caminho conforme o jogo armazena os dados
  local data = player:FindFirstChild("Data")
  if data then
    local store = data:FindFirstChild("Store") or data:FindFirstChild("Inventory")
    if store then
      for _, item in ipairs(store:GetChildren()) do
        local name = item.Name
        local qty = item:GetAttribute("Quantity") or item.Value
        if name and qty then
          detected[name] = (detected[name] or 0) + (tonumber(qty) or 0)
        end
      end
    end
  end

  -- Método 3: Procurar por BillboardGui com nome de produto
  for _, billboard in ipairs(workspace:GetDescendants()) do
    if billboard:IsA("BillboardGui") and billboard.Enabled then
      for _, child in ipairs(billboard:GetChildren()) do
        if child:IsA("TextLabel") and child.Text then
          local text = child.Text
          local num = tonumber(text)
          if num then
            local parentName = billboard.Parent and billboard.Parent.Name or "Unknown"
            if not detected[parentName] then
              detected[parentName] = num
            end
          end
        end
      end
    end
  end

  return detected
end

-- ─── Restock Function �───
-- AJUSTE: Descubra qual RemoteEvent/Function o jogo usa para comprar
-- ou reabastecer produtos. Procure no replicatedStorage ou workspace.

local function restockProduct(productName, quantity)
  if not config.autoBuy then return false end

  -- Abordagem 1: RemoteEvent
  -- AJUSTE: mude o nome do RemoteEvent e os argumentos
  local remote = game:GetService("ReplicatedStorage"):FindFirstChild("BuyProduct")
      or game:GetService("ReplicatedStorage"):FindFirstChild("RestockItem")
      or game:GetService("ReplicatedStorage"):FindFirstChild("PurchaseItem")

  if remote and remote:IsA("RemoteEvent") then
    -- Tenta diferentes padrões de argumentos
    local success, err = pcall(function()
      if config.instantDelivery then
        remote:FireServer(productName, quantity, true)
      else
        remote:FireServer(productName, quantity)
      end
    end)
    if success then return true end
  end

  -- Abordagem 2: RemoteFunction
  local remFunc = game:GetService("ReplicatedStorage"):FindFirstChild("BuyProduct")
      or game:GetService("ReplicatedStorage"):FindFirstChild("RestockItem")
  if remFunc and remFunc:IsA("RemoteFunction") then
    local success, err = pcall(function()
      remFunc:InvokeServer(productName, quantity)
    end)
    if success then return true end
  end

  -- Abordagem 3: Simular clique em botão UI
  -- (caso o jogo use interface)
  fireClickDetector(productName)

  return false
end

-- ─── Scan and Restock Loop ───

local scanning = false
local lastRestock = {}

local function performScan()
  if scanning then return end
  scanning = true
  setStatus("Scanning shelves...", Color3.fromRGB(200, 200, 100))
  task.wait(0.5)

  local products = findShelfProducts()
  local count = 0

  -- Clear old rows
  for _, child in ipairs(productList:GetChildren()) do
    if child ~= listLayout and child:IsA("Frame") then
      child:Destroy()
    end
  end

  for name, qty in products do
    if not config.ignoredProducts[name] then
      local min = config.products[name] and config.products[name].min or config.defaultMinStock
      createProductRow(name, qty, min)
      count = count + 1
    end
  end

  setStatus("Scan complete: " .. count .. " products found", Color3.fromRGB(100, 200, 100))
  scanning = false
end

local function autoRestockCycle()
  while gui and gui.Parent do
    task.wait(config.checkInterval)

    if not config.enabled then
      setStatus("Auto restock disabled", Color3.fromRGB(180, 130, 80))
      continue
    end

    setStatus("Auto-checking stock...", Color3.fromRGB(180, 180, 200))
    local products = findShelfProducts()

    local restocked = 0
    for name, currentQty in products do
      if config.ignoredProducts[name] then
        continue
      end

      local min = config.products[name] and config.products[name].min or config.defaultMinStock

      if currentQty < min then
        local needed = min - currentQty
        if not lastRestock[name] or tick() - lastRestock[name] > 5 then
          lastRestock[name] = tick()
          setStatus("Restocking " .. name .. " (need " .. needed .. ")", Color3.fromRGB(100, 180, 255))
          local ok = restockProduct(name, needed)
          if ok then
            restocked = restocked + 1
          end
          task.wait(config.restockDelay)
        end
      end
    end

    if restocked > 0 then
      setStatus("Restocked " .. restocked .. " products", Color3.fromRGB(100, 200, 100))
    end
  end
end

-- ─── Buttons ───

scanBtn.MouseButton1Click:Connect(performScan)

autoToggle.MouseButton1Click:Connect(function()
  config.enabled = not config.enabled
  updateToggleBtn()
  if config.enabled then
    setStatus("Auto restock activated", Color3.fromRGB(100, 200, 100))
  else
    setStatus("Auto restock deactivated", Color3.fromRGB(180, 130, 80))
  end
end)

-- ─── Keybinds ───

UserInputService.InputBegan:Connect(function(input, gameProcessed)
  if gameProcessed then return end
  if input.KeyCode == Enum.KeyCode.RightControl then
    gui.Enabled = not gui.Enabled
  end
end)

-- ─── Init ───

updateToggleBtn()
setStatus("Ready. Press RightCtrl to toggle UI", Color3.fromRGB(150, 150, 200))
task.delay(1, function()
  performScan()
end)

-- Start auto-restock loop in a coroutine
task.spawn(autoRestockCycle)

-- ─── Notification ───

local notify = Instance.new("TextLabel")
notify.Size = UDim2.new(0, 350, 0, 40)
notify.Position = UDim2.new(0.5, -175, 0, 20)
notify.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
notify.BackgroundTransparency = 0.1
notify.BorderSizePixel = 0
notify.Text = "✅ RT2 Auto Restock loaded — RightCtrl to toggle UI"
notify.TextColor3 = Color3.fromRGB(150, 220, 150)
notify.TextSize = 14
notify.Font = Enum.Font.GothamSemibold
notify.Parent = gui
local nUc = Instance.new("UICorner")
nUc.CornerRadius = UDim.new(0, 8)
nUc.Parent = notify
task.delay(5, function()
  if notify then notify.Visible = false end
end)
