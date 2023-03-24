using System;
using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Common
{
    public class MaterialGroupRepository
    {

        private MaterialGroupRepository() { }

        public sealed class SqlFile
        {
            public const String _Root_Folder = "Master/Material/";
            public const String GetList = _Root_Folder + "GetAllMaterialGroup";
        }

        private static MaterialGroupRepository instance = null;
        public static MaterialGroupRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new MaterialGroupRepository();
                }
                return instance;
            }
        }

        public IEnumerable<MaterialGroup> GetAllData()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<MaterialGroup> result = db.Fetch<MaterialGroup>(SqlFile.GetList);
            db.Close();
            return result;
        }
    }
}