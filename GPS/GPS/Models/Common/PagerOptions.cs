using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Mvc;
using System.Web.Mvc.Ajax;
using System.Web.Mvc.Html;
using System.Web.Routing;
using System.Web.UI.WebControls;

namespace GPS.Models.Common
{
    public class PagerOptions
    {
        public enum Position
        {
            Left = 0,
            Righ = 1
        }

        public PagerOptions(int currentPage, int totalItemCount, int pageSize)
        {
            this.ParamPageName = "page";
            this.ParamPageSizeName = "pageSize";
            this.FormatPageDisplay = "{0}";
            this.PageSizePosition = PagerOptions.Position.Righ;
            this.ShowPageSize = true;
            this.ShowSummary = true;
            this.ShowJumper = true;
            this.PageSizeItem = DefaultPageSizeItem();
            this.PagerSettings = new PagerSettings()
            {
                FirstPageText = "«",
                PreviousPageText = "‹",
                NextPageText = "›",
                LastPageText = "»",
            };

            this.MaxPageShow = 10;
            this.CurrentPage = currentPage;
            this.CurrentPageSize = pageSize;
            if (!PageSizeItem.Contains(pageSize))
            {
                PageSizeItem.Add(pageSize);
                PageSizeItem = PageSizeItem.OrderBy(fld => fld).ToList();
            }
            this.TotalItemCount = totalItemCount;

            this.GetPages();
        }

        /*Query string name*/
        public string ParamPageName { get; set; }
        public string ParamPageSizeName { get; set; }

        /*Settings*/
        public string FormatPageDisplay { get; set; }
        public bool ShowPageSize { get; set; }
        public bool ShowSummary { get; set; }
        public bool ShowJumper { get; set; }
        public Position PageSizePosition { get; set; }
        public int CurrentPage { get; set; }
        public int CurrentPageSize { get; set; }
        public int TotalItemCount { get; set; }
        public int MaxPageShow { get; set; }
        public AjaxOptions Ajax { get; set; }
        public PagerSettings PagerSettings { get; set; }

        /*Url*/
        public string ControlerName { get; set; }
        public string ActionName { get; set; }
        public object ObjectRoute { get; set; }

        /*Source*/
        public IList<int> PageSizeItem { get; set; }
        public Int32 CurrentLastPage { get; private set; }
        public Int32 GetStartRowNumber()
        {
            if (CurrentPage <= 1)
                return 1;
            return ((CurrentPage - 1) * CurrentPageSize) + 1;
        }

        /*Method*/
        public List<Int32> DefaultPageSizeItem()
        {
            return new List<Int32>() { 10, 20, 50, 100 };
        }
        public int GetPageCount()
        {
            return (int)Math.Ceiling((double)(((double)this.TotalItemCount) / ((double)this.CurrentPageSize)));
        }

        public bool IsAllowJumper()
        {
            if (!ShowJumper)
                return false;
            if (CurrentLastPage < GetPageCount())
                return true;
            if (CurrentLastPage > MaxPageShow)
                return true;

            return false;
        }

        public IEnumerable<int> GetPages()
        {
            int pageNumber = GetPageCount();
            int startPage = 1;
            CurrentLastPage = pageNumber;

            /* Show Pages*/
            if (pageNumber > this.MaxPageShow)
            {
                int midlePageNumber = ((int)Math.Ceiling((double)(((double)this.MaxPageShow) / 2.0))) - 1;
                int startPageView = this.CurrentPage - midlePageNumber;
                int lastPageView = this.CurrentPage + midlePageNumber;
                if (startPageView < 4)
                {
                    lastPageView = this.MaxPageShow;
                    startPageView = 1;
                }
                else if (lastPageView > (pageNumber - 4))
                {
                    lastPageView = pageNumber;
                    startPageView = pageNumber - this.MaxPageShow;
                }
                startPage = startPageView;
                CurrentLastPage = lastPageView;
            }

            return Enumerable.Range(startPage, CurrentLastPage - startPage + 1);
        }

        public MvcHtmlString GeneratePageControl(AjaxHelper ajaxHelper, HtmlHelper htmlHelper, Int32 pageNumber, string cssClass, string linkText = null)
        {
            var htmlString = new MvcHtmlString("");
            if (this.Ajax == null)
                htmlString = GeneratePageLink(htmlHelper, pageNumber, cssClass);
            else
                htmlString = GeneratePageLink(ajaxHelper, pageNumber, cssClass);
            string str2 = string.Format(this.FormatPageDisplay, pageNumber);
            if (!string.IsNullOrEmpty(linkText))
                htmlString = replaceTextLink(str2, linkText, htmlString);
            return htmlString;
        }

        protected MvcHtmlString GeneratePageLink(AjaxHelper ajaxHelper, int pageNumber, string cssClass)
        {
            RouteValueDictionary routeValues = getObjectRoute(pageNumber);
            string str2 = string.Format(this.FormatPageDisplay, pageNumber);
            RouteValueDictionary htmlAttributes = getHtmlAttribute(pageNumber, str2, cssClass);
            return ajaxHelper.ActionLink(str2, this.ActionName, routeValues, this.Ajax, htmlAttributes);
        }

        protected MvcHtmlString GeneratePageLink(HtmlHelper htmlHelper, int pageNumber, string cssClass)
        {
            RouteValueDictionary routeValues = getObjectRoute(pageNumber);
            string str2 = string.Format(this.FormatPageDisplay, pageNumber);
            RouteValueDictionary htmlAttributes = getHtmlAttribute(pageNumber, str2, cssClass);
            return htmlHelper.ActionLink(str2, this.ActionName, routeValues, htmlAttributes);
        }

        private MvcHtmlString replaceTextLink(string replacement, string linkText, MvcHtmlString htmlString)
        {
            if (!string.IsNullOrEmpty(linkText))
            {
                var str = htmlString.ToString().Replace(">" + HttpUtility.HtmlEncode(replacement) + "<", ">" + linkText + "<");
                htmlString = new MvcHtmlString(str);
            }
            return htmlString;
        }

        private RouteValueDictionary getHtmlAttribute(int pageNumber, string title, string cssClass)
        {
            RouteValueDictionary htmlAttributes = new RouteValueDictionary();
            htmlAttributes.Add("title", title);
            htmlAttributes.Add("date-page", pageNumber);
            htmlAttributes.Add("date-pageSize", this.CurrentPageSize);
            htmlAttributes.Add("class", cssClass);
            return htmlAttributes;
        }

        private RouteValueDictionary getObjectRoute(int pageNumber)
        {
            RouteValueDictionary routeValues = new RouteValueDictionary(this.ObjectRoute);
            if (!string.IsNullOrEmpty(this.ControlerName))
                routeValues.Add("controller", this.ControlerName);
            routeValues.Add("page", pageNumber);
            routeValues.Add("pageSize", this.CurrentPageSize);
            return routeValues;
        }

        public MvcForm BeginForm(AjaxHelper ajaxHelper)
        {
            var htmlAttribute = new RouteValueDictionary();
            htmlAttribute.Add("role", "form");
            htmlAttribute.Add("class", "form-inline");
            return BeginForm(ajaxHelper, htmlAttribute);
        }

        public MvcForm BeginForm(AjaxHelper ajaxHelper, RouteValueDictionary htmlAttribute)
        {
            MvcForm form = ajaxHelper.BeginForm(this.ActionName, new RouteValueDictionary(), this.Ajax, htmlAttribute);
            return form;
        }

        public MvcForm BeginForm(HtmlHelper htmlHelper)
        {
            var htmlAttribute = new RouteValueDictionary();
            htmlAttribute.Add("role", "form");
            htmlAttribute.Add("class", "form-inline");
            return BeginForm(htmlHelper, htmlAttribute);
        }

        public MvcForm BeginForm(HtmlHelper htmlHelper, RouteValueDictionary htmlAttribute)
        {
            MvcForm form = htmlHelper.BeginForm(this.ActionName, this.ControlerName, new RouteValueDictionary(), FormMethod.Get, htmlAttribute);
            return form;
        }

        public MvcHtmlString GetInputObjectRoute()
        {
            StringBuilder html = new StringBuilder("");
            RouteValueDictionary routeValues = new RouteValueDictionary(this.ObjectRoute);
            foreach (KeyValuePair<string, object> item in routeValues)
                if (item.Value != null)
                    html.AppendFormat("<input type=\"hidden\" name=\"{0}\" value=\"{1}\"/>", item.Key, item.Value);
            return new MvcHtmlString(html.ToString());
        }
    }
}