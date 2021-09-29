using System;

namespace GPS.Constants.MRP
{
    public sealed class MRPSqlFile
    {
        // Common
        public const String CommonGetProcurementUsageGroup = "MRP/Creation/MRPCommon_GetProcurementUsageGroup";

        // Creation
        public const String CreationPutMRPProcessToQueue = "MRP/Creation/MRPCreation_PutMRPProcessToQueue";
        public const String CreationInitial = "MRP/Creation/MRPCreation_Initial";
        public const String CreationGetLastMRPInfo = "MRP/Creation/MRPCreation_GetLastMRPInfo";
    }
}