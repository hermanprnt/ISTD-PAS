using System;

namespace GPS.Constants
{
    public sealed class CommonPage
    {
        public const String MainLayout = "~/Views/Shared/_Layout.cshtml";
        public const String GridPagination = "~/Views/Shared/Common/_GridPagination.cshtml";
        public const String DropdownList = "~/Views/Shared/Common/_DropdownList.cshtml";

        public const String RefreshSLocAction = "/SLoc/RefreshSLoc";

        #region Home Page
        public const String HomeWorklist = "~/Views/Home/HomeWorklist.cshtml";
        public const String HomeNotice = "~/Views/Home/HomeNotice.cshtml";
        public const String HomeAnnouncement = "~/Views/Home/HomeAnnouncement.cshtml";
        public const String HomeTracking = "~/Views/Home/HomeTracking.cshtml";
        public const String HomeAllDelayedApproval = "~/Views/Home/HomeAllDelayedApproval.cshtml";
        public const String HomeNotification = "~/Views/Home/HomeNotification.cshtml";
        #endregion
    }
}