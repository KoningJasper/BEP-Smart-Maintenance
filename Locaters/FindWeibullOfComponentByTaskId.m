function [ beta, eta ] = FindWeibullOfComponentByTaskId( task_id, tasks, components )
    %FINDWEIBULLOFTASK Find the Weibull parameters of a task.
    component = LocateComponentById(component_id, components);
    beta      = component{1, 4};
    eta       = component{1, 3};
end

