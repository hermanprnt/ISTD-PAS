using System;
using System.Web;
using System.Web.Mvc;

namespace GPS.CommonFunc.WebControl
{
    public static class GPSDateInput
    {
        public static IHtmlString DateInputBox(this HtmlHelper helper, String dataname)
        {
            var containerTag = new TagBuilder("div");
            containerTag.GenerateId("dateinput-" + dataname);
            containerTag.AddCssClass("input-group dateinput");
            containerTag.InnerHtml = DateIcon() + DateInputBox(dataname);

            return MvcHtmlString.Create(containerTag.ToString());
        }

        private static String DateIcon()
        {
            var iconTag = new TagBuilder("i");
            iconTag.AddCssClass("fa fa-calendar");

            var iconContainer = new TagBuilder("span");
            iconContainer.AddCssClass("input-group-addon");
            iconContainer.InnerHtml = iconTag.ToString();

            return iconContainer.ToString();
        }

        private static String DateInputBox(String dataname)
        {
            var inputTag = new TagBuilder("input");
            inputTag.GenerateId("txtdateinput-" + dataname);
            inputTag.MergeAttribute("type", "text");
            inputTag.MergeAttribute("readonly", "");
            inputTag.AddCssClass("form-control dateinputbox");

            return inputTag.ToString();
        }
    }
}