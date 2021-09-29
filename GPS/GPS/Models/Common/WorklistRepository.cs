using System;
using System.Collections.Generic;
using GPS.Constants.PR;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Common
{
    public class WorklistRepository
    {
        private WorklistRepository()
        {

        }

        private static WorklistRepository instance = null;
        public static WorklistRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new WorklistRepository();
                }
                return instance;
            }
        }

        public Tuple<int, string> CountWorklist(WorklistParam param = null)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            int result = 0;
            string message = "";

            try
            {
                dynamic args = new
                {
                    DOC_NO = param.DOC_NO,
                    ITEM_NO = param.ITEM_NO,
                    DOC_TYPE = param.DOC_TYPE,
                };

                result = db.ExecuteScalar<int>(PurchaseRequisitionSqlFiles.CountWorkflowData, args);
            }
            catch (Exception e)
            {
                message = e.Message;
            }
            finally
            {
                db.Close();
            }
            return new Tuple<int,string>(result, message);
        }

        public Tuple<List<Worklist>, string> GetWorklist(WorklistParam param = null, Int64 pageIndex = 1, int pageSize = 10)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            List<Worklist> result = new List<Worklist>();
            string message = "";
            try
            {
                dynamic args = new
                {
                    DOC_NO = param.DOC_NO,
                    ITEM_NO = param.ITEM_NO,
                    DOC_TYPE = param.DOC_TYPE,
                    PAGE_INDEX = pageIndex,
                    PAGE_SIZE = pageSize
                };
                result = db.Fetch<Worklist>(PurchaseRequisitionSqlFiles.GetWorkflowData, args);
            }
            catch (Exception e)
            {
                message = e.Message;
            }
            finally
            {
                db.Close();
            }
            return new Tuple<List<Worklist>,string>(result, message);
        }
    }
}