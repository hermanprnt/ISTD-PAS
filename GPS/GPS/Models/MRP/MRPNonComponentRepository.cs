using System;
using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.MRP
{
    public class MRPNonComponentRepository
    {
        private MRPNonComponentRepository() { }
        private static MRPNonComponentRepository instance = null;
        public static MRPNonComponentRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new MRPNonComponentRepository();
                }
                return instance;
            }
        }

        public IEnumerable<MRPNonComponent> ListProcUsage()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<MRPNonComponent> result = db.Fetch<MRPNonComponent>("MRP/NonComponent/ListProcUsage");
            db.Close();
            return result;
        }

        public IEnumerable<MRPNonComponent> ListHeaderType()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<MRPNonComponent> result = db.Fetch<MRPNonComponent>("MRP/NonComponent/ListHeaderType");
            db.Close();
            return result;
        }

        public IEnumerable<MRPNonComponent> ListPlantCode()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<MRPNonComponent> result = db.Fetch<MRPNonComponent>("MRP/NonComponent/ListPlantCode");
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
            List<MRPNonComponent> resultquery = db.Fetch<MRPNonComponent>("MRP/NonComponent/ListHeaderCode", args);
            foreach (var item in resultquery)
            {
                result = result + item.GENTANI_HEADER_CD + ";" + item.GENTANI_HEADER_CD + "|";
            }
            db.Close();
            return result;
        }

        public string GetListStorageLoc(string PlantCd)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string result = "";
            dynamic args = new
            {
                PlantCd = PlantCd
            };
            List<MRPNonComponent> resultquery = db.Fetch<MRPNonComponent>("MRP/NonComponent/ListStorageLoc", args);
            foreach (var item in resultquery)
            {
                result = result + item.STORAGE_LOCATION + ";" + item.SLOC_NAME + "|";
            }
            db.Close();
            return result;
        }

        public int CountData(string ProcUsage, string HeaderType, string HeaderCd, string MatNo, string ValidDt, string Model, string Engine, string Trans,
                                                        string DE, string ProdSfx, string Color)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                ProcUsage = ProcUsage,
                HeaderType = HeaderType,
                HeaderCd = HeaderCd,
                MatNo = MatNo,
                ValidDt = ValidDt,
                Model = Model,
                Engine = Engine,
                DE = DE,
                Transmission = Trans,
                ProdSfx = ProdSfx,
                Color = Color              
            };

            int result = db.SingleOrDefault<int>("MRP/NonComponent/CountData", args);
            db.Close();

            return result;
        }

        public IEnumerable<MRPNonComponent> GetListData(string ProcUsage, string HeaderType, string HeaderCd, string MatNo, string ValidDt, string Model, string Engine, string Trans,
                                                        string DE, string ProdSfx, string Color, int start, int length)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                ProcUsage = ProcUsage,
                HeaderType = HeaderType,
                HeaderCd = HeaderCd,
                MatNo = MatNo,               
                ValidDt = ValidDt,               
                Start = start,
                Length = length,
                Model =Model,
                Engine= Engine,
                DE = DE,
                Transmission= Trans,
                ProdSfx=ProdSfx,
                Color= Color
            };

            IEnumerable<MRPNonComponent> result = db.Fetch<MRPNonComponent>("MRP/NonComponent/GetData", args);
            db.Close();
            return result;
        }

        public int CountDataMatNo(string MatNo)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {               
                MatNo = MatNo              
            };

            int result = db.SingleOrDefault<int>("MRP/NonComponent/CountDataMatNo", args);
            db.Close();

            return result;
        }

        public string checkMaterial(string MatNo)
        {
            string result = "";
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                MatNo = MatNo
            };

            result = db.SingleOrDefault<string>("MRP/NonComponent/CheckMatNo", args);
            db.Close();
            return result;
        }

        public IEnumerable<MRPNonComponent> GetListDataMatNo(string MatNo,int start, int length)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {               
                MatNo = MatNo,              
                Start = start,
                Length = length
            };

            List<MRPNonComponent> result = db.Fetch<MRPNonComponent>("MRP/NonComponent/GetDataMatNo", args);
            db.Close();
            return result;
        }

        public MRPNonComponent GetSingleData(string ProcUsage, string HeaderType, string HeaderCd, string MatNo,string Model, string ValidDt)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                ProcUsage = ProcUsage,
                HeaderType = HeaderType,
                HeaderCd = HeaderCd,
                Model=Model,
                MatNo = MatNo,
                ValidDt = ValidDt
            };

            MRPNonComponent result = db.SingleOrDefault<MRPNonComponent>("MRP/NonComponent/GetSingleData", args);
            db.Close();
            return result;
        }

        public string SaveData(string flag, MRPNonComponent data)
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
                    HeaderType = data.GENTANI_HEADER_TYPE,
                    HeaderCd = data.GENTANI_HEADER_CD,
                    MatNo = data.MAT_NO,
                    UsageQty = data.USAGE_QTY,
                    Uom = data.UOM,
                    PlantCd = data.PLANT_CD,
                    Storage = data.STORAGE_LOCATION,
                    ValidFrom = data.VALID_DT_FR,
                    ValidTo = data.VALID_DT_TO
                };
                result = db.SingleOrDefault<string>("MRP/NonComponent/SaveData", args);
               
                db.Close();
            }
            catch (Exception err)
            {
                result = "Error| " + Convert.ToString(err.Message);
            }
            return result;
        }

        public string DeleteData(string key, string ProcUsage, string HeaderType, string HeaderCd, string MatNo, string ValidDt)
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
                    string[] MatNolist = MatNo.Split(';');
                    string[] ValidDtlist = ValidDt.Split(';');

                    for (int i = 0; i < ProcUsagelist.Length; i++)
                    {
                        var l = db.Fetch<MRPNonComponent>("MRP/NonComponent/DeleteData", new
                        {
                            ProcUsage = ProcUsagelist[i],
                            HeaderType = HeaderTypelist[i],
                            HeaderCd = HeaderCdlist[i],
                            MatNo = MatNolist[i],
                            ValidDt = ValidDtlist[i]
                        });
                    }
                }
                else
                {
                    var l = db.Fetch<MRPNonComponent>("MRP/NonComponent/DeleteData", new
                    {
                        ProcUsage = ProcUsage,
                        HeaderType = HeaderType,
                        HeaderCd = HeaderCd,
                        MatNo = MatNo,
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

        public IEnumerable<MRPNonComponent> GetDownloadData(string ProcUsage, string HeaderType, string HeaderCd, string MatNo, string ValidDt)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                ProcUsage = ProcUsage,
                HeaderType = HeaderType,
                HeaderCd = HeaderCd,
                MatNo = MatNo,
                ValidDt = ValidDt
            };

            IEnumerable<MRPNonComponent> result = db.Fetch<MRPNonComponent>("MRP/NonComponent/DownloadData", args);
            db.Close();
            return result;
        }

        public int DELETE_TB_T()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            int result = db.Execute("MRP/NonComponent/DELETE_TB_T");
            db.Close();

            return result;
        }

        public int INSERT_TB_T(int row, int LINE, MRPNonComponent data)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                row = row,
                LINE = LINE,
                PROC_USAGE_CD = data.PROC_USAGE_CD,
                GENTANI_HEADER_TYPE = data.GENTANI_HEADER_TYPE,
                GENTANI_HEADER_CD = data.GENTANI_HEADER_CD,
                MAT_NO = data.MAT_NO,
                USAGE_QTY = data.USAGE_QTY_STRING,
                UOM = data.UOM,
                PLANT_CD = data.PLANT_CD,
                STORAGE_LOCATION = data.STORAGE_LOCATION,
                VALID_DT_FR = data.VALID_DT_FR,
                VALID_DT_TO = data.VALID_DT_TO
            };

            int result = db.Execute("MRP/NonComponent/INSERT_TB_T", args);
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

            string Message = db.SingleOrDefault<string>("MRP/NonComponent/UploadData", args);
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

            int result = db.Execute("MRP/NonComponent/Log_H", args);
            db.Close();

            return result;
        }

    }
}