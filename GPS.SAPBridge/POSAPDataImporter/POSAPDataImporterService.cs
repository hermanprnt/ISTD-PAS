using System;
using System.Collections.Generic;
using GPS.Core.GPSLogService;
using GPS.Core.ViewModel;
using GPS.Core.WindowsService;

namespace POSAPDataImporter
{
    public partial class POSAPDataImporterService : GPSWindowsService, ITask
    {
        public POSAPDataImporterService()
        {
            InitializeComponent();

            Logger = LogServiceExtensions.GetCurrentLogService("PO SAP Data Importer Service");
            CurrentTask = this;
        }

        public String FunctionId { get { return "001005"; } } //isi function id nya

        public IList<NameValueItem> ScheduleList { get; set; }

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
                StartScheduler("Starting PO SAP Data Importer Service");
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
                Logger.Info("Stopping PO SAP Data Importer Service");
                StopScheduler();
            }
            catch (Exception ex)
            {
                Logger.Error(ex);
            }
        }
    }
}
