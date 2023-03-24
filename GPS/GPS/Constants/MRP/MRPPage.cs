using System;

namespace GPS.Constants.MRP
{
    public sealed class MRPPage
    {
        // Partial
        public const String CreationMRPCheckPartial = "_mrpCheck";
        public const String InquiryGridPartial = "_inquiryGrid";
        public const String InquiryItemGridPartial = "_inquiryItemGrid";
        public const String InquiryGetPartial = "_inquiryGet";

        // Creation Action
        public const String CreationMRPCheckAction = "/MRPCreation/MRPCheck";
        public const String CreationMRPProcessAction = "/MRPCreation/MRPProcess";

        // Inquiry Action
        public const String InquirySearchAction = "/MRPInquiry/Search";
        public const String InquiryClearSearchAction = "/MRPInquiry/ClearSearch";
        public const String InquiryGetMRPAction = "/MRPInquiry/GetMRP";
    }
}