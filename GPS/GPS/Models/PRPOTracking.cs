using System;

namespace GPS.Models.Common
{
    public class PRPOTrackingParam
    {
        public String DOC_TYPE { get; set; }
        public String DOC_STATUS { get; set; }
        public String DOC_DATE_FROM { get; set; }
        public String DOC_DATE_TO { get; set; }
        public String DOC_DESC { get; set; }
        public String DOC_NO { get; set; }
        public String DOC_ITEM_NO { get; set; }
        public String REGISTERED_BY { get; set; }
    }

    public class PRPOTrackingList
    {
        public String IS_HAVE_CHILD { get; set; }

        public String REFERENCE_DOC_NO { get; set; }
        public String DOC_NO { get; set; }
        public String DOC_ITEM_NO { get; set; }
        public String DOC_TYPE { get; set; }
        public String DOC_DESC { get; set; }
        public String DOC_DATE { get; set; }
        public String DOC_STATUS { get; set; }
        public String REGISTERED_BY { get; set; }
        public String REGISTERED_DT { get; set; }
        public String ORG_SH_BY { get; set; }
        public String ORG_SH_DT { get; set; }
        public String ORG_DPH_BY { get; set; }
        public String ORG_DPH_DT { get; set; }
        public String ORG_DH_BY { get; set; }
        public String ORG_DH_DT { get; set; }
        public String COOR_STAFF_BY { get; set; }
        public String COOR_STAFF_DT { get; set; }
        public String COOR_SH_BY { get; set; }
        public String COOR_SH_DT { get; set; }
        public String COOR_DPH_BY { get; set; }
        public String COOR_DPH_DT { get; set; }
        public String COOR_DH_BY { get; set; }
        public String COOR_DH_DT { get; set; }
        public String FD_STAFF_BY { get; set; }
        public String FD_STAFF_DT { get; set; }
        public String FD_SH_BY { get; set; }
        public String FD_SH_DT { get; set; }
    }
}