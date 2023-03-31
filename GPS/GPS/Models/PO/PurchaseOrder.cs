using System;
using GPS.ViewModels.PO;
using System.Collections.Generic;
using GPS.Models.Common;

namespace GPS.Models.PO
{
    public class PurchaseOrder
    {
        public String CurrentUserNoReg { get; set; }
        public String ProcessId { get; set; }
        public Int32 DataNo { get; set; }
        public String PONo { get; set; }
        public Boolean IsOneTimeVendor { get; set; }
        public String Vendor
        {
            get { return VendorCode + (String.IsNullOrEmpty(VendorName) ? String.Empty : " - " + VendorName); }
        }
        public String DD_STATUS { get; set; }
        public String VendorCode { get; set; }
        public String VendorName { get; set; }
        public String VendorAddress { get; set; }
        public String VendorCountry { get; set; }
        public String VendorCity { get; set; }
        public String VendorPostalCode { get; set; }
        public String VendorPhone { get; set; }
        public String VendorFax { get; set; }
        public String PurchasingGroup { get; set; }
        public String Currency { get; set; }
        public Decimal ExchangeRate { get; set; }
        public Decimal Amount { get; set; }
        public DateTime PODate { get; set; }
        public String POHeaderText { get; set; }
        public String POStatusCode { get; set; }
        public String POStatus { get; set; }
        public String DownloadedBy { get; set; }
        public DateTime DownloadedDate { get; set; }
        public String CreatedBy { get; set; }
        public DateTime CreatedDate { get; set; }
        public String ChangedBy { get; set; }
        public DateTime ChangedDate { get; set; }
        public String BidFilePath { get; set; }
        public String BidOriFilePath { get; set; }
        public String QuotFilePath { get; set; }
        public String QuotOriFilePath { get; set; }
        public String LockedBy { get; set; }
        public Boolean HasSPK { get; set; }
        public Boolean IsFromGPS { get; set; }
        public Boolean IsFromECatalogue { get; set; }
        public String SAPPONo { get; set; }
        public POSPKViewModel SPKInfo { get; set; }
        public Boolean IsHaveAttachment { get; set; }

        public String DOC_NO { get; set; }//20191008
        public String PO_POSTING_ERR { get; set; }//20200129
        public String ERROR_MESSAGE { get; set; } //20200129

        //For PO Letter
        public String Note1 { get; set; }
        public String Note2 { get; set; }
        public String Note3 { get; set; }
        public String Note4 { get; set; }
        public String Note5 { get; set; }
        public String Note6 { get; set; }
        public String Note7 { get; set; }
        public String Note8 { get; set; }
        public String Note9 { get; set; }
        public String Note10 { get; set; }

        //Other Email Notification
        public String OtherMail { get; set; }

        public List<Attachment> BidFileList { get; set; }
        public List<Attachment> QuotFileList { get; set; }

        public String CancelBy { get; set; }
        public DateTime CancelDate { get; set; }
        public string CancelReason { get; set; }
		

        //start : 20190715 : isid.rgl
        public String FlagAttachment { get; set; }
        //end : 20190715 : isid.rgl
    }
}