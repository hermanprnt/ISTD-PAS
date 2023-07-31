using System.Linq;
using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Models.Common;
using GPS.Models.Home;
using GPS.Models.Master;
using GPS.Models.ReceivingList;
using Toyota.Common.Web.Platform;

namespace GPS.Controllers.Home
{
    public class GRApprovalController : PageController
    {
        protected override void Startup()
        {
            var noreg = this.GetCurrentRegistrationNumber();
            Settings.Title = "GR / SA Approval";
            ViewData["Plant"] = PlantRepository.Instance.GetPlantList();
            ViewData["Sloc"] = SLocRepository.Instance.GetAllSLocList();
            ViewData["Division"] = DivisionRepository.Instance.GetDivisionData(noreg);
            ViewData["Coordinator"] = CommonListRepository.Instance.GetDataCoordinatorList();
            ViewData["UserType"] = GRApprovalRepository.Instance.getUserType();
            var NoRegList = GRApprovalRepository.Instance.getNoReg();
            ViewData["ApproveEnable"] = NoRegList.Any() && NoRegList.Contains(noreg);
        }

        private void Calldata(int Display, int Page, GRApproval gRApproval)
        {
            gRApproval.ConvertDocDate();
            Paging pg = new Paging(GRApprovalRepository.Instance.CountData(gRApproval), Page, Display);
            ViewData["Paging"] = pg;
            ViewData["CMDData"] = GRApprovalRepository.Instance.GetListData(gRApproval, pg.StartData, pg.EndData);
        }

        [HttpPost]
        public ActionResult SearchData(int Display, int Page, GRApproval gRApproval)
        {
            Calldata(Display, Page, gRApproval);
            return PartialView("_Grid");
        }

        [HttpPost]
        public ActionResult ApproveData(string MAT_DOC_NO_LIST, string LAST_CHANGE_LIST)
        {
            string username = this.GetCurrentUsername();
            return Content(GRApprovalRepository.Instance.Approve(MAT_DOC_NO_LIST, username,LAST_CHANGE_LIST)) ;
        }

        [HttpPost]
        public ActionResult DetailData(GRApproval gRApproval,int Display=10, int Page=1)
        {
            ViewData["Header"] = GRApprovalRepository.Instance.GetListData(gRApproval,1,10).FirstOrDefault();

            Paging pg = new Paging(GRApprovalRepository.Instance.CountDetail(gRApproval), Page, Display);
            ViewData["Paging_Detail"] = pg;
            ViewData["DetailData"] = GRApprovalRepository.Instance.GetDetail(gRApproval, pg.StartData, pg.EndData);
            return PartialView("_DetailData");
        }

        [HttpPost]
        public ActionResult SearchDataDetail(int Display, int Page, GRApproval gRApproval)
        {
            Paging pg = new Paging(GRApprovalRepository.Instance.CountDetail(gRApproval), Page, Display);
            ViewData["Paging_Detail"] = pg;
            ViewData["DetailData"] = GRApprovalRepository.Instance.GetDetail(gRApproval, pg.StartData, pg.EndData);
            return PartialView("_GridDetail");
        }
    }
}