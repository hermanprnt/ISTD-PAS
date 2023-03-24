using System;

namespace GPS.Core.GPSLogService
{
    public interface ILogService
    {
        void Info(String message);
        void Error(Exception ex);
    }
}