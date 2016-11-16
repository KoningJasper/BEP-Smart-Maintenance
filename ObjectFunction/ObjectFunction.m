function [ Output_Objective ] = Objective_Function(step_size_time, ...
    no_time_steps, no_components, no_tasks, simulated_data, ...
    maintenance_intervals, ship_schedule )



%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
interval = round(simulated_data.*maintenance_intervals); % no. of timesteps between maintenance

for i = 1:no_tasks
    no_executed_maintenance = floor(no_time_steps/interval(i));

    for j = 1:no_executed_maintenance
        if ship_schedule(j*interval)== 0  %0 is op zee, 1 is in de haven
            Output_Objective = 0;
            return
        end
    end
end
