using System;
using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;
using GPS.Models.Common;

namespace GPS.Models.Master
{
    public class DivisionRepository
    {
        private DivisionRepository() { }
        EmployeeModel emp = new EmployeeModel();

        #region Singleton
        private static DivisionRepository instance = null;
        public static DivisionRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new DivisionRepository();
                }
                return instance;
            }
        }
        #endregion

        #region Data Methods
        public int GetUserDivision(String noReg)
        {
            emp.NO_REG = noReg.ToString();

            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                NO_REG = noReg
            };

            Division result = db.SingleOrDefault<Division>("Master/GetAllDivision", args);
            db.Close();
            return result == null ? 0 : int.Parse(result.Division_ID);
        }

        //add by fid.ahmad 10-10-2022
        public Int32 GetRoleForDivision(String noReg)
        {
            Int32 result = 0;
            try
            {
                string SystemMaster = SystemRepository.Instance.GetSystemValue("MASTER_APP");
                //String encrypt = System.Configuration.ConfigurationManager.AppSettings["Encryption"];
                IDBContext dbsc = DatabaseManager.Instance.GetContext("SecurityCenter");
                dynamic args = new
                {
                    Noreg = noReg,
                    SystemMaster = SystemMaster
                };

                result = dbsc.SingleOrDefault<Int32>("Master/GetRoleForDivision", args);
                dbsc.Close();
            }
            catch (Exception e)
            {
                string message = e.Message;
                throw;
            }
           
          
            return result;
        }
        
        public IEnumerable<Division> GetDivisionData(String noReg = "")
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
           
            dynamic args = new
            {
                NO_REG = noReg
            };

            IEnumerable<Division> result = db.Fetch<Division>("Master/GetAllDivision", args);
            //IEnumerable<Division> result = db.Fetch<Division>("Master/GetAllDivisionCombo", args);
            db.Close();
            return result;
        }

        public IEnumerable<Division> GetDivisionDataCombo(String noReg = "")
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
           
            if (emp.NO_REG != "")
            {
                noReg = emp.NO_REG;
            }
            Int32 haveRole = GetRoleForDivision(noReg);
            
            dynamic args = new
            {
                NO_REG = emp.NO_REG
                ,HAVE_ROLE = haveRole
            };

            IEnumerable<Division> result = db.Fetch<Division>("Master/GetAllDivisionCombo", args);
            db.Close();
            return result;
        }
        #endregion
    }
}