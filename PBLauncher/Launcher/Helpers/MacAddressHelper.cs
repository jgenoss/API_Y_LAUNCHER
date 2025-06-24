using System;
using System.Net.NetworkInformation;
using System.Linq;

public class MacAddressHelper
{
    /// <summary>
    /// Obtiene la primera dirección MAC activa del sistema
    /// </summary>
    /// <returns>Dirección MAC como string o null si no se encuentra</returns>
    public static string GetMacAddress()
    {
        try
        {
            var networkInterface = NetworkInterface.GetAllNetworkInterfaces()
                .FirstOrDefault(nic =>
                    nic.OperationalStatus == OperationalStatus.Up &&
                    nic.NetworkInterfaceType != NetworkInterfaceType.Loopback &&
                    !string.IsNullOrEmpty(nic.GetPhysicalAddress().ToString()));

            return networkInterface?.GetPhysicalAddress().ToString();
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error obteniendo MAC: {ex.Message}");
            return null;
        }
    }

    /// <summary>
    /// Obtiene la dirección MAC formateada con separadores
    /// </summary>
    /// <param name="separator">Separador a usar (por defecto ':')</param>
    /// <returns>Dirección MAC formateada</returns>
    public static string GetFormattedMacAddress(string separator = ":")
    {
        string mac = GetMacAddress();
        if (string.IsNullOrEmpty(mac))
            return null;

        // Insertar separador cada 2 caracteres
        return string.Join(separator,
            Enumerable.Range(0, mac.Length / 2)
                     .Select(i => mac.Substring(i * 2, 2)));
    }

    /// <summary>
    /// Obtiene todas las direcciones MAC disponibles
    /// </summary>
    /// <returns>Array de direcciones MAC</returns>
    public static string[] GetAllMacAddresses()
    {
        try
        {
            return NetworkInterface.GetAllNetworkInterfaces()
                .Where(nic =>
                    nic.OperationalStatus == OperationalStatus.Up &&
                    nic.NetworkInterfaceType != NetworkInterfaceType.Loopback &&
                    !string.IsNullOrEmpty(nic.GetPhysicalAddress().ToString()))
                .Select(nic => nic.GetPhysicalAddress().ToString())
                .ToArray();
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error obteniendo MACs: {ex.Message}");
            return new string[0];
        }
    }
}
