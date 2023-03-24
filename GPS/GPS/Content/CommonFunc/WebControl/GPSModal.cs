using System;
using System.Web;
using System.Web.Mvc;

namespace GPS.CommonFunc.WebControl
{
    public static class GPSModal
    {
        public static IHtmlString ModalContainer(this HtmlHelper helper, String containerId)
        {
            return helper.ModalContainer(containerId, String.Empty);
        }

        public static IHtmlString ModalContainer(this HtmlHelper helper, String containerId, String cssClass)
        {
            return helper.ModalContainer(containerId, cssClass, false, null);
        }

        public static IHtmlString ModalContainer(this HtmlHelper helper, String containerId, String cssClass, Boolean isClassOverwritten, Object embeddedDataList)
        {
            var containerTag = new TagBuilder("div");
            containerTag.GenerateId(containerId);
            containerTag.AddCssClass(isClassOverwritten ? cssClass : "modal fade " + cssClass);
            containerTag.MergeAttribute("data-backdrop", "static");
            containerTag.MergeAttribute("data-keyboard", "false");
            containerTag.RenderEmbedData(embeddedDataList);

            return MvcHtmlString.Create(containerTag.ToString());
        }
    }
}