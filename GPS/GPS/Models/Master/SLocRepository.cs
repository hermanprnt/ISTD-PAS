using System;
using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Master
{
    public class SLocRepository
    {
        private SLocRepository() { }
        private static readonly SLocRepository instance = null;
        public static SLocRepository Instance
        {
            get { return instance ?? new SLocRepository(); }
        }

        public IEnumerable<SLoc> GetSLocList(String plantCode)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<SLoc> result = db.Fetch<SLoc>("Master/GetAllSLoc", new { PlantCode = plantCode });
            db.Close();

            return result;
        }

        public SLoc GetSLoc(String plantCode, String slocCode)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            SLoc result = db.SingleOrDefault<SLoc>("Master/GetSLoc", new { PlantCode = plantCode, SLocCode = slocCode });
            db.Close();

            return result;
        }
    }
}