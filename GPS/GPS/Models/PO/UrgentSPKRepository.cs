using System;
using System.Collections.Generic;
using System.Data;
using GPS.CommonFunc;
using GPS.Constants;
using GPS.Core;
using GPS.Core.ViewModel;
using GPS.Models.Common;
using GPS.ViewModels;
using GPS.ViewModels.PO;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.PO
{
    public class UrgentSPKRepository
    {
        private readonly IDBContext db;
        public UrgentSPKRepository()
        {
            db = DatabaseManager.Instance.GetContext();
            db.SetExecutionMode(DBContextExecutionMode.Direct);
        }

        public IList<UrgentSPKViewModel> GetSearchList(UrgentSPKSearchViewModel searchViewModel)
        {
            String query = "EXEC sp_UrgentSPK_GetList @PRNo, @PRStatus, @SPKNo, @SPKDateFrom, @SPKDateTo, @CurrentPage, @PageSize";
            IList<UrgentSPKViewModel> result = db.Fetch<UrgentSPKViewModel>(query, searchViewModel);
            db.Close();

            return result;
        }

        public PaginationViewModel GetSearchListPaging(UrgentSPKSearchViewModel searchViewModel)
        {
            String query = "EXEC sp_UrgentSPK_GetListCount @PRNo, @PRStatus, @SPKNo, @SPKDateFrom, @SPKDateTo";

            var viewModel = new PaginationViewModel();
            viewModel.DataName = "urgentspk";
            viewModel.TotalDataCount = db.SingleOrDefault<Int32>(query, searchViewModel);
            viewModel.PageIndex = searchViewModel.CurrentPage;
            viewModel.PageSize = searchViewModel.PageSize;

            db.Close();

            return viewModel;
        }

        private String Save(ExecProcedureModel execModel, UrgentSPKSaveViewModel viewModel, String editMode)
        {
            String query = @"EXEC sp_UrgentSPK_Save
                @CurrentUser, @CurrentRegNo, @ProcessId, @ModuleId, @FunctionId,
                @EditMode, @PRNo, @PONo, @SPKNo, @BiddingDate, @Work, @Amount,
                @Location, @VendorCode, @VendorName, @VendorAddress, @VendorPostal,
                @VendorCity, @PeriodStart, @PeriodEnd, @Retention, @TerminI,
                @TerminIDesc, @TerminII, @TerminIIDesc, @TerminIII,
                @TerminIIIDesc, @TerminIV, @TerminIVDesc, @TerminV,
                @TerminVDesc";

            dynamic param = new
            {
                execModel.CurrentUser, execModel.CurrentRegNo, execModel.ProcessId, execModel.ModuleId,
                execModel.FunctionId, EditMode = editMode, viewModel.PRNo, viewModel.PONo,
                viewModel.SPKNo, viewModel.SPKInfo.BiddingDate, viewModel.SPKInfo.Work,
                viewModel.SPKInfo.Amount, viewModel.SPKInfo.Location,
                viewModel.SPKInfo.VendorCode, viewModel.SPKInfo.VendorName,
                viewModel.SPKInfo.VendorAddress, viewModel.SPKInfo.VendorPostal, viewModel.SPKInfo.VendorCity,
                viewModel.SPKInfo.PeriodStart, viewModel.SPKInfo.PeriodEnd,
                viewModel.SPKInfo.Retention, viewModel.SPKInfo.TerminI,
                viewModel.SPKInfo.TerminIDesc, viewModel.SPKInfo.TerminII,
                viewModel.SPKInfo.TerminIIDesc, viewModel.SPKInfo.TerminIII,
                viewModel.SPKInfo.TerminIIIDesc, viewModel.SPKInfo.TerminIV,
                viewModel.SPKInfo.TerminIVDesc, viewModel.SPKInfo.TerminV,
                viewModel.SPKInfo.TerminVDesc
            };

            UrgentSPKSaveResult result = db.SingleOrDefault<UrgentSPKSaveResult>(query, param);
            db.Close();

            var resultViewModel = result.Message.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return result.SPKNo;
        }

        public String Save(ExecProcedureModel execModel, UrgentSPKSaveViewModel viewModel)
        {
            return Save(execModel, viewModel, EditMode.Add);
        }

        public String Update(ExecProcedureModel execModel, UrgentSPKSaveViewModel viewModel)
        {
            return Save(execModel, viewModel, EditMode.Edit);
        }

        public Dictionary<String, DataTable> GetSPKPdfDataTableList(String combinedDocNo)
        {
            var dtList = new Dictionary<String, DataTable>();
            String[] splittedDocNo = combinedDocNo.Split(CommonFormat.ItemDelimiter);
            String query = "EXEC sp_UrgentSPK_GetSPKDataTable @PRNo, @SPKNo";
            DataTable dt;
            using (var dda = new DummyDatabaseAgent())
                dt = dda.FetchDataTable(query, new { PRNo = splittedDocNo[0], SPKNo = splittedDocNo[1] });

            dtList.Add("POSPKDataSet", dt);

            return dtList;
        }

        public POSPKViewModel GetSPKInfo(String prNo, String spkNo)
        {
            var result = db.SingleOrDefault<POSPKViewModel>("EXEC sp_UrgentSPK_GetSPKInfo @PRNo, @SPKNo", new { PRNo = prNo, SPKNo = spkNo }) ?? new POSPKViewModel();
            db.Close();

            return result;
        }

        public SPKVendorViewModel GetVendorInfo(String vendorCode)
        {
            var result = db.SingleOrDefault<SPKVendorViewModel>("EXEC sp_UrgentSPK_GetVendorInfo @VendorCode", new { VendorCode = vendorCode }) ?? new SPKVendorViewModel();
            db.Close();

            return result;
        }
    }
}