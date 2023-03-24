using System.Collections.Generic;
using Toyota.Common.Web.Platform;
using Toyota.Common.Database;
using System;

namespace GPS.Models.Master
{
    public class BudgetConfigRepository
    {

        #region added : 20190614 : isid.rgl
        public sealed class SqlFile
        {
            public const string _Root_Folder = "Master/BudgetConfig/";
            public const string SaveUploadData = _Root_Folder + "SaveUploadedData";
            public const string GetListWBSType = _Root_Folder + "GetAllWBSType";
            
            public const string GetSelectedData = _Root_Folder + "GetSelectedData";

            public const string CountData = _Root_Folder + "CountData";
            public const string GetData = _Root_Folder + "GetData";

            public const string GetDataLookupWBS = _Root_Folder + "GetDataLookupWBS";
            public const string CountDataLookupWBS = _Root_Folder + "CountDataLookupWBS";
            public const string SaveEditData = _Root_Folder + "SaveEditData";
        }
        #endregion

        private BudgetConfigRepository() { }
        private static BudgetConfigRepository instance = null;

        public static BudgetConfigRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new BudgetConfigRepository();
                }
                return instance;
            }
        }

        #region Upload Data : 20190703 : isid.rgl
        public string SaveUploadedData(BudgetConfig param, string username)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                param.WBS_NO,
                param.WBS_YEAR,
                param.WBS_TYPE,
                UId = username
            };

            string result = db.SingleOrDefault<string>(SqlFile.SaveUploadData, args);
            db.Close();

            return result;
        }

        #endregion

        #region 20190717 : isid.rgl : Get List Data
        public IEnumerable<ComboWBSType> GetAllData()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<ComboWBSType> result = db.Fetch<ComboWBSType>(SqlFile.GetListWBSType);
            db.Close();
            return result;
        }
        public BudgetConfig GetSelectedData(String wbsno)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            var data = db.SingleOrDefault<BudgetConfig>(SqlFile.GetSelectedData, new { WbsNo = wbsno });
            db.Close();

            return data;
        }
        public int CountData(BudgetConfig param)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                WBS_NO = param.WBS_NO,
                WBS_NAME = param.WBS_NAME,
                WBS_YEAR = param.WBS_YEAR,
                DIVISION_ID = param.DIVISION_ID
            };
            int result = db.SingleOrDefault<int>(SqlFile.CountData,args);
            db.Close();

            return result;
        }

        public IEnumerable<DataWBSNO> GetListData(BudgetConfig param, int start, int length)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                WBS_NO = param.WBS_NO,
                WBS_NAME = param.WBS_NAME,
                WBS_YEAR = param.WBS_YEAR,
                DIVISION_ID = param.DIVISION_ID,
                Start = start,
                Length = length
            };

            IEnumerable<DataWBSNO> result = db.Fetch<DataWBSNO>(SqlFile.GetData, args);

            db.Close();
            return result;
        }

        #endregion
 
        #region 20190718 : isid.rgl : Lookup WBS No
        public IEnumerable<DataWBSNO> GetDataLookupWbsByFreeParam(BudgetConfig param, int start, int length)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            List<DataWBSNO> result = new List<DataWBSNO>();

            dynamic args = new
            {
                WBS_NO = param.WBS_NO,
                WBS_NAME = param.WBS_NAME,
                WBS_YEAR = param.WBS_YEAR,
                Start = start,
                Length = length
            };
            result = db.Fetch<DataWBSNO>(SqlFile.GetDataLookupWBS, args);
            db.Close();

            return result;
        }
        public int CountDataByFreeParam(BudgetConfig param)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            int result = 0;
            dynamic args = new
            {
                WBS_NO = param.WBS_NO,
                WBS_NAME = param.WBS_NAME,
                WBS_YEAR = param.WBS_YEAR
            };
            result = db.SingleOrDefault<int>(SqlFile.CountDataLookupWBS, args);
            db.Close();
            return result;
        }
        #endregion

        #region : 20190719 : isid.rgl : SAVE / EDIT / DELETE Data
        public String SaveEditDeleteData(string action, string uid, BudgetConfig param)
        {
            String result = "";
            try
            {
                IDBContext db = DatabaseManager.Instance.GetContext();
                dynamic args = new
                {
                    Flag = action,
                    WBS_NO = param.WBS_NO,
                    WBS_NAME = param.WBS_NAME,
                    WBS_YEAR = param.WBS_YEAR,
                    WBS_TYPE = param.WBS_TYPE,
                    DIVISION_ID = param.DIVISION_ID,
                    UId = uid
                };

                result = db.SingleOrDefault<string>(SqlFile.SaveEditData, args);
                db.Close();
            }
            catch (Exception ex)
            {
                result = "Error|Message Err : " + ex.Message;
            }
            return result;
        }
        #endregion

    }
}