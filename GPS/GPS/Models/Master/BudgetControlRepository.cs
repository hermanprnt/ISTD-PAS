using System.Collections.Generic;
using Toyota.Common.Web.Platform;
using Toyota.Common.Database;

namespace GPS.Models.Master
{
    public class BudgetControlRepository
    {
        private BudgetControlRepository() { }
        private static BudgetControlRepository instance = null;

        public static BudgetControlRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new BudgetControlRepository();
                }
                return instance;
            }
        }


        

        //GET DATA FOR INQUIRY
        public int CountData(string division, string wbs_no, string year)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                DIVISION = division,
                WBS_NO = wbs_no,
                WBS_YEAR = year,

            };
            int count = db.SingleOrDefault<int>("Master/BudgetControl/countDataHeader", args);
            db.Close();
            return count;
        }

        public List<BudgetControl> GetData(int start, int end, string division, string wbs_no, string year)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                Start = start,
                End = end,
                DIVISION = division,
                WBS_NO = wbs_no,
                WBS_YEAR = year,
            };
            List<BudgetControl> list = db.Fetch<BudgetControl>("Master/BudgetControl/getDataHeader", args);
            db.Close();
            return list;
        }

        public List<BudgetControl> GetSingleWBSData(string wbs_no, string division, string year)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                WBS_NO = wbs_no,
                DIVISION = division,
                WBS_YEAR = year,
            };

            List<BudgetControl> list = db.Fetch<BudgetControl>("Master/BudgetControl/getDataHeader", args);
            db.Close();
            return list;
        }

        public BudgetControl GetSingleWBSData(string wbs_no)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                WBS_NO = wbs_no,
            };

            BudgetControl result = db.SingleOrDefault<BudgetControl>("Master/BudgetControl/getSingleDataWBS", args);
            db.Close();
            return result;
        }


        public IEnumerable<BudgetControl> getDownloadHeader(string divCd, string wbs_no, string year)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                DIVISION = divCd,
                WBS_NO = wbs_no,
                WBS_YEAR = year
            };
            IEnumerable<BudgetControl> result = db.Fetch<BudgetControl>("Master/BudgetControl/downloadDataHeader", args);
            db.Close();
            return result;
        }

        public List<BudgetControl> getDownloadDetail(string wbs_no, string action_type)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                WBS_NO = wbs_no,
                ACTION_TYPE = action_type
            };
            List<BudgetControl> list = db.Fetch<BudgetControl>("Master/BudgetControl/downloadDataDetail", args);
            db.Close();
            return list;
        }

        public int CountWBSDetail(string report_no, string action_type)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                WBS_NO = report_no,
                ACTION_TYPE = action_type
            };
            int count = db.SingleOrDefault<int>("Master/BudgetControl/countDataDetail", args);
            db.Close();
            return count;
        }

        public List<BudgetControl> GetListWBSDetail(int start, int end, string wbs_no, string action_type)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                Start = start,
                End = end,
                WBS_NO = wbs_no,
                ACTION_TYPE = action_type
            };
            List<BudgetControl> list = db.Fetch<BudgetControl>("Master/BudgetControl/getDataDetail", args);
            db.Close();
            return list;
        }

        public string GetFiscalYear()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string wbs_year = "";
            wbs_year = db.SingleOrDefault<string>("Master/BudgetControl/getFiscalYear");
            db.Close();
            return wbs_year;
        }
       
    }
}