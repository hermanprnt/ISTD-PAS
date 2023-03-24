using System;
using System.Collections.Generic;
using System.Globalization;
using GPS.ViewModels.MRP;

namespace GPS.Models.MRP
{
    public class MRPInquiryRepository
    {
        private MRPInquiryRepository() { }
        private static readonly MRPInquiryRepository instance = null;
        public static MRPInquiryRepository Instance
        {
            get { return instance ?? new MRPInquiryRepository(); }
        }

        public IEnumerable<MaterialResourcePlanning> GetMRPList(MRPSearchViewModel searchViewModel)
        {
            yield return new MaterialResourcePlanning
            {
                DataNo = 1,
                MRPMonth = CultureInfo.CurrentCulture.DateTimeFormat.GetAbbreviatedMonthName(9),
                PRNo = "PR14764391",
                Status = String.Empty,
                CreatedBy = "Tekad",
                CreatedDate = DateTime.Parse("2015-06-17 02:55:38.340"),
                ChangedBy = "Puthut",
                ChangedDate = DateTime.Parse("2015-06-17 02:55:38.340"),
                POApprovalBy = "Tino",
                POApprovalDate = DateTime.Parse("2015-06-17 02:55:38.340"),
                POReleasedBy = "Lucki",
                POReleasedDate = DateTime.Parse("2015-06-17 02:55:38.340")
            };

            yield return new MaterialResourcePlanning
            {
                DataNo = 2,
                MRPMonth = CultureInfo.CurrentCulture.DateTimeFormat.GetAbbreviatedMonthName(10),
                PRNo = "PR02396626",
                Status = "Released",
                CreatedBy = "Mamun",
                CreatedDate = DateTime.Parse("2014-02-18 12:43:01.190"),
                ChangedBy = "Muslichudin",
                ChangedDate = DateTime.Parse("2014-02-18 12:43:01.190"),
                POApprovalBy = "Yudho",
                POApprovalDate = DateTime.Parse("2014-02-18 12:43:01.190"),
                POReleasedBy = "Akyas",
                POReleasedDate = DateTime.Parse("2014-02-18 12:43:01.190")
            };

            yield return new MaterialResourcePlanning
            {
                DataNo = 3,
                MRPMonth = CultureInfo.CurrentCulture.DateTimeFormat.GetAbbreviatedMonthName(10),
                PRNo = "PR79013717",
                Status = "Created",
                CreatedBy = "Casnuri",
                CreatedDate = DateTime.Parse("2013-03-21 00:26:15.190"),
                ChangedBy = "Nur",
                ChangedDate = DateTime.Parse("2013-03-21 00:26:15.190"),
                POApprovalBy = "Abdillah",
                POApprovalDate = DateTime.Parse("2013-03-21 00:26:15.190"),
                POReleasedBy = "Suprihatin",
                POReleasedDate = DateTime.Parse("2013-03-21 00:26:15.190")
            };

            yield return new MaterialResourcePlanning
            {
                DataNo = 4,
                MRPMonth = CultureInfo.CurrentCulture.DateTimeFormat.GetAbbreviatedMonthName(7),
                PRNo = "PR88576098",
                Status = String.Empty,
                CreatedBy = "Saripudin",
                CreatedDate = DateTime.Parse("2015-09-11 16:46:00.510"),
                ChangedBy = "Sakiman",
                ChangedDate = DateTime.Parse("2015-09-11 16:46:00.510"),
                POApprovalBy = "Hartomo",
                POApprovalDate = DateTime.Parse("2015-09-11 16:46:00.510"),
                POReleasedBy = "Fajriyanto",
                POReleasedDate = DateTime.Parse("2015-09-11 16:46:00.510")
            };

            yield return new MaterialResourcePlanning
            {
                DataNo = 5,
                MRPMonth = CultureInfo.CurrentCulture.DateTimeFormat.GetAbbreviatedMonthName(3),
                PRNo = "PR05529634",
                Status = "Created",
                CreatedBy = "Adwanto",
                CreatedDate = DateTime.Parse("2014-11-20 23:13:12.530"),
                ChangedBy = "Sonni",
                ChangedDate = DateTime.Parse("2014-11-20 23:13:12.530"),
                POApprovalBy = "Suseno",
                POApprovalDate = DateTime.Parse("2014-11-20 23:13:12.530"),
                POReleasedBy = "Sandi",
                POReleasedDate = DateTime.Parse("2014-11-20 23:13:12.530")
            };

        }

        public MaterialResourcePlanning GetMRP(String procUsageGroup, String mrpMonth)
        {
            return new MaterialResourcePlanning
            {
                MRPMonth = CultureInfo.CurrentCulture.DateTimeFormat.GetAbbreviatedMonthName(10),
                PRNo = "PR79013717",
                Status = "Created",
                CreatedBy = "Casnuri",
                CreatedDate = DateTime.Parse("2013-03-21 00:26:15.190"),
                ChangedBy = "Nur",
                ChangedDate = DateTime.Parse("2013-03-21 00:26:15.190"),
                POApprovalBy = "Abdillah",
                POApprovalDate = DateTime.Parse("2013-03-21 00:26:15.190"),
                POReleasedBy = "Suprihatin",
                POReleasedDate = DateTime.Parse("2013-03-21 00:26:15.190")
            };
        }

        public IEnumerable<MRPItem> GetMRPItemList(String procUsageGroup, String mrpMonth)
        {
            yield return new MRPItem
            {
                DataNo = 1,
                MaterialCode = "091110K030",
                MaterialDesc = "ATK",
                Plant = "KARAWANG",
                SLoc = "Super Steel Indah (KRW)",
                PcsPerKanban = 9,
                NQty = 11,
                N1Qty = 5,
                N2Qty = 9,
                N3Qty = 5,
                N4Qty = 10,
                N5Qty = 19
            };

            yield return new MRPItem
            {
                DataNo = 2,
                MaterialCode = "11256TSG90",
                MaterialDesc = "TOOL SET, STD L/JACK",
                Plant = "SUNTER 2",
                SLoc = "PAD",
                PcsPerKanban = 11,
                NQty = 5,
                N1Qty = 9,
                N2Qty = 11,
                N3Qty = 11,
                N4Qty = 19,
                N5Qty = 15
            };

            yield return new MRPItem
            {
                DataNo = 3,
                MaterialCode = "115110C010",
                MaterialDesc = "RETAINER, OIL SEAL",
                Plant = "KARAWANG",
                SLoc = "DUMMY Area for QUALITY Part (GI to WBS)",
                PcsPerKanban = 5,
                NQty = 9,
                N1Qty = 10,
                N2Qty = 5,
                N3Qty = 9,
                N4Qty = 15,
                N5Qty = 19
            };

            yield return new MRPItem
            {
                DataNo = 4,
                MaterialCode = "111150C011",
                MaterialDesc = "TOOL SET STATIONARY TRIAL",
                Plant = "SUNTER 1",
                SLoc = "Packing",
                PcsPerKanban = 10,
                NQty = 11,
                N1Qty = 9,
                N2Qty = 10,
                N3Qty = 19,
                N4Qty = 5,
                N5Qty = 9
            };

            yield return new MRPItem
            {
                DataNo = 5,
                MaterialCode = "091110K030",
                MaterialDesc = "Wallpaper",
                Plant = "SUNTER 1",
                SLoc = "DUMMY SLOC for MIGRATION",
                PcsPerKanban = 10,
                NQty = 10,
                N1Qty = 11,
                N2Qty = 5,
                N3Qty = 10,
                N4Qty = 19,
                N5Qty = 11
            };

        }
    }
}