using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using GPS.CommonFunc;
using GPS.Core;
using GPS.Core.ViewModel;
using GPS.ViewModels;
using GPS.ViewModels.Master;
using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Master
{
    public class PurchasingGroupRepository
    {
        public const String DataName = "purchasinggrp";

        private readonly IDBContext db;
        public PurchasingGroupRepository()
        {
            db = DatabaseManager.Instance.GetContext();
            db.SetExecutionMode(DBContextExecutionMode.Direct);
        }

        public sealed class SqlFile
        {
            public const String CreateUploadTempTable = "PurchasingGroup/CreateUploadTempTable";
            public const String InsertUploadTempTable = "PurchasingGroup/InsertUploadTempTable";
            public const String GetUploadTempTable = "PurchasingGroup/GetUploadTempTable";
            public const String MoveUploadTempTableToRealTable = "PurchasingGroup/MoveUploadTempTableToRealTable";
        }

        public void SavePurchasingGroupUploadFile(String fileName, Int32 fileSize, Stream fileStream)
        {
            try
            {
                db.BeginTransaction();
                db.SetExecutionMode(DBContextExecutionMode.ByName); //To execute query from SQL Files (because default executionmode in this repo is "Direct"

                SaveExcelFileContentToTemp(fileStream, db);
                ValidateExcelContent(db);

                db.Execute(SqlFile.MoveUploadTempTableToRealTable);
                db.CommitTransaction();
            }
            catch (Exception)
            {
                db.AbortTransaction();
                throw;
            }
            finally
            {
                db.Close();
            }
        }

        private void SaveExcelFileContentToTemp(Stream fileStream, IDBContext db)
        {
            var excelWorkbook = new HSSFWorkbook(fileStream);
            ISheet firstSheet = excelWorkbook.GetSheetAt(0);
            Int32 rowCount = firstSheet.LastRowNum;
            if (firstSheet.SheetName != "PurchasingGroup")
                throw new Exception("Please use right template.");

            if (rowCount < 1)
                throw new InvalidOperationException("Uploaded file is invalid.");

            db.Execute(SqlFile.CreateUploadTempTable);
            
            for (int i = 1; i <= rowCount; i++)
            {
                IRow currentRow = firstSheet.GetRow(i);
                dynamic args = new
                {
                    PurchasingGrpCode = Convert.ToString(currentRow.GetCell(0)),
                    PurchasingGrpDesc = Convert.ToString(currentRow.GetCell(1)),
                    ProcChannelCode = Convert.ToString(currentRow.GetCell(2))
                };

                if (args.PurchasingGrpCode == String.Empty &&
                    args.PurchasingGrpDesc == String.Empty &&
                    args.ProcChannelCode == String.Empty)
                    break;

                db.Execute(SqlFile.InsertUploadTempTable, args);
            }
        }

        private void ValidateExcelContent(IDBContext db)
        {
            var validationErrorBuilder = new StringBuilder();
            List<PurchasingGroup> tempDataList = db.Fetch<PurchasingGroup>(SqlFile.GetUploadTempTable).ToList();
            Int32 rowNo = 2;
            foreach (PurchasingGroup data in tempDataList)
            {
                if (data.PurchasingGroupCode == String.Empty)
                    validationErrorBuilder.AppendLine("Failed to upload, Purchasing Group Code is empty. Row: " + rowNo);
                if (data.Description == String.Empty)
                    validationErrorBuilder.AppendLine("Failed to upload, Purchasing Group Desc is empty. Row: " + rowNo);
                if (data.ProcChannelCode == String.Empty)
                    validationErrorBuilder.AppendLine("Failed to upload, Procurement Channel Code is empty. Row: " + rowNo);

                rowNo++;
            }

            if (validationErrorBuilder.ToString() != String.Empty)
                throw new Exception(validationErrorBuilder.ToString());
        }

        public PurchasingGroup GetByCode(String procChannelCode, String code)
        {
            String query = "EXEC sp_PurchasingGroup_GetByCode @ProcChannelCode, @Code";
            PurchasingGroup result = db.SingleOrDefault<PurchasingGroup>(query, new { ProcChannelCode = procChannelCode, Code = code });
            db.Close();

            return result;
        }

        public IList<PurchasingGroup> GetList()
        {
            IList<PurchasingGroup> result = db.Fetch<PurchasingGroup>("EXEC sp_PurchasingGroup_GetList");
            db.Close();

            return result;
        }

        public IList<PurchasingGroup> GetList(PurchasingGroupSearchViewModel searchViewModel)
        {
            String query = "EXEC sp_PurchasingGroup_GetListBySearch @Code, @Desc, @CurrentPage, @PageSize";
            IList<PurchasingGroup> result = db.Fetch<PurchasingGroup>(query, searchViewModel);
            db.Close();

            return result;
        }

        public PaginationViewModel GetListPaging(PurchasingGroupSearchViewModel searchViewModel)
        {
            var model = new PaginationViewModel();
            model.DataName = DataName;
            model.TotalDataCount = GetListCount(searchViewModel);
            model.PageIndex = searchViewModel.CurrentPage;
            model.PageSize = searchViewModel.PageSize;

            return model;
        }

        private Int32 GetListCount(PurchasingGroupSearchViewModel searchViewModel)
        {
            String query = "EXEC sp_PurchasingGroup_GetListBySearchCount @Code, @Desc";
            Int32 result = db.SingleOrDefault<Int32>(query, searchViewModel);
            db.Close();

            return result;
        }

        public IList<PurchasingGroup> GetListByUserRegNo(String regNo)
        {
            String query = "EXEC sp_POCommon_GetPurchasingGroup @CurrentRegNo";
            IList<PurchasingGroup> result = db.Fetch<PurchasingGroup>(query, new { CurrentRegNo = regNo });
            db.Close();

            return result;
        }

        public IEnumerable<String> Delete(String primaryKeyList)
        {
            String query = "EXEC sp_PurchasingGroup_Delete @PrimaryKeyList";
            String result = db.ExecuteScalar<String>(query, new { PrimaryKeyList = primaryKeyList });
            db.Close();

            var resultViewModel = result.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return primaryKeyList
                .Split(',')
                .Select(splitted =>
                {
                    var itemList = splitted.Split(';');
                    return itemList[0] + " - " + itemList[1];
                });
        }

        public void Save(String editMode, String currentUser, String procChannelCode, String code, String desc)
        {
            String query = "EXEC sp_PurchasingGroup_Save @EditMode, @CurrentUser, @ProcChannelCode, @Code, @Desc";
            String result = db.ExecuteScalar<String>(query, new { EditMode = editMode, CurrentUser = currentUser, ProcChannelCode = procChannelCode, Code = code, Desc = desc });
            db.Close();

            var resultViewModel = result.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);
        }

        public IList<PurchasingGroupUser> GetUserListByCode(String purchasingGroup)
        {
            String query = "EXEC sp_PurchasingGroup_GetUserListByCode @PurchasingGroup";
            IList<PurchasingGroupUser> result = db.Fetch<PurchasingGroupUser>(query, new { PurchasingGroup = purchasingGroup });
            db.Close();

            return result;
        }

        public IList<NameValueItem> GetUserMapDivisionList()
        {
            IList<NameValueItem> result = db.Fetch<NameValueItem>("EXEC sp_PurchasingGroup_GetUserMapDivisionList");
            db.Close();

            return result;
        }

        public IList<NameValueItem> GetUserMapDepartmentList(String divisionId)
        {
            IList<NameValueItem> result = db.Fetch<NameValueItem>("EXEC sp_PurchasingGroup_GetUserMapDepartmentList @DivisionId", new { DivisionId = divisionId });
            db.Close();

            return result;
        }

        public IList<NameValueItem> GetUserMapSectionList(String divisionId, String deptId)
        {
            IList<NameValueItem> result = db.Fetch<NameValueItem>("EXEC sp_PurchasingGroup_GetUserMapSectionList @DivisionId, @DeptId", new { DivisionId = divisionId, DeptId = deptId });
            db.Close();

            return result;
        }

        public ActionResponseViewModel DeleteUserMap(String purchasingGroup, IEnumerable<String> regNoList)
        {
            String paramString = regNoList.AsDelimitedString(regNo => regNo);
            String query = "EXEC sp_PurchasingGroup_DeleteUserMap @PurchasingGroup, @RegNoList";
            String result = db.ExecuteScalar<String>(query, new { PurchasingGroup = purchasingGroup, RegNoList = paramString });
            db.Close();

            var resultViewModel = result.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return resultViewModel;
        }

        public ActionResponseViewModel SaveUserMap(String purchasingGroup, String regNo, String divisionId, String deptId, String sectionId, String currentUser)
        {
            String query = "EXEC sp_PurchasingGroup_SaveUserMap @PurchasingGroup, @RegNo, @DivisionId, @DeptId, @SectionId, @CurrentUser";
            dynamic param = new { PurchasingGroup = purchasingGroup, RegNo = regNo, DivisionId = divisionId, DeptId = deptId, SectionId = sectionId, CurrentUser = currentUser };
            String result = db.ExecuteScalar<String>(query, param);
            db.Close();

            var resultViewModel = result.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return resultViewModel;
        }

        public ActionResponseViewModel CheckRegNo(String regNo)
        {
            String result = db.ExecuteScalar<String>("EXEC sp_PurchasingGroup_CheckRegNo @RegNo", new { RegNo = regNo });
            db.Close();

            var resultViewModel = result.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return resultViewModel;
        }
    }
}