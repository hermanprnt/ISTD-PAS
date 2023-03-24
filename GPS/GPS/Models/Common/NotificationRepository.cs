using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Common
{
    public class NotificationRepository
    {
        private static NotificationRepository instance = null;
        public static NotificationRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new NotificationRepository();
                }
                return instance;
            }
        }

        public IEnumerable<Notification> GetNotificationList(string reg_no)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                RegNo = reg_no
            };

            IEnumerable<Notification> result = db.Fetch<Notification>("Common/GetAllNotification", args);
            db.Close();
            return result;
        }
    }
}