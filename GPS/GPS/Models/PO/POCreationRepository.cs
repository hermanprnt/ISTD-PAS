using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using GPS.CommonFunc;
using GPS.Constants;
using GPS.Core;
using GPS.Core.ViewModel;
using GPS.Models.Common;
using GPS.Models.Master;
using GPS.ViewModels;
using GPS.ViewModels.PO;
using ServiceStack.Text;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;
using NameValueItem = GPS.Models.Common.NameValueItem;

namespace GPS.Models.PO
{
    public class POCreationRepository
    {
        private readonly IDBContext db;
        private readonly POCommonRepository commonRepo;
        public POCreationRepository()
        {
            db = DatabaseManager.Instance.GetContext();
            db.SetExecutionMode(DBContextExecutionMode.Direct);
            commonRepo = new POCommonRepository();
        }

        public String Initial(ExecProcedureModel execModel, String poNo)
        {
            String query = "EXEC sp_POCreation_Initial @CurrentUser, @CurrentUserName, 0, @ModuleId, @FunctionId, @PONo";
            dynamic param = new { execModel.CurrentUser, execModel.CurrentUserName, execModel.ProcessId, execModel.ModuleId, execModel.FunctionId, PONo = poNo };
            InitialActionResult result = db.SingleOrDefault<InitialActionResult>(query, param);
            db.Close();

            var resultViewModel = result.Message.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return result.ProcessId;
        }

        public ActionResponseViewModel AddPOItemCondition(ExecProcedureModel execModel, AddPOItemConditionViewModel viewModel)
        {
            String query = "EXEC sp_POCreation_AddItemConditionTemp @CurrentUser, @ProcessId, @ModuleId, @FunctionId, @PONo, @POItemNo, @SeqItemNo, @SeqNo, @CompPriceCode, @ConditionType, @CompPriceRate, @ExchangeRate, @Currency, @QtyPerUOM, @Qty";
            dynamic param = new
            {
                execModel.CurrentUser,
                execModel.ProcessId,
                execModel.ModuleId,
                execModel.FunctionId,
                viewModel.PONo,
                viewModel.POItemNo,
                viewModel.SeqItemNo,
                viewModel.SeqNo,
                viewModel.CompPriceCode,
                viewModel.ConditionType,
                viewModel.CompPriceRate,
                viewModel.ExchangeRate,
                viewModel.Currency,
                viewModel.QtyPerUOM,
                viewModel.Qty
            };

            String result = db.ExecuteScalar<String>(query, param);
            db.Close();

            var resultViewModel = result.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return resultViewModel;
        }

        public ActionResponseViewModel DeletePOItemConditionTemp(ExecProcedureModel execModel, DeletePOItemConditionViewModel viewModel)
        {
            String query = "EXEC sp_POCreation_DeleteItemConditionTemp @CurrentUser, @ProcessId, @ModuleId, @FunctionId, @PONo, @POItemNo, @SeqItemNo, @SeqNo";
            dynamic param = new
            {
                execModel.CurrentUser,
                execModel.ProcessId,
                execModel.ModuleId,
                execModel.FunctionId,
                viewModel.PONo,
                viewModel.POItemNo,
                viewModel.SeqItemNo,
                viewModel.SeqNo
            };

            String result = db.ExecuteScalar<String>(query, param);
            db.Close();

            var resultViewModel = result.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return resultViewModel;
        }

        public String SaveBidingDocFileToTemp(ExecProcedureModel execModel, String docNo, String fileName, Stream fileStream, Int32 contentLength)
        {
            const String DocPrefix = "BID";
            String tempFilename = GeneratePOUploadFileName(DocPrefix, fileName);
            SavePOFileStreamToTemp(execModel.ProcessId, tempFilename, fileStream);
            SavePOFileInfoToTemp(execModel, docNo, fileName, DocPrefix, tempFilename, contentLength);

            return tempFilename;
        }

        private void SavePOFileStreamToTemp(String processId, String tempFilename, Stream fileStream)
        {
            String tempDirPath = Path.GetFullPath(commonRepo.GetDocumentTempBasePath() + "\\" + processId);
            if (!Directory.Exists(tempDirPath))
                Directory.CreateDirectory(tempDirPath);

            String tempFilePath = Path.GetFullPath(tempDirPath + "\\" + tempFilename);
            using (FileStream streamToSave = new FileStream(tempFilePath, FileMode.Create))
            {
                fileStream.WriteTo(streamToSave);
                streamToSave.Flush();
            }
        }

        private void SavePOFileInfoToTemp(ExecProcedureModel execModel, String docNo, String oriFilename, String docPrefix, String tempFileName, Int32 contentLength)
        {
            String query = "EXEC sp_POCreation_AddAttachmentTemp @CurrentUser, @ProcessId, @ModuleId, @FunctionId, @DocNo, @DocType, @TempFilename, @OriFilename, @FileExt, @FileSize";
            dynamic param = new
            {
                execModel.CurrentUser,
                execModel.ProcessId,
                execModel.ModuleId,
                execModel.FunctionId,
                DocNo = docNo,
                DocType = docPrefix,
                TempFilename = tempFileName,
                OriFilename = oriFilename,
                FileExt = Path.GetExtension(tempFileName),
                FileSize = contentLength
            };

            String result = db.ExecuteScalar<String>(query, param);
            db.Close();

            var resultViewModel = result.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);
        }

        public String SaveQuotationFileToTemp(ExecProcedureModel execModel, String docNo, String fileName, Stream fileStream, Int32 contentLength)
        {
            const String DocPrefix = "QUOT";
            String tempFilename = GeneratePOUploadFileName(DocPrefix, fileName);
            SavePOFileStreamToTemp(execModel.ProcessId, tempFilename, fileStream);
            SavePOFileInfoToTemp(execModel, docNo, fileName, DocPrefix, tempFilename, contentLength);

            return tempFilename;
        }

        public void DeleteFileTemp(String ProcessId, String path, string currentUser)
        {
            String query = "EXEC sp_POCreation_DeleteFileTemp @ProcessId, @Path, @CurrentUser";
            db.Execute(query, new { ProcessId = ProcessId, Path = path, CurrentUser = currentUser });
            db.Close();
        }

        private String GeneratePOUploadFileName(String prefix, String fileName)
        {
            return prefix + "_" + DateTime.Now.ToString(CommonFormat.FullDateTime) + Path.GetExtension(fileName);
        }

        /*private String GetPOUploadFileTempPath(String processId)
        {
            String uploadBasePathSystemValue = SystemRepository.Instance.GetSystemValue("UPLOAD_FILE_PATH");
            String tempPathSystemValue = SystemRepository.Instance.GetSystemValue("PO_UPLOAD_TEMP_PATH");

            return Path.GetFullPath(uploadBasePathSystemValue + "\\" + tempPathSystemValue + "\\" + processId);
        }*/

        public void MoveTempAttachmentToRealPath(String processId, String poNo, String DocYear)
        {
            IList<String> deletedFiles = GetDeletedAttachmentList(processId);
            IList<String> attachedFiles = GetAttachedList(processId);

            String tempPath = Path.GetFullPath(commonRepo.GetDocumentTempBasePath() + "\\" + processId);
            String realPath = Path.GetFullPath(commonRepo.GetDocumentBasePath() + "\\" + DocYear + "\\" + poNo);

            if (deletedFiles.Any())
            {
                foreach (String filename in deletedFiles)
                {
                    String fullpath = Path.GetFullPath(tempPath + "\\" + filename);
                    if (File.Exists(fullpath))
                        File.Delete(fullpath);

                    fullpath = Path.GetFullPath(realPath + "\\" + filename);
                    if (File.Exists(fullpath))
                        File.Delete(fullpath);
                }
            }

            if (attachedFiles.Any())
            {
                foreach (String filename in attachedFiles)
                {
                    String sourcepath = Path.GetFullPath(tempPath + "\\" + filename); //GetDocFullPath(commonRepo.GetDocumentTempBasePath(), filename, ProcessId);
                    String destpath = Path.GetFullPath(realPath + "\\" + filename); //GetDocFullPath(basepath, filename, poNo);

                    if (!Directory.Exists(realPath))
                        Directory.CreateDirectory(realPath);

                    if (File.Exists(sourcepath))
                        File.Move(sourcepath, destpath);
                }
            }

            if (Directory.Exists(tempPath))
                Directory.Delete(tempPath, true);
        }

        public IList<PRPOItem> GetPRItemSearchList(PRItemSearchViewModel searchViewModel)
        {
            String query = "EXEC sp_POCreation_GetPRItemList @ProcessId, @PRNo, @ValuationClass, @PlantCode, @MaterialNo, @Currency, @SLocCode, @MaterialDesc, @VendorCode, @PRCoordinator, @PurchasingGroup, @CurrentPage, @PageSize";
            IList<PRPOItem> result = db.Fetch<PRPOItem>(query, searchViewModel);
            db.Close();

            return result;
        }

        public PaginationViewModel GetPRItemSearchListPaging(PRItemSearchViewModel searchViewModel)
        {
            String query = "EXEC sp_POCreation_GetPRItemListCount @ProcessId, @PRNo, @ValuationClass, @PlantCode, @MaterialNo, @Currency, @SLocCode, @MaterialDesc, @VendorCode, @PRCoordinator, @PurchasingGroup";

            var model = new PaginationViewModel();
            model.DataName = "pritem";
            model.TotalDataCount = db.ExecuteScalar<Int32>(query, searchViewModel);
            model.PageIndex = searchViewModel.CurrentPage;
            model.PageSize = searchViewModel.PageSize;

            db.Close();

            return model;
        }

        public ActionResponseViewModel AdoptItemTemp(ExecProcedureModel execModel, String poNo, String currency, IEnumerable<PRItemAdoptViewModel> itemAdoptList)
        {
            String paramString = itemAdoptList
                .AsDelimitedString(
                    itemAdopt => itemAdopt.PRNo,
                    itemAdopt => itemAdopt.PRItemNo,
                    itemAdopt => itemAdopt.AssetNo,
                    itemAdopt => itemAdopt.SubAssetNo);

            String query = "EXEC sp_POCreation_AdoptItemTemp @CurrentUser, @ProcessId, @ModuleId, @FunctionId, @PONo, @Currency, @PRNoPRItemNoList";
            dynamic param = new { execModel.CurrentUser, execModel.ProcessId, execModel.ModuleId, execModel.FunctionId, PONo = poNo, Currency = currency, PRNoPRItemNoList = paramString };
            String result = db.ExecuteScalar<String>(query, param);


            String PRNo = itemAdoptList
               .AsDelimitedString(
                   itemAdopt => itemAdopt.PRNo);

            String DocType = "QUOT";

            GetAttachedListFromPR(PRNo, DocType, execModel.CurrentUser, execModel.ProcessId);

            db.Close();
            var resultViewModel = result.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return resultViewModel;
        }

        //public void CopyAdoptAttachment(ExecProcedureModel execModel, String poNo, String currency, IEnumerable<PRItemAdoptViewModel> itemAdoptList)
        //{
        //    poNo = poNo == null ? "" : poNo;
        //    //String DocType = "QUOT";
        //    foreach (var item in itemAdoptList)
        //    {
        //        var listAttachement = CopyDataAttachmentAndFile(execModel, poNo, item);
        //        foreach (var fileitem in listAttachement)
        //        {
        //            CopyFileAttachmentFromPRToPO(fileitem.PR_NO, execModel.ProcessId, fileitem);
        //        }

        //    }
        //}
        public void CopyAdoptAttachment(ExecProcedureModel execModel, String poNo, String currency, IEnumerable<PRItemAdoptViewModel> itemAdoptList)
        {
            poNo = poNo == null ? "" : poNo;
            string myprno = string.Empty;
            string myprno2 = string.Empty;
            Boolean b = false;		//added : 20190626 : isid.rgl
            //String DocType = "QUOT";
            foreach (var item in itemAdoptList)
            {
                myprno = item.PRNo;
                if (myprno2 == "" || myprno2 != myprno)
                {
                    var listAttachement = CopyDataAttachmentAndFile(execModel, poNo, item);
                    foreach (var fileitem in listAttachement)
                    {
                        //modded : 20160626 : isid.rgl
                        //CopyFileAttachmentFromPRToPO(fileitem.PR_NO, execModel.ProcessId, fileitem);
                        b = CopyFileAttachmentFromPRToPO(fileitem.PR_NO, execModel.ProcessId, fileitem);
                    }
                }
                myprno2 = myprno;
            }

        }
        #region : 20190626 : isid.rgl : cek existance file in server path
        public Boolean CheckAttachmentExist(string prId, string filename)
        {
            Boolean b = false;
            string mainpath = SystemRepository.Instance.GetSystemValue("UPLOAD_FILE_PATH");
            string temppath = SystemRepository.Instance.GetSystemValue("PR_UPLOAD_PATH");

            string Fix_attachment_PR = mainpath + temppath + prId;
            String tempFilePR_Path = Path.GetFullPath(Fix_attachment_PR + "\\" + filename);
            if (File.Exists(tempFilePR_Path))
            {
                b = true;
            }
            return b;
        }
        /* Closed : 20190626 : isid.rgl
        private void CopyFileAttachmentFromPRToPO(string prId, string processId, Attachment fileitem)
        {
            string mainpath = SystemRepository.Instance.GetSystemValue("UPLOAD_FILE_PATH");
            string temppath = SystemRepository.Instance.GetSystemValue("PR_UPLOAD_PATH");
            string Fix_attachment_PR = mainpath + temppath + prId;
            String temp_attachment_PO = Path.GetFullPath(commonRepo.GetDocumentTempBasePath() + "\\" + processId);
            if (!Directory.Exists(temp_attachment_PO))
                Directory.CreateDirectory(temp_attachment_PO);

            String tempFilePR_Path = Path.GetFullPath(Fix_attachment_PR + "\\" + fileitem.FILE_PATH);
            String tempFilePO_Path = Path.GetFullPath(temp_attachment_PO + "\\" + fileitem.FILE_PATH);

            if (File.Exists(tempFilePR_Path))
            {
                if (File.Exists(tempFilePO_Path)) File.Delete(tempFilePO_Path);
                File.Copy(tempFilePR_Path, tempFilePO_Path);
            }
            else
            {
                throw new InvalidOperationException("File " + fileitem.FILE_NAME_ORI + " not found in " + Fix_attachment_PR);
            }
        }
		*/
        private Boolean CopyFileAttachmentFromPRToPO(string prId, string processId, Attachment fileitem)
        {
            Boolean b = false;
            try
            {
                string mainpath = SystemRepository.Instance.GetSystemValue("UPLOAD_FILE_PATH");
                string temppath = SystemRepository.Instance.GetSystemValue("PR_UPLOAD_PATH");

                string Fix_attachment_PR = mainpath + temppath + prId;

                String temp_attachment_PO = Path.GetFullPath(commonRepo.GetDocumentTempBasePath() + "\\" + processId);

                String tempFilePR_Path = Path.GetFullPath(Fix_attachment_PR + "\\" + fileitem.FILE_PATH);
                String tempFilePO_Path = Path.GetFullPath(temp_attachment_PO + "\\" + fileitem.FILE_PATH);

                if (!Directory.Exists(temp_attachment_PO))
                {
                    Directory.CreateDirectory(temp_attachment_PO);
                }

                if (File.Exists(tempFilePR_Path))
                {
                    if (File.Exists(tempFilePO_Path)) File.Delete(tempFilePO_Path);
                    File.Copy(tempFilePR_Path, tempFilePO_Path);
                }
                b = true;
            }
            catch (Exception ex)
            {
                b = false;
            }
            return b;
        }
        #endregion

        private IList<Attachment> CopyDataAttachmentAndFile(ExecProcedureModel execModel, string poNo, PRItemAdoptViewModel item)
        {
            String query = "EXEC sp_POCreation_CopyAttachedFilesFromPR @PONo, @PRNo, @DocType, @CurrentUser, @ProcessId";
            dynamic param = new { PONo = poNo, item.PRNo, DocType = "", CurrentUser = execModel.CurrentUser, execModel.ProcessId };
            IList<Attachment> result = db.Fetch<Attachment>(query, param);

            db.Close();

            return result;
        }

        public ActionResponseViewModel AddItemTemp(ExecProcedureModel execModel, POItemAddViewModel viewModel, out String poNo, out String poItemNo, out String seqItemNo)
        {
            // add item
            String query = "EXEC sp_POCreation_AddItemTemp @CurrentUser, @ProcessId, @ModuleId, @FunctionId, @PONo, @POItemNo, @SeqItemNo, @Vendor, @VendorName, @PurchasingGroup, @ValuationClass, @MatNo, @MatDesc, @Qty, @UOM, @Price, @WBSNo, @CostCenter, @GLAccount, @DeliveryDate, @Plant, @SLoc, @Currency";
            dynamic param = new
            {
                execModel.CurrentUser,
                execModel.ProcessId,
                execModel.ModuleId,
                execModel.FunctionId,
                viewModel.PONo,
                viewModel.POItemNo,
                viewModel.SeqItemNo,
                viewModel.Vendor,
                viewModel.VendorName,
                viewModel.PurchasingGroup,
                viewModel.ValuationClass,
                viewModel.MatNo,
                viewModel.MatDesc,
                viewModel.Qty,
                viewModel.UOM,
                viewModel.Price,
                viewModel.WBSNo,
                viewModel.CostCenter,
                viewModel.GLAccount,
                viewModel.DeliveryDate,
                viewModel.Plant,
                viewModel.SLoc,
                viewModel.Currency
            };
            String result = db.ExecuteScalar<String>(query, param);

            var resultViewModel = result.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            // NOTE: idx 0 --> message, idx 1 --> poNo, idx 2 --> poItemNo, idx 3 --> seqItemNo
            String[] splittedMessage = resultViewModel.Message.Split(CommonFormat.ItemDelimiter);
            // add subitem
            if (viewModel.SubItemList != null)
            {
                query = "EXEC sp_POCreation_AddSubItemTemp @CurrentUser, @ProcessId, @ModuleId, @FunctionId, @PONo, @POItemNo, @SeqItemNo, @MatDesc, @Qty, @UOM, @Price, @WBSNo, @CostCenter, @GLAccount, @Currency";
                foreach (POSubItemAddViewModel subItem in viewModel.SubItemList)
                {
                    param = new
                    {
                        execModel.CurrentUser,
                        execModel.ProcessId,
                        execModel.ModuleId,
                        execModel.FunctionId,
                        viewModel.PONo,
                        POItemNo = splittedMessage[2] == String.Empty ? null : splittedMessage[2],
                        SeqItemNo = splittedMessage[3] == String.Empty ? null : splittedMessage[3],
                        MatDesc = subItem.SubItemMatDesc,
                        Qty = subItem.SubItemQty,
                        UOM = subItem.SubItemUOM,
                        Price = subItem.SubItemPrice,
                        WBSNo = subItem.SubItemWBSNo,
                        CostCenter = subItem.SubItemCostCenter,
                        GLAccount = subItem.SubItemGLAccount,
                        viewModel.Currency
                    };

                    result = db.ExecuteScalar<String>(query, param);

                    resultViewModel = result.AsActionResponseViewModel();
                    if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                        throw new InvalidOperationException(resultViewModel.Message);
                }
            }
            // recalculate

            db.Close();

            poNo = viewModel.PONo;
            poItemNo = splittedMessage[2] == String.Empty ? null : splittedMessage[2];
            seqItemNo = splittedMessage[3] == String.Empty ? null : splittedMessage[3];

            return resultViewModel;
        }

        public ActionResponseViewModel UpdateSubItemTemp(POSubItemUpdateViewModel viewModel)
        {
            String query = "EXEC sp_POCreation_UpdateSubItemTemp @CurrentUser, @ProcessId, @ModuleId, @FunctionId, @PONo, @POItemNo, @SeqItemNo, @SeqNo, @MatDesc, @Qty, @UOM, @PricePerUOM, @Currency, @WBS, @CostCenter, @GLAccount";
            String result = db.ExecuteScalar<String>(query, viewModel);
            db.Close();

            var resultViewModel = result.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return resultViewModel;
        }

        public ActionResponseViewModel CopyItemTemp(ExecProcedureModel execModel, String poNo, String poItemNo, Int32 seqItemNo)
        {
            String query = "EXEC sp_POCreation_CopyItemTemp @CurrentUser, @ProcessId, @ModuleId, @FunctionId, @PONo, @POItemNo, @SeqItemNo";
            dynamic param = new
            {
                execModel.CurrentUser,
                execModel.ProcessId,
                execModel.ModuleId,
                execModel.FunctionId,
                PONo = poNo,
                POItemNo = poItemNo,
                SeqItemNo = seqItemNo
            };
            String result = db.ExecuteScalar<String>(query, param);
            db.Close();

            var resultViewModel = result.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return resultViewModel;
        }

        public IList<PRPOItem> GetItemTemp(String processId)
        {
            String query = "EXEC sp_POCreation_GetItemTemp @ProcessId";
            IList<PRPOItem> result = db.Fetch<PRPOItem>(query, new { ProcessId = processId });
            db.Close();

            return result;
        }

        public void ValidateEdit(String poNo, String username, String noreg)
        {
            String query = "EXEC sp_POCreation_ValidateEdit @poNo, @username, @noreg";
            db.Execute(query, new { poNo, username, noreg });
            db.Close();
        }

        /*public IList<PRPOItem> GetPOItemSearchList(String poNo, Int32 currentPage, Int32 pageSize)
        {
            String query = "EXEC sp_POCommon_GetPOItemSearchList @PONo, @CurrentPage, @PageSize";
            dynamic param = new { PONo = poNo, CurrentPage = currentPage, PageSize = pageSize };
            IList<PRPOItem> result = db.Fetch<PRPOItem>(query, param);
            db.Close();

            return result;
        }

        public PaginationViewModel GetPOItemSearchListPaging(String poNo, Int32 currentPage, Int32 pageSize)
        {
            String query = "EXEC sp_POCommon_GetPOItemSearchListCount @PONo";

            var model = new PaginationViewModel();
            model.DataName = POCommonRepository.POItemDataName;
            model.TotalDataCount = db.ExecuteScalar<Int32>(query, new { PONo = poNo });
            model.PageIndex = currentPage;
            model.PageSize = pageSize;

            db.Close();

            return model;
        }*/

        public ActionResponseViewModel DeleteItemTemp(POItemDeleteViewModel viewModel)
        {
            String query = "EXEC sp_POCreation_DeleteItemTemp @CurrentUser, @ProcessId, @ModuleId, @FunctionId, @PONo, @POItemNo, @SeqItemNo";
            String result = db.ExecuteScalar<String>(query, viewModel);
            db.Close();

            var resultViewModel = result.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return resultViewModel;
        }

        public ActionResponseViewModel UpdateItemTemp(POItemUpdateViewModel viewModel)
        {
            String query = "EXEC sp_POCreation_UpdateItemTemp @CurrentUser, @ProcessId, @ModuleId, @FunctionId, @PONo, @POItemNo, @SeqItemNo, @MatDesc, @Plant, @SLoc, @DeliveryDate, @Qty, @PricePerUOM, @Currency, @UOM";
            String result = db.ExecuteScalar<String>(query, viewModel);
            db.Close();

            var resultViewModel = result.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return resultViewModel;
        }

        public ActionResponseViewModel ResetItemTemp(ExecProcedureModel execModel)
        {
            String query = "EXEC sp_POCreation_ResetItemTemp @CurrentUser, @ProcessId, @ModuleId, @FunctionId";
            String result = db.ExecuteScalar<String>(query, execModel);
            db.Close();

            var resultViewModel = result.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return resultViewModel;
        }

        public IList<PRPOSubItem> GetPRSubItemSearchList(PRPOSubItemSearchViewModel searchViewModel)
        {
            //String query = "EXEC sp_POCreation_GetPRSubItemSearchList @PRNo, @PRItemNo, @CurrentPage, @PageSize";                 //closed : 20190722 : isid.rgl
            String query = "EXEC sp_POCreation_GetPRSubItemSearchList @PRNo, @PRItemNo, @CurrentPage, @PageSize, @ActionOrigin";    //modified : 20190722 : isid.rgl
            IList<PRPOSubItem> result = db.Fetch<PRPOSubItem>(query, searchViewModel);
            db.Close();

            return result;
        }

        public IList<PRPOSubItem> GetSubItemTemp(PRPOSubItemSearchViewModel searchViewModel)
        {
            //String query = "EXEC sp_POCreation_GetSubItemTemp @ProcessId, @PONo, @POItemNo, @SeqItemNo";              //closed : 20190722 : isid.rgl
            String query = "EXEC sp_POCreation_GetSubItemTemp @ProcessId, @PONo, @POItemNo, @SeqItemNo, @ActionOrigin"; //modified : 20190722 : isid.rgl
            IList<PRPOSubItem> result = db.Fetch<PRPOSubItem>(query, searchViewModel);
            db.Close();

            return result;
        }

        public POSaveResult SaveData(ExecProcedureModel execModel, PurchaseOrderSaveViewModel viewModel)
        {
            String query = @"EXEC sp_POCreation_Save
                @CurrentUser, @CurrentRegNo, @ProcessId,
                @ModuleId, @FunctionId, @PONo, @PODesc,
                @PONote1, @PONote2, @PONote3, @PONote4,
                @PONote5, @PONote6, @PONote7, @PONote8,
                @PONote9, @PONote10, @Vendor, @VendorName,
                @VendorAddress, @VendorCountry, @VendorCity, @VendorPostalCode,
                @VendorPhone, @VendorFax, @PurchasingGroup,
                @Currency, @DeliveryAddress, @IsSPKCreated, @BiddingDate,
                @Opening, @Work, @Amount, @Location, @PeriodStart, @PeriodEnd,
                @Retention, @TerminI, @TerminIDesc, @TerminII,
                @TerminIIDesc, @TerminIII, @TerminIIIDesc,
                @TerminIV, @TerminIVDesc, @TerminV, @TerminVDesc,
                @SaveAsDraft, @OtherMail";

            String[] poNoteArray = viewModel.PONote.ToArray();
            dynamic param = new
            {
                execModel.CurrentUser,
                execModel.CurrentRegNo,
                execModel.ProcessId,
                execModel.ModuleId,
                execModel.FunctionId,
                viewModel.PONo,
                viewModel.PODesc,
                PONote1 = poNoteArray[0],
                PONote2 = poNoteArray[1],
                PONote3 = poNoteArray[2],
                PONote4 = poNoteArray[3],
                PONote5 = poNoteArray[4],
                PONote6 = poNoteArray[5],
                PONote7 = poNoteArray[6],
                PONote8 = poNoteArray[7],
                PONote9 = poNoteArray[8],
                PONote10 = poNoteArray[9],
                viewModel.Vendor,
                viewModel.VendorName,
                viewModel.VendorAddress,
                viewModel.VendorCountry,
                viewModel.VendorCity,
                viewModel.VendorPostalCode,
                viewModel.VendorPhone,
                viewModel.VendorFax,
                viewModel.PurchasingGroup,
                viewModel.Currency,
                viewModel.DeliveryAddress,
                viewModel.SPKInfo.IsSPKCreated,
                viewModel.SPKInfo.BiddingDate,
                viewModel.SPKInfo.Opening,
                viewModel.SPKInfo.Work,
                viewModel.SPKInfo.Amount,
                viewModel.SPKInfo.Location,
                viewModel.SPKInfo.PeriodStart,
                viewModel.SPKInfo.PeriodEnd,
                viewModel.SPKInfo.Retention,
                viewModel.SPKInfo.TerminI,
                viewModel.SPKInfo.TerminIDesc,
                viewModel.SPKInfo.TerminII,
                viewModel.SPKInfo.TerminIIDesc,
                viewModel.SPKInfo.TerminIII,
                viewModel.SPKInfo.TerminIIIDesc,
                viewModel.SPKInfo.TerminIV,
                viewModel.SPKInfo.TerminIVDesc,
                viewModel.SPKInfo.TerminV,
                viewModel.SPKInfo.TerminVDesc,
                viewModel.SaveAsDraft,
                viewModel.OtherMail
            };

            POSaveResult result = db.SingleOrDefault<POSaveResult>(query, param);
            db.Close();

            var resultViewModel = result.Message.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return result;
        }

        public IList<String> GetDeletedAttachmentList(String processId)
        {
            String query = @"EXEC sp_POCreation_GetDeletedFiles @ProcessId";
            IList<String> result = db.Fetch<String>(query, new { ProcessId = processId });
            db.Close();

            return result;
        }

        public IList<String> GetAttachedList(String processId)
        {
            String query = @"EXEC sp_POCreation_GetAttachedFiles @ProcessId";
            IList<String> result = db.Fetch<String>(query, new { ProcessId = processId });
            db.Close();

            return result;
        }

        public void GetAttachedListFromPR(String PRNo, String DocType, String CurrentUser, String ProcessId)
        {
            String queryFilePR = "EXEC sp_POCreation_GetAttachedFilesFromPR @PRNo, @DocType, @CurrentUser, @ProcessId";
            dynamic paramFilePR = new { PRNo, DocType, CurrentUser, ProcessId };
            IList<String> resultFilePR = db.Fetch<String>(queryFilePR, paramFilePR, CurrentUser, ProcessId);
            db.Close();
        }

        public IList<ValuationClassLookupViewModel> GetValuationClassLookupList(ValuationClassLookupSearchViewModel searchViewModel)
        {
            String query = "EXEC sp_POCreation_GetValuationClassLookupList @PurchasingGroup, @SearchText, @CurrentPage, @PageSize";
            IList<ValuationClassLookupViewModel> result = db.Fetch<ValuationClassLookupViewModel>(query, searchViewModel);
            db.Close();

            return result;
        }

        public PaginationViewModel GetValuationClassLookupListPaging(ValuationClassLookupSearchViewModel searchViewModel)
        {
            String query = "EXEC sp_POCreation_GetValuationClassLookupListCount @PurchasingGroup, @SearchText";

            var model = new PaginationViewModel();
            model.DataName = "valuationclass";
            model.TotalDataCount = db.SingleOrDefault<Int32>(query, searchViewModel);
            model.PageIndex = searchViewModel.CurrentPage;
            model.PageSize = searchViewModel.PageSize;

            db.Close();

            return model;
        }

        public IList<NameValueItem> GetWBSLookupList(WBSLookupSearchViewModel searchViewModel)
        {
            String query = "EXEC sp_POCreation_GetWBSLookupList @CurrentUserRegNo, @SearchText, @CurrentPage, @PageSize";
            IList<WBS> result = db.Fetch<WBS>(query, searchViewModel);
            db.Close();

            return result
                .AsNumberedNameValueList(
                    data => data.DataNo,
                    data => data.WBS_NAME,
                    data => data.WBS_NO)
                .ToList();
        }

        public PaginationViewModel GetWBSLookupListPaging(WBSLookupSearchViewModel searchViewModel)
        {
            String query = "EXEC sp_POCreation_GetWBSLookupListCount @CurrentUserRegNo, @SearchText";

            var model = new PaginationViewModel();
            model.DataName = "wbsno";
            model.TotalDataCount = db.SingleOrDefault<Int32>(query, searchViewModel);
            model.PageIndex = searchViewModel.CurrentPage;
            model.PageSize = searchViewModel.PageSize;

            db.Close();

            return model;
        }

        public NameValueItem GetOneTimeVendor()
        {
            var result = db.SingleOrDefault<OneTimeVendorViewModel>("EXEC sp_POCreation_GetOneTimeVendor");
            db.Close();

            return result.AsNameValueItem(res => res.Name, res => res.Code);
        }

        public POSPKViewModel GetSPKInfo(String poNo)
        {
            var result = db.SingleOrDefault<POSPKViewModel>("EXEC sp_POCreation_GetSPKInfo @PONo", new { PONo = poNo }) ?? new POSPKViewModel();
            db.Close();

            return result;
        }

        public Decimal GetSPKAmount(String processId, String poNo)
        {
            var result = db.ExecuteScalar<Decimal>("EXEC sp_POCreation_GetSPKAmount @ProcessId, @PONo", new { ProcessId = processId, PONo = poNo });
            db.Close();

            return result;
        }

        public ActionResponseViewModel CheckSourceList(String material, String vendor, String plant, String purchasingGroup)
        {
            var result = db.ExecuteScalar<String>("EXEC sp_POCreation_CheckSourceList @Material, @Vendor, @Plant, @PurchasingGroup", new { Material = material, Vendor = vendor, Plant = plant, PurchasingGroup = purchasingGroup });
            db.Close();

            var resultViewModel = result.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return resultViewModel;
        }

        public ActionResponseViewModel SaveHeaderTemp(ExecProcedureModel execModel, PurchaseOrderSaveViewModel viewModel)
        {
            String query = @"EXEC sp_POCreation_SaveHeaderTemp
                @CurrentUser, @CurrentRegNo, @ProcessId,
                @ModuleId, @FunctionId, @PONo, @PODesc,
                @PONote1, @PONote2, @PONote3, @PONote4,
                @PONote5, @PONote6, @PONote7, @PONote8,
                @PONote9, @PONote10, @Vendor, @VendorName,
                @VendorAddress, @VendorCountry, @VendorCity, @VendorPostalCode,
                @VendorPhone, @VendorFax, @PurchasingGroup,
                @Currency, @DeliveryAddress, @OtherMail";

            String[] poNoteArray = viewModel.PONote.ToArray();
            dynamic param = new
            {
                execModel.CurrentUser,
                execModel.CurrentRegNo,
                execModel.ProcessId,
                execModel.ModuleId,
                execModel.FunctionId,
                viewModel.PONo,
                viewModel.PODesc,
                PONote1 = poNoteArray[0],
                PONote2 = poNoteArray[1],
                PONote3 = poNoteArray[2],
                PONote4 = poNoteArray[3],
                PONote5 = poNoteArray[4],
                PONote6 = poNoteArray[5],
                PONote7 = poNoteArray[6],
                PONote8 = poNoteArray[7],
                PONote9 = poNoteArray[8],
                PONote10 = poNoteArray[9],
                viewModel.Vendor,
                viewModel.VendorName,
                viewModel.VendorAddress,
                viewModel.VendorCountry,
                viewModel.VendorCity,
                viewModel.VendorPostalCode,
                viewModel.VendorPhone,
                viewModel.VendorFax,
                viewModel.PurchasingGroup,
                viewModel.Currency,
                viewModel.DeliveryAddress,
                viewModel.OtherMail
            };

            String result = db.ExecuteScalar<String>(query, param);
            db.Close();

            var resultViewModel = result.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return resultViewModel;
        }

        public ActionResponseViewModel RefreshItemTempCurrency(ExecProcedureModel execModel, String currency)
        {
            dynamic args = new
            {
                execModel.CurrentUser,
                execModel.ProcessId,
                execModel.ModuleId,
                execModel.FunctionId,
                Currency = currency
            };
            String result = db.ExecuteScalar<String>("EXEC sp_POCreation_RefreshItemTempCurrency @CurrentUser, @ProcessId, @ModuleId, @FunctionId, @Currency", args);
            db.Close();

            var resultViewModel = result.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return resultViewModel;
        }

        public ActionResponseViewModel ClearTemp(ExecProcedureModel execModel)
        {
            String result = db.ExecuteScalar<String>("EXEC sp_POCreation_ClearTemp @CurrentUser, @ProcessId, @ModuleId, @FunctionId", execModel);
            db.Close();

            var resultViewModel = result.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return resultViewModel;
        }

        public PurchaseOrder GetPOHeaderTemp(String processId)
        {
            PurchaseOrder result = db.SingleOrDefault<PurchaseOrder>("EXEC sp_POCreation_GetPOHeaderTemp @ProcessId", new { ProcessId = processId });
            if (result != null)
            {
                POSPKViewModel spkResult = db.SingleOrDefault<POSPKViewModel>("EXEC sp_POCreation_GetSPKTempInfo @ProcessId", new { ProcessId = processId });
                result.SPKInfo = spkResult;
                var listAttachment = GetAttachmentList("", processId);
                result.BidFileList = listAttachment.Where(x => x.DOC_TYPE == "BID").ToList();
                result.QuotFileList = listAttachment.Where(x => x.DOC_TYPE == "QUOT").ToList();
            }
            db.Close();

            return result;
        }

        public IList<Attachment> GetAttachmentList(string po_no, string process_id)
        {
            dynamic args = new
            {
                PR_NO = po_no,
                PROCESSID = process_id
            };
            //String query = "SELECT DOC_TYPE, SEQ_NO, FILE_PATH, FILE_EXTENSION, FILE_NAME_ORI FROM TB_T_ATTACHMENT WHERE DOC_NO = @PR_NO AND PROCESS_ID = @PROCESSID AND ISNULL(DELETE_FLAG,'N') = 'N'";
            String query = "SELECT DOC_TYPE, SEQ_NO, FILE_PATH, FILE_EXTENSION, FILE_NAME_ORI, PR_NO, DOC_NO, PROCESS_ID FROM TB_T_ATTACHMENT WHERE DOC_NO = @PR_NO AND PROCESS_ID = @PROCESSID AND ISNULL(DELETE_FLAG,'N') = 'N'";
            IList<Attachment> result = db.Fetch<Attachment>(query, args);
            db.Close();

            return result;
        }

        public Int32 GetAttachmentSeqNumber(string po_no, string process_id)
        {
            dynamic args = new
            {
                PR_NO = po_no,
                PROCESSID = process_id
            };
            String query = "SELECT SEQ_NO = ISNULL(MAX(SEQ_NO),0)+1 FROM TB_T_ATTACHMENT WHERE DOC_NO = @PR_NO AND PROCESS_ID = @PROCESSID";
            Int32 result = db.SingleOrDefault<Int32>(query, args);
            db.Close();

            return result;
        }
        #region 20190628 : isid.rgl, Check Vendor Existing Adopted PR
        public IList<ListVendorAdoptPR> CheckExistingAdoptPrVendor(string process_id)
        {
            dynamic args = new
            {
                PROCESSID = process_id
            };
            String query = "SELECT VENDOR_CD VendorCD FROM TB_T_PO_ITEM WHERE PROCESS_ID = @PROCESSID AND ISNULL(DELETE_FLAG, 'N') = 'N'";
            IList<ListVendorAdoptPR> result = db.Fetch<ListVendorAdoptPR>(query, args);
            db.Close();

            return result;
        }
        #endregion
    }
}