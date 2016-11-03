using SmartMaintenance.Models;

namespace SmartMaintenance.MonteCarlo
{
    internal class MonteCarloResult
    {
        // Public properties
        public double AdjustedReliability { get; set; }
        public VariableInput[] Inputs { get; set; }
    }
}
