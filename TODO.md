# 📝 Project To-Do List

## Version 2.0: Smart Recipe Manager

### 🧹 Duplicate Detection
- [ ] **Implement SHA256 Hash Comparison**: Detect exact duplicates by file content.
- [ ] **Implement Fuzzy Filename Matching**: Detect similar filenames (e.g., "Pie.txt" vs "Pie_v2.txt").
- [ ] **Duplicates Folder**: Logic to safely move identified duplicates to a separate folder for review.

### 👁️ OCR Integration (Optical Character Recognition)
- [ ] **Research WinRT API**: Investigate using `Windows.Media.Ocr` via PowerShell reflection.
- [ ] **Create `Invoke-OCR`**: Helper function to extract text from images (`.jpg`, `.png`, `.tiff`).
- [ ] **Verify OCR**: Test extraction quality on sample recipe images.

### 🗃️ Metadata Database
- [ ] **Define JSON Schema**: Structure for `recipes.json` (ID, Path, Tags, Date).
- [ ] **Implement `Update-RecipeDatabase`**: Function to add/update/remove entries in the JSON index.
- [ ] **Integration**: Call database updates during the main organization loop.

### 🖥️ GUI Updates
- [ ] **"Enable OCR" Checkbox**: Option to toggle slow OCR processing.
- [ ] **"Remove Duplicates" Mode**: New operation mode or button to trigger cleanup.
- [ ] **Database Stats**: Display count of managed recipes.

## Version 3.0: AI Chef (Future)
- [ ] **Gemini AI Integration**: Parse unstructured text into structured ingredients/steps.
- [ ] **Chat Interface**: "Chat with your Cookbook".
