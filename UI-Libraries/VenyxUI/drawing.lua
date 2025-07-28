local Drawing = Drawing
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Utility table
local utility = {}

-- Themes
local themes = {
    Background = Color3.fromRGB(24, 24, 24),
    Glow = Color3.fromRGB(0, 0, 0),
    Accent = Color3.fromRGB(10, 10, 10),
    LightContrast = Color3.fromRGB(20, 20, 20),
    DarkContrast = Color3.fromRGB(14, 14, 14),
    TextColor = Color3.fromRGB(255, 255, 255)
}

-- Store objects for theme updates
local objects = {}

-- Drawing object management
local drawingObjects = {}

-- Get screen resolution
local function getScreenSize()
    local GuiService = game:GetService("GuiService")
    if GuiService:GetScreenResolution() then
        return GuiService:GetScreenResolution()
    else
        return Vector2.new(1920, 1080) -- Default fallback resolution
    end
end

-- Utility functions
do
    function utility:Create(type, properties)
        local object = Drawing.new(type)
        for i, v in pairs(properties or {}) do
            object[i] = v
            if type(v) == "Color3" then
                local theme = utility:Find(themes, v)
                if theme then
                    objects[theme] = objects[theme] or {}
                    objects[theme][i] = objects[theme][i] or {}
                    table.insert(objects[theme][i], object)
                end
            end
        end
        object.Visible = true
        table.insert(drawingObjects, object)
        return object
    end

    function utility:Tween(object, properties, duration)
        local start = {}
        local delta = {}
        for prop, value in pairs(properties) do
            start[prop] = object[prop]
            delta[prop] = value - object[prop]
        end
        local startTime = tick()
        local connection
        connection = RunService.RenderStepped:Connect(function()
            local t = math.clamp((tick() - startTime) / duration, 0, 1)
            for prop, value in pairs(properties) do
                if typeof(value) == "Vector2" then
                    object[prop] = start[prop] + delta[prop] * t
                elseif typeof(value) == "number" then
                    object[prop] = start[prop] + delta[prop] * t
                elseif typeof(value) == "Color3" then
                    local sR, sG, sB = start[prop].R * 255, start[prop].G * 255, start[prop].B * 255
                    local dR, dG, dB = value.R * 255 - sR, value.G * 255 - sG, value.B * 255 - sB
                    object[prop] = Color3.fromRGB(sR + dR * t, sG + dG * t, sB + dB * t)
                end
            end
            if t >= 1 then
                connection:Disconnect()
            end
        end)
    end

    function utility:Wait()
        RunService.RenderStepped:Wait()
        return true
    end

    function utility:Find(table, value)
        for i, v in pairs(table) do
            if v == value then
                return i
            end
        end
    end

    function utility:Sort(pattern, values)
        local new = {}
        pattern = pattern:lower()
        if pattern == "" then
            return values
        end
        for i, value in pairs(values) do
            if tostring(value):lower():find(pattern) then
                table.insert(new, value)
            end
        end
        return new
    end

    function utility:Pop(object, shrink)
        local clone = Drawing.new("Square")
        clone.Position = object.Position + Vector2.new(shrink / 2, shrink / 2)
        clone.Size = object.Size - Vector2.new(shrink, shrink)
        clone.Color = object.Color
        clone.Filled = true
        clone.Transparency = object.Transparency
        clone.Visible = true
        table.insert(drawingObjects, clone)

        object.Transparency = 0
        utility:Tween(clone, {Size = object.Size}, 0.2)

        spawn(function()
            wait(0.2)
            object.Transparency = clone.Transparency
            clone:Remove()
        end)

        return clone
    end

    function utility:InitializeKeybind()
        self.keybinds = {}
        self.ended = {}

        UserInputService.InputBegan:Connect(function(key, proc)
            if self.keybinds[key.KeyCode] and not proc then
                for i, bind in pairs(self.keybinds[key.KeyCode]) do
                    bind()
                end
            end
        end)

        UserInputService.InputEnded:Connect(function(key)
            if key.UserInputType == Enum.UserInputType.MouseButton1 then
                for i, callback in pairs(self.ended) do
                    callback()
                end
            end
        end)
    end

    function utility:BindToKey(key, callback)
        self.keybinds[key] = self.keybinds[key] or {}
        table.insert(self.keybinds[key], callback)
        return {
            UnBind = function()
                for i, bind in pairs(self.keybinds[key]) do
                    if bind == callback then
                        table.remove(self.keybinds[key], i)
                    end
                end
            end
        }
    end

    function utility:KeyPressed()
        local key = UserInputService.InputBegan:Wait()
        while key.UserInputType ~= Enum.UserInputType.Keyboard do
            key = UserInputService.InputBegan:Wait()
        end
        wait()
        return key
    end

    function utility:DraggingEnabled(frame, parent)
        parent = parent or frame
        local dragging = false
        local dragInput, mousePos, framePos

        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local x, y = Mouse.X, Mouse.Y
                if x >= frame.Position.X and x <= frame.Position.X + frame.Size.X and
                   y >= frame.Position.Y and y <= frame.Position.Y + frame.Size.Y then
                    dragging = true
                    mousePos = Vector2.new(input.Position.X, input.Position.Y)
                    framePos = parent.Position
                end
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                local delta = Vector2.new(input.Position.X, input.Position.Y) - mousePos
                parent.Position = framePos + delta
            end
        end)
    end

    function utility:DraggingEnded(callback)
        table.insert(self.ended, callback)
    end

    function utility:GetTextSize(text, size, font)
        local temp = Drawing.new("Text")
        temp.Text = text
        temp.Size = size
        temp.Font = font or Drawing.Fonts.UI
        temp.Visible = false
        local size = temp.TextBounds
        temp:Remove()
        return size
    end
end

-- Classes
local library = {}
local page = {}
local section = {}

do
    library.__index = library
    page.__index = page
    section.__index = section

    function library.new(title)
        local screenSize = getScreenSize()
        local container = {
            Main = {
                Background = utility:Create("Square", {
                    Position = Vector2.new(0.35 * screenSize.X, 0.25 * screenSize.Y),
                    Size = Vector2.new(511, 428),
                    Color = themes.Background,
                    Filled = true,
                    Transparency = 1
                }),
                Glow = utility:Create("Square", {
                    Position = Vector2.new(-15, -15) + Vector2.new(0.35 * screenSize.X, 0.25 * screenSize.Y),
                    Size = Vector2.new(511 + 30, 428 + 30),
                    Color = themes.Glow,
                    Filled = true,
                    Transparency = 0.5
                }),
                TopBar = utility:Create("Square", {
                    Position = Vector2.new(0.35 * screenSize.X, 0.25 * screenSize.Y),
                    Size = Vector2.new(511, 38),
                    Color = themes.Accent,
                    Filled = true,
                    Transparency = 1
                }),
                Title = utility:Create("Text", {
                    Position = Vector2.new(12, 19) + Vector2.new(0.35 * screenSize.X, 0.25 * screenSize.Y),
                    Text = title,
                    Color = themes.TextColor,
                    Size = 14,
                    Font = Drawing.Fonts.UI,
                    Transparency = 1
                }),
                Pages = {
                    Background = utility:Create("Square", {
                        Position = Vector2.new(0, 38) + Vector2.new(0.35 * screenSize.X, 0.25 * screenSize.Y),
                        Size = Vector2.new(126, 428 - 38),
                        Color = themes.DarkContrast,
                        Filled = true,
                        Transparency = 1
                    }),
                    Pages_Container = {
                        Objects = {},
                        CanvasPosition = Vector2.new(0, 0),
                        CanvasSize = Vector2.new(0, 314)
                    }
                }
            }
        }

        utility:InitializeKeybind()
        utility:DraggingEnabled(container.Main.TopBar, container.Main.Background)

        return setmetatable({
            container = container,
            pagesContainer = container.Main.Pages.Pages_Container,
            pages = {},
            position = nil,
            toggling = false
        }, library)
    end

    function page.new(library, title, icon)
        local button = {
            Background = utility:Create("Square", {
                Position = Vector2.new(library.pagesContainer.Objects[#library.pagesContainer.Objects] and (library.pagesContainer.Objects[#library.pagesContainer.Objects].Position + Vector2.new(0, 26 + 10)) or Vector2.new(0, 10) + library.container.Main.Pages.Background.Position),
                Size = Vector2.new(126, 26),
                Color = themes.DarkContrast,
                Filled = true,
                Transparency = 0.65
            }),
            Title = utility:Create("Text", {
                Position = Vector2.new(40, 13) + (library.pagesContainer.Objects[#library.pagesContainer.Objects] and (library.pagesContainer.Objects[#library.pagesContainer.Objects].Position + Vector2.new(0, 26 + 10)) or Vector2.new(0, 10) + library.container.Main.Pages.Background.Position),
                Text = title,
                Color = themes.TextColor,
                Size = 12,
                Font = Drawing.Fonts.UI,
                Transparency = 0.65
            })
        }
        if icon then
            button.Icon = utility:Create("Text", {
                Position = Vector2.new(12, 13) + (library.pagesContainer.Objects[#library.pagesContainer.Objects] and (library.pagesContainer.Objects[#library.pagesContainer.Objects].Position + Vector2.new(0, 26 + 10)) or Vector2.new(0, 10) + library.container.Main.Pages.Background.Position),
                Text = icon, -- Use provided icon text
                Color = themes.TextColor,
                Size = 12,
                Font = Drawing.Fonts.UI,
                Transparency = 0.64
            })
        end

        local container = {
            Background = utility:Create("Square", {
                Position = Vector2.new(134, 46) + library.container.Main.Background.Position,
                Size = Vector2.new(511 - 142, 428 - 56),
                Color = themes.Background,
                Filled = true,
                Transparency = 1,
                Visible = false
            }),
            Objects = {},
            CanvasPosition = Vector2.new(0, 0),
            CanvasSize = Vector2.new(0, 466)
        }

        table.insert(library.pagesContainer.Objects, button.Background)
        return setmetatable({
            library = library,
            container = container,
            button = button,
            sections = {}
        }, page)
    end

    function section.new(page, title)
        local container = {
            Background = utility:Create("Square", {
                Position = Vector2.new(8, 8 + (page.container.Objects[#page.container.Objects] and (page.container.Objects[#page.container.Objects].Position.Y - page.container.Background.Position.Y + page.container.Objects[#page.container.Objects].Size.Y + 10) or 0)) + page.container.Background.Position,
                Size = Vector2.new(page.container.Background.Size.X - 10, 28),
                Color = themes.LightContrast,
                Filled = true,
                Transparency = 1
            }),
            Title = utility:Create("Text", {
                Position = Vector2.new(8, 8 + (page.container.Objects[#page.container.Objects] and (page.container.Objects[#page.container.Objects].Position.Y - page.container.Background.Position.Y + page.container.Objects[#page.container.Objects].Size.Y + 10) or 0) + 4) + page.container.Background.Position,
                Text = title,
                Color = themes.TextColor,
                Size = 12,
                Font = Drawing.Fonts.UI,
                Transparency = 1
            }),
            Container = {
                Objects = {}
            }
        }

        table.insert(page.container.Objects, container.Background)
        return setmetatable({
            page = page,
            container = container.Container,
            colorpickers = {},
            modules = {},
            binds = {},
            lists = {}
        }, section)
    end

    function library:addPage(...)
        local page = page.new(self, ...)
        local button = page.button

        table.insert(self.pages, page)

        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local x, y = Mouse.X, Mouse.Y
                if x >= button.Background.Position.X and x <= button.Background.Position.X + button.Background.Size.X and
                   y >= button.Background.Position.Y and y <= button.Background.Position.Y + button.Background.Size.Y then
                    self:SelectPage(page, true)
                end
            end
        end)

        return page
    end

    function page:addSection(...)
        local section = section.new(self, ...)
        table.insert(self.sections, section)
        return section
    end

    function library:setTheme(theme, color3)
        themes[theme] = color3
        for property, objects in pairs(objects[theme]) do
            for i, object in pairs(objects) do
                if object.Visible then
                    object[property] = color3
                else
                    objects[i] = nil
                end
            end
        end
    end

    function library:toggle()
        if self.toggling then
            return
        end

        self.toggling = true
        local container = self.container.Main

        if self.position then
            utility:Tween(container.Background, {
                Size = Vector2.new(511, 428),
                Position = self.position
            }, 0.2)
            utility:Tween(container.TopBar, {Size = Vector2.new(511, 38)}, 0.2)
            wait(0.4)
            self.position = nil
        else
            self.position = container.Background.Position
            utility:Tween(container.TopBar, {Size = Vector2.new(511, 428)}, 0.2)
            wait(0.2)
            utility:Tween(container.Background, {
                Size = Vector2.new(511, 0),
                Position = self.position + Vector2.new(0, 428)
            }, 0.2)
            wait(0.2)
        end

        self.toggling = false
    end

    function library:Notify(title, text, callback)
        if self.activeNotification then
            self.activeNotification()
        end

        local notification = {
            Background = utility:Create("Square", {
                Position = self.lastNotification or Vector2.new(10, getScreenSize().Y - 70),
                Size = Vector2.new(0, 60),
                Color = themes.Background,
                Filled = true,
                Transparency = 1
            }),
            Flash = utility:Create("Square", {
                Position = self.lastNotification or Vector2.new(10, getScreenSize().Y - 70),
                Size = Vector2.new(0, 60),
                Color = themes.TextColor,
                Filled = true,
                Transparency = 1
            }),
            Glow = utility:Create("Square", {
                Position = (self.lastNotification or Vector2.new(10, getScreenSize().Y - 70)) + Vector2.new(-15, -15),
                Size = Vector2.new(30, 90),
                Color = themes.Glow,
                Filled = true,
                Transparency = 0.5
            }),
            Title = utility:Create("Text", {
                Position = (self.lastNotification or Vector2.new(10, getScreenSize().Y - 70)) + Vector2.new(10, 8),
                Text = title or "Notification",
                Color = themes.TextColor,
                Size = 14,
                Font = Drawing.Fonts.UI,
                Transparency = 1
            }),
            Text = utility:Create("Text", {
                Position = (self.lastNotification or Vector2.new(10, getScreenSize().Y - 70)) + Vector2.new(10, 36),
                Text = text or "",
                Color = themes.TextColor,
                Size = 12,
                Font = Drawing.Fonts.UI,
                Transparency = 1
            }),
            Accept = utility:Create("Square", {
                Position = (self.lastNotification or Vector2.new(10, getScreenSize().Y - 70)) + Vector2.new(174, 8),
                Size = Vector2.new(16, 16),
                Color = themes.TextColor,
                Filled = true,
                Transparency = 1
            }),
            Decline = utility:Create("Square", {
                Position = (self.lastNotification or Vector2.new(10, getScreenSize().Y - 70)) + Vector2.new(174, 36),
                Size = Vector2.new(16, 16),
                Color = themes.TextColor,
                Filled = true,
                Transparency = 1
            })
        }

        local textSize = utility:GetTextSize(text or "", 12, Drawing.Fonts.UI)
        utility:Tween(notification.Background, {Size = Vector2.new(textSize.X + 70, 60)}, 0.2)
        utility:Tween(notification.Flash, {Size = Vector2.new(0, 60), Position = notification.Background.Position + Vector2.new(textSize.X + 70, 0)}, 0.2)
        utility:DraggingEnabled(notification.Background)

        local active = true
        local close = function()
            if not active then return end
            active = false
            self.lastNotification = notification.Background.Position
            utility:Tween(notification.Flash, {Size = Vector2.new(textSize.X + 70, 60), Position = notification.Background.Position}, 0.2)
            wait(0.2)
            utility:Tween(notification.Background, {Size = Vector2.new(0, 60), Position = notification.Background.Position + Vector2.new(textSize.X + 70, 0)}, 0.2)
            wait(0.2)
            for _, obj in pairs(notification) do
                obj:Remove()
            end
        end

        self.activeNotification = close

        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and active then
                local x, y = Mouse.X, Mouse.Y
                if x >= notification.Accept.Position.X and x <= notification.Accept.Position.X + 16 and
                   y >= notification.Accept.Position.Y and y <= notification.Accept.Position.Y + 16 then
                    if callback then callback(true) end
                    close()
                elseif x >= notification.Decline.Position.X and x <= notification.Decline.Position.X + 16 and
                       y >= notification.Decline.Position.Y and y <= notification.Decline.Position.Y + 16 then
                    if callback then callback(false) end
                    close()
                end
            end
        end)

        return notification
    end

    function section:addButton(title, callback)
        local button = {
            Background = utility:Create("Square", {
                Position = Vector2.new(0, #self.container.Objects * 34 + 8) + self.container.Background.Position,
                Size = Vector2.new(self.container.Background.Size.X, 30),
                Color = themes.DarkContrast,
                Filled = true,
                Transparency = 1
            }),
            Title = utility:Create("Text", {
                Position = Vector2.new(10, #self.container.Objects * 34 + 8 + 15) + self.container.Background.Position,
                Text = title,
                Color = themes.TextColor,
                Size = 12,
                Font = Drawing.Fonts.UI,
                Transparency = 0.9
            })
        }

        table.insert(self.modules, button)

        local debounce
        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and not debounce then
                local x, y = Mouse.X, Mouse.Y
                if x >= button.Background.Position.X and x <= button.Background.Position.X + button.Background.Size.X and
                   y >= button.Background.Position.Y and y <= button.Background.Position.Y + button.Background.Size.Y then
                    debounce = true
                    utility:Pop(button.Background, 10)
                    utility:Tween(button.Title, {Size = 14}, 0.2)
                    wait(0.2)
                    utility:Tween(button.Title, {Size = 12}, 0.2)
                    if callback then
                        callback(function(...)
                            self:updateButton(button, ...)
                        end)
                    end
                    debounce = false
                end
            end
        end)

        table.insert(self.container.Objects, button.Background)
        return button
    end

    function section:addToggle(title, default, callback)
        local toggle = {
            Background = utility:Create("Square", {
                Position = Vector2.new(0, #self.container.Objects * 34 + 8) + self.container.Background.Position,
                Size = Vector2.new(self.container.Background.Size.X, 30),
                Color = themes.DarkContrast,
                Filled = true,
                Transparency = 1
            }),
            Title = utility:Create("Text", {
                Position = Vector2.new(10, #self.container.Objects * 34 + 8 + 15) + self.container.Background.Position,
                Text = title,
                Color = themes.TextColor,
                Size = 12,
                Font = Drawing.Fonts.UI,
                Transparency = 0.9
            }),
            Button = {
                Background = utility:Create("Square", {
                    Position = Vector2.new(self.container.Background.Size.X - 50, #self.container.Objects * 34 + 8 + 7) + self.container.Background.Position,
                    Size = Vector2.new(40, 16),
                    Color = themes.LightContrast,
                    Filled = true,
                    Transparency = 1
                }),
                Frame = utility:Create("Square", {
                    Position = Vector2.new(self.container.Background.Size.X - 48, #self.container.Objects * 34 + 8 + 9.5) + self.container.Background.Position,
                    Size = Vector2.new(18, 7),
                    Color = themes.TextColor,
                    Filled = true,
                    Transparency = 1
                })
            }
        }

        table.insert(self.modules, toggle)
        table.insert(self.container.Objects, toggle.Background)

        local active = default
        self:updateToggle(toggle, nil, active)

        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local x, y = Mouse.X, Mouse.Y
                if x >= toggle.Background.Position.X and x <= toggle.Background.Position.X + toggle.Background.Size.X and
                   y >= toggle.Background.Position.Y and y <= toggle.Background.Position.Y + toggle.Background.Size.Y then
                    active = not active
                    self:updateToggle(toggle, nil, active)
                    if callback then
                        callback(active, function(...)
                            self:updateToggle(toggle, ...)
                        end)
                    end
                end
            end
        end)

        return toggle
    end

    function section:addTextbox(title, default, callback)
        local textbox = {
            Background = utility:Create("Square", {
                Position = Vector2.new(0, #self.container.Objects * 34 + 8) + self.container.Background.Position,
                Size = Vector2.new(self.container.Background.Size.X, 30),
                Color = themes.DarkContrast,
                Filled = true,
                Transparency = 1
            }),
            Title = utility:Create("Text", {
                Position = Vector2.new(10, #self.container.Objects * 34 + 8 + 15) + self.container.Background.Position,
                Text = title,
                Color = themes.TextColor,
                Size = 12,
                Font = Drawing.Fonts.UI,
                Transparency = 0.9
            }),
            Button = {
                Background = utility:Create("Square", {
                    Position = Vector2.new(self.container.Background.Size.X - 110, #self.container.Objects * 34 + 8 + 7) + self.container.Background.Position,
                    Size = Vector2.new(100, 16),
                    Color = themes.LightContrast,
                    Filled = true,
                    Transparency = 1
                }),
                Textbox = utility:Create("Text", {
                    Position = Vector2.new(self.container.Background.Size.X - 105, #self.container.Objects * 34 + 8 + 7) + self.container.Background.Position,
                    Text = default or "",
                    Color = themes.TextColor,
                    Size = 11,
                    Font = Drawing.Fonts.UI,
                    Transparency = 1
                })
            }
        }

        table.insert(self.modules, textbox)
        table.insert(self.container.Objects, textbox.Background)

        local focused = false
        local text = default or ""
        local connection

        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local x, y = Mouse.X, Mouse.Y
                if x >= textbox.Button.Background.Position.X and x <= textbox.Button.Background.Position.X + textbox.Button.Background.Size.X and
                   y >= textbox.Button.Background.Position.Y and y <= textbox.Button.Background.Position.Y + textbox.Button.Background.Size.Y then
                    focused = true
                    utility:Tween(textbox.Button.Background, {Size = Vector2.new(200, 16), Position = textbox.Button.Background.Position - Vector2.new(100, 0)}, 0.2)
                    if callback then
                        callback(text, false, function(...)
                            self:updateTextbox(textbox, ...)
                        end)
                    end
                else
                    if focused then
                        focused = false
                        utility:Tween(textbox.Button.Background, {Size = Vector2.new(100, 16), Position = textbox.Button.Background.Position + Vector2.new(100, 0)}, 0.2)
                        if callback then
                            callback(text, true, function(...)
                                self:updateTextbox(textbox, ...)
                            end)
                        end
                    end
                end
            end
        end)

        UserInputService.TextInputBegan:Connect(function(input)
            if focused then
                text = text .. input.KeyCode.Name
                textbox.Button.Textbox.Text = text
                utility:Pop(textbox.Button.Background, 10)
                if callback then
                    callback(text, false, function(...)
                        self:updateTextbox(textbox, ...)
                    end)
                end
            end
        end)

        return textbox
    end

    function section:addKeybind(title, default, callback, changedCallback)
        local keybind = {
            Background = utility:Create("Square", {
                Position = Vector2.new(0, #self.container.Objects * 34 + 8) + self.container.Background.Position,
                Size = Vector2.new(self.container.Background.Size.X, 30),
                Color = themes.DarkContrast,
                Filled = true,
                Transparency = 1
            }),
            Title = utility:Create("Text", {
                Position = Vector2.new(10, #self.container.Objects * 34 + 8 + 15) + self.container.Background.Position,
                Text = title,
                Color = themes.TextColor,
                Size = 12,
                Font = Drawing.Fonts.UI,
                Transparency = 0.9
            }),
            Button = {
                Background = utility:Create("Square", {
                    Position = Vector2.new(self.container.Background.Size.X - 110, #self.container.Objects * 34 + 8 + 7) + self.container.Background.Position,
                    Size = Vector2.new(100, 16),
                    Color = themes.LightContrast,
                    Filled = true,
                    Transparency = 1
                }),
                Text = utility:Create("Text", {
                    Position = Vector2.new(self.container.Background.Size.X - 105, #self.container.Objects * 34 + 8 + 7) + self.container.Background.Position,
                    Text = default and default.Name or "None",
                    Color = themes.TextColor,
                    Size = 11,
                    Font = Drawing.Fonts.UI,
                    Transparency = 1
                })
            }
        }

        table.insert(self.modules, keybind)
        table.insert(self.container.Objects, keybind.Background)

        local animate = function()
            utility:Pop(keybind.Button.Background, 10)
        end

        self.binds[keybind] = {callback = function()
            animate()
            if callback then
                callback(function(...)
                    self:updateKeybind(keybind, ...)
                end)
            end
        end}

        if default and callback then
            self:updateKeybind(keybind, nil, default)
        end

        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local x, y = Mouse.X, Mouse.Y
                if x >= keybind.Background.Position.X and x <= keybind.Background.Position.X + keybind.Background.Size.X and
                   y >= keybind.Background.Position.Y and y <= keybind.Background.Position.Y + keybind.Background.Size.Y then
                    animate()
                    if self.binds[keybind].connection then
                        self:updateKeybind(keybind)
                    elseif keybind.Button.Text.Text == "None" then
                        keybind.Button.Text.Text = "..."
                        local key = utility:KeyPressed()
                        self:updateKeybind(keybind, nil, key.KeyCode)
                        animate()
                        if changedCallback then
                            changedCallback(key, function(...)
                                self:updateKeybind(keybind, ...)
                            end)
                        end
                    end
                end
            end
        end)

        return keybind
    end

    function section:addColorPicker(title, default, callback)
        local colorpicker = {
            Background = utility:Create("Square", {
                Position = Vector2.new(0, #self.container.Objects * 34 + 8) + self.container.Background.Position,
                Size = Vector2.new(self.container.Background.Size.X, 30),
                Color = themes.DarkContrast,
                Filled = true,
                Transparency = 1
            }),
            Title = utility:Create("Text", {
                Position = Vector2.new(10, #self.container.Objects * 34 + 8 + 15) + self.container.Background.Position,
                Text = title,
                Color = themes.TextColor,
                Size = 12,
                Font = Drawing.Fonts.UI,
                Transparency = 0.9
            }),
            Button = utility:Create("Square", {
                Position = Vector2.new(self.container.Background.Size.X - 50, #self.container.Objects * 34 + 8 + 8.5) + self.container.Background.Position,
                Size = Vector2.new(40, 14),
                Color = default or Color3.fromRGB(255, 255, 255),
                Filled = true,
                Transparency = 1
            })
        }

        local tab = {
            Background = utility:Create("Square", {
                Position = Vector2.new(0.75 * getScreenSize().X, 0.4 * getScreenSize().Y),
                Size = Vector2.new(162, 169),
                Color = themes.Background,
                Filled = true,
                Transparency = 1,
                Visible = false
            }),
            Glow = utility:Create("Square", {
                Position = Vector2.new(0.75 * getScreenSize().X - 15, 0.4 * getScreenSize().Y - 15),
                Size = Vector2.new(162 + 30, 169 + 30),
                Color = themes.Glow,
                Filled = true,
                Transparency = 0.5
            }),
            Title = utility:Create("Text", {
                Position = Vector2.new(10, 8) + Vector2.new(0.75 * getScreenSize().X, 0.4 * getScreenSize().Y),
                Text = title,
                Color = themes.TextColor,
                Size = 14,
                Font = Drawing.Fonts.UI,
                Transparency = 1
            }),
            Close = utility:Create("Square", {
                Position = Vector2.new(136, 8) + Vector2.new(0.75 * getScreenSize().X, 0.4 * getScreenSize().Y),
                Size = Vector2.new(16, 16),
                Color = themes.TextColor,
                Filled = true,
                Transparency = 1
            }),
            Container = {
                Canvas = utility:Create("Square", {
                    Position = Vector2.new(8, 32) + Vector2.new(0.75 * getScreenSize().X, 0.4 * getScreenSize().Y),
                    Size = Vector2.new(146, 60),
                    Color = Color3.fromRGB(255, 0, 0),
                    Filled = true,
                    Transparency = 1
                }),
                Color = utility:Create("Square", {
                    Position = Vector2.new(8, 96) + Vector2.new(0.75 * getScreenSize().X, 0.4 * getScreenSize().Y),
                    Size = Vector2.new(146, 16),
                    Color = Color3.fromRGB(255, 0, 0),
                    Filled = true,
                    Transparency = 1
                }),
                Inputs = {
                    R = utility:Create("Square", {
                        Position = Vector2.new(10, 158) + Vector2.new(0.75 * getScreenSize().X, 0.4 * getScreenSize().Y),
                        Size = Vector2.new(44, 16),
                        Color = themes.DarkContrast,
                        Filled = true,
                        Transparency = 1
                    }),
                    RText = utility:Create("Text", {
                        Position = Vector2.new(10, 158) + Vector2.new(0.75 * getScreenSize().X, 0.4 * getScreenSize().Y),
                        Text = "R: 255",
                        Color = themes.TextColor,
                        Size = 10,
                        Font = Drawing.Fonts.UI,
                        Transparency = 1
                    }),
                    G = utility:Create("Square", {
                        Position = Vector2.new(60, 158) + Vector2.new(0.75 * getScreenSize().X, 0.4 * getScreenSize().Y),
                        Size = Vector2.new(44, 16),
                        Color = themes.DarkContrast,
                        Filled = true,
                        Transparency = 1
                    }),
                    GText = utility:Create("Text", {
                        Position = Vector2.new(60, 158) + Vector2.new(0.75 * getScreenSize().X, 0.4 * getScreenSize().Y),
                        Text = "G: 255",
                        Color = themes.TextColor,
                        Size = 10,
                        Font = Drawing.Fonts.UI,
                        Transparency = 1
                    }),
                    B = utility:Create("Square", {
                        Position = Vector2.new(110, 158) + Vector2.new(0.75 * getScreenSize().X, 0.4 * getScreenSize().Y),
                        Size = Vector2.new(44, 16),
                        Color = themes.DarkContrast,
                        Filled = true,
                        Transparency = 1
                    }),
                    BText = utility:Create("Text", {
                        Position = Vector2.new(110, 158) + Vector2.new(0.75 * getScreenSize().X, 0.4 * getScreenSize().Y),
                        Text = "B: 255",
                        Color = themes.TextColor,
                        Size = 10,
                        Font = Drawing.Fonts.UI,
                        Transparency = 1
                    })
                },
                Button = utility:Create("Square", {
                    Position = Vector2.new(8, 129) + Vector2.new(0.75 * getScreenSize().X, 0.4 * getScreenSize().Y),
                    Size = Vector2.new(146, 20),
                    Color = themes.DarkContrast,
                    Filled = true,
                    Transparency = 1
                }),
                ButtonText = utility:Create("Text", {
                    Position = Vector2.new(8, 129) + Vector2.new(0.75 * getScreenSize().X, 0.4 * getScreenSize().Y),
                    Text = "Submit",
                    Color = themes.TextColor,
                    Size = 11,
                    Font = Drawing.Fonts.UI,
                    Transparency = 1
                })
            }
        }

        table.insert(self.modules, colorpicker)
        local color3 = default or Color3.fromRGB(255, 255, 255)
        local hue, sat, brightness = Color3.toHSV(color3)
        local rgb = {r = color3.R * 255, g = color3.G * 255, b = color3.B * 255}

        self.colorpickers[colorpicker] = {
            tab = tab,
            callback = function(prop, value)
                rgb[prop] = value
                hue, sat, brightness = Color3.toHSV(Color3.fromRGB(rgb.r, rgb.g, rgb.b))
            end
        }

        local callback = function(value)
            if callback then
                callback(value, function(...)
                    self:updateColorPicker(colorpicker, ...)
                end)
            end
        end

        utility:DraggingEnded(function()
            draggingColor, draggingCanvas = false, false
        end)

        if default then
            self:updateColorPicker(colorpicker, nil, default)
        end

        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local x, y = Mouse.X, Mouse.Y
                if x >= colorpicker.Background.Position.X and x <= colorpicker.Background.Position.X + colorpicker.Background.Size.X and
                   y >= colorpicker.Background.Position.Y and y <= colorpicker.Background.Position.Y + colorpicker.Background.Size.Y then
                    toggleTab()
                elseif x >= tab.Close.Position.X and x <= tab.Close.Position.X + 16 and
                       y >= tab.Close.Position.Y and y <= tab.Close.Position.Y + 16 and tab.Background.Visible then
                    self:updateColorPicker(colorpicker, nil, lastColor)
                    toggleTab()
                elseif x >= tab.Container.Button.Position.X and x <= tab.Container.Button.Position.X + tab.Container.Button.Size.X and
                       y >= tab.Container.Button.Position.Y and y <= tab.Container.Button.Position.Y + tab.Container.Button.Size.Y and tab.Background.Visible then
                    toggleTab()
                end
            end
        end)

        local toggleTab = function()
            local visible = not tab.Background.Visible
            if visible then
                if self.page.library.activePicker and self.page.library.activePicker ~= toggleTab then
                    self.page.library.activePicker(false)
                end
                self.page.library.activePicker = toggleTab
                lastColor = Color3.fromHSV(hue, sat, brightness)
                tab.Background.Size = Vector2.new(0, 0)
                tab.Background.Visible = true
                utility:Tween(tab.Background, {Size = Vector2.new(162, 169)}, 0.2)
            else
                utility:Tween(tab.Background, {Size = Vector2.new(0, 0)}, 0.2)
                wait(0.2)
                tab.Background.Visible = false
            end
        end

        return colorpicker
    end

    function section:addSlider(title, default, min, max, callback)
        local slider = {
            Background = utility:Create("Square", {
                Position = Vector2.new(0, #self.container.Objects * 34 + 8) + self.container.Background.Position,
                Size = Vector2.new(self.container.Background.Size.X, 50),
                Color = themes.DarkContrast,
                Filled = true,
                Transparency = 1
            }),
            Title = utility:Create("Text", {
                Position = Vector2.new(10, #self.container.Objects * 34 + 8 + 6) + self.container.Background.Position,
                Text = title,
                Color = themes.TextColor,
                Size = 12,
                Font = Drawing.Fonts.UI,
                Transparency = 0.9
            }),
            TextBox = utility:Create("Text", {
                Position = Vector2.new(self.container.Background.Size.X - 30, #self.container.Objects * 34 + 8 + 6) + self.container.Background.Position,
                Text = tostring(default or min),
                Color = themes.TextColor,
                Size = 12,
                Font = Drawing.Fonts.UI,
                Transparency = 1
            }),
            Slider = {
                Bar = utility:Create("Square", {
                    Position = Vector2.new(10, #self.container.Objects * 34 + 8 + 28) + self.container.Background.Position,
                    Size = Vector2.new(self.container.Background.Size.X - 20, 4),
                    Color = themes.LightContrast,
                    Filled = true,
                    Transparency = 1
                }),
                Fill = utility:Create("Square", {
                    Position = Vector2.new(10, #self.container.Objects * 34 + 8 + 28) + self.container.Background.Position,
                    Size = Vector2.new((self.container.Background.Size.X - 20) * ((default or min) - min) / (max - min), 4),
                    Color = themes.TextColor,
                    Filled = true,
                    Transparency = 1
                })
            }
        }

        table.insert(self.modules, slider)
        table.insert(self.container.Objects, slider.Background)

        local value = default or min
        local dragging = false

        local callback = function(value)
            if callback then
                callback(value, function(...)
                    self:updateSlider(slider, ...)
                end)
            end
        end

        self:updateSlider(slider, nil, value, min, max)

        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local x, y = Mouse.X, Mouse.Y
                if x >= slider.Background.Position.X and x <= slider.Background.Position.X + slider.Background.Size.X and
                   y >= slider.Background.Position.Y and y <= slider.Background.Position.Y + slider.Background.Size.Y then
                    dragging = true
                end
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                local percent = math.clamp((Mouse.X - slider.Slider.Bar.Position.X) / slider.Slider.Bar.Size.X, 0, 1)
                value = math.floor(min + (max - min) * percent)
                slider.TextBox.Text = tostring(value)
                utility:Tween(slider.Slider.Fill, {Size = Vector2.new((slider.Slider.Bar.Size.X) * percent, 4)}, 0.1)
                callback(value)
            end
        end)

        return slider
    end

    function section:addDropdown(title, list, callback)
        local dropdown = {
            Background = utility:Create("Square", {
                Position = Vector2.new(0, #self.container.Objects * 34 + 8) + self.container.Background.Position,
                Size = Vector2.new(self.container.Background.Size.X, 30),
                Color = themes.DarkContrast,
                Filled = true,
                Transparency = 1
            }),
            Search = {
                TextBox = utility:Create("Text", {
                    Position = Vector2.new(10, #self.container.Objects * 34 + 8 + 15) + self.container.Background.Position,
                    Text = title,
                    Color = themes.TextColor,
                    Size = 12,
                    Font = Drawing.Fonts.UI,
                    Transparency = 0.9
                }),
                Button = utility:Create("Square", {
                    Position = Vector2.new(self.container.Background.Size.X - 28, #self.container.Objects * 34 + 8 + 6) + self.container.Background.Position,
                    Size = Vector2.new(18, 18),
                    Color = themes.TextColor,
                    Filled = true,
                    Transparency = 1
                })
            },
            List = {
                Frame = {
                    Objects = {},
                    CanvasSize = Vector2.new(0, 120),
                    CanvasPosition = Vector2.new(0, 0)
                }
            }
        }

        table.insert(self.modules, dropdown)
        table.insert(self.container.Objects, dropdown.Background)

        local search = dropdown.Search
        local focused = false
        list = list or {}

        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local x, y = Mouse.X, Mouse.Y
                if x >= search.Button.Position.X and x <= search.Button.Position.X + search.Button.Size.X and
                   y >= search.Button.Position.Y and y <= search.Button.Position.Y + search.Button.Size.Y then
                    if #dropdown.List.Frame.Objects == 0 then
                        self:updateDropdown(dropdown, nil, list, callback)
                    else
                        self:updateDropdown(dropdown, nil, nil, callback)
                    end
                elseif x >= search.TextBox.Position.X and x <= search.TextBox.Position.X + search.TextBox.TextBounds.X and
                       y >= search.TextBox.Position.Y and y <= search.TextBox.Position.Y + search.TextBox.TextBounds.Y then
                    focused = true
                    if #dropdown.List.Frame.Objects == 0 then
                        self:updateDropdown(dropdown, nil, list, callback)
                    end
                else
                    focused = false
                end
            end
        end)

        UserInputService.TextInputBegan:Connect(function(input)
            if focused then
                local key = input.KeyCode.Name
                if key == "Backspace" then
                    search.TextBox.Text = search.TextBox.Text:sub(1, -2)
                else
                    search.TextBox.Text = search.TextBox.Text .. key
                end
                local filteredList = utility:Sort(search.TextBox.Text, list)
                filteredList = #filteredList ~= 0 and filteredList
                self:updateDropdown(dropdown, nil, filteredList, callback)
            end
        end)

        return dropdown
    end

    function library:SelectPage(page, toggle)
        if toggle and self.focusedPage == page then
            return
        end

        local button = page.button
        if toggle then
            button.Title.Transparency = 1
            button.Background.Transparency = 1
            if button.Icon then
                button.Icon.Transparency = 1
            end

            local focusedPage = self.focusedPage
            self.focusedPage = page

            if focusedPage then
                self:SelectPage(focusedPage, false)
            end

            page:Resize()
            page.container.Background.Visible = true
            if focusedPage then
                focusedPage.container.Background.Visible = false
            end

            for i, section in pairs(page.sections) do
                section.container.Background.Transparency = 1
                section.container.Title.Transparency = 1
                section:Resize(true)
            end
        else
            button.Title.Transparency = 0.65
            button.Background.Transparency = 0.65
            if button.Icon then
                button.Icon.Transparency = 0.65
            end
            for i, section in pairs(page.sections) do
                section.container.Background.Transparency = 1
                section.container.Title.Transparency = 1
            end
            page.lastPosition = page.container.CanvasPosition.Y
            page:Resize()
        end
    end

    function page:Resize(scroll)
        local padding = 10
        local size = 0
        for i, section in pairs(self.sections) do
            size = size + section.container.Background.Size.Y + padding
        end
        self.container.CanvasSize = Vector2.new(0, size)
        if scroll then
            self.container.CanvasPosition = Vector2.new(0, self.lastPosition or 0)
        end
    end

    function section:Resize(smooth)
        if self.page.library.focusedPage ~= self.page then
            return
        end
        local padding = 4
        local size = 24 + (4 * padding)
        for i, module in pairs(self.modules) do
            size = size + module.Background.Size.Y + padding
        end
        if smooth then
            utility:Tween(self.container.Background, {Size = Vector2.new(self.container.Background.Size.X, size)}, 0.05)
        else
            self.container.Background.Size = Vector2.new(self.container.Background.Size.X, size)
            self.page:Resize()
        end
    end

    function section:getModule(info)
        if table.find(self.modules, info) then
            return info
        end
        for i, module in pairs(self.modules) do
            if module.Title.Text == info then
                return module
            end
        end
        error("No module found under "..tostring(info))
    end

    function section:updateButton(button, title)
        button = self:getModule(button)
        button.Title.Text = title
    end

    function section:updateToggle(toggle, title, value)
        toggle = self:getModule(toggle)
        local position = {
            In = Vector2.new(toggle.Button.Background.Position.X + 2, toggle.Button.Background.Position.Y + 2.5),
            Out = Vector2.new(toggle.Button.Background.Position.X + 20, toggle.Button.Background.Position.Y + 2.5)
        }
        value = value and "Out" or "In"
        if title then
            toggle.Title.Text = title
        end
        utility:Tween(toggle.Button.Frame, {
            Size = Vector2.new(18, 7),
            Position = position[value] + Vector2.new(0, 2.5)
        }, 0.2)
        wait(0.1)
        utility:Tween(toggle.Button.Frame, {
            Size = Vector2.new(18, 7),
            Position = position[value]
        }, 0.1)
    end

    function section:updateTextbox(textbox, title, value)
        textbox = self:getModule(textbox)
        if title then
            textbox.Title.Text = title
        end
        if value then
            textbox.Button.Textbox.Text = value
        end
    end

    function section:updateKeybind(keybind, title, key)
        keybind = self:getModule(keybind)
        local text = keybind.Button.Text
        local bind = self.binds[keybind]
        if title then
            keybind.Title.Text = title
        end
        if bind.connection then
            bind.connection = bind.connection:UnBind()
        end
        if key then
            self.binds[keybind].connection = utility:BindToKey(key, bind.callback)
            text.Text = key.Name
        else
            text.Text = "None"
        end
    end

    function section:updateColorPicker(colorpicker, title, color)
        colorpicker = self:getModule(colorpicker)
        local picker = self.colorpickers[colorpicker]
        local tab = picker.tab
        if title then
            colorpicker.Title.Text = title
            tab.Title.Text = title
        end
        local color3
        local hue, sat, brightness
        if type(color) == "table" then
            hue, sat, brightness = unpack(color)
            color3 = Color3.fromHSV(hue, sat, brightness)
        else
            color3 = color
            hue, sat, brightness = Color3.toHSV(color3)
        end
        utility:Tween(colorpicker.Button, {Color = color3}, 0.5)
        for i, container in pairs(tab.Container.Inputs) do
            if container.Text then
                container.Text.Text = container.Text.Text:sub(1, 2) .. math.floor(color3[container.Text.Text:sub(1, 1)] * 255)
            end
        end
    end

    function section:updateSlider(slider, title, value, min, max, lvalue)
        slider = self:getModule(slider)
        if title then
            slider.Title.Text = title
        end
        local percent = (value or min) - min) / (max - min)
        value = value or math.floor(min + (max - min) * percent)
        slider.TextBox.Text = tostring(value)
        utility:Tween(slider.Slider.Fill, {Size = Vector2.new((slider.Slider.Bar.Size.X) * percent, 4)}, 0.1)
        if value ~= lvalue then
            utility:Pop(slider.Background, 10)
        end
        return value
    end

    function section:updateDropdown(dropdown, title, list, callback)
        dropdown = self:getModule(dropdown)
        if title then
            dropdown.Search.TextBox.Text = title
        end
        local entries = 0
        utility:Pop(dropdown.Search.Button, 10)
        for i, button in pairs(dropdown.List.Frame.Objects) do
            button:Remove()
        end
        dropdown.List.Frame.Objects = {}
        for i, value in pairs(list or {}) do
            local button = {
                Background = utility:Create("Square", {
                    Position = Vector2.new(4, 4 + (i - 1) * 34) + dropdown.Background.Position,
                    Size = Vector2.new(dropdown.Background.Size.X - 8, 30),
                    Color = themes.DarkContrast,
                    Filled = true,
                    Transparency = 1
                }),
                Text = utility:Create("Text", {
                    Position = Vector2.new(14, 4 + (i - 1) * 34 + 15) + dropdown.Background.Position,
                    Text = tostring(value),
                    Color = themes.TextColor,
                    Size = 12,
                    Font = Drawing.Fonts.UI,
                    Transparency = 0.9
                })
            }
            table.insert(dropdown.List.Frame.Objects, button.Background)
            UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local x, y = Mouse.X, Mouse.Y
                    if x >= button.Background.Position.X and x <= button.Background.Position.X + button.Background.Size.X and
                       y >= button.Background.Position.Y and y <= button.Background.Position.Y + button.Background.Size.Y then
                        if callback then
                            callback(value, function(...)
                                self:updateDropdown(dropdown, ...)
                            end)
                        end
                        self:updateDropdown(dropdown, tostring(value), nil, callback)
                    end
                end
            end)
            entries = entries + 1
        end
        utility:Tween(dropdown.Background, {Size = Vector2.new(dropdown.Background.Size.X, (entries == 0 and 30) or math.clamp(entries, 0, 3) * 34 + 38)}, 0.3)
    end
end

return library
