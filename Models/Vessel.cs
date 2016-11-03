namespace SmartMaintenance.Models
{
    internal class Vessel
    {
        public double RequiredReliability { get; set; }
        public LocationTime[] LocationOverTime { get; set; }
    }
}
