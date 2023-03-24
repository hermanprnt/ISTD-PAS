using System;
using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.MRP
{
    public class MRPParentRepository
    {
        private MRPParentRepository() { }
        private static MRPParentRepository instance = null;
        public static MRPParentRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new MRPParentRepository();
                }
                return instance;
            }
        }

        public int CountData(string ParentCode, string ParentType)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                ParentCode = ParentCode,
                ParentType = ParentType                             
            };

            int result = db.SingleOrDefault<int>("MRP/Parent/CountData", args);
            db.Close();

            return result;
        }

        public IEnumerable<MRPParent> GetListData(string ParentCode, string ParentType, int start, int length)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                ParentCode = ParentCode,
                ParentType = ParentType,                              
                Start = start,
                Length = length
            };

            IEnumerable<MRPParent> result = db.Fetch<MRPParent>("MRP/Parent/GetData", args);
            db.Close();
            return result;
        }


        public MRPParent GetSingleData(string ParentCode, string ParentType)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                ParentCode = ParentCode,
                ParentType = ParentType
            };

            MRPParent result = db.SingleOrDefault<MRPParent>("MRP/Parent/GetSingleData", args);
            db.Close();
            return result;
        }

        public string SaveData(string flag, MRPParent data)
        {
            string result = "";
            try
            {
                IDBContext db = DatabaseManager.Instance.GetContext();
                dynamic args = new
                {
                    Flag = flag,
                    UserName = data.USER_NAME,
                    ParentCodeHide = data.PARENT_CD_HIDE,
                    ParentCode = data.PARENT_CD,
                    ParentType = data.PARENT_TYPE,
                    ParentTypeHide = data.PARENT_TYPE_HIDE
                };
                result = db.SingleOrDefault<string>("MRP/Parent/SaveData", args);
               
                db.Close();
            }
            catch (Exception err)
            {
                result = "Error| " + Convert.ToString(err.Message);
            }
            return result;
        }

        public string DeleteData(string key, string ParentCode, string ParentType)
        {
            string result = "";
            try
            {
                IDBContext db = DatabaseManager.Instance.GetContext();
                if (key.Contains(","))
                {
                    string[] ParentCodelist = ParentCode.Split(';');
                    string[] ParentTypelist = ParentType.Split(';');

                    for (int i = 0; i < ParentCodelist.Length; i++)
                    {
                        var l = db.Fetch<MRPParent>("MRP/Parent/DeleteData", new
                        {
                            ParentCode = ParentCodelist[i],
                            ParentType = ParentTypelist[i]
                        });
                    }
                }
                else
                {
                    var l = db.Fetch<MRPParent>("MRP/Parent/DeleteData", new
                    {
                        ParentCode = ParentCode,
                        ParentType = ParentType
                    });
                }
                result = "Delete successfully";
                db.Close();
            }
            catch (Exception err)
            {
                result = "Error | " + Convert.ToString(err.Message);
            }
            return result;
        }

        public IEnumerable<MRPParent> GetDownloadData(string ParentCode, string ParentType)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                ParentCode = ParentCode,
                ParentType = ParentType              
            };

            IEnumerable<MRPParent> result = db.Fetch<MRPParent>("MRP/Parent/DownloadData", args);
            db.Close();
            return result;
        }

        public int DELETE_TB_T()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            int result = db.Execute("MRP/Parent/DELETE_TB_T");
            db.Close();

            return result;
        }

        public int INSERT_TB_T(int row, int LINE, MRPParent data)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                row = row,
                LINE = LINE,
                ParentCode = data.PARENT_CD,
                ParentType = data.PARENT_TYPE                
            };

            int result = db.Execute("MRP/Parent/INSERT_TB_T", args);
            db.Close();

            return result;
        }

        public string UploadToDatabase(string UserName, Int64 PROCESS_ID)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                USER_ID = UserName,
                PROCESS_ID = PROCESS_ID               
            };

            string Message = db.SingleOrDefault<string>("MRP/Parent/UploadData", args);
            db.Close();

            return Message;
        }
       
        public int Log_Header(Int64 ProcessId, string ModuleID, string FunctionID, string Status, string UserId)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                PROCESS_ID = ProcessId,
                ModuleID = ModuleID,
                FunctionID = FunctionID,
                Status = Status,
                USER_ID = UserId                         
            };

            int result = db.Execute("MRP/Parent/Log_H", args);
            db.Close();

            return result;
        }

    }
}