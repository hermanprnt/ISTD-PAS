using System;

namespace GPS.ViewModels.PO
{
    public class POApprovalInfoViewModel
    {
        public String DocNo { get; set; }
        public String Creator { get; set; }
        public String Created { get; set; }

        public String SHApprover { get; set; }
        public String SHPlan { get; set; }
        public String SHActual { get; set; }
        public String SHPlanLitime { get; set; }
        public String SHActualLitime { get; set; }

        public String DpHApprover { get; set; }
        public String DpHPlan { get; set; }
        public String DpHActual { get; set; }
        public String DpHPlanLitime { get; set; }
        public String DpHActualLitime { get; set; }

        public String DHApprover { get; set; }
        public String DHPlan { get; set; }
        public String DHActual { get; set; }
        public String DHPlanLitime { get; set; }
        public String DHActualLitime { get; set; }

        public Boolean IsActualSHLate { get; set; }
        public Boolean IsActualDpHLate { get; set; }
        public Boolean IsActualDHLate { get; set; }
    }

    public class PurchaseOrderApprovalHistory
    {
        public string ITEM_NO { get; set; }
        public string LAST_STATUS { get; set; }
        public string LAST_APPROVED_BY { get; set; }
        public string LAST_APPROVED_DT { get; set; }
    }
}