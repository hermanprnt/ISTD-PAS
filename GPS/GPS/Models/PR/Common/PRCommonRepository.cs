using System.Collections.Generic;
using GPS.Constants.PR;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.PR.Common
{
    public class PRCommonRepository
    {
        private PRCommonRepository() { }
        private static PRCommonRepository instance = null;

        public static PRCommonRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new PRCommonRepository();
                }
                return instance;
            }
        }

        #region COMMON DROPDOWN
        public IEnumerable<PRCommonList> GetDataPRType()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<PRCommonList> result = db.Fetch<PRCommonList>(PurchaseRequisitionSqlFiles.GetPRType);
            db.Close();
            return result;
        }

        public IEnumerable<PRCommonList> GetDataAsset_Cat()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<PRCommonList> result = db.Fetch<PRCommonList>(PurchaseRequisitionSqlFiles.AssetCatList);
            db.Close();
            return result;
        }

        public IEnumerable<PRCommonList> GetDataAsset_Class()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<PRCommonList> result = db.Fetch<PRCommonList>(PurchaseRequisitionSqlFiles.AssetClassList);
            db.Close();
            return result;
        }

        public IEnumerable<PRCommonList> GetDataCostCenter(int pDIV)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new { DIVISION_ID = pDIV };
            IEnumerable<PRCommonList> resultquery = db.Fetch<PRCommonList>(PurchaseRequisitionSqlFiles.CostCenterList, args);
            db.Close();
            return resultquery;
        }

        public IEnumerable<PRCommonList> GetDataCostCenterByCoordinator(string prCoordinator, int pDIV, string regno)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new { PR_COORDINATOR = prCoordinator, DIVISION_ID = pDIV, REG_NO = regno };
            IEnumerable<PRCommonList> resultquery = db.Fetch<PRCommonList>(PurchaseRequisitionSqlFiles.CostCenterListByCoordinator, args);
            db.Close();
            return resultquery;
        }

        //FID.Ridwan: 20220705
        public IEnumerable<PRCommonList> GetDataCostCenterFamsDB(string assetNo, string subAssetNo)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new { ASSET_NO = assetNo, SUB_ASSET_NO = subAssetNo };
            IEnumerable<PRCommonList> resultquery = db.Fetch<PRCommonList>(PurchaseRequisitionSqlFiles.CostCenterListFamsDB, args);
            db.Close();
            return resultquery;
        }

        public IEnumerable<PRCommonList> GetDataPRStatusFlag(string type)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                TYPE = type
            };
            IEnumerable<PRCommonList> result = db.Fetch<PRCommonList>(PurchaseRequisitionSqlFiles.PRStatusList, args);
            db.Close();
            return result;
        }
        #endregion

        #region HOME
        public IEnumerable<PRCommonList> GetHomeTracking(string noreg)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                NOREG = noreg
            };
            IEnumerable<PRCommonList> result = db.Fetch<PRCommonList>(PurchaseRequisitionSqlFiles.HomeTrackingList, args);
            db.Close();
            return result;
        }
        #endregion

    }
}