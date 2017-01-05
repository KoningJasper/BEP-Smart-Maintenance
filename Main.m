%% Program Initialization
% Clear
clear;
close all;
clc;
addpath('Data', 'Locaters', 'ObjectFunction', 'Output');
delete('/Results/*.mat')

%% User Inputs
MCH                     = input('Cost per manhour, for maintenance: ');         % Manhour cost per hour (MCH), for maintenance.
PCH                     = input('Penalty cost per hour of downtime: ');         % Penalty Cost per Hour (PCH), Cost per hour of downtime extra, can be charter-rate per hour.
TFC                     = input('Time factor for maintenance at sea: ');        % Time factor for maintenance while at sea, time factor at sea(TFC).
noCores                 = input('Number of logical CPU cores to run on: ');     % Number of logical CPU cores.
noRuns                  = input('number of simulations to excecute: ');         % Number of MonteCarlo runs.
%t_max                   = input('schedule time (h): ');                         % Maximum simulation time (h(if t_p is 1)).

% Parameters
t_p                     = 1;                                                     % Time Step (h)
margin_MC               = 0.5;                                                   % Margin in planning in % van gevonden planning.
margin_MC_abs           = 10;                                                    % Absolute margin in hours.
allowForward            = true;                                                  % Allow maintenance to occur later 
exceedComponentMax      = false;                                                 % Exceed the specified component max time between maintenance.

% Read data
disp('Reading excel data.');
Components              = DataReader('Data/Components.xls');                      % Reads the component that are pressent in the symstem.
Tasks                   = DataReader('Data/Tasks.xls');                           % Reads the task taht need to be planed.
%VesselLoc               = SailingScheduleGenerator(t_max,t_p);                    % Reads the sailing schedule of the vessel to determind its location(port dock sailing)
%VesselLoc               = ones(50, 2);
VesselLoc               = [zeros(6000, 1) zeros(6000,1)];
t_max                   = size(VesselLoc, 1);
runningHours            = GetRunningHoursTally(VesselLoc, t_p);
maxRunningHours         = runningHours(end);

%% Setup
disp('Initializing');
startProgramTime = tic;                                                         % measuring running time of the entire program 

% Construct failure rate data   
FRT   = ConstructFailureRateGraphsPerTask(maxRunningHours, Tasks, Components);            %Failure_Rate_Per_Task (FRT)
FR0   = ConstructFailureRateGraphsNoMaintenance(maxRunningHours, Components);             %Failure_Rate_Graphs_No_Maintenance (FR0)


%% Monte-Carlo (MC)
% Setup parallel cluster (to reduce running time of the program, MC simulation is run on sevreal cores)
delete(gcp('nocreate'));                                                    % deleting existing parallelpool 
localCluster            = parcluster('local');
localCluster.NumWorkers = noCores;
saveProfile(localCluster);
parpool(noCores);

% Make a empty matrix and preperations for MC
disp('Starting Monte-Carlo simulation');
start_output    = tic;                                                            % start timer for measering executen time MC.
numberOfTasks   = size(Tasks, 1);
results         = cell(noRuns, 1);

% Execute objective function(MC) to find objective-parameters.
hbar = parfor_progressbar(noRuns,'Please wait...');
parfor r=1:noRuns
    % Generate random input intervals for each of the tasks.
    inputs = GenerateRandomInput(0.8, Tasks);
    [totalCosts, Cost_CM, Cost_PM, FRPerCompOT, startTimes, endTimes] = ObjectFunction(FRT, FR0, inputs, t_max, t_p, Components, Tasks, VesselLoc, allowForward, margin_MC, margin_MC_abs, MCH, PCH, TFC, runningHours);
    
    % Write results
    SaveResults(strcat('Results/', 'run_', num2str(r), '.mat'), {totalCosts Cost_CM Cost_PM FRPerCompOT startTimes endTimes inputs'});
    results(r, :) = {totalCosts};
    hbar.iterate(1);
end
close(hbar);
disp(['Monte-Carlo simulation executed in ', num2str(toc(start_output)), 's']);     %stop timmer for executions time MC and dislpay in workspace.
  
% Extract best result
[Y, I] = min(cell2mat(results(:, 1)));
if(results{I, 1} == realmax('single'))
    error('No solution found.');
end

% Display results
load(strcat('Results/', 'run_', num2str(I), '.mat'));
disp(['Total cost: ', num2str(result{1, 1})]);
disp(['CM cost: ', num2str(sum(result{1, 2}))]);
disp(['PM cost: ', num2str(sum(result{1, 3}))]);
GatherOutput(result{1, 4}, Components);
OutputPlanningCalendar(result{1,5}, t_p, VesselLoc, Tasks);

%% Cleaning not relevant programm requirments and show executiontime
delete(gcp('nocreate'));                                                     % deleting the create parallelpool      
delete('/Results/*.mat');                                                    % Cleanup results folder.
disp(['Entire program executed in ', num2str(toc(startProgramTime)), 's']);  %stop timer for measering total runningtime and dislplay.
%clear