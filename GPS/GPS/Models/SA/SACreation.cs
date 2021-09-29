using System;

namespace GPS.Models.MRP
{
    public class SACreation
    {
        public string PO_NO { get; set; }
        public Int32 NUMBER { get; set; }       
        public string PO_DESC { get; set; }
        public string VENDOR { get; set; }
        public string MONTH { get; set; }
        public string PO_AMOUNT { get; set; }
        public string PURCHASE_GROUP { get; set; }
        public string PO_CURR { get; set; }
        public string MAT_NO { get; set; }
        public string PO_ITEM_NO { get; set; }
        public string ITEM_NO { get; set; }
        public string UOM { get; set; }
        public string COMP_PRICE_CD { get; set; }
        public string COMP_PRICE_DESC { get; set; }
        public string COMP_PRICE_RATE { get; set; }
        public string DELIVERY_PLAN_DT { get; set; }
        public string MAT_DESC { get; set; }
        public float PO_QTY_ORI { get; set; }
        public float PO_QTY_USED { get; set; }
        public string PRICE_PER_UOM { get; set; }
        public string PRECENTAGE { get; set; }
        public string ORI_AMOUNT { get; set; }
        public float PO_QTY_REMAIN { get; set; }
        public string SLOC_NAME { get; set; }
        public string PLANT_NAME { get; set; }
        public string PO_SUBITEM_NO { get; set; }
        public string SUB_ITEM { get; set; }         
        public string CREATED_BY { get; set; }
        public string CREATED_DT { get; set; }
        public string CHANGED_BY { get; set; }
        public string CHANGED_DT { get; set; }
        public String DataName { get; set; }
    }
}