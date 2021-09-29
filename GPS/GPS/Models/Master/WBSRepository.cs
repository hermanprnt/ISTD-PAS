using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Master
{
    public class WBSRepository
    {
        private WBSRepository() { }

        #region Singleton
        private static WBSRepository instance = null;
        public static WBSRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new WBSRepository();
                }
                return instance;
            }
        }
        #endregion

        #region Data Methods
        public IEnumerable<WBS> GetWBSData()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<WBS> result = db.Fetch<WBS>("Master/GetAllWBS");
            db.Close();
            return result;
        }
        #endregion
    }
}