%% Program Initialization
% Clear
clear;
close all;
clc;

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
addpath('ActualData', 'Data', 'Locaters', 'ObjectFunction', 'Reliability');

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

% Execute MC %
numberOfTasks = size(Tasks, 1);
results       = zeros(noRuns, numberOfTasks + 1);

% Execute objective function to find objective-param.
start_output = tic;
disp('Starting Monte-Carlo simulation');
parfor r=1:noRuns
% for r=1:noRuns
    % Generate random input intervals for each of the tasks.
    inputs = GenerateRandomInput(0.5, Tasks);
    
    totalCosts = ObjectFunction(Failure_Rate_Per_Task, Failure_Rate_Graphs_No_Maintenance, inputs, t_max, t_p, Components, Tasks, VesselLocations, allowForward, margin_MC, ManhourCostPerHour, PenaltyCostPerHour, timeFactorAtSea);
    
    % Write results
    results(r, :) = [totalCosts cell2mat(inputs')];
end
execution_time = toc(start_output);
delete(gcp('nocreate'))

disp(['Monte-Carlo simulation executed in ', num2str(execution_time), 's']);
disp(['Evaluations per second: ', num2str(1/(execution_time/noRuns))]);
 
% Extract best result
[Y, I] = min(results(:, 1));
inputmat = results(I, 2:end)';
input = mat2cell(inputmat, size(inputmat, 1), 1);
GatherOutput(Failure_Rate_Per_Task, Failure_Rate_Graphs_No_Maintenance, input, t_max, t_p, Components, Tasks, VesselLocations, allowForward, margin_MC, ManhourCostPerHour, PenaltyCostPerHour, timeFactorAtSea);


disp(['Entire program executed in ', num2str(toc(startProgramTime)), 's']);
% Get other relevant data.
% PlotStuff;

% [Output_number, plotL, plotO, relPerComp, Output, mcpc, hazPerComp, plotH] = ObjectFunction(input, t_max, t_p, Components, Tasks, VesselLocations, allowForward, margin_MC, ManhourCostPerHour, PenaltyCostPerHour, timeFactorAtSea);
% 
% %% Output
% if(Output_number == 0)
%     disp('No solution found!')
%     return;
% end;
% 
% disp(['Found a total cost of $', num2str(round(Output_number, 2)), ' using the following maintenance schedule: ']);
% 
% sz = 1;
% for(i = 1:size(Output, 1))
%     sn = size(Output(i, :), 2);
%     if(sn > sz)
%         sz = sn;
%     end
% end
% 
% strings = {'Taak', 'Naam'};
% T = table((1:size(Output, 1))', Tasks(:, 2));
% for i=1:sz
%     strings{1, i + 2} = strjoin({'Onderhoud', num2str(i)}, '_');
% end
% 
% T1 = array2table(Output);
% T = [T T1];
% T.Properties.VariableNames = strings;
% disp(T);
% %disp(table((1:size(Output, 1))', Output, 'VariableNames', strings));
% 
% % Graphs %
% % Reliability
% figure;
% plot(plotL);
% title('Reliability over time')
% xlabel('Time (h)');
% ylabel('Reliability (-)');
% 
% % Hazard
% figure;
% plot(plotH);
% title('Failure-rate over time')
% xlabel('Time (h)');
% ylabel('Failure-Rate (-)');
% 
% 
% % Adjusted availability
% % Ad. av = sum t_0 to t_max [delta_t * (1 - failure_rate(t))]
% figure;
% plot(plotO);
% title('Cost over time');
% xlabel('Time (h)');
% ylabel('Cost ($)');
% 
% % Reliability per component %
% figure;
% title('Reliability over time per component.');
% xlabel('Time (h)');
% ylabel('Reliability (-)');
% legendStrings = {};
% for i = 1:size(relPerComp, 2)
%     hold on;
%     legendStrings{i} = Components{i, 2};
%     plot(relPerComp(:, i));
% end
% legend(legendStrings);
% 
% figure;
% title('Failure-rate over time per component');
% xlabel('Time (h)');
% ylabel('Failure-Rate (-)');
% legendStrings = {};
% for i = 1:size(relPerComp, 2)
%     hold on;
%     legendStrings{i} = Components{i, 2};   
%     plot(hazPerComp(:, i));    
% end
% legend(legendStrings);
% % END Output %
% 
% disp(['Program executed in ', num2str(toc(startProgramTime)), 's']);