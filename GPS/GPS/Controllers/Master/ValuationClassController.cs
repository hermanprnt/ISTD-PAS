using System;
using System.Collections.Generic;
using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Models.Common;
using GPS.Models.Master;
using Toyota.Common.Web.Platform;

namespace GPS.Controllers.Master
{
    public class ValuationClassController : PageController
    {
        public ValuationClassController()
        {
            Settings.Title = "Valuation Class Screen";
        }

        protected override void Startup()
        {
        }

        #region COMMON LIST
        public static SelectList SelectFD()
        {
            return CommonListRepository.Instance
                    .GetDataFDCheck()
                    .AsSelectList(fd => fd.FD_GROUP_CD + " - " + fd.FD_GROUP_DESC, fd => fd.FD_GROUP_CD);
        }

        // Start add by Khanif Hanafi 17-07-2019
        public static SelectList SelectItemClass()
        {
            return CommonListRepository.Instance
                    .GetDataItemClassList()
                    .AsSelectList(fd => fd.ITEM_CLASS , fd => fd.ITEM_CLASS);
        }

        public static SelectList SelectPRCoordinator()
        {
            return CommonListRepository.Instance
                    .GetDataPRCoordinatorList()
                    .AsSelectList(fd => fd.PR_COORDINATOR_CD + " - " + fd.PR_COORDINATOR_DESC, fd => fd.PR_COORDINATOR_CD);
        }

        public static SelectList SelectMatGroup()
        {
            return CommonListRepository.Instance
                    .GetDataMatGroup()
                    .AsSelectList(fd => fd.MAT_GRP_CD + " - " + fd.MAT_GRP_DESC, fd => fd.MAT_GRP_CD);
        }

        // End add by Khanif Hanafi 17-07-2019

        public static SelectList SelectPurchasing()
        {
            return CommonListRepository.Instance
                    .GetDataPurchasing_Group()
                    .AsSelectList(pg => pg.PURCHASING_GRP_CD + " - " + pg.PURCHASING_GRP_DESC, pg => pg.PURCHASING_GRP_CD);
        }

        public static SelectList SelectCalculation_Scheme()
        {
            return CommonListRepository.Instance
                    .GetDataCalculation_Scheme()
                    .AsSelectList(cal => cal.CALCULATION_SCHEME_CD + " - " + cal.CALCULATION_SCHEME_DESC, cal => cal.CALCULATION_SCHEME_CD);
        }
        #endregion

        #region SEARCH VALUATION CLASS
        public void SaveLatestPRNO(string PR_NO, int DIVISION_ID)
        {
            TempData["DIVISION_ID"] = DIVISION_ID;
            TempData["PR_NO"] = PR_NO;
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

        public ActionResult SearchData(ValuationClass param, string issearch, int page = 1, int pageSize = 10)
        {
            if (issearch == "Y")
            {
                Tuple<int, string> RowCounts = new Tuple<int, string>(0, "");
                Tuple<List<ValuationClass>, string> VCList = new Tuple<List<ValuationClass>, string>(new List<ValuationClass>(), "");

                try
                {
                    VCList = ValuationClassRepository.Instance.ListData(param, (((page - 1) * pageSize) + 1), (page * pageSize));
                    if (VCList.Item2 != "")
                        throw new Exception(VCList.Item2);

                    RowCounts = ValuationClassRepository.Instance.CountRetrievedData(param);
                    if (RowCounts.Item2 != "")
                        throw new Exception(RowCounts.Item2);

                    ViewData["GridData"] = new Tuple<List<ValuationClass>, int, string>(VCList.Item1, page, "");
                    ViewData["PagingData"] = new Tuple<Paging, string, string>(CountIndex(RowCounts.Item1, pageSize, page), "SearchValuationClass", "0");
                }
                catch (Exception e)
                {
                    ViewData["Message"] = "Error : " + e.Message;
                }
            }
            return PartialView("_ValuationClassGrid");
        }

        public ActionResult GetSingleData(string VALUATION_CLASS, string PR_TYPE)
        {
            return Json(ValuationClassRepository.Instance.GetSelectedData(VALUATION_CLASS, PR_TYPE));
        }
        #endregion

        #region ADD / EDIT DATA
        public ActionResult GetSelectedData(int isedit, string VALUATION_CLASS, string PR_TYPE)
        {
            ValuationClass vcdata = new ValuationClass();

            try
            {
                if (isedit == 1)
                {
                    vcdata = ValuationClassRepository.Instance.GetSelectedData(VALUATION_CLASS, PR_TYPE);
                    if (vcdata == null)
                        vcdata = new ValuationClass();

                    if (vcdata != null)
                    {
                        vcdata.VALUATION_CLASS = vcdata.VALUATION_CLASS != null ? vcdata.VALUATION_CLASS.ToString() : String.Empty;
                        vcdata.VALUATION_CLASS_DESC = vcdata.VALUATION_CLASS_DESC != null ? vcdata.VALUATION_CLASS_DESC : String.Empty;
                        vcdata.AREA_DESC = vcdata.AREA_DESC != null ? vcdata.AREA_DESC.ToString() : String.Empty;
                        vcdata.PROCUREMENT_TYPE = vcdata.PROCUREMENT_TYPE != null ? vcdata.PROCUREMENT_TYPE.ToString() : String.Empty;
                        //vcdata.SELECTED_PR_TYPE = vcdata.PROCUREMENT_TYPE != null ? vcdata.PROCUREMENT_TYPE.ToString() : String.Empty;
                        vcdata.PURCHASING_GROUP_CD = vcdata.PURCHASING_GROUP_CD != null ? vcdata.PURCHASING_GROUP_CD.ToString() : String.Empty;
                        vcdata.FD_GROUP_CD = vcdata.FD_GROUP_CD != null ? vcdata.FD_GROUP_CD.ToString() : String.Empty;
                        vcdata.CALCULATION_SCHEME_CD = vcdata.CALCULATION_SCHEME_CD != null ? vcdata.CALCULATION_SCHEME_CD.ToString() : String.Empty;
                        vcdata.STATUS = vcdata.STATUS != null ? vcdata.STATUS.ToString() : String.Empty;
                        vcdata.PR_COORDINATOR_CD = vcdata.PR_COORDINATOR_CD != null ? vcdata.PR_COORDINATOR_CD.ToString() : String.Empty; // added : khanif hanafi 17-07-2019
                        vcdata.ITEM_CLASS = vcdata.ITEM_CLASS != null ? vcdata.ITEM_CLASS.ToString() : String.Empty; // added : khanif hanafi 17-07-2019
                        vcdata.MATL_GROUP = vcdata.MATL_GROUP != null ? vcdata.MATL_GROUP.ToString() : String.Empty;        //added : 20190710 : isid.rgl

                        if ((vcdata.MESSAGE != "") && (vcdata.MESSAGE != null))
                            throw new Exception(vcdata.MESSAGE);
                    }
                }

                ViewData["AddEditData"] = new Tuple<ValuationClass, int, string>(vcdata, isedit, "");
            }
            catch (Exception e)
            {
                ViewData["Message"] = "Error While Get Valuation Class Data : " + e.Message;
            }
            return PartialView("_ValuationClassPopup");
        }

        public string SaveData(ValuationClass param, int isedit)
        {
            Tuple<string, string> result = new Tuple<string, string>("SUCCESS", "");
            if (isedit == 0)
            {
                result = ValuationClassRepository.Instance.SavingValidation(param);
            }

            if (result.Item1 == "SUCCESS")
                result = ValuationClassRepository.Instance.SavingProcess(param, isedit, this.GetCurrentUsername());

            switch (result.Item1)
            {
                case "SUCCESS":
                    {
                        return "SUCCESS|" + param.VALUATION_CLASS;
                    }
                case "FAILED":
                    {
                        return "There is Error while Saving Data : " + result.Item2;
                    }
                case "WARNING":
                    {
                        return "WARNING|" + param.VALUATION_CLASS + "|" + result.Item2;
                    }
                default:
                    {
                        return result.Item2;
                    }
            }
        }
        #endregion

        #region ACTIVE / INACTIVE
        public string ActiveInactive(string newstatus, string VALUATION_CLASS)
        {
            string result = ValuationClassRepository.Instance.ActiveInactive(newstatus, VALUATION_CLASS);
            return result;
        }
        #endregion
    }
}
