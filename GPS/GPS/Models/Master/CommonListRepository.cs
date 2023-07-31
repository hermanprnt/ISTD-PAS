using System.Collections.Generic;
using GPS.Constants.Master;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Master
{
    public class CommonListRepository
    {
        private CommonListRepository() { }
        private static CommonListRepository instance = null;
        public static CommonListRepository Instance
        {
            get { return instance ?? (instance = new CommonListRepository()); }
        }

        #region COMMON DROPDOWN
        public IEnumerable<CommonList> GetDataPRType()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<CommonList> result = db.Fetch<CommonList>(MasterSqlFiles.GetPRType);
            db.Close();
            return result;
        }

        public IEnumerable<CommonList> GetDataFDCheck()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<CommonList> result = db.Fetch<CommonList>(MasterSqlFiles.GetFDCheck);
            db.Close();
            return result;
        }


        // Start add by Khanif Hanafi 17-07-2019
        public IEnumerable<CommonList> GetDataItemClassList()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<CommonList> result = db.Fetch<CommonList>(MasterSqlFiles.GetItemClass);
            db.Close();
            return result;
        }

        
        public IEnumerable<CommonList> GetDataPRCoordinatorList()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<CommonList> result = db.Fetch<CommonList>(MasterSqlFiles.GetPRCoordinator);
            db.Close();
            return result;
        }
        public IEnumerable<CommonList> GetDataCoordinatorList()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<CommonList> result = db.Fetch<CommonList>(MasterSqlFiles.GetCoordinatorList);
            db.Close();
            return result;
        }

        public IEnumerable<CommonList> GetDataMatGroup()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<CommonList> result = db.Fetch<CommonList>(MasterSqlFiles.GetMatGroup);
            db.Close();
            return result;
        }
        // End add by Khanif Hanafi 17-07-2019



        public IEnumerable<CommonList> GetDataPurchasing_Group()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<CommonList> result = db.Fetch<CommonList>(MasterSqlFiles.GetPurchasingGroup);
            db.Close();
            return result;
        }

        public IEnumerable<CommonList> GetDataCalculation_Scheme()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<CommonList> result = db.Fetch<CommonList>(MasterSqlFiles.GetCalculationSchema);
            db.Close();
            return result;
        }

        #endregion
    }
}