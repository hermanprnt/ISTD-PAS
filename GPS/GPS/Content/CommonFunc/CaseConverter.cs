using System;
using System.Globalization;

namespace GPS.CommonFunc
{
    public static class CaseConverter
    {
        public static String ToPascalCase(this String source)
        {
            if (String.IsNullOrEmpty(source))
                throw new ArgumentNullException("source");

            var info = CultureInfo.CurrentCulture.TextInfo;
            return info.ToTitleCase(source);
        }

        public static String ToCamelCase(this String source)
        {
            source = source.ToPascalCase();
            return source.Substring(0, 1).ToLower() + source.Substring(1);
        }
    }
}