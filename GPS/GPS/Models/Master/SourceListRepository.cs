using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Master
{
    public class SourceListRepository
    {
        public sealed class SqlFile
        {
            public const String _Root_Folder = "Master/SourceList/";

            public const String GetData = _Root_Folder + "ReadSourceList";
            public const String CountData = _Root_Folder + "CountData";
            public const String GetSingleData = _Root_Folder + "GetSingleData";

            public const String InsertData = _Root_Folder + "InsertSourceList";
            public const String UpdateData = _Root_Folder + "UpdateSourceList";
            public const String ValidateDelete = _Root_Folder + "ValidationDeleteSourceList";
            public const String DeleteData = _Root_Folder + "DeleteSourceList";

            public const String SaveUpload = _Root_Folder + "MoveUploadTempToRealTable";
            public const String CreateTemp = _Root_Folder + "CreateUploadTempTable";
            public const String InsertTemp = _Root_Folder + "InsertUploadTempTable";
            public const String GetTemp = _Root_Folder + "GetUploadTempTable";
            public const String ValidationDate = _Root_Folder + "ValidationValidDate";
        }

        private SourceListRepository() { }
        private static SourceListRepository instance = null;
        public static SourceListRepository Instance
        {
            get { return instance ?? (instance = new SourceListRepository()); }
        }

        #region COMMON LIST
        public string GetListVendorCd()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string result = "";
            dynamic args = new
            {
                matno = ""
            };

            List<Vendor> resultquery = db.Fetch<Vendor>("Master/GetVendorCD", args);
            foreach (var item in resultquery)
            {
                result = result + item.VendorCd + ";" + item.VendorName + "|";
            }
            db.Close();
            return result;
        }

        public IEnumerable<Material> GetMaterial()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<Material> result = db.Fetch<Material>("Master/GetMaterial");
            db.Close();
            return result;
        }

        public string GetListMatNo()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string result = "";
            dynamic args = new
            {
                matno = ""
            };
            List<Material> resultquery = db.Fetch<Material>("Master/GetMaterial", args);
            foreach (var item in resultquery)
            {
                result = result + item.MaterialNo + ";" + item.MaterialDesc + "|";
            }
            db.Close();
            return result;
        }
        #endregion

        #region SEARCH
        public List<SourceList> GetData(int start, int end, string mat_no, string vendor_cd, string valid_from, string valid_to,
                                            string created_by, string created_dt, string changed_by, string changed_dt)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                Start = start,
                End = end,
                MAT_NO = mat_no,
                VENDOR_CD = vendor_cd,
                VALID_DT_FROM = valid_from,
                VALID_DT_TO = valid_to,
                CREATED_BY = created_by,
                CREATED_DT = created_dt,
                CHANGED_BY = changed_by,
                CHANGED_DT = changed_dt
            };
            List<SourceList> list = db.Fetch<SourceList>(SqlFile.GetData, args);
            db.Close();
            return list;
        }

        public int CountData(string mat_no, string vendor_cd, string valid_from, string valid_to,
                            string created_by, string created_dt, string changed_by, string changed_dt)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                MAT_NO = mat_no,
                VENDOR_CD = vendor_cd,
                VALID_DT_FROM = valid_from,
                VALID_DT_TO = valid_to,
                CREATED_BY = created_by,
                CREATED_DT = created_dt,
                CHANGED_BY = changed_by,
                CHANGED_DT = changed_dt
            };
            int count = db.SingleOrDefault<int>(SqlFile.CountData, args);
            db.Close();
            return count;
        }
        #endregion

        #region ADD / UPDATE
        public string SaveData(SourceList sl, string username)
        {
            string result;                                                                                                         
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                sl.MAT_NO,
                sl.VENDOR_CD,
                sl.VALID_DT_FROM,
                username
            };

            result = db.SingleOrDefault<string>(sl.Number == 1 ? SqlFile.InsertData : SqlFile.UpdateData, args);
            db.Close();

            return result;
        }

        public SourceList GetSingleData(string mat_no, string vendor_cd)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                MAT_NO = mat_no,
                VENDOR_CD = vendor_cd
            };

            SourceList result = db.SingleOrDefault<SourceList>(SqlFile.GetSingleData, args);
            db.Close();
            return result;
        }
        #endregion

        #region DELETE
        public string DeleteDataValidation(string mat_no, string vendor_cd)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                MAT_NO = mat_no,
                VENDOR_CD = vendor_cd
            };

            string result = db.SingleOrDefault<string>(SqlFile.ValidateDelete, args);
            db.Close();

            return result;
        }

        public int DeleteData(string mat_no, string vendor_cd)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                MAT_NO = mat_no,
                VENDOR_CD = vendor_cd
            };

            int result = db.SingleOrDefault<int>(SqlFile.DeleteData, args);
            db.Close();

            return result;
        }
        #endregion

        #region UPLOAD
        public string SaveSourceListUploadFile(String fileName, Int32 fileSize, Stream fileStream, string uid)
        {
            string result = "Successfully Upload Data Source List";
            IDBContext db = DatabaseManager.Instance.GetContext();
            try
            {
                db.BeginTransaction();

                SaveExcelFileContentToTemp(fileStream, uid, db);
                ValidateExcelContent(db);

                db.Execute(SqlFile.SaveUpload);
                db.CommitTransaction();
            }
            catch (Exception err)
            {
                db.AbortTransaction();
                result = "Error: " + err.Message;
            }
            finally
            {
                db.Close();
            }
            return result;
        }

        private void SaveExcelFileContentToTemp(Stream fileStream, string uid, IDBContext db)
        {
            HSSFWorkbook excelWorkbook = new HSSFWorkbook(fileStream);
            ISheet firstSheet = excelWorkbook.GetSheetAt(0);
            Int32 rowCount = firstSheet.LastRowNum;
            if (firstSheet.SheetName != "SourceList")
                throw new Exception("Please use right template.");

            db.Execute(SqlFile.CreateTemp);

            for (int i = 1; i <= rowCount; i++)
            {
                IRow currentRow = firstSheet.GetRow(i);
                dynamic args = new
                {
                    MaterialNo = Convert.ToString(currentRow.GetCell(0)),
                    VendorCode = Convert.ToString(currentRow.GetCell(1)),
                    ValidDateFrom = Convert.ToString(currentRow.GetCell(2)),
                    uid = uid
                };

                if (args.MaterialNo == String.Empty &&
                    args.VendorCode == String.Empty &&
                    args.ValidDateFrom == String.Empty 
                    )
                    break;

                db.Execute(SqlFile.InsertTemp, args);
            }
        }

        private void ValidateExcelContent(IDBContext db)
        {
            var validationErrorBuilder = new StringBuilder();
            List<SourceList> tempDataList = db.Fetch<SourceList>(SqlFile.GetTemp).ToList();
            Int32 rowNo = 1;
            foreach (SourceList data in tempDataList)
            {
                if (data.MAT_NO == String.Empty)
                    validationErrorBuilder.AppendLine("Failed to upload, Material No is empty. Row: " + rowNo);
                if (data.VENDOR_CD == String.Empty)
                    validationErrorBuilder.AppendLine("Failed to upload, Vendor Code is empty. Row: " + rowNo);
                if(!String.IsNullOrEmpty(data.MAT_NO) && !String.IsNullOrEmpty(data.VENDOR_CD) && !String.IsNullOrEmpty(data.VALID_DT_FROM))
                {
                    dynamic args = new {
                        MAT_NO = data.MAT_NO,
                        VALID_DT_FROM = data.VALID_DT_FROM
                    };
                    if (db.SingleOrDefault<int>(SqlFile.ValidationDate, args) > 0)
                        validationErrorBuilder.AppendLine("Cannot entry new source list when valid date equal or lower than existing valid date. Row: " + rowNo);
                }
                rowNo++;
            }

            if (validationErrorBuilder.ToString() != String.Empty)
                throw new Exception(validationErrorBuilder.ToString());
        }
        #endregion
    }
}