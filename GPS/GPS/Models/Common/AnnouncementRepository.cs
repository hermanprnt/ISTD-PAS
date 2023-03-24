using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Common
{
    public class AnnouncementRepository
    {
        private static AnnouncementRepository instance = null;
        public static AnnouncementRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new AnnouncementRepository();
                }
                return instance;
            }
        }

        public IEnumerable<Announcement> GetAllData(string reg_no)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                RegNo = reg_no
            };

            IEnumerable<Announcement> result = db.Fetch<Announcement>("Common/GetAllAnnouncement", args);
            db.Close();
            return result;
        }
    }
}