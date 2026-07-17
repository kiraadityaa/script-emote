--[[
    HAKIRA ADITYA RESPONSIVE LOADER (TRUE FULLSCREEN BUILD)
    =========================================
    Lead Developer : hakiraadityaa
    Roblox Developer: ArchDityaa
    Theme           : Modern Monochrome (Mobile Responsive)
    Duration        : 6.0 Seconds
    Target Payload  : https://raw.githubusercontent.com/hakiraadityaa/emote-menu-script/refs/heads/main/emote%20
    
    COMPATIBILITY: Lua 5.1 / Luau (Delta Executor, Wave, Hydrogen, etc.)
--]]

local CONFIG = {
    DEVELOPER_NAME = "hakiraadityaa",
    ROBLOX_ACCOUNT = "ArchDityaa",
    LOADING_DURATION = 6.0,
    TARGET_SCRIPT_URL = "https://raw.githubusercontent.com/kiraadityaa/script-emote/refs/heads/main/module",
    FALLBACK_SCRIPT_URL = "https://raw.githubusercontent.com/kiraadityaa/script-emote/refs/heads/main/module",
    
    -- CONFIGURASI MAINTENANCE & KEAMANAN
    MAINTENANCE = {
        ENABLED = false, -- Ubah ke 'true' untuk menutup akses total (KICK SEMUA ORANG TERMASUK DEVELOPER)
        REASON = "Your account has been banned due to exploit abuse."
    },
    
    SECURITY = {
        KICK_MESSAGE = "Akses Ditolak! Akun Anda (%s) tidak terdaftar dalam whitelist Hakira Engine."
    },

    WHITELIST = {
        ["kiraadityaa"] = true,
        ["dioneeee2"] = true,
        ["jakespudin"] = true,
        ["archdityaa"] = true
    },
    THEME = {
        BACKGROUND_PRIMARY   = Color3.fromRGB(12, 12, 12),
        BACKGROUND_SECONDARY = Color3.fromRGB(18, 18, 18),
        BACKGROUND_TERTIARY  = Color3.fromRGB(24, 24, 24),
        BORDER_COLOR         = Color3.fromRGB(35, 35, 35),
        BORDER_HIGHLIGHT     = Color3.fromRGB(70, 70, 70),
        TEXT_PRIMARY         = Color3.fromRGB(255, 255, 255),
        TEXT_SECONDARY       = Color3.fromRGB(150, 150, 150),
        TEXT_MUTED           = Color3.fromRGB(90, 90, 90),
        ACCENT_WHITE         = Color3.fromRGB(245, 245, 245),
        ACCENT_DARK          = Color3.fromRGB(40, 40, 40),
        ERROR_COLOR          = Color3.fromRGB(200, 70, 70),
        SUCCESS_COLOR        = Color3.fromRGB(120, 220, 120)
    },
    PARTICLE_SETTINGS = {
        MAX_PARTICLES = 25,
        MIN_SPEED = 10,
        MAX_SPEED = 30,
        MIN_SIZE = 2,
        MAX_SIZE = 4
    }
}

local Env = {
    getgenv = getgenv or function() return _G end,
    cloneref = cloneref or function(obj) return obj end,
    request = request or (http and http.request) or syn_request,
    setclipboard = setclipboard or to_clipboard or (syn and syn.write_clipboard),
    identifyexecutor = identifyexecutor or function() return "Unknown Executor" end
}

local CoreGui = Env.cloneref(game:GetService("CoreGui"))
local Players = Env.cloneref(game:GetService("Players"))
local RunService = Env.cloneref(game:GetService("RunService"))
local TweenService = Env.cloneref(game:GetService("TweenService"))
local UserInputService = Env.cloneref(game:GetService("UserInputService"))
local HttpService = Env.cloneref(game:GetService("HttpService"))
local Stats = Env.cloneref(game:GetService("Stats"))

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.1)
    LocalPlayer = Players.LocalPlayer
end

-- FUNGSI KICK BERLAPIS (MENGATASI BYPASS/ANTI-KICK DARI CLIENT EXECUTOR)
local function ForceKick(reason)
    -- Langkah 1: Panggil pemutusan koneksi standar Roblox
    pcall(function()
        LocalPlayer:Kick(reason)
    end)
    
    -- Memberi waktu jeda singkat agar paket jaringan diproses
    task.wait(0.3)
    
    -- Langkah 2: Crash Loop (Jika player menggunakan Anti-Kick, client game akan dipaksa membeku/membeludak memorinya)
    while true do
        pcall(function()
            local memorySaturator = {}
            while true do
                table.insert(memorySaturator, string.rep("HAKIRA_FORCE_EXIT_", 5000))
            end
        end)
        task.wait()
    end
end

local function GetGuiParent()
    local success, coreGuiResult = pcall(function()
        local test = Instance.new("Folder")
        test.Parent = CoreGui
        test:Destroy()
        return CoreGui
    end)
    if success then
        return CoreGui
    else
        return LocalPlayer:WaitForChild("PlayerGui")
    end
end

local function CopyToClipboard(text)
    if Env.setclipboard then
        pcall(function()
            Env.setclipboard(text)
        end)
    end
end

local Easing = {}

function Easing.OutQuad(t, b, c, d)
    t = t / d
    return -c * t * (t - 2) + b
end

function Easing.OutCubic(t, b, c, d)
    t = t / d - 1
    return c * (t * t * t + 1) + b
end

function Easing.InOutQuad(t, b, c, d)
    t = t / (d / 2)
    if t < 1 then
        return c / 2 * t * t + b
    end
    t = t - 1
    return -c / 2 * (t * (t - 2) - 1) + b
end

function Easing.OutBack(t, b, c, d, s)
    if not s then s = 1.70158 end
    t = t / d - 1
    return c * (t * t * ((s + 1) * t + s) + 1) + b
end

function Easing.OutBounce(t, b, c, d)
    t = t / d
    if t < (1 / 2.75) then
        return c * (7.5625 * t * t) + b
    elseif t < (2 / 2.75) then
        t = t - (1.5 / 2.75)
        return c * (7.5625 * t * t + 0.75) + b
    elseif t < (2.5 / 2.75) then
        t = t - (2.25 / 2.75)
        return c * (7.5625 * t * t + 0.9375) + b
    else
        t = t - (2.625 / 2.75)
        return c * (7.5625 * t * t + 0.984375) + b
    end
end

function Easing.OutElastic(t, b, c, d, a, p)
    if t == 0 then return b end
    t = t / d
    if t == 1 then return b + c end
    if not p then p = d * 0.3 end
    local s
    if not a or a < math.abs(c) then
        a = c
        s = p / 4
    else
        s = p / (2 * math.pi) * math.asin(c / a)
    end
    return a * math.pow(2, -10 * t) * math.sin((t * d - s) * (2 * math.pi) / p) + c + b
end

function Easing.LerpColor(colorA, colorB, alpha)
    return colorA:Lerp(colorB, alpha)
end

local StyleSheet = {}
StyleSheet.__index = StyleSheet

StyleSheet.Classes = {
    MainFrame = {
        BackgroundColor3 = CONFIG.THEME.BACKGROUND_PRIMARY,
        BorderSizePixel = 0,
        ClipsDescendants = true
    },
    Panel = {
        BackgroundColor3 = CONFIG.THEME.BACKGROUND_SECONDARY,
        BorderSizePixel = 0
    },
    SubPanel = {
        BackgroundColor3 = CONFIG.THEME.BACKGROUND_TERTIARY,
        BorderSizePixel = 0
    },
    HeaderLabel = {
        TextColor3 = CONFIG.THEME.TEXT_PRIMARY,
        Font = Enum.Font.GothamBold,
        BackgroundTransparency = 1
    },
    StandardLabel = {
        TextColor3 = CONFIG.THEME.TEXT_SECONDARY,
        Font = Enum.Font.SourceSans,
        BackgroundTransparency = 1
    },
    CodeLabel = {
        TextColor3 = CONFIG.THEME.TEXT_MUTED,
        Font = Enum.Font.Code,
        BackgroundTransparency = 1
    }
}

function StyleSheet:Apply(instance, className)
    local properties = self.Classes[className]
    if properties then
        for propName, value in pairs(properties) do
            instance[propName] = value
        end
    end
end

local AnimationController = {}
AnimationController.__index = AnimationController

function AnimationController.new()
    local self = setmetatable({}, AnimationController)
    self.ActiveTweens = {}
    
    RunService.Heartbeat:Connect(function(deltaTime)
        self:Update(deltaTime)
    end)
    
    return self
end

function AnimationController:Create(instance, duration, easingFunc, properties)
    local tweenData = {
        Instance = instance,
        Duration = duration,
        EasingFunc = easingFunc,
        Properties = properties,
        Elapsed = 0,
        InitialValues = {}
    }
    
    for prop, _ in pairs(properties) do
        tweenData.InitialValues[prop] = instance[prop]
    end
    
    table.insert(self.ActiveTweens, tweenData)
    
    local control = {}
    function control:Cancel()
        tweenData.Cancelled = true
    end
    
    return control
end

function AnimationController:Update(dt)
    for i = #self.ActiveTweens, 1, -1 do
        local tween = self.ActiveTweens[i]
        
        if tween.Cancelled then
            table.remove(self.ActiveTweens, i)
        else
            tween.Elapsed = tween.Elapsed + dt
            local t = math.min(tween.Elapsed, tween.Duration)
            
            for prop, targetValue in pairs(tween.Properties) do
                local initial = tween.InitialValues[prop]
                if typeof(targetValue) == "number" then
                    tween.Instance[prop] = tween.EasingFunc(t, initial, targetValue - initial, tween.Duration)
                elseif typeof(targetValue) == "UDim2" then
                    local scaleX = tween.EasingFunc(t, initial.X.Scale, targetValue.X.Scale - initial.X.Scale, tween.Duration)
                    local offsetX = tween.EasingFunc(t, initial.X.Offset, targetValue.X.Offset - initial.X.Offset, tween.Duration)
                    local scaleY = tween.EasingFunc(t, initial.Y.Scale, targetValue.Y.Scale - initial.Y.Scale, tween.Duration)
                    local offsetY = tween.EasingFunc(t, initial.Y.Offset, targetValue.Y.Offset - initial.Y.Offset, tween.Duration)
                    tween.Instance[prop] = UDim2.new(scaleX, offsetX, scaleY, offsetY)
                elseif typeof(targetValue) == "Color3" then
                    local r = tween.EasingFunc(t, initial.R, targetValue.R - initial.R, tween.Duration)
                    local g = tween.EasingFunc(t, initial.G, targetValue.G - initial.G, tween.Duration)
                    local b = tween.EasingFunc(t, initial.B, targetValue.B - initial.B, tween.Duration)
                    tween.Instance[prop] = Color3.new(r, g, b)
                end
            end
            
            if tween.Elapsed >= tween.Duration then
                table.remove(self.ActiveTweens, i)
            end
        end
    end
end

local GlobalAnimator = AnimationController.new()

local DragController = {}
DragController.__index = DragController

function DragController.new(frame)
    local self = setmetatable({}, DragController)
    self.Frame = frame
    self.Dragging = false
    self.DragInput = nil
    self.DragStart = nil
    self.StartPos = nil
    
    self.Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.Dragging = true
            self.DragStart = input.Position
            self.StartPos = self.Frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    self.Dragging = false
                end
            end)
        end
    end)
    
    self.Frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            self.DragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == self.DragInput and self.Dragging then
            local delta = input.Position - self.DragStart
            local targetPos = UDim2.new(
                self.StartPos.X.Scale,
                self.StartPos.X.Offset + delta.X,
                self.StartPos.Y.Scale,
                self.StartPos.Y.Offset + delta.Y
            )
            GlobalAnimator:Create(self.Frame, 0.15, Easing.OutQuad, {Position = targetPos})
        end
    end)
    
    return self
end

local ParticleEngine = {}
ParticleEngine.__index = ParticleEngine

function ParticleEngine.new(parentFrame)
    local self = setmetatable({}, ParticleEngine)
    self.Parent = parentFrame
    self.Particles = {}
    self.Active = true
    
    for i = 1, CONFIG.PARTICLE_SETTINGS.MAX_PARTICLES do
        self:CreatePooledParticle(math.random(0, 1000) / 1000, math.random(0, 1000) / 1000)
    end
    
    RunService.RenderStepped:Connect(function(dt)
        if self.Active then
            self:UpdateParticles(dt)
        end
    end)
    
    return self
end

function ParticleEngine:CreatePooledParticle(startX, startY)
    local size = math.random(CONFIG.PARTICLE_SETTINGS.MIN_SIZE, CONFIG.PARTICLE_SETTINGS.MAX_SIZE)
    
    local particle = Instance.new("Frame")
    particle.Name = "ParticleNode"
    particle.Size = UDim2.new(0, size, 0, size)
    particle.Position = UDim2.new(startX, 0, startY or 1.1, 0)
    particle.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
    particle.BackgroundTransparency = math.random(6, 9) / 10
    particle.BorderSizePixel = 0
    particle.Parent = self.Parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = particle
    
    local pData = {
        Instance = particle,
        Speed = math.random(CONFIG.PARTICLE_SETTINGS.MIN_SPEED, CONFIG.PARTICLE_SETTINGS.MAX_SPEED),
        SwaySpeed = math.random(1, 3),
        SwayWidth = math.random(1, 3) / 100,
        Time = math.random(0, 100)
    }
    
    table.insert(self.Particles, pData)
end

function ParticleEngine:UpdateParticles(dt)
    local parentHeight = self.Parent.AbsoluteSize.Y
    if parentHeight <= 0 then parentHeight = 290 end
    
    for i = 1, #self.Particles do
        local p = self.Particles[i]
        if p.Instance and p.Instance.Parent then
            p.Time = p.Time + dt
            local currentPos = p.Instance.Position
            local deltaY = -(p.Speed * dt) / parentHeight
            local newY = currentPos.Y.Scale + deltaY
            local newX = currentPos.X.Scale + math.sin(p.Time * p.SwaySpeed) * p.SwayWidth * dt
            
            if newY < -0.1 then
                newY = 1.1
                newX = math.random(0, 1000) / 1000
                p.Speed = math.random(CONFIG.PARTICLE_SETTINGS.MIN_SPEED, CONFIG.PARTICLE_SETTINGS.MAX_SPEED)
            end
            
            p.Instance.Position = UDim2.new(newX, 0, newY, 0)
        end
    end
end

function ParticleEngine:Destroy()
    self.Active = false
    for _, p in ipairs(self.Particles) do
        if p.Instance then
            p.Instance:Destroy()
        end
    end
    self.Particles = {}
end

local UI = {}

local function MakeTextResponsive(label, minSize, maxSize)
    label.TextScaled = true
    local constraint = Instance.new("UITextSizeConstraint")
    constraint.Parent = label
    constraint.MinTextSize = minSize or 7
    constraint.MaxTextSize = maxSize or 13
end

local function ApplyHoverEffect(button, defaultBg, hoverBg)
    button.MouseEnter:Connect(function()
        GlobalAnimator:Create(button, 0.15, Easing.OutQuad, {BackgroundColor3 = hoverBg})
    end)
    button.MouseLeave:Connect(function()
        GlobalAnimator:Create(button, 0.15, Easing.OutQuad, {BackgroundColor3 = defaultBg})
    end)
end

function UI.CreateBase(guiParent)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HakiraAditya_LoaderGui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true 
    screenGui.DisplayOrder = 999999
    screenGui.Parent = guiParent
    return screenGui
end

function UI.CreateMainFrame(parent)
    local frame = Instance.new("Frame")
    frame.Name = "MainCanvas"
    frame.Size = UDim2.new(0.8, 0, 0.75, 0)
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    
    StyleSheet:Apply(frame, "MainFrame")
    frame.Parent = parent
    
    local sizeConstraint = Instance.new("UISizeConstraint")
    sizeConstraint.MinSize = Vector2.new(340, 240)
    sizeConstraint.MaxSize = Vector2.new(460, 290)
    sizeConstraint.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = CONFIG.THEME.BORDER_COLOR
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = frame
    
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "ShadowEffect"
    shadow.Size = UDim2.new(1, 24, 1, 24)
    shadow.Position = UDim2.new(0, -12, 0, -12)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.ZIndex = 0
    shadow.Parent = frame
    
    return frame
end

function UI.CreateDecorations(parent)
    local gridPattern = Instance.new("Frame")
    gridPattern.Name = "GridBackground"
    gridPattern.Size = UDim2.new(1, 0, 1, 0)
    gridPattern.BackgroundTransparency = 1
    gridPattern.ZIndex = 1
    gridPattern.Parent = parent
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0.12, 0)
    line.BackgroundColor3 = CONFIG.THEME.BORDER_COLOR
    line.BorderSizePixel = 0
    line.Parent = parent
end

function UI.CreateHeader(parent)
    local headerFrame = Instance.new("Frame")
    headerFrame.Name = "HeaderArea"
    headerFrame.Size = UDim2.new(1, -20, 0, 24)
    headerFrame.Position = UDim2.new(0, 10, 0, 8)
    headerFrame.BackgroundTransparency = 1
    headerFrame.Parent = parent
    
    local icon = Instance.new("Frame")
    icon.Name = "IconDecor"
    icon.Size = UDim2.new(0, 20, 0, 20)
    icon.Position = UDim2.new(0, 0, 0.5, -10)
    icon.BackgroundColor3 = CONFIG.THEME.ACCENT_WHITE
    icon.BorderSizePixel = 0
    icon.Parent = headerFrame
    
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(0, 3)
    iconCorner.Parent = icon
    
    local iconText = Instance.new("TextLabel")
    iconText.Size = UDim2.new(1, 0, 1, 0)
    iconText.Text = "H"
    iconText.TextColor3 = CONFIG.THEME.BACKGROUND_PRIMARY
    iconText.Font = Enum.Font.SourceSansBold
    iconText.TextSize = 12
    iconText.BackgroundTransparency = 1
    iconText.Parent = icon
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(0.5, -20, 1, 0)
    titleLabel.Position = UDim2.new(0, 26, 0, 0)
    titleLabel.Text = "HAKIRA ENGINE"
    StyleSheet:Apply(titleLabel, "HeaderLabel")
    titleLabel.Parent = headerFrame
    MakeTextResponsive(titleLabel, 10, 14)
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.new(0, 18, 0, 18)
    closeBtn.Position = UDim2.new(1, -18, 0.5, -9)
    closeBtn.BackgroundColor3 = CONFIG.THEME.BACKGROUND_SECONDARY
    closeBtn.Text = "×"
    closeBtn.TextColor3 = CONFIG.THEME.TEXT_PRIMARY
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 13
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = headerFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = closeBtn
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Thickness = 1
    btnStroke.Color = CONFIG.THEME.BORDER_COLOR
    btnStroke.Parent = closeBtn
    
    ApplyHoverEffect(closeBtn, CONFIG.THEME.BACKGROUND_SECONDARY, CONFIG.THEME.BACKGROUND_TERTIARY)
    
    local subtitleBadge = Instance.new("Frame")
    subtitleBadge.Name = "SubtitleBadge"
    subtitleBadge.Size = UDim2.new(0, 80, 0, 16)
    subtitleBadge.Position = UDim2.new(1, -104, 0.5, -8)
    StyleSheet:Apply(subtitleBadge, "SubPanel")
    subtitleBadge.Parent = headerFrame
    
    local badgeCorner = Instance.new("UICorner")
    badgeCorner.CornerRadius = UDim.new(0, 3)
    badgeCorner.Parent = subtitleBadge
    
    local badgeStroke = Instance.new("UIStroke")
    badgeStroke.Thickness = 1
    badgeStroke.Color = CONFIG.THEME.BORDER_COLOR
    badgeStroke.Parent = subtitleBadge
    
    local badgeText = Instance.new("TextLabel")
    badgeText.Size = UDim2.new(1, 0, 1, 0)
    badgeText.Text = "ACTIVE LOADER"
    badgeText.TextColor3 = CONFIG.THEME.TEXT_SECONDARY
    badgeText.Font = Enum.Font.Code
    badgeText.BackgroundTransparency = 1
    badgeText.Parent = subtitleBadge
    MakeTextResponsive(badgeText, 7, 8)
    
    return closeBtn
end

function UI.CreateTabSelector(parent)
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, -20, 0, 22)
    tabContainer.Position = UDim2.new(0, 10, 0, 38)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = parent
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.FillDirection = Enum.FillDirection.Horizontal
    listLayout.Padding = UDim.new(0, 4)
    listLayout.Parent = tabContainer
    
    local function MakeTabButton(name, labelText, isSelected)
        local btn = Instance.new("TextButton")
        btn.Name = name .. "Tab"
        btn.Size = UDim2.new(0, 75, 1, 0)
        btn.BackgroundColor3 = isSelected and CONFIG.THEME.BACKGROUND_SECONDARY or CONFIG.THEME.BACKGROUND_PRIMARY
        btn.BorderSizePixel = 0
        btn.Text = labelText
        btn.TextColor3 = isSelected and CONFIG.THEME.TEXT_PRIMARY or CONFIG.THEME.TEXT_MUTED
        btn.Font = Enum.Font.SourceSansBold
        btn.AutoButtonColor = false
        btn.Parent = tabContainer
        MakeTextResponsive(btn, 8, 10)
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 3)
        corner.Parent = btn
        
        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1
        stroke.Color = isSelected and CONFIG.THEME.BORDER_HIGHLIGHT or CONFIG.THEME.BORDER_COLOR
        stroke.Parent = btn
        
        return btn
    end
    
    local loaderTab = MakeTabButton("Loader", "LOADER", true)
    local diagnosticsTab = MakeTabButton("Diagnostics", "DIAGNOSTICS", false)
    local creditsTab = MakeTabButton("Credits", "DEVELOPER", false)
    
    return tabContainer, loaderTab, diagnosticsTab, creditsTab
end

function UI.CreateSubPages(parent)
    local pageContainer = Instance.new("Frame")
    pageContainer.Name = "PageContainer"
    pageContainer.Size = UDim2.new(1, -20, 1, -104)
    pageContainer.Position = UDim2.new(0, 10, 0, 66)
    pageContainer.BackgroundTransparency = 1
    pageContainer.Parent = parent
    
    local loaderPage = Instance.new("CanvasGroup")
    loaderPage.Name = "LoaderPage"
    loaderPage.Size = UDim2.new(1, 0, 1, 0)
    loaderPage.BackgroundTransparency = 1
    loaderPage.GroupTransparency = 0
    loaderPage.Visible = true
    loaderPage.Parent = pageContainer
    
    local loaderLayout = Instance.new("UIListLayout")
    loaderLayout.FillDirection = Enum.FillDirection.Vertical
    loaderLayout.SortOrder = Enum.SortOrder.LayoutOrder
    loaderLayout.Padding = UDim.new(0, 4)
    loaderLayout.Parent = loaderPage
    
    local diagnosticsPage = Instance.new("CanvasGroup")
    diagnosticsPage.Name = "DiagnosticsPage"
    diagnosticsPage.Size = UDim2.new(1, 0, 1, 0)
    diagnosticsPage.BackgroundTransparency = 1
    diagnosticsPage.GroupTransparency = 1
    diagnosticsPage.Visible = false
    diagnosticsPage.Parent = pageContainer
    
    local diagBack = Instance.new("Frame")
    diagBack.Size = UDim2.new(1, 0, 1, 0)
    StyleSheet:Apply(diagBack, "Panel")
    diagBack.Parent = diagnosticsPage
    
    local diagCorner = Instance.new("UICorner")
    diagCorner.CornerRadius = UDim.new(0, 5)
    diagCorner.Parent = diagBack
    
    local diagStroke = Instance.new("UIStroke")
    diagStroke.Thickness = 1
    diagStroke.Color = CONFIG.THEME.BORDER_COLOR
    diagStroke.Parent = diagBack
    
    local diagScroll = Instance.new("ScrollingFrame")
    diagScroll.Size = UDim2.new(1, -16, 1, -16)
    diagScroll.Position = UDim2.new(0, 8, 0, 8)
    diagScroll.BackgroundTransparency = 1
    diagScroll.BorderSizePixel = 0
    diagScroll.ScrollBarThickness = 3
    diagScroll.ScrollBarImageColor3 = CONFIG.THEME.BORDER_HIGHLIGHT
    diagScroll.Parent = diagBack
    
    local mainDiagLabel = Instance.new("TextLabel")
    mainDiagLabel.Size = UDim2.new(1, 0, 1, 50)
    StyleSheet:Apply(mainDiagLabel, "CodeLabel")
    mainDiagLabel.TextXAlignment = Enum.TextXAlignment.Left
    mainDiagLabel.TextYAlignment = Enum.TextYAlignment.Top
    mainDiagLabel.LineHeight = 1.25
    mainDiagLabel.Parent = diagScroll
    
    local creditsPage = Instance.new("CanvasGroup")
    creditsPage.Name = "CreditsPage"
    creditsPage.Size = UDim2.new(1, 0, 1, 0)
    creditsPage.BackgroundTransparency = 1
    creditsPage.GroupTransparency = 1
    creditsPage.Visible = false
    creditsPage.Parent = pageContainer
    
    local credBack = Instance.new("Frame")
    credBack.Size = UDim2.new(1, 0, 1, 0)
    StyleSheet:Apply(credBack, "Panel")
    credBack.Parent = creditsPage
    
    local credCorner = Instance.new("UICorner")
    credCorner.CornerRadius = UDim.new(0, 5)
    credCorner.Parent = credBack
    
    local credStroke = Instance.new("UIStroke")
    credStroke.Thickness = 1
    credStroke.Color = CONFIG.THEME.BORDER_COLOR
    credStroke.Parent = credBack
    
    local devAvatar = Instance.new("ImageLabel")
    devAvatar.Size = UDim2.new(0, 60, 0, 60)
    devAvatar.Position = UDim2.new(0, 12, 0.5, -30)
    StyleSheet:Apply(devAvatar, "SubPanel")
    devAvatar.Image = "rbxassetid://3031023249" 
    devAvatar.ImageColor3 = Color3.fromRGB(180, 180, 180)
    devAvatar.Parent = credBack
    
    local avCorner = Instance.new("UICorner")
    avCorner.CornerRadius = UDim.new(0, 6)
    avCorner.Parent = devAvatar
    
    local profileInfo = Instance.new("TextLabel")
    profileInfo.Size = UDim2.new(1, -85, 1, -10)
    profileInfo.Position = UDim2.new(0, 78, 0, 5)
    StyleSheet:Apply(profileInfo, "StandardLabel")
    profileInfo.TextColor3 = CONFIG.THEME.TEXT_PRIMARY
    profileInfo.TextXAlignment = Enum.TextXAlignment.Left
    profileInfo.TextYAlignment = Enum.TextYAlignment.Top
    profileInfo.LineHeight = 1.3
    profileInfo.Text = "HAKIRA ADITYA ENTERPRISE\nLead Designer: @hakiraadityaa\nOwner Account: @ArchDityaa\nQuality Assurance: Active Verified Developer\nStatus: Secure Mono Engine Build"
    profileInfo.Parent = credBack
    MakeTextResponsive(profileInfo, 9, 11)
    
    return loaderPage, diagnosticsPage, mainDiagLabel, creditsPage
end

function UI.CreateMainLoaderInfo(parent)
    local infoArea = Instance.new("Frame")
    infoArea.Name = "InfoArea"
    infoArea.Size = UDim2.new(1, 0, 0.25, -2)
    StyleSheet:Apply(infoArea, "Panel")
    infoArea.LayoutOrder = 1
    infoArea.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = infoArea
    
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = CONFIG.THEME.BORDER_COLOR
    stroke.Parent = infoArea
    
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -20, 0.5, 0)
    titleText.Position = UDim2.new(0, 10, 0.1, 0)
    titleText.Text = "Emote Menu Execution Suite"
    StyleSheet:Apply(titleText, "HeaderLabel")
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = infoArea
    MakeTextResponsive(titleText, 10, 12)
    
    local targetText = Instance.new("TextLabel")
    targetText.Size = UDim2.new(1, -20, 0.4, 0)
    targetText.Position = UDim2.new(0, 10, 0.55, 0)
    targetText.Text = "Repository: github.com/hakiraadityaa"
    StyleSheet:Apply(targetText, "CodeLabel")
    targetText.TextXAlignment = Enum.TextXAlignment.Left
    targetText.Parent = infoArea
    MakeTextResponsive(targetText, 8, 9)
    
    return infoArea
end

function UI.CreateProgressBar(parent)
    local barContainer = Instance.new("Frame")
    barContainer.Name = "BarContainer"
    barContainer.Size = UDim2.new(1, 0, 0.18, -2)
    barContainer.BackgroundTransparency = 1
    barContainer.LayoutOrder = 2
    barContainer.Parent = parent
    
    local barBg = Instance.new("Frame")
    barBg.Name = "BarBackground"
    barBg.Size = UDim2.new(1, 0, 0, 4)
    barBg.Position = UDim2.new(0, 0, 0, 2)
    StyleSheet:Apply(barBg, "Panel")
    barBg.Parent = barContainer
    
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(1, 0)
    bgCorner.Parent = barBg
    
    local bgStroke = Instance.new("UIStroke")
    bgStroke.Thickness = 1
    bgStroke.Color = CONFIG.THEME.BORDER_COLOR
    bgStroke.Parent = barBg
    
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = CONFIG.THEME.ACCENT_WHITE
    fill.BorderSizePixel = 0
    fill.Parent = barBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local percentText = Instance.new("TextLabel")
    percentText.Name = "PercentText"
    percentText.Size = UDim2.new(0, 40, 1, -8)
    percentText.Position = UDim2.new(1, -40, 0, 8)
    percentText.Text = "0%"
    StyleSheet:Apply(percentText, "CodeLabel")
    percentText.TextColor3 = CONFIG.THEME.TEXT_PRIMARY
    percentText.TextXAlignment = Enum.TextXAlignment.Right
    percentText.Parent = barContainer
    MakeTextResponsive(percentText, 9, 11)
    
    local taskText = Instance.new("TextLabel")
    taskText.Name = "TaskText"
    taskText.Size = UDim2.new(1, -50, 1, -8)
    taskText.Position = UDim2.new(0, 0, 0, 8)
    taskText.Text = "Initializing loading thread..."
    StyleSheet:Apply(taskText, "StandardLabel")
    taskText.TextXAlignment = Enum.TextXAlignment.Left
    taskText.Parent = barContainer
    MakeTextResponsive(taskText, 9, 11)
    
    return fill, percentText, taskText
end

function UI.CreateStatusConsole(parent)
    local consoleFrame = Instance.new("Frame")
    consoleFrame.Name = "ConsoleFrame"
    consoleFrame.Size = UDim2.new(1, 0, 0.57, -6)
    StyleSheet:Apply(consoleFrame, "Panel")
    consoleFrame.LayoutOrder = 3
    consoleFrame.Parent = parent
    
    local consoleCorner = Instance.new("UICorner")
    consoleCorner.CornerRadius = UDim.new(0, 5)
    consoleCorner.Parent = consoleFrame
    
    local consoleStroke = Instance.new("UIStroke")
    consoleStroke.Thickness = 1
    consoleStroke.Color = CONFIG.THEME.BORDER_COLOR
    consoleStroke.Parent = consoleFrame
    
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Name = "LogScroll"
    scrollingFrame.Size = UDim2.new(1, -12, 1, -12)
    scrollingFrame.Position = UDim2.new(0, 6, 0, 6)
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.BorderSizePixel = 0
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollingFrame.ScrollBarThickness = 3
    scrollingFrame.ScrollBarImageColor3 = CONFIG.THEME.BORDER_HIGHLIGHT
    scrollingFrame.Parent = consoleFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 2)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scrollingFrame
    
    return scrollingFrame
end

function UI.CreateFooter(parent)
    local footerFrame = Instance.new("Frame")
    footerFrame.Name = "Footer"
    footerFrame.Size = UDim2.new(1, -20, 0, 30)
    footerFrame.Position = UDim2.new(0, 10, 1, -34)
    footerFrame.BackgroundTransparency = 1
    footerFrame.Parent = parent
    
    local splitLine = Instance.new("Frame")
    splitLine.Size = UDim2.new(1, 0, 0, 1)
    splitLine.Position = UDim2.new(0, 0, 0, 0)
    splitLine.BackgroundColor3 = CONFIG.THEME.BORDER_COLOR
    splitLine.BorderSizePixel = 0
    splitLine.Parent = footerFrame
    
    local creditsFrame = Instance.new("Frame")
    creditsFrame.Name = "CreditsFrame"
    creditsFrame.Size = UDim2.new(0.65, 0, 1, -4)
    creditsFrame.Position = UDim2.new(0, 0, 0, 4)
    creditsFrame.BackgroundTransparency = 1
    creditsFrame.Parent = footerFrame
    
    local devLabel = Instance.new("TextLabel")
    devLabel.Size = UDim2.new(1, 0, 0.5, 0)
    devLabel.Text = "Lead Developer: " .. CONFIG.DEVELOPER_NAME
    StyleSheet:Apply(devLabel, "HeaderLabel")
    devLabel.TextColor3 = CONFIG.THEME.TEXT_SECONDARY
    devLabel.TextXAlignment = Enum.TextXAlignment.Left
    devLabel.Parent = creditsFrame
    MakeTextResponsive(devLabel, 8, 10)
    
    local robloxLabel = Instance.new("TextLabel")
    robloxLabel.Size = UDim2.new(1, 0, 0.5, 0)
    robloxLabel.Position = UDim2.new(0, 0, 0.5, 0)
    robloxLabel.Text = "Roblox Account: " .. CONFIG.ROBLOX_ACCOUNT
    StyleSheet:Apply(robloxLabel, "StandardLabel")
    robloxLabel.TextColor3 = CONFIG.THEME.TEXT_MUTED
    robloxLabel.TextXAlignment = Enum.TextXAlignment.Left
    robloxLabel.Parent = creditsFrame
    MakeTextResponsive(robloxLabel, 7, 8)
    
    local systemFrame = Instance.new("Frame")
    systemFrame.Name = "SystemFrame"
    systemFrame.Size = UDim2.new(0.35, 0, 1, -4)
    systemFrame.Position = UDim2.new(0.65, 0, 0, 4)
    systemFrame.BackgroundTransparency = 1
    systemFrame.Parent = footerFrame
    
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.new(1, 0, 0.5, 0)
    fpsLabel.Text = "FPS: 60.00 | MS: 16.6ms"
    StyleSheet:Apply(fpsLabel, "CodeLabel")
    fpsLabel.TextColor3 = CONFIG.THEME.TEXT_SECONDARY
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Right
    fpsLabel.Parent = systemFrame
    MakeTextResponsive(fpsLabel, 7, 9)
    
    local execLabel = Instance.new("TextLabel")
    execLabel.Size = UDim2.new(1, 0, 0.5, 0)
    execLabel.Position = UDim2.new(0, 0, 0.5, 0)
    execLabel.Text = "ENGINE: " .. string.upper(Env.identifyexecutor())
    StyleSheet:Apply(execLabel, "CodeLabel")
    execLabel.TextColor3 = CONFIG.THEME.TEXT_MUTED
    execLabel.TextXAlignment = Enum.TextXAlignment.Right
    execLabel.Parent = systemFrame
    MakeTextResponsive(execLabel, 6, 8)
    
    return fpsLabel
end

local LogConsole = {}
LogConsole.__index = LogConsole

function LogConsole.new(scrollingFrame)
    local self = setmetatable({}, LogConsole)
    self.Frame = scrollingFrame
    self.LogCount = 0
    return self
end

function LogConsole:Print(message, logType)
    self.LogCount = self.LogCount + 1
    
    local logLabel = Instance.new("TextLabel")
    logLabel.Name = "Log_" .. tostring(self.LogCount)
    logLabel.Size = UDim2.new(1, 0, 0, 13)
    StyleSheet:Apply(logLabel, "CodeLabel")
    logLabel.TextXAlignment = Enum.TextXAlignment.Left
    logLabel.LayoutOrder = self.LogCount
    
    local timestamp = os.date("%H:%M:%S")
    local typePrefix = "[INFO]"
    local textColor = CONFIG.THEME.TEXT_SECONDARY
    
    if logType == "SUCCESS" then
        typePrefix = "[OK]"
        textColor = CONFIG.THEME.SUCCESS_COLOR
    elseif logType == "ERROR" then
        typePrefix = "[FAIL]"
        textColor = CONFIG.THEME.ERROR_COLOR
    elseif logType == "SYSTEM" then
        typePrefix = "[SYS]"
        textColor = CONFIG.THEME.TEXT_PRIMARY
    end
    
    logLabel.Text = string.format("[%s] %s %s", timestamp, typePrefix, message)
    logLabel.TextColor3 = textColor
    logLabel.Parent = self.Frame
    
    self.Frame.CanvasSize = UDim2.new(0, 0, 0, self.Frame.UIListLayout.AbsoluteContentSize.Y + 15)
    self.Frame.CanvasPosition = Vector2.new(0, math.max(0, self.Frame.UIListLayout.AbsoluteContentSize.Y - self.Frame.AbsoluteSize.Y + 15))
end

function LogConsole:Clear()
    for _, item in ipairs(self.Frame:GetChildren()) do
        if item:IsA("TextLabel") then
            item:Destroy()
        end
    end
    self.LogCount = 0
    self.Frame.CanvasSize = UDim2.new(0, 0, 0, 0)
end

local SystemDiagnostics = {}
SystemDiagnostics.__index = SystemDiagnostics

function SystemDiagnostics.new(displayLabel)
    local self = setmetatable({}, SystemDiagnostics)
    self.DisplayLabel = displayLabel
    self.Active = true
    self.Frames = 0
    self.Fps = 60
    self.Ping = 0
    
    task.spawn(function()
        while self.Active do
            local prevFrameCount = self.Frames
            task.wait(1)
            local currentFrames = self.Frames - prevFrameCount
            self.Fps = currentFrames
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        self.Frames = self.Frames + 1
    end)
    
    return self
end

function SystemDiagnostics:UpdateDisplay()
    local pingValue = "N/A"
    pcall(function()
        local statsPing = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
        pingValue = string.format("%.1f", statsPing)
    end)
    
    local totalMemory = string.format("%.2f MB", collectgarbage("count") / 1024)
    local executionEnv = string.upper(Env.identifyexecutor())
    
    local diagText = string.format(
        "HAKIRA LOADER DIAGNOSTICS REPORT\n" ..
        "====================================\n" ..
        "Performance Rate   : %d FPS\n" ..
        "Network Latency    : %s ms\n" ..
        "Lua Garbage Cache  : %s\n" ..
        "Executor Suite     : %s\n" ..
        "Roblox User Account: %s (ID: %d)\n" ..
        "Game Environment   : Place ID %d (Job %s)\n" ..
        "Runtime Engine     : Monochromatic Secure Stack v4.12",
        self.Fps,
        pingValue,
        totalMemory,
        executionEnv,
        LocalPlayer.Name,
        LocalPlayer.UserId,
        game.PlaceId,
        game.JobId:sub(1, 8)
    )
    
    self.DisplayLabel.Text = diagText
end

function SystemDiagnostics:Destroy()
    self.Active = false
end

local SequenceSynchronizer = {}
SequenceSynchronizer.__index = SequenceSynchronizer

function SequenceSynchronizer.new(duration)
    local self = setmetatable({}, SequenceSynchronizer)
    self.Duration = duration
    self.Elapsed = 0
    self.Callbacks = {}
    return self
end

function SequenceSynchronizer:AddEvent(timeFraction, callback)
    table.insert(self.Callbacks, {
        Fraction = timeFraction,
        Callback = callback,
        Triggered = false
    })
end

function SequenceSynchronizer:Run(progressUpdateCallback)
    local thread = coroutine.running()
    local connection
    
    connection = RunService.Heartbeat:Connect(function(dt)
        self.Elapsed = self.Elapsed + dt
        local alpha = math.clamp(self.Elapsed / self.Duration, 0, 1)
        
        progressUpdateCallback(alpha)
        
        for _, event in ipairs(self.Callbacks) do
            if not event.Triggered and alpha >= event.Fraction then
                event.Triggered = true
                task.spawn(event.Callback)
            end
        end
        
        if alpha >= 1 then
            connection:Disconnect()
            coroutine.resume(thread)
        end
    end)
    
    coroutine.yield()
end

local PayloadExecutionManager = {}

function PayloadExecutionManager.ExecuteSecure(url, logConsole)
    logConsole:Print("Contacting upstream repository server...", "SYSTEM")
    
    local success, scriptSource = pcall(function()
        return game:HttpGet(url)
    end)
    
    if (not success or not scriptSource or #scriptSource < 10) and CONFIG.FALLBACK_SCRIPT_URL ~= url then
        logConsole:Print("Primary repository failed, requesting fallback source...", "SYSTEM")
        success, scriptSource = pcall(function()
            return game:HttpGet(CONFIG.FALLBACK_SCRIPT_URL)
        end)
    end
    
    if not success or not scriptSource or #scriptSource < 10 then
        logConsole:Print("HttpRequest failed! Server rejection or offline.", "ERROR")
        error("HTTP GET Execution failed on both primary and fallback urls.")
    end
    
    logConsole:Print("Pre-compilation integrity verification passes.", "SUCCESS")
    logConsole:Print("Finalizing dynamic environment compilation...", "SYSTEM")
    
    local compiledFunc, compileError = loadstring(scriptSource)
    
    if not compiledFunc then
        logConsole:Print("Dynamic loadstring compiler failed! Source damaged.", "ERROR")
        error(compileError or "Loadstring returned nil compiling payload.")
    end
    
    local executionSuccess, runtimeError = xpcall(function()
        task.spawn(compiledFunc)
    end, function(err)
        local stackTrace = debug.traceback(err)
        return {
            Error = err,
            Trace = stackTrace
        }
    end)
    
    if not executionSuccess then
        local detailedErrorInfo = string.format(
            "HAKIRA RUNTIME CRASH REPORT\n" ..
            "===========================\n" ..
            "Developer ID: %s | Roblox ID: %s\n" ..
            "Target Script: %s\n" ..
            "System Error: %s\n" ..
            "Stack Trace:\n%s",
            CONFIG.DEVELOPER_NAME,
            CONFIG.ROBLOX_ACCOUNT,
            url,
            tostring(runtimeError.Error),
            tostring(runtimeError.Trace)
        )
        CopyToClipboard(detailedErrorInfo)
        logConsole:Print("CRITICAL ERROR ENCOUNTERED DURING SCRIPT LAUNCH!", "ERROR")
        logConsole:Print("Error details successfully copied to clipboard.", "SYSTEM")
        logConsole:Print("Stacktrace: " .. tostring(runtimeError.Error):sub(1, 35) .. "...", "ERROR")
        return false, runtimeError
    end
    
    logConsole:Print("Payload launched successfully in decoupled thread.", "SUCCESS")
    return true, nil
end

local function PlayIntroSequence(guiInstance)
    local introFrame = Instance.new("Frame")
    introFrame.Name = "IntroCanvas"
    introFrame.Size = UDim2.new(1, 0, 1, 0)
    introFrame.Position = UDim2.new(0, 0, 0, 0)
    introFrame.BackgroundColor3 = CONFIG.THEME.BACKGROUND_PRIMARY
    introFrame.BorderSizePixel = 0
    introFrame.ZIndex = 100
    introFrame.Parent = guiInstance
    
    local introText = Instance.new("TextLabel")
    introText.Name = "IntroText"
    introText.Size = UDim2.new(0.8, 0, 0.2, 0)
    introText.Position = UDim2.new(0.5, 0, 0.5, 0)
    introText.AnchorPoint = Vector2.new(0.5, 0.5)
    introText.BackgroundTransparency = 1
    introText.TextColor3 = CONFIG.THEME.TEXT_PRIMARY
    introText.Font = Enum.Font.GothamMedium
    introText.TextTransparency = 1
    introText.TextWrapped = true
    introText.Parent = introFrame
    MakeTextResponsive(introText, 14, 20)
    
    introText.Text = "welcome, selamat menikmati"
    GlobalAnimator:Create(introText, 0.6, Easing.OutQuad, {TextTransparency = 0})
    task.wait(1.8)
    GlobalAnimator:Create(introText, 0.5, Easing.OutQuad, {TextTransparency = 1})
    task.wait(0.6)
    
    introText.Text = "gunakan script secara bijak:3"
    GlobalAnimator:Create(introText, 0.6, Easing.OutQuad, {TextTransparency = 0})
    task.wait(1.8)
    GlobalAnimator:Create(introText, 0.5, Easing.OutQuad, {TextTransparency = 1})
    task.wait(0.6)
    
    GlobalAnimator:Create(introFrame, 0.6, Easing.OutQuad, {BackgroundTransparency = 1})
    task.wait(0.6)
    introFrame:Destroy()
end

local function InitializeLoader()
    local currentPlayerName = LocalPlayer.Name
    local lowcaseName = string.lower(currentPlayerName)
    
    -- 1. VERIFIKASI STATUS MAINTENANCE (KICK SEMUA PLAYER TERMASUK DEVELOPER)
    if CONFIG.MAINTENANCE.ENABLED then
        ForceKick(CONFIG.MAINTENANCE.REASON)
        return
    end
    
    -- 2. VERIFIKASI OTORISASI WHITELIST
    if not CONFIG.WHITELIST[lowcaseName] then
        local formattedKickMsg = string.format(CONFIG.SECURITY.KICK_MESSAGE, currentPlayerName)
        ForceKick(formattedKickMsg)
        return
    end
    
    -- JIKA LOLOS PENGECEKAN, INISIALISASI INTERFACE UTAMA
    local parentFolder = GetGuiParent()
    local guiInstance = UI.CreateBase(parentFolder)
    local mainFrame = UI.CreateMainFrame(guiInstance)
    UI.CreateDecorations(mainFrame)
    local closeButton = UI.CreateHeader(mainFrame)
    
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Visible = false
    
    local dragUtil = DragController.new(mainFrame)
    local tabContainer, loaderTab, diagnosticsTab, creditsTab = UI.CreateTabSelector(mainFrame)
    local loaderPage, diagnosticsPage, mainDiagLabel, creditsPage = UI.CreateSubPages(mainFrame)
    local footerFpsLabel = UI.CreateFooter(mainFrame)
    local diagnosticsTracker = SystemDiagnostics.new(mainDiagLabel)
    
    local infoArea = UI.CreateMainLoaderInfo(loaderPage)
    local fillProgress, percentText, taskText = UI.CreateProgressBar(loaderPage)
    local scrollingLogs = UI.CreateStatusConsole(loaderPage)
    local console = LogConsole.new(scrollingLogs)
    
    local particleCanvas = Instance.new("Frame")
    particleCanvas.Name = "ParticleCanvas"
    particleCanvas.Size = UDim2.new(1, 0, 1, 0)
    particleCanvas.BackgroundTransparency = 1
    particleCanvas.ZIndex = -1
    particleCanvas.Parent = mainFrame
    
    local particles = ParticleEngine.new(particleCanvas)
    
    local fpsUpdateConnection
    fpsUpdateConnection = RunService.RenderStepped:Connect(function()
        if diagnosticsTracker.Active then
            local currentPing = "N/A"
            pcall(function()
                currentPing = string.format("%.1f", Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            footerFpsLabel.Text = string.format("FPS: %.1f | MS: %s ms", diagnosticsTracker.Fps, currentPing)
            diagnosticsTracker:UpdateDisplay()
        else
            fpsUpdateConnection:Disconnect()
        end
    end)
    
    local function SafeCleanup()
        particles:Destroy()
        diagnosticsTracker:Destroy()
        mainFrame:Destroy()
        guiInstance:Destroy()
    end
    
    closeButton.MouseButton1Click:Connect(SafeCleanup)
    
    local function SwitchToTab(targetName)
        loaderTab.BackgroundColor3 = CONFIG.THEME.BACKGROUND_PRIMARY
        loaderTab.TextColor3 = CONFIG.THEME.TEXT_MUTED
        loaderTab.UIStroke.Color = CONFIG.THEME.BORDER_COLOR
        
        diagnosticsTab.BackgroundColor3 = CONFIG.THEME.BACKGROUND_PRIMARY
        diagnosticsTab.TextColor3 = CONFIG.THEME.TEXT_MUTED
        diagnosticsTab.UIStroke.Color = CONFIG.THEME.BORDER_COLOR
        
        creditsTab.BackgroundColor3 = CONFIG.THEME.BACKGROUND_PRIMARY
        creditsTab.TextColor3 = CONFIG.THEME.TEXT_MUTED
        creditsTab.UIStroke.Color = CONFIG.THEME.BORDER_COLOR
        
        local activePage = nil
        local targetPage = nil
        
        if loaderPage.Visible then activePage = loaderPage
        elseif diagnosticsPage.Visible then activePage = diagnosticsPage
        elseif creditsPage.Visible then activePage = creditsPage end
        
        if targetName == "Loader" then
            loaderTab.BackgroundColor3 = CONFIG.THEME.BACKGROUND_SECONDARY
            loaderTab.TextColor3 = CONFIG.THEME.TEXT_PRIMARY
            loaderTab.UIStroke.Color = CONFIG.THEME.BORDER_HIGHLIGHT
            targetPage = loaderPage
        elseif targetName == "Diagnostics" then
            diagnosticsTab.BackgroundColor3 = CONFIG.THEME.BACKGROUND_SECONDARY
            diagnosticsTab.TextColor3 = CONFIG.THEME.TEXT_PRIMARY
            diagnosticsTab.UIStroke.Color = CONFIG.THEME.BORDER_HIGHLIGHT
            targetPage = diagnosticsPage
        elseif targetName == "Credits" then
            creditsTab.BackgroundColor3 = CONFIG.THEME.BACKGROUND_SECONDARY
            creditsTab.TextColor3 = CONFIG.THEME.TEXT_PRIMARY
            creditsTab.UIStroke.Color = CONFIG.THEME.BORDER_HIGHLIGHT
            targetPage = creditsPage
        end
        
        if activePage and targetPage and activePage ~= targetPage then
            GlobalAnimator:Create(activePage, 0.2, Easing.OutQuad, {GroupTransparency = 1})
            task.wait(0.2)
            activePage.Visible = false
            
            targetPage.Visible = true
            targetPage.GroupTransparency = 1
            GlobalAnimator:Create(targetPage, 0.2, Easing.OutQuad, {GroupTransparency = 0})
        end
    end
    
    loaderTab.MouseButton1Click:Connect(function() SwitchToTab("Loader") end)
    diagnosticsTab.MouseButton1Click:Connect(function() SwitchToTab("Diagnostics") end)
    creditsTab.MouseButton1Click:Connect(function() SwitchToTab("Credits") end)
    
    PlayIntroSequence(guiInstance)
    
    mainFrame.Visible = true
    GlobalAnimator:Create(mainFrame, 0.6, Easing.OutBack, {Size = UDim2.new(0.8, 0, 0.75, 0)})
    task.wait(0.3)
    
    console:Print("Executing initialization handshakes...", "SYSTEM")
    console:Print("System Lead Developer: " .. CONFIG.DEVELOPER_NAME, "SYSTEM")
    console:Print("Verification with Roblox identity complete.", "SUCCESS")
    
    local chrono = SequenceSynchronizer.new(CONFIG.LOADING_DURATION)
    
    chrono:AddEvent(0.0, function()
        taskText.Text = "Verifying client platform compatibility..."
        console:Print("Executing compatibility system scan...", "SYSTEM")
        console:Print("Identified Engine Sandbox Environment: " .. Env.identifyexecutor(), "SYSTEM")
    end)
    
    chrono:AddEvent(0.15, function()
        taskText.Text = "Initializing secure runtime environment..."
        console:Print("Securing internal variables...", "SYSTEM")
    end)
    
    chrono:AddEvent(0.3, function()
        taskText.Text = "Building UI Virtual DOM elements..."
        console:Print("Constructing loader interfaces dynamically...", "SYSTEM")
    end)
    
    chrono:AddEvent(0.45, function()
        taskText.Text = "Configuring monochromatic graphic assets..."
        console:Print("Registering custom vector buffers...", "SYSTEM")
        console:Print("Subtle star particle generator verified active.", "SUCCESS")
    end)
    
    chrono:AddEvent(0.6, function()
        taskText.Text = "Querying secure remote repository source..."
        console:Print("Accessing GitHub remote repository API...", "SYSTEM")
    end)
    
    chrono:AddEvent(0.72, function()
        taskText.Text = "Fetching emote menu source packets..."
        console:Print("Transmitting secure HTTP handshake packet...", "SYSTEM")
    end)
    
    chrono:AddEvent(0.85, function()
        taskText.Text = "Parsing bytecode structures..."
        console:Print("Validating integrity checksum of loaded packets...", "SUCCESS")
    end)
    
    chrono:AddEvent(0.95, function()
        taskText.Text = "Handing process context to script compiler..."
        console:Print("Process handoff preparation complete.", "SUCCESS")
    end)
    
    chrono:Run(function(progress)
        fillProgress.Size = UDim2.new(progress, 0, 1, 0)
        percentText.Text = string.format("%d%%", math.floor(progress * 100))
    end)
    
    taskText.Text = "Executing compiled payload script..."
    console:Print("Launching main thread stream...", "SUCCESS")
    
    local executeSuccess, executeError = PayloadExecutionManager.ExecuteSecure(CONFIG.TARGET_SCRIPT_URL, console)
    
    if executeSuccess then
        taskText.Text = "Launch Complete! Disposing interface..."
        console:Print("All resources loaded successfully. Goodbye!", "SUCCESS")
        
        local fadeAnimation = GlobalAnimator:Create(mainFrame, 0.5, Easing.OutCubic, {
            Size = UDim2.new(0, 0, 0, 0)
        })
        
        task.wait(0.5)
        SafeCleanup()
    else
        taskText.Text = "Execution Interrupted! Log details saved."
        console:Print("CRASH LOCK SYSTEM IN ACTION.", "ERROR")
        console:Print("Check clipboard for the full error dump.", "SYSTEM")
    end
end

task.spawn(InitializeLoader)
