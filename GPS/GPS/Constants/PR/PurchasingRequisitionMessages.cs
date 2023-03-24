using System;

namespace GPS.Constants.PR
{
    public class PurchasingRequisitionMessages
    {
        public const String invalidCriteria = "<span>Please select at least one search criteria</span>";
        public const String invalidDate = "<span>{0} is Mandatory if {1} is not empty</span>";
        public const String singleChecked = "Please select  only one record to be {0}";
        public const String selectRecord = "Please select at least one record to be {0}";
        public const String successDelete = "<span>Data With PR No {0} is Successfully Deleted</span>";
        public const String nodataFound = "<span>No Data Found Based on This Search Criteria</span>";
        public const String morethanLimit = "<span>Total data too much, more than ";

        public const String mandatoryField = "{0} is mandatory. ";
        public const String mandatoryMemo = "Memo is mandatory if Urgent PR is set to 'Yes'. ";
        public const String singleRowCreated = "Please Create at Least One Row Detail Data. ";
        public const String successSavePR = "Success save data with PR No {0}. ";
        public const String successSaveRoutine = "Success save data with Routine No {0}. ";
        public const String mandatoryHeader = "Please fill mandatory field in header data. ";
        public const String mandatoryReservation = "{0} cannot be Empty if {1} is Selected. ";
        public const String mandatoryDetail = "{0} of {1} is Mandatory. ";
        public const String mandatoryItemIf = "{0} is mandatory if {1}. ";
        public const String mandatoryAtLeast = "Please fill at least {0} on {1} field.";
        public const String mandatoryDescription = "{0} cannot be Empty if {1} is Empty. ";
        public const String isNumber = "{0} of {1} Must be a number. ";
        public const String isDecimal = "{0} cannot be a decimal if {1}. ";
        public const String greaterThanZero = "{0} of {1} Must be greater than zero. ";
        public const String assetNoValidation = "Asset No {0} is not valid. ";
        public const String projectWBS = "Cost Center cannot be Empty if WBS No is not started with P. ";
        public const String errorExtension = "Sorry, File with type {0} is not allowed , allowed extensions are: {1}. "; //TODO: move to common
        public const String successSaveAttachment = "Success Uploading File {0}";
        public const String errorUpload = "Error Uploading File";
        public const String errorConnectionUpload = "Error! Upload failed. Can not connect to server.";
        public const String errorSaveFile = "Error Uploading File : {0}. ";
        public const String errorFileSize = "Sorry, File {0} size ({1} MB) is reaching limit, {2} filesize for {3} are: {4} MB. "; // TODO: move to common
        public const String errorCounterFile = "Sorry, maximum file allowed for {0} is {1} file(s). ";
        
    }
}