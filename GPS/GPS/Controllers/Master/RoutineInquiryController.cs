using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Models.Common;
using GPS.Constants.Master;
using GPS.Models.Master;
using Toyota.Common.Web.Platform;

namespace GPS.Controllers.Master
{
    public class RoutineInquiryController : PageController
    {
        /** Controller Method **/
        public const String _RoutineInquiryController = "/RoutineInquiry/";
        
        public const String _SearchRoutine = _RoutineInquiryController + "SearchData";
        public const String _EditRoutine = _RoutineInquiryController + "EditRoutine";
        
        public const String _getDetailRoutineH = _RoutineInquiryController + "GetDetailRoutineH";
        public const String _getDetailRoutineItem = _RoutineInquiryController + "GetDetailRoutineItem";
        public const String _getDetailRoutineSubItem = _RoutineInquiryController + "GetDetailRoutineSubItem";
        
        public RoutineInquiryController()
        {
            Settings.Title = "Routine Inquiry Screen";
        }

        protected override void Startup()
        {
            int DIVISION_ID = DivisionRepository.Instance.GetUserDivision(this.GetCurrentRegistrationNumber());
            TempData["DIVISION_ID"] = DIVISION_ID;
        }

        #region COMMON LIST 
        public PartialViewResult GetSlocbyPlant(string param)
        {
            ViewData["Sloc"] = SLocRepository.Instance.GetSLocList(param);
            return PartialView(RoutinePage._CascadeSloc);
        }
        #endregion

        #region SEARCH PR 
        private Paging CountIndex(int count, int length, int page)
        {
            Paging PG = new Paging(count,page,length);
            List<int> index = new List<int>();

            PG.Length = count;
            PG.CountData = count;
            Double Total = Math.Ceiling((Double)count / (Double)length);

            for (int i = 1; i <= Total; i++) { index.Add(i); }
            PG.IndexList = index;
            return PG;
        }

        public ActionResult SearchData(Routine param, string issearch, int page = 1, int pageSize = 10)
        {
            if (issearch == "Y")
            {
                Tuple<int, string> RowCounts = new Tuple<int,string>(0, "");
                int RowLimit = 0;
                int RowCount = 0;
                Tuple<List<Routine>, string> RoutineList = new Tuple<List<Routine>, string>(new List<Routine>(), "");

                try
                {
                    RoutineList = RoutineRepository.Instance.ListData(param, (((page - 1) * pageSize) + 1), (page * pageSize));
                    if (RoutineList.Item2 != "")
                        throw new Exception(RoutineList.Item2);

                    RowCounts = RoutineRepository.Instance.CountRetrievedPRData(param);
                    if (RowCounts.Item2 != "")
                        throw new Exception(RowCounts.Item2);

                    RowLimit = Convert.ToInt32(SystemRepository.Instance.GetSystemValue("MAX_SEARCH"));

                    string message = RowCounts.Item1 >= RowLimit ? "Total data too much, more than " + RowLimit + ", System only show new " + RowLimit + " Data" : "";
                    RowCount = RowCounts.Item1 >= RowLimit ? RowLimit : RowCounts.Item1;

                    ViewData["GridData"] = new Tuple<List<Routine>, int, string>(RoutineList.Item1, page, message);
                    ViewData["TypePaging"] = "Header";
                    ViewData["PagingDataHeader"] = new Tuple<Paging, string, string>(CountIndex(RowCount, pageSize, page), "SearchHeader", "0");
                }
                catch (Exception e)
                {
                    ViewData["Message"] = "Error : " + e.Message;
                }
            }
            return PartialView(RoutinePage._InquiryGrid);
        }
        #endregion

        #region DETAIL PR
        public ActionResult GetDetailRoutineH(string ROUTINE_NO)
        {
            Routine routinedata = new Routine();
            try
            {
                routinedata = RoutineRepository.Instance.GetDetailRoutineH(ROUTINE_NO);
                if (routinedata == null)
                    routinedata = new Routine();

                if (routinedata != null)
                {
                    routinedata.PR_DESC = routinedata.PR_DESC != null ? routinedata.PR_DESC.ToString() : String.Empty;
                    routinedata.PR_COORDINATOR = routinedata.PR_COORDINATOR != null ? routinedata.PR_COORDINATOR.ToString() : String.Empty;
                    routinedata.DIVISION_NAME = routinedata.DIVISION_NAME != null ? routinedata.DIVISION_NAME.ToString() : String.Empty;
                    routinedata.DIVISION_PIC = routinedata.DIVISION_PIC != null ? routinedata.DIVISION_PIC.ToString() : String.Empty;
                    routinedata.PLANT_CD = routinedata.PLANT_CD != null ? routinedata.PLANT_CD.ToString() : String.Empty;
                    routinedata.SLOC_CD = routinedata.SLOC_CD != null ? routinedata.SLOC_CD.ToString() : String.Empty;
                    routinedata.SCH_TYPE = routinedata.SCH_TYPE != null ? routinedata.SCH_TYPE.ToString() : String.Empty;
                    routinedata.SCH_VALUE = routinedata.SCH_VALUE != null ? routinedata.SCH_VALUE.ToString() : String.Empty;
                    routinedata.ACTIVE_FLAG = routinedata.ACTIVE_FLAG != null ? routinedata.ACTIVE_FLAG.ToString() : String.Empty;
                    routinedata.VALID_FROM = routinedata.VALID_FROM != null ? routinedata.VALID_FROM.ToString() : String.Empty;
                    routinedata.VALID_TO = routinedata.VALID_TO != null ? routinedata.VALID_TO.ToString() : String.Empty;
  
                    if ((routinedata.MESSAGE != "") && (routinedata.MESSAGE != null))
                        throw new Exception(routinedata.MESSAGE);
                }
                BindRoutineDetailItem(ROUTINE_NO, 10, 1);
                ViewData["ROUTINE_Header"] = new Tuple<Routine, string>(routinedata, ROUTINE_NO);
            }
            catch(Exception e)
            {
                ViewData["Message"] = "Error While Get Header Routine : " + e.Message;
            }
            return PartialView(RoutinePage._InquiryDetail);
        }

        public ActionResult GetDetailRoutineItem(string ROUTINE_NO, int pageSize, int page = 1)
        {
            BindRoutineDetailItem(ROUTINE_NO, pageSize, page);

            return PartialView(RoutinePage._InquiryDetailGrid);
        }

        public void BindRoutineDetailItem(string ROUTINE_NO, int pageSize, int page = 1)
        {
            Tuple<List<Routine>, string> ROUTINE_ITEM_DATA = new Tuple<List<Routine>, string>(new List<Routine>(), "");
            Tuple<int, string> ROUTINE_ITEM_DATA_Count = new Tuple<int, string>(0, "");
            try
            {

                ROUTINE_ITEM_DATA = RoutineRepository.Instance.GetDetailRoutineItem(ROUTINE_NO, (page * pageSize), (((page - 1) * pageSize) + 1));
                if (ROUTINE_ITEM_DATA.Item2 != "")
                    throw new Exception(ROUTINE_ITEM_DATA.Item2);

                ROUTINE_ITEM_DATA_Count = RoutineRepository.Instance.CountRoutineItem(ROUTINE_NO);
                if (ROUTINE_ITEM_DATA_Count.Item2 != "")
                    throw new Exception(ROUTINE_ITEM_DATA_Count.Item2);

                ViewData["ROUTINE_NO"] = ROUTINE_NO;
                ViewData["ROUTINE_Item"] = ROUTINE_ITEM_DATA.Item1;
                ViewData["TypePaging"] = "Item";
                ViewData["PagingDataItem"] = new Tuple<Paging, string, string>(CountIndex(ROUTINE_ITEM_DATA_Count.Item1, pageSize, page), "SearchRoutineItem", ROUTINE_NO);
            }
            catch (Exception e)
            {
                ViewData["Message"] = "Error While Get Detail Routine : " + e.Message;
            }
        }

        public ActionResult GetDetailRoutineSubItem(string ROUTINE_NO, string ROUTINE_ITEM_NO)
        {
            List<Routine> SUB_ITEM_DATA = RoutineRepository.Instance.GetDetailRoutineSubItem(ROUTINE_NO, ROUTINE_ITEM_NO);
            ViewData["Routine_SubItem"] = SUB_ITEM_DATA;

            return PartialView(RoutinePage._InquiryDetailSubItemGrid);
        }
        #endregion

        #region EDIT ROUTINE
        public string EditRoutine(string pROUTINE_NO)
        {
            string result = RoutineRepository.Instance.EditRoutine(pROUTINE_NO, this.GetCurrentUsername(), this.GetCurrentRegistrationNumber());
            return result;
        }
        #endregion
    }
}
