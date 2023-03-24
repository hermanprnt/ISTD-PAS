using System;
using System.Globalization;
using System.Web.Mvc;

namespace GPS.CommonFunc
{
    // NOTE: this class is needed to fix JSON request which parsed as 0 decimal in viewmodel/model
    // http://stackoverflow.com/a/5759788/1181782
    // http://haacked.com/archive/2011/03/19/fixing-binding-to-decimals.aspx/
    public class DecimalModelBinder : DefaultModelBinder
    {
        public override object BindModel(ControllerContext controllerContext, ModelBindingContext bindingContext)
        {
            ValueProviderResult result = bindingContext.ValueProvider.GetValue(bindingContext.ModelName);

            if (result.AttemptedValue == "N.aN" ||
                result.AttemptedValue == "NaN" ||
                result.AttemptedValue == "Inifini.ty" ||
                result.AttemptedValue == "Infinity" ||
                String.IsNullOrEmpty(result.AttemptedValue))
                return 0m;

            return result == null
                ? base.BindModel(controllerContext, bindingContext)
                : Convert.ToDecimal(result.AttemptedValue, CultureInfo.CurrentCulture);
        }
    }
}