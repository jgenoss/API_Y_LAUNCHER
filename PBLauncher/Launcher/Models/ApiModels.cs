using Newtonsoft.Json;
using System;
using System.Collections.Generic;

namespace PBLauncher.Models
{
    // Respuesta de verificación de HWID actualizada
    public class HwidCheckResponse
    {
        [JsonProperty("status")]
        public string Status { get; set; }

        [JsonProperty("message")]
        public string Message { get; set; }

        [JsonProperty("is_banned")]
        public bool IsBanned { get; set; }

        [JsonProperty("maintenance_mode")]
        public bool MaintenanceMode { get; set; }

        [JsonProperty("ban_reason")]
        public string BanReason { get; set; }

        [JsonProperty("banned_since")]
        public string BannedSince { get; set; }

        [JsonProperty("new_registration")]
        public bool? NewRegistration { get; set; }

        [JsonProperty("first_seen")]
        public string FirstSeen { get; set; }
    }
    // Información del launcher actualizada
    public class LauncherVersionInfo
    {
        [JsonProperty("version")]
        public string Version { get; set; }

        [JsonProperty("file_name")]
        public string FileName { get; set; }

        [JsonProperty("maintenance_mode")]
        public bool MaintenanceMode { get; set; }

        [JsonProperty("status")]
        public string Status { get; set; }

        [JsonProperty("message")]
        public string Message { get; set; }
    }
    public class MaintenanceModeData
    {
        public bool Enabled { get; set; }
        public string Message { get; set; }

        public bool IsActive => Enabled;
        public bool IsTest => !Enabled && !string.IsNullOrEmpty(Message);
    }
    // Configuración pública del sistema
    public class SystemConfig
    {
        [JsonProperty("launcher_base_url")]
        public string LauncherBaseUrl { get; set; }

        [JsonProperty("update_check_interval")]
        public int UpdateCheckInterval { get; set; }

        [JsonProperty("max_download_retries")]
        public int MaxDownloadRetries { get; set; }

        [JsonProperty("connection_timeout")]
        public int ConnectionTimeout { get; set; }

        [JsonProperty("auto_update_enabled")]
        public bool AutoUpdateEnabled { get; set; }

        [JsonProperty("force_ssl")]
        public bool ForceSsl { get; set; }

        [JsonProperty("maintenance_mode")]
        public bool MaintenanceMode { get; set; }

        [JsonProperty("debug_mode")]
        public bool DebugMode { get; set; }

        [JsonProperty("proxy_enabled")]
        public bool proxyEnabled { get; set; }

        [JsonProperty("proxy_port")]
        public int ProxyPort { get; set; }

        [JsonProperty("proxy_ip")]
        public string ProxyIp { get; set; }
    }

    // Estado del sistema actualizado
    public class SystemStatus
    {
        [JsonProperty("status")]
        public string Status { get; set; }

        [JsonProperty("maintenance_mode")]
        public bool MaintenanceMode { get; set; }

        [JsonProperty("maintenance_message")]
        public string MaintenanceMessage { get; set; }

        [JsonProperty("latest_game_version")]
        public string LatestGameVersion { get; set; }

        [JsonProperty("current_launcher_version")]
        public string CurrentLauncherVersion { get; set; }

        [JsonProperty("total_files")]
        public int TotalFiles { get; set; }

        [JsonProperty("total_updates")]
        public int TotalUpdates { get; set; }

        [JsonProperty("system_config")]
        public SystemConfig SystemConfig { get; set; }

        [JsonProperty("system_stats")]
        public SystemStats SystemStats { get; set; }

        [JsonProperty("timestamp")]
        public string Timestamp { get; set; }
    }

    // Estadísticas del sistema
    public class SystemStats
    {
        [JsonProperty("is_online")]
        public bool IsOnline { get; set; }

        [JsonProperty("is_maintenance")]
        public bool IsMaintenance { get; set; }

        [JsonProperty("active_downloads")]
        public int ActiveDownloads { get; set; }

        [JsonProperty("total_connections")]
        public int TotalConnections { get; set; }

        [JsonProperty("total_requests_today")]
        public int TotalRequestsToday { get; set; }

        [JsonProperty("failed_requests_today")]
        public int FailedRequestsToday { get; set; }

        [JsonProperty("last_updated")]
        public string LastUpdated { get; set; }
    }

    // Datos del servidor actualizados
    public class ServerData
    {
        [JsonProperty("latest_version")]
        public string LatestVersion { get; set; }

        [JsonProperty("updates")]
        public string[] Updates { get; set; }

        [JsonProperty("file_hashes")]
        public FileHashInfo[] FileHashes { get; set; }

        [JsonProperty("maintenance_mode")]
        public bool MaintenanceMode { get; set; }

        [JsonProperty("auto_update_enabled")]
        public bool AutoUpdateEnabled { get; set; }

        [JsonProperty("force_ssl")]
        public bool ForceSsl { get; set; }

        [JsonProperty("update_check_interval")]
        public int UpdateCheckInterval { get; set; }

        [JsonProperty("status")]
        public string Status { get; set; }

        [JsonProperty("message")]
        public string Message { get; set; }
    }

    // Información de hash de archivos
    public class FileHashInfo
    {
        [JsonProperty("FileName")]
        public string FileName { get; set; }

        [JsonProperty("MD5Hash")]
        public string MD5Hash { get; set; }

        [JsonProperty("RelativePath")]
        public string RelativePath { get; set; }
    }

    // Mensajes/noticias del sistema
    public class NewsMessage
    {
        [JsonProperty("id")]
        public int Id { get; set; }

        [JsonProperty("type")]
        public string Type { get; set; }

        [JsonProperty("message")]
        public string Message { get; set; }

        [JsonProperty("priority")]
        public int Priority { get; set; }

        [JsonProperty("created_at")]
        public string CreatedAt { get; set; }
    }

    // Respuesta de la API con manejo de errores
    public class ApiResponse<T>
    {
        [JsonProperty("success")]
        public bool Success { get; set; }

        [JsonProperty("data")]
        public T Data { get; set; }

        [JsonProperty("error")]
        public string Error { get; set; }

        [JsonProperty("status_code")]
        public int StatusCode { get; set; }

        [JsonProperty("maintenance_mode")]
        public bool? MaintenanceMode { get; set; }

        [JsonProperty("message")]
        public string Message { get; set; }
    }
}