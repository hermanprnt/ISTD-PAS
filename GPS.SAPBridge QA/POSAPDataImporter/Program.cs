using GPS.Core.TDKSimplifier;
using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceProcess;
using System.Text;
using System.Threading.Tasks;
using GPS.Core.GPSLogService;

namespace POSAPDataImporter
{
    static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        static void Main()
        {
            ObjectPool.Factory.RegisterSingleton<TDKDatabase>(typeof(TDKDatabase), TDKConfig.GetConnectionDescriptor());
            //ServiceBase[] ServicesToRun;
            //ServicesToRun = new ServiceBase[] 
            //{ 
            //    new POSAPDataImporterService() 
            //};
            //ServiceBase.Run(ServicesToRun);

            ILogService Logger = LogServiceExtensions.GetCurrentLogService("PO SAP Data Importer Service");
            Import.ImportDataFromSAP(Logger);
        }
    }
}
