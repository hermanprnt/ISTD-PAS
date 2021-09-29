using System;
using System.Collections.Generic;
using GPS.Models.Common;
using GPS.Models.PO;
using Toyota.Common.Credential;

namespace GPS.ViewModels.PO
{
    public class POCreationViewModel
    {
        public User CurrentUser { get; set; }
        public String ProcessId { get; set; }
        public String Operation { get; set; }

        public String PRItemDataName { get; set; }
        public String POItemDataName { get; set; }
        public String SubItemDataName { get; set; }
        public String ItemConditionDataName { get; set; }

        public PurchaseOrder Header { get; set; }
        public PRItemAdoptResultViewModel ItemList { get; set; }
        public IList<Attachment> AttachmentList { get; set; }
        public IList<Attachment> QuotationList { get; set; }
        public GenericViewModel<POApprovalInfoViewModel> ApprovalList { get; set; }
        public GenericViewModel<PurchaseOrderApprovalHistory> ApprovalHistory { get; set; }
    }
}