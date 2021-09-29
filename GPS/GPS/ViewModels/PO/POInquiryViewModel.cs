using System;
using GPS.Models.PO;

namespace GPS.ViewModels.PO
{
    public class POInquiryViewModel : GenericViewModel<PurchaseOrder>
    {
        public String ItemDataName { get; set; }
        public String SubItemDataName { get; set; }
    }
}