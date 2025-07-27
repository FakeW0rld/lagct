repeat
    task.wait()
until game:IsLoaded()
local library = {}
local ToggleUI = false
library.currentTab = nil
library.flags = {}
local services = setmetatable({}, {
    __index = function(t, k)
        return game.GetService(game, k)
    end,
})
local mouse = services.Players.LocalPlayer:GetMouse()

-- 背景图片ID（可替换为你的图片ID）
local BackgroundImageId = "rbxassetid://10828557174"  -- 示例：深蓝色渐变背景
local AccentImageId = "rbxassetid://10828558176"      -- 示例：按钮 accent 背景

function Tween(obj, t, data)
    services.TweenService
        :Create(obj, TweenInfo.new(t[1], Enum.EasingStyle[t[2]], Enum.EasingDirection[t[3]]), data)
        :Play()
    return true
end

function Ripple(obj)
    spawn(function()
        if obj.ClipsDescendants ~= true then
            obj.ClipsDescendants = true
        end
        local Ripple = Instance.new("ImageLabel")
        Ripple.Name = "Ripple"
        Ripple.Parent = obj
        Ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Ripple.BackgroundTransparency = 1.000
        Ripple.ZIndex = 8
        Ripple.Image = "rbxassetid://2708891598"
        Ripple.ImageTransparency = 0.800
        Ripple.ScaleType = Enum.ScaleType.Fit
        Ripple.ImageColor3 = Color3.fromRGB(255, 255, 255)
        Ripple.Position = UDim2.new(
            (mouse.X - Ripple.AbsolutePosition.X) / obj.AbsoluteSize.X,
            0,
            (mouse.Y - Ripple.AbsolutePosition.Y) / obj.AbsoluteSize.Y,
            0
        )
        Tween(
            Ripple,
            { 0.3, "Linear", "InOut" },
            { Position = UDim2.new(-5.5, 0, -5.5, 0), Size = UDim2.new(12, 0, 12, 0) }
        )
        wait(0.15)
        Tween(Ripple, { 0.3, "Linear", "InOut" }, { ImageTransparency = 1 })
        wait(0.3)
        Ripple:Destroy()
    end)
end

local toggled = false
local switchingTabs = false

function switchTab(new)
    if switchingTabs then
        return
    end
    local old = library.currentTab
    if old == nil then
        new[2].Visible = true
        library.currentTab = new
        services.TweenService:Create(new[1], TweenInfo.new(0.1), { ImageTransparency = 0 }):Play()
        services.TweenService:Create(new[1].TabText, TweenInfo.new(0.1), { TextTransparency = 0 }):Play()
        return
    end
    if old[1] == new[1] then
        return
    end
    switchingTabs = true
    library.currentTab = new
    services.TweenService:Create(old[1], TweenInfo.new(0.1), { ImageTransparency = 0.2 }):Play()
    services.TweenService:Create(new[1], TweenInfo.new(0.1), { ImageTransparency = 0 }):Play()
    services.TweenService:Create(old[1].TabText, TweenInfo.new(0.1), { TextTransparency = 0.2 }):Play()
    services.TweenService:Create(new[1].TabText, TweenInfo.new(0.1), { TextTransparency = 0 }):Play()
    old[2].Visible = false
    new[2].Visible = true
    task.wait(0.1)
    switchingTabs = false
end

function drag(frame, hold)
    if not hold then
        hold = frame
    end
    local dragging
    local dragInput
    local dragStart
    local startPos
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position =
            UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    hold.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    services.UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

function library.new(library, name, theme)
    for _, v in next, services.CoreGui:GetChildren() do
        if v.Name == "REN" then
            v:Destroy()
        end
    end
    
    -- 主题颜色（背景改为图片后，这些颜色主要用于边框/文本对比）
    if theme == "dark" then
        MainColor = Color3.fromRGB(28, 33, 55)
        zyColor = Color3.fromRGB(37, 43, 71)
        beijingColor = Color3.fromRGB(255, 247, 247)
    else
        MainColor = Color3.fromRGB(28, 33, 55)
        zyColor = Color3.fromRGB(37, 43, 71)
        beijingColor = Color3.fromRGB(255, 247, 247)
    end

    local dogent = Instance.new("ScreenGui")
    dogent.Name = "REN"
    if syn and syn.protect_gui then
        syn.protect_gui(dogent)
    end
    dogent.Parent = services.CoreGui

    -- 主窗口（使用图片背景）
    local Main = Instance.new("ImageLabel")  -- 改为ImageLabel以支持图片
    Main.Name = "Main"
    Main.Parent = dogent
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.Image = BackgroundImageId           -- 设置背景图片
    Main.ScaleType = Enum.ScaleType.Stretch  -- 拉伸填充
    Main.ImageTransparency = 0               -- 不透明
    Main.BorderColor3 = MainColor
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Size = UDim2.new(0, 572, 0, 353)
    Main.ZIndex = 1
    Main.Active = true
    Main.Draggable = true

    -- 主窗口圆角
    local UICornerMain = Instance.new("UICorner")
    UICornerMain.Parent = Main
    UICornerMain.CornerRadius = UDim.new(0, 3)

    -- 阴影效果
    local DropShadowHolder = Instance.new("Frame")
    DropShadowHolder.Name = "DropShadowHolder"
    DropShadowHolder.Parent = Main
    DropShadowHolder.BackgroundTransparency = 1.000
    DropShadowHolder.BorderSizePixel = 0
    DropShadowHolder.Size = UDim2.new(1, 0, 1, 0)
    DropShadowHolder.ZIndex = 0

    local DropShadow = Instance.new("ImageLabel")
    DropShadow.Name = "DropShadow"
    DropShadow.Parent = DropShadowHolder
    DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadow.BackgroundTransparency = 1.000
    DropShadow.BorderSizePixel = 0
    DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropShadow.Size = UDim2.new(1, 43, 1, 43)
    DropShadow.ZIndex = 0
    DropShadow.Image = "rbxassetid://6015897843"
    DropShadow.ImageColor3 = Color3.fromRGB(255, 255, 255)
    DropShadow.ImageTransparency = 0.500
    DropShadow.ScaleType = Enum.ScaleType.Slice
    DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)

    local UIGradient = Instance.new("UIGradient")
    UIGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.10, Color3.fromRGB(255, 127, 0)),
        ColorSequenceKeypoint.new(0.20, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.30, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.40, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.60, Color3.fromRGB(139, 0, 255)),
        ColorSequenceKeypoint.new(0.70, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.80, Color3.fromRGB(255, 127, 0)),
        ColorSequenceKeypoint.new(0.90, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 255, 0)),
    })
    UIGradient.Parent = DropShadow
    local TweenService = game:GetService("TweenService")
    local tweeninfo = TweenInfo.new(7, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1)
    local tween = TweenService:Create(UIGradient, tweeninfo, { Rotation = 360 })
    tween:Play()

    -- 窗口大小切换动画
    function toggleui()
        toggled = not toggled
        spawn(function()
            if toggled then
                wait(0.3)
            end
        end)
        Tween(Main, { 0.3, "Sine", "InOut" }, { Size = UDim2.new(0, 609, 0, (toggled and 505 or 0)) })
    end

    -- 标签内容区域
    local TabMain = Instance.new("Frame")
    TabMain.Name = "TabMain"
    TabMain.Parent = Main
    TabMain.BackgroundTransparency = 1.000  -- 透明，显示主窗口背景
    TabMain.Position = UDim2.new(0.217000037, 0, 0, 3)
    TabMain.Size = UDim2.new(0, 448, 0, 353)

    -- 分隔线
    local SB = Instance.new("Frame")
    SB.Name = "SB"
    SB.Parent = Main
    SB.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SB.BorderColor3 = MainColor
    SB.Size = UDim2.new(0, 8, 0, 353)
    local SBC = Instance.new("UICorner")
    SBC.CornerRadius = UDim.new(0, 6)
    SBC.Name = "SBC"
    SBC.Parent = SB

    -- 侧边栏（使用图片背景）
    local Side = Instance.new("ImageLabel")  -- 改为ImageLabel
    Side.Name = "Side"
    Side.Parent = SB
    Side.Image = AccentImageId              -- 侧边栏图片
    Side.ScaleType = Enum.ScaleType.Stretch
    Side.ImageTransparency = 0.2            -- 轻微透明
    Side.BorderSizePixel = 0
    Side.ClipsDescendants = true
    Side.Position = UDim2.new(1, 0, 0, 0)
    Side.Size = UDim2.new(0, 110, 0, 353)

    -- 侧边栏标题
    local ScriptTitle = Instance.new("TextLabel")
    ScriptTitle.Name = "ScriptTitle"
    ScriptTitle.Parent = Side
    ScriptTitle.BackgroundTransparency = 1.000
    ScriptTitle.Position = UDim2.new(0, 0, 0.00953488424, 0)
    ScriptTitle.Size = UDim2.new(0, 102, 0, 20)
    ScriptTitle.Font = Enum.Font.GothamSemibold
    ScriptTitle.Text = name
    ScriptTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    ScriptTitle.TextSize = 14.000
    ScriptTitle.TextScaled = true
    ScriptTitle.TextXAlignment = Enum.TextXAlignment.Left

    -- 标题渐变动画
    local UIGradientTitle = Instance.new("UIGradient")
    UIGradientTitle.Parent = ScriptTitle
    local function NPLHKB_fake_script()
        local button = ScriptTitle
        local gradient = button.UIGradient
        local ts = game:GetService("TweenService")
        local ti = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        local offset = { Offset = Vector2.new(1, 0) }
        local create = ts:Create(gradient, ti, offset)
        local startingPos = Vector2.new(-1, 0)
        local list = {}
        local s, kpt = ColorSequence.new, ColorSequenceKeypoint.new
        local counter = 0
        local status = "down"
        gradient.Offset = startingPos
        local function rainbowColors()
            local sat, val = 255, 255
            for i = 1, 10 do
                local hue = i * 17
                table.insert(list, Color3.fromHSV(hue / 255, sat / 255, val / 255))
            end
        end
        rainbowColors()
        gradient.Color = s({ kpt(0, list[#list]), kpt(0.5, list[#list - 1]), kpt(1, list[#list - 2]) })
        counter = #list
        local function animate()
            create:Play()
            create.Completed:Wait()
            gradient.Offset = startingPos
            gradient.Rotation = 180
            if counter == #list - 1 and status == "down" then
                gradient.Color = s({ kpt(0, gradient.Color.Keypoints[1].Value), kpt(0.5, list[#list]), kpt(1, list[1]) })
                counter = 1
                status = "up"
            elseif counter == #list and status == "down" then
                gradient.Color = s({ kpt(0, gradient.Color.Keypoints[1].Value), kpt(0.5, list[1]), kpt(1, list[2]) })
                counter = 2
                status = "up"
            elseif counter <= #list - 2 and status == "down" then
                gradient.Color = s({
                    kpt(0, gradient.Color.Keypoints[1].Value),
                    kpt(0.5, list[counter + 1]),
                    kpt(1, list[counter + 2]),
                })
                counter = counter + 2
                status = "up"
            end
            create:Play()
            create.Completed:Wait()
            gradient.Offset = startingPos
            gradient.Rotation = 0
            if counter == #list - 1 and status == "up" then
                gradient.Color = s({ kpt(0, list[1]), kpt(0.5, list[#list]), kpt(1, gradient.Color.Keypoints[3].Value) })
                counter = 1
                status = "down"
            elseif counter == #list and status == "up" then
                gradient.Color = s({ kpt(0, list[2]), kpt(0.5, list[1]), kpt(1, gradient.Color.Keypoints[3].Value) })
                counter = 2
                status = "down"
            elseif counter <= #list - 2 and status == "up" then
                gradient.Color = s({
                    kpt(0, list[counter + 2]),
                    kpt(0.5, list[counter + 1]),
                    kpt(1, gradient.Color.Keypoints[3].Value),
                })
                counter = counter + 2
                status = "down"
            end
            animate()
        end
        animate()
    end
    coroutine.wrap(NPLHKB_fake_script)()

    -- 侧边栏渐变（可选，可删除）
    local SideG = Instance.new("UIGradient")
    SideG.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0.00, zyColor), ColorSequenceKeypoint.new(1.00, zyColor) })
    SideG.Rotation = 90
    SideG.Name = "SideG"
    SideG.Parent = Side

    -- 标签按钮滚动区域
    local TabBtns = Instance.new("ScrollingFrame")
    TabBtns.Name = "TabBtns"
    TabBtns.Parent = Side
    TabBtns.Active = true
    TabBtns.BackgroundTransparency = 1.000  -- 透明，显示侧边栏背景
    TabBtns.BorderSizePixel = 0
    TabBtns.Position = UDim2.new(0, 0, 0.0973535776, 0)
    TabBtns.Size = UDim2.new(0, 110, 0, 318)
    TabBtns.CanvasSize = UDim2.new(0, 0, 1, 0)
    TabBtns.ScrollBarThickness = 0

    local TabBtnsL = Instance.new("UIListLayout")
    TabBtnsL.Name = "TabBtnsL"
    TabBtnsL.Parent = TabBtns
    TabBtnsL.SortOrder = Enum.SortOrder.LayoutOrder
    TabBtnsL.Padding = UDim.new(0, 12)
    TabBtnsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabBtns.CanvasSize = UDim2.new(0, 0, 0, TabBtnsL.AbsoluteContentSize.Y + 18)
    end)

    -- 侧边栏背景渐变（可选）
    local SBG = Instance.new("UIGradient")
    SBG.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0.00, zyColor), ColorSequenceKeypoint.new(1.00, zyColor) })
    SBG.Rotation = 90
    SBG.Name = "SBG"
    SBG.Parent = SB

    -- 显示/隐藏按钮（使用图片背景）
    local Open = Instance.new("ImageButton")  -- 改为ImageButton
    Open.Name = "Open"
    Open.Parent = dogent
    Open.Image = AccentImageId               -- 按钮图片
    Open.ScaleType = Enum.ScaleType.Stretch
    Open.ImageTransparency = 0.1             -- 轻微透明
    Open.Position = UDim2.new(0.00829315186, 0, 0.31107837, 0)
    Open.Size = UDim2.new(0, 61, 0, 32)
    Open.Font = Enum.Font.SourceSans
    Open.Text = "隐藏/打开"
    Open.TextColor3 = Color3.fromRGB(255, 255, 255)
    Open.TextSize = 14.000
    Open.Active = true
    Open.Draggable = true
    local UIG = Instance.new("UIGradient")
    UIG.Parent = Open
    Open.MouseButton1Click:Connect(function()
        Main.Visible = not Main.Visible
    end)

    -- 窗口拖动
    drag(Main)

    -- 主窗口显示/隐藏快捷键（LeftControl）
    services.UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.LeftControl then
            Main.Visible = not Main.Visible
        end
    end)

    -- 窗口对象
    local window = {}

    -- 创建标签
    function window.Tab(window, name, icon)
        local Tab = Instance.new("ScrollingFrame")
        Tab.Name = "Tab"
        Tab.Parent = TabMain
        Tab.Active = true
        Tab.BackgroundTransparency = 1.000  -- 透明，显示主窗口背景
        Tab.Size = UDim2.new(1, 0, 1, 0)
        Tab.ScrollBarThickness = 2
        Tab.Visible = false

        local TabL = Instance.new("UIListLayout")
        TabL.Name = "TabL"
        TabL.Parent = Tab
        TabL.SortOrder = Enum.SortOrder.LayoutOrder
        TabL.Padding = UDim.new(0, 4)
        TabL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Tab.CanvasSize = UDim2.new(0, 0, 0, TabL.AbsoluteContentSize.Y + 8)
        end)

        -- 标签按钮
        local TabIco = Instance.new("ImageLabel")
        TabIco.Name = "TabIco"
        TabIco.Parent = TabBtns
        TabIco.BackgroundTransparency = 1.000
        TabIco.BorderSizePixel = 0
        TabIco.Size = UDim2.new(0, 24, 0, 24)
        TabIco.Image = ("rbxassetid://%s"):format((icon or 4370341699))
        TabIco.ImageTransparency = 0.2

        local TabText = Instance.new("TextLabel")
        TabText.Name = "TabText"
        TabText.Parent = TabIco
        TabText.BackgroundTransparency = 1.000
        TabText.Position = UDim2.new(1.41666663, 0, 0, 0)
        TabText.Size = UDim2.new(0, 76, 0, 24)
        TabText.Font = Enum.Font.GothamSemibold
        TabText.Text = name
        TabText.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabText.TextSize = 14.000
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        TabText.TextTransparency = 0.2

        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = "TabBtn"
        TabBtn.Parent = TabIco
        TabBtn.BackgroundTransparency = 1.000
        TabBtn.BorderSizePixel = 0
        TabBtn.Size = UDim2.new(0, 110, 0, 24)
        TabBtn.AutoButtonColor = false
        TabBtn.Text = ""
        TabBtn.MouseButton1Click:Connect(function()
            spawn(function()
                Ripple(TabBtn)
            end)
            switchTab({ TabIco, Tab })
        end)

        -- 默认选中第一个标签
        if library.currentTab == nil then
            switchTab({ TabIco, Tab })
        end

        -- 标签内容
        local tab = {}

        -- 创建区域
        function tab.section(tab, name, TabVal)
            local Section = Instance.new("Frame")
            Section.Name = "Section"
            Section.Parent = Tab
            Section.BackgroundColor3 = zyColor
            Section.BackgroundTransparency = 0.5  -- 半透明，显示背景图片
            Section.BorderSizePixel = 0
            Section.ClipsDescendants = true
            Section.Size = UDim2.new(0.981000006, 0, 0, 36)

            local SectionC = Instance.new("UICorner")
            SectionC.CornerRadius = UDim.new(0, 6)
            SectionC.Name = "SectionC"
            SectionC.Parent = Section

            local SectionText = Instance.new("TextLabel")
            SectionText.Name = "SectionText"
            SectionText.Parent = Section
            SectionText.BackgroundTransparency = 1.000
            SectionText.Position = UDim2.new(0.0887396261, 0, 0, 0)
            SectionText.Size = UDim2.new(0, 401, 0, 36)
            SectionText.Font = Enum.Font.GothamSemibold
            SectionText.Text = name
            SectionText.TextColor3 = Color3.fromRGB(255, 255, 255)
            SectionText.TextSize = 16.000
            SectionText.TextXAlignment = Enum.TextXAlignment.Left

            local SectionOpen = Instance.new("ImageLabel")
            SectionOpen.Name = "SectionOpen"
            SectionOpen.Parent = SectionText
            SectionOpen.BackgroundTransparency = 1
            SectionOpen.BorderSizePixel = 0
            SectionOpen.Position = UDim2.new(0, -33, 0, 5)
            SectionOpen.Size = UDim2.new(0, 26, 0, 26)
            SectionOpen.Image = "http://www.roblox.com/asset/?id=6031302934"

            local SectionOpened = Instance.new("ImageLabel")
            SectionOpened.Name = "SectionOpened"
            SectionOpened.Parent = SectionOpen
            SectionOpened.BackgroundTransparency = 1.000
            SectionOpened.BorderSizePixel = 0
            SectionOpened.Size = UDim2.new(0, 26, 0, 26)
            SectionOpened.Image = "http://www.roblox.com/asset/?id=6031302932"
            SectionOpened.ImageTransparency = 1.000

            local SectionToggle = Instance.new("ImageButton")
            SectionToggle.Name = "SectionToggle"
            SectionToggle.Parent = SectionOpen
            SectionToggle.BackgroundTransparency = 1
            SectionToggle.BorderSizePixel = 0
            SectionToggle.Size = UDim2.new(0, 26, 0, 26)

            local Objs = Instance.new("Frame")
            Objs.Name = "Objs"
            Objs.Parent = Section
            Objs.BackgroundTransparency = 1
            Objs.BorderSizePixel = 0
            Objs.Position = UDim2.new(0, 6, 0, 36)
            Objs.Size = UDim2.new(0.986347735, 0, 0, 0)

            local ObjsL = Instance.new("UIListLayout")
            ObjsL.Name = "ObjsL"
            ObjsL.Parent = Objs
            ObjsL.SortOrder = Enum.SortOrder.LayoutOrder
            ObjsL.Padding = UDim.new(0, 8)
            ObjsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if not open then
                    return
                end
                Section.Size = UDim2.new(0.981000006, 0, 0, 36 + ObjsL.AbsoluteContentSize.Y + 8)
            end)

            local open = TabVal
            if TabVal ~= false then
                Section.Size = UDim2.new(0.981000006, 0, 0, open and 36 + ObjsL.AbsoluteContentSize.Y + 8 or 36)
                SectionOpened.ImageTransparency = (open and 0 or 1)
                SectionOpen.ImageTransparency = (open and 1 or 0)
            end

            SectionToggle.MouseButton1Click:Connect(function()
                open = not open
                Section.Size = UDim2.new(0.981000006, 0, 0, open and 36 + ObjsL.AbsoluteContentSize.Y + 8 or 36)
                SectionOpened.ImageTransparency = (open and 0 or 1)
                SectionOpen.ImageTransparency = (open and 1 or 0)
            end)

            -- 区域对象
            local section = {}

            -- 按钮
            function section.Button(section, text, callback)
                local callback = callback or function() end
                local BtnModule = Instance.new("Frame")
                BtnModule.Name = "BtnModule"
                BtnModule.Parent = Objs
                BtnModule.BackgroundTransparency = 1.000
                BtnModule.BorderSizePixel = 0
                BtnModule.Size = UDim2.new(0, 428, 0, 38)

                local Btn = Instance.new("ImageButton")  -- 图片按钮
                Btn.Name = "Btn"
                Btn.Parent = BtnModule
                Btn.Image = AccentImageId                -- 按钮图片
                Btn.ScaleType = Enum.ScaleType.Stretch
                Btn.ImageTransparency = 0.3              -- 半透明
                Btn.BorderSizePixel = 0
                Btn.Size = UDim2.new(0, 428, 0, 38)
                Btn.AutoButtonColor = false
                Btn.Font = Enum.Font.GothamSemibold
                Btn.Text = "   " .. text
                Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                Btn.TextSize = 16.000
                Btn.TextXAlignment = Enum.TextXAlignment.Left

                local BtnC = Instance.new("UICorner")
                BtnC.CornerRadius = UDim.new(0, 6)
                BtnC.Parent = Btn

                Btn.MouseButton1Click:Connect(function()
                    spawn(function()
                        Ripple(Btn)
                    end)
                    spawn(callback)
                end)
            end

            -- 标签
            function section:Label(text)
                local LabelModule = Instance.new("Frame")
                LabelModule.Name = "LabelModule"
                LabelModule.Parent = Objs
                LabelModule.BackgroundTransparency = 1.000
                LabelModule.BorderSizePixel = 0
                LabelModule.Size = UDim2.new(0, 428, 0, 19)

                local TextLabel = Instance.new("TextLabel")
                TextLabel.Parent = LabelModule
                TextLabel.BackgroundColor3 = zyColor
                TextLabel.BackgroundTransparency = 0.5  -- 半透明
                TextLabel.Size = UDim2.new(0, 428, 0, 22)
                TextLabel.Font = Enum.Font.GothamSemibold
                TextLabel.Text = text
                TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                TextLabel.TextSize = 14.000

                local LabelC = Instance.new("UICorner")
                LabelC.CornerRadius = UDim.new(0, 6)
                LabelC.Parent = TextLabel

                return TextLabel
            end

            -- 开关
            function section.Toggle(section, text, flag, enabled, callback)
                local callback = callback or function() end
                local enabled = enabled or false
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                library.flags[flag] = enabled

                local ToggleModule = Instance.new("Frame")
                ToggleModule.Name = "ToggleModule"
                ToggleModule.Parent = Objs
                ToggleModule.BackgroundTransparency = 1.000
                ToggleModule.BorderSizePixel = 0
                ToggleModule.Size = UDim2.new(0, 428, 0, 38)

                local ToggleBtn = Instance.new("ImageButton")  -- 图片按钮
                ToggleBtn.Name = "ToggleBtn"
                ToggleBtn.Parent = ToggleModule
                ToggleBtn.Image = AccentImageId                -- 按钮图片
                ToggleBtn.ScaleType = Enum.ScaleType.Stretch
                ToggleBtn.ImageTransparency = 0.3              -- 半透明
                ToggleBtn.BorderSizePixel = 0
                ToggleBtn.Size = UDim2.new(0, 428, 0, 38)
                ToggleBtn.AutoButtonColor = false
                ToggleBtn.Font = Enum.Font.GothamSemibold
                ToggleBtn.Text = "   " .. text
                ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                ToggleBtn.TextSize = 16.000
                ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left

                local ToggleBtnC = Instance.new("UICorner")
                ToggleBtnC.CornerRadius = UDim.new(0, 6)
                ToggleBtnC.Parent = ToggleBtn

                local ToggleDisable = Instance.new("Frame")
                ToggleDisable.Name = "ToggleDisable"
                ToggleDisable.Parent = ToggleBtn
                ToggleDisable.BackgroundColor3 = Background
                ToggleDisable.BorderSizePixel = 0
                ToggleDisable.Position = UDim2.new(0.901869178, 0, 0.208881587, 0)
                ToggleDisable.Size = UDim2.new(0, 36, 0, 22)

                local ToggleSwitch = Instance.new("Frame")
                ToggleSwitch.Name = "ToggleSwitch"
                ToggleSwitch.Parent = ToggleDisable
                ToggleSwitch.BackgroundColor3 = beijingColor
                ToggleSwitch.Size = UDim2.new(0, 24, 0, 22)

                local ToggleSwitchC = Instance.new("UICorner")
                ToggleSwitchC.CornerRadius = UDim.new(0, 6)
                ToggleSwitchC.Parent = ToggleSwitch

                local ToggleDisableC = Instance.new("UICorner")
                ToggleDisableC.CornerRadius = UDim.new(0, 6)
                ToggleDisableC.Parent = ToggleDisable

                local funcs = {
                    SetState = function(self, state)
                        if state == nil then
                            state = not library.flags[flag]
                        end
                        if library.flags[flag] == state then
                            return
                        end
                        services.TweenService
                            :Create(
                                ToggleSwitch,
                                TweenInfo.new(0.2),
                                {
                                    Position = UDim2.new(0, (state and ToggleSwitch.Size.X.Offset / 2 or 0), 0, 0),
                                    BackgroundColor3 = (state and Color3.fromRGB(255, 255, 255) or beijingColor),
                                }
                            )
                            :Play()
                        library.flags[flag] = state
                        callback(state)
                    end,
                    Module = ToggleModule,
                }

                if enabled ~= false then
                    funcs:SetState(flag, true)
                end

                ToggleBtn.MouseButton1Click:Connect(function()
                    funcs:SetState()
                end)

                return funcs
            end

            -- 按键绑定
            function section.Keybind(section, text, default, callback)
                local callback = callback or function() end
                assert(text, "No text provided")
                assert(default, "No default key provided")
                local default = (typeof(default) == "string" and Enum.KeyCode[default] or default)
                local banned = {
                    Return = true,
                    Space = true,
                    Tab = true,
                    Backquote = true,
                    CapsLock = true,
                    Escape = true,
                    Unknown = true,
                }
                local shortNames = {
                    RightControl = "Right Ctrl",
                    LeftControl = "Left Ctrl",
                    LeftShift = "Left Shift",
                    RightShift = "Right Shift",
                    Semicolon = ";",
                    Quote = '"',
                    LeftBracket = "[",
                    RightBracket = "]",
                    Equals = "=",
                    Minus = "-",
                    RightAlt = "Right Alt",
                    LeftAlt = "Left Alt",
                }
                local bindKey = default
                local keyTxt = (default and (shortNames[default.Name] or default.Name) or "None")

                local KeybindModule = Instance.new("Frame")
                KeybindModule.Name = "KeybindModule"
                KeybindModule.Parent = Objs
                KeybindModule.BackgroundTransparency = 1.000
                KeybindModule.BorderSizePixel = 0
                KeybindModule.Size = UDim2.new(0, 428, 0, 38)

                local KeybindBtn = Instance.new("ImageButton")  -- 图片按钮
                KeybindBtn.Name = "KeybindBtn"
                KeybindBtn.Parent = KeybindModule
                KeybindBtn.Image = AccentImageId                -- 按钮图片
                KeybindBtn.ScaleType = Enum.ScaleType.Stretch
                KeybindBtn.ImageTransparency = 0.3              -- 半透明
                KeybindBtn.BorderSizePixel = 0
                KeybindBtn.Size = UDim2.new(0, 428, 0, 38)
                KeybindBtn.AutoButtonColor = false
                KeybindBtn.Font = Enum.Font.GothamSemibold
                KeybindBtn.Text = "   " .. text
                KeybindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                KeybindBtn.TextSize = 16.000
                KeybindBtn.TextXAlignment = Enum.TextXAlignment.Left

                local KeybindBtnC = Instance.new("UICorner")
                KeybindBtnC.CornerRadius = UDim.new(0, 6)
                KeybindBtnC.Parent = KeybindBtn

                local KeybindValue = Instance.new("TextButton")
                KeybindValue.Name = "KeybindValue"
                KeybindValue.Parent = KeybindBtn
                KeybindValue.BackgroundColor3 = Background
                KeybindValue.BorderSizePixel = 0
                KeybindValue.Position = UDim2.new(0.763033211, 0, 0.289473683, 0)
                KeybindValue.Size = UDim2.new(0, 100, 0, 28)
                KeybindValue.AutoButtonColor = false
                KeybindValue.Font = Enum.Font.Gotham
                KeybindValue.Text = keyTxt
                KeybindValue.TextColor3 = Color3.fromRGB(255, 255, 255)
                KeybindValue.TextSize = 14.000

                local KeybindValueC = Instance.new("UICorner")
                KeybindValueC.CornerRadius = UDim.new(0, 6)
                KeybindValueC.Parent = KeybindValue

                local KeybindL = Instance.new("UIListLayout")
                KeybindL.Name = "KeybindL"
                KeybindL.Parent = KeybindBtn
                KeybindL.HorizontalAlignment = Enum.HorizontalAlignment.Right
                KeybindL.SortOrder = Enum.SortOrder.LayoutOrder
                KeybindL.VerticalAlignment = Enum.VerticalAlignment.Center

                local UIPadding = Instance.new("UIPadding")
                UIPadding.Parent = KeybindBtn
                UIPadding.PaddingRight = UDim.new(0, 6)

                services.UserInputService.InputBegan:Connect(function(inp, gpe)
                    if gpe then
                        return
                    end
                    if inp.UserInputType ~= Enum.UserInputType.Keyboard then
                        return
                    end
                    if inp.KeyCode ~= bindKey then
                        return
                    end
                    callback(bindKey.Name)
                end)

                KeybindValue.MouseButton1Click:Connect(function()
                    KeybindValue.Text = "..."
                    wait()
                    local key, uwu = services.UserInputService.InputEnded:Wait()
                    local keyName = tostring(key.KeyCode.Name)
                    if key.UserInputType ~= Enum.UserInputType.Keyboard then
                        KeybindValue.Text = keyTxt
                        return
                    end
                    if banned[keyName] then
                        KeybindValue.Text = keyTxt
                        return
                    end
                    wait()
                    bindKey = Enum.KeyCode[keyName]
                    KeybindValue.Text = shortNames[keyName] or keyName
                end)

                KeybindValue:GetPropertyChangedSignal("TextBounds"):Connect(function()
                    KeybindValue.Size = UDim2.new(0, KeybindValue.TextBounds.X + 30, 0, 28)
                end)
                KeybindValue.Size = UDim2.new(0, KeybindValue.TextBounds.X + 30, 0, 28)
            end

            -- 文本框
            function section.Textbox(section, text, flag, default, callback)
                local callback = callback or function() end
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                assert(default, "No default text provided")
                library.flags[flag] = default

                local TextboxModule = Instance.new("Frame")
                TextboxModule.Name = "TextboxModule"
                TextboxModule.Parent = Objs
                TextboxModule.BackgroundTransparency = 1.000
                TextboxModule.BorderSizePixel = 0
                TextboxModule.Size = UDim2.new(0, 428, 0, 38)

                local TextboxBack = Instance.new("ImageButton")  -- 图片按钮
                TextboxBack.Name = "TextboxBack"
                TextboxBack.Parent = TextboxModule
                TextboxBack.Image = AccentImageId                -- 按钮图片
                TextboxBack.ScaleType = Enum.ScaleType.Stretch
                TextboxBack.ImageTransparency = 0.3              -- 半透明
                TextboxBack.BorderSizePixel = 0
                TextboxBack.Size = UDim2.new(0, 428, 0, 38)
                TextboxBack.AutoButtonColor = false
                TextboxBack.Font = Enum.Font.GothamSemibold
                TextboxBack.Text = "   " .. text
                TextboxBack.TextColor3 = Color3.fromRGB(255, 255, 255)
                TextboxBack.TextSize = 16.000
                TextboxBack.TextXAlignment = Enum.TextXAlignment.Left

                local TextboxBackC = Instance.new("UICorner")
                TextboxBackC.CornerRadius = UDim.new(0, 6)
                TextboxBackC.Parent = TextboxBack

                local BoxBG = Instance.new("TextButton")
                BoxBG.Name = "BoxBG"
                BoxBG.Parent = TextboxBack
                BoxBG.BackgroundColor3 = Background
                BoxBG.BorderSizePixel = 0
                BoxBG.Position = UDim2.new(0.763033211, 0, 0.289473683, 0)
                BoxBG.Size = UDim2.new(0, 100, 0, 28)
                BoxBG.AutoButtonColor = false
                BoxBG.Font = Enum.Font.Gotham
                BoxBG.Text = ""
                BoxBG.TextColor3 = Color3.fromRGB(255, 255, 255)
                BoxBG.TextSize = 14.000

                local BoxBGC = Instance.new("UICorner")
                BoxBGC.CornerRadius = UDim.new(0, 6)
                BoxBGC.Parent = BoxBG

                local TextBox = Instance.new("TextBox")
                TextBox.Parent = BoxBG
                TextBox.BackgroundTransparency = 1.000
                TextBox.BorderSizePixel = 0
                TextBox.Size = UDim2.new(1, 0, 1, 0)
                TextBox.Font = Enum.Font.Gotham
                TextBox.Text = default
                TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                TextBox.TextSize = 14.000

                local TextboxBackL = Instance.new("UIListLayout")
                TextboxBackL.Name = "TextboxBackL"
                TextboxBackL.Parent = TextboxBack
                TextboxBackL.HorizontalAlignment = Enum.HorizontalAlignment.Right
                TextboxBackL.SortOrder = Enum.SortOrder.LayoutOrder
                TextboxBackL.VerticalAlignment = Enum.VerticalAlignment.Center

                local TextboxBackP = Instance.new("UIPadding")
                TextboxBackP.Name = "TextboxBackP"
                TextboxBackP.Parent = TextboxBack
                TextboxBackP.PaddingRight = UDim.new(0, 6)

                TextBox.FocusLost:Connect(function()
                    if TextBox.Text == "" then
                        TextBox.Text = default
                    end
                    library.flags[flag] = TextBox.Text
                    callback(TextBox.Text)
                end)

                TextBox:GetPropertyChangedSignal("TextBounds"):Connect(function()
                    BoxBG.Size = UDim2.new(0, TextBox.TextBounds.X + 30, 0, 28)
                end)
                BoxBG.Size = UDim2.new(0, TextBox.TextBounds.X + 30, 0, 28)
            end

            -- 滑块
            function section.Slider(section, text, flag, default, min, max, precise, callback)
                local callback = callback or function() end
                local min = min or 1
                local max = max or 10
                local default = default or min
                local precise = precise or false
                library.flags[flag] = default

                local SliderModule = Instance.new("Frame")
                SliderModule.Name = "SliderModule"
                SliderModule.Parent = Objs
                SliderModule.BackgroundTransparency = 1.000
                SliderModule.BorderSizePixel = 0
                SliderModule.Size = UDim2.new(0, 428, 0, 38)

                local SliderBack = Instance.new("ImageButton")  -- 图片按钮
                SliderBack.Name = "SliderBack"
                SliderBack.Parent = SliderModule
                SliderBack.Image = AccentImageId                -- 按钮图片
                SliderBack.ScaleType = Enum.ScaleType.Stretch
                SliderBack.ImageTransparency = 0.3              -- 半透明
                SliderBack.BorderSizePixel = 0
                SliderBack.Size = UDim2.new(0, 428, 0, 38)
                SliderBack.AutoButtonColor = false
                SliderBack.Font = Enum.Font.GothamSemibold
                SliderBack.Text = "   " .. text
                SliderBack.TextColor3 = Color3.fromRGB(255, 255, 255)
                SliderBack.TextSize = 16.000
                SliderBack.TextXAlignment = Enum.TextXAlignment.Left

                local SliderBackC = Instance.new("UICorner")
                SliderBackC.CornerRadius = UDim.new(0, 6)
                SliderBackC.Parent = SliderBack

                local SliderBar = Instance.new("Frame")
                SliderBar.Name = "SliderBar"
                SliderBar.Parent = SliderBack
                SliderBar.AnchorPoint = Vector2.new(0, 0.5)
                SliderBar.BackgroundColor3 = Background
                SliderBar.BorderSizePixel = 0
                SliderBar.Position = UDim2.new(0.369000018, 40, 0.5, 0)
                SliderBar.Size = UDim2.new(0, 140, 0, 12)

                local SliderBarC = Instance.new("UICorner")
                SliderBarC.CornerRadius = UDim.new(0, 4)
                SliderBarC.Parent = SliderBar

                local SliderPart = Instance.new("Frame")
                SliderPart.Name = "SliderPart"
                SliderPart.Parent = SliderBar
                SliderPart.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SliderPart.BorderSizePixel = 0
                SliderPart.Size = UDim2.new(0, 54, 0, 13)

                local SliderPartC = Instance.new("UICorner")
                SliderPartC.CornerRadius = UDim.new(0, 4)
                SliderPartC.Parent = SliderPart

                local SliderValBG = Instance.new("TextButton")
                SliderValBG.Name = "SliderValBG"
                SliderValBG.Parent = SliderBack
                SliderValBG.BackgroundColor3 = Background
                SliderValBG.BorderSizePixel = 0
                SliderValBG.Position = UDim2.new(0.883177578, 0, 0.131578952, 0)
                SliderValBG.Size = UDim2.new(0, 44, 0, 28)
                SliderValBG.AutoButtonColor = false
                SliderValBG.Font = Enum.Font.Gotham
                SliderValBG.Text = ""
                SliderValBG.TextColor3 = Color3.fromRGB(255, 255, 255)
                SliderValBG.TextSize = 14.000

                local SliderValBGC = Instance.new("UICorner")
                SliderValBGC.CornerRadius = UDim.new(0, 6)
                SliderValBGC.Parent = SliderValBG

                local SliderValue = Instance.new("TextBox")
                SliderValue.Name = "SliderValue"
                SliderValue.Parent = SliderValBG
                SliderValue.BackgroundTransparency = 1.000
                SliderValue.BorderSizePixel = 0
                SliderValue.Size = UDim2.new(1, 0, 1, 0)
                SliderValue.Font = Enum.Font.Gotham
                SliderValue.Text = "1000"
                SliderValue.TextColor3 = Color3.fromRGB(255, 255, 255)
                SliderValue.TextSize = 14.000

                local MinSlider = Instance.new("TextButton")
                MinSlider.Name = "MinSlider"
                MinSlider.Parent = SliderModule
                MinSlider.BackgroundTransparency = 1.000
                MinSlider.BorderSizePixel = 0
                MinSlider.Position = UDim2.new(0.296728969, 40, 0.236842096, 0)
                MinSlider.Size = UDim2.new(0, 20, 0, 20)
                MinSlider.Font = Enum.Font.Gotham
                MinSlider.Text = "-"
                MinSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
                MinSlider.TextSize = 24.000
                MinSlider.TextWrapped = true

                local AddSlider = Instance.new("TextButton")
                AddSlider.Name = "AddSlider"
                AddSlider.Parent = SliderModule
                AddSlider.AnchorPoint = Vector2.new(0, 0.5)
                AddSlider.BackgroundTransparency = 1.000
                AddSlider.BorderSizePixel = 0
                AddSlider.Position = UDim2.new(0.810906529, 0, 0.5, 0)
                AddSlider.Size = UDim2.new(0, 20, 0, 20)
                AddSlider.Font = Enum.Font.Gotham
                AddSlider.Text = "+"
                AddSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
                AddSlider.TextSize = 24.000
                AddSlider.TextWrapped = true

                local funcs = {
                    SetValue = function(self, value)
                        local percent = (mouse.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X
                        if value then
                            percent = (value - min) / (max - min)
                        end
                        percent = math.clamp(percent, 0, 1)
                        if precise then
                            value = value or tonumber(string.format("%.1f", tostring(min + (max - min) * percent)))
                        else
                            value = value or math.floor(min + (max - min) * percent)
                        end
                        library.flags[flag] = tonumber(value)
                        SliderValue.Text = tostring(value)
                        SliderPart.Size = UDim2.new(percent, 0, 1, 0)
                        callback(tonumber(value))
                    end,
                }

                MinSlider.MouseButton1Click:Connect(function()
                    local currentValue = library.flags[flag]
                    currentValue = math.clamp(currentValue - 1, min, max)
                    funcs:SetValue(currentValue)
                end)

                AddSlider.MouseButton1Click:Connect(function()
                    local currentValue = library.flags[flag]
                    currentValue = math.clamp(currentValue + 1, min, max)
                    funcs:SetValue(currentValue)
                end)

                funcs:SetValue(default)

                local dragging, boxFocused, allowed = false, false, { [""] = true, ["-"] = true }
                SliderBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        funcs:SetValue()
                        dragging = true
                    end
                end)

                services.UserInputService.InputEnded:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)

                services.UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        funcs:SetValue()
                    end
                end)

                SliderBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch then
                        funcs:SetValue()
                        dragging = true
                    end
                end)

                services.UserInputService.InputEnded:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                services.UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.Touch then
                        funcs:SetValue()
                    end
                end)

                SliderValue.Focused:Connect(function()
                    boxFocused = true
                end)

                SliderValue.FocusLost:Connect(function()
                    boxFocused = false
                    if SliderValue.Text == "" then
                        funcs:SetValue(default)
                    end
                end)

                SliderValue:GetPropertyChangedSignal("Text"):Connect(function()
                    if not boxFocused then
                        return
                    end
                    SliderValue.Text = SliderValue.Text:gsub("%D+", "")
                    local text = SliderValue.Text
                    if not tonumber(text) then
                        SliderValue.Text = SliderValue.Text:gsub("%D+", "")
                    elseif not allowed[text] then
                        if tonumber(text) > max then
                            text = max
                            SliderValue.Text = tostring(max)
                        end
                        funcs:SetValue(tonumber(text))
                    end
                end)

                return funcs
            end

            -- 下拉菜单
            function section.Dropdown(section, text, flag, options, callback)
                local callback = callback or function() end
                local options = options or {}
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                library.flags[flag] = nil

                local DropdownModule = Instance.new("Frame")
                DropdownModule.Name = "DropdownModule"
                DropdownModule.Parent = Objs
                DropdownModule.BackgroundTransparency = 1.000
                DropdownModule.BorderSizePixel = 0
                DropdownModule.ClipsDescendants = true
                DropdownModule.Size = UDim2.new(0, 428, 0, 38)

                local DropdownTop = Instance.new("ImageButton")  -- 图片按钮
                DropdownTop.Name = "DropdownTop"
                DropdownTop.Parent = DropdownModule
                DropdownTop.Image = AccentImageId                -- 按钮图片
                DropdownTop.ScaleType = Enum.ScaleType.Stretch
                DropdownTop.ImageTransparency = 0.3              -- 半透明
                DropdownTop.BorderSizePixel = 0
                DropdownTop.Size = UDim2.new(0, 428, 0, 38)
                DropdownTop.AutoButtonColor = false
                DropdownTop.Font = Enum.Font.GothamSemibold
                DropdownTop.Text = ""
                DropdownTop.TextColor3 = Color3.fromRGB(255, 255, 255)
                DropdownTop.TextSize = 16.000
                DropdownTop.TextXAlignment = Enum.TextXAlignment.Left

                local DropdownTopC = Instance.new("UICorner")
                DropdownTopC.CornerRadius = UDim.new(0, 6)
                DropdownTopC.Parent = DropdownTop

                local DropdownOpen = Instance.new("TextButton")
                DropdownOpen.Name = "DropdownOpen"
                DropdownOpen.Parent = DropdownTop
                DropdownOpen.AnchorPoint = Vector2.new(0, 0.5)
                DropdownOpen.BackgroundTransparency = 1.000
                DropdownOpen.BorderSizePixel = 0
                DropdownOpen.Position = UDim2.new(0.918383181, 0, 0.5, 0)
                DropdownOpen.Size = UDim2.new(0, 20, 0, 20)
                DropdownOpen.Font = Enum.Font.Gotham
                DropdownOpen.Text = "+"
                DropdownOpen.TextColor3 = Color3.fromRGB(255, 255, 255)
                DropdownOpen.TextSize = 24.000
                DropdownOpen.TextWrapped = true

                local DropdownText = Instance.new("TextBox")
                DropdownText.Name = "DropdownText"
                DropdownText.Parent = DropdownTop
                DropdownText.BackgroundTransparency = 1.000
                DropdownText.BorderSizePixel = 0
                DropdownText.Position = UDim2.new(0.0373831764, 0, 0, 0)
                DropdownText.Size = UDim2.new(0, 184, 0, 38)
                DropdownText.Font = Enum.Font.GothamSemibold
                DropdownText.PlaceholderColor3 = Color3.fromRGB(255, 255, 255)
                DropdownText.PlaceholderText = text
                DropdownText.Text = ""
                DropdownText.TextColor3 = Color3.fromRGB(255, 255, 255)
                DropdownText.TextSize = 16.000
                DropdownText.TextXAlignment = Enum.TextXAlignment.Left

                local DropdownModuleL = Instance.new("UIListLayout")
                DropdownModuleL.Name = "DropdownModuleL"
                DropdownModuleL.Parent = DropdownModule
                DropdownModuleL.SortOrder = Enum.SortOrder.LayoutOrder
                DropdownModuleL.Padding = UDim.new(0, 4)
                DropdownModuleL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    if not open then
                        return
                    end
                    DropdownModule.Size = UDim2.new(0, 428, 0, (DropdownModuleL.AbsoluteContentSize.Y + 4))
                end)

                local setAllVisible = function()
                    local options = DropdownModule:GetChildren()
                    for i = 1, #options do
                        local option = options[i]
                        if option:IsA("TextButton") and option.Name:match("Option_") then
                            option.Visible = true
                        end
                    end
                end

                local searchDropdown = function(text)
                    local options = DropdownModule:GetChildren()
                    for i = 1, #options do
                        local option = options[i]
                        if text == "" then
                            setAllVisible()
                        else
                            if option:IsA("TextButton") and option.Name:match("Option_") then
                                if option.Text:lower():match(text:lower()) then
                                    option.Visible = true
                                else
                                    option.Visible = false
                                end
                            end
                        end
                    end
                end

                local open = false
                local ToggleDropVis = function()
                    open = not open
                    if open then
                        setAllVisible()
                    end
                    DropdownOpen.Text = (open and "-" or "+")
                    DropdownModule.Size = UDim2.new(0, 428, 0, (open and DropdownModuleL.AbsoluteContentSize.Y + 4 or 38))
                end

                DropdownOpen.MouseButton1Click:Connect(ToggleDropVis)

                DropdownText.Focused:Connect(function()
                    if open then
                        return
                    end
                    ToggleDropVis()
                end)

                DropdownText:GetPropertyChangedSignal("Text"):Connect(function()
                    if not open then
                        return
                    end
                    searchDropdown(DropdownText.Text)
                end)

                local funcs = {}
                funcs.AddOption = function(self, option)
                    local Option = Instance.new("ImageButton")  -- 图片按钮
                    Option.Name = "Option_" .. option
                    Option.Parent = DropdownModule
                    Option.Image = AccentImageId                -- 选项图片
                    Option.ScaleType = Enum.ScaleType.Stretch
                    Option.ImageTransparency = 0.3              -- 半透明
                    Option.BorderSizePixel = 0
                    Option.Size = UDim2.new(0, 428, 0, 26)
                    Option.AutoButtonColor = false
                    Option.Font = Enum.Font.Gotham
                    Option.Text = option
                    Option.TextColor3 = Color3.fromRGB(255, 255, 255)
                    Option.TextSize = 14.000

                    local OptionC = Instance.new("UICorner")
                    OptionC.CornerRadius = UDim.new(0, 6)
                    OptionC.Parent = Option

                    Option.MouseButton1Click:Connect(function()
                        ToggleDropVis()
                        callback(Option.Text)
                        DropdownText.Text = Option.Text
                        library.flags[flag] = Option.Text
                    end)
                end

                funcs.RemoveOption = function(self, option)
                    local option = DropdownModule:FindFirstChild("Option_" .. option)
                    if option then
                        option:Destroy()
                    end
                end

                funcs.SetOptions = function(self, options)
                    for _, v in next, DropdownModule:GetChildren() do
                        if v.Name:match("Option_") then
                            v:Destroy()
                        end
                    end
                    for _, v in next, options do
                        funcs:AddOption(v)
                    end
                end

                funcs:SetOptions(options)
                return funcs
            end

            return section
        end

        return tab
    end

    return window
end

return library
