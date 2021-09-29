using System;
using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.MRP
{
    public class MRPProcUsageRepository
    {
        private MRPProcUsageRepository() { }
        private static MRPProcUsageRepository instance = null;
        public static MRPProcUsageRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new MRPProcUsageRepository();
                }
                return instance;
            }
        }

        public int CountData(string ProcUsage, string Desc)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {                
                ProcUsage = ProcUsage,
                Desc = Desc                             
            };

            int result = db.SingleOrDefault<int>("MRP/ProcUsage/CountData", args);
            db.Close();

            return result;
        }

        public IEnumerable<MRPProcUsage> GetListData(string ProcUsage, string Desc, int start, int length)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                ProcUsage = ProcUsage,
                Desc = Desc,                              
                Start = start,
                Length = length
            };

            IEnumerable<MRPProcUsage> result = db.Fetch<MRPProcUsage>("MRP/ProcUsage/GetData", args);
            db.Close();
            return result;
        }


        public MRPProcUsage GetSingleData(string ProcUsage)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                ProcUsage = ProcUsage               
            };

            MRPProcUsage result = db.SingleOrDefault<MRPProcUsage>("MRP/ProcUsage/GetSingleData", args);
            db.Close();
            return result;
        }

        public string SaveData(string flag, MRPProcUsage data)
        {
            string result = "";
            try
            {
                IDBContext db = DatabaseManager.Instance.GetContext();
                dynamic args = new
                {
                    Flag = flag,
                    UserName = data.USER_NAME,
                    ProcUsageHide = data.PROC_USAGE_CD_HIDE,
                    ProcUsage = data.PROC_USAGE_CD,
                    Desc = data.DESCRIPTION                   
                };
                result = db.SingleOrDefault<string>("MRP/ProcUsage/SaveData", args);
               
                db.Close();
            }
            catch (Exception err)
            {
                result = "Error| " + Convert.ToString(err.Message);
            }
            return result;
        }

        public string DeleteData(string key, string ProcUsage)
        {
            string result = "";
            try
            {
                IDBContext db = DatabaseManager.Instance.GetContext();
                if (key.Contains(","))
                {                    
                    string[] ProcUsagelist = ProcUsage.Split(';');
                   
                    for (int i = 0; i < ProcUsagelist.Length; i++)
                    {
                        var l = db.Fetch<MRPProcUsage>("MRP/ProcUsage/DeleteData", new
                        {                            
                            ProcUsage = ProcUsagelist[i]                           
                        });
                    }
                }
                else
                {
                    var l = db.Fetch<MRPProcUsage>("MRP/ProcUsage/DeleteData", new
                    {                        
                        ProcUsage = ProcUsage                       
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

        public IEnumerable<MRPProcUsage> GetDownloadData(string ProcUsage, string Desc)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {                
                ProcUsage = ProcUsage,
                Desc = Desc              
            };

            IEnumerable<MRPProcUsage> result = db.Fetch<MRPProcUsage>("MRP/ProcUsage/DownloadData", args);
            db.Close();
            return result;
        }

        public int DELETE_TB_T()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            int result = db.Execute("MRP/ProcUsage/DELETE_TB_T");
            db.Close();

            return result;
        }

        public int INSERT_TB_T(int row, int LINE, MRPProcUsage data)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                row = row,
                LINE = LINE,               
                PROC_USAGE_CD = data.PROC_USAGE_CD,
                DESCRIPTION = data.DESCRIPTION                
            };

            int result = db.Execute("MRP/ProcUsage/INSERT_TB_T", args);
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

            string Message = db.SingleOrDefault<string>("MRP/ProcUsage/UploadData", args);
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

            int result = db.Execute("MRP/ProcUsage/Log_H", args);
            db.Close();

            return result;
        }

    }
}