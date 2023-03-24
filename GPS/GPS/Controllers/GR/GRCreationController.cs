using System;
using System.Collections.Generic;
using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Constants;
using GPS.Core;
using GPS.Core.ViewModel;
using GPS.Models.Common;
using GPS.Models.MRP;
using GPS.ViewModels.GR;
using Toyota.Common.Web.Platform;

namespace GPS.Controllers.GR
{
    public class GRCreationController : PageController
    {
        protected override void Startup()
        {
            Settings.Title = "GR Input Screen";

            ViewData["info"] = "";
            ViewData["PONumber"] = "";
            ViewData["PODesc"] = "";
            ViewData["Vendor"] = "";
            ViewData["Month"] = "";
            ViewData["Purchase"] = "";
            ViewData["Currency"] = "";
            ViewData["Amount"] = "";

            var processIdRepo = new ProcessIdRepository();
            ViewBag.ProcessId = processIdRepo.GetNewProcessId(ModuleId.Receiving, FunctionId.GRInput, "Initial");
        }

        public void Paging(string PO, int Page, int Display)
        {
        }

        public ActionResult getSubItem(string PO, string PO_ITEM_NO)
        {
            ViewData["ListSubItem"] = GRCreationRepository.Instance.GetPOSubItem(PO, PO_ITEM_NO);
            return PartialView("_SubItem");
        }

        [HttpPost]
        public ActionResult Submit(GRSubmitViewModel viewModel)
        {
            try
            {
                var execModel = new ExecProcedureModel();
                execModel.CurrentUser = this.GetCurrentUsername();
                execModel.ModuleId = ModuleId.Receiving;
                execModel.FunctionId = FunctionId.GRInput;
                execModel.ProcessId = viewModel.ProcessId;

                String submitResult = GRCreationRepository.Instance.Submit(execModel, viewModel);

                return Json(new ActionResponseViewModel { ResponseType = ActionResponseViewModel.Success, Message = submitResult });
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        public ActionResult getPObyReff(string REFF)
        {
            ViewData["PObyReff"] = GRCreationRepository.Instance.GetDataPObyReff(REFF);
            return PartialView("_poReffGrid");
        }

        public ActionResult checkPO(string PO,string REFF, string ProcessId)
        {
            bool s = true,r=true; string a="";
            List<GRCreation> data=new List<GRCreation>();
            string message = "";
            ViewBag.ProcessId = ProcessId;
            a=GRCreationRepository.Instance.CheckPO(PO,REFF);
            if (a == "4" || a == "6" || a == "5" || a == "7")
            {
                if(a=="4" || a=="6")
                {
                    var result = Models.PO.POCommonRepository.Instance.PoReceivingValidation(this.GetCurrentUsername(), this.GetCurrentUser().RegistrationNumber, PO, REFF);
                    if (result.ResponseType== ActionResponseViewModel.Error)
                    {
                        message = result.Message.Substring(1, result.Message.Length - 1);
                        return Json("c" + "+" + message, JsonRequestBehavior.AllowGet);
                    }
                }
                if (a=="6")
                {
                    PO = GRCreationRepository.Instance.GetDataREFF(REFF);
                }
                //Add By Bayu Jonatan 12-03-2020
                if (a == "7")
                {
                    //var result = Models.PO.POCommonRepository.Instance.PoReceivingValidation(this.GetCurrentUsername(), this.GetCurrentUser().RegistrationNumber, PO, REFF);
                    message = "PO NO :" + PO + ", has expired. Please check your PO NO again";
                    List<GRCreation> ListData = GRCreationRepository.Instance.GetDataPO(PO);
                    foreach (GRCreation li in ListData)
                    {
                        ViewData["info"] = "expired";
                        ViewData["PONumber"] = li.PO_NO;
                        ViewData["PODesc"] = li.PO_DESC;
                        ViewData["Vendor"] = li.VENDOR;
                        ViewData["Month"] = li.MONTH;
                        ViewData["Purchase"] = li.PURCHASE_GROUP;
                        ViewData["Currency"] = li.PO_CURR;
                        ViewData["Amount"] = li.PO_AMOUNT;
                    }
                    ViewData["DetailList"] = GRCreationRepository.Instance.GetDetailData(PO);
                    ViewData["ListItem"] = GRCreationRepository.Instance.GetPOItem(PO);
                    s = true;
                    r = true;
                    return PartialView("_POData");
                }
                //Add By Bayu Jonatan 12-03-2020
                if (a=="5")
                {
                    r = false;
                    message = REFF;
                }
                else
                {
                    List<GRCreation> ListData = GRCreationRepository.Instance.GetDataPO(PO);
                    foreach (GRCreation li in ListData)
                    {
                        ViewData["info"] = "";
                        ViewData["PONumber"] = li.PO_NO;
                        ViewData["PODesc"] = li.PO_DESC;
                        ViewData["Vendor"] = li.VENDOR;
                        ViewData["Month"] = li.MONTH;
                        ViewData["Purchase"] = li.PURCHASE_GROUP;
                        ViewData["Currency"] =li.PO_CURR;
                        ViewData["Amount"] = li.PO_AMOUNT;
                    }
                    ViewData["DetailList"] = GRCreationRepository.Instance.GetDetailData(PO);
                    ViewData["ListItem"] = GRCreationRepository.Instance.GetPOItem(PO);
                    s = true;
                    r = true;
                }
            }
            else  {
                message = a;
                s = false;
            }

            if (s && r)
            {
                return PartialView("_POData");
            }
            else if (r==false && s)
            {
                return Json("b" + "+" + message, JsonRequestBehavior.AllowGet);
            }
            else
            {
                return Json("a" + "+" + message, JsonRequestBehavior.AllowGet);
            }
        }


    }
}
