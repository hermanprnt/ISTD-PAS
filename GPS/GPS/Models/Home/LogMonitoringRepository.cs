using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Home
{
    public class LogMonitoringRepository
    {
        private LogMonitoringRepository() { }
        private static LogMonitoringRepository instance = null;
        public static LogMonitoringRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new LogMonitoringRepository();
                }
                return instance;
            }
        }

        public IEnumerable<LogMonitoring> GetLookupFunction()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            IEnumerable<LogMonitoring> result = db.Fetch<LogMonitoring>("Home/LogMonitoring/LookupFunction");

            db.Close();
            return result;
        }

        public IEnumerable<LogMonitoring> GetLookupStatus()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            IEnumerable<LogMonitoring> result = db.Fetch<LogMonitoring>("Home/LogMonitoring/LookupStatus");

            db.Close();
            return result;
        }

        public IEnumerable<LogMonitoring> GetLookupUser()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            IEnumerable<LogMonitoring> result = db.Fetch<LogMonitoring>("Home/LogMonitoring/LookupUserId");

            db.Close();
            return result;
        }

        public int CountData(string ProcDateFrom, string ProcDateTo, string FunctionName, string ProcessId, string Status, string User)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                ProcDateFrom = ProcDateFrom,
                ProcDateTo = ProcDateTo,
                FunctionId = FunctionName,
                ProcessId = ProcessId,
                Status = Status,
                User = User
            };

            int result = db.SingleOrDefault<int>("Home/LogMonitoring/CountData", args);
            db.Close();

            return result;
        }

        public IEnumerable<LogMonitoring> GetListData(string ProcDateFrom, string ProcDateTo, string FunctionName, string ProcessId, string Status, string User, int start, int length)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                ProcDateFrom = ProcDateFrom,
                ProcDateTo = ProcDateTo,
                FunctionId = FunctionName,
                ProcessId = ProcessId,
                Status = Status,
                User = User,
                Start = start,
                Length = length
            };

            IEnumerable<LogMonitoring> result = db.Fetch<LogMonitoring>("Home/LogMonitoring/GetData", args);
            
            db.Close();
            return result;
        }
    }
}