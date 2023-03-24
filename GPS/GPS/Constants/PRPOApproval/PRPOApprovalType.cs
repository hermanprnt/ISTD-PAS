using System;

namespace GPS.Constants.PRPOApproval
{
    public sealed class PRPOApprovalType
    {
        public readonly String Name;
        public readonly PRApprovalTypeEnum Value;

        public static readonly PRPOApprovalType PR = new PRPOApprovalType(PRApprovalTypeEnum.PR, "Purchase Req.");
        public static readonly PRPOApprovalType PO = new PRPOApprovalType(PRApprovalTypeEnum.PO, "Purchase Order");

        private PRPOApprovalType(PRApprovalTypeEnum value, String name)
        {
            this.Name = name;
            this.Value = value;
        }

        public override String ToString()
        {
            return Name;
        }
    }

    public enum PRApprovalTypeEnum
    {
        PR,
        PO,
    }

    public sealed class PRApprovalUserType
    {
        public readonly String Name;
        public readonly PRApprovalUserTypeEnum Value;

        public static readonly PRApprovalUserType CURRENT_USER = new PRApprovalUserType(PRApprovalUserTypeEnum.CURRENT_USER, "Current User");
        public static readonly PRApprovalUserType ALL_USER = new PRApprovalUserType(PRApprovalUserTypeEnum.ALL_USER, "All User");

        private PRApprovalUserType(PRApprovalUserTypeEnum value, String name)
        {
            this.Name = name;
            this.Value = value;
        }

        public override String ToString()
        {
            return Name;
        }
    }

    public enum PRApprovalUserTypeEnum
    {
        CURRENT_USER,
        ALL_USER,
    }
}