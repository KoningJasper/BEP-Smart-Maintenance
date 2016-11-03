﻿using System.Linq;

using LinqToExcel;

using SmartMaintenance.Models;

namespace SmartMaintenance.Builders
{
    internal class VesselBuilder
    {
        private const string VesselLocationTimeXLSXFileName = "../../Data/VesselLocations.xlsx";
        public static Vessel Build()
        {
            var excel = new ExcelQueryFactory
            {
                FileName = VesselLocationTimeXLSXFileName
            };
            excel.AddTransformation<LocationTime>(x => x.Location, location =>
            {
                int loc;
                if (int.TryParse(location, out loc))
                    return (Location) loc;
                else
                    return null;
            });
            var locationTimes = (from x in excel.Worksheet<LocationTime>() select x).ToArray();

            return new Vessel()
            {
                RequiredReliability = 0.99,
                LocationOverTime = locationTimes
            };
        }
    }
}
