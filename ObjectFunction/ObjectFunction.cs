using System;
using System.Collections.Generic;
using System.Linq;

using SmartMaintenance.Models;

namespace SmartMaintenance.ObjectFunction
{
    internal class ObjectFunction
    {
        public double Evaluate(ConstantInputs constantInputs, VariableInput[] variableInputs, TimeSpan simulationTime)
        {
            // Input verification
            foreach (var input in variableInputs)
            {
                DateTime date = GetDate(input);

                // Check if location is correct.
                if (constantInputs.Vessel.LocationOverTime.Any(x => x.DateTime <= date))
                {
                    LocationTime locationTime = constantInputs.Vessel.LocationOverTime.Last(x => x.DateTime <= date);

                    if (locationTime.Location != input.Task.Location)
                        // Invalid location.
                        return 0;
                } else 
                    // Not possible.
                    return 0;
            }

            // Component Verification
            List<TsaiModel.TimeSerie> sim = new List<TsaiModel.TimeSerie>();
            foreach (Component comp in constantInputs.Components)
            {
                // Evaluate reliability
                var reliabilityOvertime = TsaiModel.Tsai(simulationTime.TotalHours, 10, comp, variableInputs);

                //if (reliabilityOvertime.Any(rt => rt.Probability <= constantInputs.Vessel.RequiredReliability))
                //{
                //    // Console.WriteLine("Lower than required reliability");
                //    return 0;
                //}

                if (!sim.Any())
                    sim = reliabilityOvertime.ToList();
                else
                {
                    foreach (TsaiModel.TimeSerie serie in reliabilityOvertime)
                    {
                        var matchedSerie = sim.Find(x => x.Step == serie.Step);
                        matchedSerie.Probability *= serie.Probability;
                    }
                }
            }

            return sim.Any() ? sim.Min(x => x.Probability) : 0;
        }

        public static DateTime GetDate(VariableInput input)
        {
            return DateTime.Now + TimeSpan.FromDays(input.Interval * input.Task.MaxIntervalWeeks.Value * 7);
        }
    }
}
