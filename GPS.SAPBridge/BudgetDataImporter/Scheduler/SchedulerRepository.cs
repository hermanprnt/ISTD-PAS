using System;
using System.Collections.Generic;
using GPS.Core.TDKSimplifier;
using GPS.Core.ViewModel;
using GPS.Core;
using Toyota.Common.Database;
using Toyota.Common.Lookup;

namespace BudgetDataImporter
{
    public class SchedulerRepository
    {
        private readonly IDBContext db;

        public SchedulerRepository()
        {
            TDKDatabase dbManager = ObjectPool.Factory.GetInstance<TDKDatabase>();
            db = dbManager.GetDefaultExecDbContext();
        }

        public String GetNewProcessId()
        {
            String result = db.ExecuteScalar<String>("Scheduler/GetNewProcessId");
            db.Close();

            return result;
        }

        public IList<NameValueItem> GetScheduleList(String SystemType, String SystemCd)
        {
            var result = db.Fetch<NameValueItem>("Scheduler/GetScheduleList", new { SystemType, SystemCd });
            db.Close();

            return result;
        }

        public IList<RegisteredSchedule> GetRegisteredSchedule(String SystemType)
        {
            IList<RegisteredSchedule> scheduleList = db
                .Fetch<RegisteredSchedule>("Scheduler/GetRegisteredSchedule", new { SystemType });

            db.Close();

            return scheduleList;
        }

        public ActionResponseViewModel RegisterNew(RegisteredSchedule scheduled)
        {
            String result = db.ExecuteScalar<String>("Scheduler/RegisterNew", scheduled);
            db.Close();

            var resultViewModel = result.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return resultViewModel;
        }

        public ActionResponseViewModel UpdateQueuedToRun(RegisteredSchedule queued)
        {
            String result = db.ExecuteScalar<String>("Scheduler/UpdateQueuedToRun", queued);
            db.Close();

            var resultViewModel = result.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return resultViewModel;
        }

        public ActionResponseViewModel UpdateRunningToFinish(RegisteredSchedule running)
        {
            String result = db.ExecuteScalar<String>("Scheduler/UpdateRunningToFinish", running);
            db.Close();

            var resultViewModel = result.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return resultViewModel;
        }
    }
}