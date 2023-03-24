namespace GPS.Models.Master
{
    public class BudgetControl
    {
        //header
        public int NUMBER { get; set; }
        public string WBS_NO { get; set; }
        public string WBS_DESCRIPTION { get; set; }
        public string ORIGINAL_WBS_NO { get; set; }
        public string WBS_YEAR { get; set; }
        public string CURR_CD { get; set; }
        public decimal INITIAL_RATE { get; set; }
        public double INITIAL_AMOUNT { get; set; }
        public double INITIAL_BUDGET { get; set; }
        public double ADJUSTED_BUDGET { get; set; }
        public double REMAINING_BUDGET_ACTUAL { get; set; }
        public double REMAINING_BUDGET_INITIAL_RATE { get; set; }
        public double BUDGET_CONSUME_GR_SA { get; set; }
        public double BUDGET_CONSUME_INITIAL_RATE { get; set; }
        public double BUDGET_COMMITMENT_PR_PO { get; set; }
        public double BUDGET_COMMITMENT_INITIAL_RATE { get; set; }
        public int DIV_CD { get; set; }
        public string DIV_NAME { get; set; }
        public string SHORT_NAME { get; set; }
        public string CREATED_BY { get; set; }
        public string CRATED_DT { get; set; }
        public string CHANGED_BY { get; set; }
        public string CHANGED_DT { get; set; }

        //detail
        public int SEQ_NO { get; set; }
        public string BUDGET_TRANSACTION_GROUP { get; set; }
        public string BUDGET_DOC_NO { get; set; }
        public string REFERENCE_DOC_NO { get; set; }
        public int PARENT_SEQ_NO { get; set; }
        public string MATERIAL_NO { get; set; }
        public string ITEM_DESCRIPTION { get; set; }
        //public string CURR_CD { get; set; }
        public decimal EXC_RATE_ACTUAL { get; set; }
        public double ACTUAL_AMOUNT { get; set; }
        public double TOTAL_AMOUNT { get; set; }
        public string ACTION_TYPE { get; set; }
        public string SIGN { get; set; }
        public string IS_SYNCH { get; set; }
        public string PO_NO { get; set; }//add by fid.ahmad 03-08-2022

        //for grid
        public double COMMITMENT { get; set; }
        public double REMAINING_COMMITMENT { get; set; }
        public double CONSUME { get; set; }
        public double REMAINING_CONSUME { get; set; }

        public string NON_SAP_FLAG { get; set; }

        public string WBS_TYPE { get; set; }        //added : 20190710 : isid.rgl
    }
}