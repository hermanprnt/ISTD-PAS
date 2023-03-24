using System;
using GPS.CommonFunc;
using GPS.Models.Common;

namespace GPS.ViewModels.PO
{
    public class POItemUpdateViewModel : ExecProcedureModel
    {
        public String PONo { get; set; }
        public String POItemNo { get; set; }
        public Int32 SeqItemNo { get; set; }
        public String MatDesc { get; set; }
        public String Plant { get; set; }
        public String SLoc { get; set; }
        public String UOM { get; set; }
        public String DeliveryDateString
        {
            get { return DeliveryDate == null ? String.Empty : DeliveryDate.Value.ToStandardFormat(); }
            set { DeliveryDate = String.IsNullOrEmpty(value) ? (DateTime?)null : value.FromStandardFormat(); }
        }
        public DateTime? DeliveryDate { get; set; }
        public Decimal Qty { get; set; }
        public String QtyStr { get; set; }
        public Decimal PricePerUOM { get; set; }
        public String PriceStr { get; set; }
        public String Currency { get; set; }
        //public Int64 ProcessId { get; set; }
    }
}