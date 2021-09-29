using System;

namespace GPS.Models.Common
{
    public class Announcement
    {
        public Int64 PROCESS_ID { get; set; }
        public String MSG_TYPE { get; set; }
        public String TARGET_RECIPIENT { get; set; }
        public String MSG_CONTENT { get; set; }
        public String MSG_ATTACHMENT { get; set; }
        public String CREATED_BY { get; set; }
        public DateTime CREATED_DT { get; set; }
        public String CHANGED_BY { get; set; }
        public DateTime CHANGED_DT { get; set; }
    }
}