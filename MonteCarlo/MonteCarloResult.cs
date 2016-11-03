using SmartMaintenance.Models;

namespace SmartMaintenance.MonteCarlo
{
    internal class MonteCarloResult
    {
        // Public properties
        public int FoundAtLoop { get; set; }
        public decimal AdjustedReliability { get; set; }
        public VariableInput[] Inputs { get; set; }
    }
}
