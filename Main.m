% Clear
clear all;
close all;
clc;

% Parameters
t_p     = 1;  % Time Step (h)
no_runs = 50; % Number of MonteCarlo runs.

% Read data
Components      = DataReader('Data/Components.xls');
Tasks           = DataReader('Data/Tasks.xls');
VesselLocations = DataReader('Data/VesselLocations.xls');

% Set params according to data
t_max = (length(VesselLocations) - 1) * t_p; % in h

%% Monte-Carlo %%
% INIT %
Output_number = 0;
Output        = zeros(size(Tasks, 1), 1);
plotL         = [];
plotO         = [];
relPerComp    = [];
% END INIT %

% Execute MC %
for n = 1:no_runs
    % Generate random input intervals for each of the tasks.
    inputs = GenerateRandomInput(Tasks);
    
    % Execute objective function to find objective-param.
    [Output_objective, plotLambda, plotObj, lambdaOverTime] = ObjectFunction(inputs, t_max, t_p, Components, Tasks, VesselLocations);
    
    % Monte-Carlo check if is better solution.
    if Output_objective >= Output_number
        Output_number = Output_objective;
        Output        = inputs;
        plotL         = plotLambda;
        plotO         = plotObj;
        relPerComp    = lambdaOverTime;
    end
end
% END Execute MC %

%% Output %%
disp(['De gevonden maximum adjusted availability is ', num2str(round(Output_number, 1)), ' h bij een de volgende onderhouds-intervallen: ']);
table((1:size(Output, 1))', Output, 'VariableNames', {'Taak', 'Interval'})

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