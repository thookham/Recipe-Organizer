# 📝 Recipe Organizer - Development Roadmap

## ✅ Version 1.0 - Foundation (Complete)
Core file organization with GUI, keyword detection, and standalone executable.

---

## 🚧 Version 2.0 - Smart Management (Current Focus)

### Phase 1: Data Integrity & Cleanup
**Goal**: Help users clean up messy recipe collections

- [ ] **Duplicate Detection System**
  - [ ] **Exact Duplicates**: SHA256 hash comparison for identical files
  - [ ] **Similar Recipes**: Levenshtein distance for fuzzy filename matching
  - [ ] **Smart Review UI**: Preview duplicates side-by-side before deletion
  - [ ] **Safe Move**: Quarantine duplicates to `_Duplicates` folder (don't delete immediately)

**Technical Implementation**:
```powershell
function Find-ExactDuplicates {
    param([string]$Path)
    $hashes = @{}
    Get-ChildItem -Path $Path -Recurse -File | ForEach-Object {
        $hash = Get-FileHash $_.FullName -Algorithm SHA256
        if ($hashes.ContainsKey($hash.Hash)) {
            $hashes[$hash.Hash] += @($_.FullName)
        } else {
            $hashes[$hash.Hash] = @($_.FullName)
        }
    }
    $hashes.GetEnumerator() | Where-Object { $_.Value.Count -gt 1 }
}
```

### Phase 2: Image Recipe Support
**Goal**: Make scanned recipes and photos searchable

- [ ] **OCR Engine Research**
  - [ ] Evaluate `Windows.Media.Ocr` (built-in, no dependencies)
  - [ ] Test accuracy on handwritten vs. printed recipes
  - [ ] Benchmark performance (speed vs. accuracy tradeoff)
  
- [ ] **OCR Implementation**
  - [ ] Create `Invoke-OCR` helper function
  - [ ] Add image pre-processing (rotation, contrast enhancement)
  - [ ] Generate `.txt` sidecar files for extracted text
  - [ ] Add OCR toggle in GUI (with performance warning)

- [ ] **Supported Formats**
  - [ ] JPG/PNG photo extraction
  - [ ] TIFF (already supported for filename matching, add OCR)
  - [ ] Scanned PDFs (extract images first, then OCR)

**Technical Implementation**: Using Windows.Media.Ocr WinRT API via PowerShell

### Phase 3: Recipe Index & Search
**Goal**: Fast search across all recipes without opening files

- [ ] **Database Design**
  - [ ] Define `recipes.json` schema (see below)
  - [ ] Add migration logic for existing organized folders
  - [ ] Include file hash for integrity checks
  
- [ ] **Index Management**
  - [ ] `Update-RecipeDatabase`: Add/update/remove entries
  - [ ] Auto-update on file organization
  - [ ] Rebuild index command (for corrupted databases)
  
- [ ] **Search Features**
  - [ ] Quick search bar in GUI
  - [ ] Filter by: name, category, tags, date added
  - [ ] "Recent Recipes" view (last 10 organized)

**Schema**:
```json
{
  "id": "sha256-hash",
  "filename": "Grandma's Apple Pie.pdf",
  "path": "C:\\Recipes\\Desserts\\A\\Grandma's Apple Pie.pdf",
  "category": "Desserts",
  "tags": ["apple", "pie", "dessert"],
  "date_added": "2023-11-29",
  "source_type": "PDF",
  "has_ocr": false
}
```

### Phase 4: UI/UX Improvements
- [ ] **New GUI Tab**: "Manage Database" (view stats, rebuild index, export list)
- [ ] **Batch Actions**: Select multiple recipes for tagging or category change
- [ ] **Settings Panel**: Configure OCR quality, duplicate sensitivity, default paths

---

## 🔮 Version 3.0 - AI Chef (Future Vision)

### 🧠 Smart Recipe Parsing
- [ ] **Gemini AI Integration**: Parse unstructured text → structured JSON (ingredients, steps, cook time)
- [ ] **Auto-Tagging**: Automatically tag recipes (cuisine type, difficulty, dietary restrictions)
- [ ] **Extract Nutrition**: Parse ingredient amounts → estimate calories/macros

### 💬 Interactive Cookbook
- [ ] **Chat Interface**: "Chat with your Cookbook" - natural language recipe search
- [ ] **Voice Commands**: "Find chicken recipes under 30 minutes"
- [ ] **Smart Suggestions**: "What can I cook with chicken, pasta, and garlic?"

**Technical**: RAG (Retrieval Augmented Generation) with vector embeddings

### 🍽️ Meal Planning & Grocery Management
- [ ] **Weekly Meal Planner**: AI suggests recipes from your collection for the week
- [ ] **Auto-Generated Shopping Lists**: Select recipes → get consolidated grocery list
- [ ] **Pantry Tracker**: Mark what ingredients you have → "cook with what you have" mode
- [ ] **Ingredient Inventory**: Track expiration dates, suggest recipes before food spoils

### 🔄 Recipe Intelligence
- [ ] **Ingredient Substitutions**: "I'm out of eggs" → AI suggests alternatives (applesauce, flax eggs)
- [ ] **Unit Converter**: Auto-convert metric ↔ imperial (cups → grams)
- [ ] **Servings Scaler**: Adjust from 4 to 12 servings, update all ingredients proportionally
- [ ] **Recipe Difficulty Rating**: AI analyzes steps → assigns beginner/intermediate/advanced

### 💪 Nutrition & Health
- [ ] **Auto-Calculate Nutrition**: Extract amounts → estimate calories, protein, carbs, fat
- [ ] **Dietary Filtering**: "Show me vegan recipes" or "gluten-free desserts"
- [ ] **Allergen Detection**: Flag recipes containing nuts, dairy, shellfish, etc.
- [ ] **Health Goals Integration**: Track which recipes fit your meal plan/macros
- [ ] **Nutrition Labels**: Generate FDA-style nutrition facts for each recipe

### 📱 Modern Integrations
- [ ] **Voice Cooking Mode**: Hands-free step-by-step guidance while cooking
- [ ] **Import from URL**: Paste recipe link → AI extracts and adds to collection
- [ ] **Export Beautiful PDFs**: Generate print-ready cookbooks from your collection
- [ ] **Share via QR Code**: Generate shareable links for favorite recipes
- [ ] **Social Features**: "Friends also made this recipe" (opt-in)

### 🎯 Smart Recommendations
- [ ] **"You Haven't Made This"**: Reminders for favorites you haven't cooked in 3+ months
- [ ] **Seasonal Suggestions**: "Fall recipes to try" based on current date
- [ ] **Skill Progression**: Start with easy recipes, gradually suggest harder ones
- [ ] **Similar Recipe Discovery**: "You liked Apple Pie, try Peach Cobbler"
- [ ] **Trending in Your Collection**: See which recipes you cook most often

### 🔐 Technical Requirements
- [ ] User-provided Gemini API Key (secure storage via Windows DPAPI)
- [ ] Internet connection required for AI features
- [ ] Privacy: All AI processing via user's own API quota
- [ ] Offline Mode: Core features (search, view) work without internet

**Key Technical Implementation**: Gemini API for NLP, Speech.Synthesis for voice, vector database for similarity search

---

## 🎯 Priority Order

**Next Up (v2.0 - Phase 1)**:
1. Duplicate detection (most requested feature)
2. Basic database for future search

**Following (v2.0 - Phase 2)**:
3. OCR for image recipes
4. Search functionality

**Future (v3.0)**:
5. AI features (advanced users only)
