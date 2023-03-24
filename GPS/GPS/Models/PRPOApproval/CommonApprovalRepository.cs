using System;
using System.Collections.Generic;
using GPS.Constants.PRPOApproval;
using GPS.CommonFunc;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.PRPOApproval
{
    public class CommonApprovalRepository
    {
        public sealed class SqlFile
        {
            public const String GetDelayedApproval = "CommonApproval/GetDelayedApproval";
            public const String GetAllDelayedApproval = "CommonApproval/GetAllDelayedApproval";
            public const String PostNotice = "CommonApproval/PostNotice";
            public const String ReplyNotice = "CommonApproval/ReplyNotice";
            public const String DeleteNotice = "CommonApproval/DeleteNotice";
            public const String GetNoticeList = "CommonApproval/GetNoticeList";
            public const String GetNoticeUserList = "CommonApproval/GetNoticeUserList";
            public const String GetNoticeUserListPR = "CommonApproval/GetNoticeUserListPR";// get list user for notice, 20190930
            public const String GetNoticeUnseenList = "CommonApproval/GetNoticeUnseenList";
            public const String GetHistoryList = "CommonApproval/GetHistoryList";
            public const String CountHistoryList = "CommonApproval/CountHistoryList";
            public const String VendorData = "CommonApproval/GetVendorAssignment";
        }

        #region Singleton
        private CommonApprovalRepository() { }
        private static CommonApprovalRepository instance = null;
        public static CommonApprovalRepository Instance
        {
            get { return instance ?? (instance = new CommonApprovalRepository()); }
        }
        #endregion

        #region Data Methods
        public IEnumerable<CommonApprovalHistory> GetHistoryList(CommonApprovalHistoryParam param = null, Int64 pageIndex = 1, Int32 pageSize = 10)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            
            dynamic args = new
            {
                param.DOC_NO,
                param.ITEM_NO,
                param.DOC_TYPE,

                PAGE_INDEX = pageIndex,
                PAGE_SIZE = pageSize
            };

            IEnumerable<CommonApprovalHistory> result = db.Fetch<CommonApprovalHistory>(SqlFile.GetHistoryList, args);
            db.Close();
            return result;
        }

        public Dictionary<String, String> GetUserTypeList()
        {
            var result = new Dictionary<String, String>();
            result.Add(PRApprovalUserType.CURRENT_USER.Value.ToString(), PRApprovalUserType.CURRENT_USER.Name);
            result.Add(PRApprovalUserType.ALL_USER.Value.ToString(), PRApprovalUserType.ALL_USER.Name);
            return result;
        }

        public IEnumerable<CommonApprovalNoticeUser> GetNoticeUserList(String docNo)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<CommonApprovalNoticeUser> result = db.Fetch<CommonApprovalNoticeUser>(SqlFile.GetNoticeUserList, new { DOC_NO = docNo });
            db.Close();
            return result;
        }

        //get all list user for notice 20190930
        public IEnumerable<CommonApprovalNoticeUser> GetNoticeUserListPR(String docNo)
        {
            IDBContext db = DatabaseManager.Instance.GetContext("SecurityCenter");
            IEnumerable<CommonApprovalNoticeUser> result = db.Fetch<CommonApprovalNoticeUser>(SqlFile.GetNoticeUserListPR, new { DOC_NO = docNo });
            db.Close();
            return result;
        }

        public IEnumerable<CommonApprovalNotice> GetNoticeList(String docNo, String noreg)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<CommonApprovalNotice> result = db.Fetch<CommonApprovalNotice>(SqlFile.GetNoticeList, new { DOC_NO = docNo, NOREG = noreg });
            db.Close();
            return result;
        }

        public IEnumerable<CommonApprovalNotice> GetNoticeUnseenList(String noreg)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<CommonApprovalNotice> result = db.Fetch<CommonApprovalNotice>(SqlFile.GetNoticeUnseenList, new {NOREG = noreg });
            db.Close();
            return result;
        }

        public IEnumerable<PRApprovalDelay> GetDelayedApproval(String regNo)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<PRApprovalDelay> result = db.Fetch<PRApprovalDelay>(SqlFile.GetDelayedApproval, new { REG_NO = regNo });
            foreach (PRApprovalDelay item in result)
                item.STR_DOC_DT = item.DOC_DT.ToStandardFormat();
            db.Close();
            return result;
        }

        public Int32 CountHistoryList(CommonApprovalHistoryParam param = null)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            Int32 result = db.ExecuteScalar<Int32>(SqlFile.CountHistoryList, new { param.DOC_NO });
            db.Close();
            return result;
        }

        public IEnumerable<PRApprovalDelay> GetAllDelayedApproval(String regNo)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<PRApprovalDelay> result = db.Fetch<PRApprovalDelay>(SqlFile.GetAllDelayedApproval, new { REG_NO = regNo });
            foreach (PRApprovalDelay item in result)
                item.STR_DOC_DT = item.DOC_DT.ToStandardFormat();
            db.Close();
            return result;
        }

        public CommonApprovalVendorAssignment GetVendorAssignment(String docNo)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            CommonApprovalVendorAssignment result = db.SingleOrDefault<CommonApprovalVendorAssignment>(SqlFile.VendorData, new { DOC_NO = docNo });
            //IEnumerable<CommonApprovalNotice> result = db.Fetch<CommonApprovalNotice>(SqlFile.GetNoticeList, new { DOC_NO = docNo, NOREG = noreg });
            db.Close();
            return result;
        }

        #region Post
        public Int32 PostNotice(CommonApprovalNotice param)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                param.DOC_NO,
                param.DOC_TYPE,
                param.NOTICE_FROM_USER,
                param.NOTICE_FROM_ALIAS,
                param.NOTICE_TO_USER,
                param.NOTICE_TO_ALIAS,
                param.NOTICE_MESSAGE,
                param.NOTICE_IMPORTANCE,
                param.CREATED_BY
            };

            Int32 result = db.Execute(SqlFile.PostNotice, args);
            db.Close();
            return result;
        }

        public Int32 ReplyNotice(CommonApprovalNotice param)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                param.DOC_NO,
                param.DOC_TYPE,
                param.NOTICE_FROM_USER,
                param.NOTICE_FROM_ALIAS,
                param.NOTICE_TO_USER,
                param.NOTICE_TO_ALIAS,
                param.NOTICE_MESSAGE,
                param.NOTICE_IMPORTANCE,
                param.REPLY_FOR,
                param.CREATED_BY
            };

            Int32 result = db.Execute(SqlFile.ReplyNotice, args);
            db.Close();
            return result;
        }

        public Int32 DeleteNotice(CommonApprovalNotice param)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            Int32 result = db.Execute(SqlFile.DeleteNotice, new { param.DOC_NO, param.SEQ_NO });
            db.Close();
            return result;
        }
        #endregion
        #endregion
    }
}