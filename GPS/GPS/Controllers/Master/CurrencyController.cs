using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Models.Master;
using GPS.Models.Common;

namespace GPS.Controllers.Master
{
    public class CurrencyController
    {
        public static SelectList CurrencySelectList
        {
            get
            {
                return CurrencyRepository.Instance
                    .GetCurrencyList()
                    .AsSelectList(curr => curr.CURR_CD, curr => curr.CURR_CD);
            }
        }

        public static string GetDefaultCurrency()
        {
            return SystemRepository.Instance.GetSystemValue("LOCAL_CURR_CD");
        }
    }
}