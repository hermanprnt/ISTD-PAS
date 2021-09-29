using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using GPS.CommonFunc;
using GPS.Core;
using GPS.Core.ViewModel;
using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;
using GPS.Models.Common;
using GPS.ViewModels;
using GPS.ViewModels.Lookup;
using GPS.ViewModels.Master;
using ServiceStack.Text;
using GPS.Constants;

namespace GPS.Models.Master
{
    public class MaterialRepository
    {
        public sealed class SqlFile
        {
            public const String _Root_Folder = "Master/Material/";

            public const String Initial = _Root_Folder + "Initial";
            public const String InsertUploadTemp = _Root_Folder + "InsertUploadTemp";
            public const String GetUploadTempList = _Root_Folder + "GetUploadTempList";
            public const String MoveUploadTemp = _Root_Folder + "MoveUploadTemp";
            public const String LookupSearchList = _Root_Folder + "GetMaterialLookupList";
            public const String LookupSearchListCount = _Root_Folder + "GetMaterialLookupListCount";

            public const String GetData = _Root_Folder + "ReadMaterial";
            public const String CountData = _Root_Folder + "CountTotalMaterial";
            public const String CountMatNo = _Root_Folder + "CountMaterialNumber";

            public const String InsertData = _Root_Folder + "InsertMaterial";
            public const String InsertTemp = _Root_Folder + "InsertMaterialTemp";
            public const String UpdateData = _Root_Folder + "UpdateMaterial";
            public const String GetSingleData = _Root_Folder + "GetSingleMaterial";

            public const String Delete = _Root_Folder + "DeleteMaterial";

            public const String GetMaterialImageInfo = _Root_Folder + "GetMaterialImageInfo";
            public const String UpdateMaterialImage = _Root_Folder + "UpdateMaterialImage";
        }

        private MaterialRepository() { }
        private static MaterialRepository instance = null;

        public static MaterialRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new MaterialRepository();
                }
                return instance;
            }
        }

        #region GET DATA
        public List<Material> GetData(int start, int end, string kelas, string mat_no, string mat_desc, string uom,
                                       string mrp_type, string valuation_class, string proc_usage, string asset_flag, string quota_flag)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                Start = start,
                End = end,
                Kelas = kelas,
                MAT_NO = mat_no,
                MAT_DESC = mat_desc,
                UOM = uom,
                MRP_TYPE = mrp_type,
                VALUATION_CLASS = valuation_class,
                PROC_USAGE_CD = proc_usage,
                ASSET_FLAG = asset_flag,
                QUOTA_FLAG = quota_flag
            };
            List<Material> list = db.Fetch<Material>(SqlFile.GetData, args);
            db.Close();
            return list;
        }

        public int CountData(string kelas, string mat_no, string mat_desc, string uom, string mrp_type, string valuation_class, string proc_usage, string asset_flag, string quota_flag)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                Kelas = kelas,
                MAT_NO = mat_no,
                MAT_DESC = mat_desc,
                UOM = uom,
                MRP_TYPE = mrp_type,
                VALUATION_CLASS = valuation_class,
                PROC_USAGE_CD = proc_usage,
                ASSET_FLAG = asset_flag,
                QUOTA_FLAG = quota_flag
            };
            int count = db.SingleOrDefault<int>(SqlFile.CountData, args);
            db.Close();
            return count;
        }

        public int CountMaterialNumber(string Kelas, string mat_no)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                Kelas = Kelas,
                MAT_NO = mat_no
            };
            int count = db.SingleOrDefault<int>(SqlFile.CountMatNo, args);
            db.Close();
            return count;
        }
        #endregion

        #region ADD / UPDATE
        public Tuple<List<Material>, string, int> SaveData(string Kelas, Material mat, int valid, string userid)
        {
            List<Material> listmat = new List<Material>();
            string message = "";
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                Kelas = Kelas,
                MAT_NO = mat.MaterialNo,
                MAT_DESC = mat.MaterialDesc,
                mat.UOM,
                CAR_FAMILY_CD = mat.CarFamilyCode,
                MAT_TYPE_CD = mat.MaterialTypeCode,
                MAT_GRP_CD = mat.MaterialGroupCode,
                MRP_TYPE = mat.MRPType,
                RE_ORDER_VALUE = mat.ReOrderValue,
                RE_ORDER_METHOD = mat.ReOrderMethod,
                STD_DELIVERY_TIME = mat.StandardDelivTime,
                AVG_DAILY_CONSUMPTION = mat.AvgDailyConsump,
                MIN_STOCK = mat.MinStock,
                MAX_STOCK = mat.MaxStock,
                PCS_PER_KANBAN = mat.PcsPerKanban,
                MRP_FLAG = mat.MRPFlag,
                VALUATION_CLASS = mat.ValuationClass,
                STOCK_FLAG = mat.StockFlag,
                ASSET_FLAG = mat.AssetFlag,
                QUOTA_FLAG = mat.QuotaFlag,
                CONSIGNMENT_CD = mat.ConsignmentCode,
                PROC_USAGE_CD = mat.ProcUsageCode,
                MATL_GROUP = mat.MatlGroup,
                DELETION_FLAG = mat.DeletionFlag,
                USERID = userid
            };
            if (mat.DataNo == 1)
            {
                if (CountMaterialNumber(Kelas, mat.MaterialNo) == 0)
                {
                    message = db.SingleOrDefault<string>(SqlFile.InsertData, args);
                    valid = 1;
                }
                else valid = 0;
            }
            else
            {
                message = db.SingleOrDefault<string>(SqlFile.UpdateData, args);
                valid = 1;
            }
            db.Close();
            return new Tuple<List<Material>, string, int>(listmat, message, valid);
        }

        public Material GetSingleData(string kelas, string criteria)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                Kelas = kelas,
                Criteria = criteria
            };

            Material result = db.SingleOrDefault<Material>(SqlFile.GetSingleData, args);
            db.Close();
            return result;
        }
        #endregion

        #region DELETE
        public string DeleteData(string kelas, string mat_no, string userid)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                Kelas = kelas,
                MAT_NO = mat_no,
                USER_ID = userid
            };
            string result = db.SingleOrDefault<string>(SqlFile.Delete, args);
            db.Close();
            return result;
        }
        #endregion

        #region UPLOAD
        public void SaveMaterialUploadFile(String fileName, Int32 fileSize, Stream fileStream, String currentUser, String processId)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            SaveExcelFileContentToTemp(fileStream, currentUser, processId, db);
            ValidateExcelContent(processId, db);

            db.Execute(SqlFile.MoveUploadTemp, new { ProcessId = processId });
            db.Close();
        }

        private void SaveExcelFileContentToTemp(Stream fileStream, String currentUser, String processId, IDBContext db)
        {
            HSSFWorkbook excelWorkbook = new HSSFWorkbook(fileStream);
            ISheet firstSheet = excelWorkbook.GetSheetAt(0);
            Int32 rowCount = firstSheet.LastRowNum;
            if (firstSheet.SheetName != "Material")
                throw new Exception("Please use right template.");

            for (int i = 1; i <= rowCount; i++)
            {
                IRow currentRow = firstSheet.GetRow(i);
                dynamic args = new
                {
                    CurrentUser = currentUser,
                    ProcessId = processId,
                    Class = currentRow.GetCell(0).GetString(),
                    MaterialNo = currentRow.GetCell(1).GetString(),
                    MaterialDesc = currentRow.GetCell(2).GetString(),
                    MaterialTypeCode = currentRow.GetCell(3).GetString(),
                    MaterialGroupCode = currentRow.GetCell(4).GetString(),
                    UoM = currentRow.GetCell(5).GetString(),
                    ValuationClass = currentRow.GetCell(6).GetString(),
                    MRPType = currentRow.GetCell(7).GetString(),
                    CarFamilyCode = currentRow.GetCell(8).GetString(),
                    ConsignmentCode = currentRow.GetCell(9).GetString(),
                    ProcUsageCode = currentRow.GetCell(10).GetString(),
                    ReorderValue = currentRow.GetCell(11).GetDecimal(),
                    ReorderMethod = currentRow.GetCell(12).GetString(),
                    StandardDelivTime = currentRow.GetCell(13).GetInt16(),
                    AvgDailyConsump = currentRow.GetCell(14).GetDecimal(),
                    MinStock = currentRow.GetCell(15).GetDecimal(),
                    MaxStock = currentRow.GetCell(16).GetDecimal(),
                    PcsPerKanban = currentRow.GetCell(17).GetDecimal(),
                    MRPFlag = currentRow.GetCell(18).GetString(),
                    AssetFlag = currentRow.GetCell(19).GetString(),
                    QuotaFlag = currentRow.GetCell(20).GetString(),
                    StockFlag = currentRow.GetCell(21).GetString()
                };

                if (args.Class == String.Empty &&
                    args.MaterialNo == String.Empty &&
                    args.MaterialDesc == String.Empty &&
                    args.MaterialTypeCode == String.Empty &&
                    args.MaterialGroupCode == String.Empty &&
                    args.UoM == String.Empty &&
                    args.ValuationClass == String.Empty &&
                    args.MRPType == String.Empty &&
                    args.CarFamilyCode == String.Empty &&
                    args.ConsignmentCode == String.Empty &&
                    args.ProcUsageCode == String.Empty &&
                    args.ReorderValue == 0 &&
                    args.ReorderMethod == String.Empty &&
                    args.StandardDelivTime == 0 &&
                    args.AvgDailyConsump == 0 &&
                    args.MinStock == 0 &&
                    args.MaxStock == 0 &&
                    args.PcsPerKanban == 0 &&
                    args.MRPFlag == String.Empty &&
                    args.AssetFlag == String.Empty &&
                    args.QuotaFlag == String.Empty &&
                    args.StockFlag == String.Empty)
                    break;

                db.Execute(SqlFile.InsertUploadTemp, args);
            }
        }

        private void ValidateExcelContent(String processId, IDBContext db)
        {
            var validationErrorBuilder = new StringBuilder();
            List<Material> tempDataList = db.Fetch<Material>(SqlFile.GetUploadTempList, new { ProcessId = processId }).ToList();
            Int32 rowNo = 2;
            foreach (Material data in tempDataList)
            {
                if (data.MaterialNo == String.Empty)
                    validationErrorBuilder.AppendLine("Failed to upload, Material No is empty. Row: " + rowNo);
                if (data.MaterialDesc == String.Empty)
                    validationErrorBuilder.AppendLine("Failed to upload, Material Desc is empty. Row: " + rowNo);
                if (data.UOM == String.Empty)
                    validationErrorBuilder.AppendLine("Failed to upload, UoM is empty. Row: " + rowNo);
                if (data.MaterialTypeCode == String.Empty)
                    validationErrorBuilder.AppendLine("Failed to upload, Material Type Code is empty. Row: " + rowNo);
                if (data.MRPFlag == String.Empty)
                    validationErrorBuilder.AppendLine("Failed to upload, MRP Flag is empty. Row: " + rowNo);
                if (data.ValuationClass == String.Empty)
                    validationErrorBuilder.AppendLine("Failed to upload, Valuation Class is empty. Row: " + rowNo);
                if (data.StockFlag == String.Empty)
                    validationErrorBuilder.AppendLine("Failed to upload, Stock Flag is empty. Row: " + rowNo);
                if (data.AssetFlag == String.Empty)
                    validationErrorBuilder.AppendLine("Failed to upload, Asset Flag is empty. Row: " + rowNo);
                if (data.QuotaFlag == String.Empty)
                    validationErrorBuilder.AppendLine("Failed to upload, Quota Flag is empty. Row: " + rowNo);
                rowNo++;
            }

            if (validationErrorBuilder.ToString() != String.Empty)
                throw new Exception(validationErrorBuilder.ToString());
        }

        public String Initial(ExecProcedureModel execParam)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            InitialActionResult result = db.SingleOrDefault<InitialActionResult>(SqlFile.Initial, execParam);
            db.Close();

            var resultViewModel = result.Message.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return result.ProcessId;
        }
        #endregion

        #region LOOKUP
        public IList<Material> GetMaterialLookupList(MaterialLookupSearchViewModel searchViewModel)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IList<Material> result = db.Fetch<Material>(SqlFile.LookupSearchList, searchViewModel);
            db.Close();

            return result;
        }

        public PaginationViewModel GetMaterialLookupListPaging(MaterialLookupSearchViewModel searchViewModel)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            var model = new PaginationViewModel();
            model.DataName = "material";
            model.TotalDataCount = db.ExecuteScalar<Int32>(SqlFile.LookupSearchListCount, searchViewModel);
            model.PageIndex = searchViewModel.CurrentPage;
            model.PageSize = searchViewModel.PageSize;

            db.Close();

            return model;
        }
        #endregion

        public MaterialImageViewModel GetMaterialImage(String matNo)
        {
            MaterialImageViewModel imageInfo = GetMaterialImageInfo(matNo);
            if (!String.IsNullOrEmpty(imageInfo.MatImageName))
            {
                String absoluteImagePath = GetMaterialImageAbsolutePath(imageInfo.MatImageName);
                imageInfo.MatImage = ConvertImageToBase64(absoluteImagePath);
            }
            else
                imageInfo = GetDefaultMaterialImageInfo(imageInfo);

            return imageInfo;
        }

        private String GetMaterialImageAbsolutePath(String imageName)
        {
            SystemMaster sys = SystemRepository.Instance.GetSingleData("EC", "IMAGE_PATH");
            String absoluteImagePath = Path.Combine(sys.Value, imageName);
            if (!Directory.Exists(sys.Value))
                Directory.CreateDirectory(sys.Value);

            return absoluteImagePath;
        }

        private MaterialImageViewModel GetMaterialImageInfo(String matNo)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            var result = db.SingleOrDefault<MaterialImageViewModel>(SqlFile.GetMaterialImageInfo, new { MatNo = matNo });
            db.Close();

            return result;
        }

        private MaterialImageViewModel GetDefaultMaterialImageInfo(MaterialImageViewModel imageInfo)
        {
            imageInfo.MatImageName = "not-found.gif";
            String absoluteImagePath = Path.Combine(System.Web.HttpContext.Current.Server.MapPath("~/Content/Images/Catalogue"), imageInfo.MatImageName);
            imageInfo.MatImage = ConvertImageToBase64(absoluteImagePath);

            return imageInfo;
        }

        private String ConvertImageToBase64(String imagePath)
        {
            var fileInfo = new FileInfo(imagePath);
            var fileBytes = new Byte[fileInfo.Length];
            using (FileStream fs = fileInfo.OpenRead())
                fs.Read(fileBytes, 0, fileBytes.Length);
            String base64 = new StringBuilder()
                .Append("data:image/")
                .Append(Path.GetExtension(imagePath).Replace(".", String.Empty))
                .Append(";base64,")
                .Append(Convert.ToBase64String(fileBytes))
                .ToString();
            return base64;
        }

        public void SaveMaterialUploadImage(String fileName, Int32 fileSize, Stream fileStream, String currentUser, String processId, String matNo)
        {
            String absoluteImagePath = GetMaterialImageAbsolutePath(fileName);
            using (var streamToSave = new FileStream(absoluteImagePath, FileMode.Create))
            {
                fileStream.WriteTo(streamToSave);
                streamToSave.Flush();
            }

            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                CurrentUser = currentUser,
                ProcessId = processId,
                ModuleId = ModuleId.MasterData,
                FunctionId = FunctionId.Material,
                MatNo = matNo,
                Filename = fileName
            };
            db.Execute(SqlFile.UpdateMaterialImage, args);
            db.Close();
        }
    }
}