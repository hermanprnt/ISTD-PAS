using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using GPS.Core;
using GPS.Core.GPSLogService;

namespace GRDataExporterConsole
{
    class Program
    {
        private const String ServiceName = "GPSGRDataExporterSvc";
        private const String FunctionId = "001002";

        static void Main(string[] args)
        {
            ILogService logger = LogServiceExtensions.GetCurrentLogService("GR Data Exporter Service");

            try
            {
                logger.Info(LogExtensions.Break);
                logger.Info("Starting GR Data Exporter Service");

                logger.Info("Get GR data: begin");

                var repo = new GRRepository();
                String processId = repo.GetNewProcessId(ServiceName, FunctionId);
                IList<String> grData = repo.GetData(processId, FunctionId.Substring(0, 1), FunctionId);

                logger.Info("Get GR data: end");

                if (grData.Any())
                {
                    logger.Info(String.Format("Generate text file with {0} data: begin", grData.Count));

                    IList<String> tabbedDataList = grData.Select(data => data.Replace("${tab}", "\t")).ToList();
                    String exportPath = repo.GetGRExportPath();
                    String filename = "GRExportedData" + DateTime.Now.ToString("yyyyMMddHHmmss") + ".txt";
                    String exportFilePath = Path.Combine(exportPath, filename);
                    String localFilePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, filename);

                    File.AppendAllLines(localFilePath, tabbedDataList);

                    logger.Info(String.Format("Generate text file with {0} data: end", grData.Count));

                    logger.Info("Move to FTP: begin");

                    NetworkCredential ftpCred = repo.GetFtpCredential();
                    FtpHandler.Upload(exportFilePath, localFilePath, ftpCred);

                    logger.Info("Move to FTP: end");

                    logger.Info("Change status to Posting: begin");

                    repo.UpdateGRToPosting(processId, FunctionId.Substring(0, 1), FunctionId);

                    logger.Info("Change status to Posting: end");
                }
                else
                {
                    logger.Info("There're no GR data");
                }

                logger.Info("Stopping GR Data Exporter Service");
            }
            catch (Exception ex)
            {
                logger.Error(ex);
            }
        }
    }
}
