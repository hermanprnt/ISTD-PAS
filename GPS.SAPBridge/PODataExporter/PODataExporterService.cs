using System;
using System.Collections.Generic;
using GPS.Core.GPSLogService;
using GPS.Core.ViewModel;
using GPS.Core.WindowsService;

namespace PODataExporter
{
    public partial class PODataExporterService : GPSWindowsService, ITask
    {
        public PODataExporterService()
        {
            InitializeComponent();

            Logger = LogServiceExtensions.GetCurrentLogService("PO Data Exporter Service");
            CurrentTask = this;
        }

        public String FunctionId { get { return "001001"; } }

        public IList<NameValueItem> ScheduleList { get;set; }

        public Int32 TaskControl { get; set; }

        public void OnSchedule(Object state)
        {
            Export.GenerateData(Logger);
        }

        protected override void OnStart(string[] args)
        {
            try
            {
                Logger.Info(LogExtensions.Break);
                StartScheduler("Starting PO Data Exporter Service");
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
                Logger.Info("Stopping PO Data Exporter Service");
                StopScheduler();
            }
            catch (Exception ex)
            {
                Logger.Error(ex);
            }
        }
    }
}
