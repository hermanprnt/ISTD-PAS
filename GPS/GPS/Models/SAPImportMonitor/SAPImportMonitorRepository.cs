using System;
using System.Collections.Generic;
using GPS.ViewModels;
using GPS.ViewModels.SAPImportMonitor;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.SAPImportMonitor
{
    public class SAPImportMonitorRepository
    {
        public const String DataName = "sapimport";

        private readonly IDBContext db;
        public SAPImportMonitorRepository()
        {
            db = DatabaseManager.Instance.GetContext();
            db.SetExecutionMode(DBContextExecutionMode.Direct);
        }

        public IList<SAPImportMonitor> GetList(SAPImportMonitorSearchViewModel searchViewModel)
        {
            String query = "EXEC sp_SAPImportMonitor_GetList @ProcessId, @PONo, @Status, @PurchasingGroup, @ExecDateFrom, @ExecDateTo, @CurrentPage, @PageSize";
            IList<SAPImportMonitor> result = db.Fetch<SAPImportMonitor>(query, searchViewModel);
            db.Close();

            return result;
        }

        public PaginationViewModel GetListPaging(SAPImportMonitorSearchViewModel searchViewModel)
        {
            String query = "EXEC sp_SAPImportMonitor_GetListCount @ProcessId, @PONo, @Status, @PurchasingGroup, @ExecDateFrom, @ExecDateTo";

            var model = new PaginationViewModel();
            model.DataName = DataName;
            model.TotalDataCount = db.SingleOrDefault<Int32>(query, searchViewModel);
            model.PageIndex = searchViewModel.CurrentPage;
            model.PageSize = searchViewModel.PageSize;

            db.Close();

            return model;
        }
    }
}