using Newtonsoft.Json;
using PBLauncher.Models;
using System;
using System.Net.Http;
using System.Threading.Tasks;

namespace PBLauncher.Services
{
    public class SystemStatusService
    {
        private readonly HttpClient _httpClient;
        private readonly string _apiBaseUrl;
        private SystemStatus _lastKnownStatus;
        private DateTime _lastStatusCheck;
        private readonly TimeSpan _statusCacheTime = TimeSpan.FromMinutes(1);
        Axios axios;

        public SystemStatusService(string apiBaseUrl)
        {
            // ✅ NORMALIZAR URL BASE - quitar slash final si existe
            _apiBaseUrl = apiBaseUrl.TrimEnd('/');
            axios = new Axios(_apiBaseUrl);
            _httpClient = new HttpClient();
            _httpClient.Timeout = TimeSpan.FromSeconds(30);
        }

        public async Task<SystemStatus> GetSystemStatusAsync(bool forceRefresh = false)
        {
            try
            {
                // Usar caché si no es necesario refrescar
                if (!forceRefresh && _lastKnownStatus != null &&
                    DateTime.Now - _lastStatusCheck < _statusCacheTime)
                {
                    return _lastKnownStatus;
                }

                // ✅ CONSTRUIR URL CORRECTAMENTE
                var response = await axios.Get<SystemStatus>("/status");

                _lastKnownStatus = response.Data;
                _lastStatusCheck = DateTime.Now;

                return response.Data;
            }
            catch (Exception ex)
            {
                LogMessage($"Error obteniendo estado del sistema: {ex.Message}");

                // Devolver estado offline si hay error
                return new SystemStatus
                {
                    Status = "offline",
                    MaintenanceMode = false,
                    MaintenanceMessage = "No se pudo conectar con el servidor"
                };
            }
        }

        public async Task<SystemConfig> GetSystemConfigAsync()
        {
            try
            {
                // ✅ CONSTRUIR URL CORRECTAMENTE
                var response = await axios.Get<SystemConfig>("/config");
                return response.Data;
            }
            catch (Exception ex)
            {
                LogMessage($"Error obteniendo configuración del sistema: {ex.Message}");

                // Devolver configuración por defecto
                return new SystemConfig
                {
                    AutoUpdateEnabled = true,
                    UpdateCheckInterval = 300,
                    MaxDownloadRetries = 3,
                    ConnectionTimeout = 30,
                    ForceSsl = false,
                    MaintenanceMode = false,
                    DebugMode = false
                };
            }
        }

        // ✅ MÉTODO HELPER PARA CONSTRUIR URLs (opcional, más robusto)
        private string BuildUrl(string endpoint)
        {
            return $"{_apiBaseUrl.TrimEnd('/')}/{endpoint.TrimStart('/')}";
        }

        public bool IsMaintenanceMode()
        {
            return _lastKnownStatus?.MaintenanceMode ?? false;
        }

        public string GetMaintenanceMessage()
        {
            return _lastKnownStatus?.MaintenanceMessage ?? "Sistema en mantenimiento";
        }

        public bool IsSystemOnline()
        {
            return _lastKnownStatus?.Status == "online";
        }

        private void LogMessage(string message)
        {
            try
            {
                string logEntry = $"[{DateTime.Now:yyyy-MM-dd HH:mm:ss}] [SystemStatusService] {message}";
                Console.WriteLine(logEntry);
                System.IO.File.AppendAllText("launcher.log", logEntry + Environment.NewLine);
            }
            catch
            {
                // Si no puede escribir al log, continuamos silenciosamente
            }
        }

        public void Dispose()
        {
            _httpClient?.Dispose();
        }
    }
}