using System;

namespace GPS.Models.PR.PRInquiry
{
    public class PRInquiry
    {
        /*
         *
         * 
        */
        public string DOC_NO { get; set; }
        public string ORDER_BY { get; set; }

        public string PR_NO { get; set; }
        
        public string PLANT_CD { get; set; }
        public string SLOC_CD { get; set; }
        public string DIVISION_ID { get; set; }
        public string PROJECT_NO { get; set; }
        public string CREATED_BY { get; set; }
        
        public string PR_STATUS { get; set; }
        public string PR_STATUS_DESC { get; set; }
        public string PR_DESC { get; set; }
        public string PR_DETAIL_STS { get; set; }
        public string PR_COORDINATOR { get; set; }
        public string PR_COORDINATOR_DESC { get; set; }
        public string DOC_DATE_FROM_STRING { get; set; }
        public string DOC_DATE_TO_STRING { get; set; }

        public string WBS_NAME { get; set; }
        
        public string PLANT_NAME { get; set; }
        public string SLOC_NAME { get; set; }
        public string DIVISION_NAME { get; set; }

        public string STATUS_CD { get; set; }
        public string STATUS_DESC { get; set; }

        public string PROCESS_ID { get; set; }
        
        
        public string EXPLANATION { get; set; }
        public string PROCESS_STATUS { get; set; }
        public string MESSAGE { get; set; }
        public string DOC_DT { get; set; }
        public string PR_TYPE { get; set; }
        public string PR_TYPE_CD { get; set; }

        public DateTime? CREATED_DATE_TO { get; set; }
        public DateTime? CREATED_DATE_FROM { get; set; }

        public string DELIVERY_DATE { get; set; }

        public string ITEM_CAT { get; set; }

        public string CAR_FAMILY_CD { get; set; }
        public string CAR_FAMILY_DECS { get; set; }

        public string MAT_TYPE_CD { get; set; }
        public string MAT_TYPE_DESC { get; set; }

        public string MAT_GRP_CD { get; set; }
        public string MAT_GRP_DESC { get; set; }

        public string UOM_DESC { get; set; }
        public string UOM { get; set; }

        public string FILE_PATH { get; set; }
        public string FILE_EXTENSION { get; set; }
        public string FILE_NAME_ORI { get; set; }
        public int FILE_SEQ_NO { get; set; }
        public string DOC_TYPE { get; set; }

        public string NEW_FLAG { get; set; }
        public string LIMIT { get; set; }

        public string CREATED_DT { get; set; }

        public string CHANGED_BY { get; set; }
        public string CHANGED_DT { get; set; }

        public string IS_UNDER_BUDGET { get; set; }
        public string ERROR_FLAG { get; set; }
        public string ERROR_MESSAGE { get; set; }

        public decimal NEW_AMOUNT { get; set; }
        public decimal PREV_AMOUNT { get; set; }

        public int POSITION_LEVEL { get; set; }
        public int ORG_ID { get; set; }

        public Int32 NUMBER { get; set; }
        public String LOCKED_BY { get; set; }

        /** PR H **/
        public String URGENT_DOC { get; set; }
        public String MAIN_ASSET_NO { get; set; }
        public String PR_NOTES { get; set; }

        /** PR ITEM **/
        public string ITEM_NO { get; set; }
        public string ITEM_CLASS { get; set; }
        public string SEQ_NO { get; set; }
        public string IS_PARENT { get; set; }
        public double QTY { get; set; }
        public double OPEN_QTY { get; set; }
        public double USED_QTY { get; set; }
        public string CURR { get; set; }
        public double PRICE { get; set; }
        public double AMOUNT { get; set; }
        public double EXCHANGE_RATE { get; set; }
        public double LOCAL_AMOUNT { get; set; }
        public string DELIVERY_DATE_ITEM { get; set; } //delivery date with specified format for screen
        public string CURRENT_PIC { get; set; }
        public double CANCEL_QTY { get; set; } //20191023

        /** VALUATION CLASS **/
        public string VALUATION_CLASS_DESC { get; set; }
        public string VALUATION_CLASS { get; set; }
        public string PURCHASING_GROUP_CD { get; set; }

        /** WBS **/
        public string WBS_NO { get; set; }

        /** COST CENTER **/
        public string COST_CENTER { get; set; }
        public string COST_CENTER_DESC { get; set; }

        /** GL ACCOUNT **/
        public string GL_ACCOUNT_CD { get; set; }
        public string GL_ACCOUNT_DESC { get; set; }

        /** MATERIAL **/
        public string MAT_NUMBER { get; set; }
        public string MAT_DESC { get; set; }

        /** ASSET **/
        public string ASSET_CATEGORY_CD { get; set; }
        public string ASSET_CATEGORY_DESC { get; set; }
        public string ASSET_CLASS { get; set; }
        public string ASSET_CLASS_DESC { get; set; }
        public string ASSET_LOCATION { get; set; }
        public string ASSET_NO { get; set; }

        /** VENDOR **/
        public string VENDOR_CD { get; set; }
        public string VENDOR_NAME { get; set; }

        //SUB ITEM
        public string SUBITEM_WBS_NO { get; set; }
        public string SUBITEM_COST_CENTER { get; set; }
        public string SUBITEM_COST_CENTER_DESC { get; set; }
        public string SUBITEM_GL_ACCOUNT { get; set; }
        public string SUBITEM_GL_ACCOUNT_DESC { get; set; }
        public string SUBITEM_MAT_DESC { get; set; }
        public string SUBITEM_NO { get; set; }
        public double SUBITEM_QTY { get; set; }
        public string SUBITEM_UOM { get; set; }
        public double SUBITEM_AMOUNT { get; set; }
        public double SUBITEM_LOCAL_AMOUNT { get; set; }
        public double PRICE_PER_UOM { get; set; }

        public int NUMBER_OF_SUCCESS { get; set; }
        public string PO_NO { get; set; }
        public string CANCEL_BY { get; set; }
        public string CANCEL_DT { get; set; }
        public string CANCEL_REASON { get; set; }

        //notice
        public string DOCTYPE { get; set; }

        public string PROCUREMENT_CHANNEL { get; set; }
    }
}