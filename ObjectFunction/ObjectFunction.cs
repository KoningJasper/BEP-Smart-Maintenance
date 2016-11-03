using System;

using SmartMaintenance.Models;

namespace SmartMaintenance.ObjectFunction
{
    internal class ObjectFunction
    {
        public double Evaluate(ConstantInputs constantInputs, VariableInput[] variableInputs)
        {
            return new Random().NextDouble();
        }
    }
}
