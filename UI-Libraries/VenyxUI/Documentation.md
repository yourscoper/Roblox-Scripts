# Lua UI Library Documentation

This repository contains a Lua-based UI library designed for Roblox, providing a customizable and interactive user interface system. The library includes features like pages, sections, buttons, toggles, textboxes, keybinds, color pickers, sliders, and dropdowns, all styled with a sleek, themeable design.

## Overview

The library creates a graphical user interface (GUI) within Roblox's environment, allowing developers to build menus with dynamic elements. It supports multiple pages, each containing sections that can hold various interactive modules. The UI is fully draggable and themeable, with support for smooth animations and user input handling.

## Installation

1. Clone or download this repository.
2. Place the `script.lua` file into your Roblox project, typically within a `LocalScript` under `StarterGui` or a similar location.
3. Require the script in your code:
   ```lua
   local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourscoper/Roblox-Scripts/refs/heads/main/UI-Libraries/VenyxUI/source.lua"))(); -- Adjust path as needed
   local Icons = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Nebula-Icon-Library/master/Loader.lua"))(); -- Adjust path as needed
   ```

## Usage

### Creating a Library Instance
Initialize the library with a title:
```lua
local lib = library.new("My UI")
```

### Adding Pages
Add pages to the library with an optional icon:
```lua
local page1 = lib:addPage("Home", Icons:GetIcon("home", "Lucide")) -- Icon ID is optional
```

Full list of all Lucide Icon names here -> [Lucide Icons](https://raw.githubusercontent.com/Nebula-Softworks/Nebula-Icon-Library/master/LucideIcons.lua)

### Adding Sections
Add sections to a page:
```lua
local section1 = page1:addSection("Settings")
```

### Adding Modules
- **Button**: 
  ```lua
  section1:addButton("Click Me", function() print("Clicked!") end)
  ```
- **Toggle**: 
  ```lua
  section1:addToggle("Enabled", false, function(value) print("Toggle:", value) end)
  ```
- **Textbox**: 
  ```lua
  section1:addTextbox("Enter Text", "Default", function(text) print("Text:", text) end)
  ```
- **Keybind**: 
  ```lua
  section1:addKeybind("Bind Key", Enum.KeyCode.E, function() print("Key Pressed!") end)
  ```
- **ColorPicker**: 
  ```lua
  section1:addColorPicker("Pick Color", Color3.fromRGB(255, 0, 0), function(color) print("Color:", color) end)
  ```
- **Slider**: 
  ```lua
  section1:addSlider("Volume", 50, 0, 100, function(value) print("Volume:", value) end)
  ```
- **Dropdown**: 
  ```lua
  section1:addDropdown("Options", {"Option1", "Option2"}, function(value) print("Selected:", value) end)
  ```

### Theme Customization
Change the UI theme dynamically:
```lua
lib:setTheme("Background", Color3.fromRGB(30, 30, 30))
```

### Notifications
Display notifications:
```lua
lib:Notify("Alert", "This is a test notification", function(response) print("Response:", response) end)
```

### Toggling the UI
Toggle the UI visibility:
```lua
lib:toggle()
```

## Functions

- `library:SelectPage(page, toggle)`: Switch between pages.
- `page:Resize(scroll)`: Adjust page size based on content.
- `section:Resize(smooth)`: Adjust section size with optional smooth animation.
- `section:update[Module](module, ...)`: Update module properties (e.g., `updateButton`, `updateToggle`).

## Themes
The library uses a predefined theme object (`themes`) with the following keys:
- `Background`
- `Glow`
- `Accent`
- `LightContrast`
- `DarkContrast`
- `TextColor`

## Dependencies
- Roblox API
- No external dependencies required.

## Contributing
Feel free to fork this repository, submit issues, or send pull requests for enhancements or bug fixes.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact
For support or questions, reach out via the GitHub Issues page.

*Last updated: July 22, 2025*
