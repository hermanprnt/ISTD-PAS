using System.Collections.Generic;
using Toyota.Common.Web.Platform;
using Toyota.Common.Database;
using GPS.Models.Master;
using System;

namespace GPS.Models.Report
{
    public class ProcurementTrackingRepository
    {
        private ProcurementTrackingRepository() { }
        private static ProcurementTrackingRepository instance = null;

        public static ProcurementTrackingRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new ProcurementTrackingRepository();
                }
                return instance;
            }
        }

        public int CountData(string PR_NO, string PR_DT_FROM, string PR_DT_TO, string VENDOR, string CREATED_BY, string PO_NO, string PO_DT, string WBS_NO, string GR_NO, string GR_DATE, string DIVISION_ID, string INV_NO, string INV_DT, string PCS_GRP, string CLEARING_NO, string CLEARING_DATE, string STATUS_CD)
        {
            string[] PRDate = PR_DT_FROM.Split('-');
            string[] PODate = PO_DT.Split('-');
            string[] GRDate = GR_DATE.Split('-');
            string[] ClDate = CLEARING_DATE.Split('-');
            string[] InvDate = INV_DT.Split('-');
            IDBContext db = DatabaseManager.Instance.GetContext();
            

            dynamic args = new
            {
                PR_NO = PR_NO,
                PR_DATE_FROM = PRDate[0],
                PR_DATE_TO = PRDate[1],
                VENDOR = VENDOR,
                CREATED_BY = CREATED_BY,
                PO_NO = PO_NO,
                PO_DT = PODate[0],
                PO_DT_TO = PODate[1],
                WBS_NO = WBS_NO,
                GR_NO = GR_NO,
                GR_DATE = GRDate[0],
                GR_DATE_TO = GRDate[1],
                DIVISION_ID = DIVISION_ID,
                INV_NO = INV_NO,
                INV_DT = InvDate[0],
                INV_DT_TO = InvDate[1],
                PCS_GRP = PCS_GRP,
                CLEARING_NO = CLEARING_NO,
                CLEARING_DATE = ClDate[0],
                CLEARING_DATE_TO = ClDate[1],
                STATUS_CD = STATUS_CD,
            };
            int count = db.SingleOrDefault<int>("Report/countProcurementTracking",args);
            db.Close();
            return count;
        }

        public List<ProcurementTracking> GetData(string PR_NO, string PR_DT_FROM, string PR_DT_TO, string VENDOR, string CREATED_BY, string PO_NO, string PO_DT, string WBS_NO, string GR_NO, string GR_DATE, string DIVISION_ID, string INV_NO, string INV_DT, string PCS_GRP, string CLEARING_NO, string CLEARING_DATE, string STATUS_CD, int currentPage, int pageSize)
        {
            string[] PRDate = PR_DT_FROM.Split('-');
            string[] PODate = PO_DT.Split('-');
            string[] GRDate = GR_DATE.Split('-');
            string[] ClDate = CLEARING_DATE.Split('-');
            string[] InvDate = INV_DT.Split('-');
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                PR_NO = PR_NO,
                PR_DATE_FROM = PRDate[0],
                PR_DATE_TO = PRDate[1],
                VENDOR = VENDOR,
                CREATED_BY = CREATED_BY,
                PO_NO = PO_NO,
                PO_DT = PODate[0],
                PO_DT_TO = PODate[1],
                WBS_NO = WBS_NO,
                GR_NO = GR_NO,
                GR_DATE = GRDate[0],
                GR_DATE_TO = GRDate[1],
                DIVISION_ID = DIVISION_ID,
                INV_NO = INV_NO,
                INV_DT = InvDate[0],
                INV_DT_TO = InvDate[1],
                PCS_GRP = PCS_GRP,
                CLEARING_NO = CLEARING_NO,
                CLEARING_DATE = ClDate[0],
                CLEARING_DATE_TO = ClDate[1],
                STATUS_CD = STATUS_CD,
                currentPage = currentPage,
                pageSize = pageSize
            };
            List<ProcurementTracking> list = db.Fetch<ProcurementTracking>("Report/GetAllProcurementTracking", args);
            db.Close();
            return list;
        }

        public IEnumerable<ProcurementTracking> getDownloadHeader(string PR_NO, string PR_DT_FROM, string PR_DT_TO, string VENDOR, string CREATED_BY, string PO_NO, string PO_DT, string WBS_NO, string GR_NO, string GR_DATE, string DIVISION_ID, string INV_NO, string INV_DT, string PCS_GRP, string CLEARING_NO, string CLEARING_DATE, string STATUS_CD)
        {
            string[] PRDate = PR_DT_FROM.Split('-');
            string[] PODate = PO_DT.Split('-');
            string[] GRDate = GR_DATE.Split('-');
            string[] ClDate = CLEARING_DATE.Split('-');
            string[] InvDate = INV_DT.Split('-');
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                PR_NO = PR_NO,
                PR_DATE_FROM = PRDate[0],
                PR_DATE_TO = PRDate[1],
                VENDOR = VENDOR,
                CREATED_BY = CREATED_BY,
                PO_NO = PO_NO,
                PO_DT = PODate[0],
                PO_DT_TO = PODate[1],
                WBS_NO = WBS_NO,
                GR_NO = GR_NO,
                GR_DATE = GRDate[0],
                GR_DATE_TO = GRDate[1],
                DIVISION_ID = DIVISION_ID,
                INV_NO = INV_NO,
                INV_DT = InvDate[0],
                INV_DT_TO = InvDate[1],
                PCS_GRP = PCS_GRP,
                CLEARING_NO = CLEARING_NO,
                CLEARING_DATE = ClDate[0],
                CLEARING_DATE_TO = ClDate[1],
                STATUS_CD = STATUS_CD,
            };
            IEnumerable<ProcurementTracking> result = db.Fetch<ProcurementTracking>("Report/downloadDataHeader", args);
            db.Close();
            return result;
        }

        public List<ProcurementTracking> getDownloadDetail(string PR_NO, string PR_DT_FROM, string PR_DT_TO, string VENDOR, string CREATED_BY, string PO_NO, string PO_DT, string WBS_NO, string GR_NO, string GR_DATE, string DIVISION_ID, string CLEARING_NO, string CLEARING_DATE)
        {
            string[] PRDate = PR_DT_FROM.Split('-');
            string[] PODate = PO_DT.Split('-');
            string[] GRDate = GR_DATE.Split('-');
            string[] ClDate = CLEARING_DATE.Split('-');
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                PR_NO = PR_NO,
                PR_DATE_FROM = PRDate[0],
                PR_DATE_TO = PRDate[1],
                VENDOR = VENDOR,
                CREATED_BY = CREATED_BY,
                PO_NO = PO_NO,
                PO_DT = PODate[0],
                PO_DT_TO = PODate[1],
                WBS_NO = WBS_NO,
                GR_NO = GR_NO,
                GR_DATE = GRDate[0],
                GR_DATE_TO = GRDate[1],
                DIVISION_ID = DIVISION_ID,
                CLEARING_NO = CLEARING_NO,
                CLEARING_DATE = ClDate[0],
                CLEARING_DATE_TO = ClDate[1]
            };
            List<ProcurementTracking> list = db.Fetch<ProcurementTracking>("Report/downloadDataDetail", args);
            db.Close();
            return list;
        }

        public int GetUserMapping(String noReg)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            int hasil;
            dynamic args = new
            {
                NO_REG = noReg
            };

            hasil = db.SingleOrDefault<int>("Report/GetUserMappingDiv", args);
            //db.Execute("Report/GetUserMappingDiv", args);
            db.Close();
            return hasil == -1 ? 0 : hasil;
        }

        //FID.Ridwan:20220708
        #region SAP HANA
        public IEnumerable<STATUS> GetStatus()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {

            };

            IEnumerable<STATUS> result = db.Fetch<STATUS>("Report/GetStatusCd", args);
            db.Close();
            return result;
        }

        #endregion
    }
}