--[[
  RT2 Debug Scanner v1
  Escaneia o jogo e mostra no console onde estao os produtos
]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

-- Clean old
local old = pg:FindFirstChild("RT2Debug")
if old then old:Destroy() end

-- Mini UI
local gui = Instance.new("ScreenGui")
gui.Name = "RT2Debug"
gui.ResetOnSpawn = false
gui.Parent = pg

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 360, 0, 280)
frame.Position = UDim2.new(0.5, -180, 0.5, -140)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local fc = Instance.new("UICorner")
fc.CornerRadius = UDim.new(0, 8)
fc.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -16, 0, 30)
title.Position = UDim2.new(0, 8, 0, 4)
title.BackgroundTransparency = 1
title.Text = "🔍 RT2 Debug Scanner"
title.TextColor3 = Color3.fromRGB(200, 200, 220)
title.TextSize = 14
title.Font = Enum.Font.GothamSemibold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local logBox = Instance.new("ScrollingFrame")
logBox.Size = UDim2.new(1, -16, 1, -90)
logBox.Position = UDim2.new(0, 8, 0, 38)
logBox.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
logBox.BorderSizePixel = 0
logBox.ScrollBarThickness = 4
logBox.Parent = frame

local lbc = Instance.new("UICorner")
lbc.CornerRadius = UDim.new(0, 4)
lbc.Parent = logBox

local logLayout = Instance.new("UIListLayout")
logLayout.Padding = UDim.new(0, 2)
logLayout.Parent = logBox

local btnScan = Instance.new("TextButton")
btnScan.Size = UDim2.new(0, 120, 0, 28)
btnScan.Position = UDim2.new(0, 8, 1, -34)
btnScan.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
btnScan.BorderSizePixel = 0
btnScan.Text = "🔍 Escanear Tudo"
btnScan.TextColor3 = Color3.fromRGB(255, 255, 255)
btnScan.TextSize = 11
btnScan.Font = Enum.Font.GothamSemibold
btnScan.Parent = frame
local bsc = Instance.new("UICorner")
bsc.CornerRadius = UDim.new(0, 5)
bsc.Parent = btnScan

local btnExp = Instance.new("TextButton")
btnExp.Size = UDim2.new(0, 100, 0, 28)
btnExp.Position = UDim2.new(0, 136, 1, -34)
btnExp.BackgroundColor3 = Color3.fromRGB(180, 130, 30)
btnExp.BorderSizePixel = 0
btnExp.Text = "🌳 Explorer"
btnExp.TextColor3 = Color3.fromRGB(255, 255, 255)
btnExp.TextSize = 11
btnExp.Font = Enum.Font.GothamSemibold
btnExp.Parent = frame
local bec = Instance.new("UICorner")
bec.CornerRadius = UDim.new(0, 5)
bec.Parent = btnExp

local btnCopy = Instance.new("TextButton")
btnCopy.Size = UDim2.new(0, 60, 0, 28)
btnCopy.Position = UDim2.new(0, 244, 1, -34)
btnCopy.BackgroundColor3 = Color3.fromRGB(50, 80, 150)
btnCopy.BorderSizePixel = 0
btnCopy.Text = "📋 Copiar"
btnCopy.TextColor3 = Color3.fromRGB(255, 255, 255)
btnCopy.TextSize = 10
btnCopy.Font = Enum.Font.GothamSemibold
btnCopy.Parent = frame
local bcp = Instance.new("UICorner")
bcp.CornerRadius = UDim.new(0, 5)
bcp.Parent = btnCopy

local btnClear = Instance.new("TextButton")
btnClear.Size = UDim2.new(0, 60, 0, 28)
btnClear.Position = UDim2.new(0, 310, 1, -34)
btnClear.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
btnClear.BorderSizePixel = 0
btnClear.Text = "Limpar"
btnClear.TextColor3 = Color3.fromRGB(255, 255, 255)
btnClear.TextSize = 11
btnClear.Font = Enum.Font.GothamSemibold
btnClear.Parent = frame
local blc = Instance.new("UICorner")
blc.CornerRadius = UDim.new(0, 5)
blc.Parent = btnClear

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
  logBox.CanvasSize = UDim2.new(0, 0, 0, logBox.CanvasSize.Y.Offset + 18)
  logBox.CanvasPosition = Vector2.new(0, logBox.CanvasSize.Y.Offset)
end

local function findRelevantPaths(obj, depth, maxDepth, results)
  if depth > maxDepth then return end
  if not obj then return end
  
  local name = obj.Name or "?"
  local class = obj.ClassName or "?"
  local indent = string.rep("  ", depth)
  
  -- Check if interesting
  local interesting = false
  local nameLower = name:lower()
  if nameLower:find("shelf") or nameLower:find("product") or nameLower:find("item") or nameLower:find("stock") or nameLower:find("store") or nameLower:find("shop") or nameLower:find("inventory") or nameLower:find("buy") or nameLower:find("purchase") or nameLower:find("restock") or nameLower:find("remote") or nameLower:find("sell") or nameLower:find("display") or nameLower:find("rack") or nameLower:find("warehouse") or nameLower:find("storage") then
    interesting = true
    table.insert(results, { name = name, class = class, path = obj:GetFullName(), depth = depth })
  end
  
  if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
    table.insert(results, { name = name, class = class, path = obj:GetFullName(), depth = depth, isRemote = true })
    interesting = true
  end
  
  if interesting or depth < 2 then
    for _, child in ipairs(obj:GetChildren()) do
      findRelevantPaths(child, depth + 1, maxDepth, results)
    end
  end
end

local function scanProducts()
  log("=== INICIANDO SCAN ===", Color3.fromRGB(255, 200, 80))
  
  -- 1. Scan workspace shelves
  log("[1/4] Escaneando workspace...")
  local shelfCount = 0
  for _, v in ipairs(workspace:GetDescendants()) do
    local n = v.Name:lower()
    if n:find("shelf") or n:find("display") or n:find("rack") or n:find("bin") or n:find("stand") or n:find("prateleira") then
      shelfCount = shelfCount + 1
      if shelfCount <= 20 then
        log("  Shelf: " .. v:GetFullName() .. " (" .. v.ClassName .. ")")
        -- Show attributes
        for _, attr in ipairs(v:GetAttributes()) do
          log("    → " .. attr .. " = " .. tostring(v:GetAttribute(attr)), Color3.fromRGB(150, 220, 150))
        end
        -- Show children
        for _, child in ipairs(v:GetChildren()) do
          if child:IsA("StringValue") or child:IsA("NumberValue") or child:IsA("IntValue") or child:IsA("ObjectValue") or child:IsA("Attribute") then
            log("    Child: " .. child.Name .. " = " .. tostring(child.Value), Color3.fromRGB(150, 180, 255))
          end
        end
      end
    end
  end
  log("  Total shelves found: " .. shelfCount)
  
  -- 2. Scan BillboardGuis
  log("[2/4] Escaneando BillboardGui...")
  local billboardCount = 0
  for _, bg in ipairs(workspace:GetDescendants()) do
    if bg:IsA("BillboardGui") and bg.Enabled then
      for _, lbl in ipairs(bg:GetChildren()) do
        if lbl:IsA("TextLabel") and lbl.Text then
          local num = tonumber(lbl.Text)
          if num then
            billboardCount = billboardCount + 1
            if billboardCount <= 15 then
              log("  Billboard: " .. bg.Parent.Name .. " → " .. lbl.Text, Color3.fromRGB(200, 200, 100))
            end
          end
        end
      end
    end
  end
  log("  Total stock billboards: " .. billboardCount)
  
  -- 3. Check player data
  log("[3/4] Dados do jogador...")
  local dataPaths = { "Data", "PlayerData", "Store", "leaderstats" }
  for _, p in ipairs(dataPaths) do
    local d = player:FindFirstChild(p)
    if d then
      log("  " .. p .. " encontrado!", Color3.fromRGB(100, 255, 100))
      for _, child in ipairs(d:GetChildren()) do
        log("    → " .. child:GetFullName() .. " (" .. child.ClassName .. ")")
      end
    end
  end
  
  -- 4. Check ReplicatedStorage.Remotes
  log("[4/4] Remotes disponiveis...")
  local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
  if remotes then
    for _, r in ipairs(remotes:GetChildren()) do
      if r:IsA("RemoteEvent") or r:IsA("RemoteFunction") then
        log("  Remote: " .. r.Name .. " (" .. r.ClassName .. ")", Color3.fromRGB(150, 200, 255))
      end
    end
  else
    log("  ❌ Remotes nao encontrado em ReplicatedStorage!", Color3.fromRGB(255, 100, 100))
    -- Procurar em outro lugar
    local rs = game:GetService("ReplicatedStorage")
    for _, child in ipairs(rs:GetChildren()) do
      log("  RS: " .. child.Name .. " (" .. child.ClassName .. ")")
      if child:IsA("Folder") then
        for _, sub in ipairs(child:GetChildren()) do
          if sub:IsA("RemoteEvent") or sub:IsA("RemoteFunction") then
            log("    → Remote: " .. sub.Name, Color3.fromRGB(150, 200, 255))
          end
        end
      end
    end
  end
  
  log("=== SCAN FINALIZADO ===", Color3.fromRGB(255, 200, 80))
end

local function exploreGame()
  log("=== EXPLORER ===")
  log("Procurando objetos relevantes...")
  
  local results = {}
  
  -- Check ReplicatedStorage
  findRelevantPaths(game:GetService("ReplicatedStorage"), 0, 5, results)
  
  -- Check Player
  findRelevantPaths(player, 0, 5, results)
  
  -- Sort by path
  table.sort(results, function(a, b) return a.path < b.path end)
  
  for _, r in ipairs(results) do
    local prefix = r.isRemote and "🔌" or "📁"
    log(prefix .. " " .. r.name .. " (" .. r.class .. ")", r.isRemote and Color3.fromRGB(150, 200, 255) or Color3.fromRGB(200, 200, 200))
    log("  " .. r.path, Color3.fromRGB(140, 140, 160))
  end
  
  log("Total: " .. #results .. " objetos relevantes")
  log("=== FIM ===")
end

btnScan.MouseButton1Click:Connect(scanProducts)
btnExp.MouseButton1Click:Connect(exploreGame)
btnCopy.MouseButton1Click:Connect(function()
  local lines = {}
  for _, c in ipairs(logBox:GetChildren()) do
    if c:IsA("TextLabel") and c.Text and c.Text ~= "" then
      table.insert(lines, c.Text)
    end
  end
  local full = table.concat(lines, "\n")
  setclipboard(full)
  log("✅ Copiado para área de transferência!", Color3.fromRGB(100, 255, 100))
end)
btnClear.MouseButton1Click:Connect(function()
  for _, c in ipairs(logBox:GetChildren()) do
    if c ~= logLayout then c:Destroy() end
  end
  logBox.CanvasSize = UDim2.new(0, 0, 0, 0)
end)

log("🔍 Debug Scanner carregado!")
log("Clique em 'Escanear Tudo' para ver produtos")
log("Clique em 'Explorer' para ver objetos do jogo")
log("F6 para toggle")
print("[RT2 Debug] Carregado! F6 para toggle")

-- Keybind
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, p)
  if p then return end
  if input.KeyCode == Enum.KeyCode.F6 then
    gui.Enabled = not gui.Enabled
  end
end)

-- Auto scan after 5s
task.delay(5, scanProducts)
