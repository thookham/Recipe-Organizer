# 🗺️ Project Roadmap & TODO

## Version 2.0: Smart Recipe Manager (Next Up)

### 1. 🧹 Duplicate Detection (Priority: High)
- [ ] **Exact Duplicates**: Use SHA256 file hashing to find identical files.
- [ ] **Content Duplicates**: Use fuzzy string matching (Levenshtein distance) to find the same recipe saved in different formats (e.g., `.docx` vs `.pdf`).
- [ ] **Action**: Prompt user to keep the best version or archive duplicates.

### 2. 👁️ Optical Character Recognition (OCR)
- [ ] **Integration**: Implement `Windows.Media.Ocr` (via PowerShell/C# reflection).
- [ ] **Benefit**: Enable searching text within images (`.jpg`, `.png`, `.tiff`) and scanned PDFs.

### 3. 🗃️ Structured Data & Database
- [ ] **Storage**: Implement `recipes.json` as a portable index.
- [ ] **Schema**:
    ```json
    {
      "id": "hash",
      "title": "Apple Pie",
      "path": "C:\\Recipes\\A\\ApplePie.txt",
      "tags": ["Dessert", "Fruit"],
      "ingredients": ["Apples", "Flour", "Sugar"],
      "last_cooked": "2023-10-27"
    }
    ```
- [ ] **GUI**: Add a "Database View" tab to browse the index.

---

## Version 3.0: Cloud & AI (Future)

### 4. 🧠 Google Gemini Integration ("Chef AI")
- [ ] **Target Audience**: Advanced Users.
- [ ] **Auth**: Google OAuth 2.0 Login Button.
- [ ] **Cloud Sync**: Google Drive integration for recipe storage.
- [ ] **Shopping Lists**: Google Keep/Stack integration.
- [ ] **Smart Parsing**: Use LLM to convert raw text/OCR output into structured JSON.
- [ ] **Chat Interface**: "Chat with your Cookbook" tab.
