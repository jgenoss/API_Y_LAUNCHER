using SocketIOClient;
using System;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PBLauncher.Models;
using System.Windows.Forms;
using System.Linq;
using SocketIO.Core;
using System.Collections.Generic;

namespace PBLauncher.Services
{
    public class SocketIOService : IDisposable
    {
        private SocketIOClient.SocketIO _client;
        private readonly string _serverUrl;
        private bool _isConnected = false;
        private bool _isConnecting = false;
        private bool _disposed = false;

        // Eventos para notificar cambios
        public event EventHandler<SystemStatus> SystemStatusChanged;
        public event EventHandler<NewsMessage[]> NewsUpdated;
        public event EventHandler<LauncherVersionInfo> LauncherUpdateAvailable;
        public event EventHandler<string> NewGameVersionAvailable;
        public event EventHandler<MaintenanceModeData> MaintenanceModeChanged;
        public event EventHandler<string> ConnectionStatusChanged;

        public bool IsConnected => _isConnected;

        public SocketIOService(string serverUrl)
        {
            _serverUrl = serverUrl.TrimEnd('/');
            LogMessage($"🔌 SocketIOService inicializado con URL: {_serverUrl}");
            InitializeClient();
        }

        private void InitializeClient()
        {
            try
            {
                var uri = new Uri($"{_serverUrl}/public");
                LogMessage($"🎯 Conectando a: {uri}");

                _client = new SocketIOClient.SocketIO(uri, new SocketIOOptions
                {
                    Reconnection = true,
                    ReconnectionAttempts = int.MaxValue, // ✅ NUEVO: Intentos infinitos
                    ReconnectionDelay = 1000,
                    ReconnectionDelayMax = 10000, // ✅ AUMENTADO: Máximo 10 segundos
                    RandomizationFactor = 0.5,
                    ConnectionTimeout = TimeSpan.FromSeconds(30), // ✅ AUMENTADO: 30 segundos

                    // ✅ NUEVO: Configuraciones adicionales para estabilidad
                    AutoUpgrade = false, // No cambiar de polling a websocket automáticamente
                    EIO = EngineIO.V4, // Usar Engine.IO v4
                });

                SetupEventHandlers();
                LogMessage("✅ Cliente SocketIO inicializado con configuración mejorada");
            }
            catch (Exception ex)
            {
                LogMessage($"❌ Error inicializando cliente SocketIO: {ex.Message}");
                LogMessage($"❌ Stack trace: {ex.StackTrace}");
            }
        }
        private void SetupConnectionMonitoring()
        {
            var monitoringTimer = new System.Timers.Timer(1000); // Cada 10 segundos
            monitoringTimer.Elapsed += async (sender, e) =>
            {
                try
                {
                    if (_isConnected)
                    {
                        // Verificar si la conexión sigue viva
                        var testPassed = await TestConnectionHealth();

                        if (!testPassed)
                        {
                            LogMessage("❌ Test de salud de conexión falló - marcando como desconectado");
                            _isConnected = false;
                            ConnectionStatusChanged?.Invoke(this, "Conexión perdida - reintentando...");

                            // Intentar reconectar
                            _ = Task.Run(async () => await ReconnectWithBackoff());
                        }
                    }
                }
                catch (Exception ex)
                {
                    LogMessage($"Error en monitoreo de conexión: {ex.Message}");
                }
            };

            monitoringTimer.Start();
            LogMessage("✅ Monitoreo de conexión iniciado");
        }

        private async Task<bool> TestConnectionHealth()
        {
            try
            {
                if (_client == null) return false;

                bool pongReceived = false;
                var timeoutTask = Task.Delay(1000); // 5 segundos timeout

                // Configurar handler temporal para pong
                void tempPongHandler(SocketIOResponse response)
                {
                    pongReceived = true;
                }

                _client.On("pong", tempPongHandler);

                // Enviar ping
                await _client.EmitAsync("ping");

                // Esperar pong o timeout
                var completedTask = await Task.WhenAny(
                    Task.Run(async () => {
                        while (!pongReceived && !timeoutTask.IsCompleted)
                        {
                            await Task.Delay(100);
                        }
                        return pongReceived;
                    }),
                    timeoutTask
                );

                // Limpiar handler temporal
                _client.Off("pong");

                bool isHealthy = completedTask != timeoutTask && pongReceived;
                LogMessage($"🩺 Test de salud: {(isHealthy ? "✅ SALUDABLE" : "❌ NO RESPONDE")}");

                return isHealthy;
            }
            catch (Exception ex)
            {
                LogMessage($"Error en test de salud: {ex.Message}");
                return false;
            }
        }
        private async Task ReconnectWithBackoff()
        {
            int attempt = 1;
            int maxDelay = 30000; // 30 segundos máximo

            while (!_isConnected && !_disposed && attempt <= 10)
            {
                try
                {
                    LogMessage($"🔄 Intento de reconexión #{attempt}");

                    // Limpiar conexión anterior
                    if (_client != null)
                    {
                        await _client.DisconnectAsync();
                        _client.Dispose();
                    }

                    // Crear nueva instancia
                    InitializeClient();

                    // Intentar conectar
                    bool connected = await ConnectAsync();

                    if (connected)
                    {
                        LogMessage($"✅ Reconectado exitosamente en intento #{attempt}");
                        SetupConnectionMonitoring(); // Reiniciar monitoreo
                        return;
                    }

                    // Calcular delay con backoff exponencial
                    int delay = Math.Min(1000 * (int)Math.Pow(2, attempt - 1), maxDelay);
                    LogMessage($"⏳ Esperando {delay}ms antes del siguiente intento...");

                    await Task.Delay(delay);
                    attempt++;
                }
                catch (Exception ex)
                {
                    LogMessage($"Error en intento de reconexión #{attempt}: {ex.Message}");
                    attempt++;
                }
            }

            if (!_isConnected)
            {
                LogMessage("❌ Falló la reconexión después de múltiples intentos");
                ConnectionStatusChanged?.Invoke(this, "Reconexión fallida - modo offline");
            }
        }
        private void SetupEventHandlers()
        {
            try
            {
                LogMessage("🔗 Configurando event handlers...");

                // ✅ Eventos de conexión básicos
                _client.OnConnected += async (sender, e) => {
                    LogMessage("✅ ¡CONECTADO a SocketIO!");
                    await OnConnected();
                };

                _client.OnDisconnected += async (sender, e) => {
                    LogMessage($"❌ DESCONECTADO de SocketIO: {e}");
                    await OnDisconnected(e);
                };

                _client.OnReconnected += async (sender, e) => {
                    LogMessage($"🔄 RECONECTADO a SocketIO (intento {e})");
                    await OnReconnected(e);
                };

                _client.OnReconnectFailed += async (sender, e) => {
                    LogMessage("❌ FALLÓ LA RECONEXIÓN a SocketIO");
                    await OnReconnectFailed();
                };

                _client.OnError += (sender, e) => {
                    LogMessage($"❌ ERROR SocketIO: {e}");
                    OnError(e);
                };

                // ✅ EVENTOS DEL SISTEMA CON LOGGING DETALLADO
                _client.On("connection_status", (response) => {
                    LogMessage("📡 Evento 'connection_status' recibido");
                    LogMessage($"📡 Raw data: {response.ToString()}");
                    OnConnectionStatus(response);
                });

                _client.On("initial_data", (response) => {
                    LogMessage("📋 ¡EVENTO 'initial_data' RECIBIDO!");
                    LogMessage($"📋 Raw data: {response.ToString()}");
                    OnInitialData(response);
                });

                _client.On("system_status_changed", (response) => {
                    LogMessage("📊 Evento 'system_status_changed' recibido");
                    LogMessage($"📊 Raw data: {response.ToString()}");
                    OnSystemStatusChanged(response);
                });

                _client.On("maintenance_mode_changed", (response) => {
                    LogMessage("🔧 ¡EVENTO 'maintenance_mode_changed' RECIBIDO!");
                    LogMessage($"🔧 Raw data: {response.ToString()}");
                    OnMaintenanceModeChanged(response);
                });

                _client.On("new_version_available", (response) => {
                    LogMessage("🎮 ¡EVENTO 'new_version_available' RECIBIDO!");
                    LogMessage($"🎮 Raw data: {response.ToString()}");
                    OnNewVersionAvailable(response);
                });

                _client.On("launcher_update_available", (response) => {
                    LogMessage("🚀 ¡EVENTO 'launcher_update_available' RECIBIDO!");
                    LogMessage($"🚀 Raw data: {response.ToString()}");
                    OnLauncherUpdateAvailable(response);
                });

                _client.On("stats_update", (response) => {
                    LogMessage("📈 Evento 'stats_update' recibido");
                    LogMessage($"📈 Raw data: {response.ToString()}");
                    OnStatsUpdate(response);
                });

                _client.On("notification", (response) => {
                    LogMessage("🔔 Evento 'notification' recibido");
                    LogMessage($"🔔 Raw data: {response.ToString()}");
                    OnNotification(response);
                });

                _client.On("pong", (response) => {
                    LogMessage("🏓 Pong recibido");
                    OnPong(response);
                });

                LogMessage("✅ Todos los event handlers configurados");
            }
            catch (Exception ex)
            {
                LogMessage($"❌ Error configurando event handlers: {ex.Message}");
                LogMessage($"❌ Stack trace: {ex.StackTrace}");
            }
        }

        public async Task<bool> ConnectAsync()
        {
            if (_isConnected || _isConnecting || _disposed)
            {
                LogMessage($"⚠️ Conexión ya en progreso o establecida. Conectado: {_isConnected}, Conectando: {_isConnecting}, Disposed: {_disposed}");
                return _isConnected;
            }

            try
            {
                _isConnecting = true;
                LogMessage("🔌 Iniciando conexión a SocketIO...");

                await _client.ConnectAsync();
                LogMessage("🔌 ConnectAsync() completado");

                // ✅ Esperar confirmación de conexión
                int attempts = 0;
                while (!_isConnected && attempts < 10)
                {
                    await Task.Delay(500);
                    attempts++;
                    LogMessage($"⏳ Esperando confirmación de conexión... intento {attempts}");
                }

                if (_isConnected)
                {
                    LogMessage("✅ Conexión confirmada, solicitando datos iniciales...");
                    await RequestInitialData();

                    // ✅ Enviar ping de prueba
                    await Task.Delay(1000);
                    await Ping();

                    LogMessage("✅ Proceso de conexión completado exitosamente");
                    return true;
                }
                else
                {
                    LogMessage("❌ Conexión no confirmada después de esperar");
                    return false;
                }
            }
            catch (Exception ex)
            {
                LogMessage($"❌ Excepción conectando a SocketIO: {ex.Message}");
                LogMessage($"❌ Stack trace: {ex.StackTrace}");
                return false;
            }
            finally
            {
                _isConnecting = false;
            }
        }

        public async Task DisconnectAsync()
        {
            if (_client != null && _isConnected)
            {
                try
                {
                    LogMessage("🔌 Desconectando de SocketIO...");
                    await _client.DisconnectAsync();
                    LogMessage("✅ Desconectado de SocketIO exitosamente");
                }
                catch (Exception ex)
                {
                    LogMessage($"❌ Error desconectando de SocketIO: {ex.Message}");
                }
            }
        }

        public async Task RequestInitialData()
        {
            if (_isConnected)
            {
                try
                {
                    LogMessage("📨 Solicitando datos iniciales...");
                    await _client.EmitAsync("request_initial_data");
                    LogMessage("✅ Solicitud de datos iniciales enviada");
                }
                catch (Exception ex)
                {
                    LogMessage($"❌ Error solicitando datos iniciales: {ex.Message}");
                }
            }
            else
            {
                LogMessage("⚠️ No se pueden solicitar datos iniciales - no conectado");
            }
        }

        // ✅ Event Handlers mejorados con logging detallado
        private async Task OnConnected()
        {
            await Task.Run(() =>
            {
                _isConnected = true;
                LogMessage("✅ OnConnected() ejecutado - marcando como conectado");
                ConnectionStatusChanged?.Invoke(this, "Conectado al servidor en tiempo real");
            });
        }


        private async Task OnDisconnected(string reason)
        {
            await Task.Run(() =>
            {
                _isConnected = false;
                LogMessage($"❌ OnDisconnected() ejecutado - Razón: {reason}");
                ConnectionStatusChanged?.Invoke(this, "Desconectado del servidor");
            });
        }

        private async Task OnReconnected(int attempts)
        {
            _isConnected = true;
            LogMessage($"🔄 OnReconnected() ejecutado - Intentos: {attempts}");
            ConnectionStatusChanged?.Invoke(this, "Reconectado al servidor");

            // Solicitar datos actualizados después de reconectar
            await Task.Delay(1000);
            await RequestInitialData();
        }

        private async Task OnReconnectFailed()
        {
            await Task.Run(() =>
            {
                _isConnected = false;
                LogMessage("❌ OnReconnectFailed() ejecutado");
                ConnectionStatusChanged?.Invoke(this, "Error de reconexión");
            });
        }

        private void OnError(string error)
        {
            LogMessage($"❌ OnError() ejecutado - Error: {error}");
        }
        private void test(string txt)
        {
            LogMessage($"{txt}");
            MessageBox.Show($"{txt}", "test");
        }
        private void OnConnectionStatus(SocketIOResponse response)
        {
            try
            {
                LogMessage("📡 Procesando connection_status...");
                // Paso 1: obtener el string JSON crudo
                var data = JsonConvert.DeserializeObject<List<ConnectionStatus>>(response.ToString())[0];

                LogMessage($"📡 Estado de conexión procesado: {data.status} - {data.message}");
                ConnectionStatusChanged?.Invoke(this, data.message);
            }
            catch (Exception ex)
            {
                LogMessage($"❌ Error procesando estado de conexión: {ex.Message}");
            }
        }




        private void OnSystemStatusChanged(SocketIOResponse response)
        {
            try
            {
                LogMessage("📊 Procesando system_status_changed...");
                var systemStatus = JsonConvert.DeserializeObject<List<SystemStatus>>(response.ToString())[0];
                LogMessage($"📊 Datos JSON: {systemStatus.ToString()}");

                if (systemStatus != null)
                {
                    LogMessage($"📊 Estado del sistema procesado: {systemStatus.Status}");
                    SystemStatusChanged?.Invoke(this, systemStatus);
                }
                else
                {
                    LogMessage("❌ systemStatus es null después de deserializar");
                }
            }
            catch (Exception ex)
            {
                LogMessage($"❌ Error procesando cambio de estado del sistema: {ex.Message}");
                LogMessage($"❌ Stack trace: {ex.StackTrace}");
            }
        }

        private void OnMaintenanceModeChanged(SocketIOResponse response)
        {
            try
            {
                LogMessage("🔧 Procesando maintenance_mode_changed...");
                var data = JsonConvert.DeserializeObject<List<MaintenanceModeData>>(response.ToString())[0];
                LogMessage($"🔧 Datos JSON: {data.ToString()}");

                LogMessage($"🔧 Mantenimiento procesado - Enabled: {data.Enabled}, Message: '{data.Message}'");

                var maintenanceData = new MaintenanceModeData
                {
                    Enabled = data.Enabled,
                    Message = data.Message
                };

                MaintenanceModeChanged?.Invoke(this, maintenanceData);
                LogMessage("🔧 Evento MaintenanceModeChanged disparado");
            }
            catch (Exception ex)
            {
                LogMessage($"❌ Error procesando cambio de modo mantenimiento: {ex.Message}");
                LogMessage($"❌ Stack trace: {ex.StackTrace}");
            }
        }

        private void OnNewVersionAvailable(SocketIOResponse response)
        {
            try
            {
                LogMessage("🎮 Procesando new_version_available...");
                var data = JsonConvert.DeserializeObject<List<JObject>>(response.ToString())[0];
                var version = data["version"]?.ToString();
                var isLatest = data["is_latest"]?.ToObject<bool>() ?? false;

                if (isLatest && !string.IsNullOrEmpty(version))
                {
                    LogMessage($"🎮 Nueva versión del juego procesada: {version}");
                    NewGameVersionAvailable?.Invoke(this, version);
                }
                else
                {
                    LogMessage($"🎮 Versión ignorada - isLatest: {isLatest}, version: '{version}'");
                }
            }
            catch (Exception ex)
            {
                LogMessage($"❌ Error procesando nueva versión del juego: {ex.Message}");
            }
        }

        private void OnLauncherUpdateAvailable(SocketIOResponse response)
        {
            try
            {
                LogMessage("🚀 Procesando launcher_update_available...");
                var data = JsonConvert.DeserializeObject<List<JObject>>(response.ToString())[0];
                LogMessage($"🚀 Datos JSON: {data.ToString()}");

                var launcherInfo = data.ToObject<LauncherVersionInfo>();

                if (launcherInfo != null)
                {
                    LogMessage($"🚀 Actualización del launcher procesada: {launcherInfo.Version}");
                    LauncherUpdateAvailable?.Invoke(this, launcherInfo);
                }
                else
                {
                    LogMessage("❌ launcherInfo es null después de deserializar");
                }
            }
            catch (Exception ex)
            {
                LogMessage($"❌ Error procesando actualización del launcher: {ex.Message}");
                LogMessage($"❌ Stack trace: {ex.StackTrace}");
            }
        }

        private void OnStatsUpdate(SocketIOResponse response)
        {
            try
            {
                var data = JsonConvert.DeserializeObject<List<JObject>>(response.ToString())[0]; ;
                var players = data["players"]?.ToString();
                var servers = data["servers"]?.ToString();
                LogMessage($"📈 Estadísticas procesadas - Jugadores: {players}, Servidores: {servers}");
            }
            catch (Exception ex)
            {
                LogMessage($"❌ Error procesando actualización de estadísticas: {ex.Message}");
            }
        }

        private void OnNotification(SocketIOResponse response)
        {
            try
            {
                var data = JsonConvert.DeserializeObject<List<JObject>>(response.ToString())[0];
                var type = data["type"]?.ToString();
                var message = data["message"]?.ToString();

                LogMessage($"🔔 Notificación procesada [{type}]: {message}");

                // Mostrar notificación en UI si es importante
                if (type == "warning" || type == "danger")
                {
                    try
                    {
                        var mainForm = Application.OpenForms.Cast<Form>().FirstOrDefault(f => f is LauncherForm);
                        if (mainForm != null)
                        {
                            mainForm.Invoke(new Action(() =>
                            {
                                MessageBox.Show(message, $"Notificación del Servidor", MessageBoxButtons.OK,
                                    type == "danger" ? MessageBoxIcon.Error : MessageBoxIcon.Warning);
                            }));
                        }
                    }
                    catch (Exception ex)
                    {
                        LogMessage($"❌ Error mostrando notificación: {ex.Message}");
                    }
                }
            }
            catch (Exception ex)
            {
                LogMessage($"❌ Error procesando notificación: {ex.Message}");
            }
        }

        private void OnPong(SocketIOResponse response)
        {
 
            var data = JsonConvert.DeserializeObject<List<OnPong>>(response.ToString())[0];
            LogMessage($"🏓 Pong procesado - Hora servidor: {data.server_time}");
        }

        private void OnInitialData(SocketIOResponse response)
        {
            try
            {
                LogMessage("📋 Procesando initial_data...");
                var data = JsonConvert.DeserializeObject<List<JObject>>(response.ToString())[0];
                LogMessage($"📋 Datos completos: {data?.ToString()}");

                // Procesar datos iniciales del sistema
                var systemStatusData = data["system_status"];
                if (systemStatusData != null)
                {
                    var systemStatus = systemStatusData.ToObject<SystemStatus>();
                    if (systemStatus != null)
                    {
                        LogMessage("📋 Datos iniciales del sistema procesados");
                        SystemStatusChanged?.Invoke(this, systemStatus);
                    }
                }

                // Procesar noticias iniciales
                var newsData = data["news"];
                if (newsData != null)
                {
                    var news = newsData.ToObject<NewsMessage[]>();
                    if (news != null)
                    {
                        LogMessage($"📋 {news.Length} noticias iniciales procesadas");
                        NewsUpdated?.Invoke(this, news);
                    }
                }
            }
            catch (Exception ex)
            {
                LogMessage($"❌ Error procesando datos iniciales: {ex.Message}");
                LogMessage($"❌ Stack trace: {ex.StackTrace}");
            }
        }

        // Métodos de utilidad
        public async Task SendHeartbeat()
        {
            if (_isConnected)
            {
                try
                {
                    LogMessage("💓 Enviando heartbeat...");
                    await _client.EmitAsync("launcher_heartbeat", new { request_stats = true });
                    LogMessage("✅ Heartbeat enviado");
                }
                catch (Exception ex)
                {
                    LogMessage($"❌ Error enviando heartbeat: {ex.Message}");
                }
            }
        }

        public async Task Ping()
        {
            if (_isConnected)
            {
                try
                {
                    LogMessage("🏓 Enviando ping...");
                    await _client.EmitAsync("ping");
                    LogMessage("✅ Ping enviado");
                }
                catch (Exception ex)
                {
                    LogMessage($"❌ Error enviando ping: {ex.Message}");
                }
            }
        }

        // ✅ MÉTODO PARA TEST MANUAL
        public async Task TestConnection()
        {
            try
            {
                LogMessage("🧪 === INICIANDO TEST DE CONEXIÓN ===");
                LogMessage($"🧪 URL del servidor: {_serverUrl}");
                LogMessage($"🧪 Estado conectado: {_isConnected}");
                LogMessage($"🧪 Cliente es null: {_client == null}");

                if (_isConnected)
                {
                    LogMessage("🧪 Enviando eventos de prueba...");

                    await _client.EmitAsync("ping");
                    LogMessage("✅ Ping enviado");

                    await _client.EmitAsync("request_initial_data");
                    LogMessage("✅ Request initial data enviado");

                    await _client.EmitAsync("test_admin_notification");
                    LogMessage("✅ Test admin notification enviado");
                }
                else
                {
                    LogMessage("❌ No se pueden enviar eventos - no conectado");
                }

                LogMessage("🧪 === TEST DE CONEXIÓN COMPLETADO ===");
            }
            catch (Exception ex)
            {
                LogMessage($"❌ Error en test de conexión: {ex.Message}");
            }
        }

        private void LogMessage(string message)
        {
            try
            {
                string logEntry = $"[{DateTime.Now:yyyy-MM-dd HH:mm:ss}] [SocketIOService] {message}";
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
            if (_disposed) return;

            _disposed = true;

            try
            {
                LogMessage("🗑️ Disposing SocketIOService...");
                DisconnectAsync().Wait(5000);
                _client?.Dispose();
                LogMessage("✅ SocketIOService disposed");
            }
            catch (Exception ex)
            {
                LogMessage($"❌ Error disposing SocketIOService: {ex.Message}");
            }
        }

    }
    public class OnPong
    {
        public string server_time { get; set; }
    }
    public class ConnectionStatus
    {
        public string status { get; set; }
        public string message { get; set; }
    }
}