using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Models.Common;
using Toyota.Common.Web.Platform;

namespace GPS.Controllers.Master
{
    public class UnitOfMeasureController : PageController
    {
        public static SelectList UOMSelectList
        {
            get
            {
                return UnitOfMeasureRepository.Instance
                    .GetAllData()
                    .AsSelectList(uom => uom.UNIT_OF_MEASURE_CD, uom => uom.UNIT_OF_MEASURE_CD);
            }
        }
    }
}
