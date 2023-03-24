using System;
using GPS.Core.TDKSimplifier;
using Toyota.Common.Configuration;

namespace GPS.Core.GPSLogService
{
    public class LogServiceExtensions
    {
        public const String TextLogService = "Text";
        public const String DummyLogService = "Dummy";
        public const String WindowsEventLogService = "WindowsEventLog";

        public static ILogService GetCurrentLogService(String appName)
        {
            var config = TDKConfig.GetSystemConfig("LogService") ?? new ConfigurationItem();
            String currentLogService = String.IsNullOrEmpty(config.Value) ? DummyLogService : config.Value;
            ILogService logService;
            switch (currentLogService)
            {
                case TextLogService:
                    logService = new TextFileLogService();
                    break;
                case WindowsEventLogService:
                    logService = new WindowsEventLogService(appName);
                    break;
                case DummyLogService:
                default:
                    logService = new DummyLogService();
                    break;
            }

            return logService;
        }
    }
}