using System;
using System.Windows.Forms;

namespace RecipeOrganizer
{
    static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// Supports command-line arguments for automation:
        ///   -SourcePath "path"       Source folder to scan
        ///   -DestinationPath "path"  Destination folder for organized recipes
        ///   -Mode [Test|Copy|Move]   Operation mode
        ///   -AutoRun                 Automatically start organization
        /// </summary>
        [STAThread]
        static void Main(string[] args)
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            // Parse command-line arguments
            string sourcePath = null;
            string destPath = null;
            string mode = null;
            bool autoRun = false;

            for (int i = 0; i < args.Length; i++)
            {
                string arg = args[i];

                if ((arg == "-SourcePath" || arg == "-src" || arg == "-s") && i + 1 < args.Length)
                {
                    sourcePath = args[++i];
                }
                else if ((arg == "-DestinationPath" || arg == "-dst" || arg == "-d") && i + 1 < args.Length)
                {
                    destPath = args[++i];
                }
                else if ((arg == "-Mode" || arg == "-m") && i + 1 < args.Length)
                {
                    mode = args[++i];
                }
                else if (arg == "-AutoRun" || arg == "-auto")
                {
                    autoRun = true;
                }
                else if (arg == "-?" || arg == "-h" || arg == "--help")
                {
                    MessageBox.Show(
                        "Recipe Organizer - Command Line Options\n\n" +
                        "-SourcePath, -src, -s <path>   Source folder to scan\n" +
                        "-DestinationPath, -dst, -d <path>   Destination folder\n" +
                        "-Mode, -m <Test|Copy|Move>   Operation mode\n" +
                        "-AutoRun, -auto   Automatically start organization\n" +
                        "-?, -h, --help   Show this help message",
                        "Recipe Organizer Help",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Information);
                    return;
                }
            }

            var form = new MainForm();

            // If auto-run is requested, trigger after form loads
            if (autoRun)
            {
                form.Load += (s, e) => form.AutoRun(sourcePath, destPath, mode);
            }
            else if (!string.IsNullOrEmpty(sourcePath) || !string.IsNullOrEmpty(destPath) || !string.IsNullOrEmpty(mode))
            {
                // Pre-populate fields but don't auto-run
                form.Load += (s, e) => form.AutoRun(
                    string.IsNullOrEmpty(sourcePath) ? null : sourcePath,
                    string.IsNullOrEmpty(destPath) ? null : destPath,
                    null); // Don't set mode to avoid auto-run
            }

            Application.Run(form);
        }
    }
}
