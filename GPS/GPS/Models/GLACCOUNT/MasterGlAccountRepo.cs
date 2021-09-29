using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.GLACCOUNT
{
    public class MasterGlAccountRepo 
    {

        private MasterGlAccountRepo() { }

       
      
        #region singleton

        private static MasterGlAccountRepo instance = null;

        public static MasterGlAccountRepo Instance {

            get {
                if (instance == null)
                {
                    instance = new MasterGlAccountRepo();
                }
                return instance;
            }
        }
        #endregion


        public int SearchData(masterGLAccount data,IDBContext db)
        {
            dynamic args = new
            {
                glAccountCD = data.GL_ACCOUNT_CD,
                glAccountDesc = data.GL_ACCOUNT_DESC,
                plantCd = data.PLANT_CD
            };
            int result = db.SingleOrDefault<int>("MasterGLAccount/countData", args);
            db.Close();
            return result;
            
        }

        public IList<masterGLAccount> GetListdata(masterGLAccount data,IDBContext db, int p1, int p2)
        {
            dynamic args = new
            {
                glAccountCD = data.GL_ACCOUNT_CD,
                glAccountDesc = data.GL_ACCOUNT_DESC,
                plantCd = data.PLANT_CD,
                currentPage = p1,
                recordPerpage = p2

            };
            IList<masterGLAccount> result = db.Fetch<masterGLAccount>("MasterGLAccount/GetListData", args);
            db.Close();
            return result;
        }

        public string SaveData(masterGLAccount data, string gscreen, string username)
        {
            string result = "";
            try{

                IDBContext db = DatabaseManager.Instance.GetContext();
                dynamic args = new
                {
                    glAccountCd = data.GL_ACCOUNT_CD,
                    glAccountDesc = data.GL_ACCOUNT_DESC,
                    plaantCD = data.PLANT_CD,
                    flag = gscreen,
                    getuser = username
                };
                result = db.SingleOrDefault<string>("MasterGLAccount/saveData", args);
                db.Close();
             }
            catch(Exception e)
            {
                result = "Error | "+ Convert.ToString(e.Message); 
            }
            return result;
        }

        public string DeleteData(string key, string uid)
        {
            string Result = "";
            try { 
                IDBContext db = DatabaseManager.Instance.GetContext();
                foreach(String data in key.Split(','))
                {
                    String[] cols = data.Split(';');
                    Result = db.SingleOrDefault<string>("MasterGLAccount/deleteData", new { glAccountCode = cols[0], userName = uid });
                }
            }catch(Exception ex)
            {
                Result = "Error| " + Convert.ToString(ex.Message);
            }
            return Result;
        }

        public List<masterGLAccount> GetData(string GL_ACCOUNT_CD, string GL_ACCOUNT_DESC, string PLANT_CD, int currentPage, int recordPerPage)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                currentPage = currentPage,
                recordPerpage = recordPerPage,
                glAccountCD = GL_ACCOUNT_CD,
                glAccountDesc = GL_ACCOUNT_DESC,
                plantCd = PLANT_CD
                //CreateBy = createdBy,
                //CreateDate = createdDt,
                //ChangeBy = changedBy,
                //ChangeDate = changedDt
            };
            List<masterGLAccount> list = db.Fetch<masterGLAccount>("MasterGLAccount/GetListData", args);
            db.Close();
            return list;
        }

        public int CountData(string GL_ACCOUNT_CD, string GL_ACCOUNT_DESC, string PLANT_CD)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                glAccountCD = GL_ACCOUNT_CD,
                glAccountDesc = GL_ACCOUNT_DESC,
                plantCd = PLANT_CD
                //CreateBy = createdBy,
                //CreateDate = createdDt,
                //ChangeBy = changedBy,
                //ChangeDate = changedDt
            };
            int count = db.SingleOrDefault<int>("MasterGLAccount/CountData", args);
            db.Close();
            return count;
        }
    }
}