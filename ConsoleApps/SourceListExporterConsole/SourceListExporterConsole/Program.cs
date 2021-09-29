using System;
using GPS.Core.GPSLogService;
using SourceListDataExporter;

namespace SourceListDataExporterConsole
{
    class Program
    {
        public static String FunctionId = "001008";

        static void Main(string[] args)
        {
            ILogService logger = LogServiceExtensions.GetCurrentLogService("Material Source List Service");

            try
            {
                logger.Info(LogExtensions.Break);
                logger.Info("Starting Source List Exporter Service");
                Export.GenerateData(logger, FunctionId);
                logger.Info("Stopping Source List Exporter Service");
            }
            catch (Exception ex)
            {
                logger.Error(ex);
            }
        }
    }
}
