# Changelog

## [v1.3.0] - 2025-12-04

### Added

- **Index Management**: Introduced `Update-RecipeDatabase.ps1` to maintain a JSON-based index of recipes (`recipes.json`).
- **Auto-Update**: `Organize-Recipes.ps1` now automatically updates the recipe database after organizing files.

### Fixed

- **Parameter Binding**: Resolved a bug in `Organize-Recipes.ps1` where script arguments were ignored due to missing `param()` block.

## [v1.2.1] - 2025-12-03

### Added

- **C# Port**: Native WinForms application (`src/RecipeOrganizer.exe`) for better performance and stability.
- **PowerShell Tests**: Added Pester tests (`Tests/RecipeOrganizer.Tests.ps1`) for backend logic.
- **Logging**: Added `Write-Log` helper to PowerShell script for consistent logging.

### Changed

- **Refactor**: Encapsulated `Organize-Recipes.ps1` logic into `Invoke-OrganizeRecipes` function.
- **Build**: Simplified `Build-Standalone.ps1` to remove fragile string manipulation.
- **Fixes**: Resolved Pester v3.4.0 compatibility issues in tests.

## [v1.0.2] - 2025-11-29

### Fixed

- **GUI Logic**: Fixed a critical bug where the execution logic was tied to the animation timer, causing infinite loops and silent failures.
- **Log Toggle**: Fixed the "Show/Hide Log" button to correctly resize the window and toggle visibility.
- **Run Button**: "Run" button now dynamically updates text based on the selected mode (Test, Copy, Move).
- **Simulation**: Added robust debug logging to `simulation_log.txt` for easier troubleshooting.

## [v1.0.1] - 2025-11-29

### Fixed

- **Simulation Hang**: Resolved an issue where the simulation would hang due to incorrect async invocation.
- **GUI Layout**: Log window is now hidden by default to reduce clutter.
- **Stream Capturing**: Improved capturing of Verbose and Information streams in the GUI log.

## [v1.0.0] - 2025-11-29

### Added

- **Standalone Executable**: `RecipeOrganizer.exe` is now a self-contained application. No need to install PowerShell dependencies manually.
- **Modern GUI**: A WPF-based graphical interface with dark mode, progress tracking, and log viewing.
- **Smart Sorting**: Automatically categorizes recipes into folders (e.g., `Dessert`, `Main Course`) based on keywords.
- **Format Support**: Handles `.pdf`, `.docx`, `.doc`, `.txt`, and `.tiff` files.
- **Zip Support**: Can extract and organize recipes directly from `.zip` archives.
- **CLI Improvements**: Added simplified aliases (`-src`, `-dst`, `-mod`) and a `-NoRecurse` flag.

### Changed

- **Simplified CLI**: Shortened flags for easier use (e.g., `-src`, `-dst`).
- **Permission Fixes**: Default save location changed to `My Documents\OrganizedRecipes` to avoid UAC/Admin permission issues.
- **Portable**: Repository sanitized of hardcoded paths for universal compatibility.
- **Documentation**: Comprehensive README and Walkthrough added.
