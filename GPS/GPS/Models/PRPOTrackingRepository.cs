using System;
using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Common
{
    public class PRPOTrackingRepository
    {
        public sealed class SqlFile
        {
            public const String _Root_Folder_Inquiry = "PRPOTracking/";

            public const String _GetList = _Root_Folder_Inquiry + "GetList";
            public const String _CountList = _Root_Folder_Inquiry + "CountList";
            public const String _GetSecondList = _Root_Folder_Inquiry + "GetSecondList";
            public const String _GetThirdList = _Root_Folder_Inquiry + "GetThirdList";
        }

        private PRPOTrackingRepository() { }
        private static PRPOTrackingRepository instance = null;

        public static PRPOTrackingRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new PRPOTrackingRepository();
                }
                return instance;
            }
        }

        #region SEARCH
        public Tuple<List<PRPOTrackingList>, string> ListData(PRPOTrackingParam param, int start, int length)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            List<PRPOTrackingList> result = new List<PRPOTrackingList>();
            string message = "";
            try
            {
                dynamic args = new
                {
                    param.DOC_TYPE,
                    param.DOC_STATUS,
                    param.DOC_DATE_FROM,
                    param.DOC_DATE_TO,
                    param.DOC_DESC,
                    param.DOC_NO,
                    param.REGISTERED_BY,
                    Start = start,
                    Length = length
                };
                result = db.Fetch<PRPOTrackingList>(SqlFile._GetList, args);
            }
            catch (Exception e)
            {
                message = e.Message;
            }
            finally
            {
                db.Close();
            }

            return new Tuple<List<PRPOTrackingList>, string>(result, message);
        }

        public Tuple<int, string> CountRetrievedData(PRPOTrackingParam param)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            int result = 0;
            string message = "";
            try
            {
                dynamic args = new
                {
                    param.DOC_TYPE,
                    param.DOC_STATUS,
                    param.DOC_DATE_FROM,
                    param.DOC_DATE_TO,
                    param.DOC_DESC,
                    param.DOC_NO,
                    param.REGISTERED_BY
                };

                result = db.SingleOrDefault<int>(SqlFile._CountList, args);
            }
            catch (Exception e)
            {
                message = e.Message;
            }
            finally
            {
                db.Close();
            }
            return new Tuple<int, string>(result, message);
        }

        public IEnumerable<PRPOTrackingList> GetSecondRow(PRPOTrackingParam param)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            
            dynamic args = new
            {
                param.DOC_TYPE,
                param.DOC_NO
            };
            IEnumerable<PRPOTrackingList> result = db.Fetch<PRPOTrackingList>(SqlFile._GetSecondList, args);

            return result;
        }

        public IEnumerable<PRPOTrackingList> GetThirdRow(PRPOTrackingParam param)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                param.DOC_TYPE,
                param.DOC_NO,
                param.DOC_ITEM_NO
            };
            IEnumerable<PRPOTrackingList> result = db.Fetch<PRPOTrackingList>(SqlFile._GetThirdList, args);

            return result;
        }
        #endregion
    }
}