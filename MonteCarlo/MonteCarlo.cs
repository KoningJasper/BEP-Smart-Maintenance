using System;
using System.Linq;

using SmartMaintenance.Models;

namespace SmartMaintenance.MonteCarlo
{
    internal class MonteCarlo
    {
        // Private variables.
        private readonly int _NumberOfLoops;
        private readonly ConstantInputs _ConstantInputs;
        private readonly TimeSpan _SimulationTime;

        // Public methods
        public MonteCarloResult Execute()
        {
            MonteCarloResult bestResult = new MonteCarloResult();

            for (int i = 0; i <= _NumberOfLoops; i++)
            {
                VariableInput[] inputs = GenerateRandomVariableInputs();
                double adjustedReliability = new ObjectFunction.ObjectFunction().Evaluate(_ConstantInputs, inputs, _SimulationTime);

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
        private VariableInput[] GenerateRandomVariableInputs()
        {
            return _ConstantInputs.TaskList.Select(task => new VariableInput()
            {
                Interval = new Random().NextDouble(),
                Task = task
            }).ToArray();
        }

        // Instance
        public MonteCarlo(int noLoops, ConstantInputs constants, TimeSpan simulationTime)
        {
            _NumberOfLoops  = noLoops;
            _ConstantInputs = constants;
            _SimulationTime = simulationTime;
        }
    }
}
