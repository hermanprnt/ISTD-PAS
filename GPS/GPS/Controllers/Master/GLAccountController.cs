using System;
using System.Web.Mvc;
using GPS.Constants;
using GPS.Core;
using GPS.Models.Common;
using GPS.Models.Master;
using GPS.ViewModels.Lookup;
using Toyota.Common.Web.Platform;

namespace GPS.Controllers.Master
{
    public class GLAccountController : PageController
    {
        private readonly GLAccountRepository glAccountRepo = new GLAccountRepository();

        [HttpPost]
        public ActionResult OpenGLAccountLookup(GLAccountLookupSearchViewModel searchViewModel)
        {
            try
            {
                LookupViewModel<NameValueItem> viewModel = GetLookupViewModel(searchViewModel);
                return PartialView(LookupPage.GenericLookup, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult SearchGLAccountLookup(GLAccountLookupSearchViewModel searchViewModel)
        {
            try
            {
                LookupViewModel<NameValueItem> viewModel = GetLookupViewModel(searchViewModel);
                return PartialView(LookupPage.GenericLookupGrid, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        private LookupViewModel<NameValueItem> GetLookupViewModel(GLAccountLookupSearchViewModel searchViewModel)
        {
            var viewModel = new LookupViewModel<NameValueItem>();
            viewModel.Title = "GL Account";
            viewModel.DataList = glAccountRepo.GetGLAccountLookupList(searchViewModel);
            viewModel.GridPaging = glAccountRepo.GetGLAccountLookupListPaging(searchViewModel);

            return viewModel;
        }
    }
}