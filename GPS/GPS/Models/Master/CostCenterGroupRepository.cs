using System;
using System.Collections.Generic;
using System.Linq;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Master
{
    public class CostCenterGroupRepository
    {
        private CostCenterGroupRepository() { }
        private static CostCenterGroupRepository instance = null;
        public static CostCenterGroupRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new CostCenterGroupRepository();
                }
                return instance;
            }
        }

        public IEnumerable<CostCenterGroup> GetLookupData()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            IEnumerable<CostCenterGroup> result = db.Fetch<CostCenterGroup>("Master/CostCenterGroup/LookupCostCenterGroup");

            db.Close();
            return result;
        }

        public int CountData(string CostGrpCd, string DivisionCd)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                CostGrpCd = CostGrpCd,
                DivisionCd = DivisionCd
            };

            int result = db.SingleOrDefault<int>("Master/CostCenterGroup/CountData", args);
            db.Close();

            return result;
        }

        public IEnumerable<CostCenterGroup> GetListData(string CostGroup, string DivisionCd, int start, int length)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                CostGroup = CostGroup,
                DivisionCd = DivisionCd,
                Start = start,
                Length = length
            };

            IEnumerable<CostCenterGroup> result = db.Fetch<CostCenterGroup>("Master/CostCenterGroup/GetData", args);
            
            db.Close();
            return result;
        }

        public string DeleteData(string Key)
        {
            try
            {
                IDBContext db = DatabaseManager.Instance.GetContext();
                
                foreach (string data in Key.Split(','))
                {
                    string[] cols = data.Split(';');
                    dynamic args = new
                    {
                        CostGroupCd = cols[0],
                        DivisionCd = cols[1]
                    };

                    db.Execute("Master/CostCenterGroup/DeleteData", args);

                }
                return "Data Deleted Successfully";
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }

        public string SaveData(string flag, string CostGroup, string CostGroupDesc, string DivisionCd, string uid)
        {
            string result = "";
            try
            {
                IDBContext db = DatabaseManager.Instance.GetContext();
                dynamic args = new
                {
                    Flag = flag,
                    CostGroup = CostGroup,
                    DivisionCd = DivisionCd,
                    CostGroupDesc = CostGroupDesc,
                    uid = uid
                };
                result = db.SingleOrDefault<string>("Master/CostCenterGroup/SaveData", args);
                db.Close();

                if (result == "")
                {
                    if (flag == "0") result = "Data Saved Successfully";
                    else result = "Data Edited Successfully";
                }
                else
                {
                    result = "Error |" + result;
                }
                return result;
            }
            catch (Exception ex)
            {
                return "Error |" + ex.Message;
            }
        }

        public CostCenterGroup GetSelectedData(string CostGroupCd, string DivisionCd)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                CostGroupCd = CostGroupCd,
                DivisionCd = DivisionCd
            };

            var data = db.Fetch<CostCenterGroup>("Master/CostCenterGroup/GetSelectedData", args);
            db.Close();

            return data[0];
        }

        public List<CostCenterGroup> GetDownloadData(string CostGroup, string DivisionCd)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                CostGroup = CostGroup,
                DivisionCd = DivisionCd
            };

            IEnumerable<CostCenterGroup> result = db.Fetch<CostCenterGroup>("Master/CostCenterGroup/GetDownloadData", args);

            db.Close();
            return result.ToList();
        }

        public void InsertTemporary(CostCenterGroup data)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                CostGroup = data.CostCenterGroupCd,
                DivisionCd = data.DivisionCd,
                CostGroupDesc = data.CostCenterGroupDesc,
                CreatedBy = data.CreatedBy,
                ProcessId = data.ProcessId,
                Row = data.Row,
                ErrorFlag = data.ErrorFlag
            };

            IEnumerable<Vendor> result = db.Fetch<Vendor>("Master/CostCenterGroup/InsertTemporary", args);

            db.Close();
        }

        public void UploadValidation(Int64 ProcessId, string MessageLoc, string uid)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                ProcessId = ProcessId,
                MessageLoc = MessageLoc,
                uid = uid
            };

            db.Execute("Master/CostCenterGroup/UploadValidation", args);

            db.Close();
        }

        public int SaveUploadData(Int64 ProcessId, string MessageLoc, string uid)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                ProcessId = ProcessId,
                MessageLoc = MessageLoc,
                uid = uid
            };

            int result = db.SingleOrDefault<Int16>("Master/CostCenterGroup/SaveUploadData", args);
            db.Close();

            return result;
        }

        public void DeleteTemporary(Int64 ProcessId)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                ProcessId = ProcessId
            };

            db.Execute("Master/CostCenterGroup/DeleteTemporary", args);
            db.Close();
        }

        public Int64 GetProcessId(string Message, string MessageLoc, string MessageID, string type, string module, string func, int sts, string uid)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                Message = Message,
                MessageLoc = MessageLoc,
                MessageID = MessageID,
                type = type,
                module = module,
                func = func,
                sts = sts,
                uid = uid
            };

            Int64 newProcessId = db.SingleOrDefault<Int64>("Master/GetProcessId", args);

            return newProcessId;
        }

        public void InsertLog(string Message, string MessageLoc, Int64 ProcessId, string MessageID, string type, string module, string func, int sts, string uid)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                Message = Message,
                MessageLoc = MessageLoc,
                ProcessId = ProcessId,
                MessageID = MessageID,
                type = type,
                module = module,
                func = func,
                sts = sts,
                uid = uid
            };

            db.Execute("Master/InsertLog", args);
        }

        public IEnumerable<Division> GetDivisionData()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            
            dynamic args = new
            {
                NO_REG = ""
            };

            IEnumerable<Division> result = db.Fetch<Division>("Master/GetAllDivision", args);
            db.Close();
            return result;
        }
    }
}