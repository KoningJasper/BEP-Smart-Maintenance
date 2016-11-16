% Clear
clear all;

% Read data
Components      = DataReader('Data/Components.xls');
Tasks           = DataReader('Data/Tasks.xls');
VesselLocations = DataReader('Data/VesselLocations.xls');

% Monte-Carlo
for n = 1:100
    input = GenerateRandomInput(Tasks);
end
