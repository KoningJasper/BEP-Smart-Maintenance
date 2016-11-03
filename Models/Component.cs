using System;

namespace SmartMaintenance.Models
{
    internal class Component
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public float Lambda { get; set; }
        public float K { get; set; }
        public float SI { get; set; }
    }
}
