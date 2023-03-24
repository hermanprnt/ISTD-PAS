using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;
using System.Web.Script.Serialization;
using GPS.CommonFunc;
using GPS.Constants;
using GPS.Controllers.Master;
using GPS.Core;
using GPS.Core.ViewModel;
using GPS.Models.PO;
using GPS.ViewModels;
using GPS.ViewModels.Lookup;
using GPS.ViewModels.PO;
using Toyota.Common.Web.Platform;

namespace GPS.Controllers.PO
{
    public abstract class POCommonController : PageController
    {
        public sealed class Partial
        {
            public const String CommonCss = "PO/_purchaseOrderCss";
            public const String CommonItemGrid = "PO/_purchaseOrderItemGrid";
            public const String CommonSubItemGrid = "PO/_purchaseOrderSubItemGrid";
            public const String CommonItemConditionGrid = "PO/_purchaseOrderItemConditionGrid";
            public const String CommonSubItemEditor = "PO/_purchaseOrderSubItemEditor";
            public const String CommonSPKForm = "PO/_purchaseOrderSPKForm";
        }

        protected readonly POCommonRepository commonRepo = new POCommonRepository();

        public static SelectList GetPOItemSelectList(IList<PRPOItem> dataList)
        {
            return dataList
                .AsSelectList(
                    data => data.MatNo == String.Empty ? data.MatDesc : data.MatNo + " - " + data.MatDesc,
                    data => data.PONo + ";" + data.POItemNo + ";" + data.SeqItemNo);
        }

        [HttpPost]
        public ActionResult RefreshItemMaterialList(String dropdownId, String poNo, String processId)
        {
            try
            {
                var viewModel = new DropdownListViewModel();
                viewModel.DataName = dropdownId;
                viewModel.DataList = commonRepo
                    .GetItemMaterialList(poNo, processId)
                    .AsSelectList(poitemmat => String.IsNullOrEmpty(poitemmat.MaterialNo)
                        ? poitemmat.MaterialDesc
                        : poitemmat.MaterialNo + " - " + poitemmat.MaterialDesc,
                            poitemmat => poitemmat
                                .AsDelimitedString(
                                    poitemmati => poitemmati.PONo,
                                    poitemmati => poitemmati.POItemNo,
                                    poitemmati => poitemmati.SeqItemNo));

                return PartialView(CommonPage.DropdownList, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult GetPOItemMaterialList(String processId, String poNo, String dropdownId)
        {
            try
            {
                var viewModel = new DropdownListViewModel();
                viewModel.DataName = dropdownId;
                viewModel.DataList = commonRepo
                    .GetItemMaterialList(poNo, processId)
                    .AsSelectList(poitemmat => String.IsNullOrEmpty(poitemmat.MaterialNo)
                        ? poitemmat.MaterialDesc
                        : poitemmat.MaterialNo + " - " + poitemmat.MaterialDesc,
                            poitemmat => poitemmat
                                .AsDelimitedString(
                                    poitemmati => poitemmat.PONo,
                                    poitemmati => poitemmati.POItemNo));

                return PartialView(CommonPage.DropdownList, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult GetPOItemConditionList(String processId, String poNo, String poItemNo, String seqItemNo)
        {
            try
            {
                POItemInfo poItemInfo = commonRepo.GetPOItemInfo(processId, poNo, poItemNo, seqItemNo) ?? new POItemInfo();
                POItemConditionViewModel viewModel = GetNewlyAddedPOItemCondition(processId, poNo, poItemNo, seqItemNo, poItemInfo.ValuationClass, poItemInfo.Qty);

                return PartialView(Partial.CommonItemConditionGrid, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }
        
        protected POItemConditionViewModel GetNewlyAddedPOItemCondition(String processId, String poNo, String poItemNo, String seqItemNo, String valuationClass, Decimal qty)
        {
            var viewModel = new POItemConditionViewModel();
            viewModel.CurrentUser = this.GetCurrentUser();
            viewModel.PONo = poNo;
            viewModel.POItemNo = poItemNo;
            viewModel.SeqItemNo = seqItemNo;
            viewModel.ValuationClass = valuationClass;
            viewModel.Qty = qty;
            viewModel.DataList = commonRepo.GetPOItemConditionList(processId, poNo, poItemNo, seqItemNo);
            viewModel.GridPaging = PaginationViewModel.GetDefault(POCommonRepository.ItemConditionDataName);

            return viewModel;
        }

        public static SelectList GetComponentPriceSelectList(String valuationClass)
        {
            var localRepo = new POCommonRepository();
            return localRepo
                .GetComponentPriceList(valuationClass)
                .AsSelectList(compprice => compprice.CompPriceCode, compprice => compprice.CompPriceCode);
        }

        public static SelectList GetConditionCategorySelectList()
        {
            var localRepo = new POCommonRepository();
            return localRepo
                .GetPOItemConditionCategoryList()
                .AsSelectList(cond => cond.ConditionCategoryName, cond => cond.ConditionCategory);
        }

        [HttpPost]
        public ActionResult GetComponentPriceList(String valuationClass)
        {
            try
            {
                IDictionary<String, ComponentPrice> compPriceList = commonRepo
                    .GetComponentPriceList(valuationClass)
                    .ToDictionary(compprice => compprice.CompPriceCode, compprice => compprice);
                return Json(new ActionResponseViewModel { ResponseType = ActionResponseViewModel.Success, Message = new JavaScriptSerializer().Serialize(compPriceList) });
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        // NOTE: duplicating VendorController Action to avoid Not Authorized message
        [HttpPost]
        public ActionResult OpenVendorLookup(LookupSearchViewModel searchViewModel)
        {
            var controller = new VendorController();
            return controller.OpenVendorLookup(searchViewModel);
        }

        [HttpPost]
        public ActionResult SearchVendorLookup(LookupSearchViewModel searchViewModel)
        {
            var controller = new VendorController();
            return controller.SearchVendorLookup(searchViewModel);
        }

        [HttpPost]
        public ActionResult GetItemAdditionalList(String processId, String poNo, String poItemNo, Int32 seqItemNo)
        {
            try
            {
                POItemAdditionalInfo additionalInfo = commonRepo.GetPOItemAdditionalInfo(processId, poNo, poItemNo, seqItemNo) ?? new POItemAdditionalInfo();
                return Json(new ActionResponseViewModel { Message = new JavaScriptSerializer().Serialize(additionalInfo), ResponseType = ActionResponseViewModel.Success });
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }
    }
}