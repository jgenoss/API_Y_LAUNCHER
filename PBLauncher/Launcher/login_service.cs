using System;
using System.Threading.Tasks;
using System.Collections.Generic;
using Newtonsoft.Json;

namespace PBLauncher
{
    // ==================== MODELOS DE DATOS ====================
    
    public class LoginRequest
    {
        [JsonProperty("username")]
        public string Username { get; set; }
        
        [JsonProperty("password")]
        public string Password { get; set; }
    }

    public class LoginResponse
    {
        [JsonProperty("success")]
        public bool Success { get; set; }
        
        [JsonProperty("message")]
        public string Message { get; set; }
        
        [JsonProperty("error_code")]
        public string ErrorCode { get; set; }
        
        [JsonProperty("user_data")]
        public UserData UserData { get; set; }
        
        [JsonProperty("player_id")]
        public int PlayerId { get; set; }
        
        [JsonProperty("session_info")]
        public SessionInfo SessionInfo { get; set; }
    }

    public class UserData
    {
        [JsonProperty("player_id")]
        public int PlayerId { get; set; }
        
        [JsonProperty("username")]
        public string Username { get; set; }
        
        [JsonProperty("created_at")]
        public string CreatedAt { get; set; }
        
        [JsonProperty("last_login")]
        public string LastLogin { get; set; }
    }

    public class SessionInfo
    {
        [JsonProperty("login_time")]
        public string LoginTime { get; set; }
        
        [JsonProperty("ip_address")]
        public string IpAddress { get; set; }
    }

    public class VerifyAccountRequest
    {
        [JsonProperty("username")]
        public string Username { get; set; }
    }

    public class VerifyAccountResponse
    {
        [JsonProperty("success")]
        public bool Success { get; set; }
        
        [JsonProperty("exists")]
        public bool Exists { get; set; }
        
        [JsonProperty("account_info")]
        public AccountInfo AccountInfo { get; set; }
    }

    public class AccountInfo
    {
        [JsonProperty("username")]
        public string Username { get; set; }
        
        [JsonProperty("player_id")]
        public int PlayerId { get; set; }
        
        [JsonProperty("created_at")]
        public string CreatedAt { get; set; }
    }

    // ==================== ENUMS Y EXCEPCIONES ====================
    
    public enum LoginErrorType
    {
        None,
        NetworkError,
        InvalidCredentials,
        ServerError,
        RateLimited,
        InvalidInput,
        BruteForceProtection,
        Unknown
    }

    public class LoginException : Exception
    {
        public LoginErrorType ErrorType { get; }
        public string ErrorCode { get; }
        public int StatusCode { get; }

        public LoginException(string message, LoginErrorType errorType = LoginErrorType.Unknown, 
                             string errorCode = "", int statusCode = 0) : base(message)
        {
            ErrorType = errorType;
            ErrorCode = errorCode;
            StatusCode = statusCode;
        }
    }

    // ==================== SERVICIO PRINCIPAL DE LOGIN ====================

    public class LoginService : IDisposable
    {
        private readonly Axios _axios;
        private readonly string _serverUrl;
        
        public UserData CurrentUser { get; private set; }
        public bool IsLoggedIn => CurrentUser != null;
        
        // Eventos para notificar cambios de estado
        public event Action<UserData> OnLoginSuccess;
        public event Action<string, LoginErrorType> OnLoginFailed;
        public event Action OnLogout;

        public LoginService(string serverUrl = "http://localhost:5000")
        {
            _serverUrl = serverUrl.TrimEnd('/');
            
            // Configurar Axios con headers por defecto
            var defaultHeaders = new Dictionary<string, string>
            {
                ["User-Agent"] = "PBLauncher/1.0",
                ["Accept"] = "application/json"
            };
            
            _axios = new Axios(_serverUrl, defaultHeaders);
        }

        /// <summary>
        /// Realizar login con el servidor
        /// </summary>
        /// <param name="username">Nombre de usuario</param>
        /// <param name="password">Contraseña</param>
        /// <returns>True si el login fue exitoso</returns>
        public async Task<bool> LoginAsync(string username, string password)
        {
            try
            {
                // Validaciones básicas
                if (string.IsNullOrWhiteSpace(username) || string.IsNullOrWhiteSpace(password))
                {
                    var error = "Usuario y contraseña son requeridos";
                    OnLoginFailed?.Invoke(error, LoginErrorType.InvalidInput);
                    return false;
                }

                // Preparar request
                var loginRequest = new LoginRequest
                {
                    Username = username.Trim(),
                    Password = password
                };

                // Realizar petición usando Axios
                var response = await _axios.Post<LoginResponse>("api/account/login", loginRequest);

                // Verificar si la respuesta fue exitosa
                if (response.Status >= 200 && response.Status < 300 && response.Data?.Success == true)
                {
                    // Login exitoso
                    CurrentUser = response.Data.UserData;
                    OnLoginSuccess?.Invoke(CurrentUser);
                    
                    // Opcional: Guardar sesión localmente
                    SaveUserSession(CurrentUser);
                    
                    return true;
                }
                else
                {
                    // Login falló
                    var errorMessage = response.Data?.Message ?? "Error desconocido";
                    var errorType = GetErrorTypeFromCode(response.Data?.ErrorCode, response.Status);
                    
                    OnLoginFailed?.Invoke(errorMessage, errorType);
                    return false;
                }
            }
            catch (AxiosException ex)
            {
                var errorMessage = $"Error de conexión: {ex.Message}";
                OnLoginFailed?.Invoke(errorMessage, LoginErrorType.NetworkError);
                return false;
            }
            catch (Exception ex)
            {
                var errorMessage = $"Error inesperado: {ex.Message}";
                OnLoginFailed?.Invoke(errorMessage, LoginErrorType.Unknown);
                return false;
            }
        }

        /// <summary>
        /// Verificar si un usuario existe en el servidor
        /// </summary>
        /// <param name="username">Nombre de usuario a verificar</param>
        /// <returns>True si el usuario existe</returns>
        public async Task<bool> UserExistsAsync(string username)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(username))
                    return false;

                var request = new VerifyAccountRequest { Username = username.Trim() };
                var response = await _axios.Post<VerifyAccountResponse>("api/account/verify", request);

                return response.Status >= 200 && response.Status < 300 && 
                       response.Data?.Success == true && response.Data.Exists;
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// Obtener información de una cuenta sin hacer login
        /// </summary>
        /// <param name="username">Nombre de usuario</param>
        /// <returns>Información de la cuenta o null si no existe</returns>
        public async Task<AccountInfo> GetAccountInfoAsync(string username)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(username))
                    return null;

                var request = new VerifyAccountRequest { Username = username.Trim() };
                var response = await _axios.Post<VerifyAccountResponse>("api/account/verify", request);

                if (response.Status >= 200 && response.Status < 300 && 
                    response.Data?.Success == true && response.Data.Exists)
                {
                    return response.Data.AccountInfo;
                }

                return null;
            }
            catch
            {
                return null;
            }
        }

        /// <summary>
        /// Cerrar sesión
        /// </summary>
        public void Logout()
        {
            CurrentUser = null;
            ClearUserSession();
            OnLogout?.Invoke();
        }

        /// <summary>
        /// Restaurar sesión guardada localmente
        /// </summary>
        /// <returns>True si se pudo restaurar una sesión</returns>
        public bool RestoreSession()
        {
            try
            {
                var savedUser = LoadUserSession();
                if (savedUser != null)
                {
                    CurrentUser = savedUser;
                    return true;
                }
            }
            catch
            {
                // Ignorar errores de carga
            }

            return false;
        }

        /// <summary>
        /// Verificar conectividad con el servidor
        /// </summary>
        /// <returns>True si el servidor está disponible</returns>
        public async Task<bool> TestConnectionAsync()
        {
            try
            {
                // Intentar hacer una petición simple al servidor
                var response = await _axios.Get<object>("api/status");
                return response.Status >= 200 && response.Status < 300;
            }
            catch
            {
                return false;
            }
        }

        // ==================== MÉTODOS AUXILIARES ====================

        private LoginErrorType GetErrorTypeFromCode(string errorCode, int statusCode)
        {
            if (string.IsNullOrEmpty(errorCode))
            {
                return statusCode switch
                {
                    401 => LoginErrorType.InvalidCredentials,
                    429 => LoginErrorType.RateLimited,
                    500 => LoginErrorType.ServerError,
                    _ => LoginErrorType.Unknown
                };
            }

            return errorCode switch
            {
                "INVALID_CREDENTIALS" => LoginErrorType.InvalidCredentials,
                "INVALID_INPUT" => LoginErrorType.InvalidInput,
                "DATABASE_ERROR" => LoginErrorType.ServerError,
                "INTERNAL_ERROR" => LoginErrorType.ServerError,
                "BRUTE_FORCE_USERNAME" => LoginErrorType.BruteForceProtection,
                "BRUTE_FORCE_IP" => LoginErrorType.BruteForceProtection,
                _ => LoginErrorType.Unknown
            };
        }

        public string GetUserFriendlyErrorMessage(LoginErrorType errorType)
        {
            return errorType switch
            {
                LoginErrorType.NetworkError => "No se pudo conectar al servidor. Verifica tu conexión a internet.",
                LoginErrorType.InvalidCredentials => "Usuario o contraseña incorrectos. Verifica tus datos.",
                LoginErrorType.ServerError => "Error interno del servidor. Inténtalo más tarde.",
                LoginErrorType.RateLimited => "Demasiados intentos. Espera unos minutos antes de intentar nuevamente.",
                LoginErrorType.InvalidInput => "Los datos ingresados contienen caracteres no permitidos.",
                LoginErrorType.BruteForceProtection => "Demasiados intentos fallidos. Espera 15 minutos antes de intentar nuevamente.",
                _ => "Error desconocido. Contacta al soporte técnico."
            };
        }

        // ==================== PERSISTENCIA LOCAL (OPCIONAL) ====================

        private void SaveUserSession(UserData user)
        {
            try
            {
                // Ejemplo usando Registry de Windows
                var key = Microsoft.Win32.Registry.CurrentUser.CreateSubKey(@"SOFTWARE\PBLauncher\Session");
                key?.SetValue("UserData", JsonConvert.SerializeObject(user));
                key?.Close();
            }
            catch
            {
                // Ignorar errores de guardado
            }
        }

        private UserData LoadUserSession()
        {
            try
            {
                var key = Microsoft.Win32.Registry.CurrentUser.OpenSubKey(@"SOFTWARE\PBLauncher\Session");
                var userData = key?.GetValue("UserData")?.ToString();
                key?.Close();

                if (!string.IsNullOrEmpty(userData))
                {
                    return JsonConvert.DeserializeObject<UserData>(userData);
                }
            }
            catch
            {
                // Ignorar errores
            }

            return null;
        }

        private void ClearUserSession()
        {
            try
            {
                Microsoft.Win32.Registry.CurrentUser.DeleteSubKey(@"SOFTWARE\PBLauncher\Session", false);
            }
            catch
            {
                // Ignorar errores
            }
        }

        public void Dispose()
        {
            _axios?.Dispose();
        }
    }

    // ==================== CLASE DE UTILIDADES ====================

    public static class LoginUtils
    {
        /// <summary>
        /// Validar formato de username básico
        /// </summary>
        public static bool IsValidUsername(string username)
        {
            if (string.IsNullOrWhiteSpace(username))
                return false;

            if (username.Length > 64)
                return false;

            // Verificar caracteres básicos (letras, números, guiones bajos)
            foreach (char c in username)
            {
                if (!char.IsLetterOrDigit(c) && c != '_' && c != '-')
                    return false;
            }

            return true;
        }

        /// <summary>
        /// Validar longitud mínima de contraseña
        /// </summary>
        public static bool IsValidPasswordLength(string password)
        {
            return !string.IsNullOrEmpty(password) && password.Length >= 3 && password.Length <= 64;
        }

        /// <summary>
        /// Limpiar y preparar username para envío
        /// </summary>
        public static string SanitizeUsername(string username)
        {
            return username?.Trim()?.ToLowerInvariant() ?? "";
        }
    }
}