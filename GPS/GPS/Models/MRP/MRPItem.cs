using System;

namespace GPS.Models.MRP
{
    public class MRPItem
    {
        public Int32 DataNo { get; set; }
        public String MaterialCode { get; set; }
        public String MaterialDesc { get; set; }
        public String Plant { get; set; }
        public String SLoc { get; set; }
        public Int32 PcsPerKanban { get; set; }
        public Int32 NQty { get; set; }
        public Int32 N1Qty { get; set; }
        public Int32 N2Qty { get; set; }
        public Int32 N3Qty { get; set; }
        public Int32 N4Qty { get; set; }
        public Int32 N5Qty { get; set; } 
    }
}