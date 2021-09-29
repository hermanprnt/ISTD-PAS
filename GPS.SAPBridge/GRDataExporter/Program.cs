using System;
using System.ServiceProcess;
using GPS.Core;
using GPS.Core.GPSLogService;
using GPS.Core.TDKSimplifier;
using Toyota.Common.Database;

namespace GRDataExporter
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
                //var services = new ServiceBase[] { new GRDataExporterService() };
                //ServiceBase.Run(services);

                /*// NOTE: for debugging purposes*/
                var gr = new GRDataExporterService();
                var repo = new GRRepository();
                gr.ScheduleList = repo.GetGRSchedule("001002");
                gr.StartScheduler();
            }
            catch (Exception ex)
            {
                (LogServiceExtensions.GetCurrentLogService("GR Data Exporter Service")).Error(ex);
            }
        }
    }
}
