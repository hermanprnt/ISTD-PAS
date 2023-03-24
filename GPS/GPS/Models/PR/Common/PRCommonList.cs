namespace GPS.Models.PR.Common
{
    public class PRCommonList
    {
        public string WBS_NO { get; set; }
        public string WBS_NAME { get; set; }

        public string DIVISION_ID { get; set; }

        public string STATUS_CD { get; set; }
        public string STATUS_DESC { get; set; }

        public string COST_CENTER { get; set; }
        public string COST_CENTER_DESC { get; set; }

        public string SYSTEM_VALUE { get; set; }
        public string SYSTEM_CD { get; set; }

        public string PROCUREMENT_TYPE { get; set; }
        public string PROCUREMENT_DESC { get; set; }
        public string NON_MATERIAL_FLAG { get; set; }
        public string DEFAULT_FLAG { get; set; }

        public string ASSET_CATEGORY_CD { get; set; }
        public string ASSET_CATEGORY_DESC { get; set; }

        public string ASSET_CLASS { get; set; }
        public string ASSET_CLASS_DESC { get; set; }

        public string PR_NO { get; set; }
        public string ITEM_NO { get; set; }
        public string PURCHASING_GROUP_CD { get; set; }
        public string ITEM_DESCRIPTION { get; set; }
    }
}