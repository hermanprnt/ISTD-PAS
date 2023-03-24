using System;
using System.Collections.Generic;
using GPS.Core.GPSLogService;
using GPS.Core.ViewModel;

namespace BudgetDataImporter
{
    public partial class BudgetDataImporterService : BudgetWindowsService, ITask
    {
        public BudgetDataImporterService()
        {
            InitializeComponent();

            Logger = LogServiceExtensions.GetCurrentLogService("Budget Data Importer Service");
            CurrentTask = this;
        }

        public String SystemType { get { return "BUDGET_CONTROL"; } }

        public String SystemCd { get { return "SCH_UPDATE_BUDGET_%"; } }

        public IList<NameValueItem> ScheduleList { get; set; }

        public Int32 TaskControl { get; set; }

        public void OnSchedule(Object state)
        {
            Import.ImportData(Logger);
        }

        protected override void OnStart(string[] args)
        {
            try
            {
                Logger.Info(LogExtensions.Break);
                StartScheduler("Starting Budget Data Importer Service");
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
                Logger.Info("Stopping Budget Data Importer Service");
                StopScheduler();
            }
            catch (Exception ex)
            {
                Logger.Error(ex);
            }
        }
    }
}
