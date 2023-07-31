using System;
using System.Collections.Generic;
using Toyota.Common.Credential;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;
using System.Web.Mvc;
using GPS.Models.Master;
using GPS.Models.Home;

namespace GPS.Models.ReceivingList
{
    public class GRApprovalRepository
    {
        private GRApprovalRepository() { }
        private static readonly GRApprovalRepository instance = null;
        public static GRApprovalRepository Instance
        {
            get { return instance ?? new GRApprovalRepository(); }
        }

        public IEnumerable<CommonList> getUserType()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
            };

            IEnumerable<CommonList> result = db.Fetch<CommonList>("GRApproval/GetUserType", args);

            return result;
        }

        public int CountData(GRApproval gRApproval)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                MAT_DOC_NO = gRApproval.MAT_DOC_NO,
                PLANT_CD = gRApproval.PLANT_CD,
                SLOC_CD = gRApproval.SLOC_CD,
                HEADER_TEXT = gRApproval.HEADER_TEXT,
                DIVISION_ID = gRApproval.DIVISION_ID,
                PR_COORDINATOR = gRApproval.PR_COORDINATOR,
                START_DOC_DATE = gRApproval.START_DOC_DATE,
                END_DOC_DATE = gRApproval.END_DOC_DATE,
                USER_TYPE = gRApproval.USER_TYPE,
            };

            int result = db.SingleOrDefault<int>("GRApproval/CountData", args);
            db.Close();

            return result;
        }

        public IEnumerable<GRApproval> GetListData(GRApproval gRApproval, int start, int length)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                MAT_DOC_NO = gRApproval.MAT_DOC_NO,
                PLANT_CD = gRApproval.PLANT_CD,
                SLOC_CD = gRApproval.SLOC_CD,
                HEADER_TEXT = gRApproval.HEADER_TEXT,
                DIVISION_ID = gRApproval.DIVISION_ID,
                PR_COORDINATOR = gRApproval.PR_COORDINATOR,
                START_DOC_DATE = gRApproval.START_DOC_DATE,
                END_DOC_DATE = gRApproval.END_DOC_DATE,
                USER_TYPE = gRApproval.USER_TYPE,
                RowStart = start,
                RowEnd = length
            };

            IEnumerable<GRApproval> result = db.Fetch<GRApproval>("GRApproval/GetData", args);

            db.Close();
            return result;
        }

        public IEnumerable<GRDetail> GetDetail(GRApproval gRApproval, int start, int length)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                MAT_DOC_NO = gRApproval.MAT_DOC_NO,
                PO_NO = gRApproval.PO_NO,
                HEADER_TEXT = gRApproval.HEADER_TEXT,
                RowStart = start,
                RowEnd = length
            };

            IEnumerable<GRDetail> result = db.Fetch<GRDetail>("GRApproval/GetDetail", args);

            db.Close();
            return result;
        }

        public int CountDetail(GRApproval gRApproval)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                MAT_DOC_NO = gRApproval.MAT_DOC_NO,
                PO_NO = gRApproval.PO_NO,
                HEADER_TEXT = gRApproval.HEADER_TEXT
            };

            int result = db.SingleOrDefault<int>("GRApproval/CountDetail", args);
            db.Close();

            return result;
        }

        public IEnumerable<string> getNoReg()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
            };

            IEnumerable<string> result = db.Fetch<string>("GRApproval/GetNoreg", args);

            return result;
        }

        public string Approve(string MAT_DOC_NO_LIST, string USER, string LAST_CHANGE_LIST)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                MAT_DOC_NO_LIST = MAT_DOC_NO_LIST,
                LAST_CHANGE_LIST = LAST_CHANGE_LIST,
                USER = USER
            };

            string result = db.Fetch<string>("GRApproval/Approve", args)[0];

            db.Close();
            return result;
        }

    }
}