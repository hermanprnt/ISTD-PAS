using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using GPS.Core;
using GPS.Core.GPSLogService;
using GPS.Core.ViewModel;
using GPS.Core.WindowsService;

namespace GRDataExporter
{
    public partial class GRDataExporterService : GPSWindowsService, ITask
    {
        public GRDataExporterService()
        {
            InitializeComponent();

            Logger = LogServiceExtensions.GetCurrentLogService("GR Data Exporter Service");
            CurrentTask = this;
        }

        public String FunctionId { get { return "001002"; } }

        public IList<NameValueItem> ScheduleList { get;set; }

        public Int32 TaskControl { get; set; }

        public void OnSchedule(Object state)
        {
            Logger.Info("Get GR data: begin");

            var repo = new GRRepository();
            IList<String> grData = repo.GetData(ProcessId, FunctionId.Substring(0, 1), FunctionId);

            Logger.Info("Get GR data: end");

            if (grData.Any())
            {
                Logger.Info(String.Format("Generate text file with {0} data: begin", grData.Count));

                IList<String> tabbedDataList = grData.Select(data => data.Replace("${tab}", "\t")).ToList();
                String exportPath = repo.GetGRExportPath();
                String filename = "GRExportedData" + DateTime.Now.ToString("yyyyMMddHHmmss") + ".txt";
                String exportFilePath = Path.Combine(exportPath, filename);
                String localFilePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, filename);

                File.AppendAllLines(localFilePath, tabbedDataList);

                Logger.Info(String.Format("Generate text file with {0} data: end", grData.Count));

                Logger.Info("Move to FTP: begin");

                NetworkCredential ftpCred = repo.GetFtpCredential();
                FtpHandler.Upload(exportFilePath, localFilePath, ftpCred);

                Logger.Info("Move to FTP: end");

                Logger.Info("Change status to Posting: begin");

                repo.UpdateGRToPosting(ProcessId, FunctionId.Substring(0, 1), FunctionId);

                Logger.Info("Change status to Posting: end");
            }
            else
            {
                Logger.Info("There're no GR data");
            }
        }

        protected override void OnStart(string[] args)
        {
            try
            {
                Logger.Info(LogExtensions.Break);
                StartScheduler("Starting GR Data Exporter Service");
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
                Logger.Info("Stopping GR Data Exporter Service");
                StopScheduler();
            }
            catch (Exception ex)
            {
                Logger.Error(ex);
            }
        }
    }
}
