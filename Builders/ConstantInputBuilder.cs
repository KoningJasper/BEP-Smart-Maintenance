using SmartMaintenance.Models;

namespace SmartMaintenance.Builders
{
    internal static class ConstantInputBuilder
    {
        public static ConstantInputs Build()
        {
            return new ConstantInputs()
            {
                Components = ComponentBuilder.Build(),
                TaskList = TaskBuilder.Build(),
                Vessel = VesselBuilder.Build()
            };
        }
    }
}
