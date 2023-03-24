using System;

namespace GPS.Core.GPSLogService
{
    public class DummyLogService : ILogService
    {
        public void Info(String message) { }

        public void Error(Exception ex) { }
    }
}