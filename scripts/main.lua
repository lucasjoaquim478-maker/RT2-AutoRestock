--[[
  Retail Tycoon 2 - Auto Stock Manager v2
  By: lucasjoaquim478-maker | Para Madium Executor
  loadstring(game:HttpGet("https://raw.githubusercontent.com/lucasjoaquim478-maker/RT2-AutoRestock/main/scripts/main.lua"))()
]]

-- ─── Services ───
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- ─── Constants (RT2 base) ───
local REMOTES = ReplicatedStorage:FindFirstChild("Remotes")
local FUNCTIONS = ReplicatedStorage:FindFirstChild("Functions")
local CATEGORY_ICONS = {
  Toys = "🧸", Clothing = "👕", Shoes = "👟", Hats = "🎩",
  Candy = "🍬", Snacks = "🍿", CannedFood = "🥫", BoxedFood = "📦",
  ColdFood = "🧊", BakedGoods = "🥖", Fruit = "🍎", Vegetables = "🥦",
  Condiments = "🧂", Beverages = "🥤", SmallElectronics = "📱",
  LargeElectronics = "🖥️", PCElectronics = "🖥️", PCPeripherals = "⌨️",
  OfficeElectronics = "📠", GamesConsoles = "🎮", VideoGames = "🎮",
  SmallAppliances = "🔌", LargeAppliances = "🧊", Kitchenware = "🍳",
  Luggage = "🧳", VacuumCleaners = "🌀", PersonalCare = "🧴",
  SchoolSupplies = "✏️", MusicalInstruments = "🎵", SmallFurniture = "🪑",
  LargeFurniture = "🛋️", ExerciseEquipment = "🏋️", GamesTables = "🎱",
  PersonalTransport = "🛴", CarParts = "🔧", EconomyCars = "🚗",
  Jewelry = "💍", SmallPets = "🐹", LargePets = "🐕", PetFood = "🦴",
  Guns = "🔫", Ammo = "💥", MilitaryVehicles = "🚜", ArmoredVehicles = "🛡️",
  Lumber = "🪵", PaintSupplies = "🎨", GardenTools = "🪴",
  SmallOutdoor = "🏕️", LargeOutdoor = "🏗️", PowerTools = "🔨",
}

-- ─── State ───
local store = {
  products = {},     -- name -> { current, min, restock, shelfCount, category }
  history = {},      -- name -> { lastRestock, totalRestocked }
  stats = { totalRestocks = 0, totalAttempts = 0, failedAttempts = 0 },
  running = false,
  scanning = false,
}

-- ─── UI Builder ───
local ui = {}
local gui, mainFrame

local colors = {
  bg = Color3.fromRGB(18, 18, 26),
  surface = Color3.fromRGB(26, 26, 38),
  surface2 = Color3.fromRGB(35, 35, 50),
  accent = Color3.fromRGB(120, 90, 220),
  accentLight = Color3.fromRGB(150, 120, 255),
  text = Color3.fromRGB(210, 210, 225),
  textDim = Color3.fromRGB(140, 140, 160),
  green = Color3.fromRGB(50, 190, 90),
  red = Color3.fromRGB(210, 60, 60),
  yellow = Color3.fromRGB(210, 180, 50),
  orange = Color3.fromRGB(220, 140, 40),
}

function ui:Create()
  gui = Instance.new("ScreenGui")
  gui.Name = "RT2StockManager"
  gui.ResetOnSpawn = false
  gui.DisplayOrder = 10
  gui.Parent = player:WaitForChild("PlayerGui")

  mainFrame = Instance.new("Frame")
  mainFrame.Size = UDim2.new(0, 520, 0, 580)
  mainFrame.Position = UDim2.new(0.5, -260, 0.5, -290)
  mainFrame.BackgroundColor3 = colors.bg
  mainFrame.BorderSizePixel = 0
  mainFrame.Active = true
  mainFrame.Draggable = true
  mainFrame.ClipsDescendants = true
  mainFrame.Parent = gui

  local corner = Instance.new("UICorner")
  corner.CornerRadius = UDim.new(0, 12)
  corner.Parent = mainFrame

  -- Shadow
  local shadow = Instance.new("ImageLabel")
  shadow.Size = UDim2.new(1, 40, 1, 40)
  shadow.Position = UDim2.new(0, -20, 0, -20)
  shadow.BackgroundTransparent = true
  shadow.Image = "rbxassetid://6015897843"
  shadow.ImageColor3 = Color3.new(0, 0, 0)
  shadow.ImageTransparency = 0.6
  shadow.ScaleType = Enum.ScaleType.Slice
  shadow.SliceCenter = Rect.new(49, 49, 50, 50)
  shadow.ZIndex = -1
  shadow.Parent = mainFrame

  -- ── Title Bar ──
  local titleBar = Instance.new("Frame")
  titleBar.Size = UDim2.new(1, 0, 0, 44)
  titleBar.BackgroundColor3 = colors.surface
  titleBar.BorderSizePixel = 0
  titleBar.Parent = mainFrame

  local titleCorner = Instance.new("UICorner")
  titleCorner.CornerRadius = UDim.new(0, 12)
  titleCorner.Parent = titleBar

  local titleFill = Instance.new("Frame")
  titleFill.Size = UDim2.new(1, 0, 0, 20)
  titleFill.Position = UDim2.new(0, 0, 1, -20)
  titleFill.BackgroundColor3 = colors.surface
  titleFill.BorderSizePixel = 0
  titleFill.Parent = titleBar

  local icon = Instance.new("TextLabel")
  icon.Size = UDim2.new(0, 32, 1, 0)
  icon.Position = UDim2.new(0, 10, 0, 0)
  icon.BackgroundTransparent = true
  icon.Text = "📦"
  icon.TextSize = 18
  icon.Font = Enum.Font.Gotham
  icon.Parent = titleBar

  local titleText = Instance.new("TextLabel")
  titleText.Size = UDim2.new(1, -110, 1, 0)
  titleText.Position = UDim2.new(0, 44, 0, 0)
  titleText.BackgroundTransparent = true
  titleText.Text = "Auto Stock Manager"
  titleText.TextColor3 = colors.text
  titleText.TextSize = 15
  titleText.Font = Enum.Font.GothamSemibold
  titleText.TextXAlignment = Enum.TextXAlignment.Left
  titleText.Parent = titleBar

  local versionText = Instance.new("TextLabel")
  versionText.Size = UDim2.new(0, 50, 1, 0)
  versionText.Position = UDim2.new(1, -120, 0, 0)
  versionText.BackgroundTransparent = true
  versionText.Text = "v2.0"
  versionText.TextColor3 = colors.textDim
  versionText.TextSize = 11
  versionText.Font = Enum.Font.Gotham
  versionText.Parent = titleBar

  local closeBtn = Instance.new("TextButton")
  closeBtn.Size = UDim2.new(0, 28, 0, 28)
  closeBtn.Position = UDim2.new(1, -38, 0, 8)
  closeBtn.BackgroundColor3 = colors.red
  closeBtn.BorderSizePixel = 0
  closeBtn.Text = "✕"
  closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
  closeBtn.TextSize = 14
  closeBtn.Font = Enum.Font.GothamBold
  closeBtn.Parent = titleBar

  local closeCorner = Instance.new("UICorner")
  closeCorner.CornerRadius = UDim.new(0, 6)
  closeCorner.Parent = closeBtn
  closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

  -- ── Status Bar ──
  local statusBar = Instance.new("Frame")
  statusBar.Size = UDim2.new(1, -20, 0, 30)
  statusBar.Position = UDim2.new(0, 10, 0, 50)
  statusBar.BackgroundColor3 = colors.surface
  statusBar.BorderSizePixel = 0
  statusBar.Parent = mainFrame

  local statusCorner = Instance.new("UICorner")
  statusCorner.CornerRadius = UDim.new(0, 8)
  statusCorner.Parent = statusBar

  local statusDot = Instance.new("Frame")
  statusDot.Size = UDim2.new(0, 8, 0, 8)
  statusDot.Position = UDim2.new(0, 10, 0, 11)
  statusDot.BackgroundColor3 = colors.green
  statusDot.BorderSizePixel = 0
  statusDot.Parent = statusBar

  local dotCorner = Instance.new("UICorner")
  dotCorner.CornerRadius = UDim.new(0, 4)
  dotCorner.Parent = statusDot

  local statusText = Instance.new("TextLabel")
  statusText.Size = UDim2.new(1, -60, 1, 0)
  statusText.Position = UDim2.new(0, 24, 0, 0)
  statusText.BackgroundTransparent = true
  statusText.Text = "Pronto. Pressione F6 para mostrar/esconder"
  statusText.TextColor3 = colors.textDim
  statusText.TextSize = 12
  statusText.Font = Enum.Font.Gotham
  statusText.TextXAlignment = Enum.TextXAlignment.Left
  statusText.Parent = statusBar

  -- ── Stats Row ──
  local statsRow = Instance.new("Frame")
  statsRow.Size = UDim2.new(1, -20, 0, 36)
  statsRow.Position = UDim2.new(0, 10, 0, 86)
  statsRow.BackgroundTransparent = true
  statsRow.BorderSizePixel = 0
  statsRow.Parent = mainFrame

  local statLabels = {}
  local statData = {
    { label = "Produtos", key = "products", color = colors.accentLight },
    { label = "Restocks Hoje", key = "restocks", color = colors.green },
    { label = "Tentativas", key = "attempts", color = colors.yellow },
    { label = "Falhas", key = "failures", color = colors.red },
  }

  for i, stat in ipairs(statData) do
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, 115, 0, 36)
    card.Position = UDim2.new(0, (i - 1) * 122, 0, 0)
    card.BackgroundColor3 = colors.surface
    card.BorderSizePixel = 0
    card.Parent = statsRow

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = card

    local num = Instance.new("TextLabel")
    num.Size = UDim2.new(0, 40, 1, 0)
    num.Position = UDim2.new(0, 8, 0, 0)
    num.BackgroundTransparent = true
    num.Text = stat.key == "products" and "0" or "0"
    num.TextColor3 = stat.color
    num.TextSize = 16
    num.Font = Enum.Font.GothamBlack
    num.TextXAlignment = Enum.TextXAlignment.Left
    num.Parent = card

    local lab = Instance.new("TextLabel")
    lab.Size = UDim2.new(1, -52, 1, 0)
    lab.Position = UDim2.new(0, 50, 0, 0)
    lab.BackgroundTransparent = true
    lab.Text = stat.label
    lab.TextColor3 = colors.textDim
    lab.TextSize = 10
    lab.Font = Enum.Font.Gotham
    lab.TextXAlignment = Enum.TextXAlignment.Left
    lab.Parent = card

    statLabels[stat.key] = { num = num, lab = lab, ref = stat }
  end

  -- ── Control Buttons ──
  local ctrlRow = Instance.new("Frame")
  ctrlRow.Size = UDim2.new(1, -20, 0, 36)
  ctrlRow.Position = UDim2.new(0, 10, 0, 128)
  ctrlRow.BackgroundTransparent = true
  ctrlRow.BorderSizePixel = 0
  ctrlRow.Parent = mainFrame

  local startBtn = Instance.new("TextButton")
  startBtn.Size = UDim2.new(0, 140, 0, 34)
  startBtn.BackgroundColor3 = colors.green
  startBtn.BorderSizePixel = 0
  startBtn.Text = "▶ Iniciar"
  startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
  startBtn.TextSize = 13
  startBtn.Font = Enum.Font.GothamSemibold
  startBtn.Parent = ctrlRow

  local startBtnCorner = Instance.new("UICorner")
  startBtnCorner.CornerRadius = UDim.new(0, 8)
  startBtnCorner.Parent = startBtn

  local scanBtn = Instance.new("TextButton")
  scanBtn.Size = UDim2.new(0, 140, 0, 34)
  scanBtn.Position = UDim2.new(0, 148, 0, 0)
  scanBtn.BackgroundColor3 = colors.accent
  scanBtn.BorderSizePixel = 0
  scanBtn.Text = "🔍 Escanear"
  scanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
  scanBtn.TextSize = 13
  scanBtn.Font = Enum.Font.GothamSemibold
  scanBtn.Parent = ctrlRow

  local scanBtnCorner = Instance.new("UICorner")
  scanBtnCorner.CornerRadius = UDim.new(0, 8)
  scanBtnCorner.Parent = scanBtn

  local configBtn = Instance.new("TextButton")
  configBtn.Size = UDim2.new(0, 48, 0, 34)
  configBtn.Position = UDim2.new(0, 296, 0, 0)
  configBtn.BackgroundColor3 = colors.surface2
  configBtn.BorderSizePixel = 0
  configBtn.Text = "⚙"
  configBtn.TextColor3 = colors.text
  configBtn.TextSize = 16
  configBtn.Font = Enum.Font.Gotham
  configBtn.Parent = ctrlRow

  local configBtnCorner = Instance.new("UICorner")
  configBtnCorner.CornerRadius = UDim.new(0, 8)
  configBtnCorner.Parent = configBtn

  local resetBtn = Instance.new("TextButton")
  resetBtn.Size = UDim2.new(0, 48, 0, 34)
  resetBtn.Position = UDim2.new(0, 352, 0, 0)
  resetBtn.BackgroundColor3 = colors.surface2
  resetBtn.BorderSizePixel = 0
  resetBtn.Text = "🗑"
  resetBtn.TextColor3 = colors.text
  resetBtn.TextSize = 14
  resetBtn.Font = Enum.Font.Gotham
  resetBtn.Parent = ctrlRow

  local resetBtnCorner = Instance.new("UICorner")
  resetBtnCorner.CornerRadius = UDim.new(0, 8)
  resetBtnCorner.Parent = resetBtn

  -- ── Search Bar ──
  local searchBox = Instance.new("TextBox")
  searchBox.Size = UDim2.new(1, -20, 0, 32)
  searchBox.Position = UDim2.new(0, 10, 0, 170)
  searchBox.BackgroundColor3 = colors.surface2
  searchBox.BorderSizePixel = 0
  searchBox.PlaceholderText = "🔍 Buscar produto..."
  searchBox.PlaceholderColor3 = colors.textDim
  searchBox.Text = ""
  searchBox.TextColor3 = colors.text
  searchBox.TextSize = 12
  searchBox.Font = Enum.Font.Gotham
  searchBox.ClearTextOnFocus = false
  searchBox.Parent = mainFrame

  local searchCorner = Instance.new("UICorner")
  searchCorner.CornerRadius = UDim.new(0, 8)
  searchCorner.Parent = searchBox

  -- ── Product List ──
  local listContainer = Instance.new("Frame")
  listContainer.Size = UDim2.new(1, -10, 1, -218)
  listContainer.Position = UDim2.new(0, 5, 0, 210)
  listContainer.BackgroundTransparent = true
  listContainer.BorderSizePixel = 0
  listContainer.ClipsDescendants = true
  listContainer.Parent = mainFrame

  local productList = Instance.new("ScrollingFrame")
  productList.Size = UDim2.new(1, 0, 1, 0)
  productList.BackgroundTransparent = true
  productList.BorderSizePixel = 0
  productList.ScrollBarThickness = 5
  productList.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 70)
  productList.Parent = listContainer

  local listLayout = Instance.new("UIListLayout")
  listLayout.Padding = UDim.new(0, 4)
  listLayout.SortOrder = Enum.SortOrder.Name
  listLayout.Parent = productList

  local listPadding = Instance.new("UIPadding")
  listPadding.PaddingTop = UDim.new(0, 2)
  listPadding.PaddingBottom = UDim.new(0, 2)
  listPadding.Parent = productList

  -- ── Empty State ──
  local emptyState = Instance.new("Frame")
  emptyState.Size = UDim2.new(1, 0, 1, 0)
  emptyState.BackgroundTransparent = true
  emptyState.BorderSizePixel = 0
  emptyState.Visible = true
  emptyState.Parent = listContainer

  local emptyIcon = Instance.new("TextLabel")
  emptyIcon.Size = UDim2.new(0, 60, 0, 60)
  emptyIcon.Position = UDim2.new(0.5, -30, 0.5, -50)
  emptyIcon.BackgroundTransparent = true
  emptyIcon.Text = "📋"
  emptyIcon.TextSize = 48
  emptyIcon.Font = Enum.Font.Gotham
  emptyIcon.Parent = emptyState

  local emptyText = Instance.new("TextLabel")
  emptyText.Size = UDim2.new(1, -40, 0, 40)
  emptyText.Position = UDim2.new(0, 20, 0.5, 10)
  emptyText.BackgroundTransparent = true
  emptyText.Text = "Nenhum produto encontrado\nClique em Escanear para detectar sua loja"
  emptyText.TextColor3 = colors.textDim
  emptyText.TextSize = 13
  emptyText.Font = Enum.Font.Gotham
  emptyText.TextWrapped = true
  emptyText.Parent = emptyState

  return {
    mainFrame = mainFrame,
    statusText = statusText,
    statusDot = statusDot,
    statLabels = statLabels,
    startBtn = startBtn,
    scanBtn = scanBtn,
    configBtn = configBtn,
    resetBtn = resetBtn,
    searchBox = searchBox,
    productList = productList,
    listLayout = listLayout,
    emptyState = emptyState,
    listContainer = listContainer,
  }
end

function ui:SetStatus(text, state)
  if not self.elements then return end
  self.elements.statusText.Text = text
  if state == "success" then
    self.elements.statusDot.BackgroundColor3 = colors.green
  elseif state == "error" then
    self.elements.statusDot.BackgroundColor3 = colors.red
  elseif state == "warning" then
    self.elements.statusDot.BackgroundColor3 = colors.orange
  elseif state == "info" then
    self.elements.statusDot.BackgroundColor3 = colors.accentLight
  else
    self.elements.statusDot.BackgroundColor3 = colors.textDim
  end
end

function ui:UpdateStats()
  if not self.elements then return end
  local s = self.elements.statLabels
  local pCount = 0
  for _, _ in pairs(store.products) do pCount = pCount + 1 end
  s.products.num.Text = tostring(pCount)
  s.restocks.num.Text = tostring(store.stats.totalRestocks)
  s.attempts.num.Text = tostring(store.stats.totalAttempts)
  s.failures.num.Text = tostring(store.stats.failedAttempts)
end

function ui:RefreshProductList(filter)
  if not self.elements then return end
  filter = filter or ""

  -- Clear existing rows
  for _, child in ipairs(self.elements.productList:GetChildren()) do
    if child ~= self.elements.listLayout and child:IsA("Frame") then
      child:Destroy()
    end
  end

  local count = 0
  for name, prod in store.products do
    if filter ~= "" and not name:lower():find(filter:lower()) then continue end

    local pct = 1
    if prod.maxStock and prod.maxStock > 0 then
      pct = math.clamp(prod.current / prod.maxStock, 0, 1)
    end

    -- Determine stock level color
    local stockColor
    if pct > 0.6 then
      stockColor = colors.green
    elseif pct > 0.3 then
      stockColor = colors.yellow
    else
      stockColor = colors.red
    end

    -- ── Row ──
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -10, 0, 48)
    row.BackgroundColor3 = colors.surface
    row.BorderSizePixel = 0
    row.Parent = self.elements.productList

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 8)
    rowCorner.Parent = row

    -- Status indicator (left colored bar)
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 4, 1, -8)
    indicator.Position = UDim2.new(0, 4, 0, 4)
    indicator.BackgroundColor3 = stockColor
    indicator.BorderSizePixel = 0
    indicator.Parent = row

    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(0, 2)
    indCorner.Parent = indicator

    -- Progress bar (background)
    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(0, 100, 0, 6)
    barBg.Position = UDim2.new(0, 14, 0, 6)
    barBg.BackgroundColor3 = colors.surface2
    barBg.BorderSizePixel = 0
    barBg.Parent = row

    local barBgCorner = Instance.new("UICorner")
    barBgCorner.CornerRadius = UDim.new(0, 3)
    barBgCorner.Parent = barBg

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(pct, 0, 1, 0)
    bar.BackgroundColor3 = stockColor
    bar.BorderSizePixel = 0
    bar.Parent = barBg

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 3)
    barCorner.Parent = bar

    -- Product name
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(0, 200, 0, 20)
    nameLbl.Position = UDim2.new(0, 14, 0, 16)
    nameLbl.BackgroundTransparent = true
    nameLbl.Text = name
    nameLbl.TextColor3 = colors.text
    nameLbl.TextSize = 12
    nameLbl.Font = Enum.Font.GothamSemibold
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent = row

    -- Stock count
    local stockLbl = Instance.new("TextLabel")
    stockLbl.Size = UDim2.new(0, 60, 0, 16)
    stockLbl.Position = UDim2.new(0, 120, 0, 6)
    stockLbl.BackgroundTransparent = true
    stockLbl.Text = tostring(prod.current) .. " / " .. tostring(prod.maxStock)
    stockLbl.TextColor3 = stockColor
    stockLbl.TextSize = 10
    stockLbl.Font = Enum.Font.Gotham
    stockLbl.TextXAlignment = Enum.TextXAlignment.Left
    stockLbl.Parent = row

    -- Min stock input
    local minLbl = Instance.new("TextLabel")
    minLbl.Size = UDim2.new(0, 30, 0, 16)
    minLbl.Position = UDim2.new(0, 120, 0, 24)
    minLbl.BackgroundTransparent = true
    minLbl.Text = "Mín:"
    minLbl.TextColor3 = colors.textDim
    minLbl.TextSize = 10
    minLbl.Font = Enum.Font.Gotham
    minLbl.TextXAlignment = Enum.TextXAlignment.Left
    minLbl.Parent = row

    local minBox = Instance.new("TextBox")
    minBox.Size = UDim2.new(0, 48, 0, 20)
    minBox.Position = UDim2.new(0, 148, 0, 22)
    minBox.BackgroundColor3 = colors.surface2
    minBox.BorderSizePixel = 0
    minBox.Text = tostring(prod.min)
    minBox.TextColor3 = colors.text
    minBox.TextSize = 11
    minBox.Font = Enum.Font.Gotham
    minBox.ClearTextOnFocus = true
    minBox.Parent = row

    local minBoxCorner = Instance.new("UICorner")
    minBoxCorner.CornerRadius = UDim.new(0, 4)
    minBoxCorner.Parent = minBox

    -- Restock amount input
    local restockLbl = Instance.new("TextLabel")
    restockLbl.Size = UDim2.new(0, 50, 0, 16)
    restockLbl.Position = UDim2.new(0, 206, 0, 24)
    restockLbl.BackgroundTransparent = true
    restockLbl.Text = "Restock:"
    restockLbl.TextColor3 = colors.textDim
    restockLbl.TextSize = 10
    restockLbl.Font = Enum.Font.Gotham
    restockLbl.TextXAlignment = Enum.TextXAlignment.Left
    restockLbl.Parent = row

    local restockBox = Instance.new("TextBox")
    restockBox.Size = UDim2.new(0, 48, 0, 20)
    restockBox.Position = UDim2.new(0, 252, 0, 22)
    restockBox.BackgroundColor3 = colors.surface2
    restockBox.BorderSizePixel = 0
    restockBox.Text = tostring(prod.restockAmount or prod.min)
    restockBox.TextColor3 = colors.text
    restockBox.TextSize = 11
    restockBox.Font = Enum.Font.Gotham
    restockBox.ClearTextOnFocus = true
    restockBox.Parent = row

    local restockBoxCorner = Instance.new("UICorner")
    restockBoxCorner.CornerRadius = UDim.new(0, 4)
    restockBoxCorner.Parent = restockBox

    -- Toggle restock for this product
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 28, 0, 28)
    toggleBtn.Position = UDim2.new(1, -38, 0, 10)
    toggleBtn.BackgroundColor3 = prod.disabled and colors.surface2 or colors.green
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = prod.disabled and "✕" or "✓"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 12
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = row

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 6)
    toggleCorner.Parent = toggleBtn

    toggleBtn.MouseButton1Click:Connect(function()
      prod.disabled = not prod.disabled
      toggleBtn.BackgroundColor3 = prod.disabled and colors.surface2 or colors.green
      toggleBtn.Text = prod.disabled and "✕" or "✓"
    end)

    minBox.FocusLost:Connect(function(enter)
      if enter then
        local val = tonumber(minBox.Text)
        if val and val >= 0 then
          prod.min = val
          ui:SetStatus(name .. " mínimo ajustado para " .. val, "info")
        else
          minBox.Text = tostring(prod.min)
        end
      end
    end)

    restockBox.FocusLost:Connect(function(enter)
      if enter then
        local val = tonumber(restockBox.Text)
        if val and val >= 0 then
          prod.restockAmount = val
          ui:SetStatus(name .. " restock ajustado para " .. val, "info")
        else
          restockBox.Text = tostring(prod.restockAmount or prod.min)
        end
      end
    end)

    count = count + 1
  end

  self.elements.emptyState.Visible = count == 0
  self:UpdateStats()
end

function ui:Init(elements)
  self.elements = elements
  self:SetStatus("Pronto. F6 para toggle", "idle")

  elements.scanBtn.MouseButton1Click:Connect(function()
    store:FullScan()
  end)

  elements.startBtn.MouseButton1Click:Connect(function()
    store.running = not store.running
    if store.running then
      elements.startBtn.Text = "⏹ Parar"
      elements.startBtn.BackgroundColor3 = colors.red
      store:SetMode(true)
    else
      elements.startBtn.Text = "▶ Iniciar"
      elements.startBtn.BackgroundColor3 = colors.green
      store:SetMode(false)
    end
  end)

  elements.resetBtn.MouseButton1Click:Connect(function()
    store.products = {}
    store.stats = { totalRestocks = 0, totalAttempts = 0, failedAttempts = 0 }
    self:RefreshProductList()
    self:SetStatus("Resetado. Escaneie novamente.", "info")
  end)

  elements.searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    self:RefreshProductList(elements.searchBox.Text)
  end)

  UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F6 then
      gui.Enabled = not gui.Enabled
    end
  end)
end

-- ─── Store Scanner ───

function store:FindPlot()
  -- Method 1: Use Functions.CharPlot if available
  if FUNCTIONS and FUNCTIONS:IsA("ModuleScript") then
    local ok, plot = pcall(require, FUNCTIONS)
    if ok and type(plot) == "table" and plot.CharPlot then
      local p = plot.CharPlot(player.Character or player)
      if p then return p end
    end
  end

  -- Method 2: Find through player folder in workspace
  -- Method 3: Look for plot by proximity (common in tycoons)
  local char = player.Character
  if char then
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
      local pos = root.Position
      for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v.PrimaryPart then
          local dist = (v.PrimaryPart.Position - pos).Magnitude
          if dist < 100 and (v.Name:find("Plot") or v.Name:find("Store") or v:GetAttribute("PlotId")) then
            return v
          end
        end
      end
    end
  end

  return nil
end

function store:DetectShelfProducts()
  local detected = {}
  local productMap = {}

  -- Scan workspace for shelves with product information
  for _, v in ipairs(workspace:GetDescendants()) do
    if v:IsA("Part") or v:IsA("Model") then
      local name = v.Name:lower()

      -- Common shelf/display names in RT2
      local isShelf = name:find("shelf") or name:find("display") or name:find("rack")
          or name:find("prateleira") or name:find("bin") or name:find("stand")
          or name:find("table") or name:find("rack2")

      if isShelf then
        -- Check for attributes
        local prodName = v:GetAttribute("ProductName")
            or v:GetAttribute("ItemName")
            or v:GetAttribute("SellingItem")
        local quantity = v:GetAttribute("Quantity")
            or v:GetAttribute("Stock")
            or v:GetAttribute("Amount")
        local maxStock = v:GetAttribute("MaxQuantity")
            or v:GetAttribute("MaxStock")
            or v:GetAttribute("Capacity")

        if prodName then
          if not detected[prodName] then
            detected[prodName] = { current = 0, maxStock = 0, shelves = 0 }
          end
          detected[prodName].current = detected[prodName].current + (tonumber(quantity) or 0)
          detected[prodName].maxStock = detected[prodName].maxStock + (tonumber(maxStock) or tonumber(quantity) or 50)
          detected[prodName].shelves = detected[prodName].shelves + 1
        end

        -- Alternative: check children for product info
        for _, child in ipairs(v:GetChildren()) do
          if child:IsA("StringValue") and child.Name == "ProductName" then
            local qtyVal = v:FindFirstChild("Quantity") or v:FindFirstChild("Stock")
            local maxVal = v:FindFirstChild("MaxQuantity") or v:FindFirstChild("MaxStock")
            local pName = child.Value
            if not detected[pName] then
              detected[pName] = { current = 0, maxStock = 0, shelves = 0 }
            end
            detected[pName].current = detected[pName].current + (qtyVal and tonumber(qtyVal.Value) or 0)
            detected[pName].maxStock = detected[pName].maxStock + (maxVal and tonumber(maxVal.Value) or 50)
            detected[pName].shelves = detected[pName].shelves + 1
          end
        end
      end
    end
  end

  -- Also check BillboardGuis (commonly used for stock display above shelves)
  for _, billboard in ipairs(workspace:GetDescendants()) do
    if billboard:IsA("BillboardGui") and billboard.Enabled then
      for _, child in ipairs(billboard:GetChildren()) do
        if child:IsA("TextLabel") and child.Text then
          local num = tonumber(child.Text)
          if num then
            local parentName = billboard.Parent and billboard.Parent.Name or "Unknown"
            if not detected[parentName] or (detected[parentName] and detected[parentName].current == 0) then
              if not detected[parentName] then
                detected[parentName] = { current = num, maxStock = num * 2, shelves = 1 }
              end
            end
          end
        end
      end
    end
  end

  return detected
end

function store:DetectProductsFromPlayerData()
  local detected = {}

  -- Method: check player's replicated data
  local data = player:FindFirstChild("Data") or player:FindFirstChild("PlayerData")
  if data then
    local storeData = data:FindFirstChild("Store") or data:FindFirstChild("Inventory") or data:FindFirstChild("Products")
    if storeData then
      for _, item in ipairs(storeData:GetChildren()) do
        local name = item.Name
        local qty = item:GetAttribute("Quantity") or (item:IsA("NumberValue") and item.Value)
        if name and qty then
          if not detected[name] then
            detected[name] = { current = 0, maxStock = 0, shelves = 0 }
          end
          detected[name].current = detected[name].current + (tonumber(qty) or 0)
        end
      end
    end

    -- Check for storage inventory
    local storage = data:FindFirstChild("StorageInventory") or data:FindFirstChild("Warehouse")
    if storage then
      for _, item in ipairs(storage:GetChildren()) do
        local name = item.Name
        -- This is storage (not on shelves)
      end
    end
  end

  -- Method: check leaderstats
  local ls = player:FindFirstChild("leaderstats")
  if ls then
    for _, v in ipairs(ls:GetChildren()) do
      if v:IsA("NumberValue") and v.Name ~= "Money" and v.Name ~= "Cash" and v.Name ~= "Level" then
        local name = v.Name
        if not detected[name] then
          detected[name] = { current = tonumber(v.Value) or 0, maxStock = 50, shelves = 1 }
        else
          detected[name].current = tonumber(v.Value) or 0
        end
      end
    end
  end

  return detected
end

function store:FullScan()
  if store.scanning then return end
  store.scanning = true
  ui:SetStatus("🔍 Escaneando loja...", "info")

  -- Scan multiple sources
  local shelfProducts = self:DetectShelfProducts()
  local dataProducts = self:DetectProductsFromPlayerData()

  -- Merge results
  local merged = {}
  for name, data in shelfProducts do
    merged[name] = { current = data.current, maxStock = data.maxStock, shelves = data.shelves }
  end
  for name, data in dataProducts do
    if not merged[name] then
      merged[name] = { current = data.current, maxStock = data.maxStock or 50, shelves = data.shelves or 1 }
    elseif data.current > merged[name].current then
      merged[name].current = data.current
    end
  end

  -- Update store products
  for name, data in merged do
    if not store.products[name] then
      store.products[name] = {
        current = data.current,
        maxStock = data.maxStock,
        min = 15,
        restockAmount = 25,
        disabled = false,
        shelves = data.shelves,
        category = self:GuessCategory(name),
      }
    else
      store.products[name].current = data.current
      store.products[name].maxStock = data.maxStock
      store.products[name].shelves = data.shelves
    end
  end

  ui:RefreshProductList()
  ui:SetStatus("✅ Scan concluído — " .. self:ProductCount() .. " produtos encontrados", "success")
  task.wait(0.3)
  store.scanning = false
end

function store:GuessCategory(name)
  name = name:lower()
  local keywords = {
    Toys = {"toy", "action figure", "doll", "lego", "board game", "puzzle"},
    Clothing = {"shirt", "pants", "jeans", "jacket", "dress", "skirt", "sweater", "hoodie"},
    Shoes = {"shoe", "sneaker", "boot", "sandals"},
    Electronics = {"phone", "tablet", "laptop", "computer", "headphone", "speaker", "tv", "monitor"},
    Food = {"canned", "boxed", "snack", "candy", "beverage", "drink", "soda", "chip", "cookie"},
    Furniture = {"chair", "table", "desk", "sofa", "couch", "bed", "cabinet", "shelf"},
    Sports = {"ball", "racket", "bike", "treadmill", "dumbbell", "yoga"},
    Pets = {"dog", "cat", "bird", "fish", "pet", "leash", "collar"},
    Automotive = {"car", "tire", "battery", "oil", "engine", "part", "accessory"},
  }
  for cat, words in keywords do
    for _, w in ipairs(words) do
      if name:find(w) then return cat end
    end
  end
  return "Other"
end

function store:ProductCount()
  local c = 0
  for _, _ in pairs(store.products) do c = c + 1 end
  return c
end

-- ─── Auto Restock Engine ───

function store:FindBuyRemote()
  if not REMOTES then
    REMOTES = ReplicatedStorage:FindFirstChild("Remotes")
    if not REMOTES then return nil end
  end

  -- Known names for restock/buy remotes in RT2
  local remoteNames = {
    "BuyItem", "BuyProduct", "RestockItem", "RestockShelf",
    "PurchaseItem", "OrderStock", "OrderInventory", "BuyStock",
    "PurchaseStock", "RestockFromStorage", "ManagerBuyItem",
  }

  for _, name in ipairs(remoteNames) do
    local r = REMOTES:FindFirstChild(name)
    if r then return r end
  end

  -- Fallback: list all remotes so the user can identify the right one
  local found = {}
  for _, v in ipairs(REMOTES:GetChildren()) do
    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
      table.insert(found, v.Name)
    end
  end
  return nil, found
end

function store:SetMode(running)
  if running then
    ui:SetStatus("▶ Auto stock ATIVO", "success")
    self:AutoRestockLoop()
  else
    ui:SetStatus("⏸ Auto stock PAUSADO", "warning")
  end
end

function store:AutoRestockLoop()
  while store.running do
    task.wait(3)

    if not store.running then break end

    local remote, allRemotes = self:FindBuyRemote()
    if not remote then
      ui:SetStatus("⚠ Remote de compra não encontrada", "error")
      -- Try to detect remotes from game events
      self:DiscoverRemotes()
      task.wait(5)
      continue
    end

    local restocked = 0
    for name, prod in store.products do
      if prod.disabled then continue end

      -- Re-scan current stock for this product
      local freshData = self:DetectShelfProducts()
      local currentQty = freshData[name] and freshData[name].current or 0

      store.stats.totalAttempts = store.stats.totalAttempts + 1

      if currentQty < prod.min then
        local needed = math.max(prod.restockAmount or prod.min, prod.min - currentQty)

        -- Try fire remote
        local ok = false
        local errMsg = ""

        if remote:IsA("RemoteEvent") then
          -- Try different argument patterns
          local argPatterns = {
            { name, needed },
            { name, needed, false },  -- no instant delivery
            { name, needed, false, nil },
            { needed, name },
          }
          for _, args in ipairs(argPatterns) do
            ok = pcall(function()
              remote:FireServer(unpack(args))
            end)
            if ok then break end
          end
        elseif remote:IsA("RemoteFunction") then
          ok = pcall(function()
            remote:InvokeServer(name, needed)
          end)
          if not ok then
            ok = pcall(function()
              remote:InvokeServer(needed, name)
            end)
          end
        end

        if ok then
          store.stats.totalRestocks = store.stats.totalRestocks + 1
          prod.current = prod.current + needed
          restocked = restocked + 1
          ui:SetStatus("✅ Restock: " .. name .. " (+" .. needed .. ")", "success")
        else
          store.stats.failedAttempts = store.stats.failedAttempts + 1
        end

        ui:UpdateStats()
        task.wait(1.5)
      end
    end

    if restocked == 0 then
      ui:SetStatus("📊 Estoque OK — " .. self:ProductCount() .. " produtos monitorados", "idle")
    end

    ui:RefreshProductList()
  end
end

function store:DiscoverRemotes()
  if not REMOTES then return end

  local stockRelated = {}
  for _, v in ipairs(REMOTES:GetChildren()) do
    local n = v.Name:lower()
    if n:find("buy") or n:find("stock") or n:find("restock") or n:find("item") or n:find("product") or n:find("order") or n:find("purchase") or n:find("shop") then
      table.insert(stockRelated, v.Name)
    end
  end

  if #stockRelated > 0 then
    local msg = "Remotes encontradas:\n"
    for _, name in ipairs(stockRelated) do
      msg = msg .. "  • " .. name .. "\n"
    end
    warn("[RT2 Stock Manager] " .. msg)
  end
end

-- ─── Init ───
local elements = ui:Create()
ui:Init(elements)

-- Auto-scan after 3s
task.delay(3, function()
  store:FullScan()
end)

print("[RT2 Stock Manager] v2.0 carregado! F6 para toggle UI")
