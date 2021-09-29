using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Constants;
using GPS.Core;
using GPS.Core.ViewModel;
using GPS.Models;
using GPS.Models.Common;
using GPS.Models.Master;
using GPS.ViewModels;
using GPS.ViewModels.Master;
using NPOI.HSSF.UserModel;
using Toyota.Common.Web.Platform;

namespace GPS.Controllers.Master
{
    public class PurchasingGroupController : PageController
    {
        public sealed class Partial
        {
            public const String Grid = "_purchasingGroupGrid";
            public const String Edit = "_purchasingGroupEdit";
            public const String UserMap = "_purchasingGroupUserMap";
            public const String UserMapGrid = "_purchasingGroupUserMapGrid";
            public const String UserMapEdit = "_usermapEdit";
        }

        public sealed class Action
        {
            public const String Search = "/PurchasingGroup/Search";
            public const String ClearSearch = "/PurchasingGroup/ClearSearch";
            public const String Edit = "/PurchasingGroup/Edit";
            public const String Delete = "/PurchasingGroup/Delete";
            public const String Save = "/PurchasingGroup/Save";
            public const String UserMap = "/PurchasingGroup/UserMap";
            public const String UserMapEdit = "/PurchasingGroup/EditUserMap";
            public const String UserMapDelete = "/PurchasingGroup/DeleteUserMap";
            public const String UserMapSave = "/PurchasingGroup/SaveUserMap";
            public const String RefreshDepartment = "/PurchasingGroup/RefreshDepartment";
            public const String RefreshSection = "/PurchasingGroup/RefreshSection";
            public const String RegNoCheck = "/PurchasingGroup/CheckRegNo";
            public const String GetUploadValidationInfo = "/PurchasingGroup/GetUploadValidationInfo";
            public const String Upload = "/PurchasingGroup/Upload";
            public const String Download = "/PurchasingGroup/Download";
            public const String DownloadTemplate = "/PurchasingGroup/DownloadTemplate";
        }

        private readonly PurchasingGroupRepository repo = new PurchasingGroupRepository();

        protected override void Startup()
        {
            Settings.Title = "Purchasing Group Master";
            Model = SearchEmpty();
        }

        private GenericViewModel<PurchasingGroup> SearchEmpty()
        {
            var viewModel = new GenericViewModel<PurchasingGroup>();
            viewModel.DataList = new List<PurchasingGroup>();
            viewModel.GridPaging = PaginationViewModel.GetDefault(PurchasingGroupRepository.DataName);

            return viewModel;
        }

        public static SelectList PurchasingGroupSelectList
        {
            get
            {
                return new PurchasingGroupRepository()
                    .GetList()
                    .AsSelectList(pg => pg.PurchasingGroupCode + " - " + pg.Description,
                        pg => pg.PurchasingGroupCode);
            }
        }

        public static SelectList PurchasingGroupByRegNoSelectList(String regNo)
        {
            return new PurchasingGroupRepository()
                .GetListByUserRegNo(regNo)
                .AsSelectList(pg => pg.PurchasingGroupCode + " - " + pg.Description,
                    pg => pg.PurchasingGroupCode);
        }



        public static SelectList DivisionSelectList
        {
            get
            {
                return new PurchasingGroupRepository()
                    .GetUserMapDivisionList()
                    .AsRawSelectList(nvi => nvi.Value + " - " + nvi.Name, nvi => nvi.Value);
            }
        }

        public static String GetFirstPurchasingGroup(String regNo)
        {
            IList<PurchasingGroup> purchasingGroupList = new PurchasingGroupRepository().GetListByUserRegNo(regNo);
            return (purchasingGroupList.FirstOrDefault() ?? new PurchasingGroup()).PurchasingGroupCode;
        }

        [HttpPost]
        public ActionResult Search(PurchasingGroupSearchViewModel searchViewModel)
        {
            try
            {
                var viewModel = new GenericViewModel<PurchasingGroup>();
                viewModel.CurrentUser = this.GetCurrentUser();
                viewModel.DataList = new List<PurchasingGroup>(repo.GetList(searchViewModel));
                viewModel.GridPaging = repo.GetListPaging(searchViewModel);

                return PartialView(Partial.Grid, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult ClearSearch()
        {
            try
            {
                var viewModel = SearchEmpty();
                return PartialView(Partial.Grid, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult Edit(String procChannelCode, String code)
        {
            try
            {
                var viewModel = repo.GetByCode(procChannelCode, code);
                return PartialView(Partial.Edit, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult Delete(String primaryKeyList)
        {
            try
            {
                IEnumerable<String> codeList = repo.Delete(primaryKeyList);
                return Json(new ActionResponseViewModel { ResponseType = ActionResponseViewModel.Success, Message = "Purchasing Group(s) " + String.Join(", ", codeList) + " have been deleted." });
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult Save(String editMode, String procChannelCode, String code, String desc)
        {
            try
            {
                repo.Save(editMode, this.GetCurrentUsername(), procChannelCode, code, desc);
                return Json(new ActionResponseViewModel { ResponseType = ActionResponseViewModel.Success, Message = "Purchasing Group " + code + " has been " + (editMode == EditMode.Add ? "created." : "edited.") });
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
                UploadValidationInfo info = CommonUploadRepository.Instance.GetDataUploadValidationInfo();
                return Json(info);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult Upload(HttpPostedFileBase uploadedFile, String purchasingGroupCode)
        {
            try
            {
                repo.SavePurchasingGroupUploadFile(uploadedFile.FileName, uploadedFile.ContentLength, uploadedFile.InputStream);

                return Json(new ActionResponseViewModel { ResponseType = ActionResponseViewModel.Success, Message = "File " + uploadedFile.FileName + " is uploaded successfully." });
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public FileResult Download(PurchasingGroupSearchViewModel searchViewModel)
        {
            // NOTE: hackish way to ignore paging when download
            searchViewModel.CurrentPage = 1;
            searchViewModel.PageSize = 100000;
            IEnumerable<PurchasingGroup> dataList = repo.GetList(searchViewModel);
            List<String[]> downloadDataList = dataList
                .Select(d => new[]
                {
                    d.PurchasingGroupCode,
                    d.Description,
                    d.ProcChannelCode,
                    d.CreatedBy,
                    d.CreatedDate.ToStandardFormat(),
                    d.ChangedBy,
                    d.ChangedDate.ToStandardFormat()
                })
                .ToList();

            downloadDataList.Insert(0, new[]
            {
                "Purchasing Group Code",
                "Purchasing Group Desc",
                "Procurement Channel Code",
                "Created By",
                "Created Date",
                "Changed By",
                "Changed Date"
            });

            HSSFWorkbook workbook = CommonDownload.Instance.CreateExcelSheet(downloadDataList, "PurchasingGroup");
            Byte[] excelBytes;
            using (var exportData = new MemoryStream())
            {
                workbook.Write(exportData);
                excelBytes = (Byte[]) exportData.GetBuffer().Clone();
            }
            return File(excelBytes, CommonFormat.ExcelMimeType, "PurchasingGroup_" + DateTime.Now.ToString(CommonFormat.FullDateTime) + ".xls");
        }

        [HttpPost]
        public FileResult DownloadTemplate()
        {
            const String filename = "PurchasingGroup.xls";
            String serverFilePath = HttpContext.Request.MapPath(CommonDownload.Instance.GetServerFilePath(filename));
            Byte[] fileBytes = System.IO.File.ReadAllBytes(serverFilePath);

            return File(fileBytes, CommonFormat.ExcelMimeType, filename);
        }

        [HttpPost]
        public ActionResult UserMap(String purchasingGroup)
        {
            try
            {
                IList<PurchasingGroupUser> viewModel = repo.GetUserListByCode(purchasingGroup);
                return PartialView(Partial.UserMap, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult EditUserMap()
        {
            try
            {
                return PartialView(Partial.UserMapEdit);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult DeleteUserMap(String purchasingGroup, IEnumerable<String> regNoList)
        {
            try
            {
                repo.DeleteUserMap(purchasingGroup, regNoList);
                IList<PurchasingGroupUser> viewModel = repo.GetUserListByCode(purchasingGroup);
                return PartialView(Partial.UserMapGrid, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult SaveUserMap(String purchasingGroup, String regNo, String divisionId, String deptId, String sectionId)
        {
            try
            {
                repo.SaveUserMap(purchasingGroup, regNo, divisionId, deptId, sectionId, this.GetCurrentUsername());
                IList<PurchasingGroupUser> viewModel = repo.GetUserListByCode(purchasingGroup);
                return PartialView(Partial.UserMapGrid, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult RefreshDepartment(String dropdownId, String divisionId)
        {
            try
            {
                var viewModel = new DropdownListViewModel();
                viewModel.DataName = dropdownId;
                viewModel.DataList = repo.GetUserMapDepartmentList(divisionId)
                    .AsSelectList(nvi => nvi.Value + " - " + nvi.Name, nvi => nvi.Value);

                return PartialView(CommonPage.DropdownList, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult RefreshSection(String dropdownId, String divisionId, String departmentId)
        {
            try
            {
                var viewModel = new DropdownListViewModel();
                viewModel.DataName = dropdownId;
                viewModel.DataList = repo.GetUserMapSectionList(divisionId, departmentId)
                    .AsSelectList(nvi => nvi.Value + " - " + nvi.Name, nvi => nvi.Value);

                return PartialView(CommonPage.DropdownList, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult CheckRegNo(String regNo)
        {
            try
            {
                if (String.IsNullOrEmpty(regNo))
                    return Json(new ActionResponseViewModel {ResponseType = ActionResponseViewModel.Warning});

                ActionResponseViewModel result = repo.CheckRegNo(regNo);
                return Json(result);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }
    }
}
