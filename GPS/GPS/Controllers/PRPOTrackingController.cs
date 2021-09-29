using System;
using System.Collections.Generic;
using System.Web.Mvc;
using GPS.Models.Common;
using Toyota.Common.Web.Platform;

namespace GPS.Controllers.Common
{
    public class PRPOTrackingController : PageController
    {
        /** Controller Method **/
        public const String _PRPOTrackingController = "/PRPOTracking/";

        public const String _getSecondRow = _PRPOTrackingController + "GetSecondRow";
        public const String _getThirdRow = _PRPOTrackingController + "GetThirdRow";
        public const String _Search = _PRPOTrackingController + "SearchData";
        public const String _onchangeType = _PRPOTrackingController + "ChangeType";

        public PRPOTrackingController()
        {
            Settings.Title = "PR/PO Tracking Screen";
        }

        protected override void Startup()
        {
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

        public ActionResult SearchData(PRPOTrackingParam param, string issearch, int page = 1, int pageSize = 10)
        {
            if (issearch == "Y")
            {
                Tuple<int, string> RowCounts = new Tuple<int, string>(0, "");
                int RowLimit = 0;
                int RowCount = 0;
                Tuple<List<PRPOTrackingList>, string> dt = new Tuple<List<PRPOTrackingList>, string>(new List<PRPOTrackingList>(), "");

                try
                {
                    dt = PRPOTrackingRepository.Instance.ListData(param, (((page - 1) * pageSize) + 1), (page * pageSize));
                    if (dt.Item2 != "")
                        throw new Exception(dt.Item2);

                    RowCounts = PRPOTrackingRepository.Instance.CountRetrievedData(param);
                    if (RowCounts.Item2 != "")
                        throw new Exception(RowCounts.Item2);

                    RowLimit = Convert.ToInt32(SystemRepository.Instance.GetSystemValue("MAX_SEARCH"));

                    string message = RowCounts.Item1 >= RowLimit ? "Total data too much, more than " + RowLimit + ", System only show new " + RowLimit + " Data" : "";
                    RowCount = RowCounts.Item1 >= RowLimit ? RowLimit : RowCounts.Item1;

                    ViewData["GridData"] = new Tuple<List<PRPOTrackingList>, int, string>(dt.Item1, page, message);
                    ViewData["Paging"] = new Tuple<Paging, string, string>(CountIndex(RowCount, pageSize, page), "Search", "0");
                }
                catch (Exception e)
                {
                    ViewData["Message"] = "Error : " + e.Message;
                }
            }
            return PartialView("_PartialGrid");
        }

        public ActionResult GetSecondRow(PRPOTrackingParam param)
        {
            ViewData["SecondRow"] = PRPOTrackingRepository.Instance.GetSecondRow(param);

            return PartialView("_PartialSecondRow");
        }

        public ActionResult GetThirdRow(PRPOTrackingParam param)
        {
            ViewData["ThirdRow"] = PRPOTrackingRepository.Instance.GetThirdRow(param);

            return PartialView("_PartialThirdRow");
        }

        public ActionResult ChangeType(string DOC_TYPE)
        {
            ViewData["DOC_TYPE"] = DOC_TYPE == "PR" ? "DOC" : DOC_TYPE;
            return PartialView("_PartialStatus");
        }
    }
}