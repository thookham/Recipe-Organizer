using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Security.Cryptography;
using System.Text.RegularExpressions;

namespace RecipeOrganizer
{
    public class Organizer
    {
        public event Action<string, string, ConsoleColor> OnLog;
        public event Action<int, int> OnProgress; // current, total

        private readonly string[] _keywords;
        private readonly bool _noRecurse;
        private readonly Dictionary<string, string> _seenHashes = new Dictionary<string, string>();

        public Organizer(string[] keywords, bool noRecurse)
        {
            _keywords = keywords ?? new[] { "Ingredients", "Directions", "Recipe", "Servings", "Prep time", "Cook time", "Instructions", "Method", "Yield", "Total time", "Nutrition", "Calories" };
            _noRecurse = noRecurse;
        }

        private void Log(string message, string level = "INFO", ConsoleColor color = ConsoleColor.White)
        {
            if (OnLog != null) OnLog(message, level, color);
        }

        public int Organize(string sourcePath, string destPath, string mode)
        {
            _seenHashes.Clear();
            int found = 0;

            Log(string.Format("Starting Organization in '{0}' mode.", mode), "INFO", ConsoleColor.Cyan);
            Log(string.Format("Source: {0}", sourcePath));
            Log(string.Format("Destination: {0}", destPath));

            if (!Directory.Exists(sourcePath))
            {
                Log(string.Format("Source path does not exist: {0}", sourcePath), "ERROR", ConsoleColor.Red);
                return 0;
            }

            if (mode != "Test" && !Directory.Exists(destPath))
            {
                Directory.CreateDirectory(destPath);
            }

            var searchOption = _noRecurse ? SearchOption.TopDirectoryOnly : SearchOption.AllDirectories;
            var files = Directory.GetFiles(sourcePath, "*.*", searchOption)
                .Where(f => !f.StartsWith(destPath, StringComparison.OrdinalIgnoreCase))
                .Where(f => Regex.IsMatch(Path.GetExtension(f), @"\.(docx|doc|txt|pdf|zip|tiff|tif)$", RegexOptions.IgnoreCase))
                .ToList();

            Log(string.Format("Found {0} files to scan.", files.Count), "INFO", ConsoleColor.Cyan);

            int count = 0;
            foreach (var file in files)
            {
                count++;
                OnProgress?.Invoke(count, files.Count);

                var fileInfo = new FileInfo(file);
                Log(string.Format("Processing {0}...", fileInfo.Name), "DEBUG");

                if (fileInfo.Extension.Equals(".zip", StringComparison.OrdinalIgnoreCase))
                {
                    ProcessZip(fileInfo, destPath, mode);
                    continue;
                }

                string content = GetFileText(fileInfo);
                if (IsRecipe(content, fileInfo.Name))
                {
                    found++;
                    ProcessFile(fileInfo, destPath, mode);
                }
            }

            Log("--------------------------------------------------");
            Log(string.Format("Scan Complete. Recipes Found: {0}", found));

            return found;
        }

        private void ProcessFile(FileInfo file, string destPath, string mode)
        {
            string targetFolder;
            string targetFile;
            string actionMsg;

            // Duplicate Detection via SHA256
            string fileHash = GetFileHash(file.FullName);

            if (_seenHashes.ContainsKey(fileHash))
            {
                string originalFile = _seenHashes[fileHash];
                Log(string.Format("DUPLICATE DETECTED: {0}", file.Name), "WARN", ConsoleColor.Yellow);
                Log(string.Format("  Matches: {0}", originalFile), "WARN", ConsoleColor.Gray);

                targetFolder = Path.Combine(destPath, "_Duplicates");

                // Handle filename collision in _Duplicates
                string baseName = Path.GetFileNameWithoutExtension(file.Name);
                string ext = file.Extension;
                targetFile = Path.Combine(targetFolder, file.Name);

                if (File.Exists(targetFile))
                {
                    targetFile = Path.Combine(targetFolder, string.Format("{0}_{1}{2}", baseName, fileHash.Substring(0, 8), ext));
                }

                actionMsg = string.Format("[{0}] Quarantining Duplicate: {1}", mode, file.FullName);
            }
            else
            {
                // New unique recipe
                _seenHashes[fileHash] = file.FullName;

                string firstLetter = char.ToUpper(file.Name[0]).ToString();
                if (!Regex.IsMatch(firstLetter, "[A-Z]")) firstLetter = "#";

                targetFolder = Path.Combine(destPath, firstLetter);
                targetFile = Path.Combine(targetFolder, file.Name);

                actionMsg = string.Format("[{0}] Found Recipe: {1}", mode, file.FullName);
            }

            Log(actionMsg, "INFO", ConsoleColor.Green);

            if (mode == "Test")
            {
                Log(string.Format("  -> Would move/copy to: {0}", targetFile), "INFO", ConsoleColor.Gray);
            }
            else
            {
                if (!Directory.Exists(targetFolder)) Directory.CreateDirectory(targetFolder);

                try
                {
                    if (mode == "Copy")
                    {
                        Log(string.Format("Copying: {0} -> {1}", file.Name, targetFolder), "INFO", ConsoleColor.Green);
                        file.CopyTo(targetFile, true);
                    }
                    else if (mode == "Move")
                    {
                        Log(string.Format("Moving: {0} -> {1}", file.Name, targetFolder), "INFO", ConsoleColor.Green);
                        if (File.Exists(targetFile)) File.Delete(targetFile);
                        file.MoveTo(targetFile);
                    }
                }
                catch (Exception ex)
                {
                    Log(string.Format("Error processing file {0}: {1}", file.Name, ex.Message), "ERROR", ConsoleColor.Red);
                }
            }
        }

        private string GetFileHash(string filePath)
        {
            using (var sha256 = SHA256.Create())
            using (var stream = File.OpenRead(filePath))
            {
                byte[] hashBytes = sha256.ComputeHash(stream);
                return BitConverter.ToString(hashBytes).Replace("-", "").ToUpperInvariant();
            }
        }

        private void ProcessZip(FileInfo zipFile, string destPath, string mode)
        {
            Log(string.Format("Inspecting Zip Archive: {0}", zipFile.Name), "DEBUG");
            try
            {
                using (var archive = ZipFile.OpenRead(zipFile.FullName))
                {
                    foreach (var entry in archive.Entries)
                    {
                        if (entry.FullName.EndsWith("/")) continue;

                        bool isRecipe = false;
                        if (entry.Name.IndexOf("Recipe", StringComparison.OrdinalIgnoreCase) >= 0)
                        {
                            isRecipe = true;
                            Log(string.Format("Found 'Recipe' in zip entry filename: {0}", entry.Name), "DEBUG");
                        }
                        else if (Regex.IsMatch(Path.GetExtension(entry.Name), @"\.(txt|xml|json|md)$", RegexOptions.IgnoreCase))
                        {
                            using (var reader = new StreamReader(entry.Open()))
                            {
                                string text = reader.ReadToEnd();
                                if (_keywords.Any(k => text.IndexOf(k, StringComparison.OrdinalIgnoreCase) >= 0))
                                {
                                    isRecipe = true;
                                    Log(string.Format("Found keyword in zip entry content: {0}", entry.Name), "DEBUG");
                                }
                            }
                        }

                        if (isRecipe)
                        {
                            string firstLetter = char.ToUpper(entry.Name[0]).ToString();
                            if (!Regex.IsMatch(firstLetter, "[A-Z]")) firstLetter = "#";

                            string targetFolder = Path.Combine(destPath, firstLetter);
                            string targetFile = Path.Combine(targetFolder, entry.Name);

                            if (mode == "Test")
                            {
                                Log(string.Format("[{0}] Found Recipe in Zip ({1}): {2}", mode, zipFile.Name, entry.FullName), "INFO", ConsoleColor.Green);
                                Log(string.Format("  -> Would extract to: {0}", targetFile), "INFO", ConsoleColor.Gray);
                            }
                            else
                            {
                                if (!Directory.Exists(targetFolder)) Directory.CreateDirectory(targetFolder);
                                Log(string.Format("Extracting: {0} -> {1}", entry.Name, targetFolder), "INFO", ConsoleColor.Green);
                                
                                if (File.Exists(targetFile)) File.Delete(targetFile);
                                entry.ExtractToFile(targetFile);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Log(string.Format("Failed to process zip file {0}: {1}", zipFile.Name, ex.Message), "WARN", ConsoleColor.Yellow);
            }
        }

        private bool IsRecipe(string content, string filename)
        {
            if (_keywords.Any(k => content.IndexOf(k, StringComparison.OrdinalIgnoreCase) >= 0)) return true;
            if (filename.IndexOf("Recipe", StringComparison.OrdinalIgnoreCase) >= 0) return true;
            return false;
        }

        private string GetFileText(FileInfo file)
        {
            try
            {
                string ext = file.Extension.ToLower();
                if (ext == ".txt" || ext == ".doc" || ext == ".pdf")
                {
                    return File.ReadAllText(file.FullName);
                }
                else if (ext == ".docx")
                {
                    return GetDocxText(file.FullName);
                }
            }
            catch { }
            return "";
        }

        private string GetDocxText(string path)
        {
            try
            {
                using (var archive = ZipFile.OpenRead(path))
                {
                    var entry = archive.GetEntry("word/document.xml");
                    if (entry != null)
                    {
                        using (var reader = new StreamReader(entry.Open()))
                        {
                            string content = reader.ReadToEnd();
                            return Regex.Replace(content, "<[^>]+>", " ");
                        }
                    }
                }
            }
            catch { }
            return "";
        }
    }
}
