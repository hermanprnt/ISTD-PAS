using System;
using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.MRP
{
    public class MRPGentaniTypeRepository
    {
        private MRPGentaniTypeRepository() { }
        private static MRPGentaniTypeRepository instance = null;
        public static MRPGentaniTypeRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new MRPGentaniTypeRepository();
                }
                return instance;
            }
        }     

        public IEnumerable<MRPGentaniType> ListProcUsage()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<MRPGentaniType> result = db.Fetch<MRPGentaniType>("MRP/GentaniType/ListProcUsage");
            db.Close();
            return result;
        }        

        public int CountData(string ProcUsage, string HeaderType, string Model)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {                
                ProcUsage = ProcUsage,
                HeaderType = HeaderType,
                Model = Model                     
            };

            int result = db.SingleOrDefault<int>("MRP/GentaniType/CountData", args);
            db.Close();

            return result;
        }

        public IEnumerable<MRPGentaniType> GetListData(string ProcUsage, string HeaderType,string Model, int start, int length)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                ProcUsage = ProcUsage,
                HeaderType = HeaderType,
                Model = Model,                           
                Start = start,
                Length = length
            };

            IEnumerable<MRPGentaniType> result = db.Fetch<MRPGentaniType>("MRP/GentaniType/GetData", args);
            db.Close();
            return result;
        }


        public MRPGentaniType GetSingleData(string ProcUsage, string HeaderType, string Model)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                ProcUsage = ProcUsage,
                HeaderType = HeaderType,
                Model = Model
            };

            MRPGentaniType result = db.SingleOrDefault<MRPGentaniType>("MRP/GentaniType/GetSingleData", args);
            db.Close();
            return result;
        }

        public string SaveData(string flag, MRPGentaniType data)
        {
            string result = "";
            try
            {
                IDBContext db = DatabaseManager.Instance.GetContext();
                dynamic args = new
                {
                    Flag = flag,
                    UserName = data.USER_NAME,
                    ProcUsage = data.PROC_USAGE_CD,
                    Model= data.MODEL,
                    HeaderType = data.GENTANI_HEADER_TYPE,
                    HeaderTypehidden = data.GENTANI_HEADER_TYPE_hidden,
                    Desc = data.DESCRIPTION
                };
                result = db.SingleOrDefault<string>("MRP/GentaniType/SaveData", args);
               
                db.Close();
            }
            catch (Exception err)
            {
                result = "Error| " + Convert.ToString(err.Message);
            }
            return result;
        }

        public string DeleteData(string key, string ProcUsage, string HeaderType, string Model)
        {
            string result = "";
            try
            {
                IDBContext db = DatabaseManager.Instance.GetContext();
                if (key.Contains(","))
                {                    
                    string[] ProcUsagelist = ProcUsage.Split(';');
                    string[] HeaderTypelist = HeaderType.Split(';');
                    string[] Modellist = Model.Split(';');            

                    for (int i = 0; i < ProcUsagelist.Length; i++)
                    {
                        var l = db.Fetch<MRPGentaniType>("MRP/GentaniType/DeleteData", new
                        {                            
                            ProcUsage = ProcUsagelist[i],
                            HeaderType = HeaderTypelist[i],
                            Model = Modellist[i]                     
                        });
                    }
                }
                else
                {
                    var l = db.Fetch<MRPGentaniType>("MRP/GentaniType/DeleteData", new
                    {                        
                        ProcUsage = ProcUsage,
                        HeaderType = HeaderType  ,
                        Model = Model
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

        public IEnumerable<MRPGentaniType> GetDownloadData(string ProcUsage, string HeaderType, string Model)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {                
                ProcUsage = ProcUsage,
                HeaderType = HeaderType,
                Model = Model  
            };

            IEnumerable<MRPGentaniType> result = db.Fetch<MRPGentaniType>("MRP/GentaniType/DownloadData", args);
            db.Close();
            return result;
        }

        public int DELETE_TB_T()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            int result = db.Execute("MRP/GentaniType/DELETE_TB_T");
            db.Close();

            return result;
        }

        public int INSERT_TB_T(int row, int LINE, MRPGentaniType data)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                row = row,
                LINE = LINE,               
                PROC_USAGE_CD = data.PROC_USAGE_CD,
                GENTANI_HEADER_TYPE = data.GENTANI_HEADER_TYPE,
                DESCRIPTION = data.DESCRIPTION               
            };

            int result = db.Execute("MRP/GentaniType/INSERT_TB_T", args);
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

            string Message = db.SingleOrDefault<string>("MRP/GentaniType/UploadData", args);
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

            int result = db.Execute("MRP/GentaniType/Log_H", args);
            db.Close();

            return result;
        }

    }
}