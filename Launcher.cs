using System;
using System.Diagnostics;
using System.IO;

class Launcher
{
    static void Main()
    {
        string scriptPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "RecipeOrganizerGUI.ps1");
        
        if (!File.Exists(scriptPath))
        {
            // Fallback to non-GUI script if GUI is missing, or just error out.
            // Let's try to find the GUI script.
            return;
        }

        ProcessStartInfo startInfo = new ProcessStartInfo();
        startInfo.FileName = "powershell.exe";
        startInfo.Arguments = string.Format("-ExecutionPolicy Bypass -WindowStyle Hidden -File \"{0}\"", scriptPath);
        startInfo.UseShellExecute = false;
        startInfo.CreateNoWindow = true;
        startInfo.WindowStyle = ProcessWindowStyle.Hidden;

        try
        {
            Process.Start(startInfo);
        }
        catch (Exception)
        {
            // Silently fail or could add a MessageBox if we added System.Windows.Forms reference
        }
    }
}
