using System;
using System.Collections.Generic;
using System.Linq;
using SmartMaintenance.Models;

namespace SmartMaintenance.ObjectFunction
{
    internal static class TsaiModel
    {
        public class TimeSerie
        {
            public double Step { get; set; }
            public double Probability { get; set; }
        }

        public class InputWithDate : VariableInput
        {
            public DateTime Date { get; set; }
        }

        /// <summary>
        /// Evaluate a single component using the TsaiModel
        /// </summary>
        /// <returns>Return reliability over time according to Tsai.</returns>
        internal static TimeSerie[] Tsai(double maxStep, double timestep, Component component, VariableInput[] inputs)
        {
            var convertedInputs = inputs.Select(x => new InputWithDate()
            {
                Date = ObjectFunction.GetDate(x),
                Interval = x.Interval,
                Task = x.Task
            });

            List<TimeSerie> series = new List<TimeSerie>();
            double currentStep = 0;

            while (currentStep < maxStep)
            {
                DateTime currentDate = DateTime.Now + TimeSpan.FromHours(currentStep);

                // Calculate proability
                double f_0 = component.K/component.Lambda*Math.Pow(currentStep/component.Lambda, component.K - 1)*
                           Math.Pow(Math.E, -Math.Pow(currentStep/component.Lambda, component.K));

                double f = 0;
                if (convertedInputs.Any(x => x.Date >= currentDate))
                {
                    Task task = convertedInputs.Last(x => x.Date >= currentDate).Task;
                    f = 1 - (f_0 +
                             1/task.M1*(component.K/component.Lambda)*
                             Math.Pow(((1/task.M1)*currentStep/component.Lambda), component.K - 1));
                }
                else
                {
                    f = 1 - f_0;
                }

                series.Add(new TimeSerie()
                {
                    Step = currentStep,
                    Probability = f
                });
                currentStep += timestep;
            }

            return series.ToArray();
        }
    }
}
