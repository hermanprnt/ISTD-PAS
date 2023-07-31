using System;

namespace GPS.Constants.Master
{
    public class MasterSqlFiles
    {
        public const String _Root_Folder = "Master/";
        public const String _Root_Folder_ValuationClass = _Root_Folder + "ValuationClass/";
        public const String _Root_Folder_CalculationMapping = _Root_Folder + "CalculationMapping/";

        #region VALUATION CLASS SQL
        public const String GetPRType = _Root_Folder + "get_procurementtype";
        public const String GetItemClass = _Root_Folder + "get_ItemClass";
        public const String GetPRCoordinator = _Root_Folder + "get_PRCoordinator";
        public const String GetCoordinatorList = _Root_Folder + "get_CoordinatorList";
        public const String GetMatGroup = _Root_Folder + "get_MatGroup";
        public const String GetFDCheck = _Root_Folder + "get_fdcheck";
        public const String GetPurchasingGroup = _Root_Folder + "get_purchasinggroup";
        public const String GetCalculationSchema = _Root_Folder + "get_calculationscheme";

        public const String GetValuationClassData = _Root_Folder_ValuationClass + "get_valuationclass";
        public const String ValuationDataCount = _Root_Folder_ValuationClass + "count_valuationclass";
        public const String GetValClassFreeParam = _Root_Folder_ValuationClass + "getValClass_freeParam";
        public const String CountValClassFreeParam = _Root_Folder_ValuationClass + "countValClass_freeParam";

        public const string GetSelectedValuationClass = _Root_Folder_ValuationClass + "getselected_valuationclass";
        public const string GetStatusValuationClass = _Root_Folder_ValuationClass + "getstatus_valuationclass";
        public const string ValuationClassValidation = _Root_Folder_ValuationClass + "valuationclass_validation";
        public const string ValuationClassSavingProcess = _Root_Folder_ValuationClass + "save_valuationclass";
        public const string ActiveInactiveValuationClass = _Root_Folder_ValuationClass + "activeinactive_valuationclass";
        #endregion

        #region CALCULATION SCHEME MAPPING SQL
        public const String GetCalculationMappingData = _Root_Folder_CalculationMapping + "get_calculationmapping";
        public const String CalculationMappingDataCount = _Root_Folder_CalculationMapping + "count_calculationmapping";
        public const String GetCalculationMappingDetail = _Root_Folder_CalculationMapping + "getdetail_calculationmapping";
        public const String GetSelectedCalculationMapping = _Root_Folder_CalculationMapping + "getselected_calculationmapping";
        public const String GetCompPrice = _Root_Folder + "get_compprice";
        public const String GetCalculationMappingTemp = _Root_Folder_CalculationMapping + "gettemp_calculationmapping";
        public const String GetProcessId = _Root_Folder + "get_processid";
        public const String DeleteCalculationMappingTemp = _Root_Folder_CalculationMapping + "delete_tempCMbyuserid";
        public const String DeleteSelectedCMTemp = _Root_Folder_CalculationMapping + "delete_tempCMbyselected";
        public const String SaveTempCalculationMapping = _Root_Folder_CalculationMapping + "savetemp_calculationMapping";
        public const String GetCalculationType = _Root_Folder + "get_calculationtype";
        public const String GetCalculationSchemaAdd = _Root_Folder_CalculationMapping + "getcalculation_schemeAdd";
        public const String CalculationMappingSavingProcess = _Root_Folder_CalculationMapping + "save_calculationmapping";
        public const String GetPlusMinusFlagAdd = _Root_Folder_CalculationMapping + "getplus_minusflag";
        #endregion
    }
}