using System;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Common
{
    public class ProcessIdRepository
    {
        public String GetNewProcessId(String moduleId, String functionId, String actionName)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            String result = db.ExecuteScalar<String>("Common/GetNewProcessId", new { Module = moduleId, Function = functionId, ActionName = actionName });
            db.Close();

            return result;
        }
    }
}
