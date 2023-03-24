using System;

namespace GPS.Models.Master
{
    public class Material
    {
        public Int32 DataNo { get; set; }
        public String ProcessId { get; set; }
        public Int32 SeqNo { get; set; }
        public String Class { get; set; }
        public String MaterialNo { get; set; }
        public String MaterialDesc { get; set; }
        public String MaterialTypeCode { get; set; }
        public String MaterialGroupCode { get; set; }
        public String UOM { get; set; }
        public String ValuationClass { get; set; }
        public String ValuationClassDesc { get; set; }
        public String MRPType { get; set; }
        public String CarFamilyCode { get; set; }
        public String ConsignmentCode { get; set; }
        public String ProcUsageCode { get; set; }
        public Decimal ReOrderValue { get; set; }
        public String ReOrderMethod { get; set; }
        public Int16 StandardDelivTime { get; set; }
        public Decimal AvgDailyConsump { get; set; }
        public Decimal MinStock { get; set; }
        public Decimal MaxStock { get; set; }
        public Decimal PcsPerKanban { get; set; }
        public String MatlGroup { get; set; }
        public Decimal Price { get; set; }
        public String MRPFlag { get; set; }
        public String StockFlag { get; set; }
        public String AssetFlag { get; set; }
        public String QuotaFlag { get; set; }
        public String DeletionFlag { get; set; }
        public String CreatedBy { get; set; }
        public DateTime CreatedDate { get; set; }
        public String ChangedBy { get; set; }
        public DateTime ChangedDate { get; set; }
    }

    public class MaterialValidate
    {
        //public int DataNo { get; set; }
        public string PROCESS_CD { get; set; }
        public string RESULT_MESSAGE { get; set; }
        public string MAT_NO { get; set; }
        public string MAT_DESC { get; set; }
        public string UOM { get; set; }
        public string CAR_FAMILY_CD { get; set; }
        public string CAR_FAMILY_NAME { get; set; }
        public string MAT_TYPE_CD { get; set; }
        public string MAT_TYPE_NAME { get; set; }
        public string MAT_GRP_CD { get; set; }
        public string MAT_GRP_DESC { get; set; }
        public string MRP_TYPE { get; set; }
        public string RE_ORDER_VALUE { get; set; }
        public string RE_ORDER_METHOD { get; set; }
        public string STD_DELIVERY_TIME { get; set; }
        public string AVG_DAILY_CONSUMPTION { get; set; }
        public string MIN_STOCK { get; set; }
        public string MAX_STOCK { get; set; }
        public string PCS_PER_KANBAN { get; set; }
        public string MRP_FLAG { get; set; }
        public string VALUATION_CLASS { get; set; }
        public string STOCK_FLAG { get; set; }
        public string ASSET_FLAG { get; set; }
        public string QUOTA_FLAG { get; set; }
        public string CONSIGNMENT_CD { get; set; }
        public string PROC_USAGE_CD { get; set; }
        public string DELETION_FLAG { get; set; }
        public string CREATED_BY { get; set; }
        public string CREATED_DT { get; set; }
        public string CHANGED_BY { get; set; }
        public string CHANGED_DT { get; set; }
    }

    

}