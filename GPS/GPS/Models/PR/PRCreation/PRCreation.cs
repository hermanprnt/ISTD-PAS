using System;

namespace GPS.Models.PR.PRCreation
{
    public class PRCreation
    {
        //HEADER
        public string PR_TYPE { get; set; }
        public string PR_DESC { get; set; }
        public string PR_COORDINATOR { get; set; }
        public string PR_NO { get; set; }
        public string PROJECT_NO { get; set; }
        public string EXPLANATION { get; set; }
        public string DELIVERY_DATE { get; set; } //delivery date with specified format for screen
        public string MAIN_ASSET_NO { get; set; }
        public string PR_NOTES { get; set; }
        public string PR_STATUS { get; set; }

        public string PLANT_CD { get; set; }
        public string PLANT_NAME { get; set; }

        public string SLOC_CD { get; set; }
        public string SLOC_NAME { get; set; }

        public string DIVISION_ID { get; set; }
        public string DIVISION_NAME { get; set; }

        public string QUOTATION { get; set; }

        public string FILE_PATH { get; set; }
        public string FILE_EXTENSION { get; set; }
        public string FILE_NAME_ORI { get; set; }
        public int FILE_SEQ_NO { get; set; }
        public string DOC_TYPE { get; set; }
        public Int64 FILE_SIZE { get; set; }

        public string LIMIT { get; set; }
        public int NUMBER_OF_SUCCESS { get; set; }

        #region PR ITEM
        /** PR ITEM **/
        public string ITEM_NO { get; set; }
        public string IS_PARENT { get; set; }
        public double QTY { get; set; }
        public double USED_QTY { get; set; }
        public double OPEN_QTY { get; set; }
        public string CURR { get; set; }
        public double PRICE { get; set; }
        public double AMOUNT { get; set; }
        public double EXCHANGE_RATE { get; set; }
        public string DELIVERY_DATE_ITEM { get; set; } //delivery date with specified format for screen
        public string NEW_FLAG { get; set; }

        /** VALUATION CLASS **/
        public string VALUATION_CLASS_DESC { get; set; }
        public string VALUATION_CLASS { get; set; }
        public string VALUATION_CLASS_PARAM { get; set; }
        public string AREA_DESC { get; set; }
        public string ITEM_CLASS { get; set; }
        public string ITEM_CLASS_DESC { get; set; }
        public string ITEM_TYPE { get; set; }

        /** WBS **/
        public string WBS_NO { get; set; }
        public string WBS_NAME { get; set; }
        public string WBS_PARAM { get; set; }

        /** GL ACCOUNT **/
        public string GL_ACCOUNT_CD { get; set; }
        public string GL_ACCOUNT_DESC { get; set; }
        public string GL_ACCOUNT_PARAM { get; set; }

        /** COST CENTER **/
        public string COST_CENTER { get; set; }
        public string COST_CENTER_DESC { get; set; }

        /** MATERIAL **/
        public string MAT_NUMBER { get; set; }
        public string MAT_DESC { get; set; }
        public string MAT_NUMBER_PARAM { get; set; }
        public string CAR_FAMILY_CD { get; set; }
        public string CAR_FAMILY_DESC { get; set; }
        public string MAT_TYPE_CD { get; set; }
        public string MAT_TYPE_DESC { get; set; }
        public string MAT_GRP_CD { get; set; }
        public string MAT_GRP_DESC { get; set; }
        public string QUOTA_FLAG { get; set; }

        /** VENDOR **/
        public string VENDOR_CD { get; set; }
        public string VENDOR_NAME { get; set; }
        public string VENDOR_PARAM { get; set; }
        public string ASSETNO_PARAM { get; set; }
        public string DIVISION_PARAM { get; set; }

        /** ASSET **/
        public string ASSET_CATEGORY_CD { get; set; }
        public string ASSET_CATEGORY_DESC { get; set; }
        public string ASSET_CLASS { get; set; }
        public string ASSET_CLASS_DESC { get; set; }
        public string ASSET_LOCATION { get; set; }
        public string ASSET_NO { get; set; }
        public string SUB_ASSET_NO { get; set; }
        public string ASSET_CATEGORY { get; set; }
        public string CLASS_ID { get; set; }
        public string ASSET_DESC { get; set; }
        public string DIVISION_ID_HR { get; set; }
        

        /** UOM **/
        public string UOM_DESC { get; set; }
        public string UOM { get; set; }
#endregion

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
        public double PRICE_PER_UOM { get; set; }

        public int SUBITEM_COUNT { get; set; }

        //LOGGING
        public string MESSAGE_ID { get; set; }
        public string MESSAGE_CONTENT { get; set; }
        public string LOCATION { get; set; }
        public string PROCESS_STATUS { get; set; }
        public string PROCESS_ID { get; set; }
        public string MESSAGE { get; set; }
        public string STATUS_CD { get; set; }
        public string STATUS_DESC { get; set; }

        public int POSITION_LEVEL { get; set; }
        public int ORG_ID { get; set; }
        
        public string CREATED_BY { get; set; }
        public string CREATED_DT { get; set; }
        public string CREATED_DATE { get; set; }


        public string CHANGED_BY { get; set; }
        public string CHANGED_DT { get; set; }

        public string IS_UNDER_BUDGET { get; set; }
        public string ERROR_FLAG { get; set; }
        public string ERROR_MESSAGE { get; set; }

        public double NEW_AMOUNT { get; set; }
        public double PREV_AMOUNT { get; set; }

        public string URGENT_DOC { get; set; }
        public string DOC_YEAR { get; set; }
        public string SYSTEM_ID { get; set; }
        public bool IS_RELEASED { get; set; }
        public bool IS_COMMITED { get; set; }
        public string AMOUNT_IS_CHANGED { get; set; }
        public string WBS_IS_CHANGED { get; set; }
        public double DIFF_AMOUNT { get; set; }

        public string CALC_VALUE { get; set; }

        public string PRICE_EXIST { get; set; }
        public string LOCKED_BY { get; set; }

        public string PARENT_LOC_ID { get; set; }
        public string LOCATION_ID { get; set; }
        public string LOCATION_NAME { get; set; }
       
    }
}