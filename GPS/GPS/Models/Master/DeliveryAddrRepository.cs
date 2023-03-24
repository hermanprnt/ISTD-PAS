using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Master
{
    public class DeliveryAddrRepository
    {
        private DeliveryAddrRepository() { }
        private static readonly DeliveryAddrRepository instance = null;
        public static DeliveryAddrRepository Instance
        {
            get { return instance ?? new DeliveryAddrRepository(); }
        }

        public IEnumerable<DeliveryAddr> GetDeliveryAddrList()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<DeliveryAddr> result = db.Fetch<DeliveryAddr>("Master/GetAllDeliveryAddr");
            db.Close();

            return result;
        }
    }
}