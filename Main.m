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
for n = 1:100
    input = GenerateRandomInput(Tasks);
end
