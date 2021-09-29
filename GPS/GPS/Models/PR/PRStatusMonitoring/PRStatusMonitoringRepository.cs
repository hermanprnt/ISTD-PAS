using System;
using System.Collections.Generic;
using GPS.Models.Common;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;
using GPS.Core;
using GPS.Core.ViewModel;

namespace GPS.Models.PR.PRStatusMonitoring
{
    public class PRStatusMonitoringRepository { 
        public sealed class SqlFile
        {
            public const String _Root_Folder_Status = "PR/PRStatusMonitoring/";
            public const String _GetList = _Root_Folder_Status + "GetList";
            public const String _CountList = _Root_Folder_Status + "CountList";
            public const String _SummaryData = _Root_Folder_Status + "SummaryData";
            public const String _GetFilterDelayStatus = _Root_Folder_Status + "GetFilterDelayStatus";
        }

        private PRStatusMonitoringRepository() { }
        private static PRStatusMonitoringRepository instance = null;

        public static PRStatusMonitoringRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new PRStatusMonitoringRepository();
                }
                return instance;
            }
        }

        public Tuple<List<PRStatusMonitoring>, string> GetDetailPR(PRStatusMonitoringParam param, int page, int pageSize)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            List<PRStatusMonitoring> resultquery = new List<PRStatusMonitoring>();
            string message = "";

            try
            {
                dynamic args = new
                {
                    DIVISION_ID = param.DIVISION_ID,
                    PR_NO = param.PR_NO,
                    PR_DESC = param.PR_DESC,
                    CREATED_BY = param.CREATED_BY,
                    PO_NO = param.PO_NO,
                    VENDOR = param.VENDOR,
                    GR_NO = param.GR_NO,
                    ORDER_BY = param.ORDER_BY,
                    currentPage = page,
                    pageSize = pageSize
                };
                resultquery = db.Fetch<PRStatusMonitoring>(SqlFile._GetList, args);
            }
            catch (Exception e)
            {
                message = e.Message;
            }
            finally { db.Close(); }

            return new Tuple<List<PRStatusMonitoring>, string>(resultquery, message);
        }

        public PRSummaryMonitoring GetSummaryData(int DivisionId)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                DIVISION_ID = DivisionId
            };
            var result = db.SingleOrDefault<PRSummaryMonitoring>(SqlFile._SummaryData, args);

            return result;
        }

        public Tuple<int, string> CountDetailPR(PRStatusMonitoringParam param)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            int result = 0;
            string message = "";

            try
            {
                dynamic args = new
                {
                    DIVISION_ID = param.DIVISION_ID,
                    PR_NO = param.PR_NO,
                    PR_DESC = param.PR_DESC,
                    CREATED_BY = param.CREATED_BY,
                    PO_NO = param.PO_NO,
                    VENDOR = param.VENDOR,
                    GR_NO = param.GR_NO,
                    ORDER_BY = param.ORDER_BY
                };
                result = db.SingleOrDefault<int>(SqlFile._CountList, args);
            }
            catch (Exception e)
            {
                message = e.Message;
            }
            finally { db.Close(); }

            return new Tuple<int, string>(result, message);
        }

        public IEnumerable<GPS.Models.Common.NameValueItem> GetFilterDelayStatus()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
            };

            IEnumerable<GPS.Models.Common.NameValueItem> result = db.Fetch<GPS.Models.Common.NameValueItem>(SqlFile._GetFilterDelayStatus, args);
            db.Close();
            return result;
        }
    }
}