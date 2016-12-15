%% Program Initialization
clear;
close all;
clc;
addpath('Data', 'Locaters', 'ObjectFunction', 'Reliability');


% User Inputs
%R_min              = input('Required minimum reliability: ');              % Minimum reliability;
% ManhourCostPerHour = input('Cost per manhour, for maintenance: ');         % Cost per man hour, for maintenance.
% PenaltyCostPerHour = input('Penalty cost per hour of downtime: ');         % Cost per hour of downtime extra, can be charter-rate per hour.
% timeFactorAtSea    = input('Time factor for maintenance at sea: ');        % Time factor for maintenance while at sea.
% noCores            = input('Number of logical CPU cores to run on: ');     % Number of logical CPU cores.

ManhourCostPerHour = 15;
PenaltyCostPerHour = 5000;
timeFactorAtSea    = 3;
noCores            = 4;

% Setup
startProgramTime = tic;
disp('Initializing');


minRuns = input('Minimum number of runs: ');
maxRuns = input('Maximum number of runs: ');
runStep = input('Run step size: ');

% Parameters
t_p                = 1;     % Time Step (h)
t_max              = 10000; % Maximum simulation time.
noRuns             = 10000; % Number of MonteCarlo runs.
margin_MC          = 0.5;   % Margin in planning
allowForward       = true;  % Allow maintenance to occur later 
exceedComponentMax = false; % Exceed the specified component max time between maintenance.

% Read data
disp('Reading excel data.');
Components      = DataReader('ActualData/Components.xls');
Tasks           = DataReader('ActualData/Tasks.xls');
VesselLocations = VaarschemaMakerFunctie(t_max,t_p); 
% If a complete sailing schedule is available, a new function should be
% written, which reads the excel file of that sailing schedule and devides
% it into time-steps.

% Construct failure rate data
failure_rate_construction = tic;
Failure_Rate_Per_Task              = ConstructFailureRateGraphsPerTask(t_max, Tasks, Components);
Failure_Rate_Graphs_No_Maintenance = ConstructFailureRateGraphsNoMaintenance(t_max, Components);
disp(['Construction of failure-rate took: ', num2str(toc(failure_rate_construction)), 's']);

%% Monte-Carlo
% Setup parallel cluster
localCluster = parcluster('local');
localCluster.NumWorkers = noCores;
saveProfile(localCluster);
delete(gcp('nocreate'))
parpool(noCores);

runs = minRuns:runStep:maxRuns;

bestResult = zeros(size(runs, 2), 2);
figure;
for ru = minRuns:runStep:maxRuns
    % Execute MC %
    numberOfTasks = size(Tasks, 1);
    results       = zeros(ru, numberOfTasks + 1);

    % Execute objective function to find objective-param.
    start_output = tic;
    disp('Starting Monte-Carlo simulation');
    parfor r=1:ru
    % for r=1:noRuns
        % Generate random input intervals for each of the tasks.
        inputs = GenerateRandomInput(0.5, Tasks);

        totalCosts = ObjectFunction(Failure_Rate_Per_Task, Failure_Rate_Graphs_No_Maintenance, inputs, t_max, t_p, Components, Tasks, VesselLocations, allowForward, margin_MC, ManhourCostPerHour, PenaltyCostPerHour, timeFactorAtSea);

        % Write results
        results(r, :) = [totalCosts cell2mat(inputs')];
    end
    execution_time = toc(start_output);

    disp(['Monte-Carlo simulation executed in ', num2str(execution_time), 's']);
    disp(['Evaluations per second: ', num2str(1/(execution_time/ru))]);

    % Extract best result
    [Y, I] = min(results(:, 1));
    inputmat = results(I, 2:end)';
    input = mat2cell(inputmat, size(inputmat, 1), 1);
    
    bestResult(ru, :) = [ru Y];
    
    hold on;
    plot(ru, Y, '*');
    drawnow();
end

disp(['Entire program executed in ', num2str(toc(startProgramTime)), 's']);