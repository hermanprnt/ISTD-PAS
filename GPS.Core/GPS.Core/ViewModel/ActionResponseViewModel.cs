using System;

namespace GPS.Core.ViewModel
{
    public sealed class ActionResponseViewModel
    {
        public const String Info = "I";
        public const String Warning = "W";
        public const String Error = "E";
        public const String Success = "S";

        public const String Tab = "{tab}";
        public const String NewLine = "{newline}";

        public String ResponseType { get; set; }
        public String Message { get; set; }
    }
}