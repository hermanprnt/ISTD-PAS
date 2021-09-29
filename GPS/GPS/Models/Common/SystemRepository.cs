using System;
using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Common
{
    public class SystemRepository
    {
        public sealed class SqlFile
        {
            public const String GetByFunctionId = "Master/System/GetByFunctionId";
            public const String GetByCode = "Master/System/GetByCode";
        }

        private SystemRepository() { }
        private static SystemRepository instance = null;
        public static SystemRepository Instance
        {
            get { return instance ?? (instance = new SystemRepository()); }
        }

        public String GetSystemValue(String systemCode)
        {
            SystemMaster system = GetByCode(systemCode);
            return system == null ? String.Empty : system.Value;
        }

        private SystemMaster GetByCode(String systemCode)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            SystemMaster result = db.SingleOrDefault<SystemMaster>(SqlFile.GetByCode, new { SystemCode = systemCode });
            db.Close();

            return result;
        }

        public IEnumerable<SystemMaster> GetByFunctionId(String functionId)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<SystemMaster> result = db.Fetch<SystemMaster>(SqlFile.GetByFunctionId, new { FunctionId = functionId });
            db.Close();

            return result;
        }

        public String GetUploadDataFileExtension()
        {
            return GetSystemValue("DATA_FILE_EXTS");
        }

        public String GetUploadDocumentFileExtension()
        {
            return GetSystemValue("DOCUMENT_FILE_EXTS");
        }

        public String GetUploadFileSizeLimit()
        {
            return GetSystemValue("UPLOAD_MAX_FILE_SIZE");
        }

        //tambahan rendra
        public int CountData(string Code, string Value)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                Code = Code,
                Value = Value
            };

            int result = db.SingleOrDefault<int>("Master/System/CountData", args);
            db.Close();

            return result;
        }

        public IEnumerable<SystemMaster> GetListData(string Code, string Value, int start, int length)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                Code = Code,
                Value = Value,
                Start = start,
                Length = length
            };

            IEnumerable<SystemMaster> result = db.Fetch<SystemMaster>("Master/System/GetData", args);
            db.Close();
            return result;
        }

        public SystemMaster GetSingleData(string FunctionID, string Code)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                FunctionID = FunctionID,
                Code = Code
            };

            SystemMaster result = db.SingleOrDefault<SystemMaster>("Master/System/GetSingleData", args);
            db.Close();
            return result;
        }

        public string SaveData(string flag, SystemMaster data, string UserName)
        {
            string result = "";
            try
            {
                IDBContext db = DatabaseManager.Instance.GetContext();
                dynamic args = new
                {
                    Flag = flag,
                    FunctionId = data.FunctionId,
                    Code = data.Code,
                    Value = data.Value,
                    Remark = data.Remark,
                    UserName = UserName
                };
                result = db.SingleOrDefault<string>("Master/System/SaveData", args);

                db.Close();
            }
            catch (Exception err)
            {
                result = "Error| " + Convert.ToString(err.Message);
            }
            return result;
        }

        public String DeleteData(String Key)
        {
            string result = "";
            try
            {
                IDBContext db = DatabaseManager.Instance.GetContext();

                foreach (String data in Key.Split(','))
                {
                    String[] cols = data.Split(';');

                    result = db.SingleOrDefault<string>("Master/System/DeleteData", new { FunctionID = cols[0], Code = cols[1] });

                }
                db.Close();
            }
            catch (Exception ex)
            {
                result = "Error| " + Convert.ToString(ex.Message);
            }

            return result;
        }
    }
}