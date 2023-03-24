using System;

namespace GPS.Constants.Master
{
    public class MasterMessages
    {
        public const String singleChecked = "Please select only one record to be {0}";
        public const String selectRecord = "Please select at least one record to be {0}";
        public const String successSaveValuationClass = "Success save data with Valuation Class {0}";
        public const String successActivateInactivate = "Successfully {1} Valuation Class {0}";
        public const String mandatoryField = "{0} is Mandatory";
        public const String mandatoryDetail = "{0} is Mandatory";
        public const String successSaveCalculationMapping = "Success save data with Calculation Scheme Code {0}";
        public const String lengthValidation = "{0} should not be more than {1} character";

        public const String invalidCriteria = "<span>Please select at least one search criteria</span>";
        public const String invalidDate = "<span><strong>{0}</strong> is Mandatory if <strong>{1}</strong> is not empty</span>";
        public const String successDelete = "<span>Data With PR No {0} is Successfully Deleted</span>";
        public const String nodataFound = "<span>No Data Found Based on This Search Criteria</span>";
        public const String morethanLimit = "<span>Total data too much, more than ";

        public const String mandatoryMemo = "<p><strong>Memo</strong> is mandatory if Urgent PR is set to 'Yes'</p>";
        public const String singleRowCreated = "<p>Please Create at Least <strong>One Row Detail Data</strong></p>";
        
        public const String mandatoryHeader = "<p>Please fill <strong>mandatory field</strong> in header data</p>";
        public const String mandatoryReservation = "<p><strong>{0}</strong> cannot be Empty if <strong>{1} is Selected</strong></p>";
        public const String isNumber = "<p><strong>{0}</strong> Must be a number</p>";
        public const String greaterThanZero = "<p><strong>{0}</strong> Must be greater than zero</p>";
        public const String projectWBS = "<p><strong>Cost Center</strong> cannot be Empty if WBS No is <strong>not started</strong> with P</p>";
        public const String errorExtension = "Sorry, File with type <strong>{0}</strong> is not allowed , allowed extensions are: {1}"; //TODO: move to common
        public const String successSaveAttachment = "Success Uploading File {0}";
        public const String errorUpload = "Error Uploading File";
        public const String errorConnectionUpload = "Error! Upload failed. Can not connect to server.";
        public const String errorSaveFile = "Error Uploading File : {0}";
        public const String errorFileSize = "Sorry, File <strong>{0}</strong> size (<strong>{1} MB</strong>) is reaching limit, {2} filesize for <strong>{3}</strong> are: <strong>{4} MB</strong>"; // TODO: move to common
        public const String errorCounterFile = "Sorry, maximum file allowed for {0} is {1} file(s)";
        
        
    }
}