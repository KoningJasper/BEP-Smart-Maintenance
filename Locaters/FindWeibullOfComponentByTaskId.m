function [ beta, eta ] = FindWeibullOfComponentByTaskId( task_id, tasks, components )
    %FINDWEIBULLOFTASK Find the Weibull parameters of a task.
    task = LocateTaskById(task_id, tasks);
    component = LocateComponentById(task{1, 7}, components);
    beta = component{1, 4};
    eta = component{1, 3};
end

