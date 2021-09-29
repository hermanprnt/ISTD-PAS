using System;
using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Common
{
    public class CountryRepository
    {
        public sealed class SqlFile
        {
            public const String GetList = "Country/GetList";
            public const String GetDefault = "Country/GetDefault";
        }

        private CountryRepository() { }
        private static CountryRepository instance = null;
        public static CountryRepository Instance
        {
            get { return instance ?? (instance = new CountryRepository()); }
        }

        public IEnumerable<Country> GetAllData()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<Country> result = db.Fetch<Country>(SqlFile.GetList);
            db.Close();
            return result;
        }

        public Country GetDefaultCountry()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            Country result = db.SingleOrDefault<Country>(SqlFile.GetDefault);
            db.Close();
            return result;
        }
    }
}