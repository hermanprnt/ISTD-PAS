using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using GPS.Core;
using GPS.Core.GPSLogService;

namespace SADataExporterConsole
{
    class Program
    {
        private const String ServiceName = "GPSSADataExporterSvc";
        private const String FunctionId = "001003";

        static void Main(string[] args)
        {
            ILogService logger = LogServiceExtensions.GetCurrentLogService("SA Data Exporter Service");

            try
            {
                logger.Info(LogExtensions.Break);
                logger.Info("Starting SA Data Exporter Service");

                logger.Info("Get SA data: begin");

                var repo = new SARepository();
                String processId = repo.GetNewProcessId(ServiceName, FunctionId);
                IList<String> saData = repo.GetData(processId, FunctionId.Substring(0, 1), FunctionId);

                logger.Info("Get SA data: end");

                if (saData.Any())
                {
                    logger.Info(String.Format("Generate text file with {0} data: begin", saData.Count));

                    IList<String> tabbedDataList = saData.Select(data => data.Replace("${tab}", "\t")).ToList();
                    String exportPath = repo.GetSAExportPath();
                    String filename = "SAExportedData" + DateTime.Now.ToString("yyyyMMddHHmmss") + ".txt";
                    String exportFilePath = Path.Combine(exportPath, filename);
                    String localFilePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, filename);

                    File.AppendAllLines(localFilePath, tabbedDataList);

                    logger.Info(String.Format("Generate text file with {0} data: end", saData.Count));

                    logger.Info("Move to FTP: begin");

                    NetworkCredential ftpCred = repo.GetFtpCredential();
                    FtpHandler.Upload(exportFilePath, localFilePath, ftpCred);

                    logger.Info("Move to FTP: end");

                    logger.Info("Change status to Posting: begin");

                    repo.UpdateSAToPosting(processId, FunctionId.Substring(0, 1), FunctionId);

                    logger.Info("Change status to Posting: end");
                }
                else
                {
                    logger.Info("There're no SA data");
                }

                logger.Info("Stopping SA Data Exporter Service");
            }
            catch (Exception ex)
            {
                logger.Error(ex);
            }
        }
    }
}
