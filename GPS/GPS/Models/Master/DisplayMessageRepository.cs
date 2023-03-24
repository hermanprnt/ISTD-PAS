using System;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Master
{
    public class DisplayMessageRepository
    {
        private DisplayMessageRepository() { }
        private static readonly DisplayMessageRepository instance = null;
        public static DisplayMessageRepository Instance
        {
            get { return instance ?? new DisplayMessageRepository(); }
        }

        public DisplayMessage GetDisplayMessage(String messageId)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            DisplayMessage result = db.SingleOrDefault<DisplayMessage>("Master/GetDisplayMessage", new { MessageId = messageId });
            db.Close();

            return result;
        }
    }
}