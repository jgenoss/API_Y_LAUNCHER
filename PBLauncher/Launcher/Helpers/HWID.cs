using System;
using System.Collections.Generic;
using System.Linq;
using System.Management;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace PBLauncher
{
    public class HWID
    {
        public static string GetSerialNumber()
        {
            try
            {
                string hwid = "";
                ManagementObjectSearcher searcher = new ManagementObjectSearcher("SELECT * FROM Win32_PhysicalMedia");
                foreach (ManagementObject wmi in searcher.Get())
                {
                    hwid = wmi.Properties["SerialNumber"].Value.ToString();
                    break;
                }
                return hwid;
            }
            catch (Exception ex)
            {
                return "Diskless or Error Retrieve the HWID";
            }
        }
        public static string GetHardwareID()
        {
            try
            {
                StringBuilder sb = new StringBuilder();
                ManagementObjectCollection moc = new ManagementClass("Win32_Processor").GetInstances();

                foreach (ManagementObject mo in moc)
                {
                    sb.Append(mo.Properties["ProcessorId"].Value.ToString());
                    break;
                }

                moc = new ManagementClass("Win32_DiskDrive").GetInstances();

                foreach (ManagementObject mo in moc)
                {
                    sb.Append(mo.Properties["SerialNumber"].Value.ToString());
                    break;
                }

                moc = new ManagementClass("Win32_NetworkAdapterConfiguration").GetInstances();

                foreach (ManagementObject mo in moc)
                {
                    if ((bool)mo["IPEnabled"])
                    {
                        sb.Append(mo["MacAddress"].ToString());
                        break;
                    }
                }

                byte[] hash = SHA256.Create().ComputeHash(Encoding.UTF8.GetBytes(sb.ToString()));
                StringBuilder hwidBuilder = new StringBuilder();

                for (int i = 0; i < hash.Length; i++)
                {
                    hwidBuilder.Append(hash[i].ToString("X2"));
                }

                return hwidBuilder.ToString();
            }
            catch (Exception ex)
            {
                return "Diskless or Error Retrieve the HWID";
            }
            
        }
    }
}
