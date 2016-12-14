function [ Failure_Rate_Per_Task ] = ConstructFailureRateGraphsPerTask(t_max, Tasks, Components)
%CONSTRUCTFAILURERATEGRAPHS Summary of this function goes here
% Detailed explanation goes here
    t = 1:(t_max + 1);
    no_tasks = size(Tasks, 1);
    Failure_Rate_Per_Task = zeros(no_tasks, t_max + 1);
    for i = 1:no_tasks
        [beta, theta] = FindWeibullOfComponentById(Tasks{i, 7}, Components);
        m1 = Tasks{i, 8};
        Failure_Rate_Per_Task(i, :) = beta/theta .* (((((1/m1) .* (t)) / theta).^(beta-1)));
    end
end

