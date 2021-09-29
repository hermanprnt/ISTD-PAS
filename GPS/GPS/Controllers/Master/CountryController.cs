using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Models.Common;
using Toyota.Common.Web.Platform;
using System.Collections.Generic;
using System.Linq;

namespace GPS.Controllers.Master
{
    public class CountryController : PageController
    {
        public static SelectList CountrySelectList
        {
            get
            {
                IList<NameValueItem> nameValueList = CountryRepository.Instance
                    .GetAllData()
                    .Select(country => new NameValueItem(country.CountryName, country.CountryCode))
                    .ToList();

                NameValueItem defaultCountry = CountryRepository.Instance.GetDefaultCountry().AsNameValueItem(country => country.CountryName, country => country.CountryCode);

                return new SelectList(nameValueList, NameValueItem.ValueProperty, NameValueItem.NameProperty, defaultCountry.Value);
            }
        }
    }
}
