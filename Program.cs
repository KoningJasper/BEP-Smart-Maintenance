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

            // Execute MC.
            MonteCarloResult result = new MonteCarlo.MonteCarlo(1000, ConstantInputBuilder.Build()).Execute();

            Console.WriteLine($"Result found at loop: {result.FoundAtLoop}.");
            Console.WriteLine($"With a reliability of: {result.AdjustedReliability}.");

            // Don't immediately exit.
            Console.WriteLine("Press any key to quit.");
            Console.Read();
        }
    }
}
