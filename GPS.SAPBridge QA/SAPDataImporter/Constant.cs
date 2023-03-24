using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace SAPDataImporter
{
    class POConstant
    {
        public const String ModuleId = "0";
        public const String FunctionId = "001004";
        public const String FTPLocation = "CreatePO/OUTBOUND/";
        public const String ArchieveLocation = "CreatePO/ARCHIVES/";
        public const String LocalLocation = "PO/";
    }
    class GRConstant
    {
        public const String ModuleId = "0";
        public const String FunctionId = "001004";
        public const String FTPLocation = "Good_Receipt/OUTBOUND/";
        public const String ArchieveLocation = "Good_Receipt/ARCHIVES/";
        public const String LocalLocation = "GR/";
    }
    class SAConstant
    {
        public const String ModuleId = "0";
        public const String FunctionId = "001004";
        public const String FTPLocation = "Entry_sheet/OUTBOUND/";
        public const String ArchieveLocation = "Entry_sheet/ARCHIVES/";
        public const String LocalLocation = "SA/";
    }
}
