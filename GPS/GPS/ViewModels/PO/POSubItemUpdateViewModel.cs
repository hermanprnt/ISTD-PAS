using System;
using GPS.Models.Common;

namespace GPS.ViewModels.PO
{
    public class POSubItemUpdateViewModel : ExecProcedureModel
    {
        public String PONo { get; set; }
        public String POItemNo { get; set; }
        public String SeqItemNo { get; set; }
        public String SeqNo { get; set; }
        public String MatDesc { get; set; }
        public Decimal Qty { get; set; }
        public String QtyStr { get; set; }
        public String UOM { get; set; }
        public Decimal PricePerUOM { get; set; }
        public String PriceStr { get; set; }
        public String Currency { get; set; }
        public String WBS { get; set; }
        public String CostCenter { get; set; }
        public String GLAccount { get; set; }
    }
}