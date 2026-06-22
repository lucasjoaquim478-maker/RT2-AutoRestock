--[[
  Retail Tycoon 2 - Auto Stock Manager v2.1
  loadstring(game:HttpGet("https://raw.githubusercontent.com/lucasjoaquim478-maker/RT2-AutoRestock/main/scripts/main.lua"))()
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

local products = {}
local running = false
local scanning = false
local stats = { restocks = 0, attempts = 0, fails = 0 }

-- Clean old GUI
local old = pg:FindFirstChild("RT2GUI")
if old then old:Destroy() end

-- Main GUI
local gui = Instance.new("ScreenGui")
gui.Name = "RT2GUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = pg

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 420, 0, 480)
frame.Position = UDim2.new(0.5, -210, 0.5, -240)
frame.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local fc = Instance.new("UICorner")
fc.CornerRadius = UDim.new(0, 10)
fc.Parent = frame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 36)
title.Position = UDim2.new(0, 10, 0, 6)
title.BackgroundTransparency = 1
title.Text = "📦 Auto Stock - Retail Tycoon 2"
title.TextColor3 = Color3.fromRGB(200, 200, 220)
title.TextSize = 15
title.Font = Enum.Font.GothamSemibold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

-- Close
local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 24, 0, 24)
close.Position = UDim2.new(1, -32, 0, 8)
close.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
close.BorderSizePixel = 0
close.Text = "X"
close.TextColor3 = Color3.fromRGB(255, 255, 255)
close.TextSize = 13
close.Font = Enum.Font.GothamBold
close.Parent = frame
local clc = Instance.new("UICorner")
clc.CornerRadius = UDim.new(0, 6)
clc.Parent = close
close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Status
local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(1, -20, 0, 28)
statusBar.Position = UDim2.new(0, 10, 0, 44)
statusBar.BackgroundColor3 = Color3.fromRGB(30, 30, 44)
statusBar.BorderSizePixel = 0
statusBar.Parent = frame
local sc = Instance.new("UICorner")
sc.CornerRadius = UDim.new(0, 6)
sc.Parent = statusBar

local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 7, 0, 7)
statusDot.Position = UDim2.new(0, 10, 0, 10.5)
statusDot.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
statusDot.BorderSizePixel = 0
statusDot.Parent = statusBar
local sdc = Instance.new("UICorner")
sdc.CornerRadius = UDim.new(0, 4)
sdc.Parent = statusDot

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -24, 1, 0)
statusText.Position = UDim2.new(0, 22, 0, 0)
statusText.BackgroundTransparency = 1
statusText.Text = "Pronto. Aperte F6 para toggle"
statusText.TextColor3 = Color3.fromRGB(140, 140, 165)
statusText.TextSize = 12
statusText.Font = Enum.Font.Gotham
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.Parent = statusBar

-- Buttons row
local btnRow = Instance.new("Frame")
btnRow.Size = UDim2.new(1, -20, 0, 34)
btnRow.Position = UDim2.new(0, 10, 0, 78)
btnRow.BackgroundTransparency = 1
btnRow.Parent = frame

local scanBtn = Instance.new("TextButton")
scanBtn.Size = UDim2.new(0, 130, 0, 32)
scanBtn.BackgroundColor3 = Color3.fromRGB(70, 110, 210)
scanBtn.BorderSizePixel = 0
scanBtn.Text = "🔍 Escanear"
scanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
scanBtn.TextSize = 12
scanBtn.Font = Enum.Font.GothamSemibold
scanBtn.Parent = btnRow
local sbc = Instance.new("UICorner")
sbc.CornerRadius = UDim.new(0, 6)
sbc.Parent = scanBtn

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 130, 0, 32)
toggleBtn.Position = UDim2.new(0, 138, 0, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 170, 70)
toggleBtn.BorderSizePixel = 0
toggleBtn.Text = "▶ Iniciar"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 12
toggleBtn.Font = Enum.Font.GothamSemibold
toggleBtn.Parent = btnRow
local tbc = Instance.new("UICorner")
tbc.CornerRadius = UDim.new(0, 6)
tbc.Parent = toggleBtn

-- Stats label
local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, -20, 0, 20)
statsLabel.Position = UDim2.new(0, 10, 0, 116)
statsLabel.BackgroundTransparency = 1
statsLabel.Text = "Produtos: 0 | Restocks: 0 | Falhas: 0"
statsLabel.TextColor3 = Color3.fromRGB(130, 130, 155)
statsLabel.TextSize = 11
statsLabel.Font = Enum.Font.Gotham
statsLabel.TextXAlignment = Enum.TextXAlignment.Left
statsLabel.Parent = frame

-- Search
local search = Instance.new("TextBox")
search.Size = UDim2.new(1, -20, 0, 28)
search.Position = UDim2.new(0, 10, 0, 140)
search.BackgroundColor3 = Color3.fromRGB(30, 30, 44)
search.BorderSizePixel = 0
search.PlaceholderText = "🔍 Buscar produto..."
search.PlaceholderColor3 = Color3.fromRGB(100, 100, 125)
search.Text = ""
search.TextColor3 = Color3.fromRGB(200, 200, 220)
search.TextSize = 12
search.Font = Enum.Font.Gotham
search.ClearTextOnFocus = false
search.Parent = frame
local src = Instance.new("UICorner")
src.CornerRadius = UDim.new(0, 6)
src.Parent = search

-- Product list
local listFrame = Instance.new("Frame")
listFrame.Size = UDim2.new(1, -10, 1, -188)
listFrame.Position = UDim2.new(0, 5, 0, 174)
listFrame.BackgroundTransparency = 1
listFrame.ClipsDescendants = true
listFrame.Parent = frame

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, 0, 1, 0)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 5
list.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 70)
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.Parent = listFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 3)
layout.SortOrder = Enum.SortOrder.Name
layout.Parent = list

-- Empty state
local empty = Instance.new("TextLabel")
empty.Size = UDim2.new(1, -20, 0, 50)
empty.Position = UDim2.new(0, 10, 0, 60)
empty.BackgroundTransparency = 1
empty.Text = "📋 Nenhum produto encontrado\nClique em Escanear para detectar sua loja"
empty.TextColor3 = Color3.fromRGB(120, 120, 145)
empty.TextSize = 13
empty.Font = Enum.Font.Gotham
empty.TextWrapped = true
empty.Visible = true
empty.Parent = listFrame

-- ─── Functions ───

local function setStatus(text, color)
  statusText.Text = text
  statusDot.BackgroundColor3 = color or Color3.fromRGB(140, 140, 165)
end

local function updateStats()
  local c = 0
  for _, _ in pairs(products) do c = c + 1 end
  statsLabel.Text = "Produtos: " .. c .. " | Restocks: " .. stats.restocks .. " | Tentativas: " .. stats.attempts .. " | Falhas: " .. stats.fails
end

local function guessCategory(name)
  name = name:lower()
  if name:find("toy") or name:find("doll") or name:find("action") or name:find("lego") or name:find("puzzle") or name:find("ball") or name:find("game") then return "🧸"
  elseif name:find("shirt") or name:find("pants") or name:find("jeans") or name:find("dress") or name:find("hat") or name:find("shoe") or name:find("sneaker") then return "👕"
  elseif name:find("phone") or name:find("tablet") or name:find("laptop") or name:find("computer") or name:find("headphone") or name:find("speaker") or name:find("tv") or name:find("monitor") then return "📱"
  elseif name:find("canned") or name:find("snack") or name:find("candy") or name:find("drink") or name:find("soda") or name:find("chip") or name:find("cookie") or name:find("food") or name:find("beverage") then return "🥫"
  elseif name:find("chair") or name:find("table") or name:find("desk") or name:find("sofa") or name:find("bed") or name:find("cabinet") or name:find("furniture") then return "🪑"
  elseif name:find("car") or name:find("tire") or name:find("engine") or name:find("part") then return "🚗"
  elseif name:find("pet") or name:find("dog") or name:find("cat") or name:find("fish") then return "🐾"
  elseif name:find("gun") or name:find("ammo") or name:find("military") or name:find("armor") then return "🔫"
  end
  return "📦"
end

local function refreshList(filter)
  filter = filter or ""

  for _, c in ipairs(list:GetChildren()) do
    if c ~= layout and c:IsA("Frame") then c:Destroy() end
  end

  local count = 0
  for name, prod in products do
    if filter ~= "" and not name:lower():find(filter:lower()) then continue end

    local pct = prod.maxStock > 0 and math.clamp(prod.current / prod.maxStock, 0, 1) or 0.5
    local color = pct > 0.6 and Color3.fromRGB(50, 190, 90) or (pct > 0.3 and Color3.fromRGB(200, 170, 40) or Color3.fromRGB(200, 60, 60))

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -8, 0, 44)
    row.BackgroundColor3 = Color3.fromRGB(30, 30, 44)
    row.BorderSizePixel = 0
    row.Parent = list

    local rc = Instance.new("UICorner")
    rc.CornerRadius = UDim.new(0, 6)
    rc.Parent = row

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 24, 1, 0)
    icon.Position = UDim2.new(0, 6, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = guessCategory(name)
    icon.TextSize = 14
    icon.Font = Enum.Font.Gotham
    icon.Parent = row

    local nm = Instance.new("TextLabel")
    nm.Size = UDim2.new(0, 140, 0, 18)
    nm.Position = UDim2.new(0, 32, 0, 2)
    nm.BackgroundTransparency = 1
    nm.Text = name
    nm.TextColor3 = Color3.fromRGB(200, 200, 220)
    nm.TextSize = 11
    nm.Font = Enum.Font.GothamSemibold
    nm.TextXAlignment = Enum.TextXAlignment.Left
    nm.Parent = row

    local stock = Instance.new("TextLabel")
    stock.Size = UDim2.new(0, 60, 0, 14)
    stock.Position = UDim2.new(0, 32, 0, 20)
    stock.BackgroundTransparency = 1
    stock.Text = "📦 " .. tostring(prod.current) .. "/" .. tostring(prod.maxStock)
    stock.TextColor3 = color
    stock.TextSize = 10
    stock.Font = Enum.Font.Gotham
    stock.TextXAlignment = Enum.TextXAlignment.Left
    stock.Parent = row

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(0, 80, 0, 5)
    barBg.Position = UDim2.new(0, 120, 0, 22)
    barBg.BackgroundColor3 = Color3.fromRGB(22, 22, 34)
    barBg.BorderSizePixel = 0
    barBg.Parent = row

    local bb = Instance.new("UICorner")
    bb.CornerRadius = UDim.new(0, 3)
    bb.Parent = barBg

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(pct, 0, 1, 0)
    bar.BackgroundColor3 = color
    bar.BorderSizePixel = 0
    bar.Parent = barBg

    local br = Instance.new("UICorner")
    br.CornerRadius = UDim.new(0, 3)
    br.Parent = bar

    -- Min input
    local minL = Instance.new("TextLabel")
    minL.Size = UDim2.new(0, 24, 0, 14)
    minL.Position = UDim2.new(0, 210, 0, 2)
    minL.BackgroundTransparency = 1
    minL.Text = "Min:"
    minL.TextColor3 = Color3.fromRGB(130, 130, 155)
    minL.TextSize = 9
    minL.Font = Enum.Font.Gotham
    minL.Parent = row

    local minBox = Instance.new("TextBox")
    minBox.Size = UDim2.new(0, 40, 0, 18)
    minBox.Position = UDim2.new(0, 210, 0, 15)
    minBox.BackgroundColor3 = Color3.fromRGB(22, 22, 34)
    minBox.BorderSizePixel = 0
    minBox.Text = tostring(prod.min)
    minBox.TextColor3 = Color3.fromRGB(200, 200, 220)
    minBox.TextSize = 11
    minBox.Font = Enum.Font.Gotham
    minBox.ClearTextOnFocus = true
    minBox.Parent = row
    local mb = Instance.new("UICorner")
    mb.CornerRadius = UDim.new(0, 4)
    mb.Parent = minBox
    minBox.FocusLost:Connect(function(e)
      if e then local v = tonumber(minBox.Text); if v and v >= 0 then prod.min = v else minBox.Text = tostring(prod.min) end end
    end)

    -- Restock input
    local rL = Instance.new("TextLabel")
    rL.Size = UDim2.new(0, 28, 0, 14)
    rL.Position = UDim2.new(0, 258, 0, 2)
    rL.BackgroundTransparency = 1
    rL.Text = "Qtd:"
    rL.TextColor3 = Color3.fromRGB(130, 130, 155)
    rL.TextSize = 9
    rL.Font = Enum.Font.Gotham
    rL.Parent = row

    local rBox = Instance.new("TextBox")
    rBox.Size = UDim2.new(0, 40, 0, 18)
    rBox.Position = UDim2.new(0, 258, 0, 15)
    rBox.BackgroundColor3 = Color3.fromRGB(22, 22, 34)
    rBox.BorderSizePixel = 0
    rBox.Text = tostring(prod.restock or prod.min)
    rBox.TextColor3 = Color3.fromRGB(200, 200, 220)
    rBox.TextSize = 11
    rBox.Font = Enum.Font.Gotham
    rBox.ClearTextOnFocus = true
    rBox.Parent = row
    local rb = Instance.new("UICorner")
    rb.CornerRadius = UDim.new(0, 4)
    rb.Parent = rBox
    rBox.FocusLost:Connect(function(e)
      if e then local v = tonumber(rBox.Text); if v and v >= 0 then prod.restock = v else rBox.Text = tostring(prod.restock or prod.min) end end
    end)

    local cb = Instance.new("TextButton")
    cb.Size = UDim2.new(0, 22, 0, 22)
    cb.Position = UDim2.new(1, -30, 0, 11)
    cb.BackgroundColor3 = prod.disabled and Color3.fromRGB(50, 50, 70) or Color3.fromRGB(50, 190, 90)
    cb.BorderSizePixel = 0
    cb.Text = prod.disabled and "✕" or "✓"
    cb.TextColor3 = Color3.fromRGB(255, 255, 255)
    cb.TextSize = 11
    cb.Font = Enum.Font.GothamBold
    cb.Parent = row

    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(0, 5)
    cc.Parent = cb
    cb.MouseButton1Click:Connect(function()
      prod.disabled = not prod.disabled
      cb.BackgroundColor3 = prod.disabled and Color3.fromRGB(50, 50, 70) or Color3.fromRGB(50, 190, 90)
      cb.Text = prod.disabled and "✕" or "✓"
    end)

    count = count + 1
  end

  empty.Visible = count == 0
  list.CanvasSize = UDim2.new(0, 0, 0, count * 48)
  updateStats()
end

-- ─── Scan ───

local function scanStore()
  if scanning then return end
  scanning = true
  setStatus("🔍 Escaneando loja...", Color3.fromRGB(200, 180, 60))

  local found = {}

  -- Method 1: Check parts with attributes
  for _, v in ipairs(workspace:GetDescendants()) do
    local isShelf = v.Name:lower():find("shelf") or v.Name:lower():find("display") or v.Name:lower():find("rack") or v.Name:lower():find("bin") or v.Name:lower():find("stand")
    if isShelf and (v:IsA("Part") or v:IsA("Model")) then
      local pn = v:GetAttribute("ProductName") or v:GetAttribute("ItemName") or v:GetAttribute("SellingItem")
      local qty = v:GetAttribute("Quantity") or v:GetAttribute("Stock") or v:GetAttribute("Amount")
      local mx = v:GetAttribute("MaxQuantity") or v:GetAttribute("MaxStock") or v:GetAttribute("Capacity")
      if pn then
        if not found[pn] then found[pn] = { current = 0, maxStock = 0 } end
        found[pn].current = found[pn].current + (tonumber(qty) or 0)
        found[pn].maxStock = found[pn].maxStock + (tonumber(mx) or tonumber(qty) or 50)
      end
    end
  end

  -- Method 2: BillboardGui with numbers
  for _, bg in ipairs(workspace:GetDescendants()) do
    if bg:IsA("BillboardGui") and bg.Enabled then
      for _, lbl in ipairs(bg:GetChildren()) do
        if lbl:IsA("TextLabel") and lbl.Text then
          local n = tonumber(lbl.Text)
          if n and bg.Parent then
            local pn = bg.Parent.Name
            if not found[pn] then found[pn] = { current = n, maxStock = n * 2 } end
          end
        end
      end
    end
  end

  -- Method 3: Player data
  local data = player:FindFirstChild("Data") or player:FindFirstChild("PlayerData") or player:FindFirstChild("Store")
  if data then
    local inv = data:FindFirstChild("Inventory") or data:FindFirstChild("Products") or data:FindFirstChild("StoreItems")
    if inv then
      for _, item in ipairs(inv:GetChildren()) do
        local qty = item:GetAttribute("Quantity") or (item:IsA("NumberValue") and item.Value)
        if item.Name and qty then
          if not found[item.Name] then found[item.Name] = { current = 0, maxStock = 50 } end
          found[item.Name].current = found[item.Name].current + (tonumber(qty) or 0)
        end
      end
    end
  end

  for name, data in found do
    if not products[name] then
      products[name] = { current = data.current, maxStock = data.maxStock, min = 10, restock = 20, disabled = false }
    else
      products[name].current = data.current
      products[name].maxStock = data.maxStock
    end
  end

  refreshList()
  setStatus("✅ Scan completo: " .. #found .. " produtos", Color3.fromRGB(80, 200, 80))
  scanning = false
end

-- ─── Auto Restock Loop ───

local function findBuyRemote()
  local remotes = ReplicatedStorage:FindFirstChild("Remotes")
  if not remotes then return nil end
  local names = { "BuyItem", "BuyProduct", "RestockItem", "PurchaseItem", "OrderStock", "BuyStock", "RestockShelf", "OrderInventory" }
  for _, n in ipairs(names) do
    local r = remotes:FindFirstChild(n)
    if r then return r end
  end
  return nil
end

local function restockLoop()
  while running do
    task.wait(4)

    local remote = findBuyRemote()
    if not remote then
      setStatus("⚠ Remote de compra não encontrada", Color3.fromRGB(200, 100, 50))
      task.wait(6)
      continue
    end

    local done = 0
    for name, prod in products do
      if prod.disabled then continue end

      -- Refresh current qty
      local current = prod.current

      stats.attempts = stats.attempts + 1

      if current < prod.min then
        local need = math.max(prod.restock or prod.min, prod.min - current)

        local ok = false
        if remote:IsA("RemoteEvent") then
          ok = pcall(function() remote:FireServer(name, need) end)
          if not ok then ok = pcall(function() remote:FireServer(name, need, false) end) end
          if not ok then ok = pcall(function() remote:FireServer(need, name) end) end
        elseif remote:IsA("RemoteFunction") then
          ok = pcall(function() remote:InvokeServer(name, need) end)
          if not ok then ok = pcall(function() remote:InvokeServer(need, name) end) end
        end

        if ok then
          stats.restocks = stats.restocks + 1
          prod.current = prod.current + need
          done = done + 1
          setStatus("✅ Restock: " .. name .. " (+" .. need .. ")", Color3.fromRGB(80, 200, 80))
        else
          stats.fails = stats.fails + 1
        end

        updateStats()
        task.wait(2)
      end
    end

    if done == 0 then
      setStatus("📊 Estoque OK", Color3.fromRGB(140, 140, 165))
    end

    refreshList(search.Text)
  end
end

-- ─── Button Events ───

scanBtn.MouseButton1Click:Connect(scanStore)

toggleBtn.MouseButton1Click:Connect(function()
  running = not running
  if running then
    toggleBtn.Text = "⏹ Parar"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    setStatus("▶ Auto stock ATIVO", Color3.fromRGB(80, 200, 80))
    task.spawn(restockLoop)
  else
    toggleBtn.Text = "▶ Iniciar"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 170, 70)
    setStatus("⏸ Auto stock PAUSADO", Color3.fromRGB(200, 160, 40))
  end
end)

search:GetPropertyChangedSignal("Text"):Connect(function()
  refreshList(search.Text)
end)

UserInputService.InputBegan:Connect(function(input, processed)
  if processed then return end
  if input.KeyCode == Enum.KeyCode.F6 then
    gui.Enabled = not gui.Enabled
  end
end)

-- ─── Init ───

setStatus("Pronto. F6 para toggle | Escaneie sua loja")
task.delay(3, scanStore)

print("[RT2 Stock Manager] Carregado! F6 para toggle")
