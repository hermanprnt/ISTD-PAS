using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Home
{
    public class LogMonitoringDetailRepository
    {
        private LogMonitoringDetailRepository() { }
        private static LogMonitoringDetailRepository instance = null;
        public static LogMonitoringDetailRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new LogMonitoringDetailRepository();
                }
                return instance;
            }
        }

        public LogMonitoringDetail GetHeader(string ProcessId)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                ProcessId = ProcessId
            };

            var result = db.Fetch<LogMonitoringDetail>("Home/LogMonitoringDetail/GetHeaderData", args);

            db.Close();
            return result[0];
        }

        public int CountData(string ProcessId)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                ProcessId = ProcessId
            };

            int result = db.SingleOrDefault<int>("Home/LogMonitoringDetail/CountData", args);
            db.Close();

            return result;
        }

        public IEnumerable<LogMonitoringDetail> GetListData(string ProcessId, int start, int length)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                ProcessId = ProcessId,
                Start = start,
                Length = length
            };

            IEnumerable<LogMonitoringDetail> result = db.Fetch<LogMonitoringDetail>("Home/LogMonitoringDetail/GetData", args);
            
            db.Close();
            return result;
        }

        public List<LogMonitoringDetail> GetDownloadData(string ProcessId)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                ProcessId = ProcessId
            };

            List<LogMonitoringDetail> result = db.Fetch<LogMonitoringDetail>("Home/LogMonitoringDetail/GetDownloadData", args);

            db.Close();
            return result;
        }
    }
}