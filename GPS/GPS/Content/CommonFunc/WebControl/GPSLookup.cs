using System;
using System.Web;
using System.Web.Mvc;

namespace GPS.CommonFunc.WebControl
{
    public static class GPSLookup
    {
        public static IHtmlString Lookup(this HtmlHelper helper, String dataName)
        {
            return helper.Lookup(dataName, false);
        }

        public static IHtmlString Lookup(this HtmlHelper helper, String dataName, Boolean isMandatory)
        {
            return helper.Lookup(dataName, isMandatory, String.Empty);
        }

        public static IHtmlString Lookup(this HtmlHelper helper, String dataName, Boolean isMandatory, String cssClass)
        {
            return helper.Lookup(dataName, isMandatory, cssClass, false, null);
        }

        public static IHtmlString Lookup(this HtmlHelper helper, String dataName, Boolean isMandatory, String cssClass, Boolean isClassOverwritten, Object embeddedDataList)
        {
            var containerTag = new TagBuilder("div");
            containerTag.GenerateId("lookup-" + dataName);
            containerTag.MergeAttribute("data-popupid", "popuplookup-" + dataName);
            containerTag.AddCssClass(isClassOverwritten ? cssClass : "input-group input-group-xs lookup " + cssClass);
            containerTag.RenderEmbedData(embeddedDataList);
            containerTag.InnerHtml = LookupTextbox(dataName, isMandatory) + LookupButton(dataName);

            return MvcHtmlString.Create(containerTag.ToString());
        }

        private static String LookupTextbox(String dataName, Boolean isMandatory)
        {
            var inputTag = new TagBuilder("input");
            inputTag.GenerateId("txtlookup-" + dataName);
            inputTag.MergeAttribute("type", "text");
            inputTag.MergeAttribute("readonly", "");
            inputTag.AddCssClass("form-control " + (isMandatory ? "mandatory" : String.Empty));

            return inputTag.ToString();
        }

        private static String LookupButton(String dataName)
        {
            var iconTag = new TagBuilder("i");
            iconTag.AddCssClass("fa fa-search");

            var buttonTag= new TagBuilder("button");
            buttonTag.GenerateId("btnlookup-" + dataName);
            buttonTag.AddCssClass("btn btn-warning btn-xs");
            buttonTag.InnerHtml = iconTag.ToString();

            var containerTag = new TagBuilder("span");
            containerTag.AddCssClass("input-group-btn");
            containerTag.InnerHtml = buttonTag.ToString();

            return containerTag.ToString();
        }

        public static IHtmlString LookupContainer(this HtmlHelper helper, String dataName)
        {
            return helper.ModalContainer("popuplookup-" + dataName);
        }
    }
}