using System;
using System.Collections.Generic;
using System.Linq;

using SmartMaintenance.Models;

namespace SmartMaintenance.Functions
{
    internal static class ObjectFunction
    {
        public static double Evaluate(ConstantInputs constantInputs, VariableInput[] variableInputs, TimeSpan simulationTime)
        {
            //// Input verification
            //foreach (var input in variableInputs)
            //{
            //    DateTime date = GetDate(input);

            //    // Check if location is correct.
            //    if (constantInputs.Vessel.LocationOverTime.Any(x => x.DateTime <= date))
            //    {
            //        LocationTime locationTime = constantInputs.Vessel.LocationOverTime.Last(x => x.DateTime <= date);

            //        if (locationTime.Location != input.Task.Location)
            //            // Invalid location.
            //            return 0;
            //    } else 
            //        // Not possible.
            //        return 0;
            //}

            //// Component Verification
            //List<TimeSerie[]> sim = new List<TimeSerie>();
            //foreach (Component comp in constantInputs.Components)
            //{
            //    List<TimeSerie> componentReliability = new List<TimeSerie>();

            //    // Simulate over time.
            //    int totalSteps = (int) Math.Ceiling(simulationTime.TotalHours / 10);
            //    for (int i = 0; i <= totalSteps; i++)
            //    {
            //        var ts = new TimeSerie()
            //        {
            //            Step = i,
            //            Probability = Matlab.Matlab.TsaiReliability(comp, i);
            //        };
            //    }
            //}
            return new double();
        }

        public static DateTime GetDate(VariableInput input)
        {
            return DateTime.Now + TimeSpan.FromDays(input.Interval * input.Task.MaxIntervalWeeks.Value * 7);
        }
    }
}
