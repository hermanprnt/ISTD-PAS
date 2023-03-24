using System;
using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Constants;
using GPS.Core;
using GPS.Models.Master;
using GPS.ViewModels;

namespace GPS.Controllers.Master
{
    public class SLocController : Controller
    {
        [HttpPost]
        public ActionResult RefreshSLoc(String dropdownId, String plantCode)
        {
            try
            {
                var viewModel = new DropdownListViewModel();
                viewModel.DataName = dropdownId;
                viewModel.DataList = SLocRepository.Instance
                    .GetSLocList(plantCode)
                    .AsSelectList(sloc => sloc.SLOC_CD + " - " + sloc.SLOC_NAME, sloc => sloc.SLOC_CD);

                return PartialView(CommonPage.DropdownList, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        public static SelectList GetSLocSelectList(String plantCode)
        {
            return SLocRepository.Instance
                .GetSLocList(plantCode)
                .AsSelectList(sloc => sloc.SLOC_CD + " - " + sloc.SLOC_NAME, sloc => sloc.SLOC_CD);
        }
    }
}