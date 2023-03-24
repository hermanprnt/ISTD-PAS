using System;
using System.Collections.Generic;
using System.IO;
using GPS.Constants;
using GPS.Models.Common;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;
using GPS.Core.ViewModel;
using GPS.Core;

namespace GPS.Models.PO
{
    public class POCommonRepository
    {
        public const String DataName = "purchaseorder";
        public const String PRItemDataName = "pritem";
        public const String POItemDataName = "poitem";
        public const String SubItemDataName = "subpoitem";
        public const String ItemConditionDataName = "poitem-condition";

        private static POCommonRepository instance = null;
        private readonly IDBContext db;
        public POCommonRepository()
        {
            db = DatabaseManager.Instance.GetContext();
            db.SetExecutionMode(DBContextExecutionMode.Direct);
        }

        public static POCommonRepository Instance
        {
            get { return instance ?? (instance = new POCommonRepository()); }
        }

        public IList<POItemMaterial> GetItemMaterialList(String poNo, String processId)
        {
            IList<POItemMaterial> result = db.Fetch<POItemMaterial>(
                String.IsNullOrEmpty(poNo)
                ? "EXEC sp_POCommon_GetPOItemTempMaterialList @ProcessId"
                : "EXEC sp_POCommon_GetPOItemMaterialList @PONo", new { PONo = poNo, ProcessId = processId });
            db.Close();

            return result;
        }

        public POItemInfo GetPOItemInfo(String processId, String poNo, String poItemNo, String seqItemNo)
        {
            POItemInfo result = db.SingleOrDefault<POItemInfo>(
                String.IsNullOrEmpty(poNo)
                ? "EXEC sp_POCommon_GetPOItemInfoTemp @ProcessId, @PONo, @POItemNo, @SeqItemNo"
                : "EXEC sp_POCommon_GetPOItemInfo @PONo, @POItemNo",
                new { ProcessId = processId, PONo = poNo, POItemNo = poItemNo, SeqItemNo = seqItemNo });
            db.Close();

            return result;
        }

        public IList<POItemCondition> GetPOItemConditionList(String processId, String poNo, String poItemNo, String seqItemNo)
        {
            IList<POItemCondition> result = db.Fetch<POItemCondition>(
                String.IsNullOrEmpty(poNo)
                ? "EXEC sp_POCommon_GetPOItemConditionTempList @ProcessId, @PONo, @POItemNo, @SeqItemNo"
                : "EXEC sp_POCommon_GetPOItemConditionList @PONo, @POItemNo",
                new { ProcessId = processId, PONo = poNo, POItemNo = poItemNo, SeqItemNo = seqItemNo });
            db.Close();

            return result;
        }

        public IList<ComponentPrice> GetComponentPriceList(String valuationClass)
        {
            String query = "EXEC sp_POCommon_GetComponentPriceList @ValClass";
            IList<ComponentPrice> result = db.Fetch<ComponentPrice>(query, new { ValClass = valuationClass });
            db.Close();

            return result;
        }

        public IList<POItemConditionCategory> GetPOItemConditionCategoryList()
        {
            String query = "EXEC sp_POCommon_GetPOItemConditionCategoryList 0";
            IList<POItemConditionCategory> result = db.Fetch<POItemConditionCategory>(query);
            db.Close();

            return result;
        }

        public POItemAdditionalInfo GetPOItemAdditionalInfo(String processId, String poNo, String poItemNo, Int32 seqItemNo)
        {
            POItemAdditionalInfo result = db.SingleOrDefault<POItemAdditionalInfo>(
                String.IsNullOrEmpty(poNo)
                ? "EXEC sp_POCommon_GetPOItemAdditionalInfoTemp @ProcessId, @PONo, @POItemNo, @SeqItemNo"
                : "EXEC sp_POCommon_GetPOItemAdditionalInfo @PONo, @POItemNo",
                new { ProcessId = processId, PONo = poNo, POItemNo = poItemNo, SeqItemNo = seqItemNo });
            db.Close();

            return result;
        }

        public String GetDocumentTempBasePath()
        {
            String downloadBasePathSystemValue = SystemRepository.Instance.GetSystemValue(SystemCode.UploadFilePath);
            String tempPathSystemValue = SystemRepository.Instance.GetSystemValue(SystemCode.POTempUploadPath);
            return Path.GetFullPath(downloadBasePathSystemValue + "\\" + tempPathSystemValue);
        }

        public String GetDocumentBasePath()
        {
            String downloadBasePathSystemValue = SystemRepository.Instance.GetSystemValue(SystemCode.UploadFilePath);
            String tempPathSystemValue = SystemRepository.Instance.GetSystemValue(SystemCode.POUploadPath);
            return Path.GetFullPath(downloadBasePathSystemValue + "\\" + tempPathSystemValue);
        }

        public ActionResponseViewModel PoReceivingValidation(string param_CurrentUser,string param_UserRegNo, String param_poNo, string param_reffNo)
        {
            String query = "EXEC sp_PoCommon_PoReceivingAuthorization @currentUser, @currentRegNo, @poNo,  @reffNo";
            String result = db.ExecuteScalar<String>(query, new { currentUser = param_CurrentUser, currentRegNo = param_UserRegNo, poNo = param_poNo, reffNo = param_reffNo });
            db.Close();

            var resultViewModel = result.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
            {
                if( resultViewModel.Message.Substring(0,1) !="#")
                    throw new InvalidOperationException(resultViewModel.Message);
            }

            return resultViewModel;
        }
    }

}