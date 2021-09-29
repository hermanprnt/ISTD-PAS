using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Models.Common;
using GPS.Models.Master;
using GPS.Models.PR.PRCreation;
using GPS.Constants.Master;
using Toyota.Common.Web.Platform;

namespace GPS.Controllers.Master
{
    public class RoutineCreationController : PageController
    {
        #region Controller Method
        public const String _RoutineController = "/RoutineCreation/";

        public const String _GetPIC = _RoutineController + "getPIC";
        public const String _GetPICGrid = _RoutineController + "getPICGrid";
        public const String _GetValuationClass = _RoutineController + "getValuationClass";
        public const String _GetValuationClassGrid = _RoutineController + "getValuationClassGrid";
        public const String _GetMaterial = _RoutineController + "getMaterial";
        public const String _GetMaterialGrid = _RoutineController + "getMaterialGrid";
        public const String _GetGLAccount = _RoutineController + "getGLAccount";
        public const String _GetGLAccountGrid = _RoutineController + "getGLAccountGrid";
        public const String _GetWBS = _RoutineController + "getWBS";
        public const String _GetWBSGrid = _RoutineController + "getWBSGrid";
        public const String _GetVendor = _RoutineController + "getVendor";
        public const String _GetVendorGrid = _RoutineController + "getVendorGrid";

        public const String _AddRoutine = _RoutineController + "GetRoutineNo";
        public const String _SaveRoutine = _RoutineController + "SaveRoutine";
        public const String _CancelCreation = _RoutineController + "CancelCreation";

        public const String _GetItemTemp = _RoutineController + "GetItemTempData";
        public const String _SaveItem = _RoutineController + "SaveItem";
        public const String _DeleteItem = _RoutineController + "DeleteItem";
        public const String _DeleteAllItem = _RoutineController + "DeleteAllTempData";

        public const String _GetSubItemTemp = _RoutineController + "GetSubItemTempData";
        public const String _SaveSubItem = _RoutineController + "SaveSubItem";
        public const String _DeleteSelectedSubItemTemp = _RoutineController + "DeleteSelectedSubItemTemp";
        #endregion

        public RoutineCreationController()
        {
            Settings.Title = "Routine Creation Screen";
        }

        protected override void Startup()
        {
            ViewData["UOM"] = UnitOfMeasureRepository.Instance.GetAllData();
            CreateRoutine();
        }

        #region COMMON LIST 
        public PartialViewResult GetSlocbyPlant(string param)
        {
            ViewData["Sloc"] = SLocRepository.Instance.GetSLocList(param);
            return PartialView(RoutinePage._CascadeSloc); ;
        }

        public PartialViewResult SelectCostCenter(int param = 0)
        {
            ViewData["CostCenter"] = RoutineRepository.Instance.GetDataCostCenter(param);
            return PartialView(RoutinePage._CascadeCostCenter);
        }
        #endregion

        #region GRID LOOKUP
        public ActionResult getPIC(Routine param, int pageSize = 10, int page = 1)
        {
            BindPIC(param, pageSize, page);
            return PartialView(RoutinePage._LookupPIC);
        }

        public ActionResult getPICGrid(Routine param, int pageSize = 10, int page = 1)
        {
            BindPIC(param, pageSize, page);
            return PartialView(RoutinePage._LookupPICGrid);
        }

        private void BindPIC(Routine param, int pageSize = 10, int page = 1)
        {
            ViewData["PIC"] = RoutineRepository.Instance.GetPIC(param, (page * pageSize), (((page - 1) * pageSize) + 1)).ToList();
            ViewData["Paging"] = CountIndex(RoutineRepository.Instance.CountPIC(param), pageSize, page);
            ViewData["FUNC"] = "getPICGrid";
        }

        public ActionResult getValuationClass(Routine param, int pageSize = 10, int page = 1)
        {
            BindValuationClass(param, pageSize, page);
            return PartialView(RoutinePage._LookupValuationClass);
        }

        public ActionResult getValuationClassGrid(Routine param, int pageSize = 10, int page = 1)
        {
            BindValuationClass(param, pageSize, page);
            return PartialView(RoutinePage._LookupValuationClassGrid);
        }

        private void BindValuationClass(Routine param, int pageSize = 10, int page = 1)
        {
            ViewData["ValClass"] = RoutineRepository.Instance.GetDataValuationClass(param, (page * pageSize), (((page - 1) * pageSize) + 1)).ToList();
            ViewData["Paging"] = CountIndex(RoutineRepository.Instance.CountValClass(param), pageSize, page);
            ViewData["FUNC"] = "getValClassGrid";
        }

        public ActionResult getMaterial(Routine param, int pageSize = 10, int page = 1)
        {
            BindMaterial(param, pageSize, page);
            return PartialView(RoutinePage._LookupMaterial);
        }

        public ActionResult getMaterialGrid(Routine param, int pageSize = 10, int page = 1)
        {
            BindMaterial(param, pageSize, page);
            return PartialView(RoutinePage._LookupMaterialGrid);
        }

        private void BindMaterial(Routine param, int pageSize = 10, int page = 1)
        {
            ViewData["Material"] = RoutineRepository.Instance.GetDataMatNumberConst(param, (page * pageSize), (((page - 1) * pageSize) + 1)).ToList();
            ViewData["Paging"] = CountIndex(RoutineRepository.Instance.CountMatnoConst(param), pageSize, page);
            ViewData["FUNC"] = "getMaterialGrid";
        }

        public ActionResult getGLAccount(Routine param, int pageSize = 10, int page = 1)
        {
            BindGLAccount(param, pageSize, page);
            return PartialView(RoutinePage._LookupGLAccount);
        }

        public ActionResult getGLAccountGrid(Routine param, int pageSize = 10, int page = 1)
        {
            BindGLAccount(param, pageSize, page);
            return PartialView(RoutinePage._LookupGLAccountGrid);
        }

        private void BindGLAccount(Routine param, int pageSize = 10, int page = 1)
        {
            ViewData["GLAccount"] = RoutineRepository.Instance.GetGLAccount(param, (page * pageSize), (((page - 1) * pageSize) + 1)).ToList();
            ViewData["Paging"] = CountIndex(RoutineRepository.Instance.CountGLAccount(param), pageSize, page);
            ViewData["FUNC"] = "getGLAccountGrid";
        }

        public ActionResult getWBS(Routine param, int pageSize = 10, int page = 1)
        {
            BindWBS(param, pageSize, page);
            return PartialView(RoutinePage._LookupWBS);
        }

        public ActionResult getWBSGrid(Routine param, int pageSize = 10, int page = 1)
        {
            BindWBS(param, pageSize, page);
            return PartialView(RoutinePage._LookupWBSGrid);
        }

        private void BindWBS(Routine param, int pageSize = 10, int page = 1)
        {
            ViewData["WBS"] = RoutineRepository.Instance.GetWBS(param, (page * pageSize), (((page - 1) * pageSize) + 1)).ToList();
            ViewData["Paging"] = CountIndex(RoutineRepository.Instance.CountWBS(param), pageSize, page);
            ViewData["FUNC"] = "getWBSGrid";
        }

        public ActionResult getVendor(Routine param, int pageSize = 10, int page = 1)
        {
            BindVendor(param, pageSize, page);
            return PartialView(RoutinePage._LookupVendor);
        }

        public ActionResult getVendorGrid(Routine param, int pageSize = 10, int page = 1)
        {
            BindVendor(param, pageSize, page);
            return PartialView(RoutinePage._LookupVendorGrid);
        }

        private void BindVendor(Routine param, int pageSize = 10, int page = 1)
        {
            if (String.IsNullOrEmpty(param.VENDOR_PARAM)) param.VENDOR_PARAM = "";

            ViewData["Vendor"] = VendorRepository.Instance.GetListData(param.VENDOR_PARAM, "", "", "", "", (((page - 1) * pageSize) + 1), (page * pageSize));
            ViewData["Paging"] = CountIndex(VendorRepository.Instance.CountData(param.VENDOR_PARAM, "", "", "", ""), pageSize, page);
            ViewData["FUNC"] = "getVendorGrid";
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
        #endregion

        #region ROUTINE CREATION INITIALIZE
        public string GetRoutineNo(string ROUTINE_NO)
        {
            string message = "";
            try
            {
                Tuple<Int64, string> newcreation = RoutineRepository.Instance.CreationInit(this.GetCurrentUsername(), ROUTINE_NO, this.GetCurrentRegistrationNumber(), this.GetCurrentUserFullName());
                Session["ProcessID"] = newcreation.Item1;
                Session["RoutineNo"] = ROUTINE_NO;
                Session["Username"] = this.GetCurrentUsername();

                if ((newcreation.Item2 != "") && (newcreation.Item2 != null))
                    throw new Exception(newcreation.Item2);
            }
            catch (Exception e)
            {
                message = e.Message;
            }
            return message;
        }

        public void CreateRoutine()
        {
            string message = "";
            try
            {
                bool exist = Session["ProcessID"] != null;
                if (!exist)
                    message = GetRoutineNo("0");
                else
                {
                    if (Session["Username"].ToString() != this.GetCurrentUsername())
                        message = GetRoutineNo("0");
                }

                if ((message != null) && (message != ""))
                    throw new Exception(message);

                string ROUTINE_NO = Session["RoutineNo"].ToString();
                Int64 PROCESS_ID = Convert.ToInt64(Session["ProcessID"]);

                Tuple<Routine, Routine, List<Routine>, string> RoutineData = GetRoutineData(PROCESS_ID, ROUTINE_NO);
                ViewData["ITEM_TEMP_DATA"] = RoutineData.Item3.ToList();
                ViewData["ROUTINE_H_TEMP_DATA"] = new Tuple<Routine, Routine, string, Int64>(RoutineData.Item1, RoutineData.Item2, ROUTINE_NO, PROCESS_ID);
                if ((RoutineData.Item4 != null) && (RoutineData.Item4 != ""))
                    throw new Exception(RoutineData.Item4);

                GetSlocbyPlant(RoutineData.Item2 != null ? RoutineData.Item2.PLANT_CD : "");
            }
            catch (Exception e)
            {
                ViewData["Message"] = e.Message;
            }
        }

        private Tuple<Routine, Routine, List<Routine>, string> GetRoutineData(Int64 PROCESS_ID, string ROUTINE_NO)
        {
            string message = "";
            Routine userdescription = new Routine();
            Routine RoutineHData = new Routine();
            List<Routine> ItemTempData = new List<Routine>();

            try
            {
                userdescription = RoutineRepository.Instance.GetUserDescription(this.GetCurrentRegistrationNumber());
                if ((userdescription.MESSAGE != null) && (userdescription.MESSAGE != ""))
                    throw new Exception(userdescription.MESSAGE);

                RoutineHData = RoutineRepository.Instance.GetTempRoutineH(ROUTINE_NO);

                if (RoutineHData == null)
                    RoutineHData = new Routine();

                if ((RoutineHData.MESSAGE == null) || (RoutineHData.MESSAGE == ""))
                {
                    RoutineHData.PR_DESC = String.IsNullOrEmpty(RoutineHData.PR_DESC) ? "" : RoutineHData.PR_DESC;
                    RoutineHData.PR_COORDINATOR = String.IsNullOrEmpty(RoutineHData.PR_COORDINATOR) ? "" : RoutineHData.PR_COORDINATOR;
                    RoutineHData.PLANT_CD = String.IsNullOrEmpty(RoutineHData.PLANT_CD) ? "" : RoutineHData.PLANT_CD;
                    RoutineHData.SLOC_CD = String.IsNullOrEmpty(RoutineHData.SLOC_CD) ? "" : RoutineHData.SLOC_CD;
                    RoutineHData.DIVISION_ID = String.IsNullOrEmpty(RoutineHData.DIVISION_ID.ToString()) || RoutineHData.DIVISION_ID == 0 ? userdescription.DIVISION_ID : RoutineHData.DIVISION_ID;
                    RoutineHData.SCH_TYPE = String.IsNullOrEmpty(RoutineHData.SCH_TYPE) ? "" : RoutineHData.SCH_TYPE;
                    //schedule month & day? 
                }

                if ((RoutineHData != null) && (RoutineHData.MESSAGE != null) && (RoutineHData.MESSAGE != ""))
                    throw new Exception(RoutineHData.MESSAGE);

                ItemTempData = RoutineRepository.Instance.GetTempItem(PROCESS_ID);
            }
            catch (Exception e)
            {
                message = e.Message;
            }

            return new Tuple<Routine, Routine, List<Routine>, string>
                (userdescription, RoutineHData, ItemTempData, message);
        }

        public void DeleteAllTempData(string PROCESS_ID)
        {
            PRCreationRepository.Instance.DeleteAllTempData(PROCESS_ID);
        }
        #endregion

        #region SAVING ROUTINE
        public string SaveRoutine(Routine param)
        {
            Tuple<string, string> result = new Tuple<string, string>("SUCCESS", "");

            if (result.Item1 == "SUCCESS")
                //TO DO: Validation
                //result = PRCreationRepository.Instance.SavingPRValidation(param);

            if (result.Item1 == "SUCCESS")
                result = SaveProcessing(param, this.GetCurrentUsername(), this.GetCurrentRegistrationNumber());

            switch (result.Item1)
            {
                case "SUCCESS":
                    {
                        Session["ProcessID"] = null;
                        Session["RoutineNo"] = null;
                        return "SUCCESS|" + param.ROUTINE_NO;
                    }
                case "FAILED":
                    {
                        Routine ErrorLog = RoutineRepository.Instance.GetErrorLog(Convert.ToInt64(param.PROCESS_ID));
                        return "<p>There is Error while Saving Data : </p>" +
                                              "<p>Process ID : <a href='#'>" + param.PROCESS_ID + "</a></p>" +
                                              "<p>Location : " + ErrorLog.LOCATION + "</p>" +
                                              "<p>Message : " + ErrorLog.MESSAGE_CONTENT + "</p>";
                    }
                case "WARNING":
                    {
                        Session["ProcessID"] = null;
                        Session["RoutineNo"] = null;
                        return "WARNING|" + param.ROUTINE_NO + "|" + result.Item2;
                    }
                default:
                    {
                        if (result.Item2 == "") 
                            return result.Item1;
                        else
                            return result.Item2;
                    }
            }
        }

        public Tuple<string, string> SaveProcessing(Routine param, string username, string noreg)
        {
            Tuple<string, string, int> result = new Tuple<string, string, int>("SUCCESS", "", 0);

            if (result.Item1 == "SUCCESS" && ((Session["RoutineNo"] == null ? "0" : Session["RoutineNo"].ToString()) == "0"))
            {
                result = RoutineRepository.Instance.GenerateRoutineNumber(param.PROCESS_ID.ToString(), username);
                Session["RoutineNo"] = result.Item2;
            }

            if (result.Item1 == "SUCCESS")
            {
                param.ROUTINE_NO = Session["RoutineNo"].ToString();

                switch (param.SCH_TYPE) {
                    case "D":
                    {
                        param.SCH_TYPE_DESC = "Daily";
                        param.SCH_VALUE = "";
                        break;
                    }
                    case "W": 
                        {
                        param.SCH_TYPE_DESC = "Weekly";
                        param.SCH_VALUE = param.SCH_DAY.Length == 1 ? "0" + param.SCH_DAY : param.SCH_DAY;
                        break;
                    }
                    case "M":
                    {
                        param.SCH_TYPE_DESC = "Monthly";
                        param.SCH_VALUE = param.SCH_DAY.Length == 1 ? "0" + param.SCH_DAY : param.SCH_DAY;
                        break;
                    }
                    case "Y":
                    {
                        param.SCH_TYPE_DESC = "Yearly";
                        param.SCH_VALUE = (param.SCH_DAY.Length == 1 ? "0" + param.SCH_DAY : param.SCH_DAY) + "." + (param.SCH_MONTH.Length == 1 ? "0" + param.SCH_MONTH : param.SCH_MONTH);
                        break;
                    }
                }

                result = RoutineRepository.Instance.SavingProcessing(param, username, noreg);
            }

            return new Tuple<string,string>(result.Item1, result.Item2);
        }

        public string CancelCreation(string PROCESS_ID)
        {
            string result = "";
            try
            {
                result = RoutineRepository.Instance.DeleteTempbyUser(PROCESS_ID);
                if (result == "SUCCESS")
                {
                    Session["ProcessID"] = null;
                    Session["RoutineNo"] = null;
                }
                else
                    throw new Exception(result);
            }
            catch (Exception e)
            {
                result = e.Message;
            }
            return result;
        }
        #endregion

        #region Item Temp Data Management
        public string SaveItem(Routine param)
        {
            string result = "SUCCESS";
            try
            {
                if (param.ITEM_CLASS == "S")
                {
                    param.ITEM_CLASS_DESC = "Service";
                }
                else if (param.ITEM_CLASS == "M")
                {
                    param.ITEM_CLASS_DESC = "Material";
                }

                if (param.ITEM_NO == "0")
                    param.ITEM_NO = RoutineRepository.Instance.GetLatestSeqItem(param.PROCESS_ID.ToString());

                result = RoutineRepository.Instance.InsertTempItem(param, this.GetCurrentUsername());
            }
            catch (Exception e) 
            {
                result = e.Message;
            }
            return result;
        }

        public ActionResult GetItemTempData(string PROCESS_ID)
        {
            try
            {
                List<Routine> ITEM_TEMP_DATA = RoutineRepository.Instance.GetTempItem(Int64.Parse(PROCESS_ID));
                ViewData["ITEM_TEMP_DATA"] = ITEM_TEMP_DATA;
                return PartialView(RoutinePage._ItemGrid);
            }
            catch (Exception e) {
                return Json(new Routine() { PROCESS_STATUS = "ERR", MESSAGE_CONTENT = e.Message });
            } 
        }

        public string DeleteItem(string ITEM_NO, string PROCESS_ID)
        {
            string result = RoutineRepository.Instance.DeleteItem(PROCESS_ID, ITEM_NO); 
            return result;
        }
        #endregion

        #region Sub Item Temp Data Management
        public string SaveSubItem(Routine param)
        {
            string result = "";
            try
            {
                if (param.SUBITEM_NO == "0")
                    param.SUBITEM_NO = RoutineRepository.Instance.GetLatestSeqSubItem(param.PROCESS_ID.ToString(), param.ITEM_NO);

                result = RoutineRepository.Instance.InsertTempSubItem(param, this.GetCurrentUsername());
            }
            catch (Exception e)
            {
                result = e.Message;
            }
            return result;
        }

        public ActionResult GetSubItemTempData(string PROCESS_ID, string ITEM_NO, string type, string addeditflag)
        {
            try
            {
                List<Routine> SUB_ITEM_TEMP_DATA = RoutineRepository.Instance.GetTempSubItem(Int64.Parse(PROCESS_ID), ITEM_NO);
                ViewData["SUB_ITEM"] = SUB_ITEM_TEMP_DATA;
                ViewData["ITEM_NO"] = ITEM_NO;
                ViewData["ADDEDIT_FLAG"] = addeditflag;
                ViewData["UOM"] = UnitOfMeasureRepository.Instance.GetAllData();
                
                if (type == "init") return PartialView(RoutinePage._SubItem);
                else return PartialView(RoutinePage._SubItemGrid);

            }
            catch (Exception e)
            {
                return Json(new Routine() { PROCESS_STATUS = "ERR", MESSAGE_CONTENT = e.Message });
            }
        }

        public string DeleteSelectedSubItemTemp(string PROCESS_ID, string ITEM_NO, string SUBITEM_NO)
        {
            return RoutineRepository.Instance.DeleteSelectedTempSubItem(PROCESS_ID, ITEM_NO, SUBITEM_NO);
        }
        #endregion

    }
}
