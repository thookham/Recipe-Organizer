using System;
using System.Drawing;
using System.IO;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace RecipeOrganizer
{
    public class MainForm : Form
    {
        // Controls
        private TextBox txtSource;
        private TextBox txtDest;
        private ComboBox cmbMode;
        private CheckBox chkNoRecurse;
        private TextBox txtLog;
        private Button btnRun;
        private Button btnToggleLog;
        private ProgressBar progressBar;
        private Label lblStatus;
        private Panel pnlHeader;
        private Panel pnlMain;
        private System.Windows.Forms.Timer animationTimer;

        // State
        private bool isLogVisible = false;
        private int dotCount = 0;

        // Colors (matching PowerShell version)
        private readonly Color c_header = Color.FromArgb(255, 140, 0);      // Dark Orange
        private readonly Color c_bg = Color.WhiteSmoke;
        private readonly Color c_btn_action = Color.FromArgb(46, 204, 113); // Emerald Green
        private readonly Color c_btn_text = Color.White;
        private readonly Color c_text = Color.FromArgb(44, 62, 80);         // Dark Blue/Grey

        // Emojis
        private const string E_COOKING = "🍳";
        private const string E_SALAD = "🥗";
        private const string E_FOLDER = "📂";
        private const string E_TARGET = "🎯";
        private const string E_GEAR = "⚙";
        private const string E_NO = "🚫";
        private const string E_ROCKET = "🚀";
        private const string E_MEMO = "📝";
        private const string E_MONKEY = "🙈";
        private const string E_PARTY = "🎉";
        private const string E_PAN = "🥘";

        public MainForm()
        {
            InitializeComponent();
        }

        private void InitializeComponent()
        {
            this.Text = E_COOKING + " Recipe Organizer";
            this.Size = new Size(620, 400);
            this.StartPosition = FormStartPosition.CenterScreen;
            this.FormBorderStyle = FormBorderStyle.FixedDialog;
            this.MaximizeBox = false;
            this.BackColor = c_bg;
            this.ForeColor = c_text;

            // Fonts
            Font fontTitle = new Font("Segoe UI Emoji", 14, FontStyle.Bold);
            Font fontRegular = new Font("Segoe UI", 10);
            Font fontBold = new Font("Segoe UI", 10, FontStyle.Bold);
            Font fontEmoji = new Font("Segoe UI Emoji", 10);
            Font fontEmojiBold = new Font("Segoe UI Emoji", 10, FontStyle.Bold);
            Font fontLog = new Font("Consolas", 9);
            Font fontButton = new Font("Segoe UI Emoji", 12, FontStyle.Bold);

            // Header Panel
            pnlHeader = new Panel { Location = new Point(0, 0), Size = new Size(620, 60), BackColor = c_header };
            Label lblHeader = new Label
            {
                Text = "Organize your recipes " + E_SALAD,
                Location = new Point(0, 0),
                Size = new Size(620, 60),
                Font = fontTitle,
                ForeColor = Color.White,
                TextAlign = ContentAlignment.MiddleCenter,
                BackColor = Color.Transparent
            };
            pnlHeader.Controls.Add(lblHeader);
            this.Controls.Add(pnlHeader);

            // Main Panel
            pnlMain = new Panel { Location = new Point(0, 60), Size = new Size(620, 340) };
            this.Controls.Add(pnlMain);

            // Source Path
            Label lblSource = new Label { Text = E_FOLDER + " Source Folder:", Location = new Point(20, 20), AutoSize = true, Font = fontEmojiBold };
            txtSource = new TextBox { Location = new Point(20, 45), Size = new Size(470, 25), Text = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments), Font = fontRegular };
            Button btnSource = new Button { Text = "Browse", Location = new Point(500, 44), Size = new Size(80, 27), BackColor = Color.White, FlatStyle = FlatStyle.Flat };
            btnSource.Click += (s, e) => { using (var dlg = new FolderBrowserDialog()) if (dlg.ShowDialog() == DialogResult.OK) txtSource.Text = dlg.SelectedPath; };
            pnlMain.Controls.Add(lblSource);
            pnlMain.Controls.Add(txtSource);
            pnlMain.Controls.Add(btnSource);

            // Destination Path
            Label lblDest = new Label { Text = E_TARGET + " Destination Folder:", Location = new Point(20, 80), AutoSize = true, Font = fontEmojiBold };
            txtDest = new TextBox { Location = new Point(20, 105), Size = new Size(470, 25), Text = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments), "OrganizedRecipes"), Font = fontRegular };
            Button btnDest = new Button { Text = "Browse", Location = new Point(500, 104), Size = new Size(80, 27), BackColor = Color.White, FlatStyle = FlatStyle.Flat };
            btnDest.Click += (s, e) => { using (var dlg = new FolderBrowserDialog()) if (dlg.ShowDialog() == DialogResult.OK) txtDest.Text = dlg.SelectedPath; };
            pnlMain.Controls.Add(lblDest);
            pnlMain.Controls.Add(txtDest);
            pnlMain.Controls.Add(btnDest);

            // Mode Selection
            Label lblMode = new Label { Text = E_GEAR + " Mode:", Location = new Point(20, 150), AutoSize = true, Font = fontEmojiBold };
            cmbMode = new ComboBox { Location = new Point(90, 147), Size = new Size(100, 25), DropDownStyle = ComboBoxStyle.DropDownList, Font = fontRegular };
            cmbMode.Items.AddRange(new object[] { "Test", "Copy", "Move" });
            cmbMode.SelectedIndex = 0;
            cmbMode.SelectedIndexChanged += CmbMode_SelectedIndexChanged;

            chkNoRecurse = new CheckBox { Text = E_NO + " Top folder only", Location = new Point(220, 148), AutoSize = true, Font = fontEmoji };
            pnlMain.Controls.Add(lblMode);
            pnlMain.Controls.Add(cmbMode);
            pnlMain.Controls.Add(chkNoRecurse);

            // Progress Bar
            progressBar = new ProgressBar { Location = new Point(20, 190), Size = new Size(560, 12), Style = ProgressBarStyle.Continuous };
            pnlMain.Controls.Add(progressBar);

            // Status Label
            lblStatus = new Label { Text = "Ready to organize! " + E_COOKING, Location = new Point(20, 210), Size = new Size(300, 25), Font = fontEmoji };
            pnlMain.Controls.Add(lblStatus);

            // Toggle Log Button
            btnToggleLog = new Button { Text = "Show Log " + E_MEMO, Location = new Point(20, 240), Size = new Size(130, 30), BackColor = Color.White, FlatStyle = FlatStyle.Flat, Font = fontEmoji };
            btnToggleLog.Click += BtnToggleLog_Click;
            pnlMain.Controls.Add(btnToggleLog);

            // Run Button (dynamic text based on mode)
            btnRun = new Button 
            { 
                Text = E_ROCKET + " Test Organization", 
                Location = new Point(360, 230), 
                Size = new Size(220, 50), 
                BackColor = c_btn_action, 
                ForeColor = c_btn_text, 
                Font = fontButton,
                FlatStyle = FlatStyle.Flat,
                Cursor = Cursors.Hand
            };
            btnRun.FlatAppearance.BorderSize = 0;
            btnRun.Click += BtnRun_Click;
            pnlMain.Controls.Add(btnRun);

            // Log TextBox (initially hidden)
            txtLog = new TextBox 
            { 
                Location = new Point(20, 285), 
                Size = new Size(560, 180), 
                Multiline = true, 
                ScrollBars = ScrollBars.Vertical, 
                ReadOnly = true, 
                BackColor = Color.White, 
                Font = fontLog,
                Visible = false
            };
            pnlMain.Controls.Add(txtLog);

            // Animation Timer
            animationTimer = new System.Windows.Forms.Timer { Interval = 500 };
            animationTimer.Tick += AnimationTimer_Tick;
        }

        private void CmbMode_SelectedIndexChanged(object sender, EventArgs e)
        {
            switch (cmbMode.SelectedItem.ToString())
            {
                case "Test":
                    btnRun.Text = E_ROCKET + " Test Organization";
                    break;
                case "Copy":
                    btnRun.Text = E_ROCKET + " Copy Files";
                    break;
                case "Move":
                    btnRun.Text = E_ROCKET + " Move Files";
                    break;
            }
        }

        private void BtnToggleLog_Click(object sender, EventArgs e)
        {
            isLogVisible = !isLogVisible;

            if (isLogVisible)
            {
                this.Height = 600;
                pnlMain.Size = new Size(620, 540);
                txtLog.Visible = true;
                btnToggleLog.Text = "Hide Log " + E_MONKEY;
            }
            else
            {
                this.Height = 400;
                pnlMain.Size = new Size(620, 340);
                txtLog.Visible = false;
                btnToggleLog.Text = "Show Log " + E_MEMO;
            }
        }

        private void AnimationTimer_Tick(object sender, EventArgs e)
        {
            dotCount = (dotCount + 1) % 4;
            lblStatus.Text = "Working" + new string('.', dotCount) + " " + E_PAN;
        }

        private async void BtnRun_Click(object sender, EventArgs e)
        {
            btnRun.Enabled = false;
            btnRun.BackColor = Color.Gray;
            txtLog.Clear();
            progressBar.Value = 0;
            progressBar.Style = ProgressBarStyle.Marquee;
            dotCount = 0;
            animationTimer.Start();

            string source = txtSource.Text;
            string dest = txtDest.Text;
            string mode = cmbMode.SelectedItem.ToString();
            bool noRecurse = chkNoRecurse.Checked;

            int found = 0;

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

                organizer.OnProgress += (current, total) =>
                {
                    this.Invoke((Action)(() =>
                    {
                        if (total > 0)
                        {
                            progressBar.Style = ProgressBarStyle.Continuous;
                            progressBar.Maximum = total;
                            progressBar.Value = Math.Min(current, total);
                        }
                    }));
                };

                found = organizer.Organize(source, dest, mode);
            });

            // Update database if files were organized
            if (mode != "Test" && found > 0)
            {
                this.Invoke((Action)(() =>
                {
                    txtLog.AppendText(string.Format("[{0:HH:mm:ss}] Updating Recipe Database...\r\n", DateTime.Now));
                }));

                await Task.Run(() =>
                {
                    var db = new RecipeDatabase(dest);
                    int count = db.Update();
                    this.Invoke((Action)(() =>
                    {
                        txtLog.AppendText(string.Format("[{0:HH:mm:ss}] Database updated. {1} recipes indexed.\r\n", DateTime.Now, count));
                    }));
                });
            }

            animationTimer.Stop();
            progressBar.Style = ProgressBarStyle.Continuous;
            progressBar.Value = progressBar.Maximum > 0 ? progressBar.Maximum : 100;
            lblStatus.Text = "Done! " + E_PARTY + " Bon Appétit!";
            btnRun.Enabled = true;
            btnRun.BackColor = c_btn_action;
        }

        public void AutoRun(string source, string dest, string mode)
        {
            if (!string.IsNullOrEmpty(source)) txtSource.Text = source;
            if (!string.IsNullOrEmpty(dest)) txtDest.Text = dest;
            if (!string.IsNullOrEmpty(mode))
            {
                int idx = cmbMode.Items.IndexOf(mode);
                if (idx >= 0) cmbMode.SelectedIndex = idx;
            }
            BtnRun_Click(this, EventArgs.Empty);
        }
    }
}
