using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Models.Master;
using Toyota.Common.Web.Platform;

namespace GPS.Controllers.Master
{
    public class PRCheckerController : PageController
    {
        public static SelectList PRCheckerSelectList
        {
            get
            {
                return PRCheckerRepository.Instance
                    .GetPRCheckerList()
                    .AsSelectList(checker => checker.Desc,
                        group => group.Code);
            }
        }
    }
}