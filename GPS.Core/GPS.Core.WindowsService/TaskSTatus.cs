using System;

namespace GPS.Core.WindowsService
{
    public sealed class TaskStatus
    {
        public const Int32 Queued = 0;
        public const Int32 Running = 1;
        public const Int32 Finish = 2;
    }
}