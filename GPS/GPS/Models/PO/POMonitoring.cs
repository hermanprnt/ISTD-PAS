using System;
using GPS.CommonFunc;

namespace GPS.Models.PO
{
    // NOTE: fields in this class could be used as result of PRItem search and POItem search
    public class POMonitoring
    {
        public int NUMBER { get; set; }
        public String PR_NO { get; set; }
        public String PR_ITEM_NO { get; set; }
        public String MAT_NO { get; set; }
        public String VENDOR_CD { get; set; }
        public String VENDOR_NAME { get; set; }
        public String PO_NO { get; set; }
        public String PURCHASING_GROUP_CD { get; set; }
        public String PROC_CHANNEL_CD { get; set; }
        public String DELIVERY_ADDR { get; set; }
        public String STATUS { get; set; }
        public String REMARK { get; set; }
        public DateTime PROCESS_DATE { get; set; }
        public long PROCESS_ID { get; set; }
    }
}