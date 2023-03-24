using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Mvc.Html;
using GPS.Models.Common;

namespace GPS.CommonFunc.WebControl
{
    public static class GPSEmptyDropdownList
    {
        public static IHtmlString EmptyDropdownList(this HtmlHelper helper, String dataName)
        {
            return helper.EmptyDropdownList(dataName, String.Empty);
        }

        public static IHtmlString EmptyDropdownList(this HtmlHelper helper, String dataName, String emptyMessage)
        {
            return helper.EmptyDropdownList(dataName, emptyMessage, null);
        }

        public static IHtmlString EmptyDropdownList(this HtmlHelper helper, String dataName, String emptyMessage, Object htmlAttributes)
        {
            var selectList = new SelectList(Enumerable.Repeat(new NameValueItem(emptyMessage, String.Empty), 1), NameValueItem.ValueProperty, NameValueItem.NameProperty, NameValueItem.Empty);
            if (String.IsNullOrEmpty(emptyMessage))
                selectList = new SelectList(Enumerable.Repeat(NameValueItem.Empty, 1), NameValueItem.ValueProperty, NameValueItem.NameProperty, NameValueItem.Empty);

            IDictionary<String, Object> attributes = HtmlHelper
                .AnonymousObjectToHtmlAttributes(
                    htmlAttributes ?? new { @class = "form-control" });

            return helper.DropDownList("cmb-" + dataName, selectList, attributes);
        }
    }
}