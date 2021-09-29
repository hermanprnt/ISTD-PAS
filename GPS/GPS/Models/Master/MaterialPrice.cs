using System;

namespace GPS.Models.Master
{
    public class MaterialPrice
    {
        public Int32 DataNo { get; set; }
        public String MaterialNo { get; set; }
        public String MaterialDesc { get; set; }
        public String VendorCode { get; set; }
        public String VendorName { get; set; }
        public String WarpBuyerCode { get; set; }
        public String SourceType { get; set; }
        public String ProdPurpose { get; set; }
        public String PartColorSfx { get; set; }
        public String PackingType { get; set; }
        public String ValidDateFromStr { get; set; }
        public DateTime ValidDateFrom { get; set; }
        public DateTime ValidDateTo { get; set; }
        public String PriceStatus { get; set; }
        public DateTime ApprovedDate { get; set; }
        public String ApprovedStatus { get; set; }
        public String DeletionFlag { get; set; }
        public String PCNo { get; set; }
        public String SourceData { get; set; }
        public String DraftDf { get; set; }
        public String WarpReffNo { get; set; }
        public String CPPFlag { get; set; }
        public String CurrCode { get; set; }
        public Decimal Amount { get; set; }
        public DateTime SentPiecePODate { get; set; }
        public String DataSequence { get; set; }
        public String CreatedBy { get; set; }
        public DateTime CreatedDate { get; set; }
        public String ChangedBy { get; set; }
        public DateTime ChangedDate { get; set; }
    }
}