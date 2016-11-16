using System.Collections.Generic;

using SmartMaintenance.Models;

namespace SmartMaintenance.Matlab_Functions
{
    /// <summary>
    /// Communicate with MatLab
    /// </summary>
    internal static class Matlab
    {
        internal static void Plot(MLApp.MLApp matlab, Dictionary<double, double> timeSeriesToPlot)
        {
            string x = null, y = null;
            foreach (var serie in timeSeriesToPlot)
            {
                x += "," + serie.Key;
                y += "," + serie.Value;
            }
            x = x?.TrimStart(',');
            y = y?.TrimStart(',');
            matlab.Execute("new figure;");
            matlab.Execute($"x = [{x}];");
            matlab.Execute($"y = [{y}];");
            matlab.Execute($"plot(x,y);");
        }

        /// <summary>
        /// Plot a timeseries using matlab.
        /// </summary>
        /// <param name="timeSerie"></param>
        internal static void Plot(TimeSerie timeSerie)
        {
            MLApp.MLApp matlab = new MLApp.MLApp();
            //matlab.Execute("x = ")
        }

        /// <summary>
        /// Calculate the reliability of an component at the n-th step.
        /// </summary>
        /// <param name="component">The component to calculate the reliability of.</param>
        /// <returns>Reliability of the component, between 0 and 1.</returns>
        //internal static double TsaiReliability(double k, double lambda, double m1, double m2)
        //{
        //    MLApp.MLApp matlab = new MLApp.MLApp();
        //    //
        //}
    }
}