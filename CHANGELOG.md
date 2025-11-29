# Changelog

## [1.0.0] - 2025-11-29
### Added
- **Core Script**:
    - Recursive search with `-NoRecurse` (`-nr`) option.
    - Zip file support (scans and extracts recipes).
    - TIFF image support (filename matching).
    - Simplified CLI flags (`-src`, `-dst`, `-m`, `-nr`, `-k`).
- **GUI**:
    - Modern, styled interface with header panel and flat buttons.
    - Emoji support (`Segoe UI Emoji`) for a friendly user experience.
    - Animated progress bar and status text.
    - Collapsible verbose log window.
- **Documentation**:
    - Comprehensive `README.md` with usage examples.
    - Community files: `LICENSE`, `CODE_OF_CONDUCT`, `CONTRIBUTING`, `SECURITY`.
- **Build**:
    - `Build-Release.ps1` script to compile the C# launcher and package the release.
    - `Launcher.cs` (compiles to `RecipeOrganizer.exe`) for a console-free experience.

### Changed
- Expanded default keyword list to include "Method", "Yield", "Nutrition", etc.
- Sanitized codebase to use relative paths (`$PSScriptRoot`) for portability.
