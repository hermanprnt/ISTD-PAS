using System;
using GPS.Core.GPSLogService;

namespace SAPDataImporterConsole
{
    class Program
    {
        public String FunctionId = "001004";

        static void Main(string[] args)
        {
            ILogService logger = LogServiceExtensions.GetCurrentLogService("SAP Data Importer Service");

            try
            {
                logger.Info(LogExtensions.Break);
                logger.Info("Starting SAP Data Importer Service");
                Import.ImportDataFromSAP(logger);
                logger.Info("Stopping SAP Data Importer Service");
            }
            catch (Exception ex)
            {
                logger.Error(ex);
            }
        }
    }
}
