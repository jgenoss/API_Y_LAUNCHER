namespace PBLauncher
{
    partial class LauncherForm
    {
        /// <summary>
        /// Variable del diseñador necesaria.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Limpiar los recursos que se estén usando.
        /// </summary>
        /// <param name="disposing">true si los recursos administrados se deben desechar; false en caso contrario.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Código generado por el Diseñador de Windows Forms

        /// <summary>
        /// Método necesario para admitir el Diseñador. No se puede modificar
        /// el contenido de este método con el editor de código.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(LauncherForm));
            this.lblStatus = new System.Windows.Forms.Label();
            this.progressBarDownload = new System.Windows.Forms.ProgressBar();
            this.progressBarExtract = new System.Windows.Forms.ProgressBar();
            this.lblExtract = new System.Windows.Forms.Label();
            this.lblDownload = new System.Windows.Forms.Label();
            this.lblLatestVersion = new System.Windows.Forms.Label();
            this.chkRememberSession = new System.Windows.Forms.CheckBox();
            this.textBox_pass = new System.Windows.Forms.TextBox();
            this.label_pass = new System.Windows.Forms.Label();
            this.label_user = new System.Windows.Forms.Label();
            this.textBox_user = new System.Windows.Forms.TextBox();
            this.PBDetect = new System.Windows.Forms.Timer(this.components);
            this.panel2 = new System.Windows.Forms.Panel();
            this.lb_Ip = new System.Windows.Forms.Label();
            this.lb_User = new System.Windows.Forms.Label();
            this.ExitButton = new System.Windows.Forms.PictureBox();
            this.ConfigButton = new System.Windows.Forms.PictureBox();
            this.MinimizeButton = new System.Windows.Forms.PictureBox();
            this.chromiumWebBrowser1 = new CefSharp.WinForms.ChromiumWebBrowser();
            this.btn_login = new System.Windows.Forms.PictureBox();
            this.StartGameBtn = new System.Windows.Forms.PictureBox();
            this.btnCheck = new System.Windows.Forms.PictureBox();
            this.panel2.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.ExitButton)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.ConfigButton)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.MinimizeButton)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.btn_login)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.StartGameBtn)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.btnCheck)).BeginInit();
            this.SuspendLayout();
            // 
            // lblStatus
            // 
            this.lblStatus.AutoSize = true;
            this.lblStatus.BackColor = System.Drawing.Color.Transparent;
            this.lblStatus.Font = new System.Drawing.Font("Microsoft Sans Serif", 8F);
            this.lblStatus.ForeColor = System.Drawing.Color.White;
            this.lblStatus.Location = new System.Drawing.Point(12, 594);
            this.lblStatus.Name = "lblStatus";
            this.lblStatus.Size = new System.Drawing.Size(47, 13);
            this.lblStatus.TabIndex = 2;
            this.lblStatus.Text = "lblStatus";
            // 
            // progressBarDownload
            // 
            this.progressBarDownload.BackColor = System.Drawing.SystemColors.Control;
            this.progressBarDownload.Location = new System.Drawing.Point(22, 636);
            this.progressBarDownload.Name = "progressBarDownload";
            this.progressBarDownload.Size = new System.Drawing.Size(592, 10);
            this.progressBarDownload.TabIndex = 4;
            // 
            // progressBarExtract
            // 
            this.progressBarExtract.BackColor = System.Drawing.Color.DimGray;
            this.progressBarExtract.Location = new System.Drawing.Point(22, 679);
            this.progressBarExtract.Name = "progressBarExtract";
            this.progressBarExtract.Size = new System.Drawing.Size(592, 10);
            this.progressBarExtract.TabIndex = 4;
            // 
            // lblExtract
            // 
            this.lblExtract.AutoSize = true;
            this.lblExtract.BackColor = System.Drawing.Color.Transparent;
            this.lblExtract.Font = new System.Drawing.Font("Microsoft Sans Serif", 8F);
            this.lblExtract.ForeColor = System.Drawing.Color.White;
            this.lblExtract.Location = new System.Drawing.Point(19, 656);
            this.lblExtract.Name = "lblExtract";
            this.lblExtract.Size = new System.Drawing.Size(50, 13);
            this.lblExtract.TabIndex = 6;
            this.lblExtract.Text = "lblExtract";
            // 
            // lblDownload
            // 
            this.lblDownload.AutoSize = true;
            this.lblDownload.BackColor = System.Drawing.Color.Transparent;
            this.lblDownload.Font = new System.Drawing.Font("Microsoft Sans Serif", 8F);
            this.lblDownload.ForeColor = System.Drawing.Color.White;
            this.lblDownload.Location = new System.Drawing.Point(19, 620);
            this.lblDownload.Name = "lblDownload";
            this.lblDownload.Size = new System.Drawing.Size(65, 13);
            this.lblDownload.TabIndex = 7;
            this.lblDownload.Text = "lblDownload";
            // 
            // lblLatestVersion
            // 
            this.lblLatestVersion.AutoSize = true;
            this.lblLatestVersion.BackColor = System.Drawing.Color.Transparent;
            this.lblLatestVersion.Font = new System.Drawing.Font("Microsoft Sans Serif", 8F);
            this.lblLatestVersion.ForeColor = System.Drawing.Color.White;
            this.lblLatestVersion.Location = new System.Drawing.Point(4, 7);
            this.lblLatestVersion.Name = "lblLatestVersion";
            this.lblLatestVersion.Size = new System.Drawing.Size(42, 13);
            this.lblLatestVersion.TabIndex = 8;
            this.lblLatestVersion.Text = "Version";
            // 
            // chkRememberSession
            // 
            this.chkRememberSession.AutoSize = true;
            this.chkRememberSession.BackColor = System.Drawing.Color.Transparent;
            this.chkRememberSession.Font = new System.Drawing.Font("Microsoft Sans Serif", 9F);
            this.chkRememberSession.ForeColor = System.Drawing.Color.White;
            this.chkRememberSession.Location = new System.Drawing.Point(651, 675);
            this.chkRememberSession.Name = "chkRememberSession";
            this.chkRememberSession.Size = new System.Drawing.Size(77, 19);
            this.chkRememberSession.TabIndex = 19;
            this.chkRememberSession.Text = "Recordar";
            this.chkRememberSession.UseVisualStyleBackColor = false;
            this.chkRememberSession.CheckedChanged += new System.EventHandler(this.chkRememberSession_CheckedChanged);
            // 
            // textBox_pass
            // 
            this.textBox_pass.Location = new System.Drawing.Point(638, 653);
            this.textBox_pass.MaxLength = 35;
            this.textBox_pass.Name = "textBox_pass";
            this.textBox_pass.PasswordChar = '*';
            this.textBox_pass.Size = new System.Drawing.Size(173, 20);
            this.textBox_pass.TabIndex = 17;
            this.textBox_pass.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.textBox_pass_KeyPress);
            // 
            // label_pass
            // 
            this.label_pass.AutoSize = true;
            this.label_pass.BackColor = System.Drawing.Color.Transparent;
            this.label_pass.Font = new System.Drawing.Font("Arial Black", 10F, System.Drawing.FontStyle.Bold);
            this.label_pass.ForeColor = System.Drawing.Color.White;
            this.label_pass.Location = new System.Drawing.Point(677, 631);
            this.label_pass.Name = "label_pass";
            this.label_pass.Size = new System.Drawing.Size(95, 19);
            this.label_pass.TabIndex = 16;
            this.label_pass.Text = "Contraseña";
            // 
            // label_user
            // 
            this.label_user.AutoSize = true;
            this.label_user.BackColor = System.Drawing.Color.Transparent;
            this.label_user.Font = new System.Drawing.Font("Arial Black", 10F, System.Drawing.FontStyle.Bold);
            this.label_user.ForeColor = System.Drawing.Color.White;
            this.label_user.Location = new System.Drawing.Point(688, 587);
            this.label_user.Name = "label_user";
            this.label_user.Size = new System.Drawing.Size(68, 19);
            this.label_user.TabIndex = 15;
            this.label_user.Text = "Usuario";
            // 
            // textBox_user
            // 
            this.textBox_user.Location = new System.Drawing.Point(638, 608);
            this.textBox_user.MaxLength = 35;
            this.textBox_user.Name = "textBox_user";
            this.textBox_user.Size = new System.Drawing.Size(173, 20);
            this.textBox_user.TabIndex = 14;
            this.textBox_user.MouseLeave += new System.EventHandler(this.textBox_user_MouseLeave);
            // 
            // PBDetect
            // 
            this.PBDetect.Tick += new System.EventHandler(this.PBDetect_Tick);
            // 
            // panel2
            // 
            this.panel2.BackColor = System.Drawing.Color.Transparent;
            this.panel2.BackgroundImage = global::PBLauncher.Properties.Resources.BGLabelTITLE;
            this.panel2.Controls.Add(this.lb_Ip);
            this.panel2.Controls.Add(this.lb_User);
            this.panel2.Controls.Add(this.ExitButton);
            this.panel2.Controls.Add(this.ConfigButton);
            this.panel2.Controls.Add(this.MinimizeButton);
            this.panel2.Controls.Add(this.lblLatestVersion);
            this.panel2.Location = new System.Drawing.Point(4, 4);
            this.panel2.Name = "panel2";
            this.panel2.Size = new System.Drawing.Size(1016, 28);
            this.panel2.TabIndex = 18;
            // 
            // lb_Ip
            // 
            this.lb_Ip.AutoSize = true;
            this.lb_Ip.Font = new System.Drawing.Font("Microsoft Sans Serif", 8F);
            this.lb_Ip.ForeColor = System.Drawing.Color.White;
            this.lb_Ip.Location = new System.Drawing.Point(590, 7);
            this.lb_Ip.Name = "lb_Ip";
            this.lb_Ip.Size = new System.Drawing.Size(20, 13);
            this.lb_Ip.TabIndex = 18;
            this.lb_Ip.Text = "IP:";
            this.lb_Ip.Visible = false;
            // 
            // lb_User
            // 
            this.lb_User.AutoSize = true;
            this.lb_User.Font = new System.Drawing.Font("Microsoft Sans Serif", 8F);
            this.lb_User.ForeColor = System.Drawing.Color.White;
            this.lb_User.Location = new System.Drawing.Point(382, 7);
            this.lb_User.Name = "lb_User";
            this.lb_User.Size = new System.Drawing.Size(32, 13);
            this.lb_User.TabIndex = 17;
            this.lb_User.Text = "User:";
            this.lb_User.Visible = false;
            // 
            // ExitButton
            // 
            this.ExitButton.BackgroundImage = global::PBLauncher.Properties.Resources.exit;
            this.ExitButton.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.ExitButton.Location = new System.Drawing.Point(985, 1);
            this.ExitButton.Name = "ExitButton";
            this.ExitButton.Size = new System.Drawing.Size(25, 25);
            this.ExitButton.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.ExitButton.TabIndex = 14;
            this.ExitButton.TabStop = false;
            this.ExitButton.Click += new System.EventHandler(this.btnExit_Click);
            // 
            // ConfigButton
            // 
            this.ConfigButton.BackgroundImage = global::PBLauncher.Properties.Resources.config;
            this.ConfigButton.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.ConfigButton.Location = new System.Drawing.Point(923, 1);
            this.ConfigButton.Name = "ConfigButton";
            this.ConfigButton.Size = new System.Drawing.Size(25, 25);
            this.ConfigButton.TabIndex = 15;
            this.ConfigButton.TabStop = false;
            this.ConfigButton.Click += new System.EventHandler(this.ConfigButton_Click);
            // 
            // MinimizeButton
            // 
            this.MinimizeButton.BackgroundImage = global::PBLauncher.Properties.Resources.minim;
            this.MinimizeButton.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.MinimizeButton.Location = new System.Drawing.Point(954, 1);
            this.MinimizeButton.Name = "MinimizeButton";
            this.MinimizeButton.Size = new System.Drawing.Size(25, 25);
            this.MinimizeButton.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.MinimizeButton.TabIndex = 16;
            this.MinimizeButton.TabStop = false;
            this.MinimizeButton.Click += new System.EventHandler(this.MinimizeButton_Click);
            // 
            // chromiumWebBrowser1
            // 
            this.chromiumWebBrowser1.ActivateBrowserOnCreation = false;
            this.chromiumWebBrowser1.Location = new System.Drawing.Point(4, 38);
            this.chromiumWebBrowser1.Name = "chromiumWebBrowser1";
            this.chromiumWebBrowser1.Size = new System.Drawing.Size(1016, 540);
            this.chromiumWebBrowser1.TabIndex = 12;
            // 
            // btn_login
            // 
            this.btn_login.BackColor = System.Drawing.Color.Transparent;
            this.btn_login.Image = global::PBLauncher.Properties.Resources.login;
            this.btn_login.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.btn_login.Location = new System.Drawing.Point(817, 589);
            this.btn_login.Name = "btn_login";
            this.btn_login.Size = new System.Drawing.Size(179, 105);
            this.btn_login.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.btn_login.TabIndex = 23;
            this.btn_login.TabStop = false;
            this.btn_login.Click += new System.EventHandler(this.btn_login_Click_1);
            // 
            // StartGameBtn
            // 
            this.StartGameBtn.Image = global::PBLauncher.Properties.Resources.Bitmap172;
            this.StartGameBtn.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.StartGameBtn.Location = new System.Drawing.Point(817, 589);
            this.StartGameBtn.Name = "StartGameBtn";
            this.StartGameBtn.Size = new System.Drawing.Size(179, 104);
            this.StartGameBtn.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.StartGameBtn.TabIndex = 22;
            this.StartGameBtn.TabStop = false;
            this.StartGameBtn.Visible = false;
            this.StartGameBtn.Click += new System.EventHandler(this.StartGameBtn_Click);
            // 
            // btnCheck
            // 
            this.btnCheck.BackColor = System.Drawing.Color.Transparent;
            this.btnCheck.Image = global::PBLauncher.Properties.Resources.Bitmap166;
            this.btnCheck.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.btnCheck.Location = new System.Drawing.Point(665, 589);
            this.btnCheck.Name = "btnCheck";
            this.btnCheck.Size = new System.Drawing.Size(126, 105);
            this.btnCheck.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.btnCheck.TabIndex = 13;
            this.btnCheck.TabStop = false;
            this.btnCheck.Visible = false;
            this.btnCheck.Click += new System.EventHandler(this.btnCheck_Click);
            // 
            // LauncherForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.SystemColors.WindowFrame;
            this.BackgroundImage = global::PBLauncher.Properties.Resources.BGLabel;
            this.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.ClientSize = new System.Drawing.Size(1024, 700);
            this.Controls.Add(this.btn_login);
            this.Controls.Add(this.chromiumWebBrowser1);
            this.Controls.Add(this.StartGameBtn);
            this.Controls.Add(this.panel2);
            this.Controls.Add(this.chkRememberSession);
            this.Controls.Add(this.textBox_pass);
            this.Controls.Add(this.lblStatus);
            this.Controls.Add(this.label_pass);
            this.Controls.Add(this.label_user);
            this.Controls.Add(this.lblDownload);
            this.Controls.Add(this.textBox_user);
            this.Controls.Add(this.lblExtract);
            this.Controls.Add(this.progressBarDownload);
            this.Controls.Add(this.progressBarExtract);
            this.Controls.Add(this.btnCheck);
            this.DoubleBuffered = true;
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "LauncherForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Game Launcher";
            this.panel2.ResumeLayout(false);
            this.panel2.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.ExitButton)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.ConfigButton)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.MinimizeButton)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.btn_login)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.StartGameBtn)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.btnCheck)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion
        private System.Windows.Forms.Label lblStatus;
        private System.Windows.Forms.ProgressBar progressBarDownload;
        private System.Windows.Forms.ProgressBar progressBarExtract;
        private System.Windows.Forms.Label lblExtract;
        private System.Windows.Forms.Label lblDownload;
        private System.Windows.Forms.Label lblLatestVersion;
        private System.Windows.Forms.PictureBox btnCheck;
        private System.Windows.Forms.PictureBox ExitButton;
        private System.Windows.Forms.PictureBox ConfigButton;
        private System.Windows.Forms.PictureBox MinimizeButton;
        private System.Windows.Forms.Panel panel2;
        private System.Windows.Forms.TextBox textBox_user;
        private System.Windows.Forms.TextBox textBox_pass;
        private System.Windows.Forms.Label label_pass;
        private System.Windows.Forms.Label label_user;
        private System.Windows.Forms.CheckBox chkRememberSession;
        private System.Windows.Forms.Label lb_User;
        private System.Windows.Forms.Label lb_Ip;
        private System.Windows.Forms.PictureBox StartGameBtn;
        private System.Windows.Forms.Timer PBDetect;
        private System.Windows.Forms.PictureBox btn_login;
        public CefSharp.WinForms.ChromiumWebBrowser chromiumWebBrowser1;
    }
}

