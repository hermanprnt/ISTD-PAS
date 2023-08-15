using System;
using System.Collections.Generic;
using System.Linq;
using GPS.Constants.PRPOApproval;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;
using GPS.Models.Common;

namespace GPS.Models.PRPOApproval
{
    public class PRApprovalRepository
    {
        public sealed class SqlFile
        {
            public const String GetList = "PRApproval/GetList";
            public const String CountList = "PRApproval/CountList";
            public const String CountDetailList = "PRApproval/CountDetailList";
            public const String ApproveHeader = "PRApproval/ApproveHeader";
            public const String ApproveDetail = "PRApproval/ApproveDetail";
            public const String GetDetailList = "PRApproval/GetDetailList";
            public const String GetPRHeader = "PRApproval/GetPRHeader";
            public const String GetPRSubItemList = "PRApproval/GetSubItemList";
            public const String RejectHeader = "PRApproval/RejectHeader";
            public const String RejectDetail = "PRApproval/RejectDetail";
            public const String GetListAccounting = "PRApproval/GetListAccounting";
            public const String CountListAccounting = "PRApproval/CountListAccounting";
            public const String ApprovalDivision = "PR/PRInquiry/get_approvalDivision";
            public const String ApprovalCoordinator = "PR/PRInquiry/get_approvalCoordinator";
            public const String ApprovalFinance = "PR/PRInquiry/get_approvalFinance";
            public const String ApprovalCount = "PR/PRInquiry/count_approval";

            public const String GetListDocNoOnly = "PRApproval/GetListDocNoOnly";
            public const String GetListAccountingDocNoOnly = "PRApproval/GetListAccountingDocNoOnly";

        }

        #region Singleton
        private PRApprovalRepository() { }
        private static PRApprovalRepository instance = null;
        public static PRApprovalRepository Instance
        {
            get { return instance ?? (instance = new PRApprovalRepository()); }
        }
        #endregion

        #region Data Methods
        public Int32 CountPRList(PRPOApprovalParam param = null)
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
                param.DIVISION_ID,
                param.USER_TYPE,
                param.REG_NO
            };

            Int32 result = db.ExecuteScalar<Int32>(SqlFile.CountList, args);
            db.Close();
            return result;
        }

        public Int32 CountPRListAccounting(PRPOApprovalParam param = null)
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
                param.DIVISION_ID,
                param.USER_TYPE,
                param.REG_NO
            };

            Int32 result = db.ExecuteScalar<Int32>(SqlFile.CountListAccounting, args);
            db.Close();
            return result;
        }

        public IEnumerable<PRApprovalSubItem> GetPRSubItemList(PRApprovalDetail param = null)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            // Set default value for param object.
            if (param == null)
                param = new PRApprovalDetail();

            dynamic args = new
            {
                param.DOC_NO,
                param.ITEM_NO,
            };

            IEnumerable<PRApprovalSubItem> result = db.Fetch<PRApprovalSubItem>(SqlFile.GetPRSubItemList, args);
            db.Close();
            return result;
        }

        public IEnumerable<PRApproval> GetPRList(PRPOApprovalParam param = null, Int64 pageIndex = 1, Int32 pageSize = 10)
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
                param.DIVISION_ID,
                param.USER_TYPE,

                param.REG_NO,
                param.ORDER_BY,
                PAGE_INDEX = pageIndex,
                PAGE_SIZE = pageSize
            };

            IEnumerable<PRApproval> result = db.Fetch<PRApproval>(SqlFile.GetList, args);
            db.Close();
            return result;
        }

        public PRPOApprovalParam GetPRListDocNoOnly(PRPOApprovalParam param = null)
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
                param.DIVISION_ID,
                param.USER_TYPE,
                
                param.REG_NO,
                param.ORDER_BY
            };

            PRPOApprovalParam result = db.SingleOrDefault<PRPOApprovalParam>(SqlFile.GetListDocNoOnly, args);
            db.Close();
            return result;
        }

        public string GetPRListAccountingDocNoOnly(PRPOApprovalParam param = null)
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
                param.DIVISION_ID,
                param.USER_TYPE,

                param.REG_NO,
                param.ORDER_BY
            };

            string result = db.SingleOrDefault<string>(SqlFile.GetListAccountingDocNoOnly, args);
            db.Close();
            return result;
        }

        public IEnumerable<PRApproval> GetPRListAccounting(PRPOApprovalParam param = null, Int64 pageIndex = 1, Int32 pageSize = 10)
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
                param.DIVISION_ID,
                param.USER_TYPE,

                param.REG_NO,
                param.ORDER_BY,
                PAGE_INDEX = pageIndex,
                PAGE_SIZE = pageSize
            };

            IEnumerable<PRApproval> result = db.Fetch<PRApproval>(SqlFile.GetListAccounting, args);
            db.Close();
            return result;
        }

        public Int32 CountPRDetailList(PRApproval param = null)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            // Set default value for param object.
            if (param == null)
                param = new PRApproval();

            Int32 result = db.ExecuteScalar<Int32>(SqlFile.CountDetailList, new { param.DOC_NO, param.DOC_TYPE, param.REG_NO, param.USER_TYPE });
            db.Close();
            return result;
        }

        public IEnumerable<PRApprovalDetail> GetPRDetailList(PRApproval param = null, Int64 pageIndex = 1, Int32 pageSize = 10)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            // Set default value for param object.
            if (param == null)
                param = new PRApproval();

            dynamic args = new
            {
                param.DOC_NO,
                param.DOC_TYPE,
                param.REG_NO,
                param.USER_TYPE,

                PAGE_INDEX = pageIndex,
                PAGE_SIZE = pageSize
            };

            IEnumerable<PRApprovalDetail> result = db.Fetch<PRApprovalDetail>(SqlFile.GetDetailList, args);
            db.Close();
            return result;
        }

        public Dictionary<String, String> GetPRApprovalType()
        {
            Dictionary<String, String> result = new Dictionary<String, String>();
            result.Add(PRPOApprovalType.PO.Value.ToString(), PRPOApprovalType.PO.Value.ToString());
            result.Add(PRPOApprovalType.PR.Value.ToString(), PRPOApprovalType.PR.Value.ToString());
            return result;
        }

        public Tuple<List<Worklist>, string> GetApproval(string type, string PRNO, int pageSize, int page)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            List<Worklist> resultquery = new List<Worklist>();
            string message = "";
            string sqlfile = "";

            try
            {
                switch (type)
                {
                    case "Division":
                        {
                            sqlfile = SqlFile.ApprovalDivision;
                            break;
                        }
                    case "Coordinator":
                        {
                            sqlfile = SqlFile.ApprovalCoordinator;
                            break;
                        }
                    case "Finance":
                        {
                            sqlfile = SqlFile.ApprovalFinance;
                            break;
                        }
                }

                dynamic args = new
                {
                    PR_NO = PRNO,
                    start = page,
                    length = pageSize
                };
                resultquery = db.Fetch<Worklist>(sqlfile, args);
            }
            catch (Exception e)
            {
                message = e.Message;
            }
            finally { db.Close(); }

            return new Tuple<List<Worklist>, string>(resultquery, message);
        }

        public Tuple<int, string> CountApprovalData(string prno)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string message = "";
            int result = 0;
            try
            {
                dynamic args = new { PR_NO = prno };
                result = db.SingleOrDefault<int>(SqlFile.ApprovalCount, args);
            }
            catch (Exception e)
            {
                message = e.Message;
            }
            finally
            {
                db.Close();
            }
            return new Tuple<int, string>(result, message);
        }

        #region Approve
        public CommonApprovalResult ApproveHeader(PRPOApprovalParam param, String headerMode, String docNoList, String docItemNoList, string userid, string typeApproval)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            // Set default value for param object.
            if (param == null)
                param = new PRPOApprovalParam();

            dynamic args = new
            {
                DOC_NO_PARAM = param.DOC_NO,
                DIVISION_ID_PARAM = param.DIVISION_ID,
                DOC_TYPE_PARAM = param.DOC_TYPE,
                DATE_FROM_PARAM = param.DATE_FROM,
                DATE_TO_PARAM = param.DATE_TO,
                VENDOR_CD_PARAM =param.VENDOR_CD,
                HEADER_MODE_PARAM  = headerMode,
                DOC_LIST_PARAM = docNoList,
                DOC_ITEM_LIST_PARAM  = docItemNoList,
                REG_NO_PARAM = param.REG_NO,
                USER_ID_PARAM = userid,
                USER_TYPE_PARAM = param.USER_TYPE,
                TYPEAPPROVE_PARAM = typeApproval
            };
            IEnumerable<CommonApprovalResult> result = db.Fetch<CommonApprovalResult>(SqlFile.ApproveHeader, args);
            db.Close();
            return result.Any() ? result.FirstOrDefault() : new CommonApprovalResult();
        }

        public CommonApprovalResult ApproveDetail(String regNo, String docItemNoList, string userType, string userid)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<CommonApprovalResult> result = db.Fetch<CommonApprovalResult>(SqlFile.ApproveDetail, new { DOC_ITEM_LIST = docItemNoList, REG_NO = regNo, USER_TYPE = userType, USER_ID = userid });
            db.Close();
            return result.Any() ? result.FirstOrDefault() : new CommonApprovalResult();
        }

        public PRApproval GetPRHeader(string docNo)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                DOC_NO = docNo
            };

            IEnumerable <PRApproval> result = db.Fetch<PRApproval>(SqlFile.GetPRHeader, args);
            db.Close();
            return result.Any() ? result.FirstOrDefault() : new PRApproval() { DOC_NO = docNo};
        }

        #endregion
        #endregion

        #region Approve

        #endregion

        #region Reject
        public CommonApprovalResult RejectHeader(PRPOApprovalParam param, String headerMode, String userName, String docNoList, String docItemNoList, string typeReject)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            // Set default value for param object.
            if (param == null)
                param = new PRPOApprovalParam();

            dynamic args = new
            {
                param.DOC_NO,
                param.DOC_TYPE,
                param.VENDOR_CD,
                param.DIVISION_ID,
                param.DATE_FROM,
                param.DATE_TO,
                HEADER_MODE = headerMode,
                DOC_LIST = docNoList,
                DOC_ITEM_LIST = docItemNoList,
                USER_NAME = userName,
                param.REG_NO,
                param.USER_TYPE,
                TYPEREJECT = typeReject
            };

            IEnumerable<CommonApprovalResult> result = db.Fetch<CommonApprovalResult>(SqlFile.RejectHeader, args);
            db.Close();
            return result.Any() ? result.FirstOrDefault() : new CommonApprovalResult();
        }

        public CommonApprovalResult RejectDetail(String regNo, string userName, String docItemNoList, string userType)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<CommonApprovalResult> result = db.Fetch<CommonApprovalResult>(SqlFile.RejectDetail, new { DOC_ITEM_LIST = docItemNoList, USER_NAME = userName, REG_NO = regNo, USER_TYPE = userType });
            db.Close();
            return result.Any() ? result.FirstOrDefault() : new CommonApprovalResult();
        }
        #endregion
    }
}