%% Program Initialization %%
% Clear
close all;
clc;

% Parameters
t_p     = 1;  % Time Step (h)
no_runs = 10; % Number of MonteCarlo runs.

% Read dummy data
Components      = DataReader('Data/Components.xls');
Tasks           = DataReader('Data/Tasks.xls');
VesselLocations = DataReader('Data/VesselLocations.xls');
VesselLocations = VesselLocations(:, 2);

% Set params according to data
t_max = (length(VesselLocations) - 1) * t_p; % in h

% Read actual data
% t_max           = 10*24; % in h
% Components      = DataReader('ActualData/Components.xls');
% Tasks           = DataReader('ActualData/Tasks.xls');
% VesselLocations = VaarschemaMakerFunctie(t_max,t_p);

%% Monte-Carlo %%
% INIT %
Output_number = 0;
Output        = zeros(size(Tasks, 1), 1);
plotL         = [];
plotO         = [];
relPerComp    = [];
mcpc          = [];
% END INIT %

% Execute MC %
for n = 1:no_runs
    % Generate random input intervals for each of the tasks.
    inputs = GenerateRandomInput(Tasks);
    
    % Execute objective function to find objective-param.
    [Output_objective, plotLambda, plotObj, lambdaOverTime, maintenanceTimes, maintenanceTimePerComponent] = ObjectFunction(inputs, t_max, t_p, Components, Tasks, VesselLocations, true, 0.2);
    
    % Monte-Carlo check if is better solution.
    if Output_objective >= Output_number
        Output_number = Output_objective;
        Output        = maintenanceTimes;
        plotL         = plotLambda;
        plotO         = plotObj;
        relPerComp    = lambdaOverTime;
        mcpc          = maintenanceTimePerComponent;
    end
end
% END Execute MC %

%% Output %%
if(Output_number == 0)
    disp('No solution found!')
    return;
end;

disp(['De gevonden maximum adjusted availability is ', num2str(round(Output_number, 1)), ' h bij een de volgende onderhouds-intervallen: ']);

sz = 1;
for(i = 1:size(Output, 1))
    sn = size(Output(i, :), 2);
    if(sn > sz)
        sz = sn;
    end
end

strings = {'Taak', 'Naam'};
T = table((1:size(Output, 1))', Tasks(:, 2));
for i=1:sz
    strings{1, i + 2} = strjoin({'Onderhoud', num2str(i)}, '_');
end

T1 = array2table(Output);
T = [T T1];
T.Properties.VariableNames = strings;
disp(T);
%disp(table((1:size(Output, 1))', Output, 'VariableNames', strings));

% Graphs %
% Reliability
% Rel. = 1 - failure_rate
figure;
plot(plotL);
title('Reliability over time')
xlabel('Time (h)');
ylabel('Reliability (-)');

% Adjusted availability
% Ad. av = sum t_0 to t_max [delta_t * (1 - failure_rate(t))]
figure;
plot(plotO);
title('Adjusted availability over time');
xlabel('Time (h)');
ylabel('Adjusted availability (-)');

% Reliability per component %
for i = 1:size(relPerComp, 2)
    figure;
    plot(relPerComp(:, i));
    title(['Reliability over time for component: ', Components{i, 2}]);
    xlabel('Time (h)');
    ylabel('Reliability (-)');
end

% END Output %
