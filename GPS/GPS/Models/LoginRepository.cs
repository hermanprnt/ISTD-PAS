using System;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models
{
    public class LoginRepository
    {
        public Int32 ChangePasssword(String username, String password, Int32 resetadmin)
        {
            //String encrypt = System.Configuration.ConfigurationManager.AppSettings["Encryption"];
            IDBContext dbsc = DatabaseManager.Instance.GetContext("SecurityCenter");
            Int32 result = dbsc.Execute("Common/ChangePasswordSC", new
            {
                Username = username,
                //Password = encrypt == "1" ? new SHA1Encryptor().EncryptPassword(password) : password,
                Password = password,
                ResetAdmin = resetadmin
            });
            dbsc.Close();
            return result;
        }

    }
}