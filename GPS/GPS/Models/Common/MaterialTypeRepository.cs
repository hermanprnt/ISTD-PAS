using System;
using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Common
{
    public class MaterialTypeRepository
    {

        private MaterialTypeRepository() { }

        public sealed class SqlFile
        {
            public const String _Root_Folder = "Master/Material/";
            public const String GetList = _Root_Folder + "GetAllMaterialType";
        }

        private static MaterialTypeRepository instance = null;
        public static MaterialTypeRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new MaterialTypeRepository();
                }
                return instance;
            }
        }

        public IEnumerable<MaterialType> GetAllData()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<MaterialType> result = db.Fetch<MaterialType>(SqlFile.GetList);
            db.Close();
            return result;
        }

    }
}