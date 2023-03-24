using System;
using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.MRP
{
    public class MRPGentaniHeaderRepository
    {
        private MRPGentaniHeaderRepository() { }
        private static MRPGentaniHeaderRepository instance = null;
        public static MRPGentaniHeaderRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new MRPGentaniHeaderRepository();
                }
                return instance;
            }
        }

        public IEnumerable<MRPGentaniHeader> ListParentCd()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<MRPGentaniHeader> result = db.Fetch<MRPGentaniHeader>("MRP/GentaniHeader/ListParentCd");
            db.Close();
            return result;
        }

        public IEnumerable<MRPGentaniHeader> ListProcUsage()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<MRPGentaniHeader> result = db.Fetch<MRPGentaniHeader>("MRP/GentaniHeader/ListProcUsage");
            db.Close();
            return result;
        }

        public IEnumerable<MRPGentaniHeader> ListHeaderType()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<MRPGentaniHeader> result = db.Fetch<MRPGentaniHeader>("MRP/GentaniHeader/ListHeaderType");
            db.Close();
            return result;
        }       

        public string GetListHeaderCode(string HeaderType)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string result = "";
            dynamic args = new
            {
                HeaderType = HeaderType
            };
            List<MRPGentaniHeader> resultquery = db.Fetch<MRPGentaniHeader>("MRP/GentaniHeader/ListHeaderCode", args);
            foreach (var item in resultquery)
            {
                result = result + item.GENTANI_HEADER_CD + ";" + item.GENTANI_HEADER_CD + "|";
            }
            db.Close();
            return result;
        }

        public int CountData(string ProcUsage, string HeaderType, string HeaderCd, string ValidDt, string Model, string Engine, string Transmission, string DE, string ProdSfx, string Color)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {                
                ProcUsage = ProcUsage,
                HeaderType = HeaderType,
                HeaderCd = HeaderCd,               
                ValidDt = ValidDt,
                Model= Model, 
                Engine= Engine, 
                Transmission= Transmission, 
                DE= DE, 
                ProdSfx= ProdSfx, 
                Color= Color              
            };

            int result = db.SingleOrDefault<int>("MRP/GentaniHeader/CountData", args);
            db.Close();

            return result;
        }

        public IEnumerable<MRPGentaniHeader> GetListData(string ProcUsage, string HeaderType, string HeaderCd, string ValidDt, string Model, string Engine, string Transmission, string DE, string ProdSfx, string Color,
                                                        int start, int length)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                ProcUsage = ProcUsage,
                HeaderType = HeaderType,
                HeaderCd = HeaderCd,                             
                ValidDt = ValidDt,               
                Start = start,
                Length = length,
                Model= Model, 
                Engine= Engine, 
                Transmission= Transmission, 
                DE= DE, 
                ProdSfx= ProdSfx, 
                Color= Color
            };

            IEnumerable<MRPGentaniHeader> result = db.Fetch<MRPGentaniHeader>("MRP/GentaniHeader/GetData", args);
            db.Close();
            return result;
        }


        public MRPGentaniHeader GetSingleData(string ProcUsage, string HeaderType, string HeaderCd, string ValidDt)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                ProcUsage = ProcUsage,
                HeaderType = HeaderType,
                HeaderCd = HeaderCd,               
                ValidDt = ValidDt
            };

            MRPGentaniHeader result = db.SingleOrDefault<MRPGentaniHeader>("MRP/GentaniHeader/GetSingleData", args);
            db.Close();
            return result;
        }

        public string SaveData(string flag, MRPGentaniHeader data)
        {
            string result = "";
            try
            {
                IDBContext db = DatabaseManager.Instance.GetContext();
                dynamic args = new
                {
                    Flag = flag,                    
                    ProcUsage = data.PROC_USAGE_CD,
                    UserName = data.USER_NAME,
                    HeaderType = data.GENTANI_HEADER_TYPE,
                    HeaderCd = data.GENTANI_HEADER_CD,
                    HeaderCd_hidden = data.GENTANI_HEADER_CD_hidden,                
                    ValidFrom = data.VALID_DT_FR,
                    ValidTo = data.VALID_DT_TO,
                    Model = data.MODEL,
                    Transmission = data.TRANSMISSION,
                    Engine = data.ENGINE,
                    DE = data.DE,
                    ProdSfx= data.PROD_SFX,
                    Color= data.COLOR
                };
                result = db.SingleOrDefault<string>("MRP/GentaniHeader/SaveData", args);
               
                db.Close();
            }
            catch (Exception err)
            {
                result = "Error| " + Convert.ToString(err.Message);
            }
            return result;
        }

        public string DeleteData(string key, string ProcUsage, string HeaderType, string HeaderCd, string ValidDt)
        {
            string result = "";
            try
            {
                IDBContext db = DatabaseManager.Instance.GetContext();
                if (key.Contains(","))
                {                    
                    string[] ProcUsagelist = ProcUsage.Split(';');
                    string[] HeaderTypelist = HeaderType.Split(';');                  
                    string[] HeaderCdlist = HeaderCd.Split(';');                   
                    string[] ValidDtlist = ValidDt.Split(';');

                    for (int i = 0; i < ProcUsagelist.Length; i++)
                    {
                        var l = db.Fetch<MRPGentaniHeader>("MRP/GentaniHeader/DeleteData", new
                        {                            
                            ProcUsage = ProcUsagelist[i],
                            HeaderType = HeaderTypelist[i],
                            HeaderCd = HeaderCdlist[i],                           
                            ValidDt = ValidDtlist[i]
                        });
                    }
                }
                else
                {
                    var l = db.Fetch<MRPGentaniHeader>("MRP/GentaniHeader/DeleteData", new
                    {                        
                        ProcUsage = ProcUsage,
                        HeaderType = HeaderType,
                        HeaderCd = HeaderCd,                       
                        ValidDt = ValidDt
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

        public IEnumerable<MRPGentaniHeader> GetDownloadData(string ProcUsage, string HeaderType, string HeaderCd, string ValidDt)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {                
                ProcUsage = ProcUsage,
                HeaderType = HeaderType,
                HeaderCd = HeaderCd,               
                ValidDt = ValidDt
            };

            IEnumerable<MRPGentaniHeader> result = db.Fetch<MRPGentaniHeader>("MRP/GentaniHeader/DownloadData", args);
            db.Close();
            return result;
        }

        public int DELETE_TB_T()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            int result = db.Execute("MRP/GentaniHeader/DELETE_TB_T");
            db.Close();

            return result;
        }

        public int INSERT_TB_T(int row, int LINE, MRPGentaniHeader data)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                row = row,
                LINE = LINE,               
                PROC_USAGE_CD = data.PROC_USAGE_CD,
                GENTANI_HEADER_TYPE = data.GENTANI_HEADER_TYPE,
                GENTANI_HEADER_CD = data.GENTANI_HEADER_CD,                            
                VALID_DT_FR = data.VALID_DT_FR,
                VALID_DT_TO = data.VALID_DT_TO
            };

            int result = db.Execute("MRP/GentaniHeader/INSERT_TB_T", args);
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

            string Message = db.SingleOrDefault<string>("MRP/GentaniHeader/UploadData", args);
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

            int result = db.Execute("MRP/GentaniHeader/Log_H", args);
            db.Close();

            return result;
        }

    }
}