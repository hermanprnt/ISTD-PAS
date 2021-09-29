using System;
using System.Collections.Generic;
using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Constants;
using GPS.Core;
using GPS.Core.ViewModel;
using GPS.Models.Common;
using GPS.Models.MRP;
using GPS.ViewModels.SA;
using Toyota.Common.Web.Platform;

namespace GPS.Controllers.SA
{
    public class SACreationController : PageController
    {
        //
        // GET: /SACreation/

        public SACreationController()
        {
            Settings.Title = "SA Input Screen";

            ViewData["info"] = "";
            ViewData["PONumber"] = "";
            ViewData["PODesc"] = "";
            ViewData["Vendor"] = "";
            ViewData["Month"] = "";
            ViewData["Purchase"] = "";
            ViewData["Currency"] = "";
            ViewData["Amount"] = "";

            var processIdRepo = new ProcessIdRepository();
            ViewBag.ProcessId = processIdRepo.GetNewProcessId(ModuleId.Receiving, FunctionId.SAInput, "Initial");
        }

        protected override void Startup()
        {
        }

        [HttpPost]
        public ActionResult getSubItem(String poNo, String poItemNo, String dataName)
        {
            ViewData["ListSubItem"] = SACreationRepository.Instance.GetPOSubItem(poNo, poItemNo, dataName);
            return PartialView("_SubItem");
        }

        /*public ActionResult SearchSubItem(string PO, string PO_ITEM_NO)
        {
            try
            {
                var viewModel = new GenericViewModel<SACreation>();
                viewModel.DataList = SACreationRepository.Instance.GetPOSubItem(PO,PO_ITEM_NO).ToList();

                return PartialView("SACreation / _purchaseOrderSubItemGrid", viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }*/

        [HttpPost]
        public ActionResult Submit(SASubmitViewModel viewModel)
        {
            try
            {
                var execModel = new ExecProcedureModel();
                execModel.CurrentUser = this.GetCurrentUsername();
                execModel.ModuleId = ModuleId.Receiving;
                execModel.FunctionId = FunctionId.SAInput;
                execModel.ProcessId = viewModel.ProcessId;

                String submitResult = SACreationRepository.Instance.Submit(execModel, viewModel);
                if (submitResult.Substring(0,2) == "E|")
                {
                    return Json(new ActionResponseViewModel { ResponseType = ActionResponseViewModel.Error, Message = submitResult });
                }
                else
                {
                    return Json(new ActionResponseViewModel { ResponseType = ActionResponseViewModel.Success, Message = submitResult });
                }

               
               
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        public ActionResult checkPO(string PO, string REFF)
        {
            bool s = true, r = true; string a = "";
            List<SACreation> data = new List<SACreation>();
            string message = "";
            a = SACreationRepository.Instance.CheckPO(PO, REFF);
            if (a == "4" || a == "6" || a == "5" || a == "7")
            {
                if (a == "4" || a == "6")
                {
                    var result = Models.PO.POCommonRepository.Instance.PoReceivingValidation(this.GetCurrentUsername(), this.GetCurrentUser().RegistrationNumber, PO, REFF);
                    if (result.ResponseType == ActionResponseViewModel.Error)
                    {
                        message =  result.Message.Substring(1, result.Message.Length-1) ;
                        return Json("c" + "+" + message, JsonRequestBehavior.AllowGet);
                    }
                }
                if (a == "6")
                {
                    PO = SACreationRepository.Instance.GetDataREFF(REFF);
                }
                if (a == "7")
                {
                    //var result = Models.PO.POCommonRepository.Instance.PoReceivingValidation(this.GetCurrentUsername(), this.GetCurrentUser().RegistrationNumber, PO, REFF);
                    message = "PO NO :" + PO + ", has expired. Please check your PO NO again";
                    List<SACreation> ListData = SACreationRepository.Instance.GetDataPO(PO);
                    foreach (SACreation li in ListData)
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
                    //ViewData["DetailList"] = SACreationRepository.Instance.GetDetailData(PO);
                    ViewData["ListItem"] = SACreationRepository.Instance.GetPOItem(PO);
                    s = true;
                    r = true;
                    return PartialView("_POData");
                }
                //Add By Bayu Jonatan 13-03-2020

                if (a == "5")
                {
                    r = false;
                    message = REFF;
                }
                else
                {
                    List<SACreation> ListData = SACreationRepository.Instance.GetDataPO(PO);
                    foreach (SACreation li in ListData)
                    {
                        //DateTime tempmonth = new DateTime(2015, int.Parse(li.MONTH.Substring(li.MONTH.Length - 2, 2)), 1);
                        //li.MONTH = tempmonth.ToString("MMMM") + " " + li.MONTH.Substring(0, 4);

                        ViewData["info"] = "";
                        ViewData["PONumber"] = li.PO_NO;
                        ViewData["PODesc"] = li.PO_DESC;
                        ViewData["Vendor"] = li.VENDOR;
                        ViewData["Month"] = li.MONTH;
                        ViewData["Purchase"] = li.PURCHASE_GROUP;
                        ViewData["Currency"] = li.PO_CURR;
                        ViewData["Amount"] = li.PO_AMOUNT;
                    }
                    //ViewData["DetailList"] = SACreationRepository.Instance.GetDetailData(PO);
                    ViewData["ListItem"] = SACreationRepository.Instance.GetPOItem(PO);
                    s = true;
                    r = true;
                }
            }
            else
            {
                message = a;
                s = false;
            }

            if (s && r)
            {
                return PartialView("_POData");
            }
            else if (r == false && s)
            {
                return Json("b" + "+" + message, JsonRequestBehavior.AllowGet);
            }
            else
            {
                return Json("a" + "+" + message, JsonRequestBehavior.AllowGet);
            }
        }


        public ActionResult getPObyReff(string REFF)
        {
            ViewData["PObyReff"] = GRCreationRepository.Instance.GetDataPObyReff(REFF);
            return PartialView("_poReffGrid");
        }
    }
}
