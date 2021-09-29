using System;
using System.Collections.Generic;
using System.Linq;
using GPS.CommonFunc;
using GPS.Models.Common;
using GPS.ViewModels;
using GPS.ViewModels.Lookup;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.Master
{
    public class GLAccountRepository
    {
        private readonly IDBContext db;
        public GLAccountRepository()
        {
            db = DatabaseManager.Instance.GetContext();
            db.SetExecutionMode(DBContextExecutionMode.Direct);
        }

        public IList<NameValueItem> GetGLAccountLookupList(GLAccountLookupSearchViewModel searchViewModel)
        {
            String query = "EXEC sp_GLAccount_GetGLAccountLookupList @UserRegNo, @SearchText, @CurrentPage, @PageSize";
            IList<GLAccount> result = db.Fetch<GLAccount>(query, searchViewModel);
            db.Close();

            return result
                .AsNumberedNameValueList(
                    data => data.DataNo,
                    data => data.Description,
                    data => data.Code)
                .ToList();
        }

        public PaginationViewModel GetGLAccountLookupListPaging(GLAccountLookupSearchViewModel searchViewModel)
        {
            String query = "EXEC sp_GLAccount_GetGLAccountLookupListCount @UserRegNo, @SearchText";
            var model = new PaginationViewModel();
            model.DataName = "glaccount";
            model.TotalDataCount = db.SingleOrDefault<Int32>(query, searchViewModel);
            model.PageIndex = searchViewModel.CurrentPage;
            model.PageSize = searchViewModel.PageSize;

            db.Close();

            return model;
        }
    }
}