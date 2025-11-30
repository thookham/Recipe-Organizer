# Changelog

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
