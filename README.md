# 🍳 Recipe Organizer

A powerful tool to identify, organize, and centralize your recipe files. 🥘

## ✨ Features
- **🕵️ Smart Detection**: Identifies recipes by keywords (Ingredients, Method, etc.) and filenames.
- **📄 Format Support**: Works with `.docx`, `.doc`, `.pdf`, `.txt`, `.tiff`, and `.zip` files.
- **📂 Organization**: Automatically sorts recipes into A-Z folders based on filename.
- **Easy Controls**: Browse for folders, select modes, and toggle recursion with checkboxes.
- **📝 Log View**: Toggleable "Show/Hide Log" button to view detailed progress or keep the interface clean.
- **Feedback**: Watch the animated progress bar and view detailed logs if needed.

1.  Select your **Source Folder** (where your messy files are).
2.  Select your **Destination Folder** (where you want them organized).
3.  Choose a **Mode** (Start with 'Test'!).
4.  Click **Start Organizing**.

### ⌨️ Command Line (Advanced)
You can run the PowerShell script directly:
```powershell
.\Organize-Recipes.ps1 -SourcePath "C:\MyDocs" -DestinationPath "C:\Recipes" -Mode Copy
```

## 🛠️ Advanced Usage

### Command Line Parameters
| Parameter | Alias | Description | Default |
| :--- | :--- | :--- | :--- |
| `-SourcePath` | `-src`, `-s` | The folder to search for recipes. | `MyDocuments` |
| `-DestinationPath` | `-dst`, `-d` | The folder to move/copy recipes to. | `C:\Recipes` |
| `-Mode` | `-mod`, `-m` | Operation mode: `Test`, `Copy`, `Move`. | `Test` |
| `-NoRecurse` | `-nr` | If set, only searches the top-level folder (no subfolders). | `False` |
| `-Keywords` | `-key`, `-k` | Custom list of keywords to search for. | *See below* |

**Default Keywords:** "Ingredients", "Directions", "Recipe", "Servings", "Prep time", "Cook time", "Instructions", "Method", "Yield", "Total time", "Nutrition", "Calories".

### Examples
**1. Basic Test Run**
```powershell
.\Organize-Recipes.ps1 -Mode Test
```

**2. Organize Downloads Folder (No Recursion)**
```powershell
.\Organize-Recipes.ps1 -SourcePath "C:\Users\You\Downloads" -DestinationPath "C:\Recipes" -Mode Move -NoRecurse
```

**3. Custom Keywords**
```powershell
.\Organize-Recipes.ps1 -Keywords "Grandma", "Secret Sauce" -Mode Test
```

## 🔧 Troubleshooting

### "Script is not digitally signed"
If you see this error, you need to allow script execution. Run PowerShell as Administrator and type:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```
- .NET Framework 4.5+ (Standard on modern Windows)
- PowerShell 5.1 or later
