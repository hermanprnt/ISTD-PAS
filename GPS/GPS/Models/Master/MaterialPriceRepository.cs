using System;
using System.Collections.Generic;
using System.Linq;
using GPS.Core;
using GPS.Core.ViewModel;
using GPS.ViewModels;
using GPS.ViewModels.Master;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;
using GPS.ViewModels.Lookup;

namespace GPS.Models.Master
{
    public class MaterialPriceRepository
    {
        public const String DataName = "price";

        public sealed class SqlFile
        {
            public const String _Root_Folder = "Master/Price/";

            public const String GetListBySearch = _Root_Folder + "GetListBySearch";
            public const String GetListBySearchCount = _Root_Folder + "GetListBySearchCount";
            public const String Delete = _Root_Folder + "Delete";
            public const String CountPrice = _Root_Folder + "count_price";
            public const String GetPrice = _Root_Folder + "get_price";

            public const String GetMatno = _Root_Folder + "get_matnolist";
            public const String CountMatno = _Root_Folder + "count_matnolist";

            public const String SaveValidation = _Root_Folder + "call_validateSave";
            public const String Save = _Root_Folder + "call_processingSave";
            public const String DeleteProcess = _Root_Folder + "call_processingDelete";
            public const String SaveUpload = _Root_Folder + "call_saveUpload";
        }

        private MaterialPriceRepository() { }
        private static MaterialPriceRepository instance = null;
        public static MaterialPriceRepository Instance
        {
            get { return instance ?? (instance = new MaterialPriceRepository()); }
        }

        public IEnumerable<MaterialPrice> GetList(MaterialPriceSearchViewModel searchViewModel)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<MaterialPrice> result = db.Fetch<MaterialPrice>(SqlFile.GetListBySearch, searchViewModel);
            db.Close();

            return result;
        }

        public PaginationViewModel GetListPaging(MaterialPriceSearchViewModel searchViewModel)
        {
            var model = new PaginationViewModel();
            model.DataName = DataName;
            model.TotalDataCount = GetListCount(searchViewModel);
            model.PageIndex = searchViewModel.CurrentPage;
            model.PageSize = searchViewModel.PageSize;

            return model;
        }

        private Int32 GetListCount(MaterialPriceSearchViewModel searchViewModel)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            Int32 result = db.SingleOrDefault<Int32>(SqlFile.GetListBySearchCount, searchViewModel);
            db.Close();

            return result;
        }

        public IEnumerable<String> Delete(String primaryKeyList)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            String result = db.ExecuteScalar<String>(SqlFile.Delete, new { PrimaryKeyList = primaryKeyList });
            db.Close();

            var resultViewModel = result.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return primaryKeyList
                .Split(',')
                .Select(splitted =>
                {
                    var itemList = splitted.Split(';');
                    return itemList[0] + " - " + itemList[1];
                });
        }


        public int CountPrice(string MAT_NO, string DATE_FROM, string DATE_TO, string VENDOR_CD,
                              string PRICE_STATUS, string PRICE_TYPE, string SOURCE_TYPE, string PRODUCTION_PURPOSE,
                              string PART_COLOR_SFX, string PACKING_TYPE)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                MAT_NO = MAT_NO,
                VENDOR_CD = VENDOR_CD,
                VALIDFROM = DATE_FROM,
                VALIDTO = DATE_TO,
                PRICE_STS = PRICE_STATUS,
                PRICE_TYPE = PRICE_TYPE,
                SOURCE_TYPE = SOURCE_TYPE,
                PRODUCTION_PURPOSE = PRODUCTION_PURPOSE,
                PART_COLOR_SFX = PART_COLOR_SFX,
                PACKING_TYPE = PACKING_TYPE
            };
            int result = db.SingleOrDefault<int>(SqlFile.CountPrice, args);
            db.Close();
            return result;
        }

        public IEnumerable<MaterialPrice> GetPrice(string MAT_NO, string DATE_FROM, string DATE_TO, string VENDOR_CD,
                                           string PRICE_STATUS, string PRICE_TYPE, string SOURCE_TYPE, string PRODUCTION_PURPOSE,
                                           string PART_COLOR_SFX, string PACKING_TYPE, int start, int length)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new { 
                MAT_NO = MAT_NO,
                VENDOR_CD = VENDOR_CD,
                VALIDFROM = DATE_FROM,
                VALIDTO = DATE_TO,
                PRICE_STS = PRICE_STATUS,
                PRICE_TYPE = PRICE_TYPE,
                SOURCE_TYPE = SOURCE_TYPE,
                PRODUCTION_PURPOSE = PRODUCTION_PURPOSE,
                PART_COLOR_SFX = PART_COLOR_SFX,
                PACKING_TYPE = PACKING_TYPE,
                start = start,
                length = length
            };
            IEnumerable<MaterialPrice> result = db.Fetch<MaterialPrice>(SqlFile.GetPrice, args);
            db.Close();
            return result;
        }

        public int CountMatno(string matno, string matdesc)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                MAT_NO = matno,
                MAT_DESC = matdesc
            };
            int result = db.SingleOrDefault<int>(SqlFile.CountMatno, args);
            db.Close();
            return result;
        }

        public IEnumerable<MaterialPrice> GetDataMatNumber(string matno, string matdesc, int pageSize, int page)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                MAT_NO = matno,
                MAT_DESC = matdesc,
                start = page,
                length = pageSize
            };
            IEnumerable<MaterialPrice> result = db.Fetch<MaterialPrice>(SqlFile.GetMatno, args);
            db.Close();
            return result;
        }

        public string validateSave(string PRICE_TYPE, string MAT_NO, string MAT_DESC, string VENDOR_CD, string PRODUCTION_PURPOSE,
                                   string CURR_CD, double PRICE_AMT, string VALID_DT_FROM, string PART_COLOR_SFX, string WARP_BUYER_CD,
                                   string SOURCE_TYPE, string PRICE_STS, string PACKING_TYPE)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string result = "";
            try
            {
                dynamic args = new
                {
                    PRICE_TYPE = PRICE_TYPE,
                    MAT_NO = MAT_NO,
                    MAT_DESC = MAT_DESC,
                    VENDOR_CD = VENDOR_CD,
                    PRODUCTION_PURPOSE = PRODUCTION_PURPOSE,
                    CURR_CD = CURR_CD,
                    PRICE_AMT = PRICE_AMT,
                    VALID_DT_FROM = VALID_DT_FROM,
                    PART_COLOR_SFX = PART_COLOR_SFX,
                    WARP_BUYER_CD = WARP_BUYER_CD,
                    SOURCE_TYPE = SOURCE_TYPE,
                    PRICE_STS = PRICE_STS,
                    PACKING_TYPE = PACKING_TYPE
                };
                result = db.SingleOrDefault<string>(SqlFile.SaveValidation, args);
            }
            catch(Exception e){
                result = "ERR|" + e.Message;
            }
            finally{
                db.Close();
            }
            return result;
        }

        public string processingSave(string PRICE_TYPE, string MAT_NO, string MAT_DESC, string VENDOR_CD, string PRODUCTION_PURPOSE,
                                     string CURR_CD, double PRICE_AMT, string VALID_DT_FROM, string PART_COLOR_SFX, string WARP_BUYER_CD,
                                     string SOURCE_TYPE, string PRICE_STS, string PACKING_TYPE, string USER_ID)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string result = "";
            try
            {
                dynamic args = new
                {
                    PRICE_TYPE = PRICE_TYPE,
                    MAT_NO = MAT_NO,
                    MAT_DESC = MAT_DESC,
                    VENDOR_CD = VENDOR_CD,
                    PRODUCTION_PURPOSE = PRODUCTION_PURPOSE,
                    CURR_CD = CURR_CD,
                    PRICE_AMT = PRICE_AMT,
                    VALID_DT_FROM = VALID_DT_FROM,
                    PART_COLOR_SFX = PART_COLOR_SFX,
                    WARP_BUYER_CD = WARP_BUYER_CD,
                    SOURCE_TYPE = SOURCE_TYPE,
                    PRICE_STS = PRICE_STS,
                    PACKING_TYPE = PACKING_TYPE,
                    USER_ID = USER_ID
                };
                result = db.SingleOrDefault<string>(SqlFile.Save, args);
            }
            catch (Exception e)
            {
                result = "ERR|" + e.Message;
            }
            finally
            {
                db.Close();
            }
            return result;
        }

        public string DeletePrice(string PRICE_TYPE, string MAT_NO, string VENDOR_CD, string PRODUCTION_PURPOSE, string VALID_DT_FROM,
                                   string PART_COLOR_SFX, string WARP_BUYER_CD, string SOURCE_TYPE, string PACKING_TYPE, string USER_ID)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            string result = "";
            try
            {
                dynamic args = new
                {
                    USER_ID = USER_ID,
                    PRICE_TYPE = PRICE_TYPE,
                    MAT_NO = MAT_NO,
                    VENDOR_CD = VENDOR_CD,
                    PRODUCTION_PURPOSE = PRODUCTION_PURPOSE,
                    VALID_DT_FROM = VALID_DT_FROM,
                    PART_COLOR_SFX = PART_COLOR_SFX,
                    WARP_BUYER_CD = WARP_BUYER_CD,
                    SOURCE_TYPE = SOURCE_TYPE,
                    PACKING_TYPE = PACKING_TYPE
                };
                result = db.SingleOrDefault<string>(SqlFile.DeleteProcess, args);
            }
            catch (Exception e)
            {
                result = "ERR|" + e.Message;
            }
            finally
            {
                db.Close();
            }
            return result;
        }

        #region LOOKUP
        public PaginationViewModel GetVendorLookupSearchListPaging(LookupSearchViewModel searchSearchViewModel, string custdataname)
        {
            var model = new PaginationViewModel();
            model.DataName = custdataname;
            model.TotalDataCount = GetVendorLookupSearchListCount(searchSearchViewModel);
            model.PageIndex = searchSearchViewModel.CurrentPage;
            model.PageSize = searchSearchViewModel.PageSize;

            return model;
        }

        private Int32 GetVendorLookupSearchListCount(LookupSearchViewModel searchSearchViewModel)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            Int32 result = db.SingleOrDefault<Int32>(VendorRepository.SqlFile.GetVendorLookupSearchListCount, searchSearchViewModel);
            db.Close();

            return result;
        }
        #endregion

        #region UPLOAD
        public string SaveUploadData(string PriceType, MaterialPrice datarow, string UserId)
        {
            string result = "";
            IDBContext db = DatabaseManager.Instance.GetContext();

            try
            {
                dynamic args = new
                {
                    PriceType,
                    datarow.MaterialNo,
                    datarow.VendorCode,
                    datarow.ProdPurpose,
                    datarow.WarpBuyerCode,
                    datarow.SourceType,
                    datarow.PartColorSfx,
                    datarow.PackingType,
                    datarow.CurrCode,
                    datarow.Amount,
                    ValidDateFrom = datarow.ValidDateFromStr,
                    datarow.PriceStatus,
                    UserId
                };
                result = db.SingleOrDefault<string>(SqlFile.SaveUpload, args);
            }
            catch (Exception ex)
            {
                result = result + ex.Message + "\n";
            }
            finally 
            {
                db.Close();
            }

            return result;
        }
        #endregion
    }
}