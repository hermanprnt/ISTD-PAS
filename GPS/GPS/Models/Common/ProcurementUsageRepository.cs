using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Common
{
    public class ProcurementUsageRepository
    {
        private ProcurementUsageRepository()
        {

        }


        private static ProcurementUsageRepository instance = null;
        public static ProcurementUsageRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new ProcurementUsageRepository();
                }
                return instance;
            }
        }

        public IEnumerable<ProcurementUsage> GetAllData()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<ProcurementUsage> result = db.Fetch<ProcurementUsage>("ProcurementUsage/GetAllProcurementUsage");
            db.Close();
            return result;
        }
    }
}