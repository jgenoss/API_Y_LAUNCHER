using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.IO;
using System.Threading;

namespace PBLauncher
{
    internal static class Program
    {
        private static Mutex mutex = null;
        private const string MutexName = "GameLauncherSingleInstance";
        private const string LogFile = "launcher.log";

        /// <summary>
        /// Punto de entrada principal para la aplicación.
        /// </summary>
        [STAThread]
        static void Main()
        {
            // Configurar manejo de excepciones globales
            Application.SetUnhandledExceptionMode(UnhandledExceptionMode.CatchException);
            Application.ThreadException += Application_ThreadException;
            AppDomain.CurrentDomain.UnhandledException += CurrentDomain_UnhandledException;

            try
            {

                LogMessage("Iniciando aplicación launcher...");

                // Verificar instancia única usando Mutex (más robusto que Process.GetProcessesByName)
                bool createdNew;
                mutex = new Mutex(true, MutexName, out createdNew);

                if (!createdNew)
                {
                    LogMessage("Ya existe una instancia del launcher ejecutándose");
                    MessageBox.Show("El launcher ya está ejecutándose.", "Launcher",
                        MessageBoxButtons.OK, MessageBoxIcon.Information);
                    return;
                }

                LogMessage("Instancia única verificada correctamente");

                // Configurar aplicación
                Application.EnableVisualStyles();
                Application.SetCompatibleTextRenderingDefault(false);

                LogMessage("Archivos críticos verificados");

                // Iniciar formulario principal
                LogMessage("Iniciando formulario principal...");
                Application.Run(new PleaseWait());
                LogMessage("Aplicación cerrada normalmente");
            }
            catch (Exception ex)
            {
                LogMessage($"Error crítico en Main: {ex.Message}");
                MessageBox.Show($"Error crítico al iniciar el launcher:\n{ex.Message}",
                    "Error Crítico", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                // Liberar mutex
                if (mutex != null)
                {
                    mutex.ReleaseMutex();
                    mutex.Dispose();
                }
            }
        }

        private static void Application_ThreadException(object sender, ThreadExceptionEventArgs e)
        {
            LogMessage($"Excepción en hilo de UI: {e.Exception.Message}");
            MessageBox.Show($"Error en la interfaz:\n{e.Exception.Message}",
                "Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }

        private static void CurrentDomain_UnhandledException(object sender, UnhandledExceptionEventArgs e)
        {
            Exception ex = e.ExceptionObject as Exception;
            LogMessage($"Excepción no manejada: {ex?.Message ?? "Desconocida"}");

            if (e.IsTerminating)
            {
                LogMessage("La aplicación se está cerrando debido a una excepción crítica");
                MessageBox.Show("Error crítico. La aplicación se cerrará.",
                    "Error Crítico", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private static bool VerifyCriticalFiles()
        {
            string[] criticalFiles = {
                "lccnct.dta",
                // Agrega otros archivos críticos aquí
            };

            foreach (string file in criticalFiles)
            {
                if (!File.Exists(file))
                {
                    LogMessage($"Archivo crítico faltante: {file}");
                    return false;
                }
            }

            return true;
        }

        private static void LogMessage(string message)
        {
            try
            {
                string logEntry = $"[{DateTime.Now:yyyy-MM-dd HH:mm:ss}] [PROGRAM] {message}";
                File.AppendAllText(LogFile, logEntry + Environment.NewLine);
            }
            catch
            {
                // Si no puede escribir al log, continúa silenciosamente
            }
        }
    }
}