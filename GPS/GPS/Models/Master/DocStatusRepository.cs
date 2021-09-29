using System;
using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Master
{
    public class DocStatusRepository
    {
        private DocStatusRepository() { }
        private static readonly DocStatusRepository instance = null;
        public static DocStatusRepository Instance
        {
            get { return instance ?? new DocStatusRepository(); }
        }

        public IEnumerable<DocStatus> GetDocStatusList(String docType)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<DocStatus> result = db.Fetch<DocStatus>("Master/GetAllDocStatusByType", new { DocType = docType });
            db.Close();

            return result;
        }

        public IEnumerable<DocStatus> GetDocStatusListPrInq(String docType)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<DocStatus> result = db.Fetch<DocStatus>("PR/PRInquiry/GetAllDocStatusByType", new { DocType = docType });
            db.Close();

            return result;
        }

        public DocStatus GetDocStatus(String docType, String statusCode)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            DocStatus result = db.SingleOrDefault<DocStatus>("Master/GetDocStatus", new { DocType = docType, StatusCode = statusCode });
            db.Close();

            return result;
        }
    }
}