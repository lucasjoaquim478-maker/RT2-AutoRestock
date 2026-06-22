--[[
  RT2 Explorer 2 - Sellables & Restock tester
  loadstring(game:HttpGet("https://raw.githubusercontent.com/lucasjoaquim478-maker/RT2-AutoRestock/main/scripts/explorer2.lua"))()
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

local remotes = ReplicatedStorage:FindFirstChild("Remotes")
local sellables = ReplicatedStorage:FindFirstChild("Sellables")

local old = pg:FindFirstChild("RT2Explorer2")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "RT2Explorer2"
gui.ResetOnSpawn = false
gui.Parent = pg

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 450, 0, 450)
frame.Position = UDim2.new(0.5, -225, 0.5, -225)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui
local fc = Instance.new("UICorner")
fc.CornerRadius = UDim.new(0, 10)
fc.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 30)
title.Position = UDim2.new(0, 10, 0, 6)
title.BackgroundTransparency = 1
title.Text = "RT2 Explorer v2"
title.TextColor3 = Color3.fromRGB(200, 200, 220)
title.TextSize = 14
title.Font = Enum.Font.GothamSemibold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local logBox = Instance.new("ScrollingFrame")
logBox.Size = UDim2.new(1, -16, 1, -90)
logBox.Position = UDim2.new(0, 8, 0, 40)
logBox.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
logBox.BorderSizePixel = 0
logBox.ScrollBarThickness = 4
logBox.Parent = frame
local lbc = Instance.new("UICorner")
lbc.CornerRadius = UDim.new(0, 4)
lbc.Parent = logBox

local function log(msg, color)
  local l = Instance.new("TextLabel")
  l.Size = UDim2.new(1, -8, 0, 16)
  l.BackgroundTransparency = 1
  l.Text = msg
  l.TextColor3 = color or Color3.fromRGB(180, 180, 200)
  l.TextSize = 10
  l.Font = Enum.Font.Gotham
  l.TextXAlignment = Enum.TextXAlignment.Left
  l.TextWrapped = true
  l.RichText = true
  l.Parent = logBox
  task.wait()
  logBox.CanvasSize = UDim2.new(0, 0, 0, (logBox.CanvasSize or UDim2.new(0,0,0,0)).Y.Offset + 18)
  logBox.CanvasPosition = Vector2.new(0, logBox.CanvasSize.Y.Offset)
end

-- Button 1: Ver produtos dentro de cada categoria Sellables
local btnProducts = Instance.new("TextButton")
btnProducts.Size = UDim2.new(0, 140, 0, 26)
btnProducts.Position = UDim2.new(0, 8, 1, -35)
btnProducts.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
btnProducts.BorderSizePixel = 0
btnProducts.Text = "📋 Produtos"
btnProducts.TextColor3 = Color3.fromRGB(255, 255, 255)
btnProducts.TextSize = 10
btnProducts.Font = Enum.Font.GothamSemibold
btnProducts.Parent = frame
local bc = Instance.new("UICorner")
bc.CornerRadius = UDim.new(0, 5)
bc.Parent = btnProducts

btnProducts.MouseButton1Click:Connect(function()
  log("=== SELLABLES (detalhado) ===", Color3.fromRGB(255, 200, 80))
  if not sellables then log("❌ Sellables nao encontrado"); return end
  local total = 0
  for _, cat in ipairs(sellables:GetChildren()) do
    log("Categoria: " .. cat.Name .. " (" .. #cat:GetChildren() .. " itens)", Color3.fromRGB(200, 200, 100))
    for _, prod in ipairs(cat:GetChildren()) do
      log("  - " .. prod.Name .. " (" .. prod.ClassName .. ")", Color3.fromRGB(180, 220, 180))
      total = total + 1
      -- Check attributes
      for _, attr in ipairs(prod:GetAttributes()) do
        log("      attr: " .. attr .. " = " .. tostring(prod:GetAttribute(attr)), Color3.fromRGB(140, 180, 200))
      end
    end
  end
  log("Total: " .. total .. " produtos", Color3.fromRGB(255, 200, 80))
  log("=== FIM ===")
end)

-- Button 2: Test GetSellables com argumentos diferentes
local btnGetSellables = Instance.new("TextButton")
btnGetSellables.Size = UDim2.new(0, 140, 0, 26)
btnGetSellables.Position = UDim2.new(0, 155, 1, -35)
btnGetSellables.BackgroundColor3 = Color3.fromRGB(180, 130, 30)
btnGetSellables.BorderSizePixel = 0
btnGetSellables.Text = "🔌 GetSellables"
btnGetSellables.TextColor3 = Color3.fromRGB(255, 255, 255)
btnGetSellables.TextSize = 10
btnGetSellables.Font = Enum.Font.GothamSemibold
btnGetSellables.Parent = frame
local bc2 = Instance.new("UICorner")
bc2.CornerRadius = UDim.new(0, 5)
bc2.Parent = btnGetSellables

btnGetSellables.MouseButton1Click:Connect(function()
  log("=== TESTE GETSELLABLES ===", Color3.fromRGB(255, 200, 80))
  local func = remotes and remotes:FindFirstChild("GetSellables")
  if not func then log("❌ GetSellables nao encontrado"); return end
  
  -- Tenta com diferentes argumentos
  local attempts = {
    { player },
    { player.Name },
    { "Plot_1" },
    { "XlucasXr1" },
    { player, "Plot_1" },
    {},
  }
  
  for i, args in ipairs(attempts) do
    local ok, result = pcall(function()
      return func:InvokeServer(unpack(args))
    end)
    if ok and result then
      log("✅ Com args[" .. table.concat(args, ",") .. "] FUNCIONOU!", Color3.fromRGB(100, 255, 100))
      if type(result) == "table" then
        for k, v in pairs(result) do
          log("  " .. tostring(k) .. " = " .. tostring(v):sub(1, 100), Color3.fromRGB(180, 220, 180))
        end
      else
        log("  " .. tostring(result):sub(1, 300), Color3.fromRGB(180, 220, 180))
      end
      break
    else
      log("  ❌ args[" .. table.concat(args, ",") .. "]: " .. (tostring(result):sub(1, 100) or "?"), Color3.fromRGB(200, 120, 120))
    end
  end
  log("=== FIM ===")
end)

-- Button 3: Restock test com nome real de produto
local btnRestockTest = Instance.new("TextButton")
btnRestockTest.Size = UDim2.new(0, 140, 0, 26)
btnRestockTest.Position = UDim2.new(0, 302, 1, -35)
btnRestockTest.BackgroundColor3 = Color3.fromRGB(50, 160, 70)
btnRestockTest.BorderSizePixel = 0
btnRestockTest.Text = "🔄 Test Restock"
btnRestockTest.TextColor3 = Color3.fromRGB(255, 255, 255)
btnRestockTest.TextSize = 10
btnRestockTest.Font = Enum.Font.GothamSemibold
btnRestockTest.Parent = frame
local bc3 = Instance.new("UICorner")
bc3.CornerRadius = UDim.new(0, 5)
bc3.Parent = btnRestockTest

btnRestockTest.MouseButton1Click:Connect(function()
  log("=== TESTE RESTOCK COM PRODUTOS REAIS ===", Color3.fromRGB(255, 200, 80))
  
  -- Get current storage to see what's available
  local storageFunc = remotes and remotes:FindFirstChild("GetStorage")
  local stockEvent = remotes and remotes:FindFirstChild("StockShelf")
  local stockFunc = remotes and remotes:FindFirstChild("StockShelfFunction")
  local restockFunc = remotes and remotes:FindFirstChild("RestockShelfFunction")
  
  if not storageFunc then log("❌ GetStorage nao encontrado"); return end
  if not stockEvent then log("❌ StockShelf nao encontrado"); return end
  
  -- Get current stock
  local ok, storage = pcall(function() return storageFunc:InvokeServer() end)
  if not ok or not storage then log("❌ GetStorage falhou"); return end
  
  log("Storage atual:", Color3.fromRGB(200, 200, 100))
  for prod, qty in pairs(storage) do
    if tonumber(qty) and tonumber(qty) > 0 then
      log("  " .. prod .. " = " .. qty, Color3.fromRGB(180, 220, 180))
    end
  end
  
  -- Test StockShelf (RemoteEvent) with a product that has stock
  log("Testando StockShelf:FireServer()...", Color3.fromRGB(200, 200, 100))
  local testProduct = nil
  for prod, qty in pairs(storage) do
    if tonumber(qty) and tonumber(qty) > 0 then
      testProduct = prod
      break
    end
  end
  
  if testProduct then
    log("Usando produto: " .. testProduct, Color3.fromRGB(200, 200, 100))
    
    -- Type 1: (name, qty)
    local ok1, err1 = pcall(function() stockEvent:FireServer(testProduct, 5) end)
    log("  StockShelf(name, qty): " .. (ok1 and "✅" or "❌ " .. tostring(err1):sub(1, 80)), ok1 and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100))
    
    -- Type 2: (qty, name)
    local ok2, err2 = pcall(function() stockEvent:FireServer(5, testProduct) end)
    log("  StockShelf(qty, name): " .. (ok2 and "✅" or "❌ " .. tostring(err2):sub(1, 80)), ok2 and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100))
    
    -- Type 3: (name, qty, true)
    local ok3, err3 = pcall(function() stockEvent:FireServer(testProduct, 5, true) end)
    log("  StockShelf(name, qty, true): " .. (ok3 and "✅" or "❌ " .. tostring(err3):sub(1, 80)), ok3 and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100))
    
    -- StockShelfFunction test
    if stockFunc then
      log("Testando StockShelfFunction...", Color3.fromRGB(200, 200, 100))
      local ok4, err4 = pcall(function() return stockFunc:InvokeServer(testProduct, 5) end)
      log("  StockShelfFunction(name, qty): " .. (ok4 and "✅" or "❌ " .. tostring(err4):sub(1, 80)), ok4 and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100))
      
      local ok5, err5 = pcall(function() return stockFunc:InvokeServer(testProduct) end)
      log("  StockShelfFunction(name): " .. (ok5 and "✅" or "❌ " .. tostring(err5):sub(1, 80)), ok5 and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100))
    end
    
    -- RestockShelfFunction test
    if restockFunc then
      log("Testando RestockShelfFunction...", Color3.fromRGB(200, 200, 100))
      local ok6, err6 = pcall(function() return restockFunc:InvokeServer(testProduct, 5) end)
      log("  RestockShelfFunction(name, qty): " .. (ok6 and "✅" or "❌ " .. tostring(err6):sub(1, 80)), ok6 and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100))
    end
  else
    log("Nenhum produto com estoque encontrado", Color3.fromRGB(255, 200, 80))
  end
  
  log("=== FIM ===")
end)

-- Button 4: Check if Storage changed
local btnCheckStorage = Instance.new("TextButton")
btnCheckStorage.Size = UDim2.new(0, 140, 0, 26)
btnCheckStorage.Position = UDim2.new(0, 155, 1, -66)
btnCheckStorage.BackgroundColor3 = Color3.fromRGB(80, 60, 160)
btnCheckStorage.BorderSizePixel = 0
btnCheckStorage.Text = "🏪 Check Storage"
btnCheckStorage.TextColor3 = Color3.fromRGB(255, 255, 255)
btnCheckStorage.TextSize = 10
btnCheckStorage.Font = Enum.Font.GothamSemibold
btnCheckStorage.Parent = frame
local bc4 = Instance.new("UICorner")
bc4.CornerRadius = UDim.new(0, 5)
bc4.Parent = btnCheckStorage

btnCheckStorage.MouseButton1Click:Connect(function()
  log("=== STORAGE ATUAL ===", Color3.fromRGB(255, 200, 80))
  local func = remotes and remotes:FindFirstChild("GetStorage")
  if not func then log("❌ GetStorage nao encontrado"); return end
  local ok, result = pcall(function() return func:InvokeServer() end)
  if ok and result then
    for prod, qty in pairs(result) do
      local color = tonumber(qty) and tonumber(qty) > 0 and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(200, 100, 100)
      log("  " .. prod .. " = " .. tostring(qty), color)
    end
  else
    log("❌ " .. tostring(result))
  end
  log("=== FIM ===")
end)

-- Button 5: Copy
local btnCopy = Instance.new("TextButton")
btnCopy.Size = UDim2.new(0, 80, 0, 26)
btnCopy.Position = UDim2.new(0, 302, 1, -66)
btnCopy.BackgroundColor3 = Color3.fromRGB(80, 60, 160)
btnCopy.BorderSizePixel = 0
btnCopy.Text = "📋 Copiar"
btnCopy.TextColor3 = Color3.fromRGB(255, 255, 255)
btnCopy.TextSize = 10
btnCopy.Font = Enum.Font.GothamSemibold
btnCopy.Parent = frame
local bc5 = Instance.new("UICorner")
bc5.CornerRadius = UDim.new(0, 5)
bc5.Parent = btnCopy

btnCopy.MouseButton1Click:Connect(function()
  local lines = {}
  for _, c in ipairs(logBox:GetChildren()) do
    if c:IsA("TextLabel") and c.Text and c.Text ~= "" then
      table.insert(lines, c.Text)
    end
  end
  setclipboard(table.concat(lines, "\n"))
  log("✅ Copiado!", Color3.fromRGB(100, 255, 100))
end)

log("Explorer v2 carregado!")
log("Clique em 'Produtos' para ver categorias e produtos")
log("Depois 'Test Restock' para testar com um produto real")

local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, p)
  if p then return end
  if input.KeyCode == Enum.KeyCode.F6 then gui.Enabled = not gui.Enabled end
end)

print("[RT2 Explorer2] F6 para toggle")
