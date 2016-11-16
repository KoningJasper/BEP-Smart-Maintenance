using System;
using System.Linq;

using SmartMaintenance.Functions;
using SmartMaintenance.Models;

namespace SmartMaintenance.MonteCarlo
{
    internal static class MonteCarlo
    {
        // Public methods
        public static MonteCarloResult Execute(int noLoops, ConstantInputs constants, TimeSpan simulationTime)
        {
            MonteCarloResult bestResult = new MonteCarloResult();

            for (int i = 0; i <= noLoops; i++)
            {
                VariableInput[] inputs = GenerateRandomVariableInputs(constants);
                double adjustedReliability = ObjectFunction.Evaluate(constants, inputs, simulationTime);

                // Check if it is better than the previous best result.
                if (adjustedReliability >= bestResult.AdjustedReliability)
                    bestResult = new MonteCarloResult()
                    {
                        AdjustedReliability = adjustedReliability,
                        Inputs = inputs
                    };
            }

            return bestResult;
        }

        // Private methods
        private static VariableInput[] GenerateRandomVariableInputs(ConstantInputs constants)
        {
            return constants.TaskList.Select(task => new VariableInput()
            {
                Interval = new Random().NextDouble(),
                Task = task
            }).ToArray();
        }
    }
}
