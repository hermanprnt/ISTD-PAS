using System;
using GPS.CommonFunc;

namespace GPS.ViewModels.PO
{
    public class POSPKViewModel
    {
        public Boolean IsSPKCreated { get; set; }
        public String SPKNo { get; set; }
        public String BiddingDateString
        {
            get { return BiddingDate.AsDateString(); }
            set { BiddingDate = value.FromDateString(); }
        }
        public DateTime? BiddingDate { get; set; }
        public String Work { get; set; }
        public String Opening { get; set; }
        public Decimal Amount { get; set; }
        public String Location { get; set; }
        public String VendorCode { get; set; }
        public String VendorName { get; set; }
        public String VendorAddress { get; set; }
        public String VendorPostal { get; set; }
        public String VendorCity { get; set; }
        public String PeriodStartString
        {
            get { return PeriodStart.AsDateString(); }
            set { PeriodStart = value.FromDateString(); }
        }
        public DateTime? PeriodStart { get; set; }
        public String PeriodEndString
        {
            get { return PeriodEnd.AsDateString(); }
            set { PeriodEnd = value.FromDateString(); }
        }
        public DateTime? PeriodEnd { get; set; }
        public Int32 Retention { get; set; }
        public String TerminI { get; set; }
        public String TerminIDesc { get; set; }
        public String TerminII { get; set; }
        public String TerminIIDesc { get; set; }
        public String TerminIII { get; set; }
        public String TerminIIIDesc { get; set; }
        public String TerminIV { get; set; }
        public String TerminIVDesc { get; set; }
        public String TerminV { get; set; }
        public String TerminVDesc { get; set; }
    }
}