using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Constants;
using GPS.Constants.PRPOApproval;
using GPS.Core;
using GPS.Models.Common;
using GPS.Models.Master;
using GPS.Models.PRPOApproval;
using GPS.ViewModels;
using Toyota.Common.Web.Platform;
using System.Globalization;

namespace GPS.Controllers.PR
{
    public class PRApprovalController : PageController
    {
        public const String _GetSubItem = "/PRApproval/GetPRApprovalSubItem";
        public const String _GetApproval = "/PRApproval/GetApproval";

        protected override void Startup()
        {
            Settings.Title = "PR Approval";

            ViewData["UserType"] = CommonApprovalRepository.Instance.GetUserTypeList();
            ViewData["AccountingRolesFlag"] = GetFlagRoleAccountingAccess();
            ViewData["PRApproval"] = new List<PRApproval>();
            ViewData["commonMonth"] = SystemRepository.Instance.GetSystemValue("MAXMONTH");
            ViewData["commonYears"] = SystemRepository.Instance.GetSystemValue("MAXYEARS");
            ViewData["PRApprovalPage"] = new PaginationViewModel() { DataName = PRPOApprovalPage.PRApproval, PageIndex = 1, PageSize = 10 };
        }

        #region View Methods
        [HttpPost]
        public ActionResult ResetPRApprovalGrid(PRPOApprovalParam param, Int64 pageIndex, int pageSize)
        {
            try
            {
                ViewData["PRApproval"] = new List<PRApproval>();
                ViewData["PRApprovalPage"] = new PaginationViewModel() { DataName = PRPOApprovalPage.PRApproval, PageIndex = 1, PageSize = 10 };

                return PartialView(PRPOApprovalPage.PRApprovalGrid);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult SortSearch(PRPOApprovalParam param, int pageIndex = 1, int pageSize = 10)
        {
            try
            {
                param.DOC_TYPE = "PR";
                param.REG_NO = string.Empty;
                //if (string.IsNullOrEmpty(param.USER_TYPE) || param.USER_TYPE.Equals(PRApprovalUserType.CURRENT_USER.Value.ToString()))
                param.REG_NO = this.GetCurrentRegistrationNumber();

                BindPRApproval(param, pageIndex, pageSize);

            }
            catch (Exception e)
            {
                ViewData["Message"] = "Error : " + e.Message;
            }

            if (GetFlagRoleAccountingAccess())
                return PartialView(PRPOApprovalPage.PRApprovalGridAccounting);
            else
                return PartialView(PRPOApprovalPage.PRApprovalGrid);
        }

        [HttpPost]

        public ActionResult GetPRApprovalGrid(PRPOApprovalParam param, Int64 pageIndex, int pageSize)
        {
            try
            {
                param.DOC_TYPE = "PR";
                param.REG_NO = string.Empty;
                //if (string.IsNullOrEmpty(param.USER_TYPE) || param.USER_TYPE.Equals(PRApprovalUserType.CURRENT_USER.Value.ToString()))
                param.REG_NO = this.GetCurrentRegistrationNumber();

                BindPRApproval(param, pageIndex, pageSize);

                if (GetFlagRoleAccountingAccess())
                    return PartialView(PRPOApprovalPage.PRApprovalGridAccounting);
                else
                    return PartialView(PRPOApprovalPage.PRApprovalGrid);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpGet]
        public ActionResult GetPRApprovalDetail(PRApproval param, Int64 pageIndex, int pageSize)
        {
            try
            {
                param.REG_NO = this.GetCurrentRegistrationNumber();

                //if(param.DOC_DT == DateTime.MinValue)
                //{
                //    param.DOC_DT = DateTime.ParseExact(param.STR_DOC_DT,"dd.MM.yyyy", CultureInfo.InvariantCulture);
                //}

                var newParam = PRApprovalRepository.Instance.GetPRHeader(param.DOC_NO);
                param.DOC_DT = newParam.DOC_DT;
                param.DOC_DESC = newParam.DOC_DESC;
                param.DIVISION_NAME = newParam.DIVISION_NAME;

                if (string.IsNullOrEmpty(param.USER_TYPE) || param.USER_TYPE.Equals(PRApprovalUserType.CURRENT_USER.Value.ToString()))
                {
                    param.USER_TYPE = PRApprovalUserType.CURRENT_USER.Value.ToString();
                    param.REG_NO = this.GetCurrentRegistrationNumber();
                }

                BindPRApprovalDetail(param, pageIndex, pageSize);
                //remark by rendika 03/05/2021
                //BindApproval("Division", param.DOC_NO, 10, 1);
                //BindApproval("Coordinator", param.DOC_NO, 10, 1);
                //BindApproval("Finance", param.DOC_NO, 10, 1);
                //end remark
                BindPRApprovalNotice(param.DOC_NO);
                BindPRApprovalNoticeUser(param.DOC_NO);
                BindPRApprovalAttachment(param.DOC_NO);
                BindPRApprovalDelay(param.REG_NO);
                BindPRApprovalVendorAssignment(param.DOC_NO);

                ViewData["PRApprovalType"] = param.DOC_TYPE;

                return PartialView(PRPOApprovalPage.PRApprovalDetail);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel(), JsonRequestBehavior.AllowGet);
            }
        }
        //add by rendika 03/05/2020
        [HttpPost]
        public ActionResult GetPRApprovalDetailTab(string DOC_NO, string code)
        {
            try
            {
                BindApproval(code, DOC_NO, 10, 1);
                string view = "";
                switch (code)
                {
                    case "Division":
                        {
                            view = PRPOApprovalPage.PRApprovalDivisionGrid;
                            break;
                        }
                    case "Coordinator":
                        {
                            view = PRPOApprovalPage.PRApprovalCoordinatorGrid;
                            break;
                        }
                    case "Finance":
                        {
                            view = PRPOApprovalPage.PRApprovalFinanceGrid;
                            break;
                        }
                }
                return PartialView(view);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }
        //end by rendika
        [HttpPost]
        public ActionResult GetPRApprovalSubItem(PRApprovalDetail param)
        {
            try
            {
                BindPRApprovalSubItem(param);

                return PartialView(PRPOApprovalPage.PRApprovalSubItemGrid);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult GetPRApprovalDetailGrid(PRApproval param, Int64 pageIndex, int pageSize)
        {
            try
            {
                param.REG_NO = this.GetCurrentRegistrationNumber();
                if (string.IsNullOrEmpty(param.USER_TYPE) || param.USER_TYPE.Equals(PRApprovalUserType.CURRENT_USER.Value.ToString()))
                    param.REG_NO = this.GetCurrentRegistrationNumber();

                BindPRApprovalDetail(param, pageIndex, pageSize);
                return PartialView(PRPOApprovalPage.PRApprovalDetailGrid);

                throw new InvalidOperationException("Bug: not return anything in GetPRApprovalDetailGrid");
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpGet]
        public ActionResult GetPRApprovalHistory(CommonApprovalHistoryParam param, Int64 pageIndex, int pageSize)
        {
            try
            {
                BindPRApprovalHistory(param, pageIndex, pageSize);

                return PartialView(PRPOApprovalPage.PRApprovalHistory);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult GetPRApprovalHistoryGrid(CommonApprovalHistoryParam param, Int64 pageIndex, int pageSize)
        {
            try
            {
                BindPRApprovalHistory(param, pageIndex, pageSize);

                return PartialView(PRPOApprovalPage.PRApprovalHistoryGrid);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }
        #endregion

        #region Data Methods
        public PartialViewResult GetSlocbyPlant(string param)
        {
            ViewData["Sloc"] = SLocRepository.Instance.GetSLocList(param);
            return PartialView(PRPOApprovalPage._CascadeSloc);
        }

        [HttpPost]
        public ActionResult ApprovePRApprovalHeader(PRPOApprovalParam param, string headerMode, string docNoList, string docItemNoList)
        {
            try
            {
                param.REG_NO = this.GetCurrentRegistrationNumber();
                var roleAccount = GetFlagRoleAccountingAccess();
                CommonApprovalResult resultHeader = PRApprovalRepository.Instance.ApproveHeader(param, headerMode, docNoList, docItemNoList, this.GetCurrentUsername(), roleAccount ? "ACCT" : "NON-ACCT");

                if (!String.IsNullOrEmpty(resultHeader.MESSAGE))
                {
                    String originalPath = new Uri(HttpContext.Request.Url.AbsoluteUri).OriginalString;
                    String directory = originalPath.Substring(0, originalPath.LastIndexOf("/", originalPath.LastIndexOf("/") - 1)) + "/LogMonitoringDetail/?ProcessId=" + resultHeader.MESSAGE;
                    resultHeader.MESSAGE = "<a target='_blank' href='" + directory + "'>See Log Details</a>";
                }

                ViewData["PRApprovalResult"] = resultHeader;
                return PartialView(PRPOApprovalPage.PRApprovalResultDialog);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult ApprovePRApprovalDetail(string docItemNoList, string userType)
        {
            try
            {
                string regNo = this.GetCurrentRegistrationNumber();
                CommonApprovalResult resultDetail = PRApprovalRepository.Instance.ApproveDetail(regNo, docItemNoList, userType, this.GetCurrentUsername());

                if (!String.IsNullOrEmpty(resultDetail.MESSAGE))
                {
                    String originalPath = new Uri(HttpContext.Request.Url.AbsoluteUri).OriginalString;
                    String directory = originalPath.Substring(0, originalPath.LastIndexOf("/", originalPath.LastIndexOf("/") - 1)) + "/LogMonitoringDetail/?ProcessId=" + resultDetail.MESSAGE;
                    resultDetail.MESSAGE = "<a target='_blank' href='" + directory + "'>See Log Details</a>";
                }

                ViewData["PRApprovalResult"] = resultDetail;
                return PartialView(PRPOApprovalPage.PRApprovalResultDialog);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult RejectPRApprovalHeader(PRPOApprovalParam param, string headerMode, string docNoList, string detailMode, string docItemNoList)
        {
            try
            {
                param.REG_NO = this.GetCurrentRegistrationNumber();
                var roleAccount = GetFlagRoleAccountingAccess();
                CommonApprovalResult resultHeader = PRApprovalRepository.Instance.RejectHeader(param, headerMode, this.GetCurrentUsername(), docNoList, docItemNoList, roleAccount ? "ACCT" : "NON-ACCT");
                ViewData["PRApprovalResult"] = resultHeader;

                return PartialView(PRPOApprovalPage.PRApprovalResultDialog);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult RejectPRApprovalDetail(string docItemNoList, string userType)
        {
            try
            {
                string regNo = this.GetCurrentRegistrationNumber();
                CommonApprovalResult resultDetail = PRApprovalRepository.Instance.RejectDetail(regNo, this.GetCurrentUsername(), docItemNoList, userType);
                ViewData["PRApprovalResult"] = resultDetail;

                return PartialView(PRPOApprovalPage.PRApprovalResultDialog);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult PostPRApprovalNotice(CommonApprovalNotice param)
        {
            try
            {
                param.NOTICE_FROM_USER = this.GetCurrentRegistrationNumber();
                param.NOTICE_FROM_ALIAS = this.GetCurrentUserNameDescription(this.GetCurrentRegistrationNumber()).PERSONNEL_NAME;
                param.CREATED_BY = this.GetCurrentUsername();
                int result = CommonApprovalRepository.Instance.PostNotice(param);
                if (result >= 1)
                    BindPRApprovalNotice(param.DOC_NO);

                return PartialView(PRPOApprovalPage.PRApprovalNoticeMessage);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult ReplyPRApprovalNotice(CommonApprovalNotice param)
        {
            try
            {
                param.NOTICE_FROM_USER = this.GetCurrentRegistrationNumber();
                param.NOTICE_FROM_ALIAS = this.GetCurrentUserNameDescription(this.GetCurrentRegistrationNumber()).PERSONNEL_NAME;
                param.CREATED_BY = this.GetCurrentUsername();
                int result = CommonApprovalRepository.Instance.ReplyNotice(param);
                if (result >= 1)
                    BindPRApprovalNotice(param.DOC_NO);

                return PartialView(PRPOApprovalPage.PRApprovalNoticeMessage);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult DeletePRApprovalNotice(CommonApprovalNotice param)
        {
            try
            {
                int result = CommonApprovalRepository.Instance.DeleteNotice(param);
                if (result >= 1)
                    BindPRApprovalNotice(param.DOC_NO);

                return PartialView(PRPOApprovalPage.PRApprovalNoticeMessage);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpGet]
        public FileManagerResult DownloadPRApprovalAttachment(string docNo, string fileName, string fileNameOri)
        {
            string filePath = string.Empty;

            filePath = SystemRepository.Instance.GetSystemValue(SystemCode.UploadFilePath) +
                       SystemRepository.Instance.GetSystemValue(SystemCode.PRUploadPath) + docNo;

            byte[] result = FileManager.ReadFile(filePath, fileName);
            return new FileManagerResult(fileNameOri, result);
        }
        #endregion

        #region Bind Methods
        //[HttpPost]
        public JsonResult GetCheckedAll(PRPOApprovalParam param = null)
        {
            param.DOC_TYPE = "PR";
            param.REG_NO = string.Empty;
            //if (string.IsNullOrEmpty(param.USER_TYPE) || param.USER_TYPE.Equals(PRApprovalUserType.CURRENT_USER.Value.ToString()))
            param.REG_NO = this.GetCurrentRegistrationNumber();
            var AccountRolesFlag = GetFlagRoleAccountingAccess();

            if (AccountRolesFlag)
            {
                return Json(PRApprovalRepository.Instance.GetPRListAccountingDocNoOnly(param));
            }
            else
            {
                return Json(PRApprovalRepository.Instance.GetPRListDocNoOnly(param));
            }
        }


        private void BindPRApproval(PRPOApprovalParam param = null, Int64 pageIndex = 1, int pageSize = 10)
        {
            // Bind data.
            var AccountRolesFlag = GetFlagRoleAccountingAccess();

            if (AccountRolesFlag)
            {
                ViewData["PRApproval"] = PRApprovalRepository.Instance.GetPRListAccounting(param, pageIndex, pageSize);
                //ViewData["PRDocNoOnly"] = PRApprovalRepository.Instance.GetPRListAccountingDocNoOnly(param);
            }
            else
            {
                ViewData["PRApproval"] = PRApprovalRepository.Instance.GetPRList(param, pageIndex, pageSize);
                //ViewData["PRDocNoOnly"] = PRApprovalRepository.Instance.GetPRListDocNoOnly(param);
            }

            // Bind pagination.
            PaginationViewModel result = new PaginationViewModel();
            result.DataName = PRPOApprovalPage.PRApproval;
            if (AccountRolesFlag)
                result.TotalDataCount = PRApprovalRepository.Instance.CountPRListAccounting(param);
            else
                result.TotalDataCount = PRApprovalRepository.Instance.CountPRList(param);
            result.PageIndex = Convert.ToInt32(pageIndex);
            result.PageSize = pageSize;
            result.TotalPageCount = Convert.ToInt32(Math.Ceiling((Double)result.TotalDataCount / result.PageSize));
            ViewData["PRApprovalPage"] = result;
        }

        private void BindPRApprovalDetail(PRApproval param = null, Int64 pageIndex = 1, int pageSize = 10)
        {
            // Bind parameter.
            ViewData["PRApproval"] = param;

            // Bind data.
            ViewData["PRApprovalDetail"] = PRApprovalRepository.Instance.GetPRDetailList(param, pageIndex, pageSize);

            // Bind pagination.
            PaginationViewModel result = new PaginationViewModel();
            result.DataName = PRPOApprovalPage.PRApprovalDetail;
            result.TotalDataCount = PRApprovalRepository.Instance.CountPRDetailList(param);
            result.PageIndex = Convert.ToInt32(pageIndex);
            result.PageSize = pageSize;
            result.TotalPageCount = Convert.ToInt32(Math.Ceiling((Double)result.TotalDataCount / result.PageSize));
            ViewData["PRApprovalDetailPage"] = result;
        }

        private void BindPRApprovalSubItem(PRApprovalDetail param = null)
        {
            // Bind parameter.
            ViewData["PRApprovalSubItem"] = PRApprovalRepository.Instance.GetPRSubItemList(param);
            ViewData["ItemNo"] = param.ITEM_NO.ToString();
        }

        private void BindPRApprovalAttachment(string docNo)
        {
            // Bind data.
            ViewData["PRApprovalAttachment"] = AttachmentRepository.Instance.GetAllData(docNo);
        }

        private void BindPRApprovalNotice(string docNo)
        {
            string userName = this.GetCurrentUsername();

            // Bind current user.
            ViewData["PRApprovalNoticeCurrentUser"] = userName;

            // Bind data notice.
            ViewData["PRApprovalNotice"] = CommonApprovalRepository.Instance.GetNoticeList(docNo, this.GetCurrentRegistrationNumber());
        }

        private void BindPRApprovalNoticeUser(string docNo)
        {
            // Bind user notice.
            ViewData["PRApprovalNoticeUser"] = CommonApprovalRepository.Instance.GetNoticeUserListPR(docNo).Select(x => new { x.NOTICE_TO_USER, NOTICE_TO_ALIAS = x.NOTICE_TO_ALIAS.ToPascalCase() }).Where(y => y.NOTICE_TO_USER != "-");
        }

        private void BindPRApprovalHistory(CommonApprovalHistoryParam param, Int64 pageIndex = 1, int pageSize = 10)
        {
            // Bind data.
            ViewData["PRApprovalHistory"] = CommonApprovalRepository.Instance.GetHistoryList(param, pageIndex, pageSize);

            // Bing pagination.
            PaginationViewModel result = new PaginationViewModel();
            result.DataName = PRPOApprovalPage.PRApprovalHistory;
            result.TotalDataCount = CommonApprovalRepository.Instance.CountHistoryList(param);
            result.PageIndex = Convert.ToInt32(pageIndex);
            result.PageSize = pageSize;
            result.TotalPageCount = Convert.ToInt32(Math.Ceiling((Double)result.TotalDataCount / result.PageSize));
            ViewData["PRApprovalHistoryPage"] = result;
        }

        private void BindPRApprovalDelay(string userName)
        {
            // Bind data.
            ViewData["PRApprovalDelay"] = CommonApprovalRepository.Instance.GetDelayedApproval(userName);
        }

        public ActionResult GetApproval(string type, string PR_NO, int pageSize, int page = 1)
        {
            string view = "";

            BindApproval(type, PR_NO, pageSize, page);

            ViewData["PR_NO"] = PR_NO;
            switch (type)
            {
                case "Division":
                    {
                        view = PRPOApprovalPage.PRApprovalDivisionGrid;
                        break;
                    }
                case "Coordinator":
                    {
                        view = PRPOApprovalPage.PRApprovalCoordinatorGrid;
                        break;
                    }
                case "Finance":
                    {
                        view = PRPOApprovalPage.PRApprovalFinanceGrid;
                        break;
                    }
            }

            return PartialView(view);
        }

        public void BindApproval(string type, string PR_NO, int pageSize, int page = 1)
        {
            Tuple<List<Worklist>, string> APPROVAL_DATA = new Tuple<List<Worklist>, string>(new List<Worklist>(), "");
            Tuple<int, string> APPROVAL_DATA_Count = new Tuple<int, string>(0, "");

            try
            {
                APPROVAL_DATA = PRApprovalRepository.Instance.GetApproval(type, PR_NO, (page * pageSize), (((page - 1) * pageSize) + 1));
                if (APPROVAL_DATA_Count.Item2 != "")
                    throw new Exception(APPROVAL_DATA.Item2);

                APPROVAL_DATA_Count = PRApprovalRepository.Instance.CountApprovalData(PR_NO);
                if (APPROVAL_DATA_Count.Item2 != "")
                    throw new Exception(APPROVAL_DATA_Count.Item2);

                ViewData["PR_NO"] = PR_NO;
                ViewData["Approval_" + type] = APPROVAL_DATA.Item1;
                ViewData["TypePaging"] = type;
                ViewData["PagingData" + type] = new Tuple<Paging, string, string>(CountIndex(APPROVAL_DATA_Count.Item1, pageSize, page), "SearchApproval" + type, PR_NO);
            }
            catch (Exception e)
            {
                ViewData["Message"] = "Error While Get Approval " + type + " : " + e.Message;
            }
        }

        private Paging CountIndex(int count, int length, int page)
        {
            Paging PG = new Paging(count, page, length);
            List<int> index = new List<int>();

            PG.Length = count;
            PG.CountData = count;
            Double Total = Math.Ceiling((Double)count / (Double)length);

            for (int i = 1; i <= Total; i++) { index.Add(i); }
            PG.IndexList = index;
            return PG;
        }

        #endregion

        #region Private Function
        private bool GetFlagRoleAccountingAccess()
        {
            var user = this.GetCurrentUser();
            var AccountingRoleList = SystemRepository.Instance.GetByFunctionId("ACROLE");
            Boolean flagAccRole = false;
            foreach (var item in AccountingRoleList)
            {
                var foundRoleList = user.Roles.Where(x => x.Id == item.Value);

                if (foundRoleList != null & foundRoleList.Count() > 0)
                    flagAccRole = true;
            }

            //return  true;
            return flagAccRole;
        }

        private void BindPRApprovalVendorAssignment(string docNo)
        {
            // Bind data Vendor.
            ViewData["PRApprovalVendor"] = CommonApprovalRepository.Instance.GetVendorAssignment(docNo);
        }
        #endregion
    }
}
