using System;

namespace SmartMaintenance.Models
{
    internal class Task
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public Location Location { get; set; }
        public float Duration { get; set; }
        public float? MaxIntervalWeeks { get; set; }
        public float? MaxIntervalRunningHours { get; set; }
        public int AffectedComponentId { get; set; }
        public float M1 { get; set; }
        public float M2 { get; set; }
    }
}
