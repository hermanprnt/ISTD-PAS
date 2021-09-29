using System;

namespace GPS.Models.Master
{
    public class Routine
    {
        /** HEADER **/
        public String ROUTINE_NO { get; set; }
        public String PR_DESC { get; set; }
        public String PLANT_CD { get; set; }
        public String SLOC_CD { get; set; }
        public String PR_COORDINATOR { get; set; }
        public String SCH_TYPE { get; set; }
        public String SCH_TYPE_DESC { get; set; }
        public String SCH_VALUE { get; set; }
        public String ACTIVE_FLAG { get; set; }
        public String VALID_FROM { get; set; }
        public String VALID_TO { get; set; }

        public String PERSONNEL_NAME { get; set; }
        public String NO_REG { get; set; }
        public String ORG_ID { get; set; }
        public String POSITION_LEVEL { get; set; }
        public int DIVISION_ID { get; set; }
        public String DIVISION_NAME { get; set; }
        public String DIVISION_PIC { get; set; }
        public Int64 PROCESS_ID { get; set; }
        public string SCH_MONTH { get; set; }
        public string SCH_DAY { get; set; }
        
        /** ITEM **/
        public string IS_PARENT { get; set; }
        public string ITEM_NO { get; set; }
        public double AMOUNT { get; set; }
        public double QTY { get; set; }
        
        /** PARAM GRID LOOKUP **/
        public String PIC_PARAM { get; set; }
        public String WBS_PARAM { get; set; }
        public String VALUATION_CLASS_PARAM { get; set; }
        public string GL_ACCOUNT_PARAM { get; set; }
        public string MAT_NUMBER_PARAM { get; set; }
        public string VENDOR_PARAM { get; set; }

        /** VALUATION CLASS **/
        public string VALUATION_CLASS_DESC { get; set; }
        public string VALUATION_CLASS { get; set; }
        public string ITEM_CLASS { get; set; }
        public string ITEM_CLASS_DESC { get; set; }
        public string ITEM_TYPE { get; set; }

        /** WBS **/
        public string WBS_NO { get; set; }
        public string WBS_NAME { get; set; }

        /** GL ACCOUNT **/
        public string GL_ACCOUNT_CD { get; set; }
        public string GL_ACCOUNT_DESC { get; set; }

        /** MATERIAL **/
        public string MAT_NUMBER { get; set; }
        public string MAT_DESC { get; set; }
        public string CAR_FAMILY_CD { get; set; }
        public string CAR_FAMILY_DESC { get; set; }
        public string MAT_TYPE_CD { get; set; }
        public string MAT_TYPE_DESC { get; set; }
        public string MAT_GRP_CD { get; set; }
        public string MAT_GRP_DESC { get; set; }
        public string QUOTA_FLAG { get; set; }
        public string UOM { get; set; }
        public string UOM_DESC { get; set; }
        public string CURR { get; set; }
        public double PRICE { get; set; }
        public string CALC_VALUE { get; set; }

        /** COST CENTER **/
        public string COST_CENTER { get; set; }
        public string COST_CENTER_DESC { get; set; }

        /** VENDOR **/
        public string VENDOR_CD { get; set; }
        public string VENDOR_NAME { get; set; }

        /** SUB ITEM **/
        public string SUBITEM_NO { get; set; }
        public string SUBITEM_WBS_NO { get; set; }
        public string SUBITEM_COST_CENTER { get; set; }
        public string SUBITEM_COST_CENTER_DESC { get; set; }
        public string SUBITEM_GL_ACCOUNT { get; set; }
        public string SUBITEM_GL_ACCOUNT_DESC { get; set; }
        public string SUBITEM_MAT_DESC { get; set; }
        public double SUBITEM_QTY { get; set; }
        public string SUBITEM_UOM { get; set; }
        public double SUBITEM_AMOUNT { get; set; }
        public double PRICE_PER_UOM { get; set; }

        /** LOG **/
        public string MESSAGE { get; set; }
        public string PROCESS_STATUS { get; set; }
        public string MESSAGE_CONTENT { get; set; }
        public string MESSAGE_ID { get; set; }
        public string LOCATION { get; set; }

        /** Additional from Inquiry **/
        public int NUMBER { get; set; }
        public string CREATED_BY { get; set; }
        public string CHANGED_BY { get; set; }
        public string CREATED_DT { get; set; }
        public string CHANGED_DT { get; set; }
    }
}