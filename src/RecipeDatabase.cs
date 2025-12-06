using System;
using System.Collections.Generic;
using System.IO;
using System.Security.Cryptography;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace RecipeOrganizer
{
    /// <summary>
    /// Manages the recipes.json database file.
    /// Schema matches the PowerShell Update-RecipeDatabase.ps1 implementation.
    /// </summary>
    public class RecipeDatabase
    {
        private readonly string _rootPath;
        private readonly string _dbPath;

        public RecipeDatabase(string destinationPath)
        {
            _rootPath = destinationPath;
            _dbPath = Path.Combine(Path.GetDirectoryName(destinationPath) ?? destinationPath, "recipes.json");
        }

        public RecipeDatabase(string destinationPath, string dbPath)
        {
            _rootPath = destinationPath;
            _dbPath = dbPath;
        }

        /// <summary>
        /// Scans the destination folder and updates recipes.json
        /// </summary>
        public int Update()
        {
            var recipes = new List<RecipeEntry>();

            if (Directory.Exists(_rootPath))
            {
                var files = Directory.GetFiles(_rootPath, "*.*", SearchOption.AllDirectories);

                foreach (var file in files)
                {
                    var fileInfo = new FileInfo(file);

                    // Get relative path for category extraction
                    string relativePath = file.Substring(_rootPath.Length).TrimStart(Path.DirectorySeparatorChar);
                    string[] parts = relativePath.Split(Path.DirectorySeparatorChar);

                    string category = "Uncategorized";
                    if (parts.Length >= 2)
                    {
                        category = parts[0];
                    }

                    // Calculate SHA256 hash for ID
                    string hash = GetFileHash(file);

                    recipes.Add(new RecipeEntry
                    {
                        Id = hash,
                        Filename = fileInfo.Name,
                        Path = file,
                        Category = category,
                        Tags = new string[0],
                        DateAdded = fileInfo.CreationTime.ToString("yyyy-MM-dd"),
                        SourceType = fileInfo.Extension.TrimStart('.').ToUpper(),
                        HasOcr = false
                    });
                }
            }

            // Write to JSON file
            var options = new JsonSerializerOptions
            {
                WriteIndented = true,
                PropertyNamingPolicy = JsonNamingPolicy.SnakeCaseLower
            };

            string json = JsonSerializer.Serialize(recipes, options);
            File.WriteAllText(_dbPath, json);

            return recipes.Count;
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
    }

    public class RecipeEntry
    {
        [JsonPropertyName("id")]
        public string Id { get; set; }

        [JsonPropertyName("filename")]
        public string Filename { get; set; }

        [JsonPropertyName("path")]
        public string Path { get; set; }

        [JsonPropertyName("category")]
        public string Category { get; set; }

        [JsonPropertyName("tags")]
        public string[] Tags { get; set; }

        [JsonPropertyName("date_added")]
        public string DateAdded { get; set; }

        [JsonPropertyName("source_type")]
        public string SourceType { get; set; }

        [JsonPropertyName("has_ocr")]
        public bool HasOcr { get; set; }
    }
}
