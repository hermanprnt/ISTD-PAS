using System;
using GPS.Core.GPSLogService;

namespace BudgetDataImporter
{
    class Program
    {
        static void Main(string[] args)
        {
            ILogService logger = LogServiceExtensions.GetCurrentLogService("PO SAP Data Importer Service");

            try
            {
                logger.Info(LogExtensions.Break);
                logger.Info("Starting BCS import from SAP");
                Import.ImportBCSData(logger);
                logger.Info("Stopping BCS import from SAP");
            }
            catch (Exception ex)
            {
                logger.Error(ex);
            }
        }
    }
}
