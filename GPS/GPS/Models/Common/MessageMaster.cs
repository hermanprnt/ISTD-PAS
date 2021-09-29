using System;

namespace GPS.Models.Common
{
    public class MessageMaster
    {
        public String MessageId { get; set; }
        public String Message_Text { get; set; }
        public String Message_Type { get; set; }
        public String Description { get; set; }
        public String Solution { get; set; }
        public String PIC1 { get; set; }
        public String PIC2 { get; set; }
        public String Alert_Flag { get; set; }
        public String CreatedBy { get; set; }
        public String CreatedDate { get; set; }
        public String ChangedBy { get; set; }
        public String ChangedDate { get; set; }
    }
}