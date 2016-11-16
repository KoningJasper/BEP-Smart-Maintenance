using System;
using System.Collections.Generic;
using SmartMaintenance.Builders;
using SmartMaintenance.Matlab_Functions;
using SmartMaintenance.Monte_Carlo;

namespace SmartMaintenance
{
    class Program
    {
        static void Main(string[] args)
        {
            // Create matlab instance
            MLApp.MLApp matlab = new MLApp.MLApp();
            Dictionary<double, double> plotSeries = new Dictionary<double, double>
            {
                {0, 1 },
                {1, 3},
                {2, 5}
            };

            Matlab.Plot(matlab, plotSeries);
            Console.Read();
            //Console.WriteLine("Start Monte-Carlo generation.");
            //Console.WriteLine("Simulating 365 days, with 10 hour running precision.");

            //// Execute MC.
            //MonteCarloResult result = MonteCarlo.Execute(1000, ConstantInputBuilder.Build(), TimeSpan.FromDays(365));

            //Console.WriteLine($"Found a reliability of: {result.AdjustedReliability}.");
            //Console.WriteLine($"With inputs: ");
            //foreach (var input in result.Inputs)
            //{
            //    Console.WriteLine($"{input.Task.Name} : {input.Interval}");
            //}


            //// Don't immediately exit.
            //Console.WriteLine("Press any key to quit.");
            //Console.Read();
        }
    }
}
