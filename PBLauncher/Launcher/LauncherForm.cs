using System;
using System.IO;
using System.Linq;
using System.Net;
using Newtonsoft.Json;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Diagnostics;
using System.Text;
using CefSharp;
using CefSharp.WinForms;
using System.Security.Cryptography;
using System.Collections.Generic;
using System.Threading;
using PBLauncher.Properties;
using CefSharp.DevTools.Network;
using PBLauncher.Models;
using PBLauncher.Services;
using System.Net.Http;
using System.Security.Policy;
using System.Drawing;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;
using Microsoft.Win32;
using System.Runtime.Remoting.Contexts;
using static System.Windows.Forms.VisualStyles.VisualStyleElement.Window;
using System.Runtime.InteropServices;
using System.IO.Compression;
using CefSharp.DevTools.CSS;

namespace PBLauncher
{
    public partial class LauncherForm : Form
    {
        [DllImport("user32.dll")]
        private static extern int SendMessage(IntPtr hWnd, int Msg, int wParam, int lParam);

        [DllImport("user32.dll")]
        private static extern bool ReleaseCapture();

        // Constantes para el movimiento
        private const int WM_NCLBUTTONDOWN = 0xA1;
        private const int HTCAPTION = 0x2;

        private SystemStatusService statusService;
        private LauncherStateManager stateManager;
        private SocketIOService socketIOService; // ✅ NUEVO: Servicio SocketIO
        private System.Windows.Forms.Timer systemCheckTimer;
        private System.Windows.Forms.Timer heartbeatTimer; // ✅ NUEVO: Timer para heartbeat

        // Configuración
        private SystemConfig systemConfig;
        private UserData userData;
        private const string ConfigFile = "./config.jg";
        private const string UpdateFile = "/update";
        private const string FileHashesFile = "file_hashes.jg";
        private const string UpdatesPath = "updates/";
        private const string LogFile = "launcher.log";
        private string Urls = "http://192.168.18.31:5000/api/";
        private string UrbBanner = "http://192.168.18.31:5000/api/banner/live";
        Axios axios = new Axios("http://192.168.18.31:5000/api");

        // Variables de estado
        private CancellationTokenSource cancellationTokenSource;
        private readonly WebClient GameUpdate = new WebClient();
        private bool isUpdating = false;
        private bool isMaintenanceMode = false;
        private bool socketIOEnabled = true; // ✅ NUEVO: Flag para habilitar/deshabilitar SocketIO

        // Headers para archivos DTA
        public byte[] Header_lccnct;
        public byte[] Header_sl;
        private LoginService _loginService;

        private bool isCheckingLauncherUpdate = false;
        private readonly object launcherUpdateLock = new object();
        private DateTime lastLauncherUpdateCheck = DateTime.MinValue;
        public class Config
        {
            public string InstalledVersion { get; set; }
            public DateTime LastUpdateCheck { get; set; }
            public Dictionary<string, string> FileHashes { get; set; } = new Dictionary<string, string>();
        }

        public LauncherForm()
        {
            InitializeComponent();
            InitializeLauncher();
            SetupDraggable();
        }
        public static string Gen5(string text)
        {
            using (var hmacMD5 = new HMACMD5(Encoding.UTF8.GetBytes("/x!a@r-$r%an¨.&e&+f*f(f(a)")))
            {
                byte[] data = hmacMD5.ComputeHash(Encoding.UTF8.GetBytes(text));
                StringBuilder sBuilder = new StringBuilder();
                for (int i = 0; i < data.Length; i++)
                    sBuilder.Append(data[i].ToString("x2"));
                return sBuilder.ToString();
            }
        }
        /// <summary>
        /// Crear panel de título personalizado
        /// </summary>

        /// <summary>
        /// Configurar arrastre para múltiples controles
        /// </summary>
        private void SetupDraggable()
        {
            // Hacer el panel de título arrastrable
            MakeDraggable(panel2);

            // También hacer arrastrable cualquier label en el panel
            foreach (Control control in panel2.Controls)
            {
                if (control is Label)
                {
                    MakeDraggable(control);
                }
            }
        }

        /// <summary>
        /// Hacer un control específico arrastrable
        /// </summary>
        private void MakeDraggable(Control control)
        {
            control.MouseDown += (sender, e) =>
            {
                if (e.Button == MouseButtons.Left)
                {
                    ReleaseCapture();
                    SendMessage(this.Handle, WM_NCLBUTTONDOWN, HTCAPTION, 0);
                }
            };
        }
        private async void InitializeLauncher()
        {
            try
            {
                LogMessage("Iniciando launcher principal...");

                // Inicializar servicios
                statusService = new SystemStatusService(Urls);
                stateManager = new LauncherStateManager();

                userData = new UserData
                {
                    PlayerId = 0, // Asignar valores predeterminados o iniciales
                    Username = string.Empty,
                    Token = string.Empty,
                    IpAddress = string.Empty
                };

                // Configurar eventos del gestor de estados
                stateManager.StateChanged += OnLauncherStateChanged;
                stateManager.MessageChanged += OnLauncherMessageChanged;

                // Configuración inicial de UI
                btnCheck.Enabled = false;

                cancellationTokenSource = new CancellationTokenSource();

                // Realizar detección completa
                var result = await HttpDebuggerDetector.DetectHttpDebuggersAsync();

                // Mostrar resultado
                HttpDebuggerDetector.ShowDetectionResultWithWhitelistOption(result, this);

                // Si hay procesos críticos, no permitir continuar
                if (result.OverallThreatLevel >= HttpDebuggerDetector.DetectionLevel.High)
                {
                    MessageBox.Show("❌ No se puede continuar con herramientas de debugging activas");
                    //lb_loading.ForeColor = Color.Red;
                }

                // Limpiar archivos temporales
                CleanupTempFiles();

                // Cargar configuración del sistema
                await LoadSystemConfiguration();

                // ✅ NUEVO: Inicializar SocketIO
                await InitializeSocketIO();

                // Configurar timer para verificaciones periódicas (como fallback)
                SetupSystemCheckTimer();

                // ✅ NUEVO: Configurar timer para heartbeat
                SetupHeartbeatTimer();

                // Cargar banner dinámico
                LoadDynamicBanner();

                // Inicializar estado del launcher
                await InitializeSystemStatus();

                LogMessage("Launcher inicializado exitosamente");
            }
            catch (Exception ex)
            {
                LogMessage($"Error en inicialización del launcher: {ex.Message}");
                stateManager.SetErrorState($"Error de inicialización: {ex.Message}");
            }
        }

        // ✅ NUEVO: Inicializar SocketIO
        private async Task InitializeSocketIO()
        {
            if (!socketIOEnabled) return;

            try
            {
                LogMessage("Inicializando SocketIO...");

                // Obtener URL base del servidor
                var baseUrl = Urls.Replace("/api/", "");
                socketIOService = new SocketIOService(baseUrl);

                // Configurar eventos de SocketIO
                SetupSocketIOEvents();

                // Intentar conectar
                bool connected = await socketIOService.ConnectAsync();
                
                if (connected)
                {
                    LogMessage("✅ SocketIO conectado exitosamente");
                    UpdateSocketIOStatus("Conectado en tiempo real");
                }
                else
                {
                    LogMessage("⚠️ No se pudo conectar a SocketIO, usando polling como fallback");
                    UpdateSocketIOStatus("Modo polling (sin tiempo real)");
                }
            }
            catch (Exception ex)
            {
                LogMessage($"Error inicializando SocketIO: {ex.Message}");
                UpdateSocketIOStatus("Error de conexión en tiempo real");
                // Continuar sin SocketIO
            }
        }

        // ✅ NUEVO: Configurar eventos de SocketIO
        private void SetupSocketIOEvents()
        {
            if (socketIOService == null) return;

            socketIOService.ConnectionStatusChanged += OnSocketIOConnectionChanged;
            socketIOService.SystemStatusChanged += OnSocketIOSystemStatusChanged;
            socketIOService.MaintenanceModeChanged += OnSocketIOMaintenanceModeChanged; // ✅ Esta línea ya está bien
            socketIOService.NewGameVersionAvailable += OnSocketIONewGameVersionAvailable;
            socketIOService.LauncherUpdateAvailable += OnSocketIOLauncherUpdateAvailable;
        }

        // ✅ NUEVO: Configurar timer para heartbeat
        private void SetupHeartbeatTimer()
        {
            try
            {
                heartbeatTimer = new System.Windows.Forms.Timer
                {
                    Interval = 30000 // 30 segundos
                };
                heartbeatTimer.Tick += async (sender, e) => await SendHeartbeat();
                heartbeatTimer.Start();

                LogMessage("Timer de heartbeat configurado");
            }
            catch (Exception ex)
            {
                LogMessage($"Error configurando timer de heartbeat: {ex.Message}");
            }
        }

        // ✅ NUEVO: Enviar heartbeat
        private async Task SendHeartbeat()
        {
            try
            {
                if (socketIOService?.IsConnected == true)
                {
                    // Intentar enviar heartbeat
                    await socketIOService.SendHeartbeat();
                    LogMessage("💓 Heartbeat enviado exitosamente");

                    // ✅ NUEVO: Verificar que el servidor responda con un timeout
                    var heartbeatSuccess = await VerifyServerResponse();

                    if (!heartbeatSuccess)
                    {
                        LogMessage("⚠️ El servidor no respondió al heartbeat - reconectando...");
                        await ReconnectSocketIO();
                    }
                }
                else
                {
                    LogMessage("❌ SocketIO no conectado - intentando reconectar...");
                    await ReconnectSocketIO();
                }
            }
            catch (Exception ex)
            {
                LogMessage($"❌ Error en heartbeat: {ex.Message} - reconectando...");
                await ReconnectSocketIO();
            }
        }
        private async Task ReconnectSocketIO()
        {
            try
            {
                LogMessage("🔄 Iniciando reconexión de SocketIO...");

                // Marcar como desconectado
                UpdateSocketIOStatus("Reconectando...");

                // Desconectar y limpiar
                if (socketIOService != null)
                {
                    await socketIOService.DisconnectAsync();
                }

                // Crear nueva instancia
                var baseUrl = Urls.Replace("/api/", "");
                socketIOService = new SocketIOService(baseUrl);
                SetupSocketIOEvents();

                // Intentar reconectar
                bool connected = await socketIOService.ConnectAsync();

                if (connected)
                {
                    LogMessage("✅ SocketIO reconectado exitosamente");
                    UpdateSocketIOStatus("Reconectado exitosamente");

                    // Forzar recarga de datos
                    await Task.Delay(1000);
                    await InitializeSystemStatus();
                }
                else
                {
                    LogMessage("❌ Falló la reconexión de SocketIO");
                    UpdateSocketIOStatus("Error de reconexión - usando polling");

                    // Reactivar timer más frecuente como fallback
                    if (systemCheckTimer != null)
                    {
                        systemCheckTimer.Interval = (systemConfig?.UpdateCheckInterval ?? 300) * 1000;
                    }
                }
            }
            catch (Exception ex)
            {
                LogMessage($"Error en reconexión: {ex.Message}");
                UpdateSocketIOStatus("Error de reconexión");
            }
        }
        private async Task<bool> VerifyServerResponse()
        {
            try
            {
                bool responseReceived = false;
                var timeoutTask = Task.Delay(5000); // 5 segundos timeout

                // Enviar ping y esperar pong
                EventHandler<string> tempHandler = (s, e) => responseReceived = true;
                socketIOService.ConnectionStatusChanged += tempHandler;

                await socketIOService.Ping();

                // Esperar respuesta o timeout
                var completedTask = await Task.WhenAny(
                    Task.Run(async () => {
                        while (!responseReceived && !timeoutTask.IsCompleted)
                        {
                            await Task.Delay(100);
                        }
                        return responseReceived;
                    }),
                    timeoutTask
                );

                socketIOService.ConnectionStatusChanged -= tempHandler;

                if (completedTask == timeoutTask)
                {
                    LogMessage("⏰ Timeout esperando respuesta del servidor");
                    return false;
                }

                return responseReceived;
            }
            catch (Exception ex)
            {
                LogMessage($"Error verificando respuesta del servidor: {ex.Message}");
                return false;
            }
        }

        // ✅ NUEVO: Event handlers de SocketIO
        private void OnSocketIOConnectionChanged(object sender, string status)
        {
            this.Invoke((MethodInvoker)delegate
            {
                UpdateSocketIOStatus(status);
            });
        }

        private void OnSocketIOSystemStatusChanged(object sender, SystemStatus status)
        {
            this.Invoke((MethodInvoker)delegate
            {
                LogMessage($"📊 Estado del sistema actualizado vía SocketIO: {status.Status}");
                stateManager.UpdateSystemStatus(status);
                RefreshDynamicBanner();
                Task.Run(async () => await InitializeSystemStatus());
                // Actualizar información del sistema en UI
                if (!string.IsNullOrEmpty(status.LatestGameVersion))
                {
                    SafeUpdateLabel(lblLatestVersion, status.LatestGameVersion);
                    Task.Delay(100);
                }
            });
        }
        // ✅ REEMPLAZAR este método en LauncherForm.cs:
        // Update the event handler signature to match the delegate 'EventHandler<string>'
        // Update the event handler to match the delegate 'EventHandler<MaintenanceModeData>'
        private void OnSocketIOMaintenanceModeChanged(object sender, MaintenanceModeData maintenanceData)
        {
            this.Invoke((MethodInvoker)delegate
            {
                LogMessage($"🔧 Mantenimiento via SocketIO - Data: {JsonConvert.SerializeObject(maintenanceData)}");

                if (maintenanceData == null)
                {
                    LogMessage("Error: Datos de mantenimiento no válidos.");
                    return;
                }

                // Existing logic for handling maintenance mode
                if (maintenanceData.Enabled && !isMaintenanceMode)
                {
                    isMaintenanceMode = true;
                    ShowMaintenanceNotification($"🔧 MANTENIMIENTO ACTIVADO\n\n{maintenanceData.Message}");

                    stateManager.UpdateSystemStatus(new SystemStatus
                    {
                        Status = "maintenance",
                        MaintenanceMode = true,
                        MaintenanceMessage = maintenanceData.Message
                    });
                }
                else if (!maintenanceData.Enabled && isMaintenanceMode)
                {
                    isMaintenanceMode = false;
                    ShowSystemAvailableNotification();

                    _ = Task.Run(async () => await InitializeSystemStatus());
                }
                else if (!maintenanceData.Enabled && !string.IsNullOrEmpty(maintenanceData.Message))
                {
                    ShowTestMaintenanceNotification(maintenanceData.Message);
                }

                LogMessage($"🔧 Estado mantenimiento actualizado - isMaintenanceMode: {isMaintenanceMode}");
            });
        }



        // ✅ NUEVO MÉTODO: Mostrar notificación de test de mantenimiento
        private void ShowTestMaintenanceNotification(string message)
        {
            try
            {
                var result = MessageBox.Show(
                    $"🧪 TEST DE MANTENIMIENTO RECIBIDO\n\n{message}\n\nEsto es una prueba desde el panel admin.\nEl sistema sigue funcionando normalmente.",
                    "Test de Mantenimiento",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Information
                );

                LogMessage($"🧪 Notificación de test de mantenimiento mostrada: {message}");
            }
            catch (Exception ex)
            {
                LogMessage($"Error mostrando notificación de test: {ex.Message}");
            }
        }

        // ✅ MÉTODO ACTUALIZADO: Mostrar notificación de mantenimiento real
        private void ShowMaintenanceNotification(string message)
        {
            try
            {
                var result = MessageBox.Show(
                    $"{message}\n\nEl launcher se deshabilitará temporalmente hasta que el mantenimiento termine.",
                    "Modo Mantenimiento Activado",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Warning  // ✅ CAMBIADO: Warning en lugar de Information para mantenimiento real
                );

                LogMessage($"🔧 Notificación de mantenimiento real mostrada: {message}");
            }
            catch (Exception ex)
            {
                LogMessage($"Error mostrando notificación de mantenimiento: {ex.Message}");
            }
        }

        private void OnSocketIONewGameVersionAvailable(object sender, string version)
        {
            this.Invoke((MethodInvoker)delegate
            {
                LogMessage($"🎮 Nueva versión del juego disponible vía SocketIO: {version}");
                
                // Mostrar notificación de nueva versión
                var result = MessageBox.Show(
                    $"🎮 Nueva versión del juego disponible: {version}\n\n¿Desea actualizar ahora?",
                    "Nueva Actualización Disponible",
                    MessageBoxButtons.YesNo,
                    MessageBoxIcon.Information
                );
                
                if (result == DialogResult.Yes)
                {
                    _ = Task.Run(async () => await VerifyAndUpdateAsync());
                }
            });
        }

        private void OnSocketIOLauncherUpdateAvailable(object sender, LauncherVersionInfo launcherInfo)
        {
            this.Invoke((MethodInvoker)delegate
            {
                LogMessage($"🚀 Nueva versión del launcher disponible vía SocketIO: {launcherInfo.Version}");
                
                // Mostrar notificación de actualización del launcher
                var result = MessageBox.Show(
                    $"🚀 Nueva versión del launcher disponible: {launcherInfo.Version}\n\nVersión actual: {Application.ProductVersion}\n\n¿Desea actualizar ahora?",
                    "Actualización del Launcher",
                    MessageBoxButtons.YesNo,
                    MessageBoxIcon.Information
                );
                
                if (result == DialogResult.Yes)
                {
                    _ = Task.Run(async () => await UpdateLauncher(launcherInfo));
                }
            });
        }

        // ✅ NUEVO: Mostrar notificación de noticias importantes
        private void ShowNewsNotification(NewsMessage news)
        {
            try
            {
                // Solo mostrar noticias de alta prioridad
                if (news.Priority <= 5) return;
                
                var result = MessageBox.Show(
                    $"{news.Message}",
                    $"📰 {news.Type}",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Information
                );
            }
            catch (Exception ex)
            {
                LogMessage($"Error mostrando notificación de noticias: {ex.Message}");
            }
        }

        // ✅ NUEVO: Actualizar estado de SocketIO en UI
        private void UpdateSocketIOStatus(string status)
        {
            try
            {
                // Actualizar algún indicador en la UI (puedes agregar un label)
                // lblSocketIOStatus.Text = status;
                LogMessage($"Estado SocketIO: {status}");
            }
            catch (Exception ex)
            {
                LogMessage($"Error actualizando estado SocketIO: {ex.Message}");
            }
        }

        // ✅ NUEVO: Actualizar launcher vía SocketIO
        private async Task UpdateLauncher(LauncherVersionInfo launcherInfo)
        {
            try
            {
                LogMessage($"Iniciando actualización del launcher a {launcherInfo.Version}");
                
                var client = new WebClient();
                string updaterPath = Path.Combine(Application.StartupPath, "LauncherUpdater.exe");
                
                await client.DownloadFileTaskAsync($"{Urls}/LauncherUpdater.exe", updaterPath);
                
                Process.Start(updaterPath, $"\"{Urls}\" \"{Application.ExecutablePath}\" \"{launcherInfo.FileName}\"");
                Application.Exit();
            }
            catch (Exception ex)
            {
                LogMessage($"Error actualizando launcher: {ex.Message}");
                MessageBox.Show($"Error actualizando launcher: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private async Task LoadSystemConfiguration()
        {
            try
            {
                LogMessage("Cargando configuración del sistema...");
                systemConfig = await statusService.GetSystemConfigAsync();

                // Aplicar configuración
                if (systemConfig != null)
                {
                    // Actualizar URLs si es necesario
                    if (!string.IsNullOrEmpty(systemConfig.LauncherBaseUrl))
                    {
                        // Actualizar URLs base
                        var baseUrl = systemConfig.LauncherBaseUrl.TrimEnd('/');
                        UrbBanner = $"{baseUrl}/api/banner/live";
                    }

                    LogMessage($"Configuración cargada - AutoUpdate: {systemConfig.AutoUpdateEnabled}, SSL: {systemConfig.ForceSsl}");
                }
            }
            catch (Exception ex)
            {
                LogMessage($"Error cargando configuración: {ex.Message}");
                // Usar configuración por defecto
                systemConfig = new SystemConfig
                {
                    AutoUpdateEnabled = true,
                    UpdateCheckInterval = 300,
                    MaxDownloadRetries = 3,
                    ConnectionTimeout = 30,
                    ForceSsl = false
                };
            }
        }

        private void SetupSystemCheckTimer()
        {
            try
            {
                int interval = systemConfig?.UpdateCheckInterval ?? 300;
                systemCheckTimer = new System.Windows.Forms.Timer
                {
                    // ✅ MODIFICADO: Reducir frecuencia si SocketIO está conectado
                    Interval = (socketIOService?.IsConnected == true) ? interval * 2000 : interval * 1000
                };
                systemCheckTimer.Tick += async (sender, e) => await PeriodicSystemCheck();
                systemCheckTimer.Start();

                LogMessage($"Timer de verificación configurado para {interval} segundos (SocketIO: {socketIOService?.IsConnected})");
            }
            catch (Exception ex)
            {
                LogMessage($"Error configurando timer: {ex.Message}");
            }
        }

        private void LoadDynamicBanner()
        {
            try
            {
                if (chromiumWebBrowser1 != null)
                {
                    chromiumWebBrowser1.Load(UrbBanner);
                    LogMessage($"Banner cargado desde: {UrbBanner}");
                }
            }
            catch (Exception ex)
            {
                LogMessage($"Error cargando banner: {ex.Message}");
            }
        }
        private void RefreshDynamicBanner()
        {
            try
            {
                if (chromiumWebBrowser1 != null)
                {
                    chromiumWebBrowser1.Reload();
                }
            }
            catch (Exception ex)
            {
                LogMessage($"Error cargando banner: {ex.Message}");
            }
        }

        private async Task InitializeSystemStatus()
        {
            try
            {
                LogMessage("Verificando estado inicial del sistema...");

                var status = await statusService.GetSystemStatusAsync(true);
                stateManager.UpdateSystemStatus(status);
                stateManager.UpdateSystemConfig(systemConfig);

                // Si el sistema está disponible, proceder con verificaciones
                if (stateManager.CanCheckUpdates())
                {
                    await CheckLauncherUpdate();
                    await VerifyAndUpdateAsync();
                }
            }
            catch (Exception ex)
            {
                LogMessage($"Error en verificación inicial: {ex.Message}");
                stateManager.SetErrorState($"Error de conectividad: {ex.Message}");
            }
        }

        private async Task PeriodicSystemCheck()
        {
            try
            {
                if (isUpdating) return; // No verificar si está actualizando

                // ✅ MODIFICADO: Solo hacer polling si SocketIO no está conectado
                if (socketIOService?.IsConnected != true)
                {
                    var status = await statusService.GetSystemStatusAsync(true);
                    stateManager.UpdateSystemStatus(status);

                    // Verificar si entró en modo mantenimiento
                    if (status.MaintenanceMode && !isMaintenanceMode)
                    {
                        isMaintenanceMode = true;
                        ShowMaintenanceNotification(status.MaintenanceMessage);
                    }
                    else if (!status.MaintenanceMode && isMaintenanceMode)
                    {
                        isMaintenanceMode = false;
                        ShowSystemAvailableNotification();
                    }
                }
                else
                {
                    // Si SocketIO está conectado, solo hacer ping ocasional
                    await socketIOService.Ping();
                }
            }
            catch (Exception ex)
            {
                LogMessage($"Error en verificación periódica: {ex.Message}");
            }
        }

        private void OnLauncherStateChanged(object sender, LauncherState state)
        {
            this.Invoke((MethodInvoker)delegate
            {
                UpdateUIForState(state);
            });
        }

        private void OnLauncherMessageChanged(object sender, string message)
        {
            this.Invoke((MethodInvoker)delegate
            {
                SafeUpdateLabel(lblStatus, message);
                Task.Delay(100);
            });
        }

        private void UpdateUIForState(LauncherState state)
        {
            try
            {
                switch (state)
                {
                    case LauncherState.Loading:
                        btnCheck.Enabled = false;
                        break;

                    case LauncherState.Ready:;
                        btnCheck.Enabled = true;
                        btn_login.Enabled = true;
                        label_pass.Enabled = true;
                        label_user.Enabled = true;
                        SafeUpdateLabel(lblStatus, "Listo para jugar");
                        progressBarDownload.Value = 100;
                        progressBarExtract.Value = 100;
                        
                        SafeUpdateLabel(lblDownload, "100%");
                        SafeUpdateLabel(lblExtract, "100%");
                        InitializeLoginService();
                        break;

                    case LauncherState.Updating:
                        btnCheck.Enabled = false;;
                        break;

                    case LauncherState.Maintenance:
                        btnCheck.Enabled = false;
                        btn_login.Enabled = false;
                        label_pass.Enabled = false;
                        label_user.Enabled = false;
                        
                        ShowMaintenanceMode();
                        break;

                    case LauncherState.Error:
                        btnCheck.Enabled = true; // Permitir reintentar
                        break;

                    case LauncherState.Banned:
                        btnCheck.Enabled = false;
                        SafeUpdateLabel(lblStatus, stateManager.StateMessage);
                        break;
                }
            }
            catch (Exception ex)
            {
                LogMessage($"Error actualizando UI: {ex.Message}");
            }
        }

        private void ShowMaintenanceMode()
        {
            try
            {
                // Cambiar banner a modo mantenimiento si es posible
                if (chromiumWebBrowser1 != null)
                {
                    chromiumWebBrowser1.ExecuteScriptAsync("window.setMaintenanceMode && window.setMaintenanceMode(true, '" + stateManager.StateMessage + "')");
                }

                SafeUpdateLabel(lblStatus, stateManager.StateMessage);
                LogMessage("Interfaz actualizada para modo mantenimiento");
            }
            catch (Exception ex)
            {
                LogMessage($"Error mostrando modo mantenimiento: {ex.Message}");
            }
        }

        private void ShowSystemAvailableNotification()
        {
            this.Invoke((MethodInvoker)delegate
            {
                MessageBox.Show(
                    "✅ El sistema está nuevamente disponible.\n\nPuedes continuar usando el launcher normalmente.",
                    "Sistema Disponible",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Information
                );

                // Actualizar banner
                if (chromiumWebBrowser1 != null)
                {
                    chromiumWebBrowser1.ExecuteScriptAsync("window.setMaintenanceMode && window.setMaintenanceMode(false)");
                }
            });
        }

        #region MD5 Verification
        private string CalculateMD5(string filePath)
        {
            try
            {
                using (var md5 = MD5.Create())
                {
                    using (var stream = File.OpenRead(filePath))
                    {
                        var hash = md5.ComputeHash(stream);
                        return BitConverter.ToString(hash).Replace("-", "").ToLowerInvariant();
                    }
                }
            }
            catch (Exception ex)
            {
                LogMessage($"Error calculando MD5 para {filePath}: {ex.Message}");
                return null;
            }
        }

        private async Task<bool> VerifyFileIntegrity(string filePath, string expectedMD5)
        {
            // 🎯 FIX: Si el archivo no existe, siempre es inválido
            if (!File.Exists(filePath))
            {
                LogMessage($"❌ Archivo físico no existe: {Path.GetFileName(filePath)}");
                return false;
            }

            // 🎯 FIX: Si no hay MD5 esperado, no podemos verificar
            if (string.IsNullOrEmpty(expectedMD5) || expectedMD5 == "null")
            {
                LogMessage($"⚠️ No hay MD5 para verificar: {Path.GetFileName(filePath)}");
                return false; // ← CAMBIO: Considerar como inválido
            }

            return await Task.Run(() =>
            {
                string actualMD5 = CalculateMD5(filePath);
                bool isValid = actualMD5?.Equals(expectedMD5, StringComparison.OrdinalIgnoreCase) == true;

                if (!isValid)
                {
                    LogMessage($"❌ MD5 no coincide para {Path.GetFileName(filePath)}. Esperado: {expectedMD5}, Actual: {actualMD5}");
                }
                else
                {
                    LogMessage($"✅ MD5 verificado para {Path.GetFileName(filePath)}");
                }

                return isValid;
            });
        }

        private async Task<List<string>> VerifyGameFiles()
        {
            var corruptedFiles = new List<string>();

            try
            {
                SafeUpdateLabel(lblStatus, "Obteniendo lista de archivos para verificar...");
                await Task.Delay(100);
                LogMessage("🔍 Iniciando verificación de integridad con nueva API");

                var repairFiles = await FetchRepairFilesAsync();

                if (repairFiles == null || !repairFiles.Success)
                {
                    LogMessage("❌ Error obteniendo lista de archivos de reparación");
                    SafeUpdateLabel(lblStatus, "Error obteniendo lista de archivos");
                    return corruptedFiles;
                }

                if (repairFiles.TotalFiles == 0)
                {
                    LogMessage("📋 No hay archivos para verificar");
                    SafeUpdateLabel(lblStatus, "No hay archivos para verificar");
                    return corruptedFiles;
                }

                LogMessage($"📋 Lista obtenida: {repairFiles.TotalFiles} archivos para verificar");
                SafeUpdateLabel(lblStatus, $"Verificando {repairFiles.TotalFiles} archivos...");

                SafeUpdateProgressBar(progressBarDownload, pb => pb.Value = 0);
                SafeUpdateProgressBar(progressBarExtract, pb => pb.Value = 0);

                int currentFile = 0;

                foreach (var fileInfo in repairFiles.Files)
                {
                    currentFile++;

                    int percentage = (int)((double)currentFile / repairFiles.TotalFiles * 100);
                    SafeUpdateProgressBar(progressBarDownload, pb => pb.Value = percentage);

                    SafeUpdateLabel(lblStatus, $"Verificando {currentFile}/{repairFiles.TotalFiles}: {fileInfo.FileName}");
                    LogMessage($"🔍 Verificando {currentFile}/{repairFiles.TotalFiles}: {fileInfo.FileName}");

                    if (string.IsNullOrWhiteSpace(fileInfo.FileName))
                    {
                        LogMessage("⚠️ Archivo con nombre vacío, saltando...");
                        continue;
                    }

                    string localPath = Path.Combine("./", fileInfo.RelativePath);
                    if (!File.Exists(localPath))
                    {
                        LogMessage($"❌ Archivo físico faltante detectado: {fileInfo.FileName}");
                        corruptedFiles.Add(fileInfo.FileName);
                        continue; // Saltar verificación API si sabemos que falta
                    }

                    var verificationResult = await VerifySpecificFileAsync(fileInfo.FileName);

                    if (verificationResult != null && verificationResult.Success)
                    {
                        bool needsRepair = false;
                        string reason = "";

                        if (!verificationResult.FileExists)
                        {
                            needsRepair = true;
                            reason = "archivo faltante";
                        }
                        else if (!verificationResult.MD5Match)
                        {
                            needsRepair = true;
                            reason = "MD5 no coincide";
                        }
                        else if (verificationResult.IntegrityStatus == "corrupted")
                        {
                            needsRepair = true;
                            reason = "archivo corrupto";
                        }
                        else if (verificationResult.IntegrityStatus == "file_missing")
                        {
                            needsRepair = true;
                            reason = "archivo faltante en servidor";
                        }

                        if (needsRepair)
                        {
                            corruptedFiles.Add(fileInfo.FileName);
                            LogMessage($"❌ Archivo necesita reparación: {fileInfo.FileName} ({reason})");
                        }
                        else
                        {
                            LogMessage($"✅ Archivo verificado OK: {fileInfo.FileName}");
                        }
                    }
                    else
                    {
                        corruptedFiles.Add(fileInfo.FileName);
                        string errorMsg = verificationResult?.Error ?? "error desconocido";
                        LogMessage($"⚠️ No se pudo verificar: {fileInfo.FileName} ({errorMsg}), marcando para reparación");
                    }

                    await Task.Delay(50);
                }

                SafeUpdateProgressBar(progressBarDownload, pb => pb.Value = 100);

                LogMessage($"🏁 Verificación completada. {corruptedFiles.Count} de {repairFiles.TotalFiles} archivos requieren reparación");

                if (corruptedFiles.Count > 0)
                {
                    SafeUpdateLabel(lblStatus, $"Verificación completa: {corruptedFiles.Count} archivos necesitan reparación");
                }
                else
                {
                    SafeUpdateLabel(lblStatus, "Verificación completa: Todos los archivos están íntegros");
                }

                return corruptedFiles;
            }
            catch (Exception ex)
            {
                LogMessage($"❌ Error durante verificación de archivos: {ex.Message}");
                SafeUpdateLabel(lblStatus, "Error en verificación de archivos");
                return new List<string>();
            }
        }
        #endregion

        #region File Management
        private void CleanupTempFiles()
        {
            try
            {
                if (Directory.Exists(UpdatesPath))
                {
                    DeleteDirectory(UpdatesPath);
                    LogMessage("Archivos temporales limpiados");
                }
            }
            catch (Exception ex)
            {
                LogMessage($"Error al limpiar archivos temporales: {ex.Message}");
            }
        }

        private void DeleteDirectory(string path)
        {
            try
            {
                foreach (string file in Directory.GetFiles(path))
                {
                    File.SetAttributes(file, FileAttributes.Normal);
                    File.Delete(file);
                }

                foreach (string dir in Directory.GetDirectories(path))
                {
                    DeleteDirectory(dir);
                }

                Directory.Delete(path, true);
            }
            catch (Exception ex)
            {
                LogMessage($"Error al eliminar directorio {path}: {ex.Message}");
            }
        }
        #endregion

        public string readdtafile(string FileName)
        {
            try
            {
                ASCIIEncoding asciiencoding = new ASCIIEncoding();
                BinaryReader binaryReader = new BinaryReader(File.Open(FileName, FileMode.Open));
                int num = 19;
                int num2 = (int)binaryReader.BaseStream.Length - num;
                byte[] array = binaryReader.ReadBytes(num);

                if (Path.GetFileName(FileName) == "lccnct.dta")
                {
                    Header_lccnct = array;
                }
                if (Path.GetFileName(FileName) == "sl.dta")
                {
                    Header_sl = array;
                }

                byte[] array2 = binaryReader.ReadBytes(num2);
                binaryReader.Close();
                byte b = array[10];

                for (int i = 0; i < num2; i++)
                {
                    byte[] array3 = array2;
                    int num3 = i;
                    array3[num3] -= b;
                    b += array2[i];
                }

                string result = asciiencoding.GetString(array2);
                LogMessage($"Archivo {FileName} leído correctamente");
                return result;
            }
            catch (Exception ex)
            {
                LogMessage($"Error leyendo archivo {FileName}: {ex.Message}");
                throw;
            }
        }

        private async Task<ServerData> FetchServerDataAsync()
        {
            try
            {

                var response = await axios.Get<ServerData>($"{UpdateFile}");

                var serverData = response.Data;
                if (serverData == null || string.IsNullOrWhiteSpace(serverData.LatestVersion))
                {
                    throw new InvalidOperationException("No se recibió la versión más reciente del servidor.");
                }

                LogMessage($"Datos del servidor obtenidos. Versión más reciente: {serverData.LatestVersion}");
                return serverData;
            }
            catch (Exception ex)
            {
                LogMessage($"Error obteniendo datos del servidor: {ex.Message}");
                throw;
            }
        }

        // ============================================================================
        // AGREGAR ESTOS MÉTODOS JUSTO DESPUÉS DE FetchServerDataAsync()
        // ============================================================================

        private async Task<RepairFilesResponse> FetchRepairFilesAsync()
        {
            try
            {
                LogMessage("📡 Obteniendo lista de archivos de reparación...");

                var response = await axios.Get<RepairFilesResponse>($"repair_files");

                if (response?.Data == null)
                {
                    LogMessage("❌ Respuesta nula de repair_files");
                    return null;
                }

                LogMessage($"✅ Lista obtenida: {response.Data.TotalFiles} archivos");

                if (response.Data.VerificationInfo != null)
                {
                    LogMessage($"📊 Archivos con MD5: {response.Data.VerificationInfo.FilesWithMd5}");
                    LogMessage($"📏 Tamaño total: {FormatBytes(response.Data.VerificationInfo.TotalSize)}");
                }

                return response.Data;
            }
            catch (Exception ex)
            {
                LogMessage($"❌ Error obteniendo lista de reparación: {ex.Message}");
                return null;
            }
        }

        private async Task<FileVerificationResponse> VerifySpecificFileAsync(string filename)
        {
            try
            {
                LogMessage($"🔍 Verificando archivo específico: {filename}");

                var encodedFilename = Uri.EscapeDataString(filename);
                var response = await axios.Get<FileVerificationResponse>($"file/{encodedFilename}/verify");

                if (response?.Data == null)
                {
                    LogMessage($"❌ Respuesta nula para verificación de {filename}");
                    return new FileVerificationResponse
                    {
                        Success = false,
                        FileName = filename,
                        MD5Match = false,
                        FileExists = false,
                        IntegrityStatus = "error",
                        Error = "Respuesta nula del servidor"
                    };
                }

                var result = response.Data;

                LogMessage($"📋 Resultado para {filename}:");
                LogMessage($"   - Existe en servidor: {result.Success}");
                LogMessage($"   - Existe localmente: {result.FileExists}");
                LogMessage($"   - MD5 coincide: {result.MD5Match}");
                LogMessage($"   - Estado: {result.IntegrityStatus}");

                if (!string.IsNullOrEmpty(result.Error))
                {
                    LogMessage($"   - Error: {result.Error}");
                }

                return result;
            }
            catch (Exception ex)
            {
                LogMessage($"❌ Error verificando {filename}: {ex.Message}");
                return new FileVerificationResponse
                {
                    Success = false,
                    FileName = filename,
                    MD5Match = false,
                    FileExists = false,
                    IntegrityStatus = "error",
                    Error = ex.Message
                };
            }
        }

        private async Task CheckLauncherUpdate()
        {
            // 🔒 PROTECCIÓN CONTRA MÚLTIPLES EJECUCIONES
            lock (launcherUpdateLock)
            {
                if (isCheckingLauncherUpdate)
                {
                    LogMessage("⚠️ Verificación de launcher ya en progreso, saltando...");
                    return;
                }

                // Evitar verificaciones muy frecuentes (cada 5 minutos mínimo)
                if ((DateTime.Now - lastLauncherUpdateCheck).TotalMinutes < 5)
                {
                    LogMessage("⚠️ Verificación muy reciente, saltando...");
                    return;
                }

                isCheckingLauncherUpdate = true;
                lastLauncherUpdateCheck = DateTime.Now;
            }

            try
            {
                if (!systemConfig.AutoUpdateEnabled)
                {
                    LogMessage("Actualizaciones automáticas deshabilitadas");
                    return;
                }

                LogMessage("Verificando actualización del launcher...");

                var json = await axios.Get<LauncherVersionInfo>($"/launcher_update");
                var info = json.Data;

                // Verificar modo mantenimiento en respuesta
                if (info.MaintenanceMode)
                {
                    stateManager.UpdateSystemStatus(new SystemStatus
                    {
                        MaintenanceMode = true,
                        MaintenanceMessage = info.Message ?? "Sistema en mantenimiento",
                        Status = "maintenance"
                    });
                    return;
                }

                if (Version.Parse(info.Version) > Version.Parse(Application.ProductVersion))
                {
                    LogMessage($"Nueva versión del launcher disponible: {info.Version}");

                    // 🔒 VERIFICAR QUE NO HAY OTRO DIÁLOGO ABIERTO
                    if (Application.OpenForms.OfType<Form>().Any(f => f.Text.Contains("Actualización")))
                    {
                        LogMessage("⚠️ Ya hay un diálogo de actualización abierto");
                        return;
                    }

                    string updaterPath = Path.Combine(Application.StartupPath, "LauncherUpdater.exe");

                    var client = new WebClient();
                    await client.DownloadFileTaskAsync($"{Urls}LauncherUpdater.exe", updaterPath);

                    // 🔒 INVOCAR EN HILO PRINCIPAL Y ESPERAR RESULTADO
                    string versionedFileName = $"PBLauncher_v{info.Version}.exe";
                    LogMessage($"Iniciando actualización con archivo: {versionedFileName}");
                    Process.Start(updaterPath, $"\"{Urls}\" \"{Application.ExecutablePath}\" \"{versionedFileName}\"");
                    Application.Exit();
                }
                else
                {
                    LogMessage("Launcher está actualizado");
                }
            }
            catch (Exception ex)
            {
                LogMessage($"Error al verificar actualización del launcher: {ex.Message}");

                if (!ex.Message.Contains("mantenimiento"))
                {
                    MessageBox.Show($"No se pudo verificar actualizaciones del launcher: {ex.Message}", "Advertencia", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                }
            }
            finally
            {
                // 🔒 LIBERAR FLAG
                lock (launcherUpdateLock)
                {
                    isCheckingLauncherUpdate = false;
                }
                LogMessage("Verificación de launcher completada");
            }
        }

        public async Task VerifyAndUpdateAsync()
        {
            if (!stateManager.CanCheckUpdates())
            {
                LogMessage("No se pueden verificar actualizaciones en el estado actual");
                return;
            }

            try
            {
                isUpdating = true;
                stateManager.SetUpdatingState("Verificando actualizaciones...");

                SafeUpdateLabel(lblStatus, "Cargando configuración...");
                await Task.Delay(100);
                var config = LoadConfig();

                SafeUpdateLabel(lblStatus, "Obteniendo datos del servidor...");
                await Task.Delay(100);
                var serverData = await FetchServerDataAsync();
                // Verificar modo mantenimiento en respuesta del servidor
                if (serverData.MaintenanceMode)
                {
                    SafeUpdateLabel(lblStatus, "Sistema en mantenimiento");
                    await Task.Delay(100);
                    stateManager.UpdateSystemStatus(new SystemStatus
                    {
                        MaintenanceMode = true,
                        MaintenanceMessage = serverData.Message ?? "Sistema en mantenimiento",
                        Status = "maintenance"
                        
                    });
                    return;
                }
                //chromiumWebBrowser1.Refresh();
                SafeUpdateLabel(lblLatestVersion, $"{serverData.LatestVersion}");
                await Task.Delay(100);
                // Verificar integridad de archivos existentes
                var corruptedFiles = await VerifyGameFiles();
                bool hasCorruptedFiles = corruptedFiles.Count > 0;
                bool updateRequired = IsUpdateRequired(config.InstalledVersion, serverData.LatestVersion);

                if (updateRequired || hasCorruptedFiles)
                {
                    if (!Directory.Exists(UpdatesPath))
                    {
                        Directory.CreateDirectory(UpdatesPath);
                    }

                    if (updateRequired)
                    {
                        stateManager.SetUpdatingState($"Actualizando a versión {serverData.LatestVersion}...");
                        LogMessage($"Actualizando de {config.InstalledVersion} a {serverData.LatestVersion}");
                        await ApplyUpdatesAsync(config.InstalledVersion, serverData);
                    }

                    if (hasCorruptedFiles)
                    {
                        stateManager.SetUpdatingState("Reparando archivos corruptos...");
                        LogMessage($"Reparando {corruptedFiles.Count} archivos corruptos");
                        await RepairCorruptedFiles(corruptedFiles);
                    }

                    UpdateConfig(config, serverData.LatestVersion);
                    UpdateLocalFileHashes(serverData);


                    SafeUpdateLabel(lblStatus, "Actualización completada exitosamente");
                    LogMessage("Actualización completada exitosamente");
                    progressBarDownload.Value = 100;
                    progressBarExtract.Value = 100;
                }
                else
                {
                    SafeUpdateLabel(lblStatus, "No se requieren actualizaciones");
                    LogMessage("No se requieren actualizaciones");
                    progressBarDownload.Value = 100;
                    progressBarExtract.Value = 100;
                }

                CleanupTempFiles();

                // Actualizar estado a listo
                var currentStatus = await statusService.GetSystemStatusAsync();
                stateManager.UpdateSystemStatus(currentStatus);
            }
            catch (Exception ex)
            {
                LogMessage($"Error durante la verificación/actualización: {ex.Message}");
                stateManager.SetErrorState($"Error de actualización: {ex.Message}");

                MessageBox.Show($"Error durante la actualización: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                isUpdating = false;
            }
        }
        public void SafeUpdateLabel(Label label, string text)
        {
            if (label.InvokeRequired)
            {
                label.Invoke((MethodInvoker)(() => label.Text = text));
            }
            else
            {
                label.Text = text;
            }
        }
        public static void SafeUpdateProgressBar(System.Windows.Forms.ProgressBar progressBar, Action<System.Windows.Forms.ProgressBar> updateAction)
        {
            if (progressBar.InvokeRequired)
            {
                progressBar.Invoke(updateAction, progressBar);
            }
            else
            {
                updateAction(progressBar);
            }
        }


        private async Task RepairCorruptedFiles(List<string> corruptedFiles)
        {
            if (corruptedFiles == null || corruptedFiles.Count == 0)
            {
                LogMessage("✅ No hay archivos que reparar");
                SafeUpdateLabel(lblStatus, "No hay archivos que reparar");
                return;
            }

            try
            {
                LogMessage($"🔧 Iniciando reparación de {corruptedFiles.Count} archivos");
                SafeUpdateLabel(lblStatus, $"Reparando {corruptedFiles.Count} archivos...");

                var repairFiles = await FetchRepairFilesAsync();
                if (repairFiles == null || !repairFiles.Success)
                {
                    LogMessage("❌ Error obteniendo información para reparación");
                    SafeUpdateLabel(lblStatus, "Error obteniendo información para reparación");
                    return;
                }

                SafeUpdateProgressBar(progressBarExtract, pb => pb.Value = 0);

                int currentFile = 0;
                int successfulRepairs = 0;
                int failedRepairs = 0;

                foreach (string fileName in corruptedFiles)
                {
                    currentFile++;
                    int percentage = (int)((double)currentFile / corruptedFiles.Count * 100);
                    SafeUpdateProgressBar(progressBarExtract, pb => pb.Value = percentage);

                    SafeUpdateLabel(lblStatus, $"Reparando {currentFile}/{corruptedFiles.Count}: {fileName}");
                    LogMessage($"🔧 Reparando {currentFile}/{corruptedFiles.Count}: {fileName}");

                    var fileInfo = repairFiles.Files.FirstOrDefault(f =>
                        string.Equals(f.FileName, fileName, StringComparison.OrdinalIgnoreCase));

                    if (fileInfo != null)
                    {
                        try
                        {
                            await DownloadAndVerifyFile(fileInfo);
                            LogMessage($"✅ Archivo {fileName} reparado exitosamente");
                            successfulRepairs++;
                        }
                        catch (Exception ex)
                        {
                            LogMessage($"❌ Error reparando {fileName}: {ex.Message}");
                            failedRepairs++;
                        }
                    }
                    else
                    {
                        LogMessage($"⚠️ No se encontró información para reparar: {fileName}");
                        failedRepairs++;
                    }

                    await Task.Delay(100);
                }

                SafeUpdateProgressBar(progressBarExtract, pb => pb.Value = 100);

                LogMessage($"🏁 Proceso de reparación completado:");
                LogMessage($"   ✅ Exitosos: {successfulRepairs}");
                LogMessage($"   ❌ Fallidos: {failedRepairs}");
                LogMessage($"   📊 Total procesados: {currentFile}");

                if (failedRepairs == 0)
                {
                    SafeUpdateLabel(lblStatus, "Reparación completada exitosamente");
                }
                else
                {
                    SafeUpdateLabel(lblStatus, $"Reparación completada: {failedRepairs} errores");
                }
            }
            catch (Exception ex)
            {
                LogMessage($"❌ Error durante el proceso de reparación: {ex.Message}");
                SafeUpdateLabel(lblStatus, "Error durante la reparación");
            }
        }

        private async Task DownloadAndVerifyFile(RepairFileInfo fileInfo)
        {
            if (fileInfo == null)
            {
                throw new ArgumentNullException(nameof(fileInfo), "Información del archivo es nula");
            }

            if (string.IsNullOrWhiteSpace(fileInfo.FileName))
            {
                throw new ArgumentException("Nombre de archivo vacío", nameof(fileInfo));
            }

            if (string.IsNullOrWhiteSpace(fileInfo.RelativePath))
            {
                throw new ArgumentException("Ruta relativa vacía", nameof(fileInfo));
            }

            string downloadUrl = $"{Urls}files/{fileInfo.FileName}";
            string localPath = Path.Combine("./", fileInfo.RelativePath);
            string tempPath = localPath + ".tmp";

            try
            {
                LogMessage($"📥 Descargando: {fileInfo.FileName}");
                LogMessage($"   URL: {downloadUrl}");
                LogMessage($"   Destino: {localPath}");

                var directory = Path.GetDirectoryName(localPath);
                if (!string.IsNullOrEmpty(directory) && !Directory.Exists(directory))
                {
                    Directory.CreateDirectory(directory);
                    LogMessage($"📁 Directorio creado: {directory}");
                }

                using (var client = new WebClient())
                {
                    await client.DownloadFileTaskAsync(downloadUrl, tempPath);
                }

                LogMessage($"📥 Descarga completada, verificando integridad...");

                if (!string.IsNullOrWhiteSpace(fileInfo.MD5Hash))
                {
                    if (await VerifyFileIntegrity(tempPath, fileInfo.MD5Hash))
                    {
                        if (File.Exists(localPath))
                        {
                            File.Delete(localPath);
                            LogMessage($"🗑️ Archivo anterior eliminado: {localPath}");
                        }

                        File.Move(tempPath, localPath);
                        LogMessage($"✅ Archivo {fileInfo.FileName} reparado y verificado exitosamente");
                        LogMessage($"   Tamaño: {FormatBytes(new FileInfo(localPath).Length)}");
                    }
                    else
                    {
                        if (File.Exists(tempPath))
                            File.Delete(tempPath);

                        throw new Exception($"La verificación MD5 falló para el archivo descargado: {fileInfo.FileName}");
                    }
                }
                else
                {
                    LogMessage($"⚠️ No hay MD5 para verificar, moviendo archivo sin verificación");

                    if (File.Exists(localPath))
                        File.Delete(localPath);

                    File.Move(tempPath, localPath);
                    LogMessage($"✅ Archivo {fileInfo.FileName} reparado (sin verificación MD5)");
                }
            }
            catch (Exception ex)
            {
                LogMessage($"❌ Error reparando archivo {fileInfo.FileName}: {ex.Message}");

                if (File.Exists(tempPath))
                {
                    try
                    {
                        File.Delete(tempPath);
                        LogMessage($"🗑️ Archivo temporal eliminado: {tempPath}");
                    }
                    catch (Exception cleanupEx)
                    {
                        LogMessage($"⚠️ Error eliminando temporal: {cleanupEx.Message}");
                    }
                }

                throw;
            }
        }

        private void UpdateLocalFileHashes(ServerData serverData)
        {
            try
            {
                var hashData = new Dictionary<string, string>();

                if (serverData?.FileHashes != null)
                {
                    foreach (var fileInfo in serverData.FileHashes)
                    {
                        // 🎯 FIX: Solo guardar hashes válidos
                        if (!string.IsNullOrEmpty(fileInfo.MD5Hash))
                        {
                            hashData[fileInfo.FileName] = fileInfo.MD5Hash;
                        }
                        else
                        {
                            LogMessage($"⚠️ Archivo sin MD5, no se guardará hash: {fileInfo.FileName}");
                        }
                    }
                }

                string hashJson = JsonConvert.SerializeObject(hashData, Formatting.Indented);
                File.WriteAllText(FileHashesFile, hashJson);
                LogMessage($"📝 Hashes actualizados: {hashData.Count} archivos");
            }
            catch (Exception ex)
            {
                LogMessage($"❌ Error actualizando hashes locales: {ex.Message}");
            }
        }

        private Config LoadConfig()
        {
            try
            {
                if (!File.Exists(ConfigFile))
                {
                    LogMessage("Creando archivo de configuración por defecto");
                    var defaultConfig = new Config
                    {
                        InstalledVersion = "1.0.0.0",
                        LastUpdateCheck = DateTime.MinValue
                    };
                    File.WriteAllText(ConfigFile, JsonConvert.SerializeObject(defaultConfig, Formatting.Indented));
                    return defaultConfig;
                }

                var configJson = File.ReadAllText(ConfigFile);
                if (string.IsNullOrWhiteSpace(configJson))
                {
                    LogMessage("Archivo de configuración vacío, recreando");
                    var defaultConfig = new Config
                    {
                        InstalledVersion = "1.0.0.0",
                        LastUpdateCheck = DateTime.MinValue
                    };
                    File.WriteAllText(ConfigFile, JsonConvert.SerializeObject(defaultConfig, Formatting.Indented));
                    return defaultConfig;
                }

                var config = JsonConvert.DeserializeObject<Config>(configJson);
                LogMessage($"Configuración cargada. Versión instalada: {config.InstalledVersion}");
                return config;
            }
            catch (Exception ex)
            {
                LogMessage($"Error cargando configuración: {ex.Message}");
                throw;
            }
        }

        private bool IsUpdateRequired(string installedVersion, string latestVersion)
        {
            if (string.IsNullOrWhiteSpace(installedVersion) || string.IsNullOrWhiteSpace(latestVersion))
            {
                LogMessage("Una de las versiones es nula o vacía");
                return false;
            }

            try
            {
                bool updateRequired = Version.Parse(installedVersion) < Version.Parse(latestVersion);
                LogMessage($"Comparación de versiones: {installedVersion} vs {latestVersion}. Actualización requerida: {updateRequired}");
                return updateRequired;
            }
            catch (FormatException ex)
            {
                LogMessage($"Error comparando versiones: {ex.Message}");
                throw new Exception($"Error al comparar versiones: {ex.Message}");
            }
        }

        private async Task ApplyUpdatesAsync(string installedVersion, ServerData serverData)
        {
            if (serverData?.Updates == null || serverData.Updates.Length == 0)
            {
                throw new InvalidOperationException("No hay actualizaciones disponibles en el servidor.");
            }

            var updatesToApply = serverData.Updates
                .Where(update => Version.Parse(GetVersionFromUpdate(update)) > Version.Parse(installedVersion))
                .OrderBy(update => Version.Parse(GetVersionFromUpdate(update)));

            LogMessage($"Aplicando {updatesToApply.Count()} actualizaciones");

            foreach (var update in updatesToApply)
            {
                try
                {
                    LogMessage($"🔄 Procesando actualización: {update}");

                    // ⭐ PASO 1: DESCARGAR CON VERIFICACIÓN DE ESTADO
                    SafeUpdateLabel(lblDownload, $"Preparando descarga de {update}...");
                    await Task.Delay(100); // Dar tiempo para actualizar UI

                    LogMessage($"📥 Iniciando descarga de: {update}");
                    await DownloadUpdateFileAsync(update);

                    // ⭐ PASO 2: VERIFICAR QUE LA DESCARGA SE COMPLETÓ
                    var downloadedFilePath = Path.Combine(UpdatesPath, update);

                    // Esperar hasta que el archivo esté disponible (con timeout)
                    bool fileReady = await WaitForFileReady(downloadedFilePath, TimeSpan.FromMinutes(2));

                    if (!fileReady)
                    {
                        throw new Exception($"El archivo de actualización no está listo después del timeout: {update}");
                    }

                    LogMessage($"✅ Descarga verificada: {update}");

                    // ⭐ PASO 3: EXTRAER CON VERIFICACIÓN PREVIA
                    SafeUpdateLabel(lblStatus, $"Preparando extracción de {update}...");
                    await Task.Delay(100);

                    LogMessage($"📤 Iniciando extracción de: {update}");
                    await ExtractUpdate(update);

                    LogMessage($"✅ Extracción completada: {update}");

                    // ⭐ PASO 4: LIMPIEZA SEGURA DEL ARCHIVO ZIP
                    try
                    {
                        if (File.Exists(downloadedFilePath))
                        {
                            // Verificar que no esté en uso antes de eliminar
                            await WaitForFileNotInUse(downloadedFilePath, TimeSpan.FromSeconds(30));

                            File.Delete(downloadedFilePath);
                            LogMessage($"📁 Archivo ZIP eliminado: {update}");
                        }
                    }
                    catch (Exception ex)
                    {
                        LogMessage($"⚠️ Error eliminando archivo ZIP {update}: {ex.Message}");
                        // No fallar por esto, continuar
                    }

                    LogMessage($"🎉 Actualización completada exitosamente: {update}");
                }
                catch (Exception ex)
                {
                    LogMessage($"💥 Error procesando actualización {update}: {ex.Message}");
                    throw; // Re-lanzar para que se maneje arriba
                }
            }

            LogMessage($"✅ Todas las actualizaciones aplicadas exitosamente");
        }
        // Agregar este método a LauncherForm.cs para diagnosticar:
        private async Task<bool> WaitForFileReady(string filePath, TimeSpan timeout)
        {
            var startTime = DateTime.Now;
            var fileName = Path.GetFileName(filePath);

            LogMessage($"⏳ Esperando que el archivo esté listo: {fileName}");

            while (DateTime.Now - startTime < timeout)
            {
                try
                {
                    // Verificar que el archivo existe
                    if (!File.Exists(filePath))
                    {
                        LogMessage($"   📋 Archivo aún no existe, esperando... ({(DateTime.Now - startTime).TotalSeconds:F1}s)");
                        await Task.Delay(500);
                        continue;
                    }

                    // Verificar que el archivo no está vacío
                    var fileInfo = new FileInfo(filePath);
                    if (fileInfo.Length == 0)
                    {
                        LogMessage($"   📋 Archivo existe pero está vacío, esperando... ({(DateTime.Now - startTime).TotalSeconds:F1}s)");
                        await Task.Delay(500);
                        continue;
                    }

                    // Verificar que el archivo no está en uso
                    try
                    {
                        using (var stream = new FileStream(filePath, FileMode.Open, FileAccess.Read, FileShare.Read))
                        {
                            // Si podemos abrir el archivo, está listo
                            LogMessage($"✅ Archivo listo: {fileName} ({FormatBytes(fileInfo.Length)})");
                            return true;
                        }
                    }
                    catch (IOException)
                    {
                        LogMessage($"   🔒 Archivo en uso, esperando... ({(DateTime.Now - startTime).TotalSeconds:F1}s)");
                        await Task.Delay(500);
                        continue;
                    }
                }
                catch (Exception ex)
                {
                    LogMessage($"   ⚠️ Error verificando archivo: {ex.Message}");
                    await Task.Delay(1000);
                }
            }

            LogMessage($"❌ Timeout esperando archivo: {fileName} ({timeout.TotalSeconds}s)");
            return false;
        }

        private async Task<bool> WaitForFileNotInUse(string filePath, TimeSpan timeout)
        {
            var startTime = DateTime.Now;
            var fileName = Path.GetFileName(filePath);

            while (DateTime.Now - startTime < timeout)
            {
                try
                {
                    using (var stream = new FileStream(filePath, FileMode.Open, FileAccess.Read, FileShare.None))
                    {
                        // Si podemos abrir en modo exclusivo, no está en uso
                        LogMessage($"✅ Archivo liberado: {fileName}");
                        return true;
                    }
                }
                catch (IOException)
                {
                    // Archivo aún en uso, esperar
                    await Task.Delay(200);
                }
                catch (Exception ex)
                {
                    LogMessage($"Error verificando uso del archivo {fileName}: {ex.Message}");
                    return false;
                }
            }

            LogMessage($"⚠️ Timeout - archivo puede seguir en uso: {fileName}");
            return false; // Continuar aunque no esté seguro
        }

        private void CheckFileUsage(string filePath)
        {
            try
            {
                if (!File.Exists(filePath))
                {
                    LogMessage($"Archivo no existe: {filePath}");
                    return;
                }

                LogMessage($"Verificando uso del archivo: {Path.GetFileName(filePath)}");

                // Intentar abrir en modo exclusivo para verificar si está en uso
                try
                {
                    using (var fs = new FileStream(filePath, FileMode.Open, FileAccess.Read, FileShare.None))
                    {
                        LogMessage("✅ El archivo no está siendo usado por otro proceso");
                    }
                }
                catch (IOException ioEx)
                {
                    LogMessage($"⚠️ El archivo está siendo usado: {ioEx.Message}");

                    // Intentar obtener información adicional
                    try
                    {
                        var fileInfo = new FileInfo(filePath);
                        LogMessage($"📄 Información del archivo:");
                        LogMessage($"   - Tamaño: {fileInfo.Length:N0} bytes");
                        LogMessage($"   - Creado: {fileInfo.CreationTime}");
                        LogMessage($"   - Modificado: {fileInfo.LastWriteTime}");
                        LogMessage($"   - Accedido: {fileInfo.LastAccessTime}");
                        LogMessage($"   - Atributos: {fileInfo.Attributes}");
                    }
                    catch (Exception infoEx)
                    {
                        LogMessage($"No se pudo obtener información del archivo: {infoEx.Message}");
                    }
                }
            }
            catch (Exception ex)
            {
                LogMessage($"Error verificando archivo: {ex.Message}");
            }
        }
        // Agregar estos campos a la clase LauncherForm:
        private bool isDownloadingUpdate = false;
        private readonly object downloadLock = new object();
        private string currentDownloadingFile = null; // ⭐ NUEVO: Rastrear archivo actual

        private async Task DownloadUpdateFileAsync(string update)
        {
            // ⭐ PROTECCIÓN MEJORADA CONTRA MÚLTIPLES DESCARGAS
            lock (downloadLock)
            {
                if (isDownloadingUpdate)
                {
                    LogMessage($"⚠️ Ya hay una descarga en progreso: {currentDownloadingFile}");
                    LogMessage($"   Ignorando solicitud para: {update}");
                    return;
                }
                isDownloadingUpdate = true;
                currentDownloadingFile = update; // ⭐ RASTREAR ARCHIVO ACTUAL
            }

            try
            {
                var updateUrl = $"{UpdatesPath}{update}";
                var localPath = Path.Combine(UpdatesPath, update);

                // ⭐ VERIFICAR SI EL ARCHIVO FINAL YA EXISTE Y ES VÁLIDO
                if (File.Exists(localPath))
                {
                    var existingInfo = new FileInfo(localPath);
                    if (existingInfo.Length > 0)
                    {
                        LogMessage($"✅ El archivo ya existe y es válido: {FormatBytes(existingInfo.Length)}");
                        LogMessage($"   Saltando descarga de: {update}");
                        return;
                    }
                    else
                    {
                        LogMessage($"🗑️ Archivo existente está vacío, será reemplazado");
                        CheckFileUsage(localPath);
                        File.Delete(localPath);
                    }
                }

                // Crear archivo temporal único
                var uniqueId = Guid.NewGuid().ToString("N").Substring(0, 8);
                var tempPath = Path.Combine(UpdatesPath, $"temp_{uniqueId}_{update}");

                LogMessage($"🔄 Iniciando descarga única: {Urls}{updateUrl}");
                LogMessage($"📁 ID de descarga: {uniqueId}");
                LogMessage($"📁 Archivo temporal: {Path.GetFileName(tempPath)}");

                // Actualizar UI de forma thread-safe
                SafeUpdateUI(() =>
                {
                    progressBarDownload.Value = 0;
                    progressBarDownload.Visible = true;
                    lblDownload.Visible = true;
                });

                // Crear directorio si no existe
                Directory.CreateDirectory(Path.GetDirectoryName(localPath));

                using (var httpClient = new HttpClient())
                {
                    httpClient.BaseAddress = new Uri(Urls);
                    httpClient.Timeout = TimeSpan.FromMinutes(10);
                    httpClient.DefaultRequestHeaders.Add("User-Agent", "PBLauncher/1.0");

                    using (var response = await httpClient.GetAsync(updateUrl, HttpCompletionOption.ResponseHeadersRead))
                    {
                        if (!response.IsSuccessStatusCode)
                        {
                            string errorContent = await response.Content.ReadAsStringAsync();
                            LogMessage($"❌ Error HTTP {response.StatusCode}: {errorContent}");
                            throw new Exception($"Error del servidor: {response.StatusCode} - {response.ReasonPhrase}");
                        }

                        var totalBytes = response.Content.Headers.ContentLength ?? -1L;
                        LogMessage($"📊 Tamaño del archivo: {FormatBytes(totalBytes)}");

                        using (var contentStream = await response.Content.ReadAsStreamAsync())
                        {
                            // ⭐ VERIFICAR QUE EL ARCHIVO TEMPORAL NO EXISTE (DEBERÍA SER ÚNICO)
                            if (File.Exists(tempPath))
                            {
                                LogMessage($"⚠️ El archivo temporal ya existe, eliminándolo: {Path.GetFileName(tempPath)}");
                                File.Delete(tempPath);
                            }

                            using (var fileStream = new FileStream(tempPath, FileMode.CreateNew, FileAccess.Write, FileShare.Read))
                            {
                                var buffer = new byte[8192];
                                var totalBytesRead = 0L;
                                int bytesRead;
                                var lastUIUpdate = DateTime.Now;

                                while ((bytesRead = await contentStream.ReadAsync(buffer, 0, buffer.Length)) > 0)
                                {
                                    await fileStream.WriteAsync(buffer, 0, bytesRead);
                                    totalBytesRead += bytesRead;

                                    // Actualizar UI cada 100ms
                                    var now = DateTime.Now;
                                    if ((now - lastUIUpdate).TotalMilliseconds >= 100)
                                    {
                                        var currentProgress = totalBytesRead;
                                        var currentTotal = totalBytes;

                                        SafeUpdateUI(() =>
                                        {
                                            if (currentTotal > 0)
                                            {
                                                var progressPercentage = (int)((currentProgress * 100L) / currentTotal);
                                                progressBarDownload.Value = Math.Min(progressPercentage, 100);
                                                SafeUpdateLabel(lblDownload, $"Descargando... {progressPercentage}% ({FormatBytes(currentProgress)}/{FormatBytes(currentTotal)})");
                                            }
                                            else
                                            {
                                                SafeUpdateLabel(lblDownload, $"Descargando... {FormatBytes(currentProgress)}");
                                            }
                                        });

                                        lastUIUpdate = now;
                                    }

                                    if (totalBytesRead % (8192 * 20) == 0)
                                    {
                                        await Task.Delay(1);
                                    }
                                }

                                // ⭐ ASEGURAR QUE TODOS LOS DATOS SE ESCRIBAN
                                await fileStream.FlushAsync();
                            }
                        }
                    }
                }

                // Verificar descarga temporal
                var tempFileInfo = new FileInfo(tempPath);
                if (!tempFileInfo.Exists || tempFileInfo.Length == 0)
                {
                    throw new Exception("La descarga temporal falló o el archivo está vacío");
                }

                LogMessage($"✅ Descarga temporal completada: {FormatBytes(tempFileInfo.Length)}");

                // ⭐ MOVER DE FORMA SEGURA CON VERIFICACIONES ADICIONALES
                await SafeMoveToFinalDestination(tempPath, localPath);

                // Actualizar UI final
                SafeUpdateUI(() =>
                {
                    progressBarDownload.Value = 100;
                    SafeUpdateLabel(lblDownload, "¡Descarga completada!");
                });

                LogMessage($"🎉 Descarga completada exitosamente: {update}");

            }
            catch (Exception ex)
            {
                LogMessage($"💥 Error descargando {update}: {ex.Message}");

                // ⭐ LIMPIAR SOLO ARCHIVOS TEMPORALES DE ESTA DESCARGA
                try
                {
                    var tempPattern = $"temp_*_{update}";
                    var tempFiles = Directory.GetFiles(UpdatesPath, tempPattern);
                    foreach (var tempFile in tempFiles)
                    {
                        try
                        {
                            File.Delete(tempFile);
                            LogMessage($"🧹 Archivo temporal específico limpiado: {Path.GetFileName(tempFile)}");
                        }
                        catch (Exception cleanEx)
                        {
                            LogMessage($"⚠️ Error limpiando {Path.GetFileName(tempFile)}: {cleanEx.Message}");
                        }
                    }
                }
                catch (Exception cleanupEx)
                {
                    LogMessage($"Error en limpieza: {cleanupEx.Message}");
                }

                throw;
            }
            finally
            {
                // ⭐ LIBERAR FLAG DE DESCARGA DE FORMA SEGURA
                lock (downloadLock)
                {
                    isDownloadingUpdate = false;
                    currentDownloadingFile = null;
                }

                // Ocultar UI
                SafeUpdateUI(() =>
                {
                    progressBarDownload.Visible = false;
                    lblDownload.Visible = false;
                });

                LogMessage($"🔓 Descarga liberada para: {update}");
            }
        }

        // ⭐ MÉTODO AUXILIAR PARA ACTUALIZACIONES THREAD-SAFE
        private void SafeUpdateUI(Action uiAction)
        {
            try
            {
                if (this.InvokeRequired)
                {
                    this.Invoke(uiAction);
                }
                else
                {
                    uiAction();
                }
            }
            catch (Exception ex)
            {
                LogMessage($"Error actualizando UI: {ex.Message}");
            }
        }

        // ⭐ MÉTODO AUXILIAR PARA FORMATEAR BYTES
        private string FormatBytes(long bytes)
        {
            if (bytes >= 1024 * 1024 * 1024)
                return $"{bytes / (1024.0 * 1024.0 * 1024.0):F1} GB";
            if (bytes >= 1024 * 1024)
                return $"{bytes / (1024.0 * 1024.0):F1} MB";
            if (bytes >= 1024)
                return $"{bytes / 1024.0:F1} KB";
            return $"{bytes} bytes";
        }
        private async Task SafeMoveToFinalDestination(string tempPath, string finalPath)
        {
            const int maxAttempts = 5;

            // ⭐ VERIFICAR QUE EL ARCHIVO TEMPORAL EXISTE ANTES DE INTENTAR MOVERLO
            if (!File.Exists(tempPath))
            {
                LogMessage($"⚠️ Archivo temporal no encontrado: {Path.GetFileName(tempPath)}");
                LogMessage($"   Ruta completa: {tempPath}");

                // Verificar si el archivo final ya existe (puede haber sido movido por otra instancia)
                if (File.Exists(finalPath))
                {
                    var finalInfo = new FileInfo(finalPath);
                    if (finalInfo.Length > 0)
                    {
                        LogMessage($"✅ El archivo final ya existe y es válido: {FormatBytes(finalInfo.Length)}");
                        return; // ⭐ SALIR SIN ERROR - YA ESTÁ LISTO
                    }
                    else
                    {
                        LogMessage($"⚠️ El archivo final existe pero está vacío, eliminándolo");
                        File.Delete(finalPath);
                    }
                }

                throw new Exception($"El archivo temporal no existe y el archivo final no es válido: {Path.GetFileName(tempPath)}");
            }

            // ⭐ VERIFICAR INTEGRIDAD DEL ARCHIVO TEMPORAL
            var tempInfo = new FileInfo(tempPath);
            if (tempInfo.Length == 0)
            {
                LogMessage($"❌ El archivo temporal está vacío: {Path.GetFileName(tempPath)}");
                File.Delete(tempPath);
                throw new Exception("El archivo temporal está vacío");
            }

            LogMessage($"📁 Iniciando movimiento seguro: {FormatBytes(tempInfo.Length)}");
            LogMessage($"   De: {Path.GetFileName(tempPath)}");
            LogMessage($"   A: {Path.GetFileName(finalPath)}");

            for (int attempt = 1; attempt <= maxAttempts; attempt++)
            {
                try
                {
                    // ⭐ VERIFICAR NUEVAMENTE QUE EL ARCHIVO TEMPORAL SIGUE EXISTIENDO
                    if (!File.Exists(tempPath))
                    {
                        LogMessage($"⚠️ El archivo temporal desapareció durante el intento {attempt}");

                        // Verificar si ya fue movido exitosamente
                        if (File.Exists(finalPath) && new FileInfo(finalPath).Length > 0)
                        {
                            LogMessage($"✅ El archivo final ya existe, operación completada por otra instancia");
                            return;
                        }

                        throw new Exception("El archivo temporal desapareció durante el proceso");
                    }

                    // Si el archivo final existe, eliminarlo de forma segura
                    if (File.Exists(finalPath))
                    {
                        LogMessage($"🗑️ Eliminando archivo existente (intento {attempt})");

                        // Verificar quién lo está usando antes de eliminar
                        CheckFileUsage(finalPath);

                        File.SetAttributes(finalPath, FileAttributes.Normal);
                        File.Delete(finalPath);
                        await Task.Delay(200); // Esperar liberación
                        LogMessage("   Archivo existente eliminado");
                    }

                    // ⭐ VERIFICAR UNA VEZ MÁS ANTES DEL MOVIMIENTO CRÍTICO
                    if (!File.Exists(tempPath))
                    {
                        throw new Exception("El archivo temporal desapareció justo antes del movimiento");
                    }

                    // Mover archivo temporal al destino
                    File.Move(tempPath, finalPath);
                    LogMessage($"✅ Archivo movido exitosamente: {Path.GetFileName(finalPath)}");

                    // Verificar resultado final
                    if (File.Exists(finalPath))
                    {
                        var finalInfo = new FileInfo(finalPath);
                        if (finalInfo.Length > 0)
                        {
                            LogMessage($"✅ Verificación final exitosa: {FormatBytes(finalInfo.Length)}");
                            return;
                        }
                        else
                        {
                            File.Delete(finalPath);
                            throw new Exception("El archivo final se creó pero está vacío");
                        }
                    }
                    else
                    {
                        throw new Exception("El archivo final no se creó correctamente");
                    }

                }
                catch (Exception ex)
                {
                    LogMessage($"❌ Intento {attempt}/{maxAttempts} falló: {ex.Message}");

                    if (attempt == maxAttempts)
                    {
                        // ⭐ ESTRATEGIA DE EMERGENCIA MEJORADA
                        try
                        {
                            LogMessage("🚨 Iniciando estrategia de emergencia");

                            // Verificar una última vez que el archivo temporal existe
                            if (!File.Exists(tempPath))
                            {
                                LogMessage("❌ Archivo temporal no existe para estrategia de emergencia");

                                // Última verificación: ¿el archivo final ya existe y es válido?
                                if (File.Exists(finalPath) && new FileInfo(finalPath).Length > 0)
                                {
                                    LogMessage("✅ El archivo final ya existe, considerando operación exitosa");
                                    return;
                                }

                                throw new Exception("No se puede completar: archivo temporal no existe y archivo final no es válido");
                            }

                            LogMessage("📋 Usando File.Copy como estrategia de emergencia");
                            File.Copy(tempPath, finalPath, overwrite: true);

                            if (File.Exists(finalPath) && new FileInfo(finalPath).Length > 0)
                            {
                                // Solo eliminar el temporal si la copia fue exitosa
                                File.Delete(tempPath);
                                LogMessage("✅ Estrategia de emergencia exitosa");
                                return;
                            }
                            else
                            {
                                throw new Exception("La estrategia de emergencia falló: archivo final inválido");
                            }
                        }
                        catch (Exception emergencyEx)
                        {
                            LogMessage($"💥 Estrategia de emergencia falló: {emergencyEx.Message}");
                            throw new Exception($"Falló después de {maxAttempts} intentos. Error final: {emergencyEx.Message}");
                        }
                    }

                    // Backoff exponencial
                    await Task.Delay(500 * attempt);
                }
            }
        }
        private async Task ExtractUpdate(string update)
        {
            SafeUpdateUI(() =>
            {
                progressBarExtract.Value = 0;
                progressBarExtract.Visible = true;
            });
            
            var localPath = Path.Combine(UpdatesPath, update);
            CheckFileUsage(localPath);
            var extractPath = "./";
            try
            {
                LogMessage($"Iniciando extracción: {update}");
                LogMessage($"Archivo: {localPath}");
                LogMessage($"Destino: {Path.GetFullPath(extractPath)}");

                await Task.Run(() =>
                {
                    using (ZipArchive archive = ZipFile.OpenRead(localPath))
                    {
                        int totalFiles = archive.Entries.Count;
                        int extractedFiles = 0;

                        LogMessage($"Total de entradas en el ZIP: {totalFiles}");

                        foreach (var entry in archive.Entries)
                        {
                            try
                            {
                                // Saltar directorios (entries con Name vacío)
                                if (string.IsNullOrEmpty(entry.Name))
                                {
                                    LogMessage($"📁 Directorio: {entry.FullName}");
                                    extractedFiles++;
                                    continue;
                                }

                                var destinationPath = Path.Combine(extractPath, entry.FullName);

                                LogMessage($"📤 Extrayendo: {entry.FullName}");

                                // Crear directorio padre si no existe
                                string directory = Path.GetDirectoryName(destinationPath);
                                if (!string.IsNullOrEmpty(directory) && !Directory.Exists(directory))
                                {
                                    Directory.CreateDirectory(directory);
                                    LogMessage($"📁 Directorio creado: {directory}");
                                }

                                // Eliminar archivo existente si existe
                                if (File.Exists(destinationPath))
                                {
                                    File.SetAttributes(destinationPath, FileAttributes.Normal);
                                    File.Delete(destinationPath);
                                    LogMessage($"🗑️ Archivo existente eliminado: {Path.GetFileName(destinationPath)}");
                                }

                                // Extraer archivo usando System.IO.Compression
                                entry.ExtractToFile(destinationPath, overwrite: true);

                                LogMessage($"✅ Extraído: {entry.FullName}");

                                extractedFiles++;
                                int percentage = (int)((extractedFiles / (double)totalFiles) * 100);

                                // Actualizar UI en el hilo principal
                                this.Invoke(new Action(() =>
                                {
                                    SafeUpdateUI(() =>
                                    {
                                        progressBarExtract.Value = Math.Min(percentage, 100);
                                    });
                                    SafeUpdateLabel(lblExtract, $"Extrayendo... {percentage}% completado ({extractedFiles}/{totalFiles})");
                                }));
                            }
                            catch (Exception entryEx)
                            {
                                // Log del error específico pero continuar con otros archivos
                                LogMessage($"❌ Error extrayendo {entry.FullName}: {entryEx.Message}");

                                extractedFiles++; // Contar como procesado para el progreso

                                int percentage = (int)((extractedFiles / (double)totalFiles) * 100);
                                this.Invoke(new Action(() =>
                                {
                                    SafeUpdateUI(() =>
                                    {
                                        progressBarExtract.Value = Math.Min(percentage, 100);
                                    });
                                    SafeUpdateLabel(lblExtract, $"Error en archivo, continuando... {percentage}%");
                                }));

                                // Continuar con el siguiente archivo en lugar de fallar completamente
                                continue;
                            }
                        }
                    }
                });

                // Actualizar UI final
                this.Invoke(new Action(() =>
                {
                    SafeUpdateLabel(lblExtract, "¡Extracción completada!");
                    SafeUpdateUI(() =>
                    {
                        progressBarExtract.Value = 100;
                    });
                }));

                LogMessage($"🎉 Extracción completada: {update}");
            }
            catch (Exception ex)
            {
                this.Invoke(new Action(() =>
                {
                    SafeUpdateLabel(lblExtract, "❌ Error en la extracción");
                    SafeUpdateUI(() =>
                    {
                        progressBarExtract.Value = 0;
                    });
                }));

                LogMessage($"💥 Error extrayendo {update}: {ex.Message}");
                LogMessage($"💥 Stack trace: {ex.StackTrace}");
                throw;
            }
    }

        private string GetVersionFromUpdate(string update)
        {
            return update.Replace("update_", "").Replace(".zip", "");
        }

        private void UpdateConfig(Config config, string latestVersion)
        {
            try
            {
                config.InstalledVersion = latestVersion;
                config.LastUpdateCheck = DateTime.Now;
                File.WriteAllText(ConfigFile, JsonConvert.SerializeObject(config, Formatting.Indented));
                LogMessage($"Configuración actualizada a versión: {latestVersion}");
            }
            catch (Exception ex)
            {
                LogMessage($"Error actualizando configuración: {ex.Message}");
            }
        }

        public void btnExit_Click(object sender, EventArgs e)
        {
            try
            {
                cancellationTokenSource?.Cancel();
                systemCheckTimer?.Stop();
                statusService?.Dispose();
                Application.Exit();
            }
            catch (Exception ex)
            {
                LogMessage($"Error cerrando aplicación: {ex.Message}");
                Application.Exit();
            }
        }
        private void SafeInvoke(Action action)
        {
            if (this.InvokeRequired)
                this.Invoke(action);
            else
                action();
        }
        public void SetCheck(dynamic data)
        {
            try
            {
                // Serializamos el objeto como string JSON
                var json = JsonConvert.SerializeObject(new
                {
                    User = data.User,
                    Pass = data.Pass

                });

                var key = Registry.CurrentUser.CreateSubKey(@"SOFTWARE\PBLauncher\Session");
                key?.SetValue("remember", json); // Guardamos como string
                key?.Close();
            }
            catch
            {
                // Logging o manejo de errores real sería ideal aquí
            }
        }
        public dynamic GetCheck()
        {
            try
            {
                var key = Registry.CurrentUser.OpenSubKey(@"SOFTWARE\PBLauncher\Session");
                var remember = JsonConvert.DeserializeObject<dynamic>(key?.GetValue("remember")?.ToString());
                key?.Close();
                if (remember.User != string.Empty && remember.Pass != string.Empty)
                {
                    return remember;
                }
                else
                {
                    return false;
                }
            }
            catch
            {
                // Manejo de errores
            }

            return null; // o false, según la lógica que prefieras
        }
        public void btnStart_Click(object sender, EventArgs e)
        {
            SafeInvoke(() =>
            {
                
            });
        }
        private void chkRememberSession_CheckedChanged(object sender, EventArgs e)
        {
            if (chkRememberSession.Checked)
            {
                // Guardar datos actuales
                SetCheck(new
                {
                    User = textBox_user.Text,
                    Pass = textBox_pass.Text
                });
            }
            else
            {
                // Eliminar sesión guardada (puedes sobreescribirla con null o cadena vacía)
                SetCheck(new
                {
                    User = "",
                    Pass = ""
                });
            }
        }

        private void MinimizeButton_Click(object sender, EventArgs e)
        {
            WindowState = FormWindowState.Minimized;
        }

        private void ConfigButton_Click(object sender, EventArgs e)
        {
            if (File.Exists(Application.StartupPath + @"\\PBConfig.exe"))
            {
                Process.Start("PBConfig.exe");
            }
            else
            {
                if (MessageBox.Show("PBConfig.exe Not Found" + "\n" + "Turn Off your Windows Defender and Antivirus First" + "\n" + "Do You Want To Download PBConfig.exe From Server?", "PBLauncher", MessageBoxButtons.YesNo, MessageBoxIcon.Warning) == DialogResult.Yes)
                {
                    try
                    {
                        GameUpdate.DownloadFile(Urls + "PBConfig.exe", "PBConfig.exe");
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show("Error downloading PBConfig.exe: " + ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }
                }
            }
        }

        private async void btnCheck_Click(object sender, EventArgs e)
        {
            try
            {
                btnCheck.Enabled = false;

                await InitializeSystemStatus();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error verificando estado: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                if (stateManager.CanCheckUpdates())
                {
                    btnCheck.Enabled = true;
                }
            }
        }
        protected override void OnFormClosing(FormClosingEventArgs e)
        {
            try
            {
                cancellationTokenSource?.Cancel();
                systemCheckTimer?.Stop();
                heartbeatTimer?.Stop(); // ✅ NUEVO
                
                // ✅ NUEVO: Desconectar SocketIO
                if (socketIOService != null)
                {
                    socketIOService.DisconnectAsync().Wait(2000);
                    socketIOService.Dispose();
                }
                
                statusService?.Dispose();
            }
            catch { }

            base.OnFormClosing(e);
        }

        private void LogMessage(string message)
        {
            try
            {
                string logEntry = $"[{DateTime.Now:yyyy-MM-dd HH:mm:ss}] [LauncherForm] {message}";
                Console.WriteLine(logEntry);
                File.AppendAllText(LogFile, logEntry + Environment.NewLine);
            }
            catch
            {
                // Si no puede escribir al log, continuamos silenciosamente
            }
        }
        private void ShowStatus(string message, Color color)
        {
            this.Invoke((Action)(() =>
            {
                lblStatus.Text = message;
                lblStatus.ForeColor = color;
            }));
        }
        private void InitializeLoginService()
        {
            try
            {
                // Configurar URL del servidor (cambiar según tu configuración)
                string serverUrl = "http://192.168.18.31:5000"; // Cambiar por tu URL

                _loginService = new LoginService(serverUrl);

                // Suscribirse a eventos
                _loginService.OnLoginSuccess += OnLoginSuccess;
                _loginService.OnLoginFailed += OnLoginFailed;
                _loginService.OnLogout += OnLogout;

                // Intentar restaurar sesión anterior si está marcado
                if (chkRememberSession?.Checked == true)
                {
                    if (_loginService.RestoreSession()) 
                    {
                        ShowStatus("Sesión restaurada", Color.White);
                    }
                    else
                    {
                        ShowStatus("No se pudo restaurar sesión", Color.White);
                    }
                }

                ShowStatus("Listo para conectar", Color.White);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error al inicializar el servicio de login: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void PerformLogin()
        {
            try
            {
                SafeInvoke(async () =>
                {
                    userData.IpAddress = "127.0.0.1";
                    // Validaciones básicas
                    var username = textBox_user.Text?.Trim().ToLower();
                    var password = ((userData.IpAddress == "127.0.0.1") ? Gen5(textBox_pass.Text.ToLower()) : Gen5(textBox_pass.Text.ToLower()));

                    if (string.IsNullOrWhiteSpace(username))
                    {
                        ShowStatus("Por favor ingresa tu nombre de usuario", Color.Red);
                        textBox_user.Focus();
                        return;
                    }

                    if (string.IsNullOrWhiteSpace(password))
                    {
                        ShowStatus("Por favor ingresa tu contraseña", Color.Red);
                        textBox_pass.Focus();
                        return;
                    }

                    // Validaciones adicionales
                    if (!LoginUtils.IsValidUsername(username))
                    {
                        ShowStatus("Nombre de usuario inválido", Color.Red);
                        textBox_user.Focus();
                        return;
                    }

                    if (!LoginUtils.IsValidPasswordLength(password))
                    {
                        ShowStatus("Contraseña debe tener entre 3 y 64 caracteres", Color.Red);
                        textBox_pass.Focus();
                        return;
                    }

                    // Mostrar estado de carga
                    SetLoadingState(true);
                    //ShowStatus("Conectando...", Color.Blue);

                    // Realizar login
                    var success = await _loginService.LoginAsync(username, password);

                    if (!success)
                    {
                        textBox_pass.Clear();
                        textBox_pass.Focus();
                    }
                    else
                    {
                        btnCheck.Visible = false;

                        var data = GetCheck();

                        if (data is Newtonsoft.Json.Linq.JObject rememberData)
                        {
                            chkRememberSession.Checked = true;
                            textBox_user.Text = rememberData["User"]?.ToString();
                            textBox_pass.Text = rememberData["Pass"]?.ToString();
                        }
                        else
                        {
                            chkRememberSession.Checked = false;
                        }
                        btnCheck.Visible = true;
                        label_user.Visible = false;
                        label_pass.Visible = false;
                        chkRememberSession.Visible = false;
                        textBox_user.Visible = false;
                        textBox_pass.Visible = false;
                        btn_login.Visible = false;
                    }
                });
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error al iniciar sesión: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                SetLoadingState(false);
            }
        }
        private void SetLoadingState(bool loading)
        {
            this.Invoke((Action)(() =>
            {
                btn_login.Enabled = !loading;
                textBox_user.Enabled = !loading;
                textBox_pass.Enabled = !loading;

                if (loading)
                {
                    btn_login.Text = "Conectando...";
                }
                else
                {
                    btn_login.Text = "Iniciar Sesión";
                }
            }));
        }
        private void OnLoginSuccess(UserData user)
        {
            this.Invoke((Action)(() =>
            {
                label_pass.Visible = false;
                label_user.Visible = false;
                textBox_pass.Visible = false;
                textBox_user.Visible = false;
                btn_login.Visible = false;
                chkRememberSession.Visible = false;

                lb_User.Visible = true;
                lb_Ip.Visible = true;

                lb_Ip.Text = $"IP: {user.IpAddress}";
                lb_User.Text = $"Usuario: {user.Username}";

                StartGameBtn.Visible = true;
            }));
        }

        private void OnLoginFailed(string error, LoginErrorType errorType)
        {
            this.Invoke((Action)(() =>
            {
                var friendlyMessage = _loginService.GetUserFriendlyErrorMessage(errorType);
                MessageBox.Show($"Error: {friendlyMessage}");

                // Acciones específicas según el tipo de error
                switch (errorType)
                {
                    case LoginErrorType.InvalidCredentials:
                        textBox_user.Clear();
                        textBox_pass.Focus();
                        break;

                    case LoginErrorType.BruteForceProtection:
                    case LoginErrorType.RateLimited:
                        // Deshabilitar login temporalmente
                        btn_login.Enabled = false;
                        var timer = new System.Windows.Forms.Timer();
                        timer.Interval = 60000; // 1 minuto
                        timer.Tick += (s, e) =>
                        {
                            timer.Stop();
                            timer.Dispose();
                            btn_login.Enabled = true;
                            MessageBox.Show("Puedes intentar nuevamente");
                        };
                        timer.Start();
                        break;
                }
            }));
        }

        private void OnLogout()
        {
            this.Invoke((Action)(() =>
            {
                textBox_pass.Clear();
            }));
        }

        private void textBox_user_MouseLeave(object sender, EventArgs e)
        {
            CheckUserExists();
        }
        private void CheckUserExists()
        {
            try
            {
                SafeInvoke(async () =>
                {
                    var username = textBox_user.Text?.Trim();

                    if (string.IsNullOrWhiteSpace(username))
                    {
                        lblStatus.Text = "";
                        return;
                    }

                    if (!LoginUtils.IsValidUsername(username))
                    {
                        lblStatus.Text = "Formato de usuario inválido";
                        lblStatus.ForeColor = Color.Red;
                        return;
                    }

                    lblStatus.Text = "Verificando...";
                    lblStatus.ForeColor = Color.Blue;

                    var exists = await _loginService.UserExistsAsync(username);

                    if (exists)
                    {
                        lblStatus.Text = "✓ Usuario encontrado";
                        lblStatus.ForeColor = Color.Green;
                    }
                    else
                    {
                        lblStatus.Text = "⚠ Usuario no encontrado";
                        lblStatus.ForeColor = Color.Orange;
                    }
                });
            }
            catch
            {
                lblStatus.Text = "Error verificando usuario";
                lblStatus.ForeColor = Color.White;
            }
        }

        private void textBox_pass_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == (char)Keys.Enter)
            {
                e.Handled = true;
                PerformLogin();
            }
        }

        private void btn_login_Click_1(object sender, EventArgs e)
        {
            SafeInvoke(() =>
            {
                if (!stateManager.CanStartGame())
                {
                    MessageBox.Show(
                        $"No se puede iniciar el juego en este momento.\n\nEstado: {stateManager.StateMessage}",
                        "No Disponible",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Warning
                    );
                    return;
                }

                

                PerformLogin();
            });
        }

        private async void StartGameBtn_Click(object sender, EventArgs e)
        {
            // Deshabilitar botón para evitar múltiples clics
            StartGameBtn.Enabled = true;

            try
            {

                if (!await ValidateGameStart())
                {
                    return;
                }

                // Mostrar estado en UI
                UpdateStatus("Iniciando juego...");
                await Task.Delay(100);
                // Inicializar estado del sistema
                await InitializeSystemStatus();

                // Esperar tiempo adecuado para que el estado se actualice
                await Task.Delay(1000); // 1 segundo como dice el comentario

                // Configurar y lanzar el juego
                var gameProcess = await StartGameProcess();
                if (gameProcess == null)
                {
                    UpdateStatus("Error: No se pudo iniciar el juego");
                    return;
                }

                UpdateStatus("Juego iniciado exitosamente");

                // Configurar servicios adicionales según configuración
                await ConfigureAdditionalServices(gameProcess);

            }
            catch (UnauthorizedAccessException ex)
            {
                MessageBox.Show(
                    "No tienes permisos para ejecutar el juego. Ejecuta como administrador.",
                    "Error de Permisos",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Warning
                );
            }
            catch (FileNotFoundException ex)
            {
                MessageBox.Show(
                    $"No se encontró el archivo del juego:\n{ex.FileName}",
                    "Archivo No Encontrado",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error
                );
            }
            catch (Exception ex)
            {
                MessageBox.Show(
                    $"Error inesperado al iniciar el juego:\n\n{ex.Message}",
                    "Error Crítico",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error
                );
            }
            finally
            {
                // Rehabilitar botón
                StartGameBtn.Enabled = true;
            }
        }
        private async Task<bool> ValidateGameStart()
        {
            // Verificar que existe el ejecutable
            string gameExePath = Path.Combine(Application.StartupPath, "PointBlank.exe");
            if (!File.Exists(gameExePath))
            {
                MessageBox.Show(
                    $"No se encontró PointBlank.exe en:\n{gameExePath}\n\nVerifica la instalación del juego.",
                    "Archivo Faltante",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error
                );
                return false;
            }

            // Verificar datos de usuario
            if (string.IsNullOrWhiteSpace(label_user.Text))
            {
                MessageBox.Show(
                    "Nombre de usuario no válido.",
                    "Error de Validación",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Warning
                );
                return false;
            }

            if (userData?.Token == null)
            {
                MessageBox.Show(
                    "Token de autenticación no válido. Vuelve a iniciar sesión.",
                    "Error de Autenticación",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Warning
                );
                return false;
            }

            // Verificar si hay otro proceso del juego ejecutándose
            var existingProcesses = Process.GetProcessesByName("PointBlank");
            if (existingProcesses.Length > 0)
            {
                var result = MessageBox.Show(
                    "Ya hay una instancia del juego ejecutándose. ¿Quieres cerrarla y continuar?",
                    "Juego ya ejecutándose",
                    MessageBoxButtons.YesNo,
                    MessageBoxIcon.Question
                );

                if (result == DialogResult.Yes)
                {
                    foreach (var proc in existingProcesses)
                    {
                        try
                        {
                            proc.Kill();
                            await Task.Delay(2000); // Esperar que se cierre
                        }
                        catch (Exception ex)
                        {
                            Console.WriteLine($"No se pudo cerrar proceso: {ex.Message}");
                        }
                    }
                }
                else
                {
                    return false;
                }
            }

            return true;
        }

        private Task<Process> StartGameProcess()
        {
            return Task.Run(() =>
            {
                try
                {
                    string gameExePath = Path.Combine(Application.StartupPath, "PointBlank.exe");
                    var processStartInfo = new ProcessStartInfo
                    {
                        FileName = gameExePath,
                        Arguments = $"{textBox_user.Text.ToLower()} {((userData.IpAddress == "127.0.0.1") ? textBox_pass.Text.ToLower() : userData.Token)}",
                        UseShellExecute = false,
                        CreateNoWindow = false,
                        WorkingDirectory = Application.StartupPath,
                        ErrorDialog = true
                    };

                    UpdateStatus("Lanzando PointBlank.exe...");
                    var process = Process.Start(processStartInfo);
                    return process; // Ensure a Process object is returned
                }
                catch (Exception ex)
                {
                    LogMessage($"❌ Error iniciando juego: {ex.Message}");
                    throw; // Re-throw the exception to handle it in the calling code
                }
            });
        }



        /// <summary>
        /// Configurar servicios adicionales (proxy, detección, etc.)
        /// </summary>
        private async Task ConfigureAdditionalServices(Process gameProcess)
        {
            try
            {
                if (systemConfig?.proxyEnabled == true)
                {
                    UpdateStatus("Configurando proxy...");

                    // Validar configuración de proxy
                    if (string.IsNullOrWhiteSpace(systemConfig.ProxyIp) || systemConfig.ProxyPort <= 0)
                    {
                        throw new InvalidOperationException("Configuración de proxy inválida");
                    }

                    // Iniciar GameAccess con manejo de errores
                    bool gameAccessStarted = await StartGameAccessSafely();
                    if (!gameAccessStarted)
                    {
                        UpdateStatus("Advertencia: No se pudo iniciar GameAccess");
                        return;
                    }

                    // Pequeña pausa antes de iniciar detección
                    await Task.Delay(500);

                    // Iniciar PBDetect
                    bool detectStarted = await StartPBDetectSafely();
                    if (detectStarted)
                    {
                        UpdateStatus("Servicios de proxy iniciados correctamente");
                    }
                    else
                    {
                        UpdateStatus("Advertencia: No se pudo iniciar PBDetect");
                    }

                    // Opcional: Cerrar launcher después de un tiempo
                    await ScheduleLauncherClose();
                }
                else
                {

                    if (!gameProcess.HasExited)
                    {
                        UpdateStatus("Juego funcionando correctamente. Cerrando launcher...");

                        // Cerrar de forma más elegante
                        this.Invoke(new Action(() => {
                            this.WindowState = FormWindowState.Minimized;
                            this.ShowInTaskbar = false;
                            // O cerrar completamente:
                            Application.Exit();
                        }));
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"⚠️ Error configurando servicios adicionales: {ex.Message}");
                UpdateStatus($"Advertencia: {ex.Message}");
                // No lanzar excepción aquí, ya que el juego principal ya se inició
            }
        }

        /// <summary>
        /// Iniciar GameAccess de forma segura
        /// </summary>
        private async Task<bool> StartGameAccessSafely()
        {
            try
            {
                GameAccess.Start(39190, 39191, systemConfig.ProxyIp, systemConfig.ProxyPort);
                await Task.Delay(1000); // Dar tiempo para que se inicie

                // Aquí podrías agregar verificación de que GameAccess se inició correctamente
                Console.WriteLine("✅ GameAccess iniciado");
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Error iniciando GameAccess: {ex.Message}");
                return false;
            }
        }

        /// <summary>
        /// Iniciar PBDetect de forma segura
        /// </summary>
        private async Task<bool> StartPBDetectSafely()
        {
            try
            {
                PBDetect.Start();
                await Task.Delay(500);

                Console.WriteLine("✅ PBDetect iniciado");
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Error iniciando PBDetect: {ex.Message}");
                return false;
            }
        }

        /// <summary>
        /// Programar cierre del launcher (opcional)
        /// </summary>
        private async Task ScheduleLauncherClose()
        {
            // Esperar un tiempo antes de considerar cerrar el launcher
            await Task.Delay(10000); // 10 segundos

            // Verificar si el usuario quiere mantener el launcher abierto
            var result = MessageBox.Show(
                "¿Quieres cerrar el launcher ahora que el juego está funcionando?",
                "Cerrar Launcher",
                MessageBoxButtons.YesNo,
                MessageBoxIcon.Question
            );

            if (result == DialogResult.Yes)
            {
                this.Invoke(new Action(() => Application.Exit()));
            }
        }

        /// <summary>
        /// Actualizar estado en la UI
        /// </summary>
        private void UpdateStatus(string message)
        {
            if (this.InvokeRequired)
            {
                this.Invoke(new Action<string>(UpdateStatus), message);
                return;
            }

            Console.WriteLine($"🎮 {DateTime.Now:HH:mm:ss} - {message}");

            // Si tienes un label de estado, actualizarlo
            // labelStatus.Text = message;
        }

        private async void PBDetect_Tick(object sender, EventArgs e)
        {
            try
            {
                Process[] PB = Process.GetProcessesByName("PointBlank");
                if (PB.Length == 0)
                {
                    await Task.Delay(1000);
                    LogMessage("[><] The game has ended");
                    Environment.Exit(0);
                }
                else
                {
                    try
                    {
                        if (Process.GetProcessesByName("Taskmgr").Length > 0 ||
                            Process.GetProcessesByName("perfmon").Length > 0)
                        {
                            LogMessage("[><] The game is Forced to Close [Task]");
                            var PBK = Process.GetProcessesByName("PointBlank");
                            foreach (var pb in PBK)
                                pb.Kill();
                        }
                    }

                    catch (Exception arg)
                    {
                        //Logger.Log("[!] Error [" + arg.Message + "]");
                    }
                }
            }
            catch (Exception arg)
            {
                // Logger.Log("[!] Exception [" + arg.Message + "]");
            }
        }
    }
}