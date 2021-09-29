using System;
using System.Collections.Specialized;
using System.Configuration;
using System.Reflection;

namespace GPS.Core
{
    public class AppConfig
    {
        public static T Get<T>() where T : class
        {
            T t = Activator.CreateInstance<T>();
            Type tType = typeof (T);
            PropertyInfo[] propList = tType.GetProperties();
            FieldInfo[] fieldList = tType.GetFields();

            String sectionName = tType.Name;
            var configSection = ConfigurationManager.GetSection(sectionName) as NameValueCollection;
            if (configSection != null)
            {
                foreach (PropertyInfo prop in propList)
                {
                    String config = configSection[prop.Name];
                    if (!String.IsNullOrEmpty(config))
                    {
                        Type propType = prop.GetType();
                        prop.SetValue(t, Convert.ChangeType(configSection[prop.Name], propType), null);
                    }
                    
                }

                foreach (FieldInfo field in fieldList)
                {
                    String config = configSection[field.Name];
                    if (!String.IsNullOrEmpty(config))
                    {
                        Type fieldType = field.GetType();
                        field.SetValue(t, Convert.ChangeType(configSection[field.Name], fieldType));
                    }
                }
            }

            return t;
        }
    }
}