using System;
using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Master
{
    public class PRCheckerRepository
    {
        public const String DataName = "prchecker";
        public sealed class SqlFile
        {
            public const String GetList = "Master/PRChecker/GetList";
        }

        private static PRCheckerRepository instance = null;
        public static PRCheckerRepository Instance
        {
            get { return instance ?? (instance = new PRCheckerRepository()); }
        }

        public IEnumerable<PRChecker> GetPRCheckerList()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<PRChecker> result = db.Fetch<PRChecker>(SqlFile.GetList);
            db.Close();

            return result;
        }
    }
}