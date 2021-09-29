using System;

namespace GPS.Models.Common
{
    public class Notification
    {
        public Int64 NOTIFICATION_ID { get; set; }
        public String NOTIFICATION_GRP_ID { get; set; }
        public String TITLE { get; set; }
        public String CONTENT { get; set; }
        public String AUTHOR { get; set; }
        public String CREATED_BY { get; set; }
        public DateTime CREATED_DT { get; set; }
        public String CHANGED_BY { get; set; }
        public DateTime CHANGED_DT { get; set; }
        public DateTime VALID_FROM { get; set; }
        public DateTime VALID_TO { get; set; }
    }
}