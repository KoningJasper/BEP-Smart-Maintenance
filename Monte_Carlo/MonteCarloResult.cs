using SmartMaintenance.Models;

namespace SmartMaintenance.Monte_Carlo
{
    internal class MonteCarloResult
    {
        // Public properties
        public double AdjustedReliability { get; set; }
        public VariableInput[] Inputs { get; set; }
    }
}
