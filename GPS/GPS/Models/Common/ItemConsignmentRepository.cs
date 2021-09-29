using System;
using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Common
{
    public class ItemConsignmentRepository
    {
        private ItemConsignmentRepository() { }

        public sealed class SqlFile
        {
            public const String _Root_Folder = "Master/Material/";
            public const String GetList = _Root_Folder + "GetAllItemConsignment";
        }

        private static ItemConsignmentRepository instance = null;
        public static ItemConsignmentRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new ItemConsignmentRepository();
                }
                return instance;
            }
        }

        public IEnumerable<ItemConsignment> GetAllData()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<ItemConsignment> result = db.Fetch<ItemConsignment>(SqlFile.GetList);
            db.Close();
            return result;
        }
    }
}