using System;
using System.Drawing;
using System.IO;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace RecipeOrganizer
{
    public class MainForm : Form
    {
        private TextBox txtSource;
        private TextBox txtDest;
        private ComboBox cmbMode;
        private CheckBox chkNoRecurse;
        private TextBox txtLog;
        private Button btnRun;
        private ProgressBar progressBar;
        private Label lblStatus;

        public MainForm()
        {
            InitializeComponent();
        }

        private void InitializeComponent()
        {
            this.Text = "🍳 Recipe Organizer";
            this.Size = new Size(600, 500);
            this.StartPosition = FormStartPosition.CenterScreen;
            this.FormBorderStyle = FormBorderStyle.FixedDialog;
            this.MaximizeBox = false;
            this.BackColor = Color.WhiteSmoke;

            // Header
            Panel pnlHeader = new Panel { Dock = DockStyle.Top, Height = 60, BackColor = Color.DarkOrange };
            Label lblHeader = new Label
            {
                Text = "Organize your recipes 🥗",
                Dock = DockStyle.Fill,
                TextAlign = ContentAlignment.MiddleCenter,
                Font = new Font("Segoe UI Emoji", 14, FontStyle.Bold),
                ForeColor = Color.White
            };
            pnlHeader.Controls.Add(lblHeader);
            this.Controls.Add(pnlHeader);

            // Main Panel
            Panel pnlMain = new Panel { Dock = DockStyle.Fill, Padding = new Padding(20) };
            pnlMain.Top = 60;
            this.Controls.Add(pnlMain);

            // Source
            Label lblSource = new Label { Text = "📂 Source Folder:", Location = new Point(20, 80), AutoSize = true, Font = new Font("Segoe UI", 10, FontStyle.Bold) };
            txtSource = new TextBox { Location = new Point(20, 105), Size = new Size(450, 25), Text = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments) };
            Button btnSource = new Button { Text = "Browse", Location = new Point(480, 104), Size = new Size(80, 27), BackColor = Color.White };
            btnSource.Click += (s, e) => { using (var dlg = new FolderBrowserDialog()) if (dlg.ShowDialog() == DialogResult.OK) txtSource.Text = dlg.SelectedPath; };
            this.Controls.Add(lblSource);
            this.Controls.Add(txtSource);
            this.Controls.Add(btnSource);

            // Dest
            Label lblDest = new Label { Text = "🎯 Destination Folder:", Location = new Point(20, 140), AutoSize = true, Font = new Font("Segoe UI", 10, FontStyle.Bold) };
            txtDest = new TextBox { Location = new Point(20, 165), Size = new Size(450, 25), Text = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments), "OrganizedRecipes") };
            Button btnDest = new Button { Text = "Browse", Location = new Point(480, 164), Size = new Size(80, 27), BackColor = Color.White };
            btnDest.Click += (s, e) => { using (var dlg = new FolderBrowserDialog()) if (dlg.ShowDialog() == DialogResult.OK) txtDest.Text = dlg.SelectedPath; };
            this.Controls.Add(lblDest);
            this.Controls.Add(txtDest);
            this.Controls.Add(btnDest);

            // Options
            Label lblMode = new Label { Text = "⚙ Mode:", Location = new Point(20, 210), AutoSize = true, Font = new Font("Segoe UI", 10, FontStyle.Bold) };
            cmbMode = new ComboBox { Location = new Point(90, 207), Size = new Size(100, 25), DropDownStyle = ComboBoxStyle.DropDownList };
            cmbMode.Items.AddRange(new object[] { "Test", "Copy", "Move" });
            cmbMode.SelectedIndex = 0;
            chkNoRecurse = new CheckBox { Text = "🚫 Top folder only", Location = new Point(220, 208), AutoSize = true };
            this.Controls.Add(lblMode);
            this.Controls.Add(cmbMode);
            this.Controls.Add(chkNoRecurse);

            // Progress
            progressBar = new ProgressBar { Location = new Point(20, 250), Size = new Size(540, 10) };
            this.Controls.Add(progressBar);

            // Status
            lblStatus = new Label { Text = "Ready to organize! 🍳", Location = new Point(20, 270), Size = new Size(300, 25) };
            this.Controls.Add(lblStatus);

            // Run Button
            btnRun = new Button { Text = "🚀 Start Organizing", Location = new Point(340, 280), Size = new Size(220, 50), BackColor = Color.FromArgb(46, 204, 113), ForeColor = Color.White, Font = new Font("Segoe UI", 12, FontStyle.Bold), FlatStyle = FlatStyle.Flat };
            btnRun.FlatAppearance.BorderSize = 0;
            btnRun.Click += BtnRun_Click;
            this.Controls.Add(btnRun);

            // Log
            txtLog = new TextBox { Location = new Point(20, 350), Size = new Size(540, 100), Multiline = true, ScrollBars = ScrollBars.Vertical, ReadOnly = true, BackColor = Color.White, Font = new Font("Consolas", 9) };
            this.Controls.Add(txtLog);
        }

        private async void BtnRun_Click(object sender, EventArgs e)
        {
            btnRun.Enabled = false;
            txtLog.Clear();
            progressBar.Style = ProgressBarStyle.Marquee;
            lblStatus.Text = "Working... 🥘";

            string source = txtSource.Text;
            string dest = txtDest.Text;
            string mode = cmbMode.SelectedItem.ToString();
            bool noRecurse = chkNoRecurse.Checked;

            await Task.Run(() =>
            {
                var organizer = new Organizer(null, noRecurse);
                organizer.OnLog += (msg, level, color) =>
                {
                    this.Invoke((Action)(() =>
                    {
                        txtLog.AppendText(string.Format("[{0:HH:mm:ss}] {1}\r\n", DateTime.Now, msg));
                    }));
                };
                organizer.Organize(source, dest, mode);
            });

            progressBar.Style = ProgressBarStyle.Blocks;
            progressBar.Value = 100;
            lblStatus.Text = "Done! 🎉 Bon Appétit!";
            btnRun.Enabled = true;
        }

        public void AutoRun(string source, string dest, string mode)
        {
            txtSource.Text = source;
            txtDest.Text = dest;
            cmbMode.SelectedItem = mode;
            BtnRun_Click(this, EventArgs.Empty);
        }
    }
}
