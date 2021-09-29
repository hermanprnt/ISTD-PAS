using System.Collections.Generic;
using GPS.Constants.MRP;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.MRP
{
    public class MRPCommonRepository
    {
        private MRPCommonRepository() { }
        private static readonly MRPCommonRepository instance = null;
        public static MRPCommonRepository Instance
        {
            get { return instance ?? new MRPCommonRepository(); }
        }

        public IEnumerable<ProcUsageGroup> GetProcurementUsageGroupList()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<ProcUsageGroup> procUsageGroupList = db.Fetch<ProcUsageGroup>(MRPSqlFile.CommonGetProcurementUsageGroup);
            db.Close();

            return procUsageGroupList;
        } 
    }
}