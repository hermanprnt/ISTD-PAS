using System;

namespace GPS.Models.Common
{
    public class NameValueItem
    {
        public const String NoProperty = "No";
        public const String NameProperty = "Name";
        public const String ValueProperty = "Value";

        public Int32 No { get; private set; }
        public String Name { get; private set; }
        public String Value { get; private set; }

        public static NameValueItem Empty
        {
            get { return new NameValueItem(String.Empty, String.Empty); }
        }

        public static NameValueItem None
        {
            get { return new NameValueItem("None", String.Empty); }
        }

        public NameValueItem(Int32 no, String name, String value)
        {
            No = no;
            Name = name;
            Value = value;
        }

        public NameValueItem(String name, String value) : this(0, name, value) { }

        public NameValueItem() : this(String.Empty, String.Empty) { }
    }
}