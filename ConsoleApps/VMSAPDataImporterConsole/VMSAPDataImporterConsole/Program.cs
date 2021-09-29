using System;
using GPS.Core.GPSLogService;

namespace VMSAPDataImporterConsole
{
    class Program
    {
        static void Main(string[] args)
        {
            ILogService logger = LogServiceExtensions.GetCurrentLogService("Vendor Master SAP Data Importer Service");

            try
            {
                logger.Info(LogExtensions.Break);
                logger.Info("Starting Vendor Master SAP Data Importer Service");
                Import.ImportDataFromSAP(logger);
                logger.Info("Stopping Vendor Master SAP Data Importer Service");
            }
            catch (Exception ex)
            {
                logger.Error(ex);
            }
        }
    }
}
