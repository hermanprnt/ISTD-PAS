using System;
using System.Collections.Generic;
using GPS.Core.TDKSimplifier;
using GPS.Core.ViewModel;
using Toyota.Common.Database;
using Toyota.Common.Lookup;

namespace GPS.Core.WindowsService
{
    public class SchedulerRepository
    {
        private readonly IDBContext db;

        public SchedulerRepository()
        {
            TDKDatabase dbManager = ObjectPool.Factory.GetInstance<TDKDatabase>();
            db = dbManager.GetDefaultExecDbContext();
        }

        public String GetNewProcessId(String actionName, String functionId)
        {
            String result = db.ExecuteScalar<String>("GetNewProcessId", new { ActionName = actionName, FunctionId = functionId });
            db.Close();

            return result;
        }

        public IList<NameValueItem> GetScheduleList(String functionId)
        {
            var result = db.Fetch<NameValueItem>("GetScheduleList", new { FunctionId = functionId });
            db.Close();

            return result;
        }

        public IList<RegisteredSchedule> GetRegisteredSchedule(String functionId)
        {
            IList<RegisteredSchedule> scheduleList = db
                .Fetch<RegisteredSchedule>("GetRegisteredSchedule", new { FunctionId = functionId });

            db.Close();

            return scheduleList;
        }

        public ActionResponseViewModel RegisterNew(RegisteredSchedule scheduled)
        {
            String result = db.ExecuteScalar<String>("RegisterNew", scheduled);
            db.Close();

            var resultViewModel = result.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return resultViewModel;
        }

        public ActionResponseViewModel UpdateQueuedToRun(RegisteredSchedule queued)
        {
            String result = db.ExecuteScalar<String>("UpdateQueuedToRun", queued);
            db.Close();

            var resultViewModel = result.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return resultViewModel;
        }

        public ActionResponseViewModel UpdateRunningToFinish(RegisteredSchedule running)
        {
            String result = db.ExecuteScalar<String>("UpdateRunningToFinish", running);
            db.Close();

            var resultViewModel = result.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return resultViewModel;
        }
    }
}