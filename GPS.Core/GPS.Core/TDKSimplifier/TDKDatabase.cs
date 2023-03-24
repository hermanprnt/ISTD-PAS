using Toyota.Common.Database;
using Toyota.Common.Database.Petapoco;

namespace GPS.Core.TDKSimplifier
{
    public class TDKDatabase
    {
        private IDBContext db;
        private readonly ISqlLoader sqlLoader = new FileSqlLoader(TDKConfig.SQLDirectory);

        public TDKDatabase() : this (TDKConfig.GetConnectionDescriptor()) { }

        public TDKDatabase(ConnectionDescriptor connectionDesc)
        {
            IDBContextManager dbManager = new PetaPocoContextManager(new[] { sqlLoader }, new[] { connectionDesc });
            db = dbManager.GetContext();
        }

        public IDBContext GetDefaultExecDbContext()
        {
            db.SetExecutionMode(DBContextExecutionMode.ByName);
            return db;
        }

        public IDBContext GetDirectExecDbContext()
        {
            db.SetExecutionMode(DBContextExecutionMode.Direct);
            return db;
        }
    }
}