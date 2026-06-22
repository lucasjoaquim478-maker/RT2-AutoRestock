--[[
  RT2 Remote Explorer
  Testa os remotes de stock pra descobrir argumentos
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:FindFirstChild("Remotes")
local sellables = ReplicatedStorage:FindFirstChild("Sellables")

-- Mini UI
local old = pg:FindFirstChild("RT2RemoteExplorer")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "RT2RemoteExplorer"
gui.ResetOnSpawn = false
gui.Parent = pg

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 420, 0, 400)
frame.Position = UDim2.new(0.5, -210, 0.5, -200)
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
title.Text = "🔌 RT2 Remote Explorer"
title.TextColor3 = Color3.fromRGB(200, 200, 220)
title.TextSize = 14
title.Font = Enum.Font.GothamSemibold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

-- Log
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

-- Buttons
local function makeBtn(text, pos, color)
  local b = Instance.new("TextButton")
  b.Size = UDim2.new(0, 90, 0, 26)
  b.Position = UDim2.new(0, pos, 1, -35)
  b.BackgroundColor3 = color or Color3.fromRGB(60, 80, 160)
  b.BorderSizePixel = 0
  b.Text = text
  b.TextColor3 = Color3.fromRGB(255, 255, 255)
  b.TextSize = 10
  b.Font = Enum.Font.GothamSemibold
  b.Parent = frame
  local bc = Instance.new("UICorner")
  bc.CornerRadius = UDim.new(0, 5)
  bc.Parent = b
  return b
end

local btnSellables = makeBtn("📦 Sellables", 8, Color3.fromRGB(60, 100, 200))
local btnStorage = makeBtn("🏪 Storage", 106, Color3.fromRGB(50, 160, 70))
local btnRestock = makeBtn("🔄 Restock", 204, Color3.fromRGB(180, 130, 30))
local btnCopy = makeBtn("📋 Copiar", 302, Color3.fromRGB(80, 60, 160))
local btnClear = makeBtn("Limpar", 350, Color3.fromRGB(50, 50, 70))

-- Funcoes
btnSellables.MouseButton1Click:Connect(function()
  log("=== GETSELLABLES ===", Color3.fromRGB(255, 200, 80))
  local func = remotes and remotes:FindFirstChild("GetSellables")
  if not func then log("❌ GetSellables nao encontrado", Color3.fromRGB(255, 100, 100)) return end
  
  local ok, result = pcall(function()
    return func:InvokeServer()
  end)
  if ok and result then
    log("✅ Retornou " .. tostring(#result or "?") .. " itens", Color3.fromRGB(100, 255, 100))
    for i, item in ipairs(result) do
      if i > 50 then log("... +" .. (#result - 50) .. " mais", Color3.fromRGB(150, 150, 170)); break end
      local txt = tostring(item)
      if type(item) == "table" then
        txt = ""
        for k, v in pairs(item) do
          txt = txt .. tostring(k) .. "=" .. tostring(v) .. " "
        end
      elseif type(item) == "Instance" then
        txt = item:GetFullName()
      end
      log("  " .. i .. ". " .. txt, Color3.fromRGB(180, 220, 180))
    end
  else
    log("❌ Erro: " .. tostring(result), Color3.fromRGB(255, 100, 100))
  end
  log("=== FIM ===")
end)

btnStorage.MouseButton1Click:Connect(function()
  log("=== GETSTORAGE ===", Color3.fromRGB(255, 200, 80))
  local func = remotes and remotes:FindFirstChild("GetStorage")
  if not func then log("❌ GetStorage nao encontrado", Color3.fromRGB(255, 100, 100)) return end
  
  local ok, result = pcall(function()
    return func:InvokeServer()
  end)
  if ok and result then
    log("✅ Storage:", Color3.fromRGB(100, 255, 100))
    if type(result) == "table" then
      for k, v in pairs(result) do
        log("  " .. tostring(k) .. " = " .. tostring(v), Color3.fromRGB(180, 220, 180))
      end
    else
      log("  " .. tostring(result), Color3.fromRGB(180, 220, 180))
    end
  else
    log("❌ Erro: " .. tostring(result), Color3.fromRGB(255, 100, 100))
  end
  log("=== FIM ===")
end)

btnRestock.MouseButton1Click:Connect(function()
  log("=== TESTE RESTOCK ===", Color3.fromRGB(255, 200, 80))
  
  -- Test StockShelfFunction
  local sf = remotes and remotes:FindFirstChild("StockShelfFunction")
  if sf then
    log("Testando StockShelfFunction...", Color3.fromRGB(200, 200, 100))
    
    -- Try different argument patterns
    local tests = {
      { "Apple", 10 },
      { "Small Furniture", 5 },
      { 1, 10 },  -- product ID
      { "Small Furniture", 5, false },
    }
    
    for i, args in ipairs(tests) do
      local ok, err = pcall(function()
        return sf:InvokeServer(unpack(args))
      end)
      if ok then
        log("✅ StockShelfFunction(" .. table.concat(args, ", ") .. ") FUNCIONOU!", Color3.fromRGB(100, 255, 100))
        local r = type(err) ~= "boolean" and err or "ok"
        log("  Resultado: " .. tostring(r):sub(1, 200), Color3.fromRGB(180, 220, 180))
      else
        log("  ❌ Padrao " .. i .. ": " .. tostring(err):sub(1, 100), Color3.fromRGB(200, 120, 120))
      end
    end
  end
  
  -- Test StockAllShelves  
  local sa = remotes and remotes:FindFirstChild("StockAllShelves")
  if sa then
    log("Testando StockAllShelves...", Color3.fromRGB(200, 200, 100))
    local ok, err = pcall(function()
      return sa:InvokeServer()
    end)
    if ok then
      log("✅ StockAllShelves FUNCIONOU!", Color3.fromRGB(100, 255, 100))
    else
      log("❌ StockAllShelves: " .. tostring(err):sub(1, 100), Color3.fromRGB(200, 120, 120))
    end
    
    ok, err = pcall(function()
      return sa:InvokeServer(true)
    end)
    if ok then
      log("✅ StockAllShelves(true) FUNCIONOU!", Color3.fromRGB(100, 255, 100))
    end
  end
  
  -- Test StockShelf (RemoteEvent)
  local se = remotes and remotes:FindFirstChild("StockShelf")
  if se then
    log("Testando StockShelf (RemoteEvent)...", Color3.fromRGB(200, 200, 100))
    local ok, err = pcall(function()
      se:FireServer("Small Furniture", 5)
    end)
    if ok then
      log("✅ StockShelf funcionou!", Color3.fromRGB(100, 255, 100))
    else
      log("❌ StockShelf: " .. tostring(err):sub(1, 100), Color3.fromRGB(200, 120, 120))
    end
  end
  
  -- Check Sellables folder
  if sellables then
    log("Conteudo de Sellables:", Color3.fromRGB(200, 200, 100))
    for i, child in ipairs(sellables:GetChildren()) do
      if i > 20 then log("... +" .. (#sellables:GetChildren() - 20) .. " mais"); break end
      log("  " .. child.Name .. " (" .. child.ClassName .. ")", Color3.fromRGB(150, 200, 220))
    end
  end
  
  log("=== FIM ===")
end)

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

btnClear.MouseButton1Click:Connect(function()
  for _, c in ipairs(logBox:GetChildren()) do
    if c ~= logBox:FindFirstChildOfClass("UIListLayout") then c:Destroy() end
  end
  logBox.CanvasSize = UDim2.new(0, 0, 0, 0)
end)

log("🔌 Remote Explorer carregado!")
log("Clique nos botoes para testar cada remote")
log("F6 para toggle")

local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, p)
  if p then return end
  if input.KeyCode == Enum.KeyCode.F6 then gui.Enabled = not gui.Enabled end
end)

print("[RT2 Explorer] Carregado! F6 para toggle")
