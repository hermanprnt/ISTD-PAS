using System;
using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Common
{
    public class MessageRepository
    {
        public sealed class SqlFile
        {
            public const String GetById = "Master/Message/GetById";
        }

        private MessageRepository() { }
        private static MessageRepository instance = null;
        public static MessageRepository Instance
        {
            get { return instance ?? (instance = new MessageRepository()); }
        }

        public String GetMessageText(String messageId)
        {
            MessageMaster system = GetById(messageId);
            return system == null ? String.Empty : system.Message_Text;
        }

        private MessageMaster GetById(String messageId)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            MessageMaster result = db.SingleOrDefault<MessageMaster>(SqlFile.GetById, new { MESSAGE_ID = messageId });
            db.Close();

            return result;
        }

        public MessageMaster GetSingleData(string messageId)
        {
            return GetById(messageId);
        }
    }
}