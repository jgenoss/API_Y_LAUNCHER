using CefSharp;
using Newtonsoft.Json;
using PBLauncher.Models;
using PBLauncher.Services;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Net;
using System.Runtime.CompilerServices;
using System.Security.Policy;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace PBLauncher
{
    public partial class PleaseWait : Form
    {
        private Axios axios;
        private SystemStatusService statusService;
        private string apiBaseUrl = "http://192.168.18.31:5000/api";
        private int maxRetries = 3;
        private int currentRetry = 0;

        private bool isCheckingLauncherUpdate = false;
        private readonly object launcherUpdateLock = new object();
        private DateTime lastLauncherUpdateCheck = DateTime.MinValue;

        public PleaseWait()
        {
            InitializeComponent();
        }
        private void SafeUpdateLabel(Label label, string text)
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

                LogMessage("Verificando actualización del launcher...");
                axios = new Axios(apiBaseUrl);
                var json = await axios.Get<LauncherVersionInfo>($"/launcher_update");
                var info = json.Data;

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
                    await client.DownloadFileTaskAsync($"{apiBaseUrl}/LauncherUpdater.exe", updaterPath);

                    string versionedFileName = $"PBLauncher_v{info.Version}.exe";
                    LogMessage($"Iniciando actualización con archivo: {versionedFileName}");
                    Process.Start(updaterPath, $"\"{apiBaseUrl}\" \"{Application.ExecutablePath}\" \"{versionedFileName}\"");
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
        private async void PleaseWait_Load(object sender, EventArgs e)
        {
            try
            {
                if (File.Exists("./launcher.log"))
                {
                    File.Delete("./launcher.log");
                }

                await CheckLauncherUpdate();
                // Realizar detección completa
                var result = await HttpDebuggerDetector.DetectHttpDebuggersAsync();

                // Mostrar resultado
                HttpDebuggerDetector.ShowDetectionResultWithWhitelistOption(result, this);

                // Si hay procesos críticos, no permitir continuar
                if (result.OverallThreatLevel >= HttpDebuggerDetector.DetectionLevel.High)
                {
                    SafeUpdateLabel(lb_loading, "❌ No se puede continuar con herramientas de debugging activas");
                    lb_loading.ForeColor = Color.Red;
                }
                else
                {
                    SafeUpdateLabel(lb_loading, "✅ Verificación de seguridad completada");
                    lb_loading.ForeColor = Color.Green;
                }
                // Inicializar servicios
                axios = new Axios(apiBaseUrl);
                statusService = new SystemStatusService(apiBaseUrl);

                SafeUpdateLabel(lb_loading, "Verificando sistema...");
                await CheckSystemStatus();

            }
            catch (Exception ex)
            {
                ShowErrorAndExit($"Error de inicialización: {ex.Message}");
            }
        }

        private async Task CheckSystemStatus()
        {
            try
            {
                SafeUpdateLabel(lb_loading, "Verificando estado del servidor...");

                // Obtener estado del sistema
                SystemStatus systemStatus = await statusService.GetSystemStatusAsync(true);

                // Verificar si el sistema está en mantenimiento
                if (systemStatus.MaintenanceMode)
                {
                    ShowMaintenanceMessage(systemStatus.MaintenanceMessage);
                    return;
                }

                // Verificar si el sistema está offline
                if (systemStatus.Status != "online")
                {
                    await HandleOfflineSystem(systemStatus);
                    return;
                }

                // Si el sistema está online, proceder con verificación de dispositivo
                SafeUpdateLabel(lb_loading, "Verificando dispositivo...");
                await CheckEquipmentWithRetry();
            }
            catch (Exception ex)
            {
                LogMessage($"Error verificando estado del sistema: {ex.Message}");
                await HandleSystemError(ex);
            }
        }

        private async Task CheckEquipmentWithRetry()
        {
            try
            {
                currentRetry++;
                SafeUpdateLabel(lb_loading, $"Verificando dispositivo... (intento {currentRetry}/{maxRetries})");

                await CheckEquip();
            }
            catch (Exception ex)
            {
                LogMessage($"Error en verificación de dispositivo (intento {currentRetry}): {ex.Message}");

                if (currentRetry < maxRetries)
                {
                    SafeUpdateLabel(lb_loading, $"Reintentando en 3 segundos...");
                    await Task.Delay(3000);
                    await CheckEquipmentWithRetry();
                }
                else
                {
                    ShowErrorAndExit($"No se pudo verificar el dispositivo después de {maxRetries} intentos.\n\nÚltimo error: {ex.Message}");
                }
            }
        }

        private async Task CheckEquip()
        {
            try
            {
                // Obtener identificadores del hardware
                var postData = new
                {
                    hwid = HWID.GetHardwareID(),
                    serial = HWID.GetSerialNumber(),
                    mac = MacAddressHelper.GetMacAddress()
                };

                LogMessage($"Enviando verificación de dispositivo - HWID: {postData.hwid?.Substring(0, 8)}...");

                // Realizar la solicitud HTTP
                var response = await axios.Post<HwidCheckResponse>("/check", postData);

                // Verificar respuesta exitosa
                if (response?.Data == null)
                {
                    throw new Exception("Respuesta inválida del servidor");
                }

                await ProcessHwidResponse(response.Data);
            }
            catch (Exception ex)
            {
                LogMessage($"Error en verificación de dispositivo: {ex.Message}");
                throw;
            }
        }

        private async Task ProcessHwidResponse(HwidCheckResponse response)
        {
            LogMessage($"Respuesta del servidor: Status={response.Status}, IsBanned={response.IsBanned}, Maintenance={response.MaintenanceMode}");

            // Verificar modo mantenimiento (puede haber cambiado durante la verificación)
            if (response.MaintenanceMode)
            {
                ShowMaintenanceMessage("El sistema ha entrado en modo mantenimiento");
                return;
            }

            // Procesar según el estado
            switch (response.Status?.ToLower())
            {
                case "ok":
                    await HandleSuccessfulVerification(response);
                    break;

                case "banned":
                    HandleBannedDevice(response);
                    break;

                case "maintenance":
                    ShowMaintenanceMessage(response.Message ?? "Sistema en mantenimiento");
                    break;

                case "forbidden":
                    ShowErrorAndExit("Acceso denegado desde esta ubicación.");
                    break;

                default:
                    throw new Exception($"Estado desconocido del servidor: {response.Status}");
            }
        }

        private async Task HandleSuccessfulVerification(HwidCheckResponse response)
        {
            try
            {
                if (response.IsBanned)
                {
                    HandleBannedDevice(response);
                    return;
                }

                // Dispositivo verificado correctamente
                if (response.NewRegistration == true)
                {
                    LogMessage("Dispositivo registrado por primera vez");
                    SafeUpdateLabel(lb_loading, "Dispositivo registrado exitosamente...");
                }
                else
                {
                    LogMessage("Dispositivo verificado exitosamente");

                    SafeUpdateLabel(lb_loading, "Dispositivo verificado...");
                }

                await Task.Delay(1000); // Pequeña pausa para mostrar el mensaje

                // Proceder al launcher principal
                this.Invoke((MethodInvoker)delegate
                {
                    this.Hide();
                    var launcherForm = new LauncherForm();
                    launcherForm.Show();
                });
            }
            catch (Exception ex)
            {
                LogMessage($"Error procesando verificación exitosa: {ex.Message}");
                ShowErrorAndExit($"Error inesperado: {ex.Message}");
            }
        }

        private void HandleBannedDevice(HwidCheckResponse response)
        {
            string banMessage = "Dispositivo baneado";

            if (!string.IsNullOrEmpty(response.BanReason))
            {
                banMessage += $"\n\nRazón: {response.BanReason}";
            }

            if (!string.IsNullOrEmpty(response.BannedSince))
            {
                try
                {
                    var banDate = DateTime.Parse(response.BannedSince);
                    banMessage += $"\nDesde: {banDate:dd/MM/yyyy HH:mm}";
                }
                catch
                {
                    banMessage += $"\nDesde: {response.BannedSince}";
                }
            }

            banMessage += "\n\nSi crees que esto es un error, contacta al administrador.";

            LogMessage($"Dispositivo baneado - Razón: {response.BanReason}");

            MessageBox.Show(banMessage, "Acceso Denegado", MessageBoxButtons.OK, MessageBoxIcon.Error);
            Application.Exit();
        }

        private void ShowMaintenanceMessage(string message)
        {
            LogMessage($"Sistema en mantenimiento: {message}");

            string displayMessage = "🔧 Sistema en Mantenimiento\n\n";
            displayMessage += message ?? "El sistema está temporalmente fuera de servicio";
            displayMessage += "\n\nPor favor, intenta nuevamente más tarde.";

            var result = MessageBox.Show(
                displayMessage,
                "Mantenimiento del Sistema",
                MessageBoxButtons.RetryCancel,
                MessageBoxIcon.Information
            );

            if (result == DialogResult.Retry)
            {
                // Reiniciar verificación
                currentRetry = 0;
                Task.Run(async () => await CheckSystemStatus());
            }
            else
            {
                Application.Exit();
            }
        }

        private async Task HandleOfflineSystem(SystemStatus status)
        {
            string message = "❌ Servidor No Disponible\n\n";
            message += "No se pudo conectar con el servidor del juego.\n";
            message += "Verifica tu conexión a internet e intenta nuevamente.";

            LogMessage("Sistema offline - no se puede conectar");

            var result = MessageBox.Show(
                message,
                "Servidor No Disponible",
                MessageBoxButtons.RetryCancel,
                MessageBoxIcon.Warning
            );

            if (result == DialogResult.Retry)
            {
                currentRetry = 0;
                await Task.Delay(2000); // Esperar 2 segundos antes de reintentar
                await CheckSystemStatus();
            }
            else
            {
                Application.Exit();
            }
        }

        private async Task HandleSystemError(Exception ex)
        {
            string message = "⚠️ Error de Conexión\n\n";
            message += "Ocurrió un error al verificar el estado del sistema:\n";
            message += ex.Message;
            message += "\n\n¿Deseas intentar nuevamente?";

            LogMessage($"Error del sistema: {ex.Message}");

            var result = MessageBox.Show(
                message,
                "Error de Conexión",
                MessageBoxButtons.RetryCancel,
                MessageBoxIcon.Error
            );

            if (result == DialogResult.Retry)
            {
                currentRetry = 0;
                await Task.Delay(3000); // Esperar 3 segundos antes de reintentar
                await CheckSystemStatus();
            }
            else
            {
                Application.Exit();
            }
        }

        private void ShowErrorAndExit(string errorMessage)
        {
            LogMessage($"Error fatal: {errorMessage}");

            this.Invoke((MethodInvoker)delegate
            {
                MessageBox.Show(
                    errorMessage,
                    "Error",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error
                );
                Application.Exit();
            });
        }

        private void LogMessage(string message)
        {
            try
            {
                string logEntry = $"[{DateTime.Now:yyyy-MM-dd HH:mm:ss}] [PleaseWait] {message}";
                Console.WriteLine(logEntry);
                System.IO.File.AppendAllText("launcher.log", logEntry + Environment.NewLine);
            }
            catch
            {
                // Si no puede escribir al log, continuamos silenciosamente
            }
        }

        protected override void OnFormClosing(FormClosingEventArgs e)
        {
            try
            {
                statusService?.Dispose();
            }
            catch { }

            base.OnFormClosing(e);
        }
    }
}