using System;
using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Common
{
    public class UnitOfMeasureRepository
    {
        private UnitOfMeasureRepository() { }

        public sealed class SqlFile
        {
            public const String _Root_Folder = "Master/Material/";
            public const String GetList = _Root_Folder + "GetAllUnitOfMeasure";
        }

        private static UnitOfMeasureRepository instance = null;
        public static UnitOfMeasureRepository Instance
        {
            get { return instance ?? (instance = new UnitOfMeasureRepository()); }
        }

        public IEnumerable<UnitOfMeasure> GetAllData()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<UnitOfMeasure> result = db.Fetch<UnitOfMeasure>(SqlFile.GetList);
            db.Close();
            return result;
        }
    }
}