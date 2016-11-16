namespace SmartMaintenance.Models
{
    internal class ConstantInputs
    {
        public Vessel Vessel { get; set; }
        public Component[] Components { get; set; }
        public Task[] TaskList { get; set; }
    }
}
