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
            ObjectPool.Factory.RegisterSingleton<TDKDatabase>(typeof(TDKDatabase), TDKConfig.GetConnectionDescriptor());

            //try
            //{
            //    ObjectPool.Factory.RegisterSingleton<TDKDatabase>(typeof(TDKDatabase), TDKConfig.GetConnectionDescriptor());
            //    var services = new ServiceBase[] { new SADataExporterService() };
            //    ServiceBase.Run(services);
            //}
            //catch (Exception ex)
            //{
            //    (LogServiceExtensions.GetCurrentLogService("SA Data Exporter Service")).Error(ex);
            //}

            new SADataExporterService().Start();
        }
    }
}
