using System;
using System.IO;
using System.Net;
using System.Threading;
using System.Diagnostics;

class Program
{
    static void Main(string[] args)
    {
        if (args.Length != 3) return;

        try
        {
            string url = args[0];              // http://192.168.18.31:5000/api
            string launcherPath = args[1];     // Ruta del launcher actual (PBLauncher.exe)
            string fileName = args[2];         // Nombre versionado (ej: PBLauncher_v1.0.0.1.exe)
            string selfPath = Process.GetCurrentProcess().MainModule.FileName;

            Console.WriteLine($"🚀 Iniciando actualización del launcher...");
            Console.WriteLine($"📍 URL base: {url}");
            Console.WriteLine($"📄 Archivo versionado: {fileName}");
            Console.WriteLine($"📁 Destino final: {launcherPath}");

            Thread.Sleep(2000);

            using (var client = new WebClient())
            {
                // ✅ Descargar el archivo con nombre versionado
                string baseUrl = url.Replace("/api", "");
                string downloadUrl = $"{baseUrl}/Launcher/{fileName}";
                string tempFile = $"temp_{fileName}";

                Console.WriteLine($"📥 Descargando desde: {downloadUrl}");
                Console.WriteLine($"📁 Archivo temporal: {tempFile}");

                client.DownloadFile(downloadUrl, tempFile);
                Console.WriteLine("✅ Descarga completada exitosamente");

                // Verificaciones de integridad
                if (!File.Exists(tempFile))
                {
                    throw new Exception("❌ El archivo no se descargó correctamente");
                }

                var fileInfo = new FileInfo(tempFile);
                if (fileInfo.Length == 0)
                {
                    throw new Exception("❌ El archivo descargado está vacío");
                }

                Console.WriteLine($"📊 Archivo descargado: {fileInfo.Length:N0} bytes");

                // Eliminar launcher actual
                if (File.Exists(launcherPath))
                {
                    File.Delete(launcherPath);
                    Console.WriteLine("🗑️ Launcher anterior eliminado");
                }

                // ✅ RENOMBRAR: El archivo versionado se convierte en PBLauncher.exe
                File.Move(tempFile, launcherPath);
                Console.WriteLine($"✅ Launcher actualizado: {fileName} → PBLauncher.exe");
            }

            // Cleanup y restart
            string batchPath = Path.Combine(Path.GetTempPath(), "cleanup_launcher.bat");
            string batchContent =
                "@echo off\r\n" +
                "echo Finalizando actualizacion del launcher...\r\n" +
                "timeout /t 2 /nobreak > nul\r\n" +
                $"del \"{selfPath}\"\r\n" +
                $"echo Iniciando nuevo launcher...\r\n" +
                $"start \"\" \"{launcherPath}\"\r\n" +
                "del \"%~f0\"";

            File.WriteAllText(batchPath, batchContent);
            Process.Start(batchPath);

            Console.WriteLine("🎉 Actualización completada - Reiniciando launcher...");
        }
        catch (WebException webEx)
        {
            Console.WriteLine($"❌ Error de red: {webEx.Message}");
            if (webEx.Response is HttpWebResponse response)
            {
                Console.WriteLine($"🌐 Código HTTP: {response.StatusCode}");
                Console.WriteLine($"🔗 URL que falló: {response.ResponseUri}");
            }
            Console.WriteLine("\nPresiona cualquier tecla para continuar...");
            Console.ReadKey();
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ Error: {ex.Message}");
            Console.WriteLine("\nPresiona cualquier tecla para continuar...");
            Console.ReadKey();
        }
    }
}