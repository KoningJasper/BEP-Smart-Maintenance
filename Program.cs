using System;

using SmartMaintenance.Builders;
using SmartMaintenance.MonteCarlo;

namespace SmartMaintenance
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Start Monte-Carlo generation.");
            Console.WriteLine("Simulating 365 days, with 10 hour running precision.");
            
            // Execute MC.
            MonteCarloResult result = new MonteCarlo.MonteCarlo(1000, ConstantInputBuilder.Build(), TimeSpan.FromDays(365)).Execute();

            Console.WriteLine($"Found a reliability of: {result.AdjustedReliability}.");
            Console.WriteLine($"With inputs: ");
            foreach (var input in result.Inputs)
            {
                Console.WriteLine($"{input.Task.Name} : {input.Interval}");
            }
            

            // Don't immediately exit.
            Console.WriteLine("Press any key to quit.");
            Console.Read();
        }
    }
}
