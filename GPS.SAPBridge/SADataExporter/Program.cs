using System;
using System.ServiceProcess;
using GPS.Core.GPSLogService;
using GPS.Core.TDKSimplifier;

namespace SADataExporter
{
    static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        static void Main()
        {
            try
            {
                ObjectPool.Factory.RegisterSingleton<TDKDatabase>(typeof(TDKDatabase), TDKConfig.GetConnectionDescriptor());
                
                var services = new ServiceBase[] { new SADataExporterService() };
                ServiceBase.Run(services);

                //new SADataExporterService().OnSchedule(null);
            }
            catch (Exception ex)
            {
                (LogServiceExtensions.GetCurrentLogService("SA Data Exporter Service")).Error(ex);
            }
        }
    }
}
