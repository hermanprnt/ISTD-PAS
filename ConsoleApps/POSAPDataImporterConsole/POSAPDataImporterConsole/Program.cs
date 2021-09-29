using System;
using GPS.Core.GPSLogService;

namespace POSAPDataImporterConsole
{
    class Program
    {
        static void Main(string[] args)
        {
            ILogService logger = LogServiceExtensions.GetCurrentLogService("PO SAP Data Importer Service");

            try
            {
                logger.Info(LogExtensions.Break);
                logger.Info("Starting PO SAP Data Importer Service");
                Import.ImportDataFromSAP(logger);
                logger.Info("Stopping PO SAP Data Importer Service");
            }
            catch (Exception ex)
            {
                logger.Error(ex);
            }
        }
    }
}
