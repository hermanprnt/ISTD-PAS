using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Common
{
    public class PaymentRepository
    {
        private PaymentRepository() { }
        private static PaymentRepository instance = null;
        public static PaymentRepository Instance
        {
            get { return instance ?? (instance = new PaymentRepository()); }
        }

        public IEnumerable<PaymentMethod> GetAllPayMethod()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<PaymentMethod> result = db.Fetch<PaymentMethod>("Master/Vendor/GetPaymentMethod");
            db.Close();
            return result;
        }

        public IEnumerable<PaymentTerm> GetAllPayTerm()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<PaymentTerm> result = db.Fetch<PaymentTerm>("Master/Vendor/GetPaymentTerm");
            db.Close();
            return result;
        }
    }
}