using System;
using System.Collections.Generic;
using GPS.Core.GPSLogService;
using GPS.Core.ViewModel;
using GPS.Core.WindowsService;

namespace SAPDataImporter
{
    public partial class SAPDataImporterService : GPSWindowsService, ITask
    {
        public SAPDataImporterService()
        {
            InitializeComponent();

            Logger = LogServiceExtensions.GetCurrentLogService("SAP Data Importer Service");
            CurrentTask = this;
        }

        public String FunctionId { get { return "001004"; } }

        public IList<NameValueItem> ScheduleList { get;set; }

        public Int32 TaskControl { get; set; }

        public void OnSchedule(Object state)
        {
            Import.ImportDataFromSAP(Logger);
        }

        protected override void OnStart(string[] args)
        {
            try
            {
                Logger.Info(LogExtensions.Break);
                StartScheduler("Starting SAP Data Importer Service");
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
                Logger.Info("Stopping SAP Data Importer Service");
                StopScheduler();
            }
            catch (Exception ex)
            {
                Logger.Error(ex);
            }
        }
    }
}
