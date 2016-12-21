%% Program Initialization
% Clear

clear;
close all;
clc;
addpath('Data', 'Locaters', 'ObjectFunction');


%% User Inputs

R_min                   = input('Required minimum reliability: ');              % Minimum reliability;
MCH                     = input('Cost per manhour, for maintenance: ');         % Manhour cost per hour (MCH), for maintenance.
PCH                     = input('Penalty cost per hour of downtime: ');         % Penalty Cost per Hour (PCH), Cost per hour of downtime extra, can be charter-rate per hour.
TFC                     = input('Time factor for maintenance at sea: ');        % Time factor for maintenance while at sea, time factor at sea(TFC).
noCores                 = input('Number of logical CPU cores to run on: ');     % Number of logical CPU cores.
noRuns                  = input('number of simulations to excecute: ');         % Number of MonteCarlo runs.
t_max                   = input('schedule time (h): ');                         % Maximum simulation time (h(if t_p is 1)).

% Parameters
t_p                     = 1;                                                     % Time Step (h)
margin_MC               = 0.5;                                                   % Margin in planning
allowForward            = true;                                                  % Allow maintenance to occur later 
exceedComponentMax      = false;                                                 % Exceed the specified component max time between maintenance.

% Read data
disp('Reading excel data.');
Components              = DataReader('Data/Components.xls');                      % Reeds the component that are pressent in the symstem.
Tasks                   = DataReader('Data/Tasks.xls');                           % Reeds the task taht need to be planed.
VesselLoc               = SailingScheduleGenerator(t_max,t_p);                    % Reeds the sailing schedule of the vessel to determind its location(port dock sailing)


%{ 
If a complete sailing schedule is available, a new function should be
written, which reads the excel file of that sailing schedule and devides
it into time-steps.
%}
 

%% Setup
disp('Initializing');
startProgramTime = tic;                                                         % measuring running time of the entire program 


% Construct failure rate data   
FRT   = ConstructFailureRateGraphsPerTask(t_max, Tasks, Components);            %Failure_Rate_Per_Task (FRT)
FR0   = ConstructFailureRateGraphsNoMaintenance(t_max, Components);             %Failure_Rate_Graphs_No_Maintenance (FR0)



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
results         = zeros(noRuns, numberOfTasks + 1);


% Execute objective function(MC) to find objective-parameters.
parfor r=1:noRuns
  
    % Generate random input intervals for each of the tasks.
    inputs = GenerateRandomInput(0.5, Tasks);
    totalCosts = ObjectFunction(FRT, FR0, inputs, t_max, t_p, Components, Tasks, VesselLoc, allowForward, margin_MC, MCH, PCH, TFC);
    
    % Write results
    results(r, :) = [totalCosts cell2mat(inputs')];
end

disp(['Monte-Carlo simulation executed in ', num2str(toc(start_output)), 's']);     %stop timmer for executions time MC and dislpay in workspace.
  
% Extract best result
[Y, I] = min(results(:, 1));
inputmat = results(I, 2:end)';
input = mat2cell(inputmat, size(inputmat, 1), 1);
GatherOutput(FRT, FR0, input, t_max, t_p, Components, Tasks, VesselLoc, allowForward, margin_MC);


%% Cleaning not relevant programm requirments and show executiontime

delete(gcp('nocreate'))                                                      %deleting the create parallelpool      
disp(['Entire program executed in ', num2str(toc(startProgramTime)), 's']);  %stop timer for measering total runningtime and dislplay.
