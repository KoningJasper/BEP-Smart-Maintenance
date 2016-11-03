using System;

namespace SmartMaintenance.Models
{
    internal class Task
    {
        public Guid Id { get; set; }
        public string Name { get; set; }
        public Location Location { get; set; }
        public float Duration { get; set; }
        public float? MaxIntervalWeeks { get; set; }
        public float? MaxIntervalRunningHours { get; set; }
        public Component AffectedComponent { get; set; }
        public float M1 { get; set; }
        public float M2 { get; set; }
    }
}
