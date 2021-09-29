using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Master
{
    public class StatusRepository
    {
        private StatusRepository() { }

        #region Singleton
        private static StatusRepository instance = null;
        public static StatusRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new StatusRepository();
                }
                return instance;
            }
        }
        #endregion

        #region Data Methods
        public IEnumerable<Status> GetStatusData()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<Status> result = db.Fetch<Status>("Master/GetAllStatus");
            db.Close();
            return result;
        }

        public IEnumerable<Status> GetDocumentStatusData()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<Status> result = db.Fetch<Status>("Master/GetAllDocumentStatus");
            db.Close();
            return result;
        }

        public IEnumerable<Status> GetDetailStatusData()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<Status> result = db.Fetch<Status>("Master/GetAllDetailStatus");
            db.Close();
            return result;
        }
        #endregion
    }
}