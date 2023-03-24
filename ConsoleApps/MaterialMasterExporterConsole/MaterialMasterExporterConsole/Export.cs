using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using GPS.Core;
using GPS.Core.GPSLogService;
using GPS.Core.TDKSimplifier;
using Toyota.Common.Configuration;

namespace MaterialDataExporter
{
    class Export
    {
        public static void GenerateData(ILogService logger, string FunctionId)
        {
            logger.Info(LogExtensions.Break);
            logger.Info("Process Start");
            var repo = new MaterialDataRepository(logger);
            long processid = 0;

            try
            {
                ConfigurationItem exportPathConfig = TDKConfig.GetSystemConfig("ExportFilePath") ?? new ConfigurationItem();
                String exportPath = exportPathConfig.Value;

                logger.Info("Start Generating Data");

                FileExtension.CreateDirectory(exportPath);

                IList<string> data = repo.GetData(FunctionId, ref processid);

                if (data.Any())
                {
                    for (int i = 0; i < data.Count(); i++)
                    {
                        data[i] = data[i].Replace("\\t", "\t");
                    }

                    string filename = "MM"+DateTime.Now.ToString("yyyyMMddHHmmss") + ".txt";
                    FileExtension.BulkWriteToFile(data, exportPath + filename);
                }
                else
                {
                    throw new Exception("No Data to Generated");
                }

                SendDatatoFTP(exportPath, logger);
            }
            catch (Exception ex)
            {
                logger.Error(ex);
            }
            finally
            {
                repo.DeleteLock(processid);
            }
        }

        public static void SendDatatoFTP(string localPath, ILogService logger)
        {
            String[] ListFiles = Directory.GetFiles(localPath);

            var repo = new MaterialDataRepository(logger);
            string FtpSettings = repo.GetFtpCredential();
            String[] splittedResult = FtpSettings.Split(';');

            if (splittedResult.Length < 3)
                throw new NullReferenceException("Bug: Ftp Credential is not set right.");

            string host = splittedResult[0];
            string userid = splittedResult[1];
            string password = splittedResult[2];

            NetworkCredential cred = new NetworkCredential(userid, password);

            foreach (string filename in ListFiles)
            {
                string destinationFileName = Path.Combine(host, Path.GetFileName(filename));
                FtpHandler.Upload(destinationFileName, filename, cred);
                File.Delete(filename);
            }
        }
    }
}
