using System;
using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;
using System.IO;
using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;
using NPOI.XSSF.UserModel;

namespace GPS.Models.Asset
{
    public class AssetRepository
    {
        #region List Of SQL Files
        public sealed class SqlFile
        {
            public const String _Root_Folder = "Asset/";

            public const String GetSearchList = _Root_Folder + "get_searchList";
            public const String CountSearchList = _Root_Folder + "count_searchList";
            public const String DeleteData = _Root_Folder + "delete_dataAsset";
            public const String DownloadData = _Root_Folder + "download_dataAsset";
            public const String GetTemp = _Root_Folder + "get_tempAsset";
            public const String SaveTemp = _Root_Folder + "save_tempAsset";
            public const String TempValidation = _Root_Folder + "validate_tempAsset";
            public const String DeleteTemp = _Root_Folder + "delete_tempAsset";
            public const String SaveValidation = _Root_Folder + "validate_saveAsset";
            public const String DeleteSelectedTemp = _Root_Folder + "delete_selectedTemp";
            public const String CancelSaving = _Root_Folder + "cancel_saveAsset";
            public const String SaveData = _Root_Folder + "save_dataAsset";
        }
        #endregion

        private AssetRepository() { }
        private static AssetRepository instance = null;

        public static AssetRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new AssetRepository();
                }
                return instance;
            }
        }

        #region SEARCH
        public Tuple<List<AssetUpload>, string> ListData(AssetUpload param, int start, int length)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            List<AssetUpload> result = new List<AssetUpload>();
            string message = "";
            try
            {
                dynamic args = new
                {
                    param.PR_NO,
                    param.STATUS_CD,
                    param.ITEM_NO,
                    param.ASSET_NO,
                    param.ASSET_CATEGORY,
                    param.SUBASSET_NO,
                    param.ASSET_CLASS,
                    param.REGISTRATION_DATE_FROM,
                    param.REGISTRATION_DATE_TO,
                    Start = start,
                    Length = length
                };
                result = db.Fetch<AssetUpload>(SqlFile.GetSearchList, args);
            }
            catch(Exception e) {
                message = e.Message;
            }
            finally { 
                db.Close();
            }

            return new Tuple<List<AssetUpload>,string>(result, message);
        }

        public Tuple<int, string> CountRetrievedData(AssetUpload param)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            int result = 0;
            string message = "";
            try
            {
                dynamic args = new
                {
                    param.PR_NO,
                    param.STATUS_CD,
                    param.ITEM_NO,
                    param.ASSET_NO,
                    param.ASSET_CATEGORY,
                    param.SUBASSET_NO,
                    param.ASSET_CLASS,
                    param.REGISTRATION_DATE_FROM,
                    param.REGISTRATION_DATE_TO
                };

                result = db.SingleOrDefault<int>(SqlFile.CountSearchList, args);
            }
            catch (Exception e)
            {
                message = e.Message;
            }
            finally
            {
                db.Close();
            }
            return new Tuple<int,string>(result, message);
        }
        #endregion

        #region UPLOAD
        public void SaveTemp(string filepath, string userid, string PROCESS_ID)
        {
            ISheet firstSheet;

            if (Path.GetExtension(filepath) == ".xls")
            {
                HSSFWorkbook excelWorkbook = new HSSFWorkbook(new FileStream(filepath, FileMode.Open, FileAccess.Read));
                firstSheet = excelWorkbook.GetSheetAt(0);
            }
            else {
                XSSFWorkbook excelWorkbook = new XSSFWorkbook(new FileStream(filepath, FileMode.Open, FileAccess.Read));
                firstSheet = excelWorkbook.GetSheetAt(0);
            }
            
            Int32 rowCount = firstSheet.LastRowNum;
            if (firstSheet.SheetName != "ASSET_UPLOAD")
                throw new Exception("Please use right template.");

            for (int i = 1; i <= rowCount; i++)
            {
                IRow currentRow = firstSheet.GetRow(i);
                dynamic args = new
                {
                    USER_ID = userid,
                    PROCESS_ID,
                    PR_NO = currentRow.GetCell(0) == null ? "" : currentRow.GetCell(0).ToString(),
                    ITEM_NO = currentRow.GetCell(1) == null ? "" : currentRow.GetCell(1).ToString(),
                    SEQ_NO = currentRow.GetCell(2) ==  null ? "" : currentRow.GetCell(2).ToString(),
                    ASSET_CATEGORY = currentRow.GetCell(3) == null ? "" : currentRow.GetCell(3).ToString(),
                    ASSET_CLASS = currentRow.GetCell(4) == null ? "" : currentRow.GetCell(4).ToString(),
                    ASSET_LOCATION = currentRow.GetCell(5) == null ? "" : currentRow.GetCell(5).ToString(),
                    REGISTRATION_DT = currentRow.GetCell(6) == null ? "" : currentRow.GetCell(6).ToString(),
                    ASSET_NO = currentRow.GetCell(7) == null ? "" : currentRow.GetCell(7).ToString(),
                    SUB_ASSET_NO = currentRow.GetCell(8) == null ? "" : currentRow.GetCell(8).ToString(),
                    SERIAL_NO = currentRow.GetCell(9) == null ? "" : currentRow.GetCell(9).ToString()
                };

                if (String.IsNullOrEmpty(args.PR_NO) && String.IsNullOrEmpty(args.ITEM_NO) && String.IsNullOrEmpty(args.SEQ_NO)
                    && String.IsNullOrEmpty(args.ASSET_CATEGORY) && String.IsNullOrEmpty(args.ASSET_CLASS) && String.IsNullOrEmpty(args.ASSET_LOCATION)
                    && String.IsNullOrEmpty(args.REGISTRATION_DT) && String.IsNullOrEmpty(args.ASSET_NO) && String.IsNullOrEmpty(args.SUB_ASSET_NO)
                    && String.IsNullOrEmpty(args.SERIAL_NO))
                { break; }

                IDBContext db = DatabaseManager.Instance.GetContext();
                db.Execute(SqlFile.SaveTemp, args);
                db.Close();
            }
        }

        public void ValidateTemp(string PROCESS_ID)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            db.Execute(SqlFile.TempValidation, new { PROCESS_ID });
            db.Close();
        }

        public void DeleteTemp(string PROCESS_ID)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            db.Execute(SqlFile.DeleteTemp, new { PROCESS_ID });
            db.Close();
        }

        public Tuple<List<AssetUpload>, string, string> GetTemp(string PROCESS_ID)
        {
            List<AssetUpload> result = new List<AssetUpload>();
            string message = "";

            IDBContext db = DatabaseManager.Instance.GetContext();
            try
            {
                dynamic args = new
                {
                    PROCESS_ID
                };
                result = db.Fetch<AssetUpload>(SqlFile.GetTemp, args);
            }
            catch (Exception ex)
            {
                message = ex.Message;
            }
            finally 
            {
                db.Close();
            }

            return new Tuple<List<AssetUpload>, string, string>(result, PROCESS_ID, message);
        }

        public Tuple<string, string> SaveValidation(string PROCESS_ID)
        {
            string status = "";
            string message = "";

            IDBContext db = DatabaseManager.Instance.GetContext();
            try
            {
                AssetUpload res = db.SingleOrDefault<AssetUpload>(SqlFile.SaveValidation, new { PROCESS_ID });
                status = res.PROCESS_STATUS;
                message = res.MESSAGE;
            }
            catch (Exception ex)
            {
                status = "ERR";
                message = ex.Message;
            }
            finally 
            {
                db.Close();
            }

            return new Tuple<string, string>(status, message);
        }

        public string DeleteSelectedTemp(AssetUpload param)
        {
            string message = "";

            IDBContext db = DatabaseManager.Instance.GetContext();
            try
            {
                dynamic args = new 
                {
                    param.PR_NO,
                    param.ITEM_NO,
                    param.SEQ_NO,
                    param.PROCESS_ID
                };
                message = db.ExecuteScalar<string>(SqlFile.DeleteSelectedTemp, args);
            }
            catch (Exception ex)
            {
                message = "ERR|" + ex.Message;
            }
            finally
            { 
                db.Close();
            }

            return message;
        }

        public string CancelSaving(string PROCESS_ID)
        {
            string message = "";

            IDBContext db = DatabaseManager.Instance.GetContext();
            try
            {
                dynamic args = new
                {
                    PROCESS_ID
                };
                message = db.ExecuteScalar<string>(SqlFile.CancelSaving, args);
            }
            catch (Exception ex)
            {
                message = "ERR|" + ex.Message;
            }
            finally
            {
                db.Close();
            }

            return message;
        }

        public Tuple<string, string> SaveData(string PROCESS_ID)
        {
            string status = "";
            string message = "";

            IDBContext db = DatabaseManager.Instance.GetContext();
            try
            {
                AssetUpload res = db.SingleOrDefault<AssetUpload>(SqlFile.SaveData, new { PROCESS_ID });
                status = res.PROCESS_STATUS;
                message = res.MESSAGE;
            }
            catch (Exception ex)
            {
                status = "ERR";
                message = ex.Message;
            }
            finally
            {
                db.Close();
            }

            return new Tuple<string, string>(status, message);
        }
        #endregion

        #region DELETE
        public string DeleteData(AssetUpload param)
        {
            string message = "";

            IDBContext db = DatabaseManager.Instance.GetContext();
            try
            {
                dynamic args = new
                {
                    param.PR_NO,
                    param.ITEM_NO,
                    param.SEQ_NO
                };
                message = db.ExecuteScalar<string>(SqlFile.DeleteData, args);
            }
            catch (Exception ex)
            {
                message = "ERR|" + ex.Message;
            }
            finally
            {
                db.Close();
            }

            return message;
        }
        #endregion


        #region DOWNLOAD
        public IEnumerable<AssetUpload> DownloadData(AssetUpload param)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                param.PR_NO,
                param.STATUS_CD,
                param.ITEM_NO,
                param.ASSET_NO,
                param.ASSET_CATEGORY,
                param.SUBASSET_NO,
                param.ASSET_CLASS,
                param.REGISTRATION_DATE_FROM,
                param.REGISTRATION_DATE_TO,
            };
            IEnumerable<AssetUpload> result = db.Fetch<AssetUpload>("Asset/download_dataAsset", args);
            db.Close();
            return result;
        }
        #endregion
    }
}