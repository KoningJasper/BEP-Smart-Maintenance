namespace SmartMaintenance.Models
{
    internal class Vessel
    {
        public decimal RequiredReliability { get; set; }
        public LocationTime[] LocationOverTime { get; set; }
    }
}
