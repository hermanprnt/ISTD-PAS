using System;

namespace GPS.Constants.Master
{
    public class MasterControllerMethod
    {
        public const String _ValuationClassController = "~/ValuationClass/";
        public const String _CalculationMappingController = "~/CalculationMapping/";

        #region VALUATION CLASS
        public const String _SearchValuationClass = _ValuationClassController + "SearchData";
        public const String _GetSelectedVCData = _ValuationClassController + "GetSelectedData";
        public const String _GetSingleVCData = _ValuationClassController + "GetSingleData";
        public const string _SaveValuationClass = _ValuationClassController + "SaveData";
        public const string _ActiveInactiveValuationClass = _ValuationClassController + "ActiveInactive";
        #endregion

        #region CALCULATION MAPPING
        public const String _SearchCalculationMapping = _CalculationMappingController + "SearchData";
        public const String _SearchDetailCalculationMapping = _CalculationMappingController + "SearchDetail";
        public const String _GetSelectedCMData = _CalculationMappingController + "GetSelectedData";
        public const String _DeleteCalculationMappingTemp = _CalculationMappingController + "DeleteSelectedTemp";
        public const String _GetDetailPopup = _CalculationMappingController + "GetDetailPopup";
        public const String _SaveDetailCalculationMapping = _CalculationMappingController + "SaveDetail";
        public const String _SaveCalculationMapping = _CalculationMappingController + "SaveData";
        #endregion
    }
}