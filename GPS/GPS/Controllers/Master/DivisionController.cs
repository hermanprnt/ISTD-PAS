using System.Web.Mvc;
using GPS.Models.Master;
using GPS.CommonFunc;

namespace GPS.Controllers.Master
{
    public class DivisionController
    {
        public static SelectList GetDivisionList()
        {
            return DivisionRepository.Instance
                .GetDivisionData()
                .AsSelectList(div => div.Division_NAME,
                    div => div.Division_ID);
        }

        public static SelectList GetDivisionListCombo()
        {
            return DivisionRepository.Instance
                .GetDivisionDataCombo()
                .AsSelectList(div => div.Division_NAME,
                    div => div.Division_ID);
        }
    }
}