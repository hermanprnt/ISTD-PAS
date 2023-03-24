using System;
using GPS.CommonFunc;

namespace GPS.ViewModels.Master
{
    public class ReceivingListSearchViewModel : SearchViewModel
    {
        public String ReceivingNo { get; set; }
        public DateTime? ReceivingDateFrom { get; set; }
        public String ReceivingDateFromString
        {
            get { return ReceivingDateFrom.AsDateString(); }
            set { ReceivingDateFrom = value.FromDateString(); }
        }
        public DateTime? ReceivingDateTo { get; set; }
        public String ReceivingDateToString
        {
            get { return ReceivingDateTo.AsDateString(); }
            set { ReceivingDateTo = value.FromDateString(); }
        }
        public String PONo { get; set; }
        public String Vendor { get; set; }
        public String Status { get; set; }
        public String User { get; set; }
        public String HeaderText { get; set; }
        public String SAPDocNo { get; set; }
    }
}