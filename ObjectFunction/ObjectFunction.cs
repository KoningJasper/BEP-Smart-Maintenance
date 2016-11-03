using System;
using System.Linq;

using SmartMaintenance.Models;

namespace SmartMaintenance.ObjectFunction
{
    internal class ObjectFunction
    {
        public double Evaluate(ConstantInputs constantInputs, VariableInput[] variableInputs)
        {
            foreach (var input in variableInputs)
            {
                DateTime date = DateTime.Now + TimeSpan.FromDays(input.Interval*input.Task.MaxIntervalWeeks.Value*7);

                // Check if location is correct.
                if (constantInputs.Vessel.LocationOverTime.Any(x => x.DateTime >= date))
                {
                    LocationTime locationTime = constantInputs.Vessel.LocationOverTime.First(x => x.DateTime >= date);

                    if (locationTime.Location != input.Task.Location)
                        // Invalid location.
                        return 0;
                } else 
                    // Not possible.
                    return 0;
            }
            return new Random().NextDouble();
        }
    }
}
