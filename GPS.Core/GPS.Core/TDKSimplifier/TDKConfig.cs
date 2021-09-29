using System;
using System.Collections.Generic;
using System.Linq;
using Toyota.Common.Configuration;
using Toyota.Common.Configuration.Binder;
using Toyota.Common.Database;

namespace GPS.Core.TDKSimplifier
{

    public class TDKConfig
    {
        // NOTE: this three are extracted from Toyota.Common.Web.Platform.LocationConstants
        public static String ConfigDirectory
        {
            get { return AppDomain.CurrentDomain.BaseDirectory + "Configurations"; }
        }

        public static String SQLDirectory
        {
            get { return AppDomain.CurrentDomain.BaseDirectory + "SQL"; }
        }

        public static String WebContentDirectory
        {
            get { return AppDomain.CurrentDomain.BaseDirectory + "Contents"; }
        }

        public static IList<ConfigurationItem> GetConfigList(String appStage, String configFilename)
        {
            var appConfigCabinet = new ConfigurationCabinet("AppConfigCabinet");
            var xmlConfigBinder = new DifferentialXmlConfigurationBinder(configFilename, appStage, ConfigDirectory);
            appConfigCabinet.AddBinder(xmlConfigBinder);
            xmlConfigBinder.Load();

            IConfigurationBinder configurationBinder = appConfigCabinet.GetBinder(configFilename);
            IList<ConfigurationItem> configItemList = configurationBinder.GetConfigurations();

            return configItemList;
        }

        public static IList<ConfigurationItem> GetConfigList(String configFilename)
        {
            var envConfig = GetSystemConfig("Development-Stage") ?? new ConfigurationItem();
            String currentStage = envConfig.Value;
            if (String.IsNullOrEmpty(currentStage) || currentStage == AppStage.None)
                currentStage = AppStage.Development;
            IList<ConfigurationItem> configList = GetConfigList(currentStage, configFilename);

            return configList;
        }

        public static ConfigurationItem GetSystemConfig(String configKey)
        {
            return GetConfigList(AppStage.None, "System")
                .FirstOrDefault(conf => conf.Key == configKey);
        }

        public static ConnectionDescriptor GetConnectionDescriptor()
        {
            const String ConfigFilename = "Database";
            IList<ConfigurationItem> dbConfig = GetConfigList(ConfigFilename);
            
            var configItem = dbConfig
                .FirstOrDefault(conf => ((CompositeConfigurationItem) conf)
                    .GetItem("IsDefault").Value.ToLower() == "true") as CompositeConfigurationItem;

            if (configItem == null)
                throw new InvalidOperationException("There's no default connection in configurations. Please set one.");

            var connectionDesc = new ConnectionDescriptor
            {
                Name = configItem.Key,
                ConnectionString = configItem.GetItem("ConnectionString").Value,
                ProviderName = configItem.GetItem("Provider").Value,
                IsDefault = Convert.ToBoolean(configItem.GetItem("IsDefault").Value)
            };

            return connectionDesc;
        }

        public static String GetTextLogFilepath()
        {
            var config = GetSystemConfig("LogFilepath") ?? new ConfigurationItem();
            if (String.IsNullOrEmpty(config.Value))
                throw new InvalidOperationException("There's no default path for text log. Please set one.");

            return config.Value + DateTime.Now.ToString("MMMM") + "_" + DateTime.Now.Year.ToString() + ".txt";
        }
    }
}