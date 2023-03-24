using System;
using GPS.Core.GPSLogService;
using MaterialDataExporter;

namespace MaterialDataExporterConsole
{
    class Program
    {
        public static String FunctionId = "001006";

        static void Main(string[] args)
        {
            ILogService logger = LogServiceExtensions.GetCurrentLogService("Material Master Exporter Service");

            try
            {
                logger.Info(LogExtensions.Break);
                logger.Info("Starting Material Master Exporter Service");
                Export.GenerateData(logger, FunctionId);
                logger.Info("Stopping Material Master Exporter Service");
            }
            catch (Exception ex)
            {
                logger.Error(ex);
            }
        }
    }
}
