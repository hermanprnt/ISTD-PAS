using System;
using System.Collections.Generic;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Master
{
    public class ProcurementChannelRepository
    {
        public sealed class SqlFile
        {
            public const String GetList = "Master/GetProcChannelList";
            public const String GetListByNoreg = "Master/GetProcChannelListByNoreg";
        }

        private static ProcurementChannelRepository instance = null;
        public static ProcurementChannelRepository Instance
        {
            get { return instance ?? (instance = new ProcurementChannelRepository()); }
        }

        public IEnumerable<ProcurementChannel> GetProcurementChannelList()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<ProcurementChannel> result = db.Fetch<ProcurementChannel>(SqlFile.GetList);
            db.Close();
            return result;
        }

        public IEnumerable<ProcurementChannel> GetProcurementChannelList(string noreg)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic param = new { NOREG = noreg };

            IEnumerable<ProcurementChannel> result = db.Fetch<ProcurementChannel>(SqlFile.GetListByNoreg, param);
            db.Close();
            return result;
        }
    }
}