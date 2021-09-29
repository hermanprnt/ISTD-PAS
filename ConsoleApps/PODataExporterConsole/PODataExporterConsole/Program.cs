using System;
using GPS.Core.GPSLogService;
using PODataExporter;

namespace PODataExporterConsole
{
    class Program
    {
        public String FunctionId = "001001";

        static void Main(string[] args)
        {
            ILogService logger = LogServiceExtensions.GetCurrentLogService("PO Data Exporter Service");

            try
            {
                logger.Info(LogExtensions.Break);
                logger.Info("Starting PO Data Exporter Service");
                Export.GenerateData(logger);
                logger.Info("Stopping PO Data Exporter Service");
            }
            catch (Exception ex)
            {
                logger.Error(ex);
            }
        }
    }
}
