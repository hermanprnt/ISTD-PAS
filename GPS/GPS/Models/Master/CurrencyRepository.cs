using System;
using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Master
{
    public class CurrencyRepository
    {
        private CurrencyRepository() { }
        private static readonly CurrencyRepository instance = null;
        public static CurrencyRepository Instance
        {
            get { return instance ?? new CurrencyRepository(); }
        }

        public IEnumerable<Currency> GetCurrencyList()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<Currency> result = db.Fetch<Currency>("Master/GetAllCurrency");
            db.Close();

            return result;
        }

        public Currency GetCurrency(String currencyCode)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            Currency result = db.SingleOrDefault<Currency>("Master/GetCurrency", new { CurrencyCode = currencyCode });
            db.Close();

            return result;
        }
    }
}