using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using SmartMaintenance.Functions;
using SmartMaintenance.Models;

namespace SmartMaintenance.Matlab
{
    /// <summary>
    /// Communicate with MatLab
    /// </summary>
    internal static class Matlab
    {
        internal static void Plot(Dictionary<double, double> timeSeriesToPlot)
        {
            //MLApp.MLApp matlab = new MLApp.MLApp();
        }

        /// <summary>
        /// Plot a timeseries using matlab.
        /// </summary>
        /// <param name="timeSerie"></param>
        internal static void Plot(TimeSerie timeSerie)
        {
            //MLApp.MLApp matlab = new MLApp.MLApp();
        }

        /// <summary>
        /// Calculate the reliability of an component at the n-th step.
        /// </summary>
        /// <param name="component">The component to calculate the reliability of.</param>
        /// <returns>Reliability of the component, between 0 and 1.</returns>
        internal static double TsaiReliability(Component component)
        {
            
        }
    }
}
