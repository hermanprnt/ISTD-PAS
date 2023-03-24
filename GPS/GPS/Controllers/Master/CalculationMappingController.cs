using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Models.Common;
using GPS.Models.Master;
using Toyota.Common.Web.Platform;

namespace GPS.Controllers.Master
{
    public class CalculationMappingController : PageController
    {
        public CalculationMappingController()
        {
            Settings.Title = "Calculation Mapping Screen";
        }

        protected override void Startup()
        {
        }

        #region COMMON LIST
        public List<CalculationMapping> SelectCompPrice()
        {
            List<CalculationMapping> _selectCompPrice = CalculationMappingRepository.Instance.GetDataCompPrice().ToList();
            return _selectCompPrice;
        }

        public List<CalculationMapping> SelectCalculationType()
        {
            List<CalculationMapping> _selectCalculationType = CalculationMappingRepository.Instance.GetDataCalculationType().ToList();
            return _selectCalculationType;
        }

        public List<CalculationMapping> SelectCalculation_Scheme()
        {
            List<CalculationMapping> _selectCalculationScheme = CalculationMappingRepository.Instance.GetDataCalculationScheme().ToList();
            return _selectCalculationScheme;
        }

        public static SelectList SelectPlusMinus_Flag()
        {
            return CalculationMappingRepository.Instance
                    .GetDataPlusMinusFlag()
                    .AsSelectList(pm => pm.PLUS_MINUS_SIGN, pm => pm.PLUS_MINUS_FLAG);
        }
        #endregion

        #region SEARCH DATA
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

        public ActionResult SearchData(CalculationMapping param, string issearch, int page = 1, int pageSize = 10)
        {
            if (issearch == "Y")
            {
                Tuple<int, string> RowCounts = new Tuple<int, string>(0, "");
                Tuple<List<CalculationMapping>, string> CMList = new Tuple<List<CalculationMapping>, string>(new List<CalculationMapping>(), "");

                try
                {
                    CMList = CalculationMappingRepository.Instance.ListData(param, (((page - 1) * pageSize) + 1), (page * pageSize));
                    if (CMList.Item2 != "")
                        throw new Exception(CMList.Item2);

                    RowCounts = CalculationMappingRepository.Instance.CountRetrievedData(param);
                    if (RowCounts.Item2 != "")
                        throw new Exception(RowCounts.Item2);

                    ViewData["GridData"] = new Tuple<List<CalculationMapping>, int, string>(CMList.Item1, page, "");
                    ViewData["PagingData"] = new Tuple<Paging, string, string>(CountIndex(RowCounts.Item1, pageSize, page), "SearchCalculationMapping", "0");
                }
                catch (Exception e)
                {
                    ViewData["Message"] = "Error : " + e.Message;
                }
            }
            return PartialView("_CalculationMappingGrid");
        }

        public ActionResult SearchDetail(string CALCULATION_SCHEME_CD)
        {
            ViewData["DetailCalculationMapping"] = CalculationMappingRepository.Instance.GetDetail(CALCULATION_SCHEME_CD);
            return PartialView("_DetailCalculationMapping");
        }
        #endregion

        #region ADD / EDIT DATA
        public ActionResult GetSelectedData(int isedit, string CALCULATION_SCHEME_CD, Int64 PROCESS_ID)
        {
            CalculationMapping cmdata = new CalculationMapping();
            List<CalculationMapping> cmdetail = new List<CalculationMapping>();
            List<CalculationMapping> calculation_scheme = new List<CalculationMapping>();
            
            string deltemp;
            Int64 ProcessId = 0;
            if (PROCESS_ID == 0)
            {
                ProcessId = CalculationMappingRepository.Instance.GetProcessId(isedit, this.GetCurrentUsername());
                deltemp = CalculationMappingRepository.Instance.DeleteTemp(this.GetCurrentUsername());
            }
            else
            {
                ProcessId = PROCESS_ID;
                deltemp = "SUCCESS";
            }
            if (deltemp == "SUCCESS")
            {
                try
                {
                    if (isedit == 1)
                    {
                        if(PROCESS_ID == 0)
                            cmdata = CalculationMappingRepository.Instance.GetSelectedData(CALCULATION_SCHEME_CD);
                        
                        if (cmdata == null)
                            cmdata = new CalculationMapping();

                        if (cmdata != null)
                        {
                            cmdata.CALCULATION_SCHEME_CD = cmdata.CALCULATION_SCHEME_CD != null ? cmdata.CALCULATION_SCHEME_CD.ToString() : String.Empty;
                            cmdata.CALCULATION_SCHEME_DESC = cmdata.CALCULATION_SCHEME_DESC != null ? cmdata.CALCULATION_SCHEME_DESC : String.Empty;
                            cmdata.STATUS = cmdata.STATUS != null ? cmdata.STATUS.ToString() : String.Empty;

                            if(PROCESS_ID == 0)
                                cmdetail = CalculationMappingRepository.Instance.GetDetailTemp(1, CALCULATION_SCHEME_CD, ProcessId);
                            else
                                cmdetail = CalculationMappingRepository.Instance.GetDetailTemp(0, "", PROCESS_ID);

                            if ((cmdata.MESSAGE != "") && (cmdata.MESSAGE != null))
                                throw new Exception(cmdata.MESSAGE);
                        }
                    }
                    else
                    {
                        calculation_scheme = SelectCalculation_Scheme();
                        if(PROCESS_ID != 0) cmdetail = CalculationMappingRepository.Instance.GetDetailTemp(0, "", PROCESS_ID);
                    }

                    ViewData["ProcessId"] = ProcessId;
                    ViewData["AddEditDetail"] = cmdetail;
                    ViewData["selectCompPrice"] = SelectCompPrice();
                    ViewData["selectCalculationType"] = SelectCalculationType();
                    ViewData["selectCalculationScheme"] = calculation_scheme;
                    ViewData["AddEditData"] = new Tuple<CalculationMapping, int, string>(cmdata, isedit, "");
                }
                catch (Exception e)
                {
                    ViewData["Message"] = "Error While Get Calculation Mapping Data : " + e.Message;
                }
            }
            else ViewData["Message"] = deltemp;

            if(PROCESS_ID == 0)
                return PartialView("_CalculationMappingPopup");
            else
                return PartialView("_CalculationMappingDetailGrid");
        }

        public string DeleteSelectedTemp(CalculationMapping param)
        {
            string result = CalculationMappingRepository.Instance.DeleteSelectedItem(param.SEQ_NO, param.PROCESS_ID);
            return result;
        }

        public string SaveDetail(CalculationMapping param)
        {
            string result = CalculationMappingRepository.Instance.SaveDetail(param, this.GetCurrentUsername());
            return result;
        }

        public string SaveData(CalculationMapping param, int isedit)
        {
            Tuple<string, string> result = new Tuple<string, string>("SUCCESS", "");
            //result = CalculationMappingRepository.Instance.SavingValidation(param);

            if (result.Item1 == "SUCCESS")
                result = CalculationMappingRepository.Instance.SavingProcess(param, isedit, this.GetCurrentUsername());

            switch (result.Item1)
            {
                case "SUCCESS":
                    {
                        return "SUCCESS|" + result.Item2;
                    }
                case "FAILED":
                    {
                        return "There is Error while Saving Data : " + result.Item2;
                    }
                case "WARNING":
                    {
                        return "WARNING|" + result.Item2;
                    }
                default:
                    {
                        return result.Item2;
                    }
            }
        }
        #endregion
    }
}
