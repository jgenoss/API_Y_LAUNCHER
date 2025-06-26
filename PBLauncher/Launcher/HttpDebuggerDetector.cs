using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Management;
using System.Net;
using System.Net.NetworkInformation;
using System.Security.Cryptography.X509Certificates;
using System.Text.Json;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Windows.Forms;
using Microsoft.Win32;

public static class HttpDebuggerDetector
{
    // ===== LISTA BLANCA CONFIGURABLE =====
    public static class Whitelist
    {
        private static HashSet<string> _whitelistedProcesses = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

        // Lista blanca por defecto SOLO para procesos legítimos (NO herramientas de debugging)
        private static readonly string[] DefaultWhitelist = {
            // Navegadores
            "chrome.exe",
            "msedge.exe",
            "firefox.exe",
            "opera.exe",
            "brave.exe",
            "vivaldi.exe",
            "msedgewebview2.exe",
            "iexplore.exe",
            
            // Editores de código y IDEs
            "code.exe",                 // Visual Studio Code
            "devenv.exe",              // Visual Studio
            "rider64.exe",             // JetBrains Rider
            "idea64.exe",              // IntelliJ IDEA
            "pycharm64.exe",           // PyCharm
            "webstorm64.exe",          // WebStorm
            "phpstorm64.exe",          // PhpStorm
            "clion64.exe",             // CLion
            "notepad++.exe",           // Notepad++
            "sublime_text.exe",        // Sublime Text
            "atom.exe",                // Atom
            "brackets.exe",            // Brackets
            
            // Aplicaciones de comunicación
            "discord.exe",
            "teams.exe",               // Microsoft Teams
            "slack.exe",
            "zoom.exe",
            "skype.exe",
            "telegram.exe",
            "whatsapp.exe",
            
            // Aplicaciones multimedia
            "spotify.exe",
            "vlc.exe",                 // VLC Media Player
            "wmplayer.exe",            // Windows Media Player
            "itunes.exe",              // iTunes
            "musicbee.exe",            // MusicBee
            "potplayer.exe",           // PotPlayer
            "mpc-hc64.exe",            // Media Player Classic
            
            // Gaming platforms
            "steam.exe",
            "epicgameslauncher.exe",
            "uplay.exe",
            "origin.exe",
            "battle.net.exe",
            "gog galaxy.exe",
            "riotclientservices.exe",  // Riot Games
            "leagueclient.exe",        // League of Legends
            "valorant.exe",            // Valorant
            
            // Herramientas de productividad
            "winrar.exe",
            "7z.exe",
            "7zfm.exe",               // 7-Zip File Manager
            "winzip64.exe",
            "teamviewer.exe",
            "anydesk.exe",
            "chrome remote desktop.exe",
            
            // Adobe Creative Suite
            "photoshop.exe",
            "illustrator.exe",
            "premiere.exe",
            "afterfx.exe",            // After Effects
            "indesign.exe",
            "lightroom.exe",
            "acrobat.exe",
            "acroread32.exe",         // Adobe Reader
            
            // Streaming/Recording
            "obs64.exe",
            "obs32.exe",
            "streamlabs obs.exe",
            "xsplit.core.exe",
            "bandicam.exe",
            "camtasia.exe",
            "nvidia shadowplay.exe",
            
            // Utilidades del sistema
            "ccleaner64.exe",
            "malwarebytes.exe",
            "defender.exe",
            "msiexec.exe",
            "installer.exe",
            "setup.exe",
            "uninstall.exe",
            
            // Procesos del sistema Windows
            "explorer.exe",
            "dwm.exe",
            "winlogon.exe",
            "csrss.exe",
            "svchost.exe",
            "lsass.exe",
            "services.exe",
            "spoolsv.exe",
            "conhost.exe",
            "backgroundtaskhost.exe",
            "runtimebroker.exe",
            "searchui.exe",
            "startmenuexperiencehost.exe",
            "shellexperiencehost.exe",
            "taskhostw.exe",
            "dllhost.exe",
            "sihost.exe",
            "ctfmon.exe",
            "audiodg.exe",
            "fontdrvhost.exe",
            "smartscreen.exe",
            "securityhealthsystray.exe",
            "securityhealthservice.exe",
            
            // Drivers y servicios
            "nvcontainer.exe",         // NVIDIA
            "nvidia web helper.exe",
            "amd.exe",
            "radeoninstaller.exe",     // AMD
            "intel.exe",
            "intelcphdcpsvc.exe",      // Intel
            "realtekhdaudmgr.exe",     // Realtek Audio
            
            // Antivirus comunes
            "avast.exe",
            "avg.exe",
            "avira.exe",
            "kaspersky.exe",
            "bitdefender.exe",
            "norton.exe",
            "mcafee.exe",
            "eset.exe",
            "windowsdefender.exe",
            
            // Herramientas de desarrollo (legítimas)
            "git.exe",
            "gitbash.exe",
            "cmd.exe",
            "powershell.exe",
            "pwsh.exe",                // PowerShell Core
            "terminal.exe",            // Windows Terminal
            "conemu64.exe",            // ConEmu
            "cmder.exe",
            "putty.exe",
            "winscp.exe",
            "filezilla.exe",
            "postman.exe",             // Postman (API tool, no debugger)
            "insomnia.exe",            // Insomnia (API tool)
            
            // Herramientas de oficina
            "winword.exe",             // Microsoft Word
            "excel.exe",               // Microsoft Excel
            "powerpnt.exe",            // Microsoft PowerPoint
            "outlook.exe",             // Microsoft Outlook
            "onenote.exe",             // Microsoft OneNote
            "swriter.exe",             // LibreOffice Writer
            "scalc.exe",               // LibreOffice Calc
            "simpress.exe",            // LibreOffice Impress
            
            // Otras aplicaciones comunes
            "calculator.exe",
            "notepad.exe",
            "mspaint.exe",
            "snippingtool.exe",
            "snippingtool.exe",
            "screensketch.exe",        // Snip & Sketch
            "calculator.exe",
            "magnify.exe",             // Magnifier
            "narrator.exe",            // Narrator
            "osk.exe"                  // On-Screen Keyboard
        };

        static Whitelist()
        {
            LoadWhitelist();
        }

        public static void LoadWhitelist()
        {
            try
            {
                _whitelistedProcesses.Clear();

                // Agregar lista por defecto
                foreach (var process in DefaultWhitelist)
                {
                    _whitelistedProcesses.Add(process);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error cargando whitelist: {ex.Message}");
            }
        }

        public static bool IsWhitelisted(string processName)
        {
            if (string.IsNullOrEmpty(processName)) return false;

            string normalizedName = processName.ToLower();
            if (!normalizedName.EndsWith(".exe"))
                normalizedName += ".exe";

            return _whitelistedProcesses.Contains(normalizedName);
        }

        public static string[] GetCustomWhitelistedProcesses()
        {
            return _whitelistedProcesses.Except(DefaultWhitelist, StringComparer.OrdinalIgnoreCase).ToArray();
        }

        public static string[] GetAllWhitelistedProcesses()
        {
            return _whitelistedProcesses.ToArray();
        }
    }

    // ===== ENUMS Y CLASES =====
    public enum ThreatType
    {
        Process = 1,
        Certificate = 2,
        ProxyConfiguration = 3,
        SuspiciousPort = 4,
        RegistryEntry = 5,
        SuspiciousFile = 6,
        NetworkAnomaly = 7,
        CommandLineArgument = 8
    }

    public enum DetectionLevel
    {
        None = 0,
        Low = 1,
        Medium = 2,
        High = 3,
        Critical = 4
    }

    public class ProcessThreat
    {
        public int ProcessId { get; set; }
        public string ProcessName { get; set; }
        public string ProcessPath { get; set; }
        public string WindowTitle { get; set; }
        public string DetectedAs { get; set; }
        public DetectionLevel Severity { get; set; }
        public DateTime DetectedAt { get; set; } = DateTime.Now;
        public List<int> SuspiciousPorts { get; set; } = new List<int>();
        public string CommandLine { get; set; }
        public bool CanWhitelist { get; set; } = true;

        public override string ToString()
        {
            return $"{ProcessName} (PID: {ProcessId}) - {DetectedAs}";
        }
    }

    public class ThreatInfo
    {
        public ThreatType Type { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string Details { get; set; }
        public DetectionLevel Severity { get; set; }
        public DateTime DetectedAt { get; set; } = DateTime.Now;
        public ProcessThreat ProcessInfo { get; set; }
    }

    public class DetectionResult
    {
        public bool IsDebuggerDetected { get; set; }
        public List<ThreatInfo> DetectedThreats { get; set; } = new List<ThreatInfo>();
        public List<ProcessThreat> SuspiciousProcesses { get; set; } = new List<ProcessThreat>();
        public List<ProcessThreat> WhitelistedProcesses { get; set; } = new List<ProcessThreat>();
        public DetectionLevel OverallThreatLevel { get; set; }
        public string DetailedInfo { get; set; }
        public TimeSpan ScanDuration { get; set; }

        public bool HasProcessThreats => SuspiciousProcesses.Any();
        public int ProcessThreatCount => SuspiciousProcesses.Count;
        public int WhitelistedCount => WhitelistedProcesses.Count;
        public string[] ProcessNames => SuspiciousProcesses.Select(p => p.ProcessName).Distinct().ToArray();
        public string[] DetectedTools => SuspiciousProcesses.Select(p => p.DetectedAs).Distinct().ToArray();
    }

    // ===== LISTAS DE HERRAMIENTAS DE DEBUGGING =====
    private static readonly string[] KnownDebuggerProcesses = {
        "fiddler", "fiddle", "charles", "charlesproxy", "burpsuite", "burp",
        "httpanalyzer", "httpdebugger", "wireshark", "tcpview", "procmon",
        "processhacker", "procdump", "apimonitor", "detours", "hookapi",
        "ollydbg", "ida", "x64dbg", "windbg", "cheatengine", "artmoney",
        "mitmproxy", "owasp-zap", "zaproxy", "paros", "webscarab",
        "httpscoop", "iewatch", "networkminer", "ettercap", "cain",
        "telerik", "rehex", "hxd", "hexedit", "binhex", "winhex"
    };

    private static readonly string[] KnownDebuggerCertificates = {
        "DO_NOT_TRUST_FiddlerRoot", "Charles Proxy CA", "Burp Suite CA",
        "OWASP Zap Root CA", "mitmproxy", "HTTP Toolkit CA"
    };

    // ===== FUNCIÓN PRINCIPAL =====
    public static async Task<DetectionResult> DetectHttpDebuggersAsync(bool enableAdvancedDetection = true)
    {
        var result = new DetectionResult();
        var stopwatch = Stopwatch.StartNew();

        try
        {
            Whitelist.LoadWhitelist();

            // 1. Detectar procesos sospechosos
            await DetectSuspiciousProcesses(result);

            // 2. Detectar configuración de proxy
            DetectProxyConfiguration(result);

            // 3. Detectar certificados de debugging tools
            DetectDebuggerCertificates(result);

            // 4. Detectar puertos sospechosos
            await DetectSuspiciousPorts(result);

            if (enableAdvancedDetection)
            {
                // 5. Detectar modificaciones del registro
                DetectRegistryModifications(result);

                // 6. Detectar archivos temporales sospechosos
                DetectSuspiciousFiles(result);

                // 7. Análisis de timing
                await DetectTimingAnomalies(result);
            }

            DetermineThreatLevel(result);
        }
        catch (Exception ex)
        {
            result.DetectedThreats.Add(new ThreatInfo
            {
                Type = ThreatType.NetworkAnomaly,
                Title = "Error durante la detección",
                Description = ex.Message,
                Severity = DetectionLevel.Medium
            });
        }

        stopwatch.Stop();
        result.ScanDuration = stopwatch.Elapsed;
        result.IsDebuggerDetected = result.DetectedThreats.Any() || result.SuspiciousProcesses.Any();
        return result;
    }

    // ===== DETECCIÓN DE PROCESOS CON WHITELIST =====
    private static async Task DetectSuspiciousProcesses(DetectionResult result)
    {
        try
        {
            var processes = Process.GetProcesses();

            foreach (var process in processes)
            {
                try
                {
                    string processName = process.ProcessName.ToLower();
                    string windowTitle = process.MainWindowTitle?.ToLower() ?? "";

                    foreach (string debuggerName in KnownDebuggerProcesses)
                    {
                        if (processName.Contains(debuggerName) || windowTitle.Contains(debuggerName))
                        {
                            var processPath = "Desconocido";
                            try
                            {
                                processPath = process.MainModule?.FileName ?? "Desconocido";
                            }
                            catch { }

                            var suspiciousPorts = GetProcessListeningPorts();
                            var severity = GetProcessThreatSeverity(debuggerName);

                            var processInfo = new ProcessThreat
                            {
                                ProcessId = process.Id,
                                ProcessName = process.ProcessName,
                                ProcessPath = processPath,
                                WindowTitle = process.MainWindowTitle ?? "Sin título",
                                DetectedAs = GetFriendlyToolName(debuggerName),
                                Severity = severity,
                                SuspiciousPorts = suspiciousPorts,
                                CanWhitelist = true
                            };

                            // Verificar whitelist
                            if (Whitelist.IsWhitelisted(process.ProcessName))
                            {
                                result.WhitelistedProcesses.Add(processInfo);
                            }
                            else
                            {
                                result.SuspiciousProcesses.Add(processInfo);

                                result.DetectedThreats.Add(new ThreatInfo
                                {
                                    Type = ThreatType.Process,
                                    Title = $"🚨 {GetFriendlyToolName(debuggerName)} detectado",
                                    Description = $"Se detectó el proceso '{process.ProcessName}' correspondiente a {GetFriendlyToolName(debuggerName)}.",
                                    Details = $"PID: {process.Id}\nRuta: {processPath}\nVentana: {process.MainWindowTitle ?? "N/A"}",
                                    Severity = severity,
                                    ProcessInfo = processInfo
                                });
                            }
                            break;
                        }
                    }
                }
                catch (Exception ex)
                {
                    if (!ex.Message.Contains("Access is denied"))
                    {
                        // Log solo errores relevantes
                    }
                }
            }

            await DetectProcessesWithWMI(result);
        }
        catch (Exception ex)
        {
            result.DetectedThreats.Add(new ThreatInfo
            {
                Type = ThreatType.Process,
                Title = "Error detectando procesos",
                Description = ex.Message,
                Severity = DetectionLevel.Low
            });
        }
    }

    private static async Task DetectProcessesWithWMI(DetectionResult result)
    {
        try
        {
            await Task.Run(() =>
            {
                using (var searcher = new ManagementObjectSearcher("SELECT Name, ProcessId, CommandLine FROM Win32_Process"))
                {
                    foreach (ManagementObject process in searcher.Get())
                    {
                        string processName = process["Name"]?.ToString() ?? "";
                        string commandLine = process["CommandLine"]?.ToString() ?? "";
                        string processId = process["ProcessId"]?.ToString() ?? "";

                        if (HasSuspiciousCommandLine(commandLine))
                        {
                            if (!Whitelist.IsWhitelisted(processName))
                            {
                                var processInfo = new ProcessThreat
                                {
                                    ProcessId = int.TryParse(processId, out int pid) ? pid : 0,
                                    ProcessName = processName,
                                    DetectedAs = "Proceso con argumentos sospechosos",
                                    Severity = DetectionLevel.High,
                                    CommandLine = commandLine
                                };

                                result.SuspiciousProcesses.Add(processInfo);

                                result.DetectedThreats.Add(new ThreatInfo
                                {
                                    Type = ThreatType.CommandLineArgument,
                                    Title = $"🕵️ Argumentos sospechosos: {processName}",
                                    Description = "Proceso con argumentos típicos de herramientas de debugging.",
                                    Details = $"Línea de comandos: {commandLine}",
                                    Severity = DetectionLevel.High,
                                    ProcessInfo = processInfo
                                });
                            }
                        }
                    }
                }
            });
        }
        catch (Exception)
        {
            // WMI puede fallar, no es crítico
        }
    }

    // ===== OTRAS DETECCIONES =====
    private static void DetectProxyConfiguration(DetectionResult result)
    {
        try
        {
            var proxy = WebRequest.GetSystemWebProxy();
            var testUri = new Uri("http://www.google.com");
            var proxyUri = proxy.GetProxy(testUri);

            if (proxyUri != testUri)
            {
                var severity = IsKnownDebuggerProxy(proxyUri.Host.ToLower(), proxyUri.Port)
                    ? DetectionLevel.High
                    : DetectionLevel.Medium;

                result.DetectedThreats.Add(new ThreatInfo
                {
                    Type = ThreatType.ProxyConfiguration,
                    Title = "Configuración de proxy detectada",
                    Description = "El sistema está configurado para usar un servidor proxy.",
                    Details = $"Proxy: {proxyUri.Host}:{proxyUri.Port}",
                    Severity = severity
                });
            }

            DetectProxyInRegistry(result);
        }
        catch (Exception ex)
        {
            result.DetectedThreats.Add(new ThreatInfo
            {
                Type = ThreatType.ProxyConfiguration,
                Title = "Error detectando configuración de proxy",
                Description = ex.Message,
                Severity = DetectionLevel.Low
            });
        }
    }

    private static void DetectProxyInRegistry(DetectionResult result)
    {
        try
        {
            using (var key = Registry.CurrentUser.OpenSubKey(@"Software\Microsoft\Windows\CurrentVersion\Internet Settings"))
            {
                if (key != null)
                {
                    var proxyEnable = key.GetValue("ProxyEnable");
                    var proxyServer = key.GetValue("ProxyServer")?.ToString();

                    if (proxyEnable?.ToString() == "1" && !string.IsNullOrEmpty(proxyServer))
                    {
                        var severity = IsDebuggerPort(proxyServer) ? DetectionLevel.High : DetectionLevel.Medium;

                        result.DetectedThreats.Add(new ThreatInfo
                        {
                            Type = ThreatType.RegistryEntry,
                            Title = "Configuración de proxy en registro",
                            Description = "Se encontró configuración de proxy en el registro de Windows.",
                            Details = $"Servidor: {proxyServer}",
                            Severity = severity
                        });
                    }
                }
            }
        }
        catch (Exception)
        {
            // No es crítico si no se puede acceder al registro
        }
    }

    private static void DetectDebuggerCertificates(DetectionResult result)
    {
        try
        {
            var store = new X509Store(StoreName.Root, StoreLocation.CurrentUser);
            store.Open(OpenFlags.ReadOnly);

            foreach (var cert in store.Certificates)
            {
                string issuer = cert.Issuer?.ToLower() ?? "";
                string subject = cert.Subject?.ToLower() ?? "";
                string friendlyName = cert.FriendlyName?.ToLower() ?? "";

                foreach (string debuggerCert in KnownDebuggerCertificates)
                {
                    string certLower = debuggerCert.ToLower();
                    if (issuer.Contains(certLower) || subject.Contains(certLower) || friendlyName.Contains(certLower))
                    {
                        result.DetectedThreats.Add(new ThreatInfo
                        {
                            Type = ThreatType.Certificate,
                            Title = $"Certificado de debugging detectado: {debuggerCert}",
                            Description = "Se encontró un certificado instalado correspondiente a una herramienta de debugging.",
                            Details = $"Emisor: {cert.Issuer}\nVálido hasta: {cert.NotAfter:yyyy-MM-dd}\nHuella: {cert.Thumbprint}",
                            Severity = DetectionLevel.High
                        });
                    }
                }
            }

            store.Close();
        }
        catch (Exception ex)
        {
            result.DetectedThreats.Add(new ThreatInfo
            {
                Type = ThreatType.Certificate,
                Title = "Error verificando certificados",
                Description = ex.Message,
                Severity = DetectionLevel.Low
            });
        }
    }

    private static async Task DetectSuspiciousPorts(DetectionResult result)
    {
        await Task.Run(() =>
        {
            try
            {
                var tcpConnections = IPGlobalProperties.GetIPGlobalProperties().GetActiveTcpListeners();
                int[] suspiciousPorts = { 8080, 8888, 8088, 8443, 9090, 9999, 8082, 8081, 3128, 8000 };

                var foundPorts = suspiciousPorts.Where(port =>
                    tcpConnections.Any(tcp => tcp.Port == port)).ToList();

                if (foundPorts.Any())
                {
                    result.DetectedThreats.Add(new ThreatInfo
                    {
                        Type = ThreatType.SuspiciousPort,
                        Title = "Puertos sospechosos en uso",
                        Description = "Se detectaron puertos abiertos comúnmente usados por herramientas de debugging.",
                        Details = $"Puertos: {string.Join(", ", foundPorts)}",
                        Severity = DetectionLevel.Medium
                    });
                }
            }
            catch (Exception ex)
            {
                result.DetectedThreats.Add(new ThreatInfo
                {
                    Type = ThreatType.SuspiciousPort,
                    Title = "Error detectando puertos",
                    Description = ex.Message,
                    Severity = DetectionLevel.Low
                });
            }
        });
    }

    private static void DetectRegistryModifications(DetectionResult result)
    {
        try
        {
            string[] registryPaths = {
                @"SOFTWARE\Fiddler2",
                @"SOFTWARE\Charles",
                @"SOFTWARE\PortSwigger\BurpSuite"
            };

            foreach (string path in registryPaths)
            {
                try
                {
                    using (var key = Registry.CurrentUser.OpenSubKey(path) ?? Registry.LocalMachine.OpenSubKey(path))
                    {
                        if (key != null)
                        {
                            result.DetectedThreats.Add(new ThreatInfo
                            {
                                Type = ThreatType.RegistryEntry,
                                Title = "Entrada de registro sospechosa",
                                Description = $"Se encontró una entrada de registro para una herramienta de debugging.",
                                Details = $"Ruta: {path}",
                                Severity = DetectionLevel.Medium
                            });
                        }
                    }
                }
                catch { }
            }
        }
        catch (Exception) { }
    }

    private static void DetectSuspiciousFiles(DetectionResult result)
    {
        try
        {
            string[] suspiciousFiles = {
                @"C:\Users\{0}\AppData\Local\Programs\Fiddler",
                @"C:\Program Files\Fiddler2",
                @"C:\Program Files\Charles",
                @"C:\Users\{0}\AppData\Roaming\Charles"
            };

            string userName = Environment.UserName;

            foreach (string filePath in suspiciousFiles)
            {
                string fullPath = string.Format(filePath, userName);
                if (Directory.Exists(fullPath) || File.Exists(fullPath))
                {
                    result.DetectedThreats.Add(new ThreatInfo
                    {
                        Type = ThreatType.SuspiciousFile,
                        Title = "Archivo/directorio sospechoso",
                        Description = "Se encontró un archivo o directorio correspondiente a una herramienta de debugging.",
                        Details = $"Ruta: {fullPath}",
                        Severity = DetectionLevel.Medium
                    });
                }
            }
        }
        catch (Exception) { }
    }

    private static async Task DetectTimingAnomalies(DetectionResult result)
    {
        try
        {
            var stopwatch = Stopwatch.StartNew();

            using (var client = new WebClient())
            {
                try
                {
                    await client.DownloadStringTaskAsync("http://www.google.com");
                    stopwatch.Stop();

                    if (stopwatch.ElapsedMilliseconds > 5000)
                    {
                        result.DetectedThreats.Add(new ThreatInfo
                        {
                            Type = ThreatType.NetworkAnomaly,
                            Title = "Latencia sospechosa detectada",
                            Description = "La conexión parece estar siendo interceptada por un proxy.",
                            Details = $"Tiempo de respuesta: {stopwatch.ElapsedMilliseconds}ms",
                            Severity = DetectionLevel.Medium
                        });
                    }
                }
                catch (WebException ex)
                {
                    if (ex.Message.Contains("proxy") || ex.Message.Contains("407"))
                    {
                        result.DetectedThreats.Add(new ThreatInfo
                        {
                            Type = ThreatType.NetworkAnomaly,
                            Title = "Error de proxy detectado",
                            Description = "Se detectó un error relacionado con proxy durante la conexión.",
                            Details = ex.Message,
                            Severity = DetectionLevel.High
                        });
                    }
                }
            }
        }
        catch (Exception) { }
    }

    // ===== FUNCIONES AUXILIARES =====
    private static string GetFriendlyToolName(string debuggerName)
    {
        var friendlyNames = new Dictionary<string, string>
        {
            ["fiddler"] = "Fiddler (Proxy/Debugger HTTP)",
            ["fiddle"] = "Fiddler",
            ["charles"] = "Charles Proxy",
            ["charlesproxy"] = "Charles Proxy",
            ["burpsuite"] = "Burp Suite",
            ["burp"] = "Burp Suite",
            ["httpanalyzer"] = "HTTP Analyzer",
            ["httpdebugger"] = "HTTP Debugger",
            ["wireshark"] = "Wireshark (Analizador de red)",
            ["tcpview"] = "TCPView",
            ["procmon"] = "Process Monitor",
            ["processhacker"] = "Process Hacker",
            ["cheatengine"] = "Cheat Engine",
            ["apimonitor"] = "API Monitor",
            ["mitmproxy"] = "mitmproxy",
            ["owasp-zap"] = "OWASP ZAP",
            ["zaproxy"] = "ZAP Proxy",
            ["ettercap"] = "Ettercap",
            ["networkminer"] = "NetworkMiner"
        };

        return friendlyNames.ContainsKey(debuggerName) ? friendlyNames[debuggerName] : debuggerName.ToUpper();
    }

    private static DetectionLevel GetProcessThreatSeverity(string processName)
    {
        string[] criticalProcesses = { "fiddler", "charles", "burp", "wireshark", "cheatengine", "httpanalyzer", "httpdebugger" };
        string[] highRiskProcesses = { "procmon", "apimonitor", "processhacker", "tcpview", "mitmproxy", "owasp-zap" };

        if (criticalProcesses.Contains(processName))
            return DetectionLevel.Critical;
        else if (highRiskProcesses.Contains(processName))
            return DetectionLevel.High;
        else
            return DetectionLevel.Medium;
    }

    private static bool HasSuspiciousCommandLine(string commandLine)
    {
        if (string.IsNullOrEmpty(commandLine)) return false;

        string[] suspiciousArgs = { "--proxy", "--intercept", "--debug", "mitm", "--capture", "--monitor", "--hook" };
        return suspiciousArgs.Any(arg => commandLine.ToLower().Contains(arg));
    }

    private static List<int> GetProcessListeningPorts()
    {
        var listeningPorts = new List<int>();
        int[] debuggerPorts = { 8080, 8888, 8088, 8443 };

        try
        {
            var tcpConnections = IPGlobalProperties.GetIPGlobalProperties().GetActiveTcpListeners();
            listeningPorts.AddRange(debuggerPorts.Where(port =>
                tcpConnections.Any(tcp => tcp.Port == port)));
        }
        catch { }

        return listeningPorts;
    }

    private static bool IsKnownDebuggerProxy(string host, int port)
    {
        var knownConfigs = new Dictionary<string, int[]>
        {
            ["localhost"] = new[] { 8080, 8888, 8088, 8443 },
            ["127.0.0.1"] = new[] { 8080, 8888, 8088, 8443 },
            ["::1"] = new[] { 8080, 8888, 8088, 8443 }
        };

        return knownConfigs.ContainsKey(host) && knownConfigs[host].Contains(port);
    }

    private static bool IsDebuggerPort(string proxyServer)
    {
        var match = Regex.Match(proxyServer, @":(\d+)");
        if (match.Success && int.TryParse(match.Groups[1].Value, out int port))
        {
            int[] debuggerPorts = { 8080, 8888, 8088, 8443, 9090, 9999 };
            return debuggerPorts.Contains(port);
        }
        return false;
    }

    private static void DetermineThreatLevel(DetectionResult result)
    {
        if (!result.DetectedThreats.Any() && !result.SuspiciousProcesses.Any())
        {
            result.OverallThreatLevel = DetectionLevel.None;
            return;
        }

        var criticalCount = result.SuspiciousProcesses.Count(p => p.Severity == DetectionLevel.Critical);
        var highCount = result.SuspiciousProcesses.Count(p => p.Severity == DetectionLevel.High);

        if (criticalCount > 0)
            result.OverallThreatLevel = DetectionLevel.Critical;
        else if (highCount >= 1)
            result.OverallThreatLevel = DetectionLevel.High;
        else if (result.DetectedThreats.Count >= 3)
            result.OverallThreatLevel = DetectionLevel.Medium;
        else
            result.OverallThreatLevel = DetectionLevel.Low;

        result.DetailedInfo = $"Detectadas {result.DetectedThreats.Count} amenazas y {result.SuspiciousProcesses.Count} procesos sospechosos. " +
                             $"Nivel general: {result.OverallThreatLevel}";
    }

    // ===== FUNCIONES DE UI =====
    public static void ShowDetectionResultWithWhitelistOption(DetectionResult result, Form parentForm = null)
    {
        if (!result.IsDebuggerDetected && result.WhitelistedCount == 0)
        {
            return;
        }

        var resultForm = new Form
        {
            Text = $"Herramientas de Debugging - {result.OverallThreatLevel}",
            Size = new System.Drawing.Size(700, 600),
            StartPosition = FormStartPosition.CenterParent,
            FormBorderStyle = FormBorderStyle.FixedDialog,
            MaximizeBox = false,
            MinimizeBox = false
        };

        var textBox = new RichTextBox
        {
            Dock = DockStyle.Fill,
            ReadOnly = true,
            BackColor = System.Drawing.Color.White,
            Font = new System.Drawing.Font("Consolas", 9)
        };

        var message = $"🚨 RESULTADOS DE DETECCIÓN\n\n";
        message += $"📊 Nivel de amenaza: {result.OverallThreatLevel}\n";
        message += $"⏱️ Tiempo de escaneo: {result.ScanDuration.TotalMilliseconds:F0}ms\n\n";

        if (result.WhitelistedCount > 0)
        {
            message += $"🟢 PROCESOS EN LISTA BLANCA: {result.WhitelistedCount}\n";
            foreach (var process in result.WhitelistedProcesses)
            {
                message += $"   • {process.ProcessName} - {process.DetectedAs}\n";
            }
            message += "\n";
        }

        if (result.HasProcessThreats)
        {
            message += "🔍 PROCESOS SOSPECHOSOS DETECTADOS:\n";
            foreach (var process in result.SuspiciousProcesses)
            {
                message += $"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
                message += $"📛 Proceso: {process.ProcessName}\n";
                message += $"🏷️ Detectado como: {process.DetectedAs}\n";
                message += $"🆔 PID: {process.ProcessId}\n";
                message += $"📁 Ruta: {process.ProcessPath}\n";
                message += $"⚠️ Severidad: {process.Severity}\n";
                message += $"➕ Se puede agregar a lista blanca\n\n";
            }
        }

        var otherThreats = result.DetectedThreats.Where(t => t.Type != ThreatType.Process && t.Type != ThreatType.CommandLineArgument).ToList();
        if (otherThreats.Any())
        {
            message += "🔍 OTRAS AMENAZAS:\n";
            foreach (var threat in otherThreats)
            {
                message += $"• {threat.Title}\n";
            }
            message += "\n";
        }

        message += "💡 RECOMENDACIÓN:\n";
        switch (result.OverallThreatLevel)
        {
            case DetectionLevel.Critical:
                message += "🚨 CRÍTICO: Cierre inmediatamente las herramientas detectadas.\nEl juego no puede continuar con estas herramientas activas.";
                break;
            case DetectionLevel.High:
                message += "⚠️ ALTO: Se recomienda cerrar las herramientas detectadas\nantes de continuar.";
                break;
            case DetectionLevel.Medium:
                message += "⚠️ MEDIO: Revise las herramientas detectadas.\nAlgunas pueden interferir con el juego.";
                break;
            default:
                message += "ℹ️ BAJO: Se detectaron herramientas menores.\nPuede continuar con precaución.";
                break;
        }

        textBox.Text = message;

        var buttonPanel = new Panel { Height = 50, Dock = DockStyle.Bottom };

        var btnClose = new Button
        {
            Text = "Cerrar",
            Size = new System.Drawing.Size(80, 30),
            Location = new System.Drawing.Point(600, 10),
            DialogResult = DialogResult.OK
        };

        buttonPanel.Controls.Add(btnClose);

        resultForm.Controls.Add(textBox);
        resultForm.Controls.Add(buttonPanel);
        resultForm.AcceptButton = btnClose;

        resultForm.ShowDialog(parentForm);
        Environment.Exit(0);
    }

    // ===== FUNCIONES DE CONVENIENCIA =====
    public static async Task<string[]> GetSuspiciousProcessNamesAsync()
    {
        try
        {
            var result = await DetectHttpDebuggersAsync(enableAdvancedDetection: false);
            return result.ProcessNames;
        }
        catch
        {
            return new string[0];
        }
    }

    public static bool QuickProcessCheck(out string detectedProcess)
    {
        detectedProcess = null;
        try
        {
            var processes = Process.GetProcesses();
            string[] quickCheck = { "fiddler", "charles", "burp", "wireshark", "cheatengine" };

            foreach (var process in processes)
            {
                string name = process.ProcessName.ToLower();
                var detected = quickCheck.FirstOrDefault(debugger => name.Contains(debugger));
                if (detected != null && !Whitelist.IsWhitelisted(process.ProcessName))
                {
                    detectedProcess = $"{process.ProcessName} ({GetFriendlyToolName(detected)})";
                    return true;
                }
            }
            return false;
        }
        catch
        {
            return false;
        }
    }
}