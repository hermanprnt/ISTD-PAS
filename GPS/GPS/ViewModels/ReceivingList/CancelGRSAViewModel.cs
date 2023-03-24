using System;
using GPS.CommonFunc;

namespace GPS.ViewModels.ReceivingList
{
    public class CancelGRSAViewModel
    {
        public String CurrentUser { get; set; }
        public String CurrentRegNo { get; set; }
        public String ProcessId { get; set; }
        public String ModuleId { get; set; }
        public String FunctionId { get; set; }
        public String MatDoc { get; set; }
        public DateTime? CancelDate { get; set; }
        public String CancelDateString
        {
            get { return CancelDate.AsDateString(); }
            set { CancelDate = value.FromDateString(); }
        }
        public String CancelReason { get; set; }
    }
}