using System;
using System.Collections.Generic;
using System.Globalization;
using System.Web;
using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Constants;
using GPS.Constants.PO;
using GPS.Controllers.Master;
using GPS.Core;
using GPS.Core.ViewModel;
using GPS.Models;
using GPS.Models.Common;
using GPS.Models.Master;
using GPS.Models.PO;
using GPS.ViewModels;
using GPS.ViewModels.Lookup;
using GPS.ViewModels.PO;
using NameValueItem = GPS.Models.Common.NameValueItem;
using System.Linq;
using System.IO;
using System.Diagnostics;

namespace GPS.Controllers.PO
{
    // NOTE: inherit from POCommon because POCommon is not registered in SC and won't registered ever :'(
    public class POCreationController : POCommonController
    {
        private const String DefaultTitle = "Purchase Order Creation";
        private const String PONoEditSessionKey = "gps.po.edit.session.pono";
        public const String PONoSaveSessionKey = "gps.po.save.session.pono";

        public new sealed class Partial
        {
            public const String CreationPRItemSearch = "_creationPRItemSearch";
            public const String CreationPRItemGrid = "_creationPRItemGrid";
            public const String CreationIndex = "POCreation";
            public const String VendorLookup = "_vendorLookup";
            public const String VendorLookupGrid = "_vendorLookupGrid";
            public const String ValuationClassLookup = "_valuationClassLookup";
            public const String ValuationClassLookupGrid = "_valuationClassLookupGrid";
            public const String SubItemEditor = "_creationSubItemEditor";
        }

        public sealed class Action
        {
            public const String Index = "/POCreation";
            public const String Edit = "/POCreation/EditEmpty";
            public const String Save = "/POCreation/Save";
            public const String Update = "/POCreation/Update";
            public const String RefreshCurrency = "/POCreation/RefreshCurrency";
            public const String GetExchangeRate = "/POCreation/GetExchangeRate";
            public const String PRItemAdd = "/POCreation/PRItemAdd";
            public const String GetUploadValidationInfo = "/POCreation/GetUploadValidationInfo";
            public const String UploadBidingDocFile = "/POCreation/UploadBidingDocFile";
            public const String UploadQuotationFile = "/POCreation/UploadQuotationFile";
            public const String DeleteFile = "/POCreation/DeleteTempFile";
            public const String PRItemSearch = "/POCreation/PRItemSearch";
            public const String PRItemSearchEmpty = "/POCreation/PRItemSearchEmpty";
            public const String ItemAdopt = "/POCreation/AdoptItem";
            public const String ItemAdd = "/POCreation/AddItem";
            public const String ItemDelete = "/POCreation/DeleteItem";
            public const String ItemUpdate = "/POCreation/UpdateItem";
            public const String ItemCopy = "/POCreation/CopyItem";
            public const String SubItemAdd = "/POCreation/AddSubItem";
            public const String SubItemUpdate = "/POCreation/UpdateSubItem";
            public const String ItemConditionAdd = "/POCreation/POItemConditionAdd";
            public const String ItemConditionDelete = "/POCreation/POItemConditionDelete";
            public const String BackToInquiry = "/POCreation/BackToInquiry";
            public const String CreationTypeChange = "/POCreation/ChangeCreationType";
            public const String RefreshSPKAmount = "/POCreation/RefreshSPKAmount";
            public const String SearchPOSubItem = "/POCreation/SearchPOSubItemTemp";
            public const String SearchPRSubItem = "/POCreation/SearchPRSubItem";
            public const String POSubItemEditorShow = "/POCreation/ShowPOSubItemEditor";
            public const String SourceListCheck = "/POCreation/CheckSourceList";
            public const String POHeaderSilentSave = "/POCreation/SilentSavePOHeader";
            public const String TempDataClear = "/POCreation/ClearTempData";

            public const String OpenValuationClassLookup = "/POCreation/OpenValuationClassLookup";
            public const String SearchValuationClassLookup = "/POCreation/SearchValuationClassLookup";
            public const String OpenMaterialLookup = "/POCreation/OpenMaterialLookup";
            public const String SearchMaterialLookup = "/POCreation/SearchMaterialLookup";
            public const String OpenWBSLookup = "/POCreation/OpenWBSLookup";
            public const String SearchWBSLookup = "/POCreation/SearchWBSLookup";
            public const String OpenGLAccountLookup = "/POCreation/OpenGLAccountLookup";
            public const String SearchGLAccountLookup = "/POCreation/SearchGLAccountLookup";
            public const String OpenCreationVendorLookup = "/POCreation/OpenCreationVendorLookup";
            public const String SearchCreationVendorLookup = "/POCreation/SearchCreationVendorLookup";
            public const String OpenCreationVendorEcatalogueLookup = "/POCreation/OpenCreationVendorEcatalogueLookup";
            public const String SearchCreationVendorEcatalogueLookup = "/POCreation/SearchCreationVendorEcatalogueLookup";

            // NOTE: exist in POCommon
            public const String RefreshItemMaterialList = "/POCreation/RefreshItemMaterialList";
            public const String GetItemConditionList = "/POCreation/GetPOItemConditionList";
            public const String GetItemAdditionalList = "/POCreation/GetItemAdditionalList";
            public const String OpenVendorLookup = "/POCreation/OpenVendorLookup";
            public const String SearchVendorLookup = "/POCreation/SearchVendorLookup";

            //Refresh Attachment
            public const String RefreshAttachment = "/POCreation/RefreshAttachment";
            public const String _ValidateDownloadCreation = "/POCreation/ValidateDownload";

            //Check Existing adopted PR : isid.rgl : 20190627
            public const String CheckExistingAdoptPR = "/POCreation/CheckExistingAdoptPR";
        }

        private readonly POCreationRepository creationRepo = new POCreationRepository();
        private readonly POInquiryRepository inquiryRepo = new POInquiryRepository();

        protected override void Startup()
        {
            Settings.Title = DefaultTitle + " - New";

            var execModel = new ExecProcedureModel();
            execModel.CurrentUser = this.GetCurrentUsername();
            execModel.CurrentUserName = this.GetCurrentUserFullName();
            execModel.ModuleId = ModuleId.PurchaseOrder;
            execModel.FunctionId = FunctionId.POCreation;
           

            String processId = execModel.ProcessId = creationRepo.Initial(execModel, String.Empty);
            var viewModel = new POCreationViewModel();
            viewModel.ProcessId = processId;
            viewModel.CurrentUser = this.GetCurrentUser();
            viewModel.Operation = EditMode.Add;
            viewModel.PRItemDataName = POCommonRepository.PRItemDataName;
            viewModel.POItemDataName = POCommonRepository.POItemDataName;
            viewModel.SubItemDataName = POCommonRepository.SubItemDataName;
            viewModel.Header = creationRepo.GetPOHeaderTemp(processId) ?? new PurchaseOrder();
            viewModel.Header.PurchasingGroup = PurchasingGroupController.GetFirstPurchasingGroup(this.GetCurrentRegistrationNumber());
            viewModel.Header.Currency = String.IsNullOrEmpty(viewModel.Header.Currency) ? CurrencyController.GetDefaultCurrency() : viewModel.Header.Currency;
            viewModel.Header.SPKInfo = viewModel.Header.SPKInfo ?? new POSPKViewModel();
            viewModel.PlantCode = SystemRepository.Instance.GetSingleData("POCR01", "PLANT_LIMIT").Value;
            viewModel.AgreementStatus = SystemRepository.Instance.GetSingleData("AGR001", "AGREEMENT_LIMIT").Value;
            IList<PRPOItem> itemList = creationRepo.GetItemTemp(processId) ?? new List<PRPOItem>();
            var itemViewModel = new PRItemAdoptResultViewModel();
            itemViewModel.CurrentUser = viewModel.CurrentUser;
            itemViewModel.DataList = itemList;
            itemViewModel.GridPaging = PaginationViewModel.GetDefault(POCommonRepository.POItemDataName);
            viewModel.ItemList = itemViewModel;
           

            Model = viewModel;
        }

        [HttpPost]
        public ActionResult RefreshCurrency(String processId, String currency)
        {
            try
            {
                var execModel = new ExecProcedureModel();
                execModel.CurrentUser = this.GetCurrentUsername();
                execModel.ModuleId = ModuleId.PurchaseOrder;
                execModel.FunctionId = FunctionId.POCreation;
                execModel.ProcessId = processId;

                creationRepo.RefreshItemTempCurrency(execModel, currency);
                PRItemAdoptResultViewModel addedItemList = GetNewlyAddedPOItem(processId);

                return PartialView(POCommonController.Partial.CommonItemGrid, addedItemList);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult GetExchangeRate(String currency)
        {
            try
            {
                Currency currentCurrency = CurrencyRepository.Instance.GetCurrency(currency);
                return Json(new ActionResponseViewModel { ResponseType = ActionResponseViewModel.Success, Message = (currentCurrency == null ? Decimal.Zero : currentCurrency.EXCHANGE_RATE).ToString("##.###") });
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult PRItemAdd(String processId, String currency, String purchasingGroup)
        {
            try
            {
                var searchViewModel = new PRItemSearchViewModel();
                searchViewModel.ProcessId = processId;
                searchViewModel.Currency = currency;
                searchViewModel.PurchasingGroup = purchasingGroup;
                searchViewModel.CurrentPage = 1;
                searchViewModel.PageSize = PaginationViewModel.DefaultPageSize;

                var viewModel = new GenericViewModel<PRPOItem>();
                viewModel.CurrentUser = this.GetCurrentUser();
                viewModel.DataList = creationRepo.GetPRItemSearchList(searchViewModel);
                viewModel.GridPaging = creationRepo.GetPRItemSearchListPaging(searchViewModel);

                ViewData["MaxItemAllowed"] = int.Parse(SystemRepository.Instance.GetSingleData("00000", "MAX_PR_ITEM").Value);
                ViewData["ErrMsgMaximumItem"] = MessageRepository.Instance.GetMessageText("ERR00001");
                return PartialView(Partial.CreationPRItemSearch, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult POItemConditionAdd(String processId, String valuationClass, AddPOItemConditionViewModel addViewModel)
        {
            try
            {
                var execModel = new ExecProcedureModel();
                execModel.CurrentUser = this.GetCurrentUsername();
                execModel.ModuleId = ModuleId.PurchaseOrder;
                execModel.FunctionId = FunctionId.POCreation;
                execModel.ProcessId = processId;

                creationRepo.AddPOItemCondition(execModel, addViewModel);
                POItemConditionViewModel viewModel = GetNewlyAddedPOItemCondition(processId, addViewModel.PONo, addViewModel.POItemNo, addViewModel.SeqItemNo, valuationClass, addViewModel.Qty);

                return PartialView(POCommonController.Partial.CommonItemConditionGrid, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult POItemConditionDelete(String processId, DeletePOItemConditionViewModel deleteViewModel)
        {
            try
            {
                var execModel = new ExecProcedureModel();
                execModel.CurrentUser = this.GetCurrentUsername();
                execModel.ModuleId = ModuleId.PurchaseOrder;
                execModel.FunctionId = FunctionId.POCreation;
                execModel.ProcessId = processId;

                POItemInfo poItemInfo = commonRepo.GetPOItemInfo(processId, deleteViewModel.PONo, deleteViewModel.POItemNo, deleteViewModel.SeqItemNo);
                creationRepo.DeletePOItemConditionTemp(execModel, deleteViewModel);
                POItemConditionViewModel viewModel = GetNewlyAddedPOItemCondition(processId, deleteViewModel.PONo, deleteViewModel.POItemNo, deleteViewModel.SeqItemNo, poItemInfo.ValuationClass, poItemInfo.Qty);

                return PartialView(POCommonController.Partial.CommonItemConditionGrid, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult GetUploadValidationInfo()
        {
            try
            {
                UploadValidationInfo info = CommonUploadRepository.Instance.GetDocumentUploadValidationInfo();
                return Json(info);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult UploadBidingDocFile(HttpPostedFileBase uploadedFile, String processId, String poNo)
        {
            try
            {
                var execModel = new ExecProcedureModel();
                execModel.CurrentUser = this.GetCurrentUsername();
                execModel.ModuleId = ModuleId.PurchaseOrder;
                execModel.FunctionId = FunctionId.POCreation;
                execModel.ProcessId = processId;

                string filename = creationRepo.SaveBidingDocFileToTemp(execModel, poNo, uploadedFile.FileName, uploadedFile.InputStream, uploadedFile.ContentLength);
                IList<Attachment> attachmentList = GetAttachmentList(processId, poNo, "BID");
                Int32 sequenceNumber = creationRepo.GetAttachmentSeqNumber(poNo, processId);
                return Json(new ActionResponseViewModel { ResponseType = ActionResponseViewModel.Success, Message = "File " + uploadedFile.FileName + " is uploaded successfully.|" + filename+"|"+ attachmentList.Count + "|" + sequenceNumber });
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult UploadQuotationFile(HttpPostedFileBase uploadedFile, String processId, String poNo)
        {
            try
            {
                var execModel = new ExecProcedureModel();
                execModel.CurrentUser = this.GetCurrentUsername();
                execModel.ModuleId = ModuleId.PurchaseOrder;
                execModel.FunctionId = FunctionId.POCreation;
                execModel.ProcessId = processId;

                string filename = creationRepo.SaveQuotationFileToTemp(execModel, poNo, uploadedFile.FileName, uploadedFile.InputStream, uploadedFile.ContentLength);
                IList<Attachment> attachmentList = GetAttachmentList(processId, poNo, "QUOT");
                var seqNumber = creationRepo.GetAttachmentSeqNumber(poNo, processId);
                return Json(new ActionResponseViewModel { ResponseType = ActionResponseViewModel.Success, Message = "File " + uploadedFile.FileName + " is uploaded successfully.|" + filename + "|" + attachmentList.Count+"|"+ seqNumber });
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        private IList<Attachment> GetAttachmentList(string processId, string poNo, string docType)
        {
            var attachmentList = creationRepo.GetAttachmentList(poNo, processId);
            attachmentList = attachmentList.Where(x => x.DOC_TYPE == docType).ToList();
            return attachmentList;
        }

        #region Get Attachment From PR
        [HttpPost]
        public ActionResult UploadBidingDocFileFromPR(HttpPostedFileBase uploadedFile, String processId, String poNo)
        {
            try
            {
                var execModel = new ExecProcedureModel();
                execModel.CurrentUser = this.GetCurrentUsername();
                execModel.ModuleId = ModuleId.PurchaseOrder;
                execModel.FunctionId = FunctionId.POCreation;
                execModel.ProcessId = processId;

                string filename = creationRepo.SaveBidingDocFileToTemp(execModel, poNo, uploadedFile.FileName, uploadedFile.InputStream, uploadedFile.ContentLength);
                return Json(new ActionResponseViewModel { ResponseType = ActionResponseViewModel.Success, Message = "File " + uploadedFile.FileName + " is uploaded successfully.|" + filename });
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult UploadQuotationFileFromPR(HttpPostedFileBase uploadedFile, String processId, String poNo)
        {
            try
            {
                var execModel = new ExecProcedureModel();
                execModel.CurrentUser = this.GetCurrentUsername();
                execModel.ModuleId = ModuleId.PurchaseOrder;
                execModel.FunctionId = FunctionId.POCreation;
                execModel.ProcessId = processId;

                string filename = creationRepo.SaveQuotationFileToTemp(execModel, poNo, uploadedFile.FileName, uploadedFile.InputStream, uploadedFile.ContentLength);

                return Json(new ActionResponseViewModel { ResponseType = ActionResponseViewModel.Success, Message = "File " + uploadedFile.FileName + " is uploaded successfully.|" + filename });
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }
        #endregion Get Attachment From PR

        [HttpPost]
        public ActionResult DeleteTempFile(string poNo, String processId, String path, string type)
        {
            try
            {
                creationRepo.DeleteFileTemp(processId, path, this.GetCurrentUsername());
                IList<Attachment> attachmentList = GetAttachmentList(processId, (poNo == null ? "":poNo), type.ToUpper());
                return Json(new ActionResponseViewModel { ResponseType = ActionResponseViewModel.Success, Message = "SUC|File deleted successfully.|"+ attachmentList.Count() });
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult PRItemSearchEmpty()
        {
            try
            {
                var viewModel = new GenericViewModel<PRPOItem>();
                viewModel.CurrentUser = this.GetCurrentUser();
                viewModel.DataList = new List<PRPOItem>();
                viewModel.GridPaging = PaginationViewModel.GetDefault(POCommonRepository.PRItemDataName);

                return PartialView(Partial.CreationPRItemGrid, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult PRItemSearch(PRItemSearchViewModel searchViewModel)
        {
            try
            {
                var viewModel = new GenericViewModel<PRPOItem>();
                viewModel.CurrentUser = this.GetCurrentUser();
                viewModel.DataList = creationRepo.GetPRItemSearchList(searchViewModel);
                viewModel.GridPaging = creationRepo.GetPRItemSearchListPaging(searchViewModel);

                return PartialView(Partial.CreationPRItemGrid, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult AdoptItem(POItemAdoptViewModel viewModel)
        {
            try
            {
                var execModel = new ExecProcedureModel();
                execModel.CurrentUser = this.GetCurrentUsername();
                execModel.ModuleId = ModuleId.PurchaseOrder;
                execModel.FunctionId = FunctionId.POCreation;
                execModel.ProcessId = viewModel.ProcessId;

                creationRepo.AdoptItemTemp(execModel, viewModel.PONo, viewModel.Currency, viewModel.PRItemAdoptList);
                creationRepo.CopyAdoptAttachment(execModel, viewModel.PONo, viewModel.Currency, viewModel.PRItemAdoptList);
                PRItemAdoptResultViewModel addedItemList = GetNewlyAddedPOItem(viewModel.ProcessId);

                //add by ISTD) Yanes
                //get file path from PR

                return PartialView(POCommonController.Partial.CommonItemGrid, addedItemList);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult AddItem(POItemAddViewModel viewModel)
        {
            try
            {
                String deliveryDate = (viewModel.DeliveryDateString ?? String.Empty).Trim();
                if (deliveryDate != String.Empty)
                    viewModel.DeliveryDate = deliveryDate.FromStandardFormat();

                var execModel = new ExecProcedureModel();
                execModel.CurrentUser = this.GetCurrentUsername();
                execModel.ModuleId = ModuleId.PurchaseOrder;
                execModel.FunctionId = FunctionId.POCreation;
                execModel.ProcessId = viewModel.ProcessId;

                String poNo, poItemNo, seqItemNo;
                creationRepo.AddItemTemp(execModel, viewModel, out poNo, out poItemNo, out seqItemNo);
                PRItemAdoptResultViewModel addedItemList = GetNewlyAddedPOItem(viewModel.ProcessId);

                return PartialView(POCommonController.Partial.CommonItemGrid, addedItemList);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult AddSubItem(POItemAddViewModel viewModel)
        {
            try
            {
                String deliveryDate = (viewModel.DeliveryDateString ?? String.Empty).Trim();
                if (deliveryDate != String.Empty)
                    viewModel.DeliveryDate = deliveryDate.FromStandardFormat();

                String processId = viewModel.ProcessId;

                var execModel = new ExecProcedureModel();
                execModel.CurrentUser = this.GetCurrentUsername();
                execModel.ModuleId = ModuleId.PurchaseOrder;
                execModel.FunctionId = FunctionId.POCreation;
                execModel.ProcessId = processId;

                String poNo, poItemNo, seqItemNo;
                creationRepo.AddItemTemp(execModel, viewModel, out poNo, out poItemNo, out seqItemNo);
                var subItemSearch = new PRPOSubItemSearchViewModel
                {
                    ProcessId = processId,
                    PONo = poNo,
                    POItemNo = poItemNo,
                    SeqItemNo = seqItemNo,
                    DataName = POCommonRepository.POItemDataName,
                    CurrentPage = 1,
                    PageSize = 10
                };

                return SearchPOSubItemTemp(subItemSearch);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult UpdateSubItem(POSubItemUpdateViewModel viewModel)
        {
            string prc = null;
            string hrg = null;
            //
            hrg = viewModel.PriceStr;
            prc = hrg.Replace(",", "");		

            try
            {
                viewModel.CurrentUser = this.GetCurrentUsername();
                viewModel.ModuleId = ModuleId.PurchaseOrder;
                viewModel.FunctionId = FunctionId.POCreation;
                viewModel.PricePerUOM = Convert.ToDecimal(prc);
                viewModel.Qty = Convert.ToDecimal(viewModel.QtyStr);

                creationRepo.UpdateSubItemTemp(viewModel);
                var subItemSearch = new PRPOSubItemSearchViewModel
                {
                    ProcessId = viewModel.ProcessId,
                    PONo = viewModel.PONo,
                    POItemNo = viewModel.POItemNo,
                    SeqItemNo = viewModel.SeqItemNo,
                    DataName = POCommonRepository.POItemDataName,
                    CurrentPage = 1,
                    PageSize = 10
                };

                return SearchPOSubItemTemp(subItemSearch);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult CopyItem(String processId, String poNo, String poItemNo, Int32 seqItemNo)
        {
            try
            {
                var execModel = new ExecProcedureModel();
                execModel.CurrentUser = this.GetCurrentUsername();
                execModel.ModuleId = ModuleId.PurchaseOrder;
                execModel.FunctionId = FunctionId.POCreation;
                execModel.ProcessId = processId;

                creationRepo.CopyItemTemp(execModel, poNo, poItemNo, seqItemNo);
                PRItemAdoptResultViewModel addedItemList = GetNewlyAddedPOItem(processId);

                return PartialView(POCommonController.Partial.CommonItemGrid, addedItemList);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        private PRItemAdoptResultViewModel GetNewlyAddedPOItem(String processId)
        {
            var addedItemList = new PRItemAdoptResultViewModel();
            addedItemList.CurrentUser = this.GetCurrentUser();
            addedItemList.DataList = creationRepo.GetItemTemp(processId);
            addedItemList.GridPaging = PaginationViewModel.GetDefault(POCommonRepository.POItemDataName);

            return addedItemList;
        }

        // NOTE: <ActionName>Empty could means 2 action.
        // 1. action returning partial with empty data.
        // 2. action with empty logic, like redirecting to other page.
        [HttpPost]
        public ActionResult EditEmpty(String poNo)
        {
            try
            {
                creationRepo.ValidateEdit(poNo, this.GetCurrentUsername(), this.GetCurrentRegistrationNumber());

                Session.Add(PONoEditSessionKey, poNo);
                return Json(new ActionResponseViewModel { ResponseType = ActionResponseViewModel.Success, Message = Url.Action("Edit", "POCreation") });
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        public ActionResult Edit()
        {
            try
            {
                if (Session[PONoEditSessionKey] != null)
                {
                    String poNo = Session[PONoEditSessionKey].ToString();
                    Session.Remove(PONoEditSessionKey);

                    Settings.Title = DefaultTitle + " - " + poNo;
                    IndexIgnoreStartup();

                    var execModel = new ExecProcedureModel();
                    execModel.CurrentUser = this.GetCurrentUsername();
                    execModel.CurrentUserName = this.GetCurrentUserFullName();
                    execModel.ModuleId = ModuleId.PurchaseOrder;
                    execModel.FunctionId = FunctionId.POCreation;

                    string messageResult = inquiryRepo.UnlockPO(poNo, execModel.CurrentUser);
                    if(!string.IsNullOrEmpty(messageResult) && messageResult != "SUCCESS")
                    {
                        throw new Exception(messageResult.Replace("unlock", "edit").Replace(", please", ", the document is being locked by other, please"));
                    }
                    String processId = execModel.ProcessId = creationRepo.Initial(execModel, poNo);

                    var viewModel = new POCreationViewModel();
                    viewModel.CurrentUser = this.GetCurrentUser();
                    viewModel.ProcessId = processId;
                    viewModel.Operation = EditMode.Edit;
                    viewModel.PRItemDataName = POCommonRepository.PRItemDataName;
                    viewModel.POItemDataName = POCommonRepository.POItemDataName;
                    viewModel.SubItemDataName = POCommonRepository.SubItemDataName;
                    
					//start : 20190716 : isid.rgl
                    //viewModel.Header = inquiryRepo.GetByNo(poNo);
                    viewModel.Header = inquiryRepo.GetByNo(poNo, this.GetCurrentRegistrationNumber());
                    //end : 20190716 : isid.rgl
					
                    var listAttachment = creationRepo.GetAttachmentList(poNo, processId);
                    viewModel.Header.BidFileList = listAttachment.Where(x => x.DOC_TYPE == "BID").ToList();
                    viewModel.Header.QuotFileList = listAttachment.Where(x => x.DOC_TYPE == "QUOT").ToList();
                    viewModel.Header.SPKInfo = creationRepo.GetSPKInfo(poNo);

                    var itemList = new PRItemAdoptResultViewModel();
                    itemList.CurrentUser = this.GetCurrentUser();
                    itemList.DataList = creationRepo.GetItemTemp(processId);
                    itemList.GridPaging = PaginationViewModel.GetDefault(POCommonRepository.POItemDataName);
                    viewModel.ItemList = itemList;

                    return View(Partial.CreationIndex, viewModel);
                }

                return RedirectToAction("Index");
            }
            catch (Exception ex)
            {
                POCreationViewModel viewModel = GenerateModelForErrorPurpose();

                ViewData["ERROR_EXCEPTION"] = "E|" + ex.Message;
                return View(Partial.CreationIndex, viewModel);
                //return Json(ex.AsActionResponseViewModel(), JsonRequestBehavior.AllowGet);
            }
        }

        private POCreationViewModel GenerateModelForErrorPurpose()
        {
            var execModel = new ExecProcedureModel();
            execModel.CurrentUser = this.GetCurrentUsername();
            execModel.CurrentUserName = this.GetCurrentUserFullName();
            execModel.ModuleId = ModuleId.PurchaseOrder;
            execModel.FunctionId = FunctionId.POCreation;

            String processId = "00000000000";
            var viewModel = new POCreationViewModel();
            viewModel.ProcessId = processId;
            viewModel.CurrentUser = this.GetCurrentUser();
            viewModel.Operation = EditMode.Add;
            viewModel.PRItemDataName = POCommonRepository.PRItemDataName;
            viewModel.POItemDataName = POCommonRepository.POItemDataName;
            viewModel.SubItemDataName = POCommonRepository.SubItemDataName;
            viewModel.Header = new PurchaseOrder();
            viewModel.Header.Currency = CurrencyController.GetDefaultCurrency();
            viewModel.Header.SPKInfo = new POSPKViewModel();
            var itemList = new PRItemAdoptResultViewModel();
            itemList.CurrentUser = this.GetCurrentUser();
            itemList.DataList = creationRepo.GetItemTemp(processId);
            itemList.GridPaging = PaginationViewModel.GetDefault(POCommonRepository.POItemDataName);
            viewModel.ItemList = itemList;
            return viewModel;
        }

        [HttpPost]
        public ActionResult DeleteItem(POItemDeleteViewModel viewModel)
        {
            try
            {
                viewModel.CurrentUser = this.GetCurrentUsername();
                viewModel.ModuleId = ModuleId.PurchaseOrder;
                viewModel.FunctionId = FunctionId.POCreation;

                creationRepo.DeleteItemTemp(viewModel);
                PRItemAdoptResultViewModel addedItemList = GetNewlyAddedPOItem(viewModel.ProcessId);

                return PartialView(POCommonController.Partial.CommonItemGrid, addedItemList);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult UpdateItem(POItemUpdateViewModel viewModel)
        {
			string prc = null;
            string hrg = null;
            //
            hrg = viewModel.PriceStr;
            prc = hrg.Replace(",", "");				  
            try
            {
                viewModel.CurrentUser = this.GetCurrentUsername();
                viewModel.ModuleId = ModuleId.PurchaseOrder;
                viewModel.FunctionId = FunctionId.POCreation;
				viewModel.PricePerUOM = Convert.ToDecimal(prc);
                viewModel.Qty = Convert.ToDecimal(viewModel.QtyStr);
				
                creationRepo.UpdateItemTemp(viewModel);
                PRItemAdoptResultViewModel addedItemList = GetNewlyAddedPOItem(viewModel.ProcessId);

                return PartialView(POCommonController.Partial.CommonItemGrid, addedItemList);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult SearchPOSubItemTemp(PRPOSubItemSearchViewModel searchViewModel)
        {
            try
            {
                var viewModel = new GenericViewModel<PRPOSubItem>();
                viewModel.CurrentUser = this.GetCurrentUser();
                viewModel.DataList = creationRepo.GetSubItemTemp(searchViewModel);
                viewModel.GridPaging = new PaginationViewModel {DataName = searchViewModel.DataName};

                return PartialView(POCommonController.Partial.CommonSubItemGrid, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult ShowPOSubItemEditor(POSubItemEditorShowViewModel showViewModel)
        {
            try
            {
                var viewModel = new POSubItemEditorViewModel();
                viewModel.CurrentUser = this.GetCurrentUser();
                viewModel.DataList = new List<PRPOSubItem>();
                viewModel.DataNo = showViewModel.DataNo;
                viewModel.GridPaging = new PaginationViewModel { DataName = showViewModel.DataName };

                return PartialView(Partial.SubItemEditor, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult SearchPRSubItem(PRPOSubItemSearchViewModel searchViewModel)
        {
            try
            {
                var viewModel = new GenericViewModel<PRPOSubItem>();
                viewModel.CurrentUser = this.GetCurrentUser();
                viewModel.DataList = creationRepo.GetPRSubItemSearchList(searchViewModel);
                viewModel.GridPaging = new PaginationViewModel { DataName = searchViewModel.DataName };

                return PartialView(POCommonController.Partial.CommonSubItemGrid, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult Save(PurchaseOrderSaveViewModel viewModel)
        {
            try
            {
                var execModel = new ExecProcedureModel();
                execModel.CurrentUser = this.GetCurrentUsername();
                execModel.CurrentRegNo = this.GetCurrentRegistrationNumber();
                execModel.ModuleId = ModuleId.PurchaseOrder;
                execModel.FunctionId = FunctionId.POCreation;
                execModel.ProcessId = viewModel.ProcessId;

                // add by fid.ahmad 27-02-2023 handle issue vendor code was not filtered by purchasing group 
                POSaveResult resultChecking = creationRepo.PlantCodeChecking(execModel, viewModel);

                //add by ark.herman 23.06.2023 check if master due dilligence and master agreement already registered
                var validation = viewModel.Vendor;


                POSaveResult result = creationRepo.SaveData(execModel, viewModel);
                creationRepo.MoveTempAttachmentToRealPath(viewModel.ProcessId, result.PONo, result.DocYear);
                Session.Add(PONoSaveSessionKey, result.PONo);

                return Json(new ActionResponseViewModel { ResponseType = ActionResponseViewModel.Success, Message = "PO " + result.PONo + (viewModel.PONo != String.Empty ? " is created." : " is saved.") });
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        public static SelectList CreationTypeSelectList
        {
            get
            {
                var creationTypeList = new List<NameValueItem>();
                creationTypeList.Add(new NameValueItem("Manual PO", POCreationType.Manual));
                creationTypeList.Add(new NameValueItem("Standard PO", POCreationType.Standard));

                return creationTypeList.AsSelectList(item => item.Name, item => item.Value);
            }
        }

        [HttpPost]
        public ActionResult ChangeCreationType(String processId, String creationType)
        {
            try
            {
                var execModel = new ExecProcedureModel();
                execModel.CurrentUser = this.GetCurrentUsername();
                execModel.CurrentRegNo = this.GetCurrentRegistrationNumber();
                execModel.ModuleId = ModuleId.PurchaseOrder;
                execModel.FunctionId = FunctionId.POCreation;
                execModel.ProcessId = processId;

                creationRepo.ResetItemTemp(execModel);
                PRItemAdoptResultViewModel addedItemList = GetNewlyAddedPOItem(processId);

                return PartialView(POCommonController.Partial.CommonItemGrid, addedItemList);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult OpenValuationClassLookup(ValuationClassLookupSearchViewModel searchViewModel)
        {
            try
            {
                var viewModel = new LookupViewModel<ValuationClassLookupViewModel>();
                viewModel.Title = "Valuation Class";
                viewModel.DataList = creationRepo.GetValuationClassLookupList(searchViewModel);
                viewModel.GridPaging = creationRepo.GetValuationClassLookupListPaging(searchViewModel);

                return PartialView(Partial.ValuationClassLookup, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult SearchValuationClassLookup(ValuationClassLookupSearchViewModel searchViewModel)
        {
            try
            {
                var viewModel = new LookupViewModel<ValuationClassLookupViewModel>();
                viewModel.Title = "Valuation Class";
                viewModel.DataList = creationRepo.GetValuationClassLookupList(searchViewModel);
                viewModel.GridPaging = creationRepo.GetValuationClassLookupListPaging(searchViewModel);

                return PartialView(Partial.ValuationClassLookupGrid, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        // NOTE: duplicating MaterialLookup Action to avoid Not Authorized message
        [HttpPost]
        public ActionResult OpenMaterialLookup(MaterialLookupSearchViewModel searchViewModel)
        {
            var controller = new MaterialController();
            return controller.OpenMaterialLookup(searchViewModel);
        }

        [HttpPost]
        public ActionResult SearchMaterialLookup(MaterialLookupSearchViewModel searchViewModel)
        {
            var controller = new MaterialController();
            return controller.SearchMaterialLookup(searchViewModel);
        }

        // NOTE: duplicating UnitOfMeasureController Action to avoid Not Authorized message
        public static SelectList UOMSelectList
        {
            get { return UnitOfMeasureController.UOMSelectList; }
        }

        public static SelectList CountrySelectList
        {
            get { return CountryController.CountrySelectList; }
        }

        [HttpPost]
        public ActionResult OpenWBSLookup(WBSLookupSearchViewModel searchViewModel)
        {
            try
            {
                searchViewModel.CurrentUserRegNo = this.GetCurrentRegistrationNumber();
                LookupViewModel<NameValueItem> viewModel = GetWBSLookupViewModel(searchViewModel);
                return PartialView(LookupPage.GenericLookup, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult SearchWBSLookup(WBSLookupSearchViewModel searchViewModel)
        {
            try
            {
                searchViewModel.CurrentUserRegNo = this.GetCurrentRegistrationNumber();
                LookupViewModel<NameValueItem> viewModel = GetWBSLookupViewModel(searchViewModel);
                return PartialView(LookupPage.GenericLookupGrid, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        private LookupViewModel<NameValueItem> GetWBSLookupViewModel(WBSLookupSearchViewModel searchViewModel)
        {
            var viewModel = new LookupViewModel<NameValueItem>();
            viewModel.Title = "WBS";
            viewModel.DataList = creationRepo.GetWBSLookupList(searchViewModel);
            viewModel.GridPaging = creationRepo.GetWBSLookupListPaging(searchViewModel);

            return viewModel;
        }

        [HttpPost]
        public ActionResult OpenGLAccountLookup(GLAccountLookupSearchViewModel searchViewModel)
        {
            var controller = new GLAccountController();
            return controller.OpenGLAccountLookup(searchViewModel);
        }

        [HttpPost]
        public ActionResult SearchGLAccountLookup(GLAccountLookupSearchViewModel searchViewModel)
        {
            var controller = new GLAccountController();
            return controller.SearchGLAccountLookup(searchViewModel);
        }

        public static SelectList GetCostCenterSelectList(String currentRegNo)
        {
            return CostCenterController.GetCostCenterSelectList(currentRegNo);
        }
        #region added : 20190614 : isid.rgl
        public static SelectList GetCostCenterSelectListAll()
        {
            return CostCenterController.GetCostCenterSelectListAll();
        }

        #endregion

        [HttpPost]
        public ActionResult OpenCreationVendorLookup(LookupSearchViewModel searchViewModel)
        {
            try
            {
                var viewModel = new CreationVendorLookupViewModel();
                viewModel.Title = "Vendor";
                viewModel.DataList = VendorRepository.Instance.GetVendorLookupSearchListPO(searchViewModel);
                viewModel.GridPaging = VendorRepository.Instance.GetVendorLookupSearchListPagingPO(searchViewModel);
                viewModel.OneTimeVendor = creationRepo.GetOneTimeVendor();

                return PartialView(Partial.VendorLookup, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult SearchCreationVendorLookup(LookupSearchViewModel searchViewModel)
        {
            try
            {
                var viewModel = new CreationVendorLookupViewModel();
                viewModel.DataList = VendorRepository.Instance.GetVendorLookupSearchListPO(searchViewModel);//edit 20200127
                viewModel.GridPaging = VendorRepository.Instance.GetVendorLookupSearchListPagingPO(searchViewModel);//edit 20200127
                viewModel.OneTimeVendor = creationRepo.GetOneTimeVendor();

                return PartialView(Partial.VendorLookupGrid, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult OpenCreationVendorEcatalogueLookup(LookupCustomSearchViewModel searchViewModel)
        {
            try
            {
                var viewModel = new CreationVendorLookupViewModel();
                viewModel.Title = "Vendor";
                viewModel.DataList = VendorRepository.Instance.GetVendorEcatalgueLookupSearchList(searchViewModel);
                viewModel.GridPaging = VendorRepository.Instance.GetVendorEcatalgueLookupSearchListPaging(searchViewModel);
                viewModel.OneTimeVendor = creationRepo.GetOneTimeVendor();

                return PartialView(Partial.VendorLookup, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult SearchCreationVendorEcatalogueLookup(LookupCustomSearchViewModel searchViewModel)
        {
            try
            {
                var viewModel = new CreationVendorLookupViewModel();
                viewModel.DataList = VendorRepository.Instance.GetVendorEcatalgueLookupSearchList(searchViewModel);
                viewModel.GridPaging = VendorRepository.Instance.GetVendorEcatalgueLookupSearchListPaging(searchViewModel);
                viewModel.OneTimeVendor = creationRepo.GetOneTimeVendor();

                return PartialView(Partial.VendorLookupGrid, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult RefreshSPKAmount(String processId, String poNo)
        {
            try
            {
                Decimal spkAmount = creationRepo.GetSPKAmount(processId, poNo);
                return Json(new ActionResponseViewModel { ResponseType = ActionResponseViewModel.Success, Message = spkAmount.ToString(CultureInfo.InvariantCulture) });
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult CheckSourceList(String material, String vendor, String plant, String purchasingGroup)
        {
            try
            {
                return Json(creationRepo.CheckSourceList(material, vendor, plant, purchasingGroup));
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult SilentSavePOHeader(PurchaseOrderSaveViewModel viewModel)
        {
            try
            {
                var execModel = new ExecProcedureModel();
                execModel.CurrentUser = this.GetCurrentUsername();
                execModel.CurrentRegNo = this.GetCurrentRegistrationNumber();
                execModel.ModuleId = ModuleId.PurchaseOrder;
                execModel.FunctionId = FunctionId.POCreation;
                execModel.ProcessId = viewModel.ProcessId;
            
                creationRepo.SaveHeaderTemp(execModel, viewModel);
                return Json(new ActionResponseViewModel { ResponseType = ActionResponseViewModel.Success, Message = "PO Header is silently saved." });
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult ClearTempData(String processId)
        {
            try
            {
                var execModel = new ExecProcedureModel();
                execModel.CurrentUser = this.GetCurrentUsername();
                execModel.CurrentRegNo = this.GetCurrentRegistrationNumber();
                execModel.ModuleId = ModuleId.PurchaseOrder;
                execModel.FunctionId = FunctionId.POCreation;
                execModel.ProcessId = processId;

                creationRepo.ClearTemp(execModel);
                return Json(new ActionResponseViewModel { ResponseType = ActionResponseViewModel.Success, Message = "PO temp cleared." });
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        //public ActionResult RefreshAttachment(String processId, String poNo, string docType)
        //{
        //    try
        //    {
        //        var attachmentList= (List<Attachment>)creationRepo.GetAttachmentList(poNo, processId);
        //        var attachmentFilterList =  attachmentList.Where(x => x.DOC_TYPE == docType).ToList();
        //        var spanType = docType.ToLower();

        //        string html = "";
        //        foreach (var item in attachmentFilterList)
        //        {
        //            html = html + @"<span id='isrow-" + item.SEQ_NO + "' class='remove-list-" + spanType + "'>" +
        //                        "<a href = '#' id = 'lnk-delfile-" + spanType + "' data-spanid = 'isrow-" + item.SEQ_NO + "'  data-type = '" + spanType + "' data-path = '" + item.FILE_PATH + "'>" +
        //                        "<img src='../Content/img/error.png' title='Delete "+ (item.FILE_NAME_ORI.Length > 20 ? item.FILE_NAME_ORI.Substring(0, 20) + ". . ." : item.FILE_NAME_ORI) + "' height='15' width='15'/></a>" +
        //                        "<a href = '#' onclick = \"javascript:downloadFile('"+ processId + "', '"+ item.FILE_PATH + "')\">" + (item.FILE_NAME_ORI.Length > 20 ? item.FILE_NAME_ORI.Substring(0, 20) + ". . ." : item.FILE_NAME_ORI) + "</a>" +
        //                        "</span> ";
        //        }
        //        return Json(new ActionResponseViewModel { ResponseType = ActionResponseViewModel.Success, Message = html+"|"+ attachmentFilterList.Count});
        //    }
        //    catch (Exception ex)
        //    {
        //        return Json(ex.AsActionResponseViewModel());
        //    }
        //}
        public ActionResult RefreshAttachment(String processId, String poNo, String prNo, string docType)
        {
            Boolean b = false;
            try
            {
                var attachmentList = (List<Attachment>)creationRepo.GetAttachmentList(poNo, processId);
                var attachmentFilterList = attachmentList.Where(x => x.DOC_TYPE == docType).ToList();
                var spanType = docType.ToLower();

                string html = "";
                foreach (var item in attachmentFilterList)
                {
                    #region 20190626 : isid.rgl
                    b = creationRepo.CheckAttachmentExist(item.PR_NO, item.FILE_PATH);

                    if (b == true)
                    {
                        html = html + @"<span id='isrow-" + item.SEQ_NO + "' class='remove-list-" + spanType + "'>" +
                                "<a href = '#' id = 'lnk-delfile-" + spanType + "' data-spanid = 'isrow-" + item.SEQ_NO + "'  data-type = '" + spanType + "' data-path = '" + item.FILE_PATH + "'>" +
                                "<img src='../Content/img/error.png' title='Delete " + (item.FILE_NAME_ORI.Length > 20 ? item.FILE_NAME_ORI.Substring(0, 20) + ". . ." : item.FILE_NAME_ORI) + "' height='15' width='15'/></a>" +
                                "<a href = '#' onclick = \"javascript:downloadFile('" + processId + "', '" + item.FILE_PATH + "')\">" + (item.FILE_NAME_ORI.Length > 20 ? item.FILE_NAME_ORI.Substring(0, 20) + ". . ." : item.FILE_NAME_ORI) + "</a>" +
                                "</span> ";
                    }
                    #endregion
                }
                return Json(new ActionResponseViewModel { ResponseType = ActionResponseViewModel.Success, Message = html + "|" + attachmentFilterList.Count });
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }
        public string ValidateDownload(string processId, string path)
        {
            var poHeader = creationRepo.GetPOHeaderTemp(processId);
            var docyear = poHeader.PODate.Year.ToString();
            var poNo = poHeader.PONo;
            string fixpath = commonRepo.GetDocumentBasePath();
            string temppath = commonRepo.GetDocumentTempBasePath();
            string temp_attachment_path = temppath + "\\" + processId + "\\" + path;
            string fix_attachment_path = fixpath + "\\" + docyear +"\\" + poNo+ "\\" + path;
            string filename = path;
            string mime = GetMimeType(path);

            if (System.IO.File.Exists(fix_attachment_path)) path = fix_attachment_path;
            else path = temp_attachment_path;

            if (System.IO.File.Exists(path)) return "Y";
            else return "<p>File Not Found in " + path + "</p>";
        }

        public void DownloadFile(string processId, string path)
        {
            var poHeader = creationRepo.GetPOHeaderTemp(processId);
            var docyear = poHeader.PODate.Year.ToString();
            var poNo = poHeader.PONo;
            string fixpath = commonRepo.GetDocumentBasePath();
            string temppath = commonRepo.GetDocumentTempBasePath();
            string temp_attachment_path = temppath + "\\" + processId + "\\" + path;
            string fix_attachment_path = fixpath + "\\" + docyear + "\\" + poNo + "\\" + path;
            string filename = path;
            string mime = GetMimeType(path);

            if (System.IO.File.Exists(fix_attachment_path)) path = fix_attachment_path;
            else path = temp_attachment_path;

            Response.Clear();
            Response.ContentType = mime;
            Response.AppendHeader("content-disposition", "attachment; filename=" + filename);
            Response.TransmitFile(path);
            Response.End();
        }

        private string GetMimeType(string fileName)
        {
            string mimeType = "application/unknown";
            string ext = Path.GetExtension(fileName).ToLower();
            Microsoft.Win32.RegistryKey regKey = Microsoft.Win32.Registry.ClassesRoot.OpenSubKey(ext);
            if (regKey != null && regKey.GetValue("Content Type") != null)
                mimeType = regKey.GetValue("Content Type").ToString();
            return mimeType;
        }

        #region 20190628 : isid.rgl, Check Vendor Existing Adopted PR
        public ActionResult CheckExistingAdoptPR(String processId)
        {
            string b = string.Empty;
            string c = string.Empty;
            string d = "x";
            try
            {
                List<ListVendorAdoptPR> ExistingAdoptVendorList = (List<ListVendorAdoptPR>)creationRepo.CheckExistingAdoptPrVendor(processId);

                if (ExistingAdoptVendorList.Count > 0)
                {
                    foreach (var item in ExistingAdoptVendorList)
                    {
                        c = item.VendorCD;
                        if (d == "" || d != c)
                        {
                            d = c;
                        }
                        b = "1" + "|" + d;
                    }
                };
                return Json(new ActionResponseViewModel { ResponseType = ActionResponseViewModel.Success, Message = b });
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }
        #endregion

    }
}