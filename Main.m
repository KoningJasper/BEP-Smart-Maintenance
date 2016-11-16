% Clear
clear all;

% Parameters
t_p   = 1; % Time Step (h)

% Read data
Components      = DataReader('Data/Components.xls');
Tasks           = DataReader('Data/Tasks.xls');
VesselLocations = DataReader('Data/VesselLocations.xls');

% Set params according to data
t_max = (length(VesselLocations) - 1) * t_p; % in h

% Monte-Carlo
Output_number = 0;

for n = 1:100
    inputs = GenerateRandomInput(Tasks);
    inputs_size = length(inputs);
    for m = 1:inputs_size
        [beta, eta] = FindWeibullOfComponentByTaskId(inputs{m, 1}, Tasks, Components);
    end
    % [Output_objective,interval] = Objective_Function (....)
    if Output_objective => Output
    Output_number = Output_objective;
    Output = interval;
    end
end

% Output
