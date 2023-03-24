using System;
using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.MRP
{
    public class MRPParentHikiateRepository
    {
        private MRPParentHikiateRepository() { }
        private static MRPParentHikiateRepository instance = null;
        public static MRPParentHikiateRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new MRPParentHikiateRepository();
                }
                return instance;
            }
        }

        public IEnumerable<MRPParentHikiate> ListParentCd()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<MRPParentHikiate> result = db.Fetch<MRPParentHikiate>("MRP/ParentHikiate/ListParentCd");
            db.Close();
            return result;
        }

        public IEnumerable<MRPParentHikiate> ListProcUsage()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<MRPParentHikiate> result = db.Fetch<MRPParentHikiate>("MRP/ParentHikiate/ListProcUsage");
            db.Close();
            return result;
        }

        public IEnumerable<MRPParentHikiate> ListHeaderType()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<MRPParentHikiate> result = db.Fetch<MRPParentHikiate>("MRP/ParentHikiate/ListHeaderType");
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
            List<MRPParentHikiate> resultquery = db.Fetch<MRPParentHikiate>("MRP/ParentHikiate/ListHeaderCode", args);
            foreach (var item in resultquery)
            {
                result = result + item.GENTANI_HEADER_CD + ";" + item.GENTANI_HEADER_CD + "|";
            }
            db.Close();
            return result;
        }       

        public int CountData(string ParentCd, string ProcUsage, string HeaderType, string HeaderCd, string ValidDt,string Model, string Engine, string Trans,
                                                        string DE, string ProdSfx, string Color)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                ParentCd = ParentCd,
                ProcUsage = ProcUsage,
                HeaderType = HeaderType,
                HeaderCd = HeaderCd,
                ValidDt = ValidDt,
                Model = Model,
                Engine = Engine,
                DE = DE,
                Transmission = Trans,
                ProdSfx = ProdSfx,
                Color = Color
            };

            int result = db.SingleOrDefault<int>("MRP/ParentHikiate/CountData", args);
            db.Close();

            return result;
        }

        public IEnumerable<MRPParentHikiate> GetListData(string ParentCd, string ProcUsage, string HeaderType, string HeaderCd, string ValidDt,string Model, string Engine, string Trans,
                                                        string DE, string ProdSfx, string Color,
                                                        int start, int length)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                ParentCd = ParentCd,
                ProcUsage = ProcUsage,
                HeaderType = HeaderType,
                HeaderCd = HeaderCd,                             
                ValidDt = ValidDt,               
                Start = start,
                Length = length,
                Model = Model,
                Engine = Engine,
                DE = DE,
                Transmission = Trans,
                ProdSfx = ProdSfx,
                Color = Color      
            };

            IEnumerable<MRPParentHikiate> result = db.Fetch<MRPParentHikiate>("MRP/ParentHikiate/GetData", args);
            db.Close();
            return result;
        }

        public int CountDataParentCd(string ParentCd)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                ParentCd = ParentCd
            };

            int result = db.SingleOrDefault<int>("MRP/ParentHikiate/CountDataParentCd", args);
            db.Close();

            return result;
        }

        public IEnumerable<MRPParentHikiate> GetListDataParentCd(string ParentCd, int start, int length)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                ParentCd = ParentCd,
                Start = start,
                Length = length
            };

            List<MRPParentHikiate> result = db.Fetch<MRPParentHikiate>("MRP/ParentHikiate/GetDataParentCd", args);
            db.Close();
            return result;
        }


        public MRPParentHikiate GetSingleData(string ParentCd, string ProcUsage,string Model, string HeaderType, string HeaderCd, string ValidDt)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                ParentCd = ParentCd,
                ProcUsage = ProcUsage,
                Model = Model,
                HeaderType = HeaderType,
                HeaderCd = HeaderCd,               
                ValidDt = ValidDt
            };

            MRPParentHikiate result = db.SingleOrDefault<MRPParentHikiate>("MRP/ParentHikiate/GetSingleData", args);
            db.Close();
            return result;
        }

        public string SaveData(string flag, MRPParentHikiate data)
        {
            string result = "";
            try
            {
                IDBContext db = DatabaseManager.Instance.GetContext();
                dynamic args = new
                {
                    Flag = flag,
                    UserName = data.USER_NAME,
                    ParentCode = data.PARENT_CD,
                    ProcUsage = data.PROC_USAGE_CD,
                    HeaderType = data.GENTANI_HEADER_TYPE,
                    HeaderCd = data.GENTANI_HEADER_CD,                  
                    UsageQty = data.MULTIPLY_USAGE,                   
                    ValidFrom = data.VALID_DT_FR,
                    ValidTo = data.VALID_DT_TO
                };
                result = db.SingleOrDefault<string>("MRP/ParentHikiate/SaveData", args);
               
                db.Close();
            }
            catch (Exception err)
            {
                result = "Error| " + Convert.ToString(err.Message);
            }
            return result;
        }

        public string DeleteData(string key, string ParentCd, string ProcUsage, string HeaderType, string HeaderCd, string ValidDt)
        {
            string result = "";
            try
            {
                IDBContext db = DatabaseManager.Instance.GetContext();
                if (key.Contains(","))
                {
                    string[] ParentCdlist = ParentCd.Split(';');
                    string[] ProcUsagelist = ProcUsage.Split(';');
                    string[] HeaderTypelist = HeaderType.Split(';');                  
                    string[] HeaderCdlist = HeaderCd.Split(';');                   
                    string[] ValidDtlist = ValidDt.Split(';');

                    for (int i = 0; i < ProcUsagelist.Length; i++)
                    {
                        var l = db.Fetch<MRPParentHikiate>("MRP/ParentHikiate/DeleteData", new
                        {
                            ParentCd = ParentCdlist[i],
                            ProcUsage = ProcUsagelist[i],
                            HeaderType = HeaderTypelist[i],
                            HeaderCd = HeaderCdlist[i],                           
                            ValidDt = ValidDtlist[i]
                        });
                    }
                }
                else
                {
                    var l = db.Fetch<MRPParentHikiate>("MRP/ParentHikiate/DeleteData", new
                    {
                        ParentCd = ParentCd,
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

        public IEnumerable<MRPParentHikiate> GetDownloadData(string ParentCd, string ProcUsage, string HeaderType, string HeaderCd, string ValidDt)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                ParentCd = ParentCd,
                ProcUsage = ProcUsage,
                HeaderType = HeaderType,
                HeaderCd = HeaderCd,               
                ValidDt = ValidDt
            };

            IEnumerable<MRPParentHikiate> result = db.Fetch<MRPParentHikiate>("MRP/ParentHikiate/DownloadData", args);
            db.Close();
            return result;
        }

        public int DELETE_TB_T()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            int result = db.Execute("MRP/ParentHikiate/DELETE_TB_T");
            db.Close();

            return result;
        }

        public int INSERT_TB_T(int row, int LINE, MRPParentHikiate data)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                row = row,
                LINE = LINE,
                PARENT_CD = data.PARENT_CD,
                PROC_USAGE_CD = data.PROC_USAGE_CD,
                GENTANI_HEADER_TYPE = data.GENTANI_HEADER_TYPE,
                GENTANI_HEADER_CD = data.GENTANI_HEADER_CD,
                USAGE_QTY = data.MULTIPLY_USAGE_STRING,               
                VALID_DT_FR = data.VALID_DT_FR,
                VALID_DT_TO = data.VALID_DT_TO
            };

            int result = db.Execute("MRP/ParentHikiate/INSERT_TB_T", args);
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

            string Message = db.SingleOrDefault<string>("MRP/ParentHikiate/UploadData", args);
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

            int result = db.Execute("MRP/ParentHikiate/Log_H", args);
            db.Close();

            return result;
        }

    }
}