using System;

namespace GPS.ViewModels.PO
{
    public class POSubItemAddViewModel
    {
        public String SubItemDataNo { get; set; }
        public String SubItemMatDesc { get; set; }
        public Decimal SubItemQty { get; set; }
        //public String SubItemQtyStr { get; set; }
        public String SubItemUOM { get; set; }
        public Decimal SubItemPrice { get; set; }
        //public String SubItemPriceStr { get; set; }
        public String SubItemWBSNo { get; set; }
        public String SubItemCostCenter { get; set; }
        public String SubItemGLAccount { get; set; }
    }
}