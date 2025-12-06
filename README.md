# 🍳 Recipe Organizer

A powerful tool to identify, organize, and centralize your recipe files automatically. 🥘

[![GitHub release](https://img.shields.io/github/v/release/thookham/Recipe-Organizer)](https://github.com/thookham/Recipe-Organizer/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## ✨ Features

- **🕵️ Smart Detection**: Identifies recipes by keywords (Ingredients, Method, etc.) and filenames
- **📄 Multi-Format Support**: Works with `.docx`, `.doc`, `.pdf`, `.txt`, `.tiff`, and `.zip` files
- **📂 Automatic Organization**: Sorts recipes into A-Z folders based on filename
- **🗃️ Recipe Database**: Maintains a searchable `recipes.json` index of your collection
- **🎛️ Easy Controls**: Browse for folders, select modes, and toggle options with checkboxes
- **📝 Toggleable Log**: Show/hide detailed progress logs to keep the interface clean
- **⚡ Performance**: Animated progress bar with real-time status updates
- **🔒 Safe Testing**: Test mode previews changes without moving files

---

## 📥 Installation

### Option 1: C# Application (Recommended) 🚀

**Faster, more stable, and easier to use.**

1. Go to the `src` folder.
2. Run `RecipeOrganizer.exe`.
3. (Optional) Move the EXE to any folder you like.

### Option 2: PowerShell Script 📜

**Good for customization or if you prefer scripts.**

1. Run `RecipeOrganizerGUI.ps1`.
2. Ensure you have PowerShell execution policies set to allow scripts.

### Option 3: Standalone PowerShell EXE

1. Run `Build-Standalone.ps1` to create a wrapped EXE version of the script.
2. Find the output in the `Release` folder.

---

## 🚀 Quick Start (GUI)

1. **Select Source Folder**: Where your messy recipe files are
2. **Select Destination Folder**: Where you want them organized
3. **Choose Mode**:
   - **Test** - Preview what will happen (no files moved)
   - **Copy** - Copy recipes to destination (originals untouched)
   - **Move** - Move recipes to destination (originals deleted)
4. Click **Start Organizing** (button text changes based on mode!)

**Tip**: Always start with **Test** mode to see what will happen first.

---

## 🛠️ Advanced Usage

### Command Line

Run the PowerShell script directly for automation or scripting:

```powershell
.\Organize-Recipes.ps1 -SourcePath "C:\MyDocs" -DestinationPath "C:\Recipes" -Mode Copy
```

### Parameters

| Parameter | Alias | Description | Default |
|-----------|-------|-------------|---------|
| `-SourcePath` | `-src`, `-s` | Folder to search for recipes | `MyDocuments` |
| `-DestinationPath` | `-dst`, `-d` | Folder to organize recipes into | `C:\Recipes` |
| `-Mode` | `-mod`, `-m` | Operation mode: `Test`, `Copy`, `Move` | `Test` |
| `-NoRecurse` | `-nr` | Only search top-level folder (no subfolders) | `False` |
| `-Keywords` | `-key`, `-k` | Custom keywords to search for | *See below* |

**Default Keywords**: "Ingredients", "Directions", "Recipe", "Servings", "Prep time", "Cook time", "Instructions", "Method", "Yield", "Total time", "Nutrition", "Calories"

### Examples

**Basic test run**:

```powershell
.\Organize-Recipes.ps1 -Mode Test
```

**Organize Downloads folder (no recursion)**:

```powershell
.\Organize-Recipes.ps1 -SourcePath "C:\Users\You\Downloads" -DestinationPath "C:\Recipes" -Mode Move -NoRecurse
```

**Custom keywords**:

```powershell
.\Organize-Recipes.ps1 -Keywords "Grandma", "Secret Sauce", "Family Recipe" -Mode Test
```

---

## 🔧 Troubleshooting

### "Windows cannot access the specified device" / SmartScreen Warning

**This is normal** - the executable is not code-signed (we're an open-source project).

**Quick Fix**:

1. **Move the EXE** from Downloads to another folder (e.g., `C:\RecipeOrganizer\`)
2. **Right-click** `RecipeOrganizer.exe` → **Properties**
3. **Check "Unblock"** at the bottom → Click **OK**
4. **Run the EXE** - if SmartScreen appears, click **"More info"** → **"Run anyway"**

**Why this happens**:

- Windows Defender SmartScreen flags unsigned executables as "Unknown Publisher"
- Attack Surface Reduction (ASR) rules block untrusted executables from the Downloads folder
- **This is NOT malware** - the source code is public and fully auditable on GitHub

**For Enterprise Users**: Ask your IT administrator to whitelist `RecipeOrganizer.exe`.

### "Script is not digitally signed"

If using the PowerShell script directly, you need to allow script execution:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Run this in PowerShell **as Administrator**.

### "Files not found"

- Ensure files contain one of the keywords (e.g., "Ingredients", "Recipe")
- For images (TIFF) or PDFs without text, ensure the **filename** contains "Recipe"
- Check if the file is in a subfolder and you used `-NoRecurse`

### "Access Denied"

- Ensure you have permission to **read** source files and **write** to destination
- Close any open Word/PDF documents before running the script
- Try running as Administrator (right-click → "Run as administrator")

---

## 📋 Requirements

- **OS**: Windows 10 or Windows 11
- **.NET 6 SDK**: Required only if building from source ([Download](https://dotnet.microsoft.com/download/dotnet/6.0))
- **PowerShell**: 5.1 or later (for script mode)

---

## 🗺️ Roadmap

Want to see what's coming next? Check out our [ROADMAP.md](ROADMAP.md) for the full development roadmap!

**v2.0 Features** (Now Available! 🎉):

- ✅ Duplicate detection (SHA256 hash comparison)
- ✅ Recipe database with JSON index
- ✅ Full C# feature parity with PowerShell version

**Upcoming Features**:

- **v2.1**: OCR for image recipes, fuzzy filename matching
- **v3.0**: AI-powered features (Gemini integration, meal planning, nutrition tracking)

---

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 💬 Support

- **Issues**: [GitHub Issues](https://github.com/thookham/Recipe-Organizer/issues)
- **Discussions**: [GitHub Discussions](https://github.com/thookham/Recipe-Organizer/discussions)

---

## ⭐ Show Your Support

If you find this tool helpful, please consider giving it a star on GitHub! ⭐
