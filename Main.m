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
Output = zeros(size(Tasks, 1), 1);

for n = 1:50
    % Generate random input intervals for each of the tasks.
    inputs = GenerateRandomInput(Tasks);
    
    % Execute objective function to find objective-param.
    [Output_objective, interval] = ObjectFunction(inputs, t_max, t_p, Components, Tasks, VesselLocations);
    
    % Monte-Carlo check better solution.
    if Output_objective >= Output_number
        Output_number = Output_objective;
        Output = inputs;
    end
end

% Output
Output_number
Output