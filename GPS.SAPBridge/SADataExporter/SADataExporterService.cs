using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using GPS.Core;
using GPS.Core.GPSLogService;
using GPS.Core.ViewModel;
using GPS.Core.WindowsService;

namespace SADataExporter
{
    public partial class SADataExporterService : GPSWindowsService, ITask
    {
        public SADataExporterService()
        {
            InitializeComponent();

            Logger = LogServiceExtensions.GetCurrentLogService("SA Data Exporter Service");
            CurrentTask = this;
        }

        public String FunctionId { get { return "001003"; } }

        public IList<NameValueItem> ScheduleList { get;set; }

        public Int32 TaskControl { get; set; }

        public void OnSchedule(Object state)
        {
            Logger.Info("Get SA data: begin");

            var repo = new SARepository();
            IList<String> saData = repo.GetData();

            Logger.Info("Get SA data: end");

            if (saData.Any())
            {
                Logger.Info(String.Format("Generate text file with {0} data: begin", saData.Count));

                IList<String> tabbedDataList = saData.Select(data => data.Replace("${tab}", "\t")).ToList();
                String exportPath = repo.GetSAExportPath();
                String filename = "SAExportedData" + DateTime.Now.ToString("yyyyMMddHHmmss") + ".txt";
                String exportFilePath = Path.Combine(exportPath, filename);
                String localFilePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, filename);

                File.AppendAllLines(localFilePath, tabbedDataList);

                Logger.Info(String.Format("Generate text file with {0} data: end", saData.Count));

                Logger.Info("Move to FTP: begin");

                NetworkCredential ftpCred = repo.GetFtpCredential();
                FtpHandler.Upload(exportFilePath, localFilePath, ftpCred);

                Logger.Info("Move to FTP: end");

                Logger.Info("Change status to Posting: begin");

                repo.UpdateSAToPosting();

                Logger.Info("Change status to Posting: end");
            }
            else
            {
                Logger.Info("There're no SA data");
            }
        }

        protected override void OnStart(string[] args)
        {
            try
            {
                Logger.Info(LogExtensions.Break);
                StartScheduler("Starting SA Data Exporter Service");
            }
            catch (Exception ex)
            {
                Logger.Error(ex);
            }
        }

        protected override void OnStop()
        {
            try
            {
                Logger.Info(LogExtensions.Break);
                Logger.Info("Stopping SA Data Exporter Service");
                StopScheduler();
            }
            catch (Exception ex)
            {
                Logger.Error(ex);
            }
        }
    }
}
