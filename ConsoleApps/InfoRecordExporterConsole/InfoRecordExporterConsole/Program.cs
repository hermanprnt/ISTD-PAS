using System;
using GPS.Core.GPSLogService;
using MaterialPriceDataExporter;

namespace MaterialPriceDataExporterConsole
{
    class Program
    {
        public static String FunctionId = "001007";

        static void Main(string[] args)
        {
            ILogService logger = LogServiceExtensions.GetCurrentLogService("Material Price Exporter Service");

            try
            {
                logger.Info(LogExtensions.Break);
                logger.Info("Starting Material Price Exporter Service");
                Export.GenerateData(logger, FunctionId);
                logger.Info("Stopping Material Price Exporter Service");
            }
            catch (Exception ex)
            {
                logger.Error(ex);
            }
        }
    }
}
