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

%% Monte-Carlo %%
% INIT %
Output_number = 0;
Output        = zeros(size(Tasks, 1), 1);
plotL         = [];
plotO         = [];
% END INIT %

% Execute MC %
for n = 1:50
    % Generate random input intervals for each of the tasks.
    inputs = GenerateRandomInput(Tasks);
    
    % Execute objective function to find objective-param.
    [Output_objective, plotLambda, plotObj] = ObjectFunction(inputs, t_max, t_p, Components, Tasks, VesselLocations);
    
    % Monte-Carlo check if is better solution.
    if Output_objective >= Output_number
        Output_number = Output_objective;
        Output        = inputs;
        plotL         = plotLambda;
        plotO         = plotObj;
    end
end
% END Execute MC %

% Output %
disp(['De gevonden maximum adjusted availability is ', num2str(Output_number), ' bij een de volgende intervallen: ']);
disp(Output);
figure;
plot(plotL);
title('Reliability over time')
xlabel('Time (h)');
ylabel('Reliability (-)');
figure;
plot(plotO);
title('Adjusted availability over time');
xlabel('Time (h)');
ylabel('Adjusted availability (-)');
% END Output %