using System;
using System.ComponentModel;
using System.Web.Mvc;

namespace GPS.CommonFunc.WebControl
{
    public static class RendererExtensions
    {
        public static void RenderEmbedData(this TagBuilder tag, Object embeddedDataList)
        {
            if (embeddedDataList != null)
            {
                foreach (PropertyDescriptor propertyDescriptor in TypeDescriptor.GetProperties(embeddedDataList))
                    tag.MergeAttribute("data-" + propertyDescriptor.Name.Replace('_', '-'), propertyDescriptor.GetValue(embeddedDataList).ToString());
            }
        }
    }
}