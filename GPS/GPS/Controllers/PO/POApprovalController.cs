using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Constants;
using GPS.Constants.PRPOApproval;
using GPS.Core;
using GPS.Models.Common;
using GPS.Models.PO;
using GPS.Models.PRPOApproval;
using GPS.ViewModels;
using Toyota.Common.Web.Platform;

namespace GPS.Controllers.PO
{
    public class POApprovalController : PageController
    {
        public const String _GetSubItem = "/POApproval/GetPOApprovalSubItem";

        private readonly POApprovalRepository approvalRepo = new POApprovalRepository();
        private readonly POCommonRepository commonRepo = new POCommonRepository();

        public sealed class Action
        {
            public const String ApprovePO = "/POApproval/ApprovePO";
            public const String RejectPO = "/POApproval/RejectPO";
        }

        protected override void Startup()
        {
            Settings.Title = "PO Approval";

            ViewData["UserType"] = approvalRepo.GetUserTypeList();
            ViewData["Noreg"] = this.GetCurrentRegistrationNumber();

            ViewData["POApproval"] = new List<POApproval>();
            ViewData["POApprovalPage"] = new PaginationViewModel() { DataName = PRPOApprovalPage.POApproval, PageIndex = 1, PageSize = 10 };
        }

        #region View Methods
        [HttpPost]
        public ActionResult ResetPRApprovalGrid(PRPOApprovalParam param, Int64 pageIndex, int pageSize)
        {
            try
            {
                ViewData["POApproval"] = new List<PRApproval>();
                ViewData["POApprovalPage"] = new PaginationViewModel() { DataName = PRPOApprovalPage.POApproval, PageIndex = 1, PageSize = 10 };

                return PartialView(PRPOApprovalPage.POApprovalGrid);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult GetPOApprovalGrid(POApprovalParam param)
        {
            try
            {
                param.CurrentUserRegNo = this.GetCurrentRegistrationNumber();
                param.CurrentUser = this.GetCurrentUsername();

                BindPOApproval(param);

                return PartialView(PRPOApprovalPage.POApprovalGrid);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult GetPOApprovalGridSort(POApprovalParam param)
        {
            param.CurrentUserRegNo = this.GetCurrentRegistrationNumber();
            param.CurrentUser = this.GetCurrentUsername();
            ViewData["POApproval"] = approvalRepo.SearchList(param);
            
            return PartialView("POApprovalGridBody");
        }

        [HttpPost]
        public ActionResult GetPOApprovalDetail(POApproval param, Boolean showNotice, Int32 pageIndex, Int32 pageSize)
        {
            try
            {
                String docNo = param.DocNo;
                String docType = PRPOApprovalType.PO.ToString();

                param = approvalRepo.GetApproval(docNo);
                param.CurrentUserRegNo = this.GetCurrentRegistrationNumber();
                if (String.IsNullOrEmpty(param.UserType) || param.UserType == UserType.CurrentUser)
                    param.UserType = UserType.CurrentUser;

                BindPOApprovalDetail(param, docType, pageIndex, pageSize);
                BindPOApprovalCondition(param, docType, pageIndex, pageSize);

                BindPOApprovalNotice(docNo, showNotice);
                BindPOApprovalNoticeUser(docNo);
                BindPOApprovalAttachment(docNo);
                BindPOApprovalDelay(param.CurrentUserRegNo);

                ViewData["POApprovalType"] = docType;
                ViewData["POApprovalDocNo"] = docNo;

                return PartialView(PRPOApprovalPage.POApprovalDetail);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult GetPOApprovalSubItem(String docNo, String docItemNo)
        {
            try
            {
                ViewData["POApprovalSubItem"] = approvalRepo.GetPOSubItemList(new POApprovalDetail { DOC_NO = docNo, ITEM_NO = docItemNo });

                return PartialView(PRPOApprovalPage.POApprovalSubItemGrid);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpGet]
        public ActionResult GetPOApprovalHistory(CommonApprovalHistoryParam param, Int64 pageIndex, int pageSize)
        {
            try
            {
                BindPOApprovalHistory(param, pageIndex, pageSize);

                return PartialView(PRPOApprovalPage.POApprovalHistory);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult GetPOApprovalHistoryGrid(CommonApprovalHistoryParam param, Int64 pageIndex, int pageSize)
        {
            try
            {
                BindPOApprovalHistory(param, pageIndex, pageSize);

                return PartialView(PRPOApprovalPage.POApprovalHistoryGrid);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }
        #endregion

        private void FixDateFromAndTo(ExecPOApprovalModel execParam)
        {
            String dateFrom = (execParam.DateFrom ?? String.Empty).Trim();
            String dateTo = (execParam.DateTo ?? String.Empty).Trim();

            if (dateFrom != String.Empty)
                execParam.DateFrom = dateFrom.FromStandardFormat().ToSqlCompatibleFormat();

            if (dateTo != String.Empty)
                execParam.DateTo = dateTo.FromStandardFormat().ToSqlCompatibleFormat();
        }

        #region Data Methods
        [HttpPost]
        public ActionResult ApprovePO(ExecPOApprovalModel execParam)
        {
            try
            {
                FixDateFromAndTo(execParam);

                execParam.CurrentUser = this.GetCurrentUsername();
                execParam.CurrentRegNo = this.GetCurrentRegistrationNumber();
                execParam.ModuleId = ModuleId.PurchaseOrder;
                execParam.FunctionId = FunctionId.POApproval;
                ExecPOApprovalResultModel result = approvalRepo.Approve(execParam);
                ViewBag.POApprovalResult = result;

                return PartialView(PRPOApprovalPage.POApprovalResultDialog);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult RejectPO(ExecPOApprovalModel execParam)
        {
            try
            {
                FixDateFromAndTo(execParam);

                execParam.CurrentUser = this.GetCurrentUsername();
                execParam.CurrentRegNo = this.GetCurrentRegistrationNumber();
                execParam.ModuleId = ModuleId.PurchaseOrder;
                execParam.FunctionId = FunctionId.POApproval;
                ExecPOApprovalResultModel result = approvalRepo.Reject(execParam);
                ViewBag.POApprovalResult = result;

                return PartialView(PRPOApprovalPage.POApprovalResultDialog);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult PostPOApprovalNotice(CommonApprovalNotice param)
        {
            try
            {
                param.DOC_TYPE = "PO";

                param.NOTICE_FROM_USER = this.GetCurrentRegistrationNumber();
                param.NOTICE_FROM_ALIAS = this.GetCurrentUserNameDescription(this.GetCurrentRegistrationNumber()).PERSONNEL_NAME;
                param.CREATED_BY = this.GetCurrentUsername();
                int result = CommonApprovalRepository.Instance.PostNotice(param);
                if (result >= 1)
                    BindPOApprovalNotice(param.DOC_NO, true);

                return PartialView(PRPOApprovalPage.POApprovalNoticeMessage);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult ReplyPOApprovalNotice(CommonApprovalNotice param)
        {
            try
            {
                param.DOC_TYPE = "PO";

                param.NOTICE_FROM_USER = this.GetCurrentRegistrationNumber();
                param.NOTICE_FROM_ALIAS = this.GetCurrentUserNameDescription(this.GetCurrentRegistrationNumber()).PERSONNEL_NAME;
                param.CREATED_BY = this.GetCurrentUsername();
                int result = CommonApprovalRepository.Instance.ReplyNotice(param);
                if (result >= 1)
                    BindPOApprovalNotice(param.DOC_NO, true);

                return PartialView(PRPOApprovalPage.POApprovalNoticeMessage);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult DeletePOApprovalNotice(CommonApprovalNotice param)
        {
            try
            {
                int result = CommonApprovalRepository.Instance.DeleteNotice(param);
                if (result >= 1)
                    BindPOApprovalNotice(param.DOC_NO, true);

                return PartialView(PRPOApprovalPage.POApprovalNoticeMessage);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpGet]
        public FileManagerResult DownloadPOApprovalAttachment(string docNo, string docSource, string fileName, string fileNameOri, string docYear)
        {
            try
            {
                string filePath = Path.GetFullPath(commonRepo.GetDocumentBasePath() + "\\" + docYear + "\\" + docNo);
                byte[] result = FileManager.ReadFile(filePath, fileName);
                return new FileManagerResult(fileNameOri, result);
            }
            catch (Exception ex)
            {
                var errorFile = PdfFileCreator.GenerateErrorInfoTextFile(ex);
                return new FileManagerResult(errorFile.Filename, errorFile.FileByteArray);
            }
        }

        #endregion

        #region Bind Methods
        private void BindPOApproval(POApprovalParam param)
        {
            param.FixDateFromAndTo();

            // Bind data.
            ViewData["POApproval"] = approvalRepo.SearchList(param);

            // Bind pagination.
            ViewData["POApprovalPage"] = approvalRepo.SearchListCount(param);
        }

        private void BindPOApprovalDetail(POApproval param, String docType, Int32 pageIndex = 1, Int32 pageSize = 10)
        {
            // Bind parameter.
            ViewData["POApproval"] = param;

            // Bind data.
            ViewData["POApprovalDetail"] = approvalRepo.GetPODetailList(param, docType, pageIndex, pageSize);

            // Bind pagination.
            PaginationViewModel result = new PaginationViewModel();
            result.DataName = PRPOApprovalPage.POApprovalDetail;
            result.TotalDataCount = approvalRepo.CountPODetailList(param, docType);
            result.PageIndex = pageIndex;
            result.PageSize = pageSize;
            result.TotalPageCount = Convert.ToInt32(Math.Ceiling((Double)result.TotalDataCount / result.PageSize));
            ViewData["POApprovalDetailPage"] = result;
        }

        private void BindPOApprovalCondition(POApproval param, String docType, Int32 pageIndex = 1, Int32 pageSize = 10)
        {
            // Bind parameter.
            ViewData["POApproval"] = param;

            // Bind data.
            ViewData["POApprovalCondition"] = approvalRepo.GetPOConditionList(param, docType, pageIndex, pageSize);

            // Bind pagination.
            PaginationViewModel result = new PaginationViewModel();
            result.DataName = PRPOApprovalPage.POApprovalDetail;
            result.TotalDataCount = approvalRepo.CountPOConditionList(param);
            result.PageIndex = pageIndex;
            result.PageSize = pageSize;
            result.TotalPageCount = Convert.ToInt32(Math.Ceiling((Double)result.TotalDataCount / result.PageSize));
            ViewData["POApprovalConditionPage"] = result;
        }

        private void BindPOApprovalAttachment(string docNo)
        {
            // Bind data.
            IList<Attachment> attachmentList = AttachmentRepository.Instance.GetAllData(docNo);
            ViewData["POApprovalAttachment"] = attachmentList;
            ViewData["POApprovalBiddingDoc"] = attachmentList.Where(att => att.DOC_TYPE == "BID").ToList();
            ViewData["POApprovalQuotation"] = attachmentList.Where(att => att.DOC_TYPE == "QUOT").ToList();
        }

        private void BindPOApprovalNotice(String docNo, Boolean showNotice)
        {
            String userName = this.GetCurrentUsername();

            ViewData["POApprovalShowNotice"] = showNotice;

            // Bind current user.
            ViewData["POApprovalNoticeCurrentUser"] = userName;

            // Bind data notice.
            ViewData["POApprovalNotice"] = CommonApprovalRepository.Instance.GetNoticeList(docNo, this.GetCurrentRegistrationNumber());
        }

        private void BindPOApprovalNoticeUser(String docNo)
        {
            // Bind user notice. 20190930 
            List<CommonApprovalNoticeUser> dt = CommonApprovalRepository.Instance.GetNoticeUserListPR(docNo).ToList<CommonApprovalNoticeUser>();
            dt.Remove(new CommonApprovalNoticeUser(){ NOTICE_TO_USER = this.GetCurrentRegistrationNumber() });
            ViewData["POApprovalNoticeUser"] = dt.Select(x => new { x.NOTICE_TO_USER, NOTICE_TO_ALIAS = x.NOTICE_TO_ALIAS.ToPascalCase() });
        }

        private void BindPOApprovalHistory(CommonApprovalHistoryParam param, Int64 pageIndex = 1, int pageSize = 10)
        {
            // Bind data.
            ViewData["POApprovalHistory"] = CommonApprovalRepository.Instance.GetHistoryList(param, pageIndex, pageSize);

            // Bing pagination.
            PaginationViewModel result = new PaginationViewModel();
            result.DataName = PRPOApprovalPage.PRApprovalHistory;
            result.TotalDataCount = CommonApprovalRepository.Instance.CountHistoryList(param);
            result.PageIndex = Convert.ToInt32(pageIndex);
            result.PageSize = pageSize;
            result.TotalPageCount = Convert.ToInt32(Math.Ceiling((Double)result.TotalDataCount / result.PageSize));
            ViewData["POApprovalHistoryPage"] = result;
        }

        private void BindPOApprovalDelay(string userName)
        {
            // Bind data.
            ViewData["POApprovalDelay"] = CommonApprovalRepository.Instance.GetDelayedApproval(userName);
        }
        #endregion

    }
}
