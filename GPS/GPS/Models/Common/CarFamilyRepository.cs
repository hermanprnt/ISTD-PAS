using System;
using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Common
{
    public class CarFamilyRepository
    {
        private CarFamilyRepository() { }

        public sealed class SqlFile
        {
            public const String _Root_Folder = "Master/Material/";
            public const String GetList = _Root_Folder + "GetAllCarFamily";
        }

        private static CarFamilyRepository instance = null;
        public static CarFamilyRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new CarFamilyRepository();
                }
                return instance;
            }
        }

        public IEnumerable<CarFamily> GetAllData()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<CarFamily> result = db.Fetch<CarFamily>(SqlFile.GetList);
            db.Close();
            return result;
        }
    }
}