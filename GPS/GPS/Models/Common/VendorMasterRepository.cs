using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Common
{
    public class VendorMasterRepository
    {
        private VendorMasterRepository()
        {

        }


        private static VendorMasterRepository instance = null;
        public static VendorMasterRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new VendorMasterRepository();
                }
                return instance;
            }
        }


        #region countDataVendor
        public int CountData(string param)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                Param = param
            };

            int count = db.SingleOrDefault<int>("VendorMaster/CountDataVendor", args);
            db.Close();
            return count;
        }
        #endregion

        #region GetDataVendor
        public List<VendorMaster> GetDataVendor(string param, int start, int end)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                Param = param,
                Start = start,
                End = end
            };
            List<VendorMaster> list = db.Fetch<VendorMaster>("VendorMaster/GetAllVendor", args);
            db.Close();
            return list;
        }
        #endregion
    }
}