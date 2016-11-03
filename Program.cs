using System;

using SmartMaintenance.Builders;

namespace SmartMaintenance
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Start Monte-Carlo generation.");
            new MonteCarlo.MonteCarlo(1000, ConstantInputBuilder.Build()).Execute();
        }
    }
}
