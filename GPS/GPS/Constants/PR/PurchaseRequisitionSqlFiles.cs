using System;

namespace GPS.Constants.PR
{
    public class PurchaseRequisitionSqlFiles
    {
        public const String _Root_Folder_Common = "PR/Common/";
        public const String _Root_Folder_Creation = "PR/PRCreation/";
        public const String _Root_Folder_Inquiry = "PR/PRInquiry/";
        public const String _Root_Folder_Creation_DataList = _Root_Folder_Creation + "DataList/";

        #region COMMON SQL
        public const String GetWorkflowData = _Root_Folder_Common + "get_workFlow";
        public const String CountWorkflowData = _Root_Folder_Common + "count_workFlow";
        #endregion

        #region PRCREATION COMMON LIST
        public const String GetPRType = _Root_Folder_Creation_DataList + "get_prtype";
        public const String VendorList = _Root_Folder_Common + "get_vendorList";
        public const String DivisionList = _Root_Folder_Common + "call_getListDivision";
        public const String CostCenterList = _Root_Folder_Creation_DataList + "get_costcenterList";
        public const String CostCenterListByCoordinator = _Root_Folder_Creation_DataList + "get_costcenterListByCoordinator";
        public const String PRStatusList = _Root_Folder_Inquiry + "get_prstatusList";
        public const String AssetCatList = _Root_Folder_Creation_DataList + "get_assetCatList";
        public const String AssetClassList = _Root_Folder_Creation_DataList + "get_assetClassList";

        public const String HomeTrackingList = _Root_Folder_Common + "get_homeTracking";
        #endregion
    }
}