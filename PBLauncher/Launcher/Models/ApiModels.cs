using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Text.Json.Serialization;

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

        [JsonPropertyName("RelativePath")]
        public string RelativePath { get; set; }

        [JsonPropertyName("relative_path")]
        public string relative_path { set => RelativePath = value; }
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
    // ============================================================================
    // AGREGAR ESTOS MODELOS AL FINAL DE ApiModels.cs
    // ============================================================================

    /// <summary>
    /// Respuesta del endpoint /repair_files
    /// </summary>
    public class RepairFilesResponse
    {
        [JsonProperty("success")]
        public bool Success { get; set; }

        [JsonProperty("total_files")]
        public int TotalFiles { get; set; }

        [JsonProperty("files")]
        public RepairFileInfo[] Files { get; set; }

        [JsonProperty("verification_info")]
        public VerificationInfo VerificationInfo { get; set; }
    }

    /// <summary>
    /// Información de cada archivo para reparación
    /// </summary>
    public class RepairFileInfo
    {
        [JsonProperty("filename")]
        public string FileName { get; set; }

        [JsonProperty("md5")]
        public string MD5Hash { get; set; }

        [JsonProperty("path")]
        public string RelativePath { get; set; }

        [JsonProperty("size")]
        public long FileSize { get; set; }

        [JsonProperty("created_at")]
        public string CreatedAt { get; set; }

        [JsonProperty("updated_at")]
        public string UpdatedAt { get; set; }

        [JsonProperty("verify_url")]
        public string VerifyUrl { get; set; }
    }

    /// <summary>
    /// Información adicional sobre la verificación
    /// </summary>
    public class VerificationInfo
    {
        [JsonProperty("total_size")]
        public long TotalSize { get; set; }

        [JsonProperty("files_with_md5")]
        public int FilesWithMd5 { get; set; }

        [JsonProperty("verify_all_url")]
        public string VerifyAllUrl { get; set; }
    }

    /// <summary>
    /// Respuesta del endpoint /file/<filename>/verify
    /// </summary>
    public class FileVerificationResponse
    {
        [JsonProperty("success")]
        public bool Success { get; set; }

        [JsonProperty("filename")]
        public string FileName { get; set; }

        [JsonProperty("md5")]
        public string ExpectedMD5 { get; set; }

        [JsonProperty("calculated_md5")]
        public string CalculatedMD5 { get; set; }

        [JsonProperty("md5_match")]
        public bool MD5Match { get; set; }

        [JsonProperty("file_exists")]
        public bool FileExists { get; set; }

        [JsonProperty("integrity_status")]
        public string IntegrityStatus { get; set; }

        [JsonProperty("size")]
        public long FileSize { get; set; }

        [JsonProperty("download_url")]
        public string DownloadUrl { get; set; }

        [JsonProperty("error")]
        public string Error { get; set; }
    }
}