using System;

namespace GPS.Constants
{
    public sealed class FunctionId
    {
        public const String Material = "101001";
        public const String MaterialClass = "101002";
        public const String Vendor = "102001";
        public const String VendorUploadData = "102002";
        public const String Plant = "103001";
        public const String Sloc = "104001";
        public const String MaterialPrice = "105001";
        public const String CostCenterGroupUploadData = "105002";
        public const String SourceList = "106001";
        public const String CostCenter = "107001";
        public const String CostCenterGroup = "107002";
        public const String PurchasingGroup = "108001";
        public const String ExchangeRate = "109001";
        public const String ValuationClass = "110001";
        public const String Quota = "111001";
        public const String QuotaUploadData = "111002";
        public const String POCalculationSchema = "112001";
        public const String ComponentPrice = "113001";
        public const String ComponentPriceRate = "114001";
        public const String PRCreationValidationProcess = "201001";
        public const String PRInquiry = "202001";
        public const String PRApproval = "203001";
        public const String PRQuotaTransaction = "204001";
        public const String POCreation = "301001";
        public const String POInquiry = "302001";
        public const String POApproval = "303001";
        public const String POFormCreation = "304001";
        public const String GPPSRetrievalGPPSInterface = "401001";
        public const String EngineProdPlanDataRetrievalNESInterface = "402001";
        public const String PackingProdPlanRetrievalROEMInterface = "403001";
        public const String MRPExecution = "404001";
        public const String MRPProcessNQCCalculation = "405001";
        public const String MRPUpload = "406001";
        public const String MRPConfirmation = "407001";
        public const String ParentMaster = "408001";
        public const String ProcurementUsageMaster = "409001";
        public const String GentaniTypeMaster = "410001";
        public const String GentaniHeaderMaster = "411001";
        public const String ParentGentaniHeaderHikiateMaster = "412001";
        public const String GentaniHeaderMaterialHikiateMaster = "413001";
        public const String GRInput = "501001";
        public const String SAInput = "501002";
        public const String ReceivingList = "501003";

        // NOTE: Special function id used in TB_M_SYSTEM
        public const String PriceStatus = "PRI01";
        public const String PriceType = "PRI02";
        public const String TemplatePrice = "PRI03";
    }
}