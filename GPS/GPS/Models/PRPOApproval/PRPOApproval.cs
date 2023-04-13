using System;
using GPS.CommonFunc;
using GPS.ViewModels;

namespace GPS.Models.PRPOApproval
{
    /// <summary>
    /// PRApproval view parameter model. 
    /// </summary>
    public class PRPOApprovalParam
    {
        public String ListDocNo { get; set; }
        public String DOC_NO { get; set; }
        public String DOC_TYPE { get; set; }
        public String DOC_DESC { get; set; }

        public String PLANT_CD { get; set; }
        public String SLOC_CD { get; set; }
        public String DIVISION_ID { get; set; }

        public String PR_COORDINATOR { get; set; }
        public String PURCHASING_GRP_CD { get; set; }

        public String VENDOR_CD { get; set; } // for PO or when approval
        public String CURRENCY { get; set; }

        public DateTime? DATE_FROM { get; set; }
        public DateTime? DATE_TO { get; set; }

        public String REG_NO { get; set; }
        public String USER_TYPE { get; set; }
        public String ORDER_BY { get; set; }
    }

    public class POApprovalParam : SearchViewModel
    {
        public String DocNo { get; set; }
        public String DocDesc { get; set; }
        public String Plant { get; set; }
        public String SLoc { get; set; }
        public String PurchasingGroup { get; set; }
        public String Status { get; set; }
        public String Vendor { get; set; }
        public String Currency { get; set; }
        public String CurrentUser { get; set; }
        public String CurrentUserRegNo { get; set; }
        public String UserType { get; set; }
        public String GovRelate { get; set; }

    }

    /// <summary>
    /// PRApproval view data model.
    /// </summary> 
    public class PRApproval
    {
        public Int64 NUMBER { get; set; }

        public String DOC_NO { get; set; }
        public String DOC_TYPE { get; set; }
        public String DOC_DESC { get; set; }
        public String PR_COORDINATOR { get; set; }

        public String CURR { get; set; }
        public Decimal AMOUNT { get; set; }

        public String STATUS_CD { get; set; }
        public String STATUS_DESC { get; set; }

        public String DIVISION_ID { get; set; }
        public String DIVISION_NAME { get; set; }

        public DateTime DOC_DT { get; set; }
        public String STR_DOC_DT { get; set; }
        public String URGENT_DOC { get; set; }

        public String PLANT_CD { get; set; }
        public String SLOC_CD { get; set; }

        public String CREATED_BY { get; set; }
        public String CREATED_DT { get; set; }
        public String CHANGED_BY { get; set; }
        public String CHANGED_DT { get; set; }
        
        public String REG_NO { get; set; }
        public String USER_TYPE { get; set; }

        public String DOC_ITEM_NO { get; set; }
        public String ITEM_DESC { get; set; }
        public Decimal QTY { get; set; }
        public Decimal PRICE_UOM { get; set; }
        public String ITEM_CLASS { get; set; }
        public String WBS_NO { get; set; }
        public String WBS_DESC { get; set; }
        public String GL_ACCOUNT { get; set; }
        public String ASSET_NO { get; set; }
        public String CREATED_NAME { get; set; }


    }

    /// <summary>
    /// PRApproval detail view data model.
    /// </summary> 
    public class PRApprovalDetail
    {
        public Int64 NUMBER { get; set; }

        public String DOC_NO { get; set; }
        public String DOC_TYPE { get; set; }
        public String ITEM_NO { get; set; }
        public String IS_PARENT { get; set; }
        public String ITEM_CLASS { get; set; }
        public String WBS_NO { get; set; }
        public String WBS_NAME { get; set; }
        public String COST_CENTER_CD { get; set; }
        public String VALUATION_CLASS { get; set; }
        public String VALUATION_CLASS_DESC { get; set; }
        public String GL_ACCOUNT { get; set; }
        public String MAT_NO { get; set; }
        public String MAT_DESC { get; set; }
        public Decimal QTY { get; set; }
        public String UOM { get; set; }
        public String CURR { get; set; }
        public Decimal PRICE { get; set; }
        public String AMOUNT { get; set; }
        public String DELIVERY_PLAN_DT { get; set; }
        public String ASSET_CATEGORY { get; set; }
        public String ASSET_CLASS { get; set; }
        public String ASSET_LOCATION { get; set; }
        public String ASSET_NO { get; set; }
        public String VENDOR_NAME { get; set; }
        public String STATUS_CD { get; set; }
        public String STATUS_DESC { get; set; }

        public String IS_REJECTED { get; set; }
    }

    /// <summary>
    /// PRApproval subitem view data model.
    /// </summary> 
    public class PRApprovalSubItem
    {
        public String SUBITEM_NO { get; set; }
        public String ITEM_NO { get; set; }
        public String MAT_DESC { get; set; }
        public String COST_CENTER { get; set; }
        public String COST_CENTER_DESC { get; set; }
        public String WBS_NO { get; set; }
        public String GL_ACCOUNT { get; set; }
        public String GL_ACCOUNT_DESC { get; set; }
        public Decimal QTY { get; set; }
        public String UOM { get; set; }
        public Decimal PRICE_PER_UOM { get; set; }
        public Decimal AMOUNT { get; set; }
    }

    /// <summary>
    /// POApproval view data model.
    /// </summary> 
    public class POApproval
    {
        public String GovRelate { get; set; }
        public Int32 DataNo { get; set; }
        public String DD_STATUS { get; set; }
        public String DocNo { get; set; }
        public String DocDesc { get; set; }
        public String Currency { get; set; }
        public Decimal Amount { get; set; }
        public Decimal ExchangeRate { get; set; }
        public String Vendor { get; set; }
        public String Status { get; set; }
        public String PurchasingGroup { get; set; }
        public DateTime DocDate { get; set; }
        public String DocDateString
        {
            get { return DocDate == DateTime.MinValue ? String.Empty : DocDate.ToStandardFormat(); }
            set { DocDate = String.IsNullOrEmpty(value) ? DateTime.MinValue : value.FromStandardFormat(); }
        }
        public Boolean IsHaveAttachment { get; set; }
        public String UrgentDoc { get; set; }
        public String CreatedBy { get; set; }
        public DateTime CreatedDate { get; set; }
        public String ChangedBy { get; set; }
        public DateTime ChangedDate { get; set; }

        public String UserType { get; set; }
        public String Division { get; set; }
        public String CurrentUser { get; set; }
        public String CurrentUserRegNo { get; set; }
    }

    /// <summary>
    /// POApproval detail view data model.
    /// </summary> 
    public class POApprovalDetail
    {
        public Int64 NUMBER { get; set; }

        public String DOC_NO { get; set; }
        public String DOC_ITEM_NO { get; set; }
        public String DOC_TYPE { get; set; }
        public String PR_NO { get; set; }
        public String ITEM_NO { get; set; }
        public String ITEM_CLASS { get; set; }
        public String IS_PARENT { get; set; }
        public String VALUATION_CLASS { get; set; }
        public String MAT_NO { get; set; }
        public String MAT_DESC { get; set; }
        public Decimal QTY { get; set; }
        public String UOM { get; set; }
        public String CURR { get; set; }
        public Decimal PRICE { get; set; }
        public String AMOUNT { get; set; }
        public String DELIVERY_PLAN_DT { get; set; }
        public String PLANT_CD { get; set; }
        public String SLOC_CD { get; set; }
        public String STATUS_CD { get; set; }
        public String STATUS_DESC { get; set; }
        public String WBS_NO { get; set; }
        public String COST_CENTER_CD { get; set; }
        public String GL_ACCOUNT { get; set; }
        public Boolean HAS_ITEM { get; set; }

        public String IS_REJECTED { get; set; }
    }

    /// <summary>
    /// POApproval subitem view data model.
    /// </summary> 
    public class POApprovalSubItem
    {
        public Int64 SUBITEM_NO { get; set; }
        public String ITEM_NO { get; set; }
        public String MAT_DESC { get; set; }
        public Decimal QTY { get; set; }
        public String UOM { get; set; }
        public Decimal PRICE_PER_UOM { get; set; }
        public Decimal AMOUNT { get; set; }
        public String WBS_NO { get; set; }
        public String COST_CENTER { get; set; }
        public String GL_ACCOUNT { get; set; }
    }

    /// <summary>
    /// POApprovalCondition view data model.
    /// </summary> 
    public class POApprovalCondition
    {
        public Int64 NUMBER { get; set; }

        public String DOC_NO { get; set; }
        public String DOC_ITEM_NO { get; set; }
        public String PR_NO { get; set; }
        public Int64 ITEM_NO { get; set; }
        public String MAT_NO { get; set; }
        public String MAT_DESC { get; set; }
        public String COMP_PRICE_CD { get; set; }
        public String COMP_PRICE_DESC { get; set; }
        public String CONDITION_TYPE { get; set; }
        public Decimal QTY { get; set; }
        public Decimal EXCHANGE_RATE { get; set; }
        public Decimal AMOUNT { get; set; }
        public String COMP_TYPE { get; set; }
    }

    /// <summary>
    /// PRApproval result view data model.
    /// </summary> 
    public class CommonApprovalResult
    {
        public string ACTION { get; set; }
        public Int64 DOC_COUNT { get; set; }
        public Int64 ITEM_COUNT { get; set; }
        public Int64 SUCCESS { get; set; }
        public Int64 FAIL { get; set; }
        public string MESSAGE { get; set; }
    }

    /// <summary>
    /// PRApproval delay view data model.
    /// </summary> 
    public class PRApprovalDelay
    {
        public String DOC_NO { get; set; }
        public String DOC_DESC { get; set; }
        public String DOC_TYPE { get; set; }
        public DateTime DOC_DT { get; set; }
        public String STR_DOC_DT { get; set; }
        public String DIVISION_NAME { get; set; }
        public String CURR { get; set; }
        public Decimal AMOUNT { get; set; }
        public String STATUS_DESC { get; set; }
        public String CREATED_BY { get; set; }
        public DateTime APPROVED_DT { get; set; }
        public Int32 DELAY { get; set; }
    }
}