using System.Collections.Generic;
using System.Web.Mvc;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Common
{
    public class AttachmentRepository : Controller
    {
        private static AttachmentRepository instance = null;
        public static AttachmentRepository Instance
        {
            get { return instance ?? (instance = new AttachmentRepository()); }
        }

        public IList<Attachment> GetAllData(string docNo)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IList<Attachment> result = db.Fetch<Attachment>("Common/GetAllAttachment", new { DOC_NO = docNo });
            db.Close();
            return result;
        }
    }
}