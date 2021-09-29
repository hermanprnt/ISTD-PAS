using System;
using System.Collections.Generic;
using GPS.Constants.PRPOApproval;
using GPS.Core;
using GPS.Core.ViewModel;
using GPS.ViewModels;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.PRPOApproval
{
    public class POApprovalRepository
    {
        public sealed class SqlFile
        {
            public const String GetApproval = "POApproval/GetApproval";
            public const String GetList = "POApproval/GetList";
            public const String GetListCount = "POApproval/GetListCount";
            public const String Approve = "POApproval/Approve";
            public const String Reject = "POApproval/Reject";

            public const String CountDetailList = "POApproval/CountDetailList";
            public const String GetDetailList = "POApproval/GetDetailList";
            public const String GetPOSubItemList = "POApproval/GetPOSubItemList";
            public const String GetConditionList = "POApproval/GetConditionList";
            public const String CountConditionList = "POApproval/CountConditionList";
        }

        private readonly IDBContext db;
        public POApprovalRepository()
        {
            db = DatabaseManager.Instance.GetContext();
            db.SetExecutionMode(DBContextExecutionMode.Direct);
        }

        public IList<POApprovalSubItem> GetPOSubItemList(POApprovalDetail param = null)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            // Set default value for param object.
            if (param == null)
                param = new POApprovalDetail();

            dynamic args = new
            {
                param.DOC_NO,
                param.ITEM_NO,
            };

            IList<POApprovalSubItem> result = db.Fetch<POApprovalSubItem>(SqlFile.GetPOSubItemList, args);
            db.Close();
            return result;
        }

        public Int32 CountPOList(PRPOApprovalParam param = null)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            // Set default value for param object.
            if (param == null)
                param = new PRPOApprovalParam();

            dynamic args = new
            {
                param.DOC_NO,
                param.DOC_TYPE,
                param.DOC_DESC,
                param.DATE_FROM,
                param.DATE_TO,
                param.PR_COORDINATOR,
                param.PLANT_CD,
                param.SLOC_CD,
                param.PURCHASING_GRP_CD,
                param.VENDOR_CD,
                param.CURRENCY,
                //param.STATUSD,
                param.USER_TYPE,
                param.REG_NO
            };

            Int32 result = db.ExecuteScalar<Int32>(SqlFile.GetListCount, args);
            db.Close();
            return result;
        }

        public POApproval GetApproval(String documentNo)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            POApproval result = db.SingleOrDefault<POApproval>(SqlFile.GetApproval, new { DocNo = documentNo });
            db.Close();

            return result;
        }

        public IEnumerable<POApproval> SearchList(POApprovalParam param)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<POApproval> result = db.Fetch<POApproval>(SqlFile.GetList, param);
            db.Close();
            return result;
        }

        public PaginationViewModel SearchListCount(POApprovalParam param)
        {
            var viewModel = new PaginationViewModel();
            viewModel.DataName = PRPOApprovalPage.POApproval;
            viewModel.TotalDataCount = GetListCount(param);
            viewModel.PageIndex = param.CurrentPage;
            viewModel.PageSize = param.PageSize;

            return viewModel;
        }

        public Int32 GetListCount(POApprovalParam param)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            Int32 result = db.SingleOrDefault<Int32>(SqlFile.GetListCount, param);
            db.Close();

            return result;
        }

        public Dictionary<String, String> GetUserTypeList()
        {
            var result = new Dictionary<String, String>();
            result.Add(UserType.CurrentUser, "Current User");
            result.Add(UserType.AllUser, "All User");
            return result;
        }

        public Int32 CountPODetailList(POApproval param, String docType)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            // Set default value for param object.
            if (param == null)
                param = new POApproval();

            Int32 result = db.ExecuteScalar<Int32>(SqlFile.CountDetailList, new { DOC_NO = param.DocNo, REG_NO = param.CurrentUserRegNo, USER_TYPE = param.UserType });
            db.Close();
            return result;
        }

        public Int32 CountPOConditionList(POApproval param = null)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            // Set default value for param object.
            if (param == null)
                param = new POApproval();

            Int32 result = db.ExecuteScalar<Int32>(SqlFile.CountConditionList, new { DOC_NO = param.DocNo });
            db.Close();
            return result;
        }

        public IEnumerable<POApprovalDetail> GetPODetailList(POApproval param, String docType, Int32 pageIndex = 1, Int32 pageSize = 10)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            // Set default value for param object.
            if (param == null)
                param = new POApproval();

            dynamic args = new
            {
                DOC_NO = param.DocNo,
                REG_NO = param.CurrentUserRegNo,
                USER_TYPE = param.UserType,

                PAGE_INDEX = pageIndex,
                PAGE_SIZE = pageSize
            };

            IEnumerable<POApprovalDetail> result = db.Fetch<POApprovalDetail>(SqlFile.GetDetailList, args);
            db.Close();
            return result;
        }

        public IEnumerable<POApprovalCondition> GetPOConditionList(POApproval param, String docType, Int32 pageIndex = 1, Int32 pageSize = 10)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            // Set default value for param object.
            if (param == null)
                param = new POApproval();

            dynamic args = new
            {
                DOC_NO = param.DocNo,
                pageIndex,
                pageSize
            };

            IEnumerable<POApprovalCondition> result = db.Fetch<POApprovalCondition>(SqlFile.GetConditionList, args);
            db.Close();
            return result;
        }

        public ExecPOApprovalResultModel Approve(ExecPOApprovalModel execParam)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            var execResult = db.SingleOrDefault<ExecPOApprovalResultModel>(SqlFile.Approve, execParam);
            db.Close();

            var resultViewModel = execResult.Message.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return execResult;
        }

        public ExecPOApprovalResultModel Reject(ExecPOApprovalModel execParam)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            var execResult = db.SingleOrDefault<ExecPOApprovalResultModel>(SqlFile.Reject, execParam);
            db.Close();

            var resultViewModel = execResult.Message.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return execResult;
        }
    }
}