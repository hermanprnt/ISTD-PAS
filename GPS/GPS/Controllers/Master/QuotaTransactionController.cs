using System.Collections.Generic;
using System.Web.Mvc;
using GPS.Models.Common;
using GPS.CommonFunc;
using GPS.Models.Master;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;
using System.Web.Script.Serialization;

namespace GPS.Controllers.Master
{
    public class QuotaTransactionController : PageController
    {
        public QuotaTransactionController()
        {            
            Settings.Title = "Quota Transaction";           
        }

        protected override void Startup()
        {

        }     

        public IEnumerable<ValuationClass> GetListValuationClass()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<ValuationClass> listValClass = db.Fetch<ValuationClass>("Quota/GetListValuationClass");
            db.Close();
            return listValClass;
        }

        //count data
        private int CountData(string division, string type, string wbs, string coord)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                DIVISION_ID = division,
                TYPE = type,
                WBS_NO = wbs,
                ORD_COORD = coord,
            };
            int count = db.SingleOrDefault<int>("Quota/CountTotalQuotaList", args);
            db.Close();
            return count;
        }

        //get data
        private List<QuotaDetail> GetData(int start, int end, string division, string type, string wbs, string coord)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                Start = start,
                End = end,
                DIVISION_ID = division,
                TYPE = type,
                WBS_NO = wbs,
                ORD_COORD = coord,

            };
            List<QuotaDetail> list = db.Fetch<QuotaDetail>("Quota/ReadQuotaList", args);
            db.Close();
            return list;
        }

        private List<QuotaDetail> GetDataConfirm(string Doc_No, string Confirm_Flag, string QuotaType, string ConsumeMonth, string DivisionID)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                Doc_No = Doc_No,
                Confirm_Flag = Confirm_Flag,
                QuotaType = QuotaType,
                ConsumeMonth = ConsumeMonth,
                DivisionID = DivisionID

            };
            List<QuotaDetail> list = db.Fetch<QuotaDetail>("Quota/GetDataConfirm", args);
            db.Close();
            return list;
        }

        //call data
        private void CallData(int Display = 10, int Page = 1, string division = "", string type = "", string wbs = "", string coord = "")
        {
            Paging pg = new Paging(CountData(division, type, wbs, coord), Page, Display);
            ViewData["Paging"] = pg;
            List<QuotaDetail> list = GetData(pg.StartData, pg.EndData, division, type, wbs, coord);
            ViewData["ListQuota"] = list;
        }

        public ActionResult onGetData(string search, int Display = 10, int Page = 1, string division = "", string type = "", string wbs = "", string coord = "")
        {
            if (search == "Y")
            {
                CallData(Display, Page, division, type, wbs, coord);
            }

            return PartialView("_QuotaTransactionMainGrid");
        }

        public ActionResult GetSingleData(string DivisionID, string QuotaType, string ConsumeMonth)
        {
            return Json(QuotaRepository.Instance.GetSingleDataQuotaTrans(DivisionID, QuotaType, ConsumeMonth));
        }

        public ActionResult GetSingleDataConfirm(string DivisionID, string QuotaType, string ConsumeMonth)
        {
            QuotaDetail quota = QuotaRepository.Instance.GetSingleDataQuotaTrans(DivisionID, QuotaType, ConsumeMonth);
            ViewBag.CONSUME_MONTH = quota.CONSUME_MONTH;
            ViewBag.CONSUME_MONTH2 = Periode(quota.CONSUME_MONTH);
            ViewBag.DIVISION_ID = quota.DIVISION_ID;
            ViewBag.TYPE = quota.TYPE;
            ViewBag.DIVISION_NAME = quota.DIVISION_NAME;
            ViewBag.TYPE_DESCRIPTION = quota.TYPE_DESCRIPTION;

            List<QuotaDetail> list = GetDataConfirm("-", "N", QuotaType, ConsumeMonth, DivisionID);
            foreach(QuotaDetail item in list)
            {
                item.QUOTA_MONTH2 = Periode(item.QUOTA_MONTH2);
            }
            ViewData["ListQuotaConfirm"] = list;

            return PartialView("_AdditionalConfirmPopUp");
        }

        public ContentResult GetSingleDataConfirmLookup(string DIVISION_ID, string QuotaType, string ConsumeMonth)
        {
            List<QuotaDetail> list = GetDataConfirm("-", "N", QuotaType, ConsumeMonth, DIVISION_ID);

            var jsonserializer = new JavaScriptSerializer();
            var json = jsonserializer.Serialize(list);

            return Content(json);
        }  

        public ActionResult SubmitTolerance(string DivisionID, string QuotaType, string ConsumeMonth, string Tolerance)
        {
            string message = "";

            message = QuotaRepository.Instance.SubmitTolerance(DivisionID, QuotaType, ConsumeMonth, Tolerance, this.GetCurrentUsername());

            return new JsonResult
            {
                Data = new
                {
                    message = message
                }
            };
        }

        public ActionResult SubmitAdditonal(string DivisionID, string QuotaType, string ConsumeMonth, string AmountTransfer, string SourcePeriode, string SourceOrderType)
        {
            string message = "";

            message = QuotaRepository.Instance.SubmitAdditonal(DivisionID, QuotaType, ConsumeMonth, AmountTransfer, SourcePeriode, SourceOrderType, this.GetCurrentUsername());

            return new JsonResult
            {
                Data = new
                {
                    message = message
                }
            };
        }

        public ActionResult ConfirmAdditional(string DOC_NO, int SEQ_NO, string CONFIRM_FLAG, decimal Amount, string DIVISION_ID, string DT_MONTH, string DST_TYPE)
        {
            string message = "";

            message = QuotaRepository.Instance.ConfirmAdditional(DOC_NO, SEQ_NO, CONFIRM_FLAG, Amount, DIVISION_ID, DT_MONTH, DST_TYPE,this.GetCurrentUsername());

            return new JsonResult
            {
                Data = new
                {
                    message = message
                }
            };
        }

        public ActionResult ConfirmAdditionalCancel(string DOC_NO, int SEQ_NO, string CONFIRM_FLAG, decimal Amount, string DIVISION_ID, string DT_MONTH, string DST_TYPE)
        {
            string message = "";

            message = QuotaRepository.Instance.ConfirmAdditionalCancel(DOC_NO, SEQ_NO, CONFIRM_FLAG, Amount, DIVISION_ID, DT_MONTH, DST_TYPE, this.GetCurrentUsername());

            return new JsonResult
            {
                Data = new
                {
                    message = message
                }
            };
        }

        public string GetListPeriode(string CONSUME_MONTH)
        {
            string result = QuotaRepository.Instance.GetListPeriode(CONSUME_MONTH);
            return result;
        }

        public string GetListSourceOrderType(string DIVISION_ID)
        {
            string result = QuotaRepository.Instance.GetListSourceOrderType(DIVISION_ID);
            return result;
        }

        public string Periode(string CONSUME_MONTH)
        {
            var periode = "";           
            var yyyy = CONSUME_MONTH.Substring(0,4); 
            var mm = CONSUME_MONTH.Substring(CONSUME_MONTH.Length - 2, 2);                    
            var month = "";
            
            if (mm == "01") {
                month = "January";
            }
            else if (mm == "02") {
                month = "February";
            }
            else if (mm == "03") {
                month = "March";
            }
            else if (mm == "04") {
                month = "April";
            }
            else if (mm == "05") {
                month = "May";
            }
            else if (mm == "06") {
                month = "June";
            }
            else if (mm == "07") {
                month = "July";
            }
            else if (mm == "08") {
                month = "August";
            }
            else if (mm == "09") {
                month = "September";
            }
            else if (mm == "10") {
                month = "October";
            }
            else if (mm == "11") {
                month = "November";
            }
            else if (mm == "12") {
                month = "December";
            }          
            periode = month + " " + yyyy; 
            
            return  periode;    
        }

    }
}
