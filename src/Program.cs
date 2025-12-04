using System;
using System.Windows.Forms;

namespace RecipeOrganizer
{
    static class Program
    {
        [STAThread]
        static void Main(string[] args)
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            var form = new MainForm();

            if (args.Length > 0)
            {
                // Simple CLI arg parsing for AutoRun
                string source = "";
                string dest = "";
                string mode = "Test";
                bool autoRun = false;

                for (int i = 0; i < args.Length; i++)
                {
                    if (args[i] == "-SourcePath" && i + 1 < args.Length) source = args[i + 1];
                    if (args[i] == "-DestinationPath" && i + 1 < args.Length) dest = args[i + 1];
                    if (args[i] == "-Mode" && i + 1 < args.Length) mode = args[i + 1];
                    if (args[i] == "-AutoRun") autoRun = true;
                }

                if (autoRun)
                {
                    form.Load += (s, e) => form.AutoRun(source, dest, mode);
                }
            }

            Application.Run(form);
        }
    }
}
